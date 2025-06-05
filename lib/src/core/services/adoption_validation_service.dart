// lib/src/core/services/adoption_validation_service.dart
// NOVO - Service centralizado para todas as validações de adoção

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/auth/data/repositories/auth_repository.dart';

// Provider para o serviço de validação
final adoptionValidationServiceProvider =
    Provider<AdoptionValidationService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AdoptionValidationService(
    firestore: FirebaseFirestore.instance,
    authRepository: authRepository,
  );
});

class AdoptionValidationService {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  AdoptionValidationService({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
  })  : _firestore = firestore,
        _authRepository = authRepository;

  // VALIDAÇÃO PRINCIPAL: Usuário pode criar nova solicitação?
  Future<AdoptionValidationResult> canCreateAdoptionRequest() async {
    try {
      final user = _authRepository.getCurrentUser();
      if (user == null) {
        return AdoptionValidationResult.failure(
          AdoptionValidationError.unauthenticated,
          'Usuário não autenticado',
        );
      }

      // Verificar se já tem pets
      final userHasPets = await _checkUserHasPets(user.uid);
      if (userHasPets) {
        return AdoptionValidationResult.failure(
          AdoptionValidationError.alreadyHasPets,
          'Usuário já possui pets adotados',
        );
      }

      // Verificar se já tem solicitação ativa
      final hasActiveRequest = await _checkActiveAdoptionRequest(user.uid);
      if (hasActiveRequest) {
        return AdoptionValidationResult.failure(
          AdoptionValidationError.activeRequestExists,
          'Usuário já possui uma solicitação de adoção ativa',
        );
      }

      return AdoptionValidationResult.success();
    } catch (e) {
      debugPrint('[AdoptionValidation] Erro em canCreateAdoptionRequest: $e');
      return AdoptionValidationResult.failure(
        AdoptionValidationError.unknown,
        'Erro interno: $e',
      );
    }
  }

  // VALIDAÇÃO: Usuário pode confirmar adoção?
  Future<AdoptionValidationResult> canConfirmAdoption(String requestId) async {
    try {
      final user = _authRepository.getCurrentUser();
      if (user == null) {
        return AdoptionValidationResult.failure(
          AdoptionValidationError.unauthenticated,
          'Usuário não autenticado',
        );
      }

      // Verificar se a solicitação existe e está pendente
      final requestDoc =
          await _firestore.collection('adoptionRequests').doc(requestId).get();

      if (!requestDoc.exists) {
        return AdoptionValidationResult.failure(
          AdoptionValidationError.requestNotFound,
          'Solicitação de adoção não encontrada',
        );
      }

      final requestData = requestDoc.data()!;
      final status = requestData['status'] as String?;

      if (status != 'pending') {
        return AdoptionValidationResult.failure(
          AdoptionValidationError.requestNotPending,
          'Solicitação não está mais pendente (status: $status)',
        );
      }

      // Verificar se o usuário não é o iniciador
      final initiatorId = requestData['initiatorUserId'] as String?;
      if (initiatorId == user.uid) {
        return AdoptionValidationResult.failure(
          AdoptionValidationError.selfAdoption,
          'Usuário não pode adotar seus próprios pets',
        );
      }

      // Verificar se o usuário já tem pets
      final userHasPets = await _checkUserHasPets(user.uid);
      if (userHasPets) {
        return AdoptionValidationResult.failure(
          AdoptionValidationError.alreadyHasPets,
          'Usuário já possui pets adotados',
        );
      }

      return AdoptionValidationResult.success();
    } catch (e) {
      debugPrint('[AdoptionValidation] Erro em canConfirmAdoption: $e');
      return AdoptionValidationResult.failure(
        AdoptionValidationError.unknown,
        'Erro interno: $e',
      );
    }
  }

  // VALIDAÇÃO: Pet IDs são válidos?
  Future<AdoptionValidationResult> validatePetIds(List<String> petIds) async {
    if (petIds.isEmpty) {
      return AdoptionValidationResult.failure(
        AdoptionValidationError.invalidPets,
        'Lista de pets não pode estar vazia',
      );
    }

    if (petIds.length != 3) {
      return AdoptionValidationResult.failure(
        AdoptionValidationError.invalidPets,
        'Deve selecionar exatamente 3 pets',
      );
    }

    try {
      // Verificar se todos os pets existem e não estão adotados
      final petDocs = await _firestore
          .collection('pets')
          .where(FieldPath.documentId, whereIn: petIds)
          .get();

      if (petDocs.docs.length != petIds.length) {
        return AdoptionValidationResult.failure(
          AdoptionValidationError.invalidPets,
          'Alguns pets selecionados não existem',
        );
      }

      for (final doc in petDocs.docs) {
        final petData = doc.data();
        final isAdopted = petData['isAdopted'] as bool? ?? false;

        if (isAdopted) {
          return AdoptionValidationResult.failure(
            AdoptionValidationError.petsNotAvailable,
            'Pet ${doc.id} já foi adotado',
          );
        }
      }

      return AdoptionValidationResult.success();
    } catch (e) {
      debugPrint('[AdoptionValidation] Erro em validatePetIds: $e');
      return AdoptionValidationResult.failure(
        AdoptionValidationError.unknown,
        'Erro ao validar pets: $e',
      );
    }
  }

