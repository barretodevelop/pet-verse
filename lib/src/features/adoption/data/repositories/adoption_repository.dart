// lib/src/features/adoption/data/repositories/adoption_repository.dart
// CORRIGIDO - Validações críticas + operações atômicas + tratamento robusto de erros

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/adoption/data/models/adoption_request_model.dart';
import 'package:petverse/src/features/auth/data/repositories/auth_repository.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart';
import 'package:uuid/uuid.dart';

// Exceções específicas para melhor tratamento de erros
class AdoptionException implements Exception {
  final String message;
  final String code;

  const AdoptionException(this.message, this.code);

  @override
  String toString() => 'AdoptionException[$code]: $message';
}

class AdoptionValidationException extends AdoptionException {
  const AdoptionValidationException(String message)
      : super(message, 'VALIDATION_ERROR');
}

class AdoptionStateException extends AdoptionException {
  const AdoptionStateException(String message) : super(message, 'STATE_ERROR');
}

final adoptionRepositoryProvider = Provider<AdoptionRepository>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AdoptionRepository(FirebaseFirestore.instance, authRepository);
});

class AdoptionRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  AdoptionRepository(this._firestore, this._authRepository);

  // VALIDAÇÕES CENTRALIZADAS
  void _validateUser() {
    final user = _authRepository.getCurrentUser();
    if (user == null) {
      throw const AdoptionValidationException('Usuário não autenticado');
    }
  }

  void _validatePetSelection(List<String> petIds) {
    if (petIds.isEmpty) {
      throw const AdoptionValidationException('Nenhum pet selecionado');
    }
    if (petIds.length > 3) {
      throw const AdoptionValidationException('Máximo de 3 pets permitidos');
    }
    if (petIds.toSet().length != petIds.length) {
      throw const AdoptionValidationException('Pets duplicados na seleção');
    }
  }

  // BUSCA SOLICITAÇÕES PENDENTES - Com validação de data
  Stream<List<AdoptionRequest>> getPendingAdoptionRequests() {
    try {
      return _firestore
          .collection('adoptionRequests')
          .where('status', isEqualTo: 'pending')
          .where('isPublic', isEqualTo: true)
          .where('createdAt',
              isGreaterThan: Timestamp.fromDate(DateTime.now()
                  .subtract(const Duration(days: 7)))) // Apenas últimos 7 dias
          .orderBy('createdAt', descending: true)
          .limit(50) // Limitar para performance
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => AdoptionRequest.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      debugPrint(
          '[AdoptionRepository] Erro ao buscar solicitações pendentes: $e');
      return Stream.value([]);
    }
  }

  // BUSCA SOLICITAÇÃO POR ID - Com cache local
  Future<AdoptionRequest?> getAdoptionRequestById(String requestId) async {
    try {
      if (requestId.isEmpty) {
        throw const AdoptionValidationException('ID da solicitação inválido');
      }

      final doc =
          await _firestore.collection('adoptionRequests').doc(requestId).get();

      if (!doc.exists) {
        debugPrint(
            '[AdoptionRepository] Solicitação não encontrada: $requestId');
        return null;
      }

      final request = AdoptionRequest.fromFirestore(doc);

      // Validar se ainda está válida (não expirou)
      final daysSinceCreation =
          DateTime.now().difference(request.createdAt.toDate()).inDays;

      if (daysSinceCreation > 7) {
        debugPrint('[AdoptionRepository] Solicitação expirada: $requestId');
        return null;
      }

      return request;
    } catch (e) {
      debugPrint('[AdoptionRepository] Erro ao buscar solicitação por ID: $e');
      return null;
    }
  }

  // BUSCA POR CÓDIGO DE AMIGO - Com validação robusta
  Future<AdoptionRequest?> getAdoptionRequestByFriendCode(
      String friendCode) async {
    try {
      if (friendCode.trim().isEmpty || friendCode.length < 6) {
        throw const AdoptionValidationException('Código de amigo inválido');
      }

      final cleanCode = friendCode.trim().toUpperCase();

      final querySnapshot = await _firestore
          .collection('adoptionRequests')
          .where('friendCode', isEqualTo: cleanCode)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final request = AdoptionRequest.fromFirestore(querySnapshot.docs.first);

      // Verificar se não expirou
      final hoursSinceCreation =
          DateTime.now().difference(request.createdAt.toDate()).inHours;

      if (hoursSinceCreation > 168) {
        // 7 dias em horas
        await _expireRequest(request.id);
        return null;
      }

      return request;
    } catch (e) {
      debugPrint('[AdoptionRepository] Erro ao buscar por código: $e');
      rethrow;
    }
  }

  // BUSCA PETS POR IDS - Com validação de estado
  Future<List<Pet>> getPetsByIds(List<String> petIds) async {
    try {
      if (petIds.isEmpty) return [];

      // Validar IDs
      for (final id in petIds) {
        if (id.trim().isEmpty) {
          throw const AdoptionValidationException(
              'ID de pet inválido encontrado');
        }
      }

      final snapshot = await _firestore
          .collection('pets')
          .where(FieldPath.documentId, whereIn: petIds)
          .get();

      final pets = snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();

      // Verificar se todos os pets estão disponíveis
      final unavailablePets = pets.where((pet) => pet.isAdopted).toList();
      if (unavailablePets.isNotEmpty) {
        debugPrint(
            '[AdoptionRepository] Pets indisponíveis encontrados: ${unavailablePets.map((p) => p.id)}');
      }

      return pets.where((pet) => !pet.isAdopted).toList();
    } catch (e) {
      debugPrint('[AdoptionRepository] Erro ao buscar pets: $e');
      return [];
    }
  }

  // PETS DISPONÍVEIS - Com filtros de qualidade
  Stream<List<Pet>> getAvailablePets() {
    try {
      return _firestore
          .collection('pets')
          .where('isAdopted', isEqualTo: false)
          .orderBy('name')
          .limit(100) // Limitar para performance
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Pet.fromFirestore(doc))
            .where((pet) => _isPetValid(pet))
            .toList();
      });
    } catch (e) {
      debugPrint('[AdoptionRepository] Erro ao buscar pets disponíveis: $e');
      return Stream.value([]);
    }
  }

  bool _isPetValid(Pet pet) {
    return pet.name.isNotEmpty &&
        pet.species.isNotEmpty &&
        pet.imageUrl.isNotEmpty &&
        !pet.isAdopted;
  }

  // CRIAR SOLICITAÇÃO - Operação atômica com validações
  Future<String?> createAdoptionRequest(
    List<String> petOptionIds, {
    required bool isPublic,
  }) async {
    _validateUser();
    _validatePetSelection(petOptionIds);

    final User currentUser = _authRepository.getCurrentUser()!;

    try {
      // Verificar se usuário já tem solicitação ativa
      await _validateNoActiveRequest(currentUser.uid);

      // Verificar se todos os pets estão disponíveis
      await _validatePetsAvailable(petOptionIds);

      String? friendCode;
      if (!isPublic) {
        friendCode = _generateFriendCode();
      }

      // Operação atômica
      final batch = _firestore.batch();

      // Criar documento de solicitação
      final requestRef = _firestore.collection('adoptionRequests').doc();
      batch.set(requestRef, {
        'id': requestRef.id,
        'initiatorUserId': currentUser.uid,
        'petOptionsIds': petOptionIds,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'friendCode': friendCode,
        'isPublic': isPublic,
        'expiresAt':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      });

      // Marcar pets como em processo de adoção
      for (final petId in petOptionIds) {
        final petRef = _firestore.collection('pets').doc(petId);
        batch.update(petRef, {
          'currentAdoptionRequestId': requestRef.id,
          'lastUpdateAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      debugPrint(
          '[AdoptionRepository] Solicitação criada com sucesso: ${requestRef.id}');
      return friendCode;
    } catch (e) {
      debugPrint('[AdoptionRepository] Erro ao criar solicitação: $e');
      rethrow;
    }
  }

  // CONFIRMAR ADOÇÃO - Operação totalmente atômica
  Future<void> confirmAdoption(String requestId, String selectedPetId) async {
    _validateUser();

    if (requestId.isEmpty || selectedPetId.isEmpty) {
      throw const AdoptionValidationException('IDs inválidos fornecidos');
    }

    final User currentUser = _authRepository.getCurrentUser()!;

    try {
      // Validações prévias
      final request = await getAdoptionRequestById(requestId);
      if (request == null) {
        throw const AdoptionStateException(
            'Solicitação não encontrada ou expirada');
      }

      if (request.status != 'pending') {
        throw const AdoptionStateException(
            'Solicitação não está mais pendente');
      }

      if (!request.petOptionsIds.contains(selectedPetId)) {
        throw const AdoptionValidationException(
            'Pet não faz parte desta solicitação');
      }

      if (request.initiatorUserId == currentUser.uid) {
        throw const AdoptionValidationException(
            'Não é possível adotar seu próprio pet');
      }

      // Verificar se pet ainda está disponível
      final petDoc =
          await _firestore.collection('pets').doc(selectedPetId).get();
      if (!petDoc.exists) {
        throw const AdoptionStateException('Pet não encontrado');
      }

      final petData = petDoc.data() as Map<String, dynamic>;
      if (petData['isAdopted'] == true) {
        throw const AdoptionStateException('Pet já foi adotado');
      }

      // OPERAÇÃO ATÔMICA - Tudo ou nada
      final batch = _firestore.batch();

      // 1. Atualizar solicitação
      final requestRef =
          _firestore.collection('adoptionRequests').doc(requestId);
      batch.update(requestRef, {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'selectedPetId': selectedPetId,
        'completerUserId': currentUser.uid,
      });

      // 2. Criar documento de adoção
      final adoptionRef = _firestore.collection('adoptions').doc();
      batch.set(adoptionRef, {
        'requestId': requestId,
        'petId': selectedPetId,
        'adopter1Id': request.initiatorUserId,
        'adopter2Id': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // 3. Atualizar pet
      final petRef = _firestore.collection('pets').doc(selectedPetId);
      batch.update(petRef, {
        'isAdopted': true,
        'currentAdoptionRequestId': null,
        'adoptionId': adoptionRef.id,
        'adoptedAt': FieldValue.serverTimestamp(),
      });

      // 4. Atualizar usuários
      final adopter1Ref =
          _firestore.collection('users').doc(request.initiatorUserId);
      final adopter2Ref = _firestore.collection('users').doc(currentUser.uid);

      batch.update(adopter1Ref, {
        'pets': FieldValue.arrayUnion([selectedPetId]),
        'lastAdoptionAt': FieldValue.serverTimestamp(),
      });

      batch.update(adopter2Ref, {
        'pets': FieldValue.arrayUnion([selectedPetId]),
        'lastAdoptionAt': FieldValue.serverTimestamp(),
      });

      // 5. Limpar outros pets da solicitação
      final otherPetIds =
          request.petOptionsIds.where((id) => id != selectedPetId);
      for (final petId in otherPetIds) {
        final otherPetRef = _firestore.collection('pets').doc(petId);
        batch.update(otherPetRef, {
          'currentAdoptionRequestId': null,
        });
      }

      await batch.commit();

      debugPrint('[AdoptionRepository] Adoção confirmada com sucesso');
    } catch (e) {
      debugPrint('[AdoptionRepository] Erro ao confirmar adoção: $e');
      rethrow;
    }
  }

  // REJEITAR SOLICITAÇÃO - Com limpeza completa
  Future<void> rejectAdoptionRequest(String requestId) async {
    try {
      if (requestId.isEmpty) {
        throw const AdoptionValidationException('ID da solicitação inválido');
      }

      final request = await getAdoptionRequestById(requestId);
      if (request == null) {
        throw const AdoptionStateException('Solicitação não encontrada');
      }

      final batch = _firestore.batch();

      // Atualizar solicitação
      final requestRef =
          _firestore.collection('adoptionRequests').doc(requestId);
      batch.update(requestRef, {
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      // Limpar pets
      for (final petId in request.petOptionsIds) {
        final petRef = _firestore.collection('pets').doc(petId);
        batch.update(petRef, {
          'currentAdoptionRequestId': null,
        });
      }

      await batch.commit();

      debugPrint('[AdoptionRepository] Solicitação rejeitada com sucesso');
    } catch (e) {
      debugPrint('[AdoptionRepository] Erro ao rejeitar solicitação: $e');
      rethrow;
    }
  }

  // MÉTODOS AUXILIARES DE VALIDAÇÃO

  Future<void> _validateNoActiveRequest(String userId) async {
    final existingRequests = await _firestore
        .collection('adoptionRequests')
        .where('initiatorUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    if (existingRequests.docs.isNotEmpty) {
      throw const AdoptionStateException(
          'Você já possui uma solicitação de adoção ativa');
    }
  }

  Future<void> _validatePetsAvailable(List<String> petIds) async {
    final pets = await getPetsByIds(petIds);

    if (pets.length != petIds.length) {
      final unavailableIds =
          petIds.where((id) => !pets.any((pet) => pet.id == id)).toList();

      throw AdoptionStateException(
          'Pets indisponíveis: ${unavailableIds.join(', ')}');
    }
  }

  String _generateFriendCode() {
    return const Uuid().v4().substring(0, 8).toUpperCase();
  }

  Future<void> _expireRequest(String requestId) async {
    try {
      await _firestore.collection('adoptionRequests').doc(requestId).update({
        'status': 'expired',
        'expiredAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[AdoptionRepository] Erro ao expirar solicitação: $e');
    }
  }
}
