// lib/shared/providers/pet_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/model/pet_model.dart';
import 'package:petverse/core/services/pet_service.dart';

// Provider para pets disponíveis
final availablePetsProvider = FutureProvider<List<PetModel>>((ref) async {
  return await PetService.getAvailablePets();
});

// Provider para pets por IDs
final petsByIdsProvider =
    FutureProvider.family<List<PetModel>, List<String>>((ref, petIds) async {
  return await PetService.getPetsByIds(petIds);
});

// Provider para um pet específico
final petByIdProvider =
    FutureProvider.family<PetModel?, String>((ref, petId) async {
  return await PetService.getPetById(petId);
});

// State para pets selecionados na adoção
final selectedPetsProvider =
    StateNotifierProvider<SelectedPetsNotifier, List<String>>((ref) {
  return SelectedPetsNotifier();
});

class SelectedPetsNotifier extends StateNotifier<List<String>> {
  SelectedPetsNotifier() : super([]);

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
}
