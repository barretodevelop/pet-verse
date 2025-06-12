// File: lib/data/datasources/remote/firestore_user_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/config/app_config.dart';
import 'package:petverse/core/errors/exceptions.dart';
import 'package:petverse/data/models/achievement_model.dart';
import 'package:petverse/data/models/transaction_model.dart';
import 'package:petverse/data/models/user_model.dart';

/// Firestore User datasource interface
abstract class FirestoreUserDatasource {
  Future<UserModel?> getUserData(String userId);
  Future<void> createUser(UserModel user);
  Future<void> updateUser(String userId, Map<String, dynamic> data);
  Future<void> addTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getUserTransactions(String userId, {int limit = 20});
  Future<List<AchievementModel>> getUserAchievements(String userId);
  Future<void> updateAchievementProgress(String userId, String achievementId, int progress);
}

/// Implementation of Firestore User datasource
class FirestoreUserDatasourceImpl implements FirestoreUserDatasource {
  final FirebaseFirestore _firestore;

  FirestoreUserDatasourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel?> getUserData(String userId) async {
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
      throw DatabaseException('Failed to get user data: $e');
    }
  }

  @override
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConfig.firestoreUsersCollection)
          .doc(user.id)
          .set(user.toFirestore());
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to create user: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('Failed to create user: $e');
    }
  }

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
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
      throw DatabaseException('Failed to update user: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('Failed to update user: $e');
    }
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection(AppConfig.firestoreTransactionsCollection)
          .doc(transaction.id)
          .set(transaction.toFirestore());
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to add transaction: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('Failed to add transaction: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getUserTransactions(String userId, {int limit = 20}) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConfig.firestoreTransactionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to get transactions: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('Failed to get transactions: $e');
    }
  }

  @override
  Future<List<AchievementModel>> getUserAchievements(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConfig.firestoreUsersCollection)
          .doc(userId)
          .collection(AppConfig.firestoreAchievementsCollection)
          .get();

      return querySnapshot.docs.map((doc) => AchievementModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to get achievements: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('Failed to get achievements: $e');
    }
  }

  @override
  Future<void> updateAchievementProgress(String userId, String achievementId, int progress) async {
    try {
      await _firestore
          .collection(AppConfig.firestoreUsersCollection)
          .doc(userId)
          .collection(AppConfig.firestoreAchievementsCollection)
          .doc(achievementId)
          .update({
        'currentValue': progress,
        'isCompleted': progress >= 100, // Assuming 100 is completion
        'completedAt': progress >= 100 ? Timestamp.now() : null,
      });
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to update achievement: ${e.message}', code: e.code);
    } catch (e) {
      throw DatabaseException('Failed to update achievement: $e');
    }
  }
}
