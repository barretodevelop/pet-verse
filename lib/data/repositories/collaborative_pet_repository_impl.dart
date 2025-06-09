// File: lib/data/repositories/collaborative_pet_repository_impl.dart

import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/data/models/collaboration/collaborative_action_model.dart';
import 'package:petverse/data/models/collaboration/collaborative_pet_model.dart';
import 'package:petverse/data/models/collaboration/user_collaboration_data_model.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_action_entity.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';
import 'package:petverse/domain/entities/collaboration/reveal_request_entity.dart';
import 'package:petverse/domain/entities/collaboration/user_collaboration_data_entity.dart';
import 'package:petverse/domain/repositories/collaborative_pet_repository.dart';
import 'package:petverse/services/collaboration_matchmaking_service.dart';
import 'package:petverse/services/real_time_sync_service.dart';

class CollaborativePetRepositoryImpl implements CollaborativePetRepository {
  final FirebaseFirestore _firestore;
  final RealTimeSyncService _syncService;
  final CollaborationMatchmakingService _matchmakingService;

  CollaborativePetRepositoryImpl({
    required FirebaseFirestore firestore,
    required RealTimeSyncService syncService,
    required CollaborationMatchmakingService matchmakingService,
  })  : _firestore = firestore,
        _syncService = syncService,
        _matchmakingService = matchmakingService;

  @override
  Future<Either<Failure, List<CollaborativePetEntity>>> getAvailableCollaborativePets() async {
    try {
      final snapshot = await _firestore
          .collection('collaborative_pets')
          .where('status', whereIn: [
            CollaborationStatus.waitingForPartner.name,
            CollaborationStatus.activeCollaboration.name,
          ])
          .orderBy('matchedAt', descending: true)
          .limit(20)
          .get();

      final pets = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CollaborativePetModel.fromMap(data).toEntity();
      }).toList();

