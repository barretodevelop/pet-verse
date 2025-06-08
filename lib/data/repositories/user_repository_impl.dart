// File: lib/data/repositories/user_repository_impl.dart

import 'package:petverse/core/config/app_config.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/core/errors/exceptions.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/core/utils/helpers.dart';
import 'package:petverse/data/datasources/local/local_storage_datasource.dart';
import 'package:petverse/data/datasources/remote/firestore_user_datasource.dart';
import 'package:petverse/data/models/transaction_model.dart';
import 'package:petverse/data/models/user_model.dart';
import 'package:petverse/data/repositories/achievement_entity.dart';
import 'package:petverse/domain/entities/daily_reward_entity.dart';
import 'package:petverse/domain/entities/transaction_entity.dart';
import 'package:petverse/domain/entities/user_entity.dart';
import 'package:petverse/domain/repositories/user_repository.dart';

/// Implementation of UserRepository
class UserRepositoryImpl implements UserRepository {
  final FirestoreUserDatasource _firestoreDatasource;
  final LocalStorageDatasource _localDatasource;

  UserRepositoryImpl(this._firestoreDatasource, this._localDatasource);

  @override
  Future<Either<Failure, UserEntity?>> getUserData(String userId) async {
    try {
      // Try to get from cache first
      final cachedData = await _localDatasource.getCachedUserData(userId);
      if (cachedData != null) {
        final userModel = UserModel.fromJson(cachedData);
        return Right(userModel);
      }

      // Get from Firestore if not in cache
      final userModel = await _firestoreDatasource.getUserData(userId);

      // Cache the result
      if (userModel != null) {
        await _localDatasource.cacheUserData(userId, userModel.toJson());
      }

      return Right(userModel);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } on CacheException catch (e) {
      // If cache fails, still try to return Firestore data
      try {
        final userModel = await _firestoreDatasource.getUserData(userId);
        return Right(userModel);
      } on DatabaseException catch (dbError) {
        return Left(DatabaseFailure(dbError.message, code: dbError.code));
      }
    } catch (e) {
      return Left(UserDataFailure('Unexpected error getting user data: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createUser(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _firestoreDatasource.createUser(userModel);

      // Cache the new user
      await _localDatasource.cacheUserData(user.id, userModel.toJson());

      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UserDataFailure('Unexpected error creating user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestoreDatasource.updateUser(userId, data);

      // Clear cache to force refresh on next get
      await _localDatasource.clearUserCache(userId);

      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UserDataFailure('Unexpected error updating user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserCurrency({
    required String userId,
    required int coins,
    required int gems,
    required int xp,
    required int level,
  }) async {
    try {
      final updateData = {
        'coins': coins,
        'gems': gems,
        'totalXp': xp,
        'level': level,
        'lastLoginAt': DateTime.now(),
      };

      await _firestoreDatasource.updateUser(userId, updateData);

      // Clear cache to force refresh
      await _localDatasource.clearUserCache(userId);

      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UserDataFailure('Unexpected error updating currency: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      await _firestoreDatasource.addTransaction(transactionModel);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(TransactionFailure('Unexpected error adding transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getUserTransactions(
    String userId, {
    int limit = 20,
    String? lastTransactionId,
  }) async {
    try {
      final transactions = await _firestoreDatasource.getUserTransactions(userId, limit: limit);
      return Right(transactions);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(TransactionFailure('Unexpected error getting transactions: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AchievementEntity>>> getUserAchievements(String userId) async {
    try {
      final achievements = await _firestoreDatasource.getUserAchievements(userId);
      return Right(achievements);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UserDataFailure('Unexpected error getting achievements: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAchievementProgress({
    required String userId,
    required String achievementId,
    required int progress,
  }) async {
    try {
      await _firestoreDatasource.updateAchievementProgress(userId, achievementId, progress);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UserDataFailure('Unexpected error updating achievement: $e'));
    }
  }

  @override
  Future<Either<Failure, DailyRewardEntity>> claimDailyReward(String userId) async {
    try {
      // Get user data to calculate reward
      final userResult = await getUserData(userId);

      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          if (user == null) {
            return const Left(UserDataFailure('User not found'));
          }

          // Calculate consecutive days and rewards
          final now = DateTime.now();
          int consecutiveDays = 1;

          if (user.lastDailyReward != null) {
            final daysSinceLastReward = Helpers.daysBetween(user.lastDailyReward!, now);
            if (daysSinceLastReward == 1) {
              consecutiveDays = user.loginStreak + 1;
            }
          }

          // Calculate rewards based on consecutive days
          int rewardCoins = AppConfig.dailyRewardBaseCoins + (consecutiveDays * 25);
          int rewardGems = (consecutiveDays % 7 == 0) ? 5 : (consecutiveDays % 3 == 0 ? 2 : 0);
          int rewardXp = AppConfig.dailyRewardBaseXp + (consecutiveDays * 5);

          // Update user currency and daily reward status
          final updateResult = await updateUserCurrency(
            userId: userId,
            coins: user.coins + rewardCoins,
            gems: user.gems + rewardGems,
            xp: user.totalXp + rewardXp,
            level: user.level,
          );

          return updateResult.fold(
            (failure) => Left(failure),
            (_) async {
              // Update daily reward tracking
              await updateUser(userId, {
                'lastDailyReward': now,
                'loginStreak': consecutiveDays,
              });

              // Create reward entity
              final reward = DailyRewardEntity(
                id: Helpers.generateId(),
                day: consecutiveDays,
                type: RewardType.coins,
                amount: rewardCoins,
                description: 'Daily login reward for day $consecutiveDays',
                isClaimed: true,
                claimedAt: now,
              );

              return Right(reward);
            },
          );
        },
      );
    } catch (e) {
      return Left(UserDataFailure('Unexpected error claiming daily reward: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> canClaimDailyReward(String userId) async {
    try {
      final userResult = await getUserData(userId);

      return userResult.fold(
        (failure) => Left(failure),
        (user) {
          if (user == null) {
            return const Left(UserDataFailure('User not found'));
          }

          final canClaim = Helpers.canClaimDailyReward(user.lastDailyReward);
          return Right(canClaim);
        },
      );
    } catch (e) {
      return Left(UserDataFailure('Unexpected error checking daily reward: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getUserStats(String userId) async {
    try {
      final userResult = await getUserData(userId);

      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          if (user == null) {
            return const Left(UserDataFailure('User not found'));
          }

          // Get additional stats
          final transactionsResult = await getUserTransactions(userId, limit: 100);
          final achievementsResult = await getUserAchievements(userId);

          final transactions = transactionsResult.rightOrNull ?? [];
          final achievements = achievementsResult.rightOrNull ?? [];

          final stats = {
            'totalXp': user.totalXp,
            'level': user.level,
            'coins': user.coins,
            'gems': user.gems,
            'loginStreak': user.loginStreak,
            'totalTransactions': transactions.length,
            'totalAchievements': achievements.length,
            'completedAchievements': achievements.where((a) => a.isCompleted).length,
            'memberSince': user.createdAt.toIso8601String(),
            'lastLogin': user.lastLoginAt.toIso8601String(),
          };

          return Right(stats);
        },
      );
    } catch (e) {
      return Left(UserDataFailure('Unexpected error getting user stats: $e'));
    }
  }
}
