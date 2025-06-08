// File: lib/domain/usecases/user/claim_daily_reward.dart

import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/daily_reward_entity.dart';
import 'package:petverse/domain/repositories/user_repository.dart';

/// Use case for claiming daily reward
class ClaimDailyReward {
  final UserRepository _userRepository;

  ClaimDailyReward(this._userRepository);

  Future<Either<Failure, DailyRewardEntity>> call(String userId) async {
    // First check if reward can be claimed
    final canClaimResult = await _userRepository.canClaimDailyReward(userId);

    return canClaimResult.fold(
      (failure) => Left(failure),
      (canClaim) async {
        if (!canClaim) {
          return const Left(UserDataFailure('Daily reward already claimed today'));
        }

        return await _userRepository.claimDailyReward(userId);
      },
    );
  }
}
