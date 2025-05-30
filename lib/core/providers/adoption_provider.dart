// lib/shared/providers/adoption_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/model/adoption_request_model.dart';

import '../../core/services/adoption_service.dart';

// Provider para pedidos públicos de adoção
final publicAdoptionRequestsProvider =
    FutureProvider<List<AdoptionRequestModel>>((ref) async {
  return await AdoptionService.getPublicAdoptionRequests();
});

// Stream provider para pedidos em tempo real
final watchPublicAdoptionRequestsProvider =
    StreamProvider<List<AdoptionRequestModel>>((ref) {
  return AdoptionService.watchPublicAdoptionRequests();
});

// State para filtros da lista pública
final adoptionFiltersProvider =
    StateNotifierProvider<AdoptionFiltersNotifier, AdoptionFilters>((ref) {
  return AdoptionFiltersNotifier();
});

class AdoptionFilters {
  final String searchTerm;
  final List<String> petTypes;
  final int maxDaysRemaining;

  const AdoptionFilters({
    this.searchTerm = '',
    this.petTypes = const [],
    this.maxDaysRemaining = 5,
  });

  AdoptionFilters copyWith({
    String? searchTerm,
    List<String>? petTypes,
    int? maxDaysRemaining,
  }) {
    return AdoptionFilters(
      searchTerm: searchTerm ?? this.searchTerm,
      petTypes: petTypes ?? this.petTypes,
      maxDaysRemaining: maxDaysRemaining ?? this.maxDaysRemaining,
    );
  }
}

class AdoptionFiltersNotifier extends StateNotifier<AdoptionFilters> {
  AdoptionFiltersNotifier() : super(const AdoptionFilters());

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

  void clearFilters() {
    state = const AdoptionFilters();
  }
}

// Notifier para ações de adoção
class AdoptionNotifier extends StateNotifier<AsyncValue<void>> {
  AdoptionNotifier() : super(const AsyncValue.data(null));

  Future<String> createAdoptionRequest({
    required String requesterId,
    required String requesterName,
    required List<String> selectedPetIds,
  }) async {
    try {
      state = const AsyncValue.loading();
      final requestId = await AdoptionService.createAdoptionRequest(
        requesterId: requesterId,
        requesterdisplayName: requesterName,
        selectedPetIds: selectedPetIds,
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
    required String coParentName,
  }) async {
    try {
      state = const AsyncValue.loading();
      await AdoptionService.acceptAdoptionRequest(
        requestId: requestId,
        petId: petId,
        coParentId: coParentId,
        coParentdisplayName: coParentName,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<String> generateShareLink(String requestId) async {
    try {
      return await AdoptionService.generateShareLink(requestId);
    } catch (error) {
      rethrow;
    }
  }
}

final adoptionNotifierProvider =
    StateNotifierProvider<AdoptionNotifier, AsyncValue<void>>((ref) {
  return AdoptionNotifier();
});
