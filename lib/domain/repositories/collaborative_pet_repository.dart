// File: lib/domain/repositories/collaborative_pet_repository.dart

import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_action_entity.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';
import 'package:petverse/domain/entities/collaboration/reveal_request_entity.dart';
import 'package:petverse/domain/entities/collaboration/user_collaboration_data_entity.dart';

abstract class CollaborativePetRepository {
  /// Buscar pets disponíveis para adoção colaborativa
  Future<Either<Failure, List<CollaborativePetEntity>>> getAvailableCollaborativePets();

  /// Buscar pets colaborativos do usuário
  Future<Either<Failure, List<CollaborativePetEntity>>> getUserCollaborativePets(String userId);

  /// Buscar pet colaborativo por ID
  Future<Either<Failure, CollaborativePetEntity?>> getCollaborativePet(String petId);

  /// Adicionar usuário à lista de espera para adoção
  Future<Either<Failure, void>> addToWaitingList(String userId, String petId);

  /// Processar match entre usuários
  Future<Either<Failure, CollaborativePetEntity>> processMatch(String petId, List<String> userIds);

  /// Criar novo pet colaborativo
  Future<Either<Failure, CollaborativePetEntity>> createCollaborativePet(
      CollaborativePetEntity pet);

  /// Atualizar pet com ação colaborativa
  Future<Either<Failure, void>> addCollaborativeAction(
      String petId, CollaborativeActionEntity action);

  /// Buscar ações recentes do pet
  Future<Either<Failure, List<CollaborativeActionEntity>>> getPetActions(String petId,
      {int limit = 10});

  /// Verificar se pode revelar parceiros
  Future<Either<Failure, bool>> canRevealPartners(String petId);

  /// Processar solicitação de reveal
  Future<Either<Failure, RevealRequestEntity>> requestReveal(String petId, String userId);

  /// Responder solicitação de reveal
  Future<Either<Failure, void>> respondReveal(String requestId, String userId, bool accepted);

  /// Processar reveal de parceiros
  Future<Either<Failure, void>> processReveal(String petId, String userId, bool accepted);

  /// Buscar dados de colaboração do usuário
  Future<Either<Failure, UserCollaborationDataEntity>> getUserCollaborationData(String userId);

  /// Atualizar dados de colaboração do usuário
  Future<Either<Failure, void>> updateUserCollaborationData(UserCollaborationDataEntity data);

  /// Stream de atualizações em tempo real do pet
  Stream<CollaborativePetEntity> watchPetUpdates(String petId);

  /// Stream de ações em tempo real
  Stream<CollaborativeActionEntity> watchPetActions(String petId);
}
