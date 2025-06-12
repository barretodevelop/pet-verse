// File: lib/domain/usecases/pet/rest_pet.dart

import 'package:petverse/core/config/app_config.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/pet_entity.dart';
import 'package:petverse/domain/repositories/pet_repository.dart';
import 'package:petverse/domain/repositories/user_repository.dart';

/// Parameters for resting a pet
class RestPetParams {
  final String userId;
  final String petId;

  RestPetParams({
    required this.userId,
    required this.petId,
  });
}

/// Use case for resting a pet (sleep)
class RestPet {
  final PetRepository _petRepository;
  final UserRepository _userRepository;

  RestPet(this._petRepository, this._userRepository);

  Future<Either<Failure, PetEntity>> call(RestPetParams params) async {
    // Rest the pet (free action)
    final restResult = await _petRepository.restPet(
      userId: params.userId,
      petId: params.petId,
    );

    return restResult.fold(
      (failure) => Left(failure),
      (restedPet) async {
        // Get user data to add XP
        final userResult = await _userRepository.getUserData(params.userId);

        return userResult.fold(
          (failure) => Right(restedPet), // Still return pet even if XP update fails
          (user) async {
            if (user != null) {
              // Add XP for pet care
              await _userRepository.updateUserCurrency(
                userId: params.userId,
                coins: user.coins,
                gems: user.gems,
                xp: user.totalXp + AppConfig.restPetXpReward,
                level: user.level,
              );
            }

            return Right(restedPet);
          },
        );
      },
    );
  }
}
