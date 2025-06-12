// File: lib/data/repositories/pet_repository_impl.dart

import 'package:petverse/core/config/app_config.dart';
import 'package:petverse/core/errors/exceptions.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/core/utils/helpers.dart';
import 'package:petverse/data/datasources/remote/firestore_pet_datasource.dart';
import 'package:petverse/data/models/pet_model.dart';
import 'package:petverse/domain/entities/pet_entity.dart';
import 'package:petverse/domain/repositories/pet_repository.dart';

/// Implementation of PetRepository
class PetRepositoryImpl implements PetRepository {
  final FirestorePetDatasource _petDatasource;

  PetRepositoryImpl(this._petDatasource);

  @override
  Future<Either<Failure, List<PetEntity>>> getUserPets(String userId) async {
    try {
      final petModels = await _petDatasource.getUserPets(userId);
      return Right(petModels);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(PetGameFailure('Unexpected error getting user pets: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PetEntity>>> getAvailablePets() async {
    try {
      final petModels = await _petDatasource.getAvailablePets();
      return Right(petModels);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(PetGameFailure('Unexpected error getting available pets: $e'));
    }
  }

  @override
  Future<Either<Failure, PetEntity>> adoptPet({
    required String userId,
    required PetEntity petData,
  }) async {
    try {
      final petModel = PetModel.fromEntity(petData);
      final adoptedPet = await _petDatasource.adoptPet(userId, petModel);
      return Right(adoptedPet);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(PetGameFailure('Unexpected error adopting pet: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePet({
    required String userId,
    required PetEntity pet,
  }) async {
    try {
      final petModel = PetModel.fromEntity(pet);
      await _petDatasource.updatePet(userId, petModel);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(PetGameFailure('Unexpected error updating pet: $e'));
    }
  }

  @override
  Future<Either<Failure, PetEntity>> feedPet({
    required String userId,
    required String petId,
  }) async {
    try {
      final pet = await _petDatasource.getPetById(userId, petId);
      if (pet == null) {
        return const Left(PetGameFailure('Pet not found'));
      }

      final now = DateTime.now();
      final updatedPet = pet.copyWith(
        hunger: Helpers.clamp(pet.hunger + 30, 0, 100),
        happiness: Helpers.clamp(pet.happiness + 5, 0, 100),
        xp: pet.xp + AppConfig.feedPetXpReward,
        lastFed: now,
      );

      // Check for level up
      final finalPet = _checkPetLevelUp(updatedPet);

      await _petDatasource.updatePet(userId, finalPet);
      return Right(finalPet);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(PetGameFailure('Unexpected error feeding pet: $e'));
    }
  }

  @override
  Future<Either<Failure, PetEntity>> playWithPet({
    required String userId,
    required String petId,
  }) async {
    try {
      final pet = await _petDatasource.getPetById(userId, petId);
      if (pet == null) {
        return const Left(PetGameFailure('Pet not found'));
      }

      if (pet.energy < 10) {
        return const Left(PetGameFailure('Pet is too tired to play'));
      }

      final now = DateTime.now();
      final updatedPet = pet.copyWith(
        happiness: Helpers.clamp(pet.happiness + 25, 0, 100),
        energy: Helpers.clamp(pet.energy - 10, 0, 100),
        xp: pet.xp + AppConfig.playWithPetXpReward,
        lastPlayed: now,
      );

      // Check for level up
      final finalPet = _checkPetLevelUp(updatedPet);

      await _petDatasource.updatePet(userId, finalPet);
      return Right(finalPet);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(PetGameFailure('Unexpected error playing with pet: $e'));
    }
  }

  @override
  Future<Either<Failure, PetEntity>> restPet({
    required String userId,
    required String petId,
  }) async {
    try {
      final pet = await _petDatasource.getPetById(userId, petId);
      if (pet == null) {
        return const Left(PetGameFailure('Pet not found'));
      }

      final now = DateTime.now();
      final updatedPet = pet.copyWith(
        energy: Helpers.clamp(pet.energy + 40, 0, 100),
        xp: pet.xp + AppConfig.restPetXpReward,
        lastSlept: now,
      );

      // Check for level up
      final finalPet = _checkPetLevelUp(updatedPet);

      await _petDatasource.updatePet(userId, finalPet);
      return Right(finalPet);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(PetGameFailure('Unexpected error resting pet: $e'));
    }
  }

  @override
  Future<Either<Failure, PetEntity?>> getPetById({
    required String userId,
    required String petId,
  }) async {
    try {
      final pet = await _petDatasource.getPetById(userId, petId);
      return Right(pet);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(PetGameFailure('Unexpected error getting pet: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePet({
    required String userId,
    required String petId,
  }) async {
    try {
      await _petDatasource.deletePet(userId, petId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(PetGameFailure('Unexpected error deleting pet: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPetStats({
    required String userId,
    required String petId,
  }) async {
    try {
      final pet = await _petDatasource.getPetById(userId, petId);
      if (pet == null) {
        return const Left(PetGameFailure('Pet not found'));
      }

      final stats = {
        'id': pet.id,
        'name': pet.name,
        'type': pet.type,
        'level': pet.level,
        'xp': pet.xp,
        'xpToNextLevel': pet.xpToNextLevel,
        'hunger': pet.hunger,
        'happiness': pet.happiness,
        'energy': pet.energy,
        'evolutionStage': pet.evolutionStage,
        'skills': pet.skills,
        'mood': Helpers.getPetMood(
          hunger: pet.hunger,
          happiness: pet.happiness,
          energy: pet.energy,
        ),
        'overallHealthiness': Helpers.calculatePetHappiness(
          hunger: pet.hunger,
          energy: pet.energy,
          cleanliness: 100, // Default cleanliness
        ),
        'timeSinceLastFed': DateTime.now().difference(pet.lastFed).inMinutes,
        'timeSinceLastPlayed': DateTime.now().difference(pet.lastPlayed).inMinutes,
        'timeSinceLastSlept': DateTime.now().difference(pet.lastSlept).inMinutes,
      };

      return Right(stats);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message, code: e.code));
    } catch (e) {
      return Left(PetGameFailure('Unexpected error getting pet stats: $e'));
    }
  }

  /// Helper method to check and handle pet level up
  PetModel _checkPetLevelUp(PetModel pet) {
    PetModel updatedPet = pet;

    while (updatedPet.xp >= updatedPet.xpToNextLevel) {
      final newLevel = updatedPet.level + 1;
      final newXp = updatedPet.xp - updatedPet.xpToNextLevel;
      final newXpToNext = updatedPet.xpToNextLevel + (newLevel * 20);

      updatedPet = updatedPet.copyWith(
        level: newLevel,
        xp: newXp,
        xpToNextLevel: newXpToNext,
      );
    }

    return updatedPet;
  }
}
