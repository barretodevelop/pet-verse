// lib/core/providers/firebase_adoption_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/model/firebase_pet_model.dart';
import 'package:petverse/core/services/firebase_adoption_service.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';

// NEW: Provider para pets colaborativos disponíveis
final availableCollaborativePetsProvider =
    FutureProvider<List<FirebasePetModel>>((ref) async {
  return await FirebaseAdoptionService.getAvailablePetsForCollaboration();
});

// NEW: Provider para pedidos públicos de adoção (Firebase)
final publicAdoptionRequestsFirebaseProvider =
    FutureProvider<List<CollaborativeAdoptionRequest>>((ref) async {
  return await FirebaseAdoptionService.getPublicAdoptionRequests();
});

// NEW: Stream provider para pedidos em tempo real
final watchPublicAdoptionRequestsFirebaseProvider =
    StreamProvider<List<CollaborativeAdoptionRequest>>((ref) {
  return FirebaseAdoptionService.watchPublicAdoptionRequests();
});

// UPDATE: State para pets selecionados na criação de adoção
final selectedCollaborativePetsProvider =
    StateNotifierProvider<SelectedCollaborativePetsNotifier, List<String>>(
        (ref) {
  return SelectedCollaborativePetsNotifier();
});

class SelectedCollaborativePetsNotifier extends StateNotifier<List<String>> {
  SelectedCollaborativePetsNotifier() : super([]);

  void addPet(String petId) {
    if (state.length < 3 && !state.contains(petId)) {
      state = [...state, petId];
    }
  }

  void removePet(String petId) {
    state = state.where((id) => id != petId).toList();
  }

  void togglePet(String petId) {
    if (state.contains(petId)) {
      removePet(petId);
    } else {
      addPet(petId);
    }
  }

  void clear() {
    state = [];
  }

  bool isPetSelected(String petId) => state.contains(petId);
  bool get canSelectMore => state.length < 3;
  bool get hasSelection => state.isNotEmpty;
  bool get isComplete => state.length == 3;
}

// NEW: Provider para pets de um pedido específico
final petsFromRequestProvider =
    FutureProvider.family<List<FirebasePetModel>, String>(
        (ref, requestId) async {
  return await FirebaseAdoptionService.getPetsFromRequest(requestId);
});

// NEW: Provider para pets do usuário atual
final userPetsProvider = FutureProvider<List<FirebasePetModel>>((ref) async {
  final authState = ref.watch(authenticationNotifierProvider);
  if (authState.user?.uid == null) return [];

  return await FirebaseAdoptionService.getUserPets(authState.user!.uid);
});

// NEW: State para filtros da lista pública (Firebase)
final adoptionFiltersFirebaseProvider = StateNotifierProvider<
    AdoptionFiltersFirebaseNotifier, AdoptionFiltersFirebase>((ref) {
  return AdoptionFiltersFirebaseNotifier();
});

class AdoptionFiltersFirebase {
  final String searchTerm;
  final List<String> petTypes;
  final int maxDaysRemaining;
  final String region;

  const AdoptionFiltersFirebase({
    this.searchTerm = '',
    this.petTypes = const [],
    this.maxDaysRemaining = 5,
    this.region = '',
  });

  AdoptionFiltersFirebase copyWith({
    String? searchTerm,
    List<String>? petTypes,
    int? maxDaysRemaining,
    String? region,
  }) {
    return AdoptionFiltersFirebase(
      searchTerm: searchTerm ?? this.searchTerm,
      petTypes: petTypes ?? this.petTypes,
      maxDaysRemaining: maxDaysRemaining ?? this.maxDaysRemaining,
      region: region ?? this.region,
    );
  }
}

class AdoptionFiltersFirebaseNotifier
    extends StateNotifier<AdoptionFiltersFirebase> {
  AdoptionFiltersFirebaseNotifier() : super(const AdoptionFiltersFirebase());

  void updateSearchTerm(String term) {
    state = state.copyWith(searchTerm: term);
  }

  void togglePetType(String type) {
    final currentTypes = List<String>.from(state.petTypes);
    if (currentTypes.contains(type)) {
      currentTypes.remove(type);
    } else {
      currentTypes.add(type);
    }
    state = state.copyWith(petTypes: currentTypes);
  }

  void updateMaxDays(int days) {
    state = state.copyWith(maxDaysRemaining: days);
  }

  void updateRegion(String region) {
    state = state.copyWith(region: region);
  }

  void clearFilters() {
    state = const AdoptionFiltersFirebase();
  }
}

