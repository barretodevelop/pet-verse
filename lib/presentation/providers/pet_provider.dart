import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// StateNotifier para gerenciar pets disponíveis
class AvailablePetsNotifier extends StateNotifier<List<Pet>> {
  AvailablePetsNotifier() : super(_createInitialPets());

  /// Cria pets iniciais para o sistema
  static List<Pet> _createInitialPets() {
    return [
      Pet(
        id: 'p1',
        name: 'Max',
        imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🐶',
        type: 'Cachorro',
        description: 'Um cão leal e brincalhão que adora correr no parque.',
        generatedByUserId: null,
      ),
      Pet(
        id: 'p2',
        name: 'Mia',
        imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🐱',
        type: 'Gato',
        description: 'Uma gata curiosa e independente que adora explorar.',
        generatedByUserId: null,
      ),
      Pet(
        id: 'p3',
        name: 'Pip',
        imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🐦',
        type: 'Pássaro',
        description: 'Um pássaro colorido que adora cantar melodias.',
        generatedByUserId: null,
      ),
      Pet(
        id: 'p4',
        name: 'Coelhinho',
        imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🐰',
        type: 'Coelho',
        description: 'Um coelho muito fofo e saltitante que adora cenouras.',
        generatedByUserId: null,
      ),
      Pet(
        id: 'p5',
        name: 'Nemo',
        imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🐠',
        type: 'Peixe',
        description: 'Um peixe pequeno, mas aventureiro dos oceanos.',
        generatedByUserId: null,
      ),
    ];
  }

  /// Adiciona um novo pet à lista
  void addPet(Pet pet) {
    state = [...state, pet];
  }

  /// Marca um pet como adotado
  void markPetAsAdopted(String petId) {
    state = state.map((pet) {
      return pet.id == petId ? pet.copyWith(isAdopted: true) : pet;
    }).toList();
  }

  /// Remove um pet da lista (usado para pets deletados)
  void removePet(String petId) {
    state = state.where((pet) => pet.id != petId).toList();
  }

  /// Libera um pet gerado por usuário (torna disponível para todos)
  void releaseGeneratedPet(String userId, String petId) {
    state = state.map((pet) {
      if (pet.id == petId && pet.generatedByUserId == userId) {
        return pet.copyWith(generatedByUserId: null);
      }
      return pet;
    }).toList();
  }

  /// Atualiza as estatísticas de um pet adotado
  void updatePetStats(
    String petId, {
    int? hunger,
    int? happiness,
    int? energy,
    int? level,
    int? xp,
    int? xpToNextLevel,
  }) {
    state = state.map((pet) {
      if (pet.id == petId) {
        return pet.copyWith(
          hunger: hunger,
          happiness: happiness,
          energy: energy,
          level: level,
          xp: xp,
          xpToNextLevel: xpToNextLevel,
        );
      }
      return pet;
    }).toList();
  }

  /// Restaura pets iniciais (usado para reset)
  void resetToInitialPets() {
    state = _createInitialPets();
  }

  /// Carrega pets de uma fonte externa
  void loadPets(List<Pet> pets) {
    state = pets;
  }
}

/// StateNotifier para gerenciar solicitações de adoção ativas
class AdoptionRequestsNotifier extends StateNotifier<List<AdoptionRequest>> {
  AdoptionRequestsNotifier() : super(_createInitialRequests());

  /// Cria solicitações iniciais para demonstração
  static List<AdoptionRequest> _createInitialRequests() {
    return [
      AdoptionRequest(
        id: 'req1',
        creatorUserId: 'user_demo_1',
        petsInRequest: [
          Pet(
            id: 'p10',
            name: 'Bolt',
            imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=⚡',
            type: 'Cachorro',
            description: 'Veloz e cheio de energia para aventuras.',
          ),
          Pet(
            id: 'p11',
            name: 'Sombra',
            imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=👻',
            type: 'Gato',
            description: 'Um gato misterioso e carinhoso.',
          ),
          Pet(
            id: 'p12',
            name: 'Fluffy',
            imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🐑',
            type: 'Ovelha',
            description: 'Extremamente macia e tranquila.',
          ),
        ],
        daysLeft: 3,
      ),
      AdoptionRequest(
        id: 'req2',
        creatorUserId: 'user_demo_2',
        petsInRequest: [
          Pet(
            id: 'p13',
            name: 'Robô',
            imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🤖',
            type: 'Robô-Pet',
            description: 'Um companheiro tecnológico e inteligente.',
          ),
          Pet(
            id: 'p14',
            name: 'Fofura',
            imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🌸',
            type: 'Coelho',
            description: 'Adora cenouras e abraços calorosos.',
          ),
          Pet(
            id: 'p15',
            name: 'Asa',
            imageUrl: 'https://placehold.co/60x60/cccccc/000000?text=🦅',
            type: 'Águia',
            description: 'Corajosa e com visão aguçada.',
          ),
        ],
        daysLeft: 5,
      ),
    ];
  }

