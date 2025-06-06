// lib/presentation/providers/pet_provider.dart
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/firebase/firebase_analytics_service.dart';
import 'package:petverse/core/firebase/firestore_service.dart';
import 'package:petverse/core/providers/firebase_providers.dart';
import 'package:petverse/data/models/adoption_request_status.dart';
import 'package:petverse/data/models/pet.dart';

/// Enum para os estados do fluxo de adoção
enum AdoptionFlowStates {
  noPet,
  creatingRequest,
  adoptExistingFlow,
  adoptWithFriendFlow,
  requestActive,
  hasPet,
}

/// StateNotifier para gerenciar pets disponíveis integrado com Firebase
class AvailablePetsNotifier extends StateNotifier<AsyncValue<List<Pet>>> {
  final FirestoreService _firestoreService;
  final FirebaseAnalyticsService _analyticsService;
  final Ref _ref;

  AvailablePetsNotifier(
    this._firestoreService,
    this._analyticsService,
    this._ref,
  ) : super(const AsyncValue.loading()) {
    loadPets();
  }

  /// Carrega pets disponíveis do Firebase
  Future<void> loadPets() async {
    try {
      state = const AsyncValue.loading();

      final result = await _firestoreService.getAvailablePets(limit: 50);

      if (result.success) {
        final pets = result.data ?? [];
        state = AsyncValue.data(pets);

        // Log analytics
        await _analyticsService.logEvent(
          AnalyticsEvent.userLogin, // placeholder
          parameters: {
            'action': 'pets_loaded',
            'count': pets.length,
          },
        );
      } else {
        state = AsyncValue.error(
          result.error ?? 'Erro ao carregar pets',
          StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);

      // Log error
      await _analyticsService.logError(
        error: e,
        stackTrace: stackTrace,
        reason: 'Failed to load pets',
      );
    }
  }

  /// Adiciona um novo pet
  Future<bool> addPet(Pet pet) async {
    try {
      final result = await _firestoreService.savePet(pet);

      if (result.success) {
        // Recarrega a lista
        await loadPets();

        // Log analytics
        await _analyticsService.logPetGenerated(
          petId: result.data ?? pet.id,
          petType: pet.type,
          userId: pet.generatedByUserId,
          isUnique: pet.generatedByUserId != null,
        );

        return true;
      }

      return false;
    } catch (e, stackTrace) {
      await _analyticsService.logError(
        error: e,
        stackTrace: stackTrace,
        reason: 'Failed to add pet',
      );
      return false;
    }
  }

  /// Marca um pet como adotado
  Future<bool> markPetAsAdopted(String petId, {String? adopterId}) async {
    try {
      final result = await _firestoreService.updatePetStatus(
        petId,
        isAdopted: true,
      );

      if (result.success) {
        // Atualiza estado local
        state.whenData((pets) {
          final updatedPets = pets.map((pet) {
            return pet.id == petId ? pet.copyWith(isAdopted: true) : pet;
          }).toList();
          state = AsyncValue.data(updatedPets);
        });

        // Log analytics
        final pet = await _getPetById(petId);
        if (pet != null) {
          await _analyticsService.logPetAdopted(
            petId: petId,
            petType: pet.type,
            adoptionType: 'individual',
            userId: adopterId,
          );
        }

        return true;
      }

      return false;
    } catch (e, stackTrace) {
      await _analyticsService.logError(
        error: e,
        stackTrace: stackTrace,
        reason: 'Failed to mark pet as adopted',
      );
      return false;
    }
  }

  /// Atualiza estatísticas de um pet
  Future<bool> updatePetStats(
    String petId, {
    int? hunger,
    int? happiness,
    int? energy,
    int? level,
    int? xp,
  }) async {
    try {
      final result = await _firestoreService.updatePetStatus(
        petId,
        hunger: hunger,
        happiness: happiness,
        energy: energy,
        level: level,
        xp: xp,
      );

      if (result.success) {
        // Atualiza estado local
        state.whenData((pets) {
          final updatedPets = pets.map((pet) {
            if (pet.id == petId) {
              return pet.copyWith(
                hunger: hunger,
                happiness: happiness,
                energy: energy,
                level: level,
                xp: xp,
              );
            }
            return pet;
          }).toList();
          state = AsyncValue.data(updatedPets);
        });

        return true;
      }

      return false;
    } catch (e, stackTrace) {
      await _analyticsService.logError(
        error: e,
        stackTrace: stackTrace,
        reason: 'Failed to update pet stats',
      );
      return false;
    }
  }

  /// Alimenta um pet
  Future<bool> feedPet(String petId, String? userId) async {
    try {
      final pet = await _getPetById(petId);
      if (pet == null) return false;

      final newHunger = (pet.hunger + 20).clamp(0, 100);
      final newHappiness = (pet.happiness + 5).clamp(0, 100);

      final success = await updatePetStats(
        petId,
        hunger: newHunger,
        happiness: newHappiness,
      );

      if (success) {
        // Log analytics
        await _analyticsService.logPetAction(
          action: 'fed',
          petId: petId,
          userId: userId,
          cost: 10,
        );
      }

      return success;
    } catch (e, stackTrace) {
      await _analyticsService.logError(
        error: e,
        stackTrace: stackTrace,
        reason: 'Failed to feed pet',
      );
      return false;
    }
  }

  /// Brinca com um pet
  Future<bool> playWithPet(String petId, String? userId) async {
    try {
      final pet = await _getPetById(petId);
      if (pet == null) return false;

      final newHunger = (pet.hunger - 10).clamp(0, 100);
      final newHappiness = (pet.happiness + 25).clamp(0, 100);
      final newEnergy = (pet.energy - 15).clamp(0, 100);
      final newXp = pet.xp + 10;

      final success = await updatePetStats(
        petId,
        hunger: newHunger,
        happiness: newHappiness,
        energy: newEnergy,
        xp: newXp,
      );

      if (success) {
        // Log analytics
        await _analyticsService.logPetAction(
          action: 'played',
          petId: petId,
          userId: userId,
          cost: 5,
        );
      }

      return success;
    } catch (e, stackTrace) {
      await _analyticsService.logError(
        error: e,
        stackTrace: stackTrace,
        reason: 'Failed to play with pet',
      );
      return false;
    }
  }

  /// Obtém pet por ID
  Future<Pet?> _getPetById(String petId) async {
    return state.when(
      data: (pets) => pets.firstWhere(
        (pet) => pet.id == petId,
        orElse: () => Pet(
          id: '',
          name: '',
          imageUrl: '',
          type: '',
          description: '',
        ),
      ),
      loading: () => null,
      error: (_, __) => null,
    );
  }

  /// Refresh manual
  Future<void> refresh() => loadPets();
}

/// StateNotifier para gerenciar solicitações de adoção integrado com Firebase
class AdoptionRequestsNotifier
    extends StateNotifier<AsyncValue<List<AdoptionRequest>>> {
  final FirestoreService _firestoreService;
  final FirebaseAnalyticsService _analyticsService;

  AdoptionRequestsNotifier(
    this._firestoreService,
    this._analyticsService,
  ) : super(const AsyncValue.loading()) {
    loadRequests();
  }

  /// Carrega solicitações ativas do Firebase
  Future<void> loadRequests() async {
    try {
      state = const AsyncValue.loading();

      final result = await _firestoreService.getActiveAdoptionRequests();

      if (result.success) {
        state = AsyncValue.data(result.data ?? []);
      } else {
        state = AsyncValue.error(
          result.error ?? 'Erro ao carregar solicitações',
          StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);

      await _analyticsService.logError(
        error: e,
        stackTrace: stackTrace,
        reason: 'Failed to load adoption requests',
      );
    }
  }

  /// Adiciona uma nova solicitação
  Future<bool> addRequest(AdoptionRequest request) async {
    try {
      final result = await _firestoreService.saveAdoptionRequest(request);

      if (result.success) {
        await loadRequests();

        // Log analytics
        await _analyticsService.logAdoptionRequest(
          requestId: result.data ?? request.id,
          action: 'created',
          userId: request.creatorUserId,
          petsCount: request.petsInRequest.length,
        );

        return true;
      }

      return false;
    } catch (e, stackTrace) {
      await _analyticsService.logError(
        error: e,
        stackTrace: stackTrace,
        reason: 'Failed to add adoption request',
      );
      return false;
    }
  }

  /// Completa uma solicitação de adoção
  Future<bool> completeRequest(
    String requestId,
    String joinerUserId,
    String chosenPetId,
  ) async {
    try {
      final result = await _firestoreService.updateAdoptionRequestStatus(
        requestId,
        AdoptionRequestStatus.completed,
        joinerUserId: joinerUserId,
        chosenPetId: chosenPetId,
      );

      if (result.success) {
        await loadRequests();

        // Log analytics
        await _analyticsService.logAdoptionRequest(
          requestId: requestId,
          action: 'completed',
          userId: joinerUserId,
        );

        return true;
      }

      return false;
    } catch (e, stackTrace) {
      await _analyticsService.logError(
        error: e,
        stackTrace: stackTrace,
        reason: 'Failed to complete adoption request',
      );
      return false;
    }
  }

  /// Cancela uma solicitação
  Future<bool> cancelRequest(String requestId, String userId) async {
    try {
      final result = await _firestoreService.updateAdoptionRequestStatus(
        requestId,
        AdoptionRequestStatus.cancelled,
      );

      if (result.success) {
        await loadRequests();

        // Log analytics
        await _analyticsService.logAdoptionRequest(
          requestId: requestId,
          action: 'cancelled',
          userId: userId,
        );

        return true;
      }

      return false;
    } catch (e, stackTrace) {
      await _analyticsService.logError(
        error: e,
        stackTrace: stackTrace,
        reason: 'Failed to cancel adoption request',
      );
      return false;
    }
  }

  /// Refresh manual
  Future<void> refresh() => loadRequests();
}

// ========================================
// PROVIDERS ATUALIZADOS COM FIREBASE
// ========================================

/// Provider para pets disponíveis usando Firebase
final availablePetsProvider =
    StateNotifierProvider<AvailablePetsNotifier, AsyncValue<List<Pet>>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final analyticsService = FirebaseAnalyticsService.instance;

  return AvailablePetsNotifier(
    firestoreService,
    analyticsService,
    ref,
  );
});