// NEW: Provider para pedidos filtrados
final filteredAdoptionRequestsProvider =
    FutureProvider<List<CollaborativeAdoptionRequest>>((ref) async {
  final filters = ref.watch(adoptionFiltersFirebaseProvider);

  return await FirebaseAdoptionService.getFilteredRequests(
    petTypes: filters.petTypes.isEmpty ? null : filters.petTypes,
    maxDaysRemaining: filters.maxDaysRemaining,
    region: filters.region.isEmpty ? null : filters.region,
  );
});

// NEW: Notifier para ações de adoção Firebase
class FirebaseAdoptionNotifier extends StateNotifier<AsyncValue<void>> {
  FirebaseAdoptionNotifier() : super(const AsyncValue.data(null));

  Future<String> createCollaborativeAdoptionRequest({
    required String requesterId,
    required String requesterDisplayName,
    required String requesterCodename,
    required int requesterColorTheme,
    required int requesterLevel,
    required List<String> selectedPetIds,
    required String codedMessage,
    required List<String> personalityTags,
    required String region,
  }) async {
    try {
      state = const AsyncValue.loading();

      final requestId =
          await FirebaseAdoptionService.createCollaborativeAdoptionRequest(
        requesterId: requesterId,
        requesterDisplayName: requesterDisplayName,
        requesterCodename: requesterCodename,
        requesterColorTheme: requesterColorTheme,
        requesterLevel: requesterLevel,
        selectedPetIds: selectedPetIds,
        codedMessage: codedMessage,
        personalityTags: personalityTags,
        region: region,
      );

      state = const AsyncValue.data(null);
      return requestId;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> acceptAdoptionRequest({
    required String requestId,
    required String petId,
    required String coParentId,
    required String coParentDisplayName,
    required String coParentCodename,
  }) async {
    try {
      state = const AsyncValue.loading();

      await FirebaseAdoptionService.acceptAdoptionRequest(
        requestId: requestId,
        petId: petId,
        coParentId: coParentId,
        coParentDisplayName: coParentDisplayName,
        coParentCodename: coParentCodename,
      );

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<String> generateShareLink(String requestId) async {
    try {
      return await FirebaseAdoptionService.generateShareLink(requestId);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> incrementViews(String requestId) async {
    try {
      await FirebaseAdoptionService.incrementViews(requestId);
    } catch (error) {
      // Silenciar erro de views para não afetar UX
      print('Erro ao incrementar views: $error');
    }
  }

  Future<void> incrementInterest(String requestId) async {
    try {
      await FirebaseAdoptionService.incrementInterest(requestId);
    } catch (error) {
      // Silenciar erro de interesse para não afetar UX
      print('Erro ao incrementar interesse: $error');
    }
  }

  Future<void> cancelAdoptionRequest(String requestId) async {
    try {
      state = const AsyncValue.loading();
      await FirebaseAdoptionService.cancelAdoptionRequest(requestId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final firebaseAdoptionNotifierProvider =
    StateNotifierProvider<FirebaseAdoptionNotifier, AsyncValue<void>>((ref) {
  return FirebaseAdoptionNotifier();
});

// NEW: Provider para inicialização de dados mock (executar uma vez)
final initializeMockDataProvider = FutureProvider<bool>((ref) async {
  try {
    await FirebaseAdoptionService.initializeMockDataInFirebase();
    return true;
  } catch (e) {
    print('Erro ao inicializar dados mock: $e');
    return false;
  }
});

// NEW: Provider combinado para status da inicialização
final adoptionSystemStatusProvider = Provider<
    ({
      bool isInitialized,
      bool hasError,
      String? errorMessage,
    })>((ref) {
  final initAsync = ref.watch(initializeMockDataProvider);

  return initAsync.when(
    data: (isInitialized) => (
      isInitialized: isInitialized,
      hasError: false,
      errorMessage: null,
    ),
    loading: () => (
      isInitialized: false,
      hasError: false,
      errorMessage: null,
    ),
    error: (error, _) => (
      isInitialized: false,
      hasError: true,
      errorMessage: error.toString(),
    ),
  );
});
