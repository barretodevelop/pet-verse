// File: lib/domain/repositories/user_repository.dart

import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/data/repositories/achievement_entity.dart';
import 'package:petverse/domain/entities/daily_reward_entity.dart';
import 'package:petverse/domain/entities/transaction_entity.dart';

import '../entities/user_entity.dart';

/// User repository interface for managing user data
abstract class UserRepository {
  /// Get user data by ID
  Future<Either<Failure, UserEntity?>> getUserData(String userId);

  /// Create new user profile
  Future<Either<Failure, void>> createUser(UserEntity user);

  /// Update user data
  Future<Either<Failure, void>> updateUser(String userId, Map<String, dynamic> data);

  /// Update user currency (coins, gems, xp)
  Future<Either<Failure, void>> updateUserCurrency({
    required String userId,
    required int coins,
    required int gems,
    required int xp,
    required int level,
  });

  /// Add transaction record
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction);

  /// Get user transactions
  Future<Either<Failure, List<TransactionEntity>>> getUserTransactions(
    String userId, {
    int limit = 20,
    String? lastTransactionId,
  });

  /// Get user achievements
  Future<Either<Failure, List<AchievementEntity>>> getUserAchievements(String userId);

  /// Update achievement progress
  Future<Either<Failure, void>> updateAchievementProgress({
    required String userId,
    required String achievementId,
    required int progress,
  });

  /// Claim daily reward
  Future<Either<Failure, DailyRewardEntity>> claimDailyReward(String userId);

  /// Check if daily reward can be claimed
  Future<Either<Failure, bool>> canClaimDailyReward(String userId);

  /// Get user statistics
  Future<Either<Failure, Map<String, dynamic>>> getUserStats(String userId);
}
