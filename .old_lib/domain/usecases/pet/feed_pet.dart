// File: lib/domain/usecases/pet/feed_pet.dart

import 'package:petverse/core/config/app_config.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/pet_entity.dart';
import 'package:petverse/domain/repositories/pet_repository.dart';
import 'package:petverse/domain/repositories/user_repository.dart';

/// Parameters for feeding a pet
class FeedPetParams {
  final String userId;
  final String petId;

  FeedPetParams({
    required this.userId,
    required this.petId,
  });
}

/// Use case for feeding a pet
class FeedPet {
  final PetRepository _petRepository;
  final UserRepository _userRepository;

  FeedPet(this._petRepository, this._userRepository);

  Future<Either<Failure, PetEntity>> call(FeedPetParams params) async {
    // Get user data to check if they have enough coins
    final userResult = await _userRepository.getUserData(params.userId);

    return userResult.fold(
      (failure) => Left(failure),
      (user) async {
        if (user == null) {
          return const Left(UserDataFailure('User not found'));
        }

        if (user.coins < AppConfig.feedPetCost) {
          return const Left(PetGameFailure('Insufficient coins to feed pet'));
        }

        // Feed the pet
        final feedResult = await _petRepository.feedPet(
          userId: params.userId,
          petId: params.petId,
        );

        return feedResult.fold(
          (failure) => Left(failure),
          (fedPet) async {
            // Deduct coins and add XP
            final updateResult = await _userRepository.updateUserCurrency(
              userId: params.userId,
              coins: user.coins - AppConfig.feedPetCost,
              gems: user.gems,
              xp: user.totalXp + AppConfig.feedPetXpReward,
              level: user.level,
            );

            return updateResult.fold(
              (failure) => Left(failure),
              (_) => Right(fedPet),
            );
          },
        );
      },
    );
  }
}
