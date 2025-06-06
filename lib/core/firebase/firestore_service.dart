// lib/core/firebase/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../../data/models/adoption_request_status.dart';
import '../../data/models/pet.dart';
import '../../data/models/user_currency.dart';
import '../auth/auth_middleware.dart';
import '../validation/input_validator.dart';

/// Resultado de operação Firestore
class FirestoreResult<T> {
  final bool success;
  final T? data;
  final String? error;

  const FirestoreResult({
    required this.success,
    this.data,
    this.error,
  });

  factory FirestoreResult.success(T data) {
    return FirestoreResult(success: true, data: data);
  }

  factory FirestoreResult.failure(String error) {
    return FirestoreResult(success: false, error: error);
  }
}

/// Serviço do Firestore para gerenciar dados da aplicação
class FirestoreService {
  static final Logger _logger = Logger();
  static FirestoreService? _instance;

  final FirebaseFirestore _firestore;

  // Nomes das coleções
  static const String _usersCollection = 'users';
  static const String _petsCollection = 'pets';
  static const String _adoptionRequestsCollection = 'adoption_requests';
  static const String _userCurrencyCollection = 'user_currency';
  static const String _systemCollection = 'system';

  FirestoreService._() : _firestore = FirebaseFirestore.instance {
    _configureFirestore();
  }

  /// Singleton instance
  static FirestoreService get instance {
    return _instance ??= FirestoreService._();
  }

