// lib/core/services/user_service.dart
import 'package:petverse/core/model/pet_model.dart';
import 'package:petverse/core/model/user_model.dart';
import 'package:petverse/core/services/firebase_service.dart';

class UserService {
  static Future<UserModel?> getCurrentUser() async {
    final userId = FirebaseService.currentUserId;
    if (userId == null) return null;

    try {
      final doc = await FirebaseService.users.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  static Future<UserModel> updateUser(UserModel user) async {
    try {
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await FirebaseService.users
          .doc(user.id)
          .update(updatedUser.toFirestore());
      return updatedUser;
    } catch (e) {
      throw Exception('Erro ao atualizar usuário: $e');
    }
  }

  static Future<void> assignPetToUser(String userId, String petId) async {
    try {
      await FirebaseService.runTransaction((transaction) async {
        // Get user document
        final userDoc =
            await transaction.get(FirebaseService.users.doc(userId));
        if (!userDoc.exists) throw Exception('Usuário não encontrado');

        final user = UserModel.fromFirestore(userDoc);
        final updatedPetIds = [...user.petIds];
        if (!updatedPetIds.contains(petId)) {
          updatedPetIds.add(petId);
        }

        // Update user
        final updatedUser = user.copyWith(
          currentPetId: petId,
          petIds: updatedPetIds,
          updatedAt: DateTime.now(),
        );

        transaction.update(
          FirebaseService.users.doc(userId),
          updatedUser.toFirestore(),
        );

        // Update pet ownership
        final petDoc = await transaction.get(FirebaseService.pets.doc(petId));
        if (petDoc.exists) {
          final pet = PetModel.fromFirestore(petDoc);
          final updatedOwnerIds = [...pet.ownerIds];
          if (!updatedOwnerIds.contains(userId)) {
            updatedOwnerIds.add(userId);
          }

          transaction.update(
            FirebaseService.pets.doc(petId),
            {
              'ownerIds': updatedOwnerIds,
              'isAvailable': false,
            },
          );
        }
      });
    } catch (e) {
      throw Exception('Erro ao atribuir pet ao usuário: $e');
    }
  }
}
