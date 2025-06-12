// File: lib/domain/usecases/pet/adopt_pet.dart

import 'package:petverse/core/config/app_config.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/pet_entity.dart';
import 'package:petverse/domain/repositories/pet_repository.dart';
import 'package:petverse/domain/repositories/user_repository.dart';

/// Parameters for adopting a pet
class AdoptPetParams {
  final String userId;
  final PetEntity petData;

  AdoptPetParams({
    required this.userId,
    required this.petData,
  });
}

/// Use case for adopting a pet
class AdoptPet {
  final PetRepository _petRepository;
  final UserRepository _userRepository;

  AdoptPet(this._petRepository, this._userRepository);

  Future<Either<Failure, PetEntity>> call(AdoptPetParams params) async {
    // Get user data to check if they have enough coins
    final userResult = await _userRepository.getUserData(params.userId);

    return userResult.fold(
      (failure) => Left(failure),
      (user) async {
        if (user == null) {
          return const Left(UserDataFailure('User not found'));
        }

        if (user.coins < AppConfig.adoptPetCost) {
          return const Left(PetGameFailure('Insufficient coins to adopt pet'));
        }

        // Adopt the pet
        final adoptResult = await _petRepository.adoptPet(
          userId: params.userId,
          petData: params.petData,
        );

        return adoptResult.fold(
          (failure) => Left(failure),
          (adoptedPet) async {
            // Deduct coins and add XP
            final updateResult = await _userRepository.updateUserCurrency(
              userId: params.userId,
              coins: user.coins - AppConfig.adoptPetCost,
              gems: user.gems,
              xp: user.totalXp + 50,
              level: user.level,
            );

            return updateResult.fold(
              (failure) => Left(failure),
              (_) => Right(adoptedPet),
            );
          },
        );
      },
    );
  }
}