  /// Configurações do Firestore
  void _configureFirestore() {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  // ========================================
  // USUÁRIOS
  // ========================================

  /// Salva dados do usuário
  Future<FirestoreResult<void>> saveUser(AuthUser user) async {
    try {
      final userDoc = _firestore.collection(_usersCollection).doc(user.id);

      final userData = {
        ...user.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await userDoc.set(userData, SetOptions(merge: true));

      _logger.d('User saved: ${user.id}');
      return FirestoreResult.success(null);
    } catch (e, stackTrace) {
      _logger.e('Failed to save user', error: e, stackTrace: stackTrace);
      return FirestoreResult.failure('Erro ao salvar usuário: $e');
    }
  }

  /// Obtém dados do usuário
  Future<FirestoreResult<AuthUser?>> getUser(String userId) async {
    try {
      final userDoc =
          await _firestore.collection(_usersCollection).doc(userId).get();

      if (!userDoc.exists) {
        return FirestoreResult.success(null);
      }

      final userData = userDoc.data()!;
      final user = AuthUser.fromJson(userData);

      return FirestoreResult.success(user);
    } catch (e, stackTrace) {
      _logger.e('Failed to get user', error: e, stackTrace: stackTrace);
      return FirestoreResult.failure('Erro ao buscar usuário: $e');
    }
  }

  /// Atualiza última atividade do usuário
  Future<FirestoreResult<void>> updateUserLastActivity(String userId) async {
    try {
      final userDoc = _firestore.collection(_usersCollection).doc(userId);

      await userDoc.update({
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      return FirestoreResult.success(null);
    } catch (e) {
      _logger.w('Failed to update user activity: $e');
      return FirestoreResult.failure('Erro ao atualizar atividade: $e');
    }
  }

  // ========================================
  // PETS
  // ========================================

  /// Salva pet no Firestore
  Future<FirestoreResult<String>> savePet(Pet pet) async {
    try {
      // Valida dados do pet
      final validation = _validatePetData(pet);
      if (!validation.isValid) {
        return FirestoreResult.failure(validation.error!);
      }

      final petsCollection = _firestore.collection(_petsCollection);

      final petData = {
        ...pet.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      DocumentReference docRef;
      if (pet.id.isNotEmpty) {
        // Atualiza pet existente
        docRef = petsCollection.doc(pet.id);
        await docRef.set(petData, SetOptions(merge: true));
      } else {
        // Cria novo pet
        docRef = await petsCollection.add(petData);
      }

      _logger.d('Pet saved: ${docRef.id}');
      return FirestoreResult.success(docRef.id);
    } catch (e, stackTrace) {
      _logger.e('Failed to save pet', error: e, stackTrace: stackTrace);
      return FirestoreResult.failure('Erro ao salvar pet: $e');
    }
  }

  /// Obtém pets disponíveis
  Future<FirestoreResult<List<Pet>>> getAvailablePets({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(_petsCollection)
          .where('isAdopted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      final pets = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Pet.fromJson({...data, 'id': doc.id});
      }).toList();

      return FirestoreResult.success(pets);
    } catch (e, stackTrace) {
      _logger.e('Failed to get available pets',
          error: e, stackTrace: stackTrace);
      return FirestoreResult.failure('Erro ao buscar pets: $e');
    }
  }

  /// Obtém pets do usuário
  Future<FirestoreResult<List<Pet>>> getUserPets(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_petsCollection)
          .where('generatedByUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final pets = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Pet.fromJson({...data, 'id': doc.id});
      }).toList();

      return FirestoreResult.success(pets);
    } catch (e, stackTrace) {
      _logger.e('Failed to get user pets', error: e, stackTrace: stackTrace);
      return FirestoreResult.failure('Erro ao buscar pets do usuário: $e');
    }
  }

  /// Atualiza status do pet
  Future<FirestoreResult<void>> updatePetStatus(
    String petId, {
    int? hunger,
    int? happiness,
    int? energy,
    int? level,
    int? xp,
    bool? isAdopted,
  }) async {
    try {
      final petDoc = _firestore.collection(_petsCollection).doc(petId);

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (hunger != null) updates['hunger'] = hunger.clamp(0, 100);
      if (happiness != null) updates['happiness'] = happiness.clamp(0, 100);
      if (energy != null) updates['energy'] = energy.clamp(0, 100);
      if (level != null) updates['level'] = level;
      if (xp != null) updates['xp'] = xp;
      if (isAdopted != null) updates['isAdopted'] = isAdopted;

      await petDoc.update(updates);

      _logger.d('Pet status updated: $petId');
      return FirestoreResult.success(null);
    } catch (e, stackTrace) {
      _logger.e('Failed to update pet status',
          error: e, stackTrace: stackTrace);
      return FirestoreResult.failure('Erro ao atualizar pet: $e');
    }
  }

  // ========================================
  // SOLICITAÇÕES DE ADOÇÃO
  // ========================================

  /// Salva solicitação de adoção
  Future<FirestoreResult<String>> saveAdoptionRequest(
      AdoptionRequest request) async {
    try {
      final requestsCollection =
          _firestore.collection(_adoptionRequestsCollection);

      final requestData = {
        ...request.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      DocumentReference docRef;
      if (request.id.isNotEmpty) {
        docRef = requestsCollection.doc(request.id);
        await docRef.set(requestData, SetOptions(merge: true));
      } else {
        docRef = await requestsCollection.add(requestData);
      }

      _logger.d('Adoption request saved: ${docRef.id}');
      return FirestoreResult.success(docRef.id);
    } catch (e, stackTrace) {
      _logger.e('Failed to save adoption request',
          error: e, stackTrace: stackTrace);
      return FirestoreResult.failure('Erro ao salvar solicitação: $e');
    }
  }

  /// Obtém solicitações de adoção ativas
  Future<FirestoreResult<List<AdoptionRequest>>> getActiveAdoptionRequests({
    int limit = 10,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_adoptionRequestsCollection)
          .where('status', isEqualTo: 'pending')
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .orderBy('expiresAt')
          .limit(limit)
          .get();

      final requests = await Future.wait(
        querySnapshot.docs.map((doc) async {
          final data = doc.data();

          // Busca dados dos pets
          final petsData = data['petsInRequest'] as List<dynamic>;
          final pets = await Future.wait(
            petsData.map((petData) async {
              return Pet.fromJson(petData as Map<String, dynamic>);
            }),
          );

          return AdoptionRequest(
            id: doc.id,
            creatorUserId: data['creatorUserId'] as String,
            petsInRequest: pets,
            daysLeft: data['daysLeft'] as int,
            createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
            expiresAt: (data['expiresAt'] as Timestamp).toDate(),
            status: AdoptionRequestStatus.fromString(data['status'] as String),
            joinerUserId: data['joinerUserId'] as String?,
            chosenPetId: data['chosenPetId'] as String?,
          );
        }),
      );

      return FirestoreResult.success(requests);
    } catch (e, stackTrace) {
      _logger.e('Failed to get adoption requests',
          error: e, stackTrace: stackTrace);
      return FirestoreResult.failure('Erro ao buscar solicitações: $e');
    }
  }

  /// Atualiza status da solicitação de adoção
  Future<FirestoreResult<void>> updateAdoptionRequestStatus(
    String requestId,
    AdoptionRequestStatus status, {
    String? joinerUserId,
    String? chosenPetId,
  }) async {
    try {
      final requestDoc =
          _firestore.collection(_adoptionRequestsCollection).doc(requestId);

      final updates = <String, dynamic>{
        'status': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (joinerUserId != null) updates['joinerUserId'] = joinerUserId;
      if (chosenPetId != null) updates['chosenPetId'] = chosenPetId;

      await requestDoc.update(updates);

      _logger.d('Adoption request status updated: $requestId');
      return FirestoreResult.success(null);
    } catch (e, stackTrace) {
      _logger.e('Failed to update adoption request',
          error: e, stackTrace: stackTrace);
      return FirestoreResult.failure('Erro ao atualizar solicitação: $e');
    }
  }

  // ========================================
  // MOEDA DO USUÁRIO
  // ========================================

  /// Salva moeda do usuário
  Future<FirestoreResult<void>> saveUserCurrency(UserCurrency currency) async {
    try {
      final currencyDoc = _firestore
          .collection(_userCurrencyCollection)
          .doc(currency.currentUserId);

      final currencyData = {
        ...currency.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await currencyDoc.set(currencyData, SetOptions(merge: true));

      _logger.d('User currency saved: ${currency.currentUserId}');
      return FirestoreResult.success(null);
    } catch (e, stackTrace) {
      _logger.e('Failed to save user currency',
          error: e, stackTrace: stackTrace);
      return FirestoreResult.failure('Erro ao salvar moeda: $e');
    }
  }

  /// Obtém moeda do usuário
  Future<FirestoreResult<UserCurrency?>> getUserCurrency(String userId) async {
    try {
      final currencyDoc = await _firestore
          .collection(_userCurrencyCollection)
          .doc(userId)
          .get();

      if (!currencyDoc.exists) {
        return FirestoreResult.success(null);
      }

      final currencyData = currencyDoc.data()!;
      final currency = UserCurrency.fromJson(currencyData);

      return FirestoreResult.success(currency);
    } catch (e, stackTrace) {
      _logger.e('Failed to get user currency',
          error: e, stackTrace: stackTrace);
      return FirestoreResult.failure('Erro ao buscar moeda: $e');
    }
  }

  /// Atualiza moeda do usuário usando transação
  Future<FirestoreResult<void>> updateUserCurrencyTransaction(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final currencyDoc =
          _firestore.collection(_userCurrencyCollection).doc(userId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(currencyDoc);

        final currentData = snapshot.exists
            ? snapshot.data()!
            : UserCurrency.initial(userId).toJson();

        final updatedData = {
          ...currentData,
          ...updates,
          'lastUpdated': DateTime.now().toIso8601String(),
        };

        transaction.set(currencyDoc, updatedData, SetOptions(merge: true));
      });

      _logger.d('User currency updated via transaction: $userId');
      return FirestoreResult.success(null);
    } catch (e, stackTrace) {
      _logger.e('Failed to update user currency',
          error: e, stackTrace: stackTrace);
      return FirestoreResult.failure('Erro ao atualizar moeda: $e');
    }
  }

  // ========================================
  // MÉTODOS UTILITÁRIOS
  // ========================================

  /// Valida dados do pet
  ValidationResult _validatePetData(Pet pet) {
    final validations = <String, ValidationResult>{};

    validations['name'] =
        InputValidator.validate(pet.name, ValidationType.petName);
    validations['description'] =
        InputValidator.validate(pet.description, ValidationType.petDescription);
    validations['type'] = InputValidator.validate(
        pet.type, ValidationType.generic,
        maxLength: 50);

    final errors = validations.entries
        .where((entry) => !entry.value.isValid)
        .map((entry) => '${entry.key}: ${entry.value.error}')
        .toList();

    if (errors.isNotEmpty) {
      return ValidationResult.invalid('Dados inválidos: ${errors.join(', ')}');
    }

    return ValidationResult.valid(pet);
  }

  /// Obtém referência de coleção
  CollectionReference getCollection(String collection) {
    return _firestore.collection(collection);
  }

  /// Executa batch write
  Future<FirestoreResult<void>> executeBatch(
      List<BatchOperation> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        switch (operation.type) {
          case BatchOperationType.set:
            batch.set(
                operation.documentRef, operation.data!, operation.options);
            break;
          case BatchOperationType.update:
            batch.update(operation.documentRef, operation.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(operation.documentRef);
            break;
        }
      }

      await batch.commit();

      _logger
          .d('Batch operation completed with ${operations.length} operations');
      return FirestoreResult.success(null);
    } catch (e, stackTrace) {
      _logger.e('Failed to execute batch', error: e, stackTrace: stackTrace);
      return FirestoreResult.failure('Erro na operação em lote: $e');
    }
  }

