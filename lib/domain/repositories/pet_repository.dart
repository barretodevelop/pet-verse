// File: lib/domain/repositories/pet_repository.dart

import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/pet_entity.dart';

/// Pet repository interface for managing pet data
abstract class PetRepository {
  /// Get user's pets
  Future<Either<Failure, List<PetEntity>>> getUserPets(String userId);

  /// Get available pets for adoption
  Future<Either<Failure, List<PetEntity>>> getAvailablePets();

  /// Adopt a pet
  Future<Either<Failure, PetEntity>> adoptPet({
    required String userId,
    required PetEntity petData,
  });

  /// Update pet data
  Future<Either<Failure, void>> updatePet({
    required String userId,
    required PetEntity pet,
  });

  /// Feed pet
  Future<Either<Failure, PetEntity>> feedPet({
    required String userId,
    required String petId,
  });

  /// Play with pet
  Future<Either<Failure, PetEntity>> playWithPet({
    required String userId,
    required String petId,
  });

  /// Rest pet (sleep)
  Future<Either<Failure, PetEntity>> restPet({
    required String userId,
    required String petId,
  });

  /// Get pet by ID
  Future<Either<Failure, PetEntity?>> getPetById({
    required String userId,
    required String petId,
  });

  /// Delete pet
  Future<Either<Failure, void>> deletePet({
    required String userId,
    required String petId,
  });

  /// Get pet statistics
  Future<Either<Failure, Map<String, dynamic>>> getPetStats({
    required String userId,
    required String petId,
  });
}
