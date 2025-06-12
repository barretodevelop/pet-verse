// PetProvider
// lib/providers/pet_provider.dart - PetProvider
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/models/pet_model.dart';
import 'package:petverse/providers/user_provider.dart'; // Para obter o userId
import 'package:petverse/services/firestore_service.dart';

final petProvider = StateNotifierProvider<PetNotifier, List<PetModel>>((ref) {
  final userId = ref.watch(userProvider.select((user) => user?.id));
  // Instancie o FirestoreService aqui. Se ele for um provider, use ref.watch.
  return PetNotifier(ref, userId, FirestoreService());
});

class PetNotifier extends StateNotifier<List<PetModel>> {
  final Ref _ref;
  final String? _userId; // Armazena o userId atual
  final FirestoreService _firestoreService;
  StreamSubscription? _petsSubscription;

  PetNotifier(this._ref, this._userId, this._firestoreService) : super([]) {
    if (_userId != null) {
      _listenToPetChanges(_userId!);
    } else {
      print(
          '⚠️ PetNotifier: UserId is null at initialization, cannot load pets.');
    }
  }

  void _listenToPetChanges(String userId) {
    _petsSubscription?.cancel(); // Cancela a inscrição anterior, se houver
    _petsSubscription = _firestoreService.getUserPets(userId).listen(
      (pets) {
        state = pets;
        print(
            '✅ PetProvider: Pets list updated with ${state.length} pets for user $userId');
      },
      onError: (error) {
        print(
            '❌ PetProvider: Error listening to pet changes for user $userId: $error');
        state = []; // Limpa o estado em caso de erro
      },
    );
  }

  // Chamado pelo AppNotifier quando o usuário loga ou desloga
  void updateUserContext(String? newUserId) {
    // Não é ideal modificar _userId diretamente se for final,
    // mas para este exemplo, vamos assumir que o provider será recriado ou
    // que o _userId no construtor é o que importa para a subscrição inicial.
    // A melhor prática é o provider ser recriado quando o userId muda.
    // No entanto, para um StateNotifier que precisa de um userId para sua stream,
    // este método pode reiniciar a escuta.
    if (newUserId != null && newUserId != _userId) {
      // Apenas se o ID realmente mudou
      print(
          '🔄 PetNotifier: User context updated to $newUserId. Reloading pets.');
      _listenToPetChanges(newUserId);
    } else if (newUserId == null) {
      print('🔄 PetNotifier: User logged out. Clearing pets.');
      _petsSubscription?.cancel();
      state = [];
    }
  }

  void setPets(List<PetModel> pets) {
    state = pets;
    print('ℹ️ PetNotifier: Pets set manually. Count: ${state.length}');
  }

  Future<void> addPet(PetModel pet) async {
    if (_userId == null) {
      print('❌ PetNotifier: Cannot add pet, user not logged in.');
      throw Exception('User not logged in.');
    }
    try {
      // Garante que o ownerId está correto antes de salvar
      final petWithOwnerId = pet.copyWith(ownerId: _userId);
      await _firestoreService.createPet(petWithOwnerId);
      print('✅ PetNotifier: Request to add pet ${pet.name} sent to Firestore.');
      // O estado será atualizado pelo listener do stream
    } catch (e) {
      print('❌ PetNotifier: Failed to add pet ${pet.name}: $e');
      rethrow;
    }
  }

  // Renomeado de updatePet para updatePetData para clareza
  Future<void> updatePetData(PetModel updatedPet) async {
    try {
      await _firestoreService.updatePet(updatedPet);
      print(
          '✅ PetNotifier: Request to update pet ${updatedPet.name} sent to Firestore.');
      // O estado será atualizado pelo listener do stream
      // Para feedback imediato, você PODE atualizar o estado local aqui,
      // mas esteja ciente de uma possível dupla atualização quando o stream emitir.
      // state = state.map((pet) => pet.id == updatedPet.id ? updatedPet : pet).toList();
    } catch (e) {
      print('❌ PetNotifier: Failed to update pet ${updatedPet.name}: $e');
      rethrow;
    }
  }

  Future<void> removePet(String petId) async {
    try {
      await _firestoreService.deletePet(petId);
      print('✅ PetNotifier: Request to remove pet $petId sent to Firestore.');
      // O estado será atualizado pelo listener do stream
    } catch (e) {
      print('❌ PetNotifier: Failed to remove pet $petId: $e');
      rethrow;
    }
  }

  Future<void> updatePetStats(String petId,
      {int? happiness, int? hunger, int? energy, int? health}) {
    final petToUpdate = state.firstWhere((p) => p.id == petId, orElse: () {
      // Lançar um erro ou retornar um valor nulo/padrão se o pet não for encontrado
      // Isso evita tentar atualizar um pet que não está no estado local.
      throw Exception(
          'Pet with ID $petId not found in local state for stat update.');
    });

    final updatedPet = petToUpdate.copyWith(
      happiness: happiness ?? petToUpdate.happiness,
      hunger: hunger ?? petToUpdate.hunger,
      energy: energy ?? petToUpdate.energy,
      health: health ?? petToUpdate.health,
      lastCared: DateTime.now(),
    );
    // Chama o método geral de atualização que salva no Firestore
    return updatePetData(updatedPet);
  }

  Future<void> addPetXP(String petId, int xpGain) {
    final petToUpdate = state.firstWhere((p) => p.id == petId, orElse: () {
      throw Exception(
          'Pet with ID $petId not found in local state for XP update.');
    });

    final newXP = petToUpdate.xp + xpGain;
    final newLevel = (newXP / 100).floor() + 1;
    final updatedPet = petToUpdate.copyWith(xp: newXP, level: newLevel);
    // Chama o método geral de atualização que salva no Firestore
    return updatePetData(updatedPet);
  }

  @override
  void dispose() {
    _petsSubscription?.cancel();
    super.dispose();
  }
}