/// Provider para solicitações de adoção usando Firebase
final activeAdoptionRequestsProvider = StateNotifierProvider<
    AdoptionRequestsNotifier, AsyncValue<List<AdoptionRequest>>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final analyticsService = FirebaseAnalyticsService.instance;

  return AdoptionRequestsNotifier(
    firestoreService,
    analyticsService,
  );
});

/// Provider para o estado do fluxo de adoção
final adoptionFlowStateProvider = StateProvider<AdoptionFlowStates>((ref) {
  return AdoptionFlowStates.noPet;
});

/// Provider para o pet atualmente adotado
final currentAdoptedPetProvider = StateProvider<Pet?>((ref) => null);

/// Provider para pets selecionados na criação de solicitação
final selectedPetsForMyRequestIdsProvider =
    StateProvider<List<String>>((ref) => []);

/// Provider para pets selecionados na adoção com amigo
final selectedPetsForFriendAdoptionIdsProvider =
    StateProvider<List<String>>((ref) => []);

/// Provider para código de adoção com amigo
final friendAdoptionCodeProvider = StateProvider<String>((ref) => '');

/// Provider para mensagens do sistema
final friendAdoptionMessageProvider = StateProvider<String>((ref) => '');

/// Provider para pet recém-gerado
final newlyGeneratedPetProvider = StateProvider<Pet?>((ref) => null);

