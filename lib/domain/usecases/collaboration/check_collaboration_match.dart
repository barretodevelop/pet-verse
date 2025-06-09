// File: lib/domain/usecases/collaboration/check_collaboration_match.dart

import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';
import 'package:petverse/domain/repositories/collaborative_pet_repository.dart';
import 'package:petverse/domain/usecases/usecase.dart';

class CheckCollaborationMatch implements UseCase<CollaborationMatchResult, CheckMatchParams> {
  final CollaborativePetRepository repository;

  CheckCollaborationMatch(this.repository);

  @override
  Future<Either<Failure, CollaborationMatchResult>> call(CheckMatchParams params) async {
    try {
      // Buscar pet e verificar status
      final petResult = await repository.getCollaborativePet(params.petId);

      return petResult.fold(
        (failure) => Left(failure),
        (pet) {
          if (pet == null) {
            return Left(ValidationFailure('Pet não encontrado'));
          }

          // Se já tem 2 cuidadores, houve match
          final hasMatch = pet.caretakerIds.length == 2;

          return Right(CollaborationMatchResult(
            hasMatch: hasMatch,
            pet: hasMatch ? pet : null,
            message: hasMatch
                ? 'Parceiro encontrado! Começem a cuidar juntos!'
                : 'Aguardando parceiro...',
          ));
        },
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao verificar match: $e'));
    }
  }
}

class CheckMatchParams {
  final String petId;
  final String userId;

  CheckMatchParams({
    required this.petId,
    required this.userId,
  });
}

class CollaborationMatchResult {
  final bool hasMatch;
  final CollaborativePetEntity? pet;
  final String message;

  CollaborationMatchResult({
    required this.hasMatch,
    this.pet,
    required this.message,
  });
}
