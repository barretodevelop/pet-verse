// File: lib/services/game_data_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../core/config/app_config.dart';
import '../core/errors/exceptions.dart';
import '../data/models/pet_model.dart';
import '../data/models/user_model.dart';
import '../domain/entities/pet_entity.dart';
import '../domain/entities/user_entity.dart';
import 'firebase_service.dart';

/// Game data service for managing user and pet data with Firebase
class GameDataService {
  static final GameDataService _instance = GameDataService._internal();
  factory GameDataService() => _instance;
  GameDataService._internal();

  final FirebaseService _firebaseService = FirebaseService();

  FirebaseFirestore get _firestore => _firebaseService.firestore;
  fb_auth.FirebaseAuth get _auth => _firebaseService.auth;

  /// Initialize user profile after first login
  Future<UserEntity> initializeUserProfile(fb_auth.User firebaseUser) async {
    try {
      final now = DateTime.now();

      // Check if user already exists
      final existingUser = await getUserData(firebaseUser.uid);
      if (existingUser != null) {
        // Update last login
        await updateUserData(firebaseUser.uid, {
          'lastLoginAt': now,
        });
        return existingUser;
      }

      // Create new user profile
      final newUser = UserEntity(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? 'no-email@example.com',
        displayName: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'Player',
        photoURL: firebaseUser.photoURL,
        createdAt: now,
        lastLoginAt: now,
        coins: AppConfig.initialCoins,
        gems: AppConfig.initialGems,
        totalXp: AppConfig.initialXp,
        level: AppConfig.initialLevel,
      );

      await createUser(newUser);
      return newUser;
    } catch (e) {
      throw UserDataException('Failed to initialize user profile: $e');
    }
  }

  /// Create new user in Firestore
  Future<void> createUser(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _firestore
          .collection(AppConfig.firestoreUsersCollection)
          .doc(user.id)
          .set(userModel.toFirestore());
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to create user: ${e.message}', code: e.code);
    } catch (e) {
      throw UserDataException('Failed to create user: $e');
    }
  }

  /// Get user data from Firestore
  Future<UserEntity?> getUserData(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection(AppConfig.firestoreUsersCollection).doc(userId).get();

      if (!docSnapshot.exists) {
        return null;
      }

      return UserModel.fromFirestore(docSnapshot);
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to get user data: ${e.message}', code: e.code);
    } catch (e) {
      throw UserDataException('Failed to get user data: $e');
    }
  }

  /// Update user data in Firestore
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      // Convert DateTime values to Timestamps
      final updatedData = Map<String, dynamic>.from(data);
      for (final entry in updatedData.entries) {
        if (entry.value is DateTime) {
          updatedData[entry.key] = Timestamp.fromDate(entry.value);
        }
      }

      await _firestore
          .collection(AppConfig.firestoreUsersCollection)
          .doc(userId)
          .update(updatedData);
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to update user data: ${e.message}', code: e.code);
    } catch (e) {
      throw UserDataException('Failed to update user data: $e');
    }
  }

  /// Get user's pets from Firestore
  Future<List<PetEntity>> getUserPets(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConfig.firestoreUsersCollection)
          .doc(userId)
          .collection(AppConfig.firestorePetsCollection)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to get user pets: ${e.message}', code: e.code);
    } catch (e) {
      throw PetGameException('Failed to get user pets: $e');
    }
  }

  /// Adopt a new pet
  Future<PetEntity> adoptPet(String userId, PetEntity petData) async {
    try {
      final petRef = _firestore
          .collection(AppConfig.firestoreUsersCollection)
          .doc(userId)
          .collection(AppConfig.firestorePetsCollection)
          .doc();

      final now = DateTime.now();
      final adoptedPet = petData.copyWith(
        id: petRef.id,
        isAdopted: true,
        generatedByUserId: userId,
        lastFed: now,
        lastPlayed: now,
        lastSlept: now,
      );

      final petModel = PetModel.fromEntity(adoptedPet);
      await petRef.set(petModel.toFirestore());

      return adoptedPet;
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to adopt pet: ${e.message}', code: e.code);
    } catch (e) {
      throw PetGameException('Failed to adopt pet: $e');
    }
  }

  /// Update pet data
  Future<void> updatePet(String userId, PetEntity pet) async {
    try {
      final petModel = PetModel.fromEntity(pet);
      await _firestore
          .collection(AppConfig.firestoreUsersCollection)
          .doc(userId)
          .collection(AppConfig.firestorePetsCollection)
          .doc(pet.id)
          .update(petModel.toFirestore());
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to update pet: ${e.message}', code: e.code);
    } catch (e) {
      throw PetGameException('Failed to update pet: $e');
    }
  }

  /// Get pet by ID
  Future<PetEntity?> getPetById(String userId, String petId) async {
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
      throw PetGameException('Failed to get pet: $e');
    }
  }

  /// Get game statistics for user
  Future<Map<String, dynamic>> getUserGameStats(String userId) async {
    try {
      final user = await getUserData(userId);
      if (user == null) {
        throw const UserDataException('User not found');
      }

      final pets = await getUserPets(userId);

      final stats = {
        'totalPets': pets.length,
        'adoptedPets': pets.where((p) => p.isAdopted).length,
        'averagePetLevel':
            pets.isEmpty ? 0 : pets.map((p) => p.level).reduce((a, b) => a + b) / pets.length,
        'totalCoins': user.coins,
        'totalGems': user.gems,
        'totalXp': user.totalXp,
        'currentLevel': user.level,
        'loginStreak': user.loginStreak,
        'daysSinceJoined': DateTime.now().difference(user.createdAt).inDays,
        'lastActiveDate': user.lastLoginAt.toIso8601String(),
      };

      return stats;
    } catch (e) {
      throw UserDataException('Failed to get game stats: $e');
    }
  }

  /// Clear all user data (for account deletion)
  Future<void> deleteUserData(String userId) async {
    try {
      // Delete all pets first
      final petsQuery = await _firestore
          .collection(AppConfig.firestoreUsersCollection)
          .doc(userId)
          .collection(AppConfig.firestorePetsCollection)
          .get();

      final batch = _firestore.batch();

      for (final doc in petsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user document
      batch.delete(_firestore.collection(AppConfig.firestoreUsersCollection).doc(userId));

      await batch.commit();
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to delete user data: ${e.message}', code: e.code);
    } catch (e) {
      throw UserDataException('Failed to delete user data: $e');
    }
  }

  /// Backup user data
  Future<Map<String, dynamic>> backupUserData(String userId) async {
    try {
      final user = await getUserData(userId);
      final pets = await getUserPets(userId);

      return {
        'user': user != null ? UserModel.fromEntity(user).toJson() : null,
        'pets': pets.map((pet) => PetModel.fromEntity(pet).toJson()).toList(),
        'backupDate': DateTime.now().toIso8601String(),
        'version': AppConfig.appVersion,
      };
    } catch (e) {
      throw UserDataException('Failed to backup user data: $e');
    }
  }

  /// Check if service is available
  Future<bool> isServiceAvailable() async {
    try {
      return await _firebaseService.checkConnection();
    } catch (e) {
      return false;
    }
  }
}
