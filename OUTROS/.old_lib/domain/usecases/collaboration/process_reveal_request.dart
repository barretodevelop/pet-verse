// File: lib/domain/usecases/collaboration/process_reveal_request.dart

import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/collaboration/reveal_request_entity.dart';
import 'package:petverse/domain/repositories/collaborative_pet_repository.dart';
import 'package:petverse/domain/usecases/usecase.dart';

class ProcessRevealRequest implements UseCase<RevealRequestResult, ProcessRevealParams> {
  final CollaborativePetRepository repository;

  ProcessRevealRequest(this.repository);

  @override
  Future<Either<Failure, RevealRequestResult>> call(ProcessRevealParams params) async {
    try {
      // 1. Verificar se pode fazer reveal
      final canRevealResult = await repository.canRevealPartners(params.petId);

      return canRevealResult.fold(
        (failure) => Left(failure),
        (canReveal) async {
          if (!canReveal) {
            return Left(ValidationFailure('Pet ainda não atingiu o nível necessário para reveal'));
          }

          // 2. Criar solicitação de reveal
          final requestResult = await repository.requestReveal(params.petId, params.userId);

          return requestResult.fold(
            (failure) => Left(failure),
            (request) => Right(RevealRequestResult(
              success: true,
              request: request,
              message: 'Solicitação de reveal enviada para seu parceiro!',
            )),
          );
        },
      );
    } catch (e) {
      return Left(ValidationFailure('Erro ao processar solicitação de reveal: $e'));
    }
  }
}

class ProcessRevealParams {
  final String userId;
  final String petId;

  ProcessRevealParams({
    required this.userId,
    required this.petId,
  });
}

class RevealRequestResult {
  final bool success;
  final RevealRequestEntity request;
  final String message;

  RevealRequestResult({
    required this.success,
    required this.request,
    required this.message,
  });
}
