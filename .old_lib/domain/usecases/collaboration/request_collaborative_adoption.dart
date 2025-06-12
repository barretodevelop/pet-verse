// File: lib/domain/usecases/collaboration/request_collaborative_adoption.dart

import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';
import 'package:petverse/domain/repositories/collaborative_pet_repository.dart';
import 'package:petverse/domain/usecases/usecase.dart';

class RequestCollaborativeAdoption
    implements UseCase<CollaborativeAdoptionResult, RequestCollaborativeAdoptionParams> {
  final CollaborativePetRepository repository;

  RequestCollaborativeAdoption(this.repository);

  @override
  Future<Either<Failure, CollaborativeAdoptionResult>> call(
      RequestCollaborativeAdoptionParams params) async {
    try {
      // 1. Verificar se usuário tem slots disponíveis
      final userDataResult = await repository.getUserCollaborationData(params.userId);

      return userDataResult.fold(
        (failure) => Left(failure),
        (userData) async {
          if (!userData.hasAvailableSlots) {
            return Left(
                ValidationFailure('Você não tem slots disponíveis para adoção colaborativa'));
          }

          // 2. Verificar se pet existe e está disponível
          final petResult = await repository.getCollaborativePet(params.petId);

          return petResult.fold(
            (failure) => Left(failure),
            (pet) async {
              if (pet == null) {
                return Left(ValidationFailure('Pet não encontrado'));
              }

              // 3. Adicionar à lista de espera
              final waitingResult = await repository.addToWaitingList(params.userId, params.petId);

              return waitingResult.fold(
                (failure) => Left(failure),
                (_) => Right(CollaborativeAdoptionResult(
                  success: true,
                  message: 'Solicitação de adoção colaborativa enviada!',
                  petId: params.petId,
                  waitingForPartner: true,
                )),
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(ValidationFailure('Erro ao processar adoção colaborativa: $e'));
    }
  }
}

class RequestCollaborativeAdoptionParams {
  final String userId;
  final String petId;

  RequestCollaborativeAdoptionParams({
    required this.userId,
    required this.petId,
  });
}

class CollaborativeAdoptionResult {
  final bool success;
  final String message;
  final String petId;
  final bool waitingForPartner;
  final CollaborativePetEntity? pet;

  CollaborativeAdoptionResult({
    required this.success,
    required this.message,
    required this.petId,
    required this.waitingForPartner,
    this.pet,
  });
}