      return Right(pets);
    } catch (e) {
      developer.log('Erro ao buscar pets colaborativos: $e', name: 'CollaborativePetRepository');
      return Left(ServerFailure('Erro ao buscar pets colaborativos'));
    }
  }

  @override
  Future<Either<Failure, List<CollaborativePetEntity>>> getUserCollaborativePets(
      String userId) async {
    try {
      final snapshot = await _firestore
          .collection('collaborative_pets')
          .where('caretakerIds', arrayContains: userId)
          .orderBy('matchedAt', descending: true)
          .get();

      final pets = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CollaborativePetModel.fromMap(data).toEntity();
      }).toList();

      return Right(pets);
    } catch (e) {
      developer.log('Erro ao buscar pets do usuário: $e', name: 'CollaborativePetRepository');
      return Left(ServerFailure('Erro ao buscar seus pets colaborativos'));
    }
  }

  @override
  Future<Either<Failure, CollaborativePetEntity?>> getCollaborativePet(String petId) async {
    try {
      final snapshot = await _firestore.collection('collaborative_pets').doc(petId).get();

      if (!snapshot.exists) {
        return const Right(null);
      }

      final data = snapshot.data()!;
      data['id'] = snapshot.id;

      final pet = CollaborativePetModel.fromMap(data).toEntity();
      return Right(pet);
    } catch (e) {
      developer.log('Erro ao buscar pet: $e', name: 'CollaborativePetRepository');
      return Left(ServerFailure('Erro ao buscar pet colaborativo'));
    }
  }

  @override
  Future<Either<Failure, void>> addToWaitingList(String userId, String petId) async {
    try {
      // Processar matchmaking
      final hasMatch = await _matchmakingService.processMatchmaking(petId, userId);

      if (hasMatch) {
        developer.log('Match encontrado para pet $petId', name: 'CollaborativePetRepository');
      }

      return const Right(null);
    } catch (e) {
      developer.log('Erro ao adicionar à lista de espera: $e', name: 'CollaborativePetRepository');
      return Left(ServerFailure('Erro ao processar solicitação de adoção'));
    }
  }

  @override
  Future<Either<Failure, CollaborativePetEntity>> processMatch(
      String petId, List<String> userIds) async {
    try {
      await _firestore.collection('collaborative_pets').doc(petId).update({
        'caretakerIds': userIds,
        'status': CollaborationStatus.activeCollaboration.name,
        'matchedAt': FieldValue.serverTimestamp(),
      });

      final petResult = await getCollaborativePet(petId);

      return petResult.fold(
        (failure) => Left(failure),
        (pet) => pet != null ? Right(pet) : Left(ServerFailure('Pet não encontrado após match')),
      );
    } catch (e) {
      developer.log('Erro ao processar match: $e', name: 'CollaborativePetRepository');
      return Left(ServerFailure('Erro ao processar match'));
    }
  }

  @override
  Future<Either<Failure, CollaborativePetEntity>> createCollaborativePet(
      CollaborativePetEntity pet) async {
    try {
      final model = CollaborativePetModel.fromEntity(pet);
      final docRef = await _firestore.collection('collaborative_pets').add(model.toMap());

      final createdPet = pet.copyWith(id: docRef.id);
      return Right(createdPet);
    } catch (e) {
      developer.log('Erro ao criar pet colaborativo: $e', name: 'CollaborativePetRepository');
      return Left(ServerFailure('Erro ao criar pet colaborativo'));
    }
  }

  @override
  Future<Either<Failure, void>> addCollaborativeAction(
      String petId, CollaborativeActionEntity action) async {
    try {
      final batch = _firestore.batch();

      // Adicionar ação
      final actionRef =
          _firestore.collection('collaborative_pets').doc(petId).collection('actions').doc();

      final actionModel = CollaborativeActionModel.fromEntity(action);
      batch.set(actionRef, actionModel.toMap());

      // Atualizar stats do pet
      final petRef = _firestore.collection('collaborative_pets').doc(petId);
      final currentPet = await petRef.get();

      if (currentPet.exists) {
        final data = currentPet.data()!;
        final updatedStats = _applyActionEffects(data, action.effects);
        batch.update(petRef, updatedStats);
      }

      await batch.commit();

      // Notificar parceiro
      await _syncService.notifyPartnerAction(petId, action.userId, action.actionType.name);

      return const Right(null);
    } catch (e) {
      developer.log('Erro ao adicionar ação: $e', name: 'CollaborativePetRepository');
      return Left(ServerFailure('Erro ao registrar ação'));
    }
  }

  @override
  Future<Either<Failure, List<CollaborativeActionEntity>>> getPetActions(String petId,
      {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('collaborative_pets')
          .doc(petId)
          .collection('actions')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      final actions = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CollaborativeActionModel.fromMap(data).toEntity();
      }).toList();

      return Right(actions);
    } catch (e) {
      developer.log('Erro ao buscar ações: $e', name: 'CollaborativePetRepository');
      return Left(ServerFailure('Erro ao buscar ações do pet'));
    }
  }

  @override
  Future<Either<Failure, bool>> canRevealPartners(String petId) async {
    try {
      final petResult = await getCollaborativePet(petId);

      return petResult.fold(
        (failure) => Left(failure),
        (pet) => Right(pet?.canReveal ?? false),
      );
    } catch (e) {
      return Left(ServerFailure('Erro ao verificar reveal'));
    }
  }

  @override
  Future<Either<Failure, RevealRequestEntity>> requestReveal(String petId, String userId) async {
    try {
      // Implementar lógica de solicitação de reveal
      final request = RevealRequestEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        petId: petId,
        requestedByUserId: userId,
        targetUserId: '', // Será preenchido com o parceiro
        requestedAt: DateTime.now(),
      );

      return Right(request);
    } catch (e) {
      return Left(ServerFailure('Erro ao solicitar reveal'));
    }
  }

  @override
  Future<Either<Failure, void>> respondReveal(
      String requestId, String userId, bool accepted) async {
    try {
      // Implementar resposta ao reveal
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao responder reveal'));
    }
  }

  @override
  Future<Either<Failure, void>> processReveal(String petId, String userId, bool accepted) async {
    try {
      // Implementar processamento do reveal
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Erro ao processar reveal'));
    }
  }

  @override
  Future<Either<Failure, UserCollaborationDataEntity>> getUserCollaborationData(
      String userId) async {
    try {
      final snapshot = await _firestore.collection('user_collaboration_data').doc(userId).get();

      if (!snapshot.exists) {
        // Criar dados iniciais para usuário novo
        final newData = UserCollaborationDataEntity(
          userId: userId,
          experienceLevel: 1,
          maxCollaborativeSlots: 3,
          activePetIds: [],
          completedCollaborations: [],
          totalSuccessfulReveals: 0,
          cooperationRating: 5.0,
          preferredActions: {},
          lastActiveAt: DateTime.now(),
          badges: {},
          stats: const CollaborationStats(
            totalCollaborations: 0,
            successfulReveals: 0,
            averagePetLevel: 0.0,
            totalActionsPerformed: 0,
            partnerSatisfactionRating: 5.0,
            preferredPetTypes: [],
            totalXpGained: 0,
            actionCounts: {},
          ),
        );

        final model = UserCollaborationDataModel.fromEntity(newData);
        await _firestore.collection('user_collaboration_data').doc(userId).set(model.toMap());

        return Right(newData);
      }

      final data = snapshot.data()!;
      data['userId'] = snapshot.id;

      final userData = UserCollaborationDataModel.fromMap(data).toEntity();
      return Right(userData);
    } catch (e) {
      developer.log('Erro ao buscar dados de colaboração: $e', name: 'CollaborativePetRepository');
      return Left(ServerFailure('Erro ao buscar dados de colaboração'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserCollaborationData(
      UserCollaborationDataEntity data) async {
    try {
      final model = UserCollaborationDataModel.fromEntity(data);
      await _firestore
          .collection('user_collaboration_data')
          .doc(data.userId)
          .set(model.toMap(), SetOptions(merge: true));

      return const Right(null);
    } catch (e) {
      developer.log('Erro ao atualizar dados de colaboração: $e',
          name: 'CollaborativePetRepository');
      return Left(ServerFailure('Erro ao atualizar dados de colaboração'));
    }
  }

  @override
  Stream<CollaborativePetEntity> watchPetUpdates(String petId) {
    return _syncService.watchPetUpdates(petId);
  }

  @override
  Stream<CollaborativeActionEntity> watchPetActions(String petId) {
    return _syncService.watchPetActions(petId);
  }

  Map<String, dynamic> _applyActionEffects(
      Map<String, dynamic> currentStats, Map<String, dynamic> effects) {
    final updatedStats = <String, dynamic>{};

    effects.forEach((stat, change) {
      if (currentStats.containsKey(stat)) {
        final currentValue = (currentStats[stat] as num?)?.toDouble() ?? 0.0;
        final newValue = (currentValue + (change as num).toDouble()).clamp(0.0, 100.0);
        updatedStats[stat] = newValue;
      }
    });

    updatedStats['lastUpdated'] = FieldValue.serverTimestamp();
    return updatedStats;
  }
}
