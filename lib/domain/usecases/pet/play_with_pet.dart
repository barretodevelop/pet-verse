// File: lib/domain/usecases/pet/play_with_pet.dart

import 'package:petverse/core/config/app_config.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/pet_entity.dart';
import 'package:petverse/domain/repositories/pet_repository.dart';
import 'package:petverse/domain/repositories/user_repository.dart';

/// Parameters for playing with a pet
class PlayWithPetParams {
  final String userId;
  final String petId;

  PlayWithPetParams({
    required this.userId,
    required this.petId,
  });
}

/// Use case for playing with a pet
class PlayWithPet {
  final PetRepository _petRepository;
  final UserRepository _userRepository;

  PlayWithPet(this._petRepository, this._userRepository);

  Future<Either<Failure, PetEntity>> call(PlayWithPetParams params) async {
    // Get user data to check if they have enough coins
    final userResult = await _userRepository.getUserData(params.userId);

    return userResult.fold(
      (failure) => Left(failure),
      (user) async {
        if (user == null) {
          return const Left(UserDataFailure('User not found'));
        }

        if (user.coins < AppConfig.playWithPetCost) {
          return const Left(PetGameFailure('Insufficient coins to play with pet'));
        }

        // Get pet to check energy
        final petResult = await _petRepository.getPetById(
          userId: params.userId,
          petId: params.petId,
        );

        return petResult.fold(
          (failure) => Left(failure),
          (pet) async {
            if (pet == null) {
              return const Left(PetGameFailure('Pet not found'));
            }

            if (pet.energy < 10) {
              return const Left(PetGameFailure('Pet is too tired to play'));
            }

            // Play with the pet
            final playResult = await _petRepository.playWithPet(
              userId: params.userId,
              petId: params.petId,
            );

            return playResult.fold(
              (failure) => Left(failure),
              (playedPet) async {
                // Deduct coins and add XP
                final updateResult = await _userRepository.updateUserCurrency(
                  userId: params.userId,
                  coins: user.coins - AppConfig.playWithPetCost,
                  gems: user.gems,
                  xp: user.totalXp + AppConfig.playWithPetXpReward,
                  level: user.level,
                );

                return updateResult.fold(
                  (failure) => Left(failure),
                  (_) => Right(playedPet),
                );
              },
            );
          },
        );
      },
    );
  }
}