  /// Adiciona uma nova solicitação
  void addRequest(AdoptionRequest request) {
    state = [...state, request];
  }

  /// Completa uma solicitação de adoção
  void completeRequest(
      String requestId, String joinerUserId, String chosenPetId) {
    state = state.map((request) {
      if (request.id == requestId) {
        return request.complete(joinerUserId, chosenPetId);
      }
      return request;
    }).toList();
  }

  /// Remove uma solicitação
  void removeRequest(String requestId) {
    state = state.where((request) => request.id != requestId).toList();
  }

  /// Cancela uma solicitação
  void cancelRequest(String requestId) {
    state = state.map((request) {
      if (request.id == requestId) {
        return request.cancel();
      }
      return request;
    }).toList();
  }

  /// Expira solicitações antigas automaticamente
  void expireOldRequests() {
    state = state.map((request) {
      if (request.isExpired &&
          request.status == AdoptionRequestStatus.pending) {
        return request.expire();
      }
      return request;
    }).toList();
  }

  /// Limpa todas as solicitações
  void clear() {
    state = [];
  }

  /// Carrega solicitações de uma fonte externa
  void loadRequests(List<AdoptionRequest> requests) {
    state = requests;
  }
}

/// Provider para pets disponíveis
final availablePetsProvider =
    StateNotifierProvider<AvailablePetsNotifier, List<Pet>>((ref) {
  return AvailablePetsNotifier();
});

/// Provider para solicitações de adoção ativas
final activeAdoptionRequestsProvider =
    StateNotifierProvider<AdoptionRequestsNotifier, List<AdoptionRequest>>(
        (ref) {
  return AdoptionRequestsNotifier();
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

// =======================================
// Modal State Providers
// =======================================

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

// =======================================
// Computed Providers
// =======================================

/// Provider para pets disponíveis (não adotados)
final availablePetsNotAdoptedProvider = Provider<List<Pet>>((ref) {
  final pets = ref.watch(availablePetsProvider);
  return pets.where((pet) => !pet.isAdopted).toList();
});

/// Provider para pets do usuário atual
final userPetsProvider = Provider<List<Pet>>((ref) {
  final pets = ref.watch(availablePetsProvider);
  // Aqui você poderia filtrar por usuário se tivesse o ID do usuário atual
  return pets.where((pet) => pet.generatedByUserId != null).toList();
});

/// Provider para solicitações pendentes (que outros podem participar)
final pendingAdoptionRequestsProvider = Provider<List<AdoptionRequest>>((ref) {
  final requests = ref.watch(activeAdoptionRequestsProvider);
  return requests
      .where((request) =>
          request.status == AdoptionRequestStatus.pending && request.isActive)
      .toList();
});

/// Provider para contagem de pets por tipo
final petCountByTypeProvider = Provider<Map<String, int>>((ref) {
  final pets = ref.watch(availablePetsProvider);
  final countMap = <String, int>{};

  for (final pet in pets) {
    countMap[pet.type] = (countMap[pet.type] ?? 0) + 1;
  }

  return countMap;
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
final petsStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final pets = ref.watch(availablePetsProvider);
  final adoptedPet = ref.watch(currentAdoptedPetProvider);

  return {
    'totalPets': pets.length,
    'adoptedPets': pets.where((p) => p.isAdopted).length,
    'availablePets': pets.where((p) => !p.isAdopted).length,
    'userHasPet': adoptedPet != null,
    'averageLevel': adoptedPet?.level ?? 0,
  };
});

// =======================================
// Utility Functions
// =======================================

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

/// Extension para facilitar o uso dos providers de pets
extension PetProvidersExtensions on WidgetRef {
  /// Verifica se um pet pode ser selecionado
  bool canSelectPet(
      String petId, List<String> currentSelection, int maxSelection) {
    if (currentSelection.contains(petId)) return true; // Pode desselecionar
    return currentSelection.length < maxSelection;
  }

  /// Adiciona ou remove um pet da seleção
  void togglePetSelection(String petId,
      StateController<List<String>> controller, int maxSelection) {
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
}