  // VALIDAÇÃO: Código de amigo é válido?
  Future<AdoptionValidationResult> validateFriendCode(String friendCode) async {
    if (friendCode.trim().isEmpty) {
      return AdoptionValidationResult.failure(
        AdoptionValidationError.invalidFriendCode,
        'Código de amigo não pode estar vazio',
      );
    }

    if (friendCode.length < 6 || friendCode.length > 12) {
      return AdoptionValidationResult.failure(
        AdoptionValidationError.invalidFriendCode,
        'Código de amigo deve ter entre 6 e 12 caracteres',
      );
    }

    try {
      final querySnapshot = await _firestore
          .collection('adoptionRequests')
          .where('friendCode', isEqualTo: friendCode.toUpperCase())
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return AdoptionValidationResult.failure(
          AdoptionValidationError.friendCodeNotFound,
          'Código de amigo não encontrado ou expirado',
        );
      }

      return AdoptionValidationResult.success();
    } catch (e) {
      debugPrint('[AdoptionValidation] Erro em validateFriendCode: $e');
      return AdoptionValidationResult.failure(
        AdoptionValidationError.unknown,
        'Erro ao validar código: $e',
      );
    }
  }

  // Métodos auxiliares privados
  Future<bool> _checkUserHasPets(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();

    if (!userDoc.exists) return false;

    final userData = userDoc.data()!;
    final pets = userData['pets'] as List<dynamic>? ?? [];

    return pets.isNotEmpty;
  }

  Future<bool> _checkActiveAdoptionRequest(String userId) async {
    final querySnapshot = await _firestore
        .collection('adoptionRequests')
        .where('initiatorUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}

// Classe para resultado das validações
@immutable
class AdoptionValidationResult {
  final bool isValid;
  final AdoptionValidationError? error;
  final String? message;

  const AdoptionValidationResult._({
    required this.isValid,
    this.error,
    this.message,
  });

  factory AdoptionValidationResult.success() {
    return const AdoptionValidationResult._(isValid: true);
  }

  factory AdoptionValidationResult.failure(
    AdoptionValidationError error,
    String message,
  ) {
    return AdoptionValidationResult._(
      isValid: false,
      error: error,
      message: message,
    );
  }

  @override
  String toString() {
    return 'AdoptionValidationResult(isValid: $isValid, error: $error, message: $message)';
  }
}

// Enum para tipos de erro de validação
enum AdoptionValidationError {
  unauthenticated,
  alreadyHasPets,
  activeRequestExists,
  requestNotFound,
  requestNotPending,
  selfAdoption,
  invalidPets,
  petsNotAvailable,
  invalidFriendCode,
  friendCodeNotFound,
  unknown,
}

// Extensão para mensagens user-friendly
extension AdoptionValidationErrorExtension on AdoptionValidationError {
  String get userMessage {
    switch (this) {
      case AdoptionValidationError.unauthenticated:
        return 'Você precisa estar logado para continuar';
      case AdoptionValidationError.alreadyHasPets:
        return 'Você já possui pets adotados';
      case AdoptionValidationError.activeRequestExists:
        return 'Você já tem uma solicitação de adoção ativa';
      case AdoptionValidationError.requestNotFound:
        return 'Solicitação não encontrada';
      case AdoptionValidationError.requestNotPending:
        return 'Esta solicitação não está mais disponível';
      case AdoptionValidationError.selfAdoption:
        return 'Você não pode adotar seus próprios pets';
      case AdoptionValidationError.invalidPets:
        return 'Seleção de pets inválida';
      case AdoptionValidationError.petsNotAvailable:
        return 'Um ou mais pets não estão disponíveis';
      case AdoptionValidationError.invalidFriendCode:
        return 'Código de amigo inválido';
      case AdoptionValidationError.friendCodeNotFound:
        return 'Código não encontrado ou expirado';
      case AdoptionValidationError.unknown:
        return 'Erro inesperado. Tente novamente.';
    }
  }
}
