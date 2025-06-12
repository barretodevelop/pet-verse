// File: lib/domain/usecases/collaboration/sync_collaborative_action.dart

import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_action_entity.dart';
import 'package:petverse/domain/repositories/collaborative_pet_repository.dart';
import 'package:petverse/domain/usecases/usecase.dart';

class SyncCollaborativeAction implements UseCase<CollaborativeActionResult, SyncActionParams> {
  final CollaborativePetRepository repository;

  SyncCollaborativeAction(this.repository);

  @override
  Future<Either<Failure, CollaborativeActionResult>> call(SyncActionParams params) async {
    try {
      // 1. Validar ação
      final petResult = await repository.getCollaborativePet(params.petId);

      return petResult.fold(
        (failure) => Left(failure),
        (pet) async {
          if (pet == null) {
            return Left(ValidationFailure('Pet não encontrado'));
          }

          if (!pet.caretakerIds.contains(params.userId)) {
            return Left(ValidationFailure('Você não é cuidador deste pet'));
          }

          // 2. Criar ação
          final action = CollaborativeActionEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: params.userId,
            petId: params.petId,
            actionType: params.actionType,
            timestamp: DateTime.now(),
            anonymousName: _getAnonymousName(params.userId, pet.caretakerIds),
            effects: _calculateActionEffects(params.actionType),
            xpGained: params.actionType.xpReward,
          );

          // 3. Registrar ação
          final actionResult = await repository.addCollaborativeAction(params.petId, action);

          return actionResult.fold(
            (failure) => Left(failure),
            (_) async {
              // 4. Verificar se desbloqueou reveal
              final updatedPetResult = await repository.getCollaborativePet(params.petId);

              return updatedPetResult.fold(
                (failure) => Right(CollaborativeActionResult(
                  success: true,
                  action: action,
                  xpGained: action.xpGained,
                  canRevealNow: false,
                  message: '${params.actionType.displayName} realizado com sucesso!',
                )),
                (updatedPet) => Right(CollaborativeActionResult(
                  success: true,
                  action: action,
                  xpGained: action.xpGained,
                  canRevealNow: updatedPet?.canReveal ?? false,
                  message: '${params.actionType.displayName} realizado com sucesso!',
                )),
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(ValidationFailure('Erro ao sincronizar ação: $e'));
    }
  }

  String _getAnonymousName(String userId, List<String> caretakerIds) {
    final index = caretakerIds.indexOf(userId);
    return index == 0 ? 'Cuidador A' : 'Cuidador B';
  }

  Map<String, dynamic> _calculateActionEffects(CollaborativeActionType actionType) {
    switch (actionType) {
      case CollaborativeActionType.feed:
        return {'hunger': 20, 'happiness': 5};
      case CollaborativeActionType.play:
        return {'happiness': 25, 'energy': -10};
      case CollaborativeActionType.rest:
        return {'energy': 30};
      case CollaborativeActionType.medicine:
        return {'energy': 20, 'happiness': -5};
      case CollaborativeActionType.clean:
        return {'happiness': 15};
      case CollaborativeActionType.train:
        return {'happiness': 10, 'energy': -15, 'xp': 50};
      case CollaborativeActionType.pet:
        return {'happiness': 20};
      case CollaborativeActionType.exercise:
        return {'energy': -20, 'happiness': 10};
    }
  }
}

class SyncActionParams {
  final String userId;
  final String petId;
  final CollaborativeActionType actionType;

  SyncActionParams({
    required this.userId,
    required this.petId,
    required this.actionType,
  });
}

class CollaborativeActionResult {
  final bool success;
  final CollaborativeActionEntity action;
  final int xpGained;
  final bool canRevealNow;
  final String message;

  CollaborativeActionResult({
    required this.success,
    required this.action,
    required this.xpGained,
    required this.canRevealNow,
    required this.message,
  });
}
