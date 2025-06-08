// File: lib/data/datasources/remote/firestore_pet_datasource.dart

import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/config/app_config.dart';
import 'package:petverse/core/errors/exceptions.dart';
import 'package:petverse/data/models/pet_model.dart';

/// Firestore Pet datasource interface
abstract class FirestorePetDatasource {
  Future<List<PetModel>> getUserPets(String userId);
  Future<List<PetModel>> getAvailablePets();
  Future<PetModel> adoptPet(String userId, PetModel petData);
  Future<void> updatePet(String userId, PetModel pet);
  Future<PetModel?> getPetById(String userId, String petId);
  Future<void> deletePet(String userId, String petId);
}

/// Implementation of Firestore Pet datasource
class FirestorePetDatasourceImpl implements FirestorePetDatasource {
  final FirebaseFirestore _firestore;

  FirestorePetDatasourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<PetModel>> getUserPets(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConfig.firestoreUsersCollection)
          .doc(userId)
          .collection(AppConfig.firestorePetsCollection)
          .get();

      return querySnapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to get user pets: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('Failed to get user pets: $e');
    }
  }

  @override
  Future<List<PetModel>> getAvailablePets() async {
    // Mock implementation - in a real app, this would fetch from a global pets collection
    // or generate pets dynamically
    await Future.delayed(const Duration(milliseconds: 300));

    final random = math.Random();
    final now = DateTime.now();

    final petTypes = ['Fire', 'Water', 'Grass', 'Electric', 'Psychic', 'Flying'];
    final petNames = ['Charmander', 'Squirtle', 'Bulbasaur', 'Pikachu', 'Abra', 'Pidgey'];
    final petImageUrls = [
      'https://img.icons8.com/color/96/charmander.png',
      'https://img.icons8.com/color/96/squirtle.png',
      'https://img.icons8.com/color/96/bulbasaur.png',
      'https://img.icons8.com/color/96/pikachu.png',
      'https://img.icons8.com/color/96/abra.png',
      'https://img.icons8.com/color/96/pidgey.png',
    ];

    return List.generate(petTypes.length, (index) {
      return PetModel(
        id: 'available_${now.millisecondsSinceEpoch}_$index',
        name: petNames[index % petNames.length],
        imageUrl: petImageUrls[index % petImageUrls.length],
        type: petTypes[index % petTypes.length],
        description: 'An adorable pet ready to be your companion!',
        hunger: 60 + random.nextInt(41),
        happiness: 60 + random.nextInt(41),
        energy: 60 + random.nextInt(41),
        lastFed: now,
        lastPlayed: now,
        lastSlept: now,
      );
    });
  }

  @override
  Future<PetModel> adoptPet(String userId, PetModel petData) async {
    try {
      final petRef = _firestore
          .collection(AppConfig.firestoreUsersCollection)
          .doc(userId)
          .collection(AppConfig.firestorePetsCollection)
          .doc();

      final adoptedPet = petData.copyWith(
        id: petRef.id,
        isAdopted: true,
        generatedByUserId: userId,
      );

      await petRef.set(adoptedPet.toFirestore());
      return adoptedPet;
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to adopt pet: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('Failed to adopt pet: $e');
    }
  }

  @override
  Future<void> updatePet(String userId, PetModel pet) async {
    try {
      await _firestore
          .collection(AppConfig.firestoreUsersCollection)
          .doc(userId)
          .collection(AppConfig.firestorePetsCollection)
          .doc(pet.id)
          .update(pet.toFirestore());
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to update pet: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('Failed to update pet: $e');
    }
  }

  @override
  Future<PetModel?> getPetById(String userId, String petId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConfig.firestoreUsersCollection)
          .doc(userId)
          .collection(AppConfig.firestorePetsCollection)
          .doc(petId)
          .get();

      if (!docSnapshot.exists) {
        return null;
      }

      return PetModel.fromFirestore(docSnapshot);
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to get pet: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('Failed to get pet: $e');
    }
  }

  @override
  Future<void> deletePet(String userId, String petId) async {
    try {
      await _firestore
          .collection(AppConfig.firestoreUsersCollection)
          .doc(userId)
          .collection(AppConfig.firestorePetsCollection)
          .doc(petId)
          .delete();
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to delete pet: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('Failed to delete pet: $e');
    }
  }
}
