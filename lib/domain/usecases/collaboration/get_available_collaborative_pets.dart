// File: lib/domain/usecases/collaboration/get_available_collaborative_pets.dart

import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';
import 'package:petverse/domain/repositories/collaborative_pet_repository.dart';
import 'package:petverse/domain/usecases/usecase.dart';

class GetAvailableCollaborativePets implements UseCase<List<CollaborativePetEntity>, NoParams> {
  final CollaborativePetRepository repository;

  GetAvailableCollaborativePets(this.repository);

  @override
  Future<Either<Failure, List<CollaborativePetEntity>>> call(NoParams params) async {
    try {
      return await repository.getAvailableCollaborativePets();
    } catch (e) {
      return Left(ServerFailure('Erro ao buscar pets colaborativos: $e'));
    }
  }
}