  /// Limpa cache offline
  Future<void> clearCache() async {
    try {
      await _firestore.clearPersistence();
      _logger.d('Firestore cache cleared');
    } catch (e) {
      _logger.w('Failed to clear cache: $e');
    }
  }

  /// Habilita/desabilita rede
  Future<void> enableNetwork(bool enable) async {
    try {
      if (enable) {
        await _firestore.enableNetwork();
      } else {
        await _firestore.disableNetwork();
      }
      _logger.d('Firestore network ${enable ? 'enabled' : 'disabled'}');
    } catch (e) {
      _logger.w('Failed to toggle network: $e');
    }
  }
}

// ========================================
// CLASSES AUXILIARES
// ========================================

/// Operação de batch
/// Operação de batch - TRECHO CORRIGIDO
class BatchOperation {
  final BatchOperationType type;
  final DocumentReference documentRef;
  final Map<String, dynamic>? data;
  final SetOptions? options; // Mudança 1: Tornar nullable

  const BatchOperation({
    required this.type,
    required this.documentRef,
    this.data,
    this.options, // Mudança 2: Remover valor padrão
  });

  factory BatchOperation.set(
    DocumentReference documentRef,
    Map<String, dynamic> data, {
    SetOptions? options, // Mudança 3: Tornar nullable
  }) {
    return BatchOperation(
      type: BatchOperationType.set,
      documentRef: documentRef,
      data: data,
      options: options ?? SetOptions(), // Mudança 4: Usar no momento de uso
    );
  }

  factory BatchOperation.update(
    DocumentReference documentRef,
    Map<String, dynamic> data,
  ) {
    return BatchOperation(
      type: BatchOperationType.update,
      documentRef: documentRef,
      data: data,
      options: null, // Mudança 5: Explicit null para update
    );
  }

  factory BatchOperation.delete(DocumentReference documentRef) {
    return BatchOperation(
      type: BatchOperationType.delete,
      documentRef: documentRef,
      options: null, // Mudança 6: Explicit null para delete
    );
  }
}

enum BatchOperationType { set, update, delete }