/// Provider para erros de geração
final generationErrorProvider = StateProvider<String>((ref) => '');

/// Provider para status de geração
final generatingUniquePetProvider = StateProvider<bool>((ref) => false);

/// Provider para informações da solicitação de adoção
final adoptionRequestInfoProvider =
    StateProvider<Map<String, dynamic>>((ref) => {
          'views': 0,
          'daysLeft': 5,
          'petsSelected': <String>[],
          'fullPetsSelected': <Pet>[],
        });

// ========================================
// MODAL STATE PROVIDERS
// ========================================

/// Provider para controle do modal de detalhes do pet
final petDetailsModalOpenProvider = StateProvider<bool>((ref) => false);

/// Provider para o pet no modal
final petInModalProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

/// Provider para controle do modal de participar em adoção
final joinAdoptionModalOpenProvider = StateProvider<bool>((ref) => false);

/// Provider para a solicitação no modal
final requestInModalProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

/// Provider para controle do modal de detalhes da própria solicitação
final myRequestDetailsModalOpenProvider = StateProvider<bool>((ref) => false);

// ========================================
// COMPUTED PROVIDERS ATUALIZADOS
// ========================================

/// Provider para pets disponíveis (não adotados) usando Firebase
final availablePetsNotAdoptedProvider = Provider<AsyncValue<List<Pet>>>((ref) {
  final petsAsync = ref.watch(availablePetsProvider);

  return petsAsync.when(
    data: (pets) => AsyncValue.data(
      pets.where((pet) => !pet.isAdopted).toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider para pets do usuário atual usando Firebase
final userPetsProvider = Provider<AsyncValue<List<Pet>>>((ref) {
  final userId = ref.watch(firebaseCurrentUserProvider)?.uid;

  if (userId == null) {
    return const AsyncValue.data([]);
  }

  return ref.watch(userPetsFirebaseProvider(userId));
});

/// Provider para solicitações pendentes (que outros podem participar)
final pendingAdoptionRequestsProvider =
    Provider<AsyncValue<List<AdoptionRequest>>>((ref) {
  final requestsAsync = ref.watch(activeAdoptionRequestsProvider);

  return requestsAsync.when(
    data: (requests) => AsyncValue.data(
      requests
          .where((request) =>
              request.status == AdoptionRequestStatus.pending &&
              request.isActive)
          .toList(),
    ),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider para contagem de pets por tipo
final petCountByTypeProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  final petsAsync = ref.watch(availablePetsProvider);

  return petsAsync.when(
    data: (pets) {
      final countMap = <String, int>{};
      for (final pet in pets) {
        countMap[pet.type] = (countMap[pet.type] ?? 0) + 1;
      }
      return AsyncValue.data(countMap);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Provider para verificar se o usuário pode criar uma nova solicitação
final canCreateRequestProvider = Provider<bool>((ref) {
  final flowState = ref.watch(adoptionFlowStateProvider);
  final selectedPets = ref.watch(selectedPetsForMyRequestIdsProvider);

  return flowState == AdoptionFlowStates.creatingRequest &&
      selectedPets.length == 3;
});

/// Provider para verificar se há pets críticos
final hasCriticalPetsProvider = Provider<bool>((ref) {
  final adoptedPet = ref.watch(currentAdoptedPetProvider);
  return adoptedPet?.isCriticalStatus ?? false;
});

/// Provider para estatísticas gerais dos pets
final petsStatsProvider = Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  final petsAsync = ref.watch(availablePetsProvider);
  final adoptedPet = ref.watch(currentAdoptedPetProvider);

  return petsAsync.when(
    data: (pets) => AsyncValue.data({
      'totalPets': pets.length,
      'adoptedPets': pets.where((p) => p.isAdopted).length,
      'availablePets': pets.where((p) => !p.isAdopted).length,
      'userHasPet': adoptedPet != null,
      'averageLevel': adoptedPet?.level ?? 0,
    }),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// ========================================
// UTILITY FUNCTIONS
// ========================================

/// Gera um ID único para pets
String generatePetId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = Random();
  final randomPart =
      List.generate(6, (_) => random.nextInt(36).toRadixString(36)).join();
  return 'pet_${timestamp}_$randomPart';
}

/// Gera um ID único para solicitações
String generateRequestId() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final random = Random();
  final randomPart =
      List.generate(4, (_) => random.nextInt(36).toRadixString(36)).join();
  return 'req_${timestamp}_$randomPart';
}

/// Gera um código aleatório para adoção com amigo
String generateAdoptionCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random();
  return String.fromCharCodes(
    Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
  );
}

// ========================================
// EXTENSIONS PARA FACILITAR O USO
// ========================================

extension PetProvidersExtensions on WidgetRef {
  /// Verifica se um pet pode ser selecionado
  bool canSelectPet(
      String petId, List<String> currentSelection, int maxSelection) {
    if (currentSelection.contains(petId)) return true; // Pode desselecionar
    return currentSelection.length < maxSelection;
  }

  /// Adiciona ou remove um pet da seleção
  void togglePetSelection(
    String petId,
    StateController<List<String>> controller,
    int maxSelection,
  ) {
    final current = controller.state;
    if (current.contains(petId)) {
      controller.state = current.where((id) => id != petId).toList();
    } else if (current.length < maxSelection) {
      controller.state = [...current, petId];
    }
  }

  /// Limpa todas as seleções
  void clearAllSelections() {
    read(selectedPetsForMyRequestIdsProvider.notifier).state = [];
    read(selectedPetsForFriendAdoptionIdsProvider.notifier).state = [];
    read(friendAdoptionCodeProvider.notifier).state = '';
    read(friendAdoptionMessageProvider.notifier).state = '';
  }

  /// Verifica se o usuário tem um pet adotado
  bool get hasPet => read(currentAdoptedPetProvider) != null;

  /// Retorna o pet atual ou null
  Pet? get currentPet => read(currentAdoptedPetProvider);

  /// Refresh de pets usando Firebase
  Future<void> refreshPets() async {
    read(availablePetsProvider.notifier).refresh();
  }

  /// Refresh de solicitações usando Firebase
  Future<void> refreshAdoptionRequests() async {
    read(activeAdoptionRequestsProvider.notifier).refresh();
  }

  /// Alimenta pet e atualiza no Firebase
  Future<bool> feedPet(String petId) async {
    final userId = read(firebaseCurrentUserProvider)?.uid;
    return read(availablePetsProvider.notifier).feedPet(petId, userId);
  }

  /// Brinca com pet e atualiza no Firebase
  Future<bool> playWithPet(String petId) async {
    final userId = read(firebaseCurrentUserProvider)?.uid;
    return read(availablePetsProvider.notifier).playWithPet(petId, userId);
  }

  /// Adiciona pet no Firebase
  Future<bool> addPet(Pet pet) async {
    return read(availablePetsProvider.notifier).addPet(pet);
  }

  /// Marca pet como adotado no Firebase
  Future<bool> markPetAsAdopted(String petId) async {
    final userId = read(firebaseCurrentUserProvider)?.uid;
    return read(availablePetsProvider.notifier)
        .markPetAsAdopted(petId, adopterId: userId);
  }
}
