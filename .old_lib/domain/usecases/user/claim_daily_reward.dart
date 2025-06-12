// File: lib/domain/usecases/user/claim_daily_reward.dart

/// Use case for claiming daily reward
library;

// File: lib/domain/usecases/user/claim_daily_reward.dart
// CORRIGIDO - Versão simplificada que funciona

import 'dart:math' as math;

import 'package:petverse/core/constants/economy_constants.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/daily_reward_result.dart';
import 'package:petverse/domain/entities/user_entity.dart';
import 'package:petverse/domain/repositories/user_repository.dart';
import 'package:petverse/domain/usecases/usecase.dart';

/// Use case para reivindicar recompensa diária
class ClaimDailyReward implements UseCase<DailyRewardResult, String> {
  final UserRepository _repository;

  ClaimDailyReward(this._repository);

  @override
  Future<Either<Failure, DailyRewardResult>> call(String userId) async {
    try {
      // Buscar dados do usuário
      final userResult = await _repository.getUserData(userId);

      return userResult.fold(
        (failure) => Left(failure),
        (user) async {
          // Verificar se pode reivindicar
          if (!_canClaimDailyReward(user!)) {
            return Right(DailyRewardResult.failure('Recompensa diária já foi reivindicada hoje'));
          }

          // Calcular recompensas
          final rewards = _calculateDailyReward(user);
          final streak = _calculateStreak(user);

          // Atualizar dados do usuário
          final newCoins = (user.coins + rewards.coins).clamp(0, EconomyConstants.maxCoins);
          final newGems = (user.gems + rewards.gems).clamp(0, EconomyConstants.maxGems);
          final newXp = user.totalXp + rewards.xp;
          final newLevel = _calculateLevelFromXp(newXp);
          final isLevelUp = newLevel > user.level;

          // Atualizar usando método básico
          final updateResult = await _repository.updateUserCurrency(
            userId: userId,
            coins: newCoins,
            gems: newGems,
            xp: newXp,
            level: newLevel,
          );

          return updateResult.fold(
            (failure) => Left(failure),
            (_) => Right(DailyRewardResult.success(
              coinsRewarded: rewards.coins,
              gemsRewarded: rewards.gems,
              xpRewarded: rewards.xp,
              streakDay: streak,
              isLevelUp: isLevelUp,
            )),
          );
        },
      );
    } catch (e) {
      return Right(DailyRewardResult.failure('Erro ao reivindicar recompensa: $e'));
    }
  }

  /// Verifica se o usuário pode reivindicar a recompensa diária
  bool _canClaimDailyReward(UserEntity user) {
    // Por simplicidade, sempre permite reivindicar por enquanto
    // Em produção, verificaria o timestamp da última recompensa
    return true;
  }

  /// Calcula o streak atual (simplificado)
  int _calculateStreak(UserEntity user) {
    // Por simplicidade, retorna 1-7 aleatoriamente
    // Em produção, calcularia baseado no histórico
    return 1 + (user.level % 7);
  }

  /// Calcula as recompensas diárias baseadas no nível
  DailyRewards _calculateDailyReward(UserEntity user) {
    const baseCoins = EconomyConstants.dailyRewardCoinsBase;
    const baseGems = EconomyConstants.dailyRewardGemsBase;

    // Multiplicador por nível
    final levelMultiplier = EconomyConstants.getRewardMultiplier(user.level);

    // Multiplicador por streak simulado
    final streakMultiplier = 1.0 + (_calculateStreak(user) * 0.1);

    final coins = (baseCoins * levelMultiplier * streakMultiplier).round();
    final gems = (baseGems * levelMultiplier * 0.5).round();
    final xp = (50 * levelMultiplier).round();

    return DailyRewards(
      coins: coins.clamp(baseCoins, baseCoins * 3),
      gems: gems.clamp(baseGems, baseGems * 2),
      xp: xp.clamp(50, 300),
    );
  }

  /// Calcula nível baseado no XP
  int _calculateLevelFromXp(int xp) {
    if (xp <= 0) return 1;
    // Fórmula: level = sqrt(xp / 100) + 1
    return (math.sqrt(xp / 100)).floor() + 1;
  }
}

/// Recompensas calculadas (classe simples)
class DailyRewards {
  final int coins;
  final int gems;
  final int xp;

  const DailyRewards({
    required this.coins,
    required this.gems,
    required this.xp,
  });

  @override
  String toString() {
    return 'DailyRewards(coins: $coins, gems: $gems, xp: $xp)';
  }
}
