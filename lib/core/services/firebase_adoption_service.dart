// lib/core/services/firebase_adoption_service.dart
// UPDATE: Service expandido para conectar Firebase com adoção colaborativa

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/firebase_pet_model.dart';

class FirebaseAdoptionService {
  // UPDATE: Coleções do Firebase para adoção colaborativa
  static const String collaborativePetsCollection = 'collaborative_pets';
  static const String collaborativeRequestsCollection =
      'collaborative_requests';
  static const String petInteractionsCollection = 'pet_interactions';

  // NEW: Referências das coleções
  static CollectionReference get collaborativePets =>
      FirebaseFirestore.instance.collection(collaborativePetsCollection);

  static CollectionReference get collaborativeRequests =>
      FirebaseFirestore.instance.collection(collaborativeRequestsCollection);

  static CollectionReference get petInteractions =>
      FirebaseFirestore.instance.collection(petInteractionsCollection);

  // NEW: =====================================================
  // DADOS MOCK PARA INICIALIZAÇÃO DO FIREBASE
  // =====================================================

  /// NEW: Inicializa dados mock no Firebase (executar uma vez apenas)
  static Future<void> initializeMockDataInFirebase() async {
    try {
      print('🔄 Inicializando dados mock no Firebase...');

      // Verificar se já existem dados
      final existingPets = await collaborativePets.limit(1).get();
      if (existingPets.docs.isNotEmpty) {
        print('✅ Dados já existem no Firebase. Pulando inicialização.');
        return;
      }

      // NEW: Pets mock para inserir no Firebase
      final mockPets = [
        {
          'name': 'Luna',
          'type': 'cat',
          'breed': 'Persa',
          'age': '2 anos',
          'photo': '🐱',
          'traits': ['carinhoso', 'brincalhão', 'calmo'],
          'description': 'Luna é uma gatinha muito dócil e carinhosa',
          'happiness': 85,
          'health': 92,
          'energy': 78,
          'hygiene': 90,
          'isAvailable': true,
        },
        {
          'name': 'Max',
          'type': 'dog',
          'breed': 'Golden Retriever',
          'age': '3 anos',
          'photo': '🐕',
          'traits': ['leal', 'energético', 'protetor'],
          'description': 'Max é um cachorro muito leal e protetor',
          'happiness': 72,
          'health': 88,
          'energy': 95,
          'hygiene': 70,
          'isAvailable': true,
        },
        {
          'name': 'Bella',
          'type': 'rabbit',
          'breed': 'Holland Lop',
          'age': '1 ano',
          'photo': '🐰',
          'traits': ['tímido', 'fofo', 'tranquilo'],
          'description': 'Bella é uma coelhinha muito fofa e tranquila',
          'happiness': 90,
          'health': 95,
          'energy': 60,
          'hygiene': 85,
          'isAvailable': true,
        },
        {
          'name': 'Charlie',
          'type': 'dog',
          'breed': 'Beagle',
          'age': '4 anos',
          'photo': '🐕',
          'traits': ['amigável', 'obediente', 'carinhoso'],
          'description': 'Charlie é muito amigável e obediente',
          'happiness': 88,
          'health': 85,
          'energy': 80,
          'hygiene': 75,
          'isAvailable': true,
        },
        {
          'name': 'Mimi',
          'type': 'cat',
          'breed': 'Siamês',
          'age': '1 ano',
          'photo': '🐱',
          'traits': ['curioso', 'ativo', 'brincalhão'],
          'description': 'Mimi é uma gatinha muito curiosa e ativa',
          'happiness': 80,
          'health': 90,
          'energy': 85,
          'hygiene': 88,
          'isAvailable': true,
        },
        {
          'name': 'Rocky',
          'type': 'dog',
          'breed': 'Bulldog',
          'age': '5 anos',
          'photo': '🐕',
          'traits': ['forte', 'protetor', 'leal'],
          'description': 'Rocky é um cachorro grande e muito protetor',
          'happiness': 75,
          'health': 80,
          'energy': 70,
          'hygiene': 65,
          'isAvailable': true,
        },
        {
          'name': 'Snow',
          'type': 'hamster',
          'breed': 'Anão Russo',
          'age': '6 meses',
          'photo': '🐹',
          'traits': ['pequeno', 'ativo', 'fofo'],
          'description': 'Snow é um hamster branquinho muito fofo',
          'happiness': 95,
          'health': 100,
          'energy': 90,
          'hygiene': 95,
          'isAvailable': true,
        },
        {
          'name': 'Kiwi',
          'type': 'bird',
          'breed': 'Calopsita',
          'age': '2 anos',
          'photo': '🦜',
          'traits': ['colorido', 'falante', 'inteligente'],
          'description': 'Kiwi é uma calopsita muito colorida e falante',
          'happiness': 85,
          'health': 88,
          'energy': 92,
          'hygiene': 90,
          'isAvailable': true,
        },
      ];

      // NEW: Inserir pets no Firebase
      final batch = FirebaseFirestore.instance.batch();

      for (final petData in mockPets) {
        final petRef = collaborativePets.doc();
        final pet = FirebasePetModel.fromMockPet({
          'id': petRef.id,
          ...petData,
        });
        batch.set(petRef, pet.toFirestore());
      }

      await batch.commit();
      print('✅ ${mockPets.length} pets inseridos no Firebase!');

      // NEW: Criar alguns pedidos de adoção mock
      await _createMockAdoptionRequests();
    } catch (e) {
      print('❌ Erro ao inicializar dados mock: $e');
      rethrow;
    }
  }

  // NEW: Criar pedidos de adoção mock
  static Future<void> _createMockAdoptionRequests() async {
    try {
      // Buscar alguns pets para os pedidos
      final petsSnapshot = await collaborativePets.limit(6).get();
      final pets = petsSnapshot.docs
          .map((doc) => FirebasePetModel.fromFirestore(doc))
          .toList();

      if (pets.length < 6) return;

      final mockRequests = [
        {
          'requesterCodename': 'Guardian Azul',
          'requesterColorTheme': 0xFF3B82F6,
          'requesterLevel': 12,
          'selectedPetIds': [pets[0].id, pets[1].id, pets[2].id],
          'codedMessage':
              'Colaborador experiente busca parceiro dedicado para missão especial',
          'personalityTags': ['dedicado', 'organizado', 'carinhoso'],
          'region': 'Zona Sul - SP',
          'views': 47,
          'interested': 12,
        },
        {
          'requesterCodename': 'Protetor Rosa',
          'requesterColorTheme': 0xFFEC4899,
          'requesterLevel': 8,
          'selectedPetIds': [pets[3].id, pets[4].id, pets[5].id],
          'codedMessage': 'Primeira missão em grupo, procuro mentor experiente',
          'personalityTags': ['iniciante', 'entusiasmado', 'responsável'],
          'region': 'Centro - RJ',
          'views': 23,
          'interested': 8,
        },
      ];

      for (final requestData in mockRequests) {
        final request = CollaborativeAdoptionRequest(
          id: '',
          requesterId: 'mock_user_${Random().nextInt(1000)}',
          requesterDisplayName: 'Usuário Mock',
          requesterCodename: requestData['requesterCodename'] as String,
          requesterColorTheme: requestData['requesterColorTheme'] as int,
          requesterLevel: requestData['requesterLevel'] as int,
          selectedPetIds: [pets[0].id, pets[1].id, pets[2].id],
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 5)),
          codedMessage: requestData['codedMessage'] as String,
          personalityTags: ['iniciante', 'entusiasmado', 'responsável'],
          region: requestData['region'] as String,
          views: requestData['views'] as int,
          interested: requestData['interested'] as int,
        );

        await collaborativeRequests.add(request.toFirestore());
      }

      print('✅ Pedidos de adoção mock criados!');
    } catch (e) {
      print('❌ Erro ao criar pedidos mock: $e');
    }
  }

  // UPDATE: =====================================================
  // MÉTODOS PRINCIPAIS DO SERVICE
  // =====================================================

  /// UPDATE: Buscar pets disponíveis para adoção colaborativa
  static Future<List<FirebasePetModel>>
      getAvailablePetsForCollaboration() async {
    try {
      final query = await collaborativePets
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return query.docs
          .map((doc) => FirebasePetModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar pets disponíveis: $e');
      return [];
    }
  }

  static Future<String> createCollaborativeAdoptionRequest({
    required String requesterId,
    required String requesterDisplayName,
    required String requesterCodename,
    required int requesterColorTheme,
    required int requesterLevel,
    required List<String> selectedPetIds,
    required String codedMessage,
    required List<String> personalityTags,
    required String region,
  }) async {
    try {
      // SOLUÇÃO 1: Verificar ANTES da transação
      final existingQuery = await collaborativeRequests
          .where('requesterId', isEqualTo: requesterId)
          .where('status', isEqualTo: AdoptionRequestStatus.pending.toString())
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        throw Exception('Você já possui uma solicitação ativa');
      }

      // Agora executar a transação sem queries complexas
      final String requestId = await FirebaseFirestore.instance
          .runTransaction<String>((transaction) async {
        // Criar o pedido de adoção
        final request = CollaborativeAdoptionRequest(
          id: '',
          requesterId: requesterId,
          requesterDisplayName: requesterDisplayName,
          requesterCodename: requesterCodename,
          requesterColorTheme: requesterColorTheme,
          requesterLevel: requesterLevel,
          selectedPetIds: selectedPetIds,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 5)),
          codedMessage: codedMessage,
          personalityTags: personalityTags,
          region: region,
        );

        // Criar documento de referência
        final docRef = collaborativeRequests.doc();

        // Adicionar o pedido
        transaction.set(docRef, request.copyWith(id: docRef.id).toFirestore());

        // Marcar pets como não disponíveis
        for (final petId in selectedPetIds) {
          final petRef = collaborativePets.doc(petId);
          transaction.update(petRef, {
            'isAvailable': false,
            'adoptionRequestId': docRef.id,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        return docRef.id;
      });

      print('✅ Pedido de adoção criado: $requestId');
      return requestId;
    } catch (e) {
      print('❌ Erro ao criar pedido de adoção: $e');
      rethrow;
    }
  }

  /// UPDATE: Buscar pedidos de adoção públicos
  static Future<List<CollaborativeAdoptionRequest>>
      getPublicAdoptionRequests() async {
    try {
      final now = Timestamp.now();
      final query = await collaborativeRequests
          .where('status', isEqualTo: AdoptionRequestStatus.pending.toString())
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => CollaborativeAdoptionRequest.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar pedidos públicos: $e');
      return [];
    }
  }

  /// NEW: Stream para pedidos em tempo real
  static Stream<List<CollaborativeAdoptionRequest>>
      watchPublicAdoptionRequests() {
    final now = Timestamp.now();
    return collaborativeRequests
        .where('status', isEqualTo: AdoptionRequestStatus.pending.toString())
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CollaborativeAdoptionRequest.fromFirestore(doc))
            .toList());
  }

  /// NEW: Buscar pets de um pedido específico
  static Future<List<FirebasePetModel>> getPetsFromRequest(
      String requestId) async {
    try {
      final requestDoc = await collaborativeRequests.doc(requestId).get();
      if (!requestDoc.exists) return [];

      final request = CollaborativeAdoptionRequest.fromFirestore(requestDoc);

      final petDocs = await Future.wait(request.selectedPetIds
          .map((petId) => collaborativePets.doc(petId).get()));

      return petDocs
          .where((doc) => doc.exists)
          .map((doc) => FirebasePetModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar pets do pedido: $e');
      return [];
    }
  }

  static Future<void> acceptAdoptionRequest({
    required String requestId,
    required String petId,
    required String coParentId,
    required String coParentDisplayName,
    required String coParentCodename,
  }) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Buscar o pedido
        final requestDoc = await transaction.get(
          collaborativeRequests.doc(requestId),
        );

        if (!requestDoc.exists) {
          throw Exception('Pedido de adoção não encontrado');
        }

        final request = CollaborativeAdoptionRequest.fromFirestore(requestDoc);

        // VERIFICAR se não é o próprio dono tentando aceitar
        if (request.requesterId == coParentId) {
          throw Exception(
              'Você não pode aceitar sua própria solicitação de adoção');
        }

        if (request.status != AdoptionRequestStatus.pending ||
            request.isExpired) {
          throw Exception('Pedido de adoção não está mais disponível');
        }

        // VERIFICAR se o pet está na lista de pets selecionados
        if (!request.selectedPetIds.contains(petId)) {
          throw Exception('Este pet não faz parte desta solicitação');
        }

        // Atualizar pedido de adoção
        transaction.update(
          collaborativeRequests.doc(requestId),
          {
            'acceptedPetId': petId,
            'coParentId': coParentId,
            'coParentDisplayName': coParentDisplayName,
            'coParentCodename': coParentCodename,
            'status': AdoptionRequestStatus.accepted.toString(),
          },
        );

        // Atualizar pet escolhido
        transaction.update(
          collaborativePets.doc(petId),
          {
            'ownerIds': [request.requesterId, coParentId],
            'primaryOwnerId': request.requesterId,
            'isAvailable': false,
          },
        );

        // Marcar outros pets como disponíveis novamente
        for (final otherPetId in request.selectedPetIds) {
          if (otherPetId != petId) {
            transaction.update(
              collaborativePets.doc(otherPetId),
              {
                'isAvailable': true,
                'adoptionRequestId': FieldValue.delete(),
              },
            );
          }
        }

        // TODO: Adicionar pets aos perfis dos usuários
        // Isso será implementado quando tivermos o UserService
      });

      print('✅ Adoção aceita com sucesso!');
    } catch (e) {
      print('❌ Erro ao aceitar adoção: $e');
      rethrow;
    }
  }

  /// NEW: Incrementar visualizações de um pedido
  static Future<void> incrementViews(String requestId) async {
    try {
      await collaborativeRequests.doc(requestId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('❌ Erro ao incrementar views: $e');
    }
  }

  /// NEW: Incrementar interesse em um pedido
  static Future<void> incrementInterest(String requestId) async {
    try {
      await collaborativeRequests.doc(requestId).update({
        'interested': FieldValue.increment(1),
      });
    } catch (e) {
      print('❌ Erro ao incrementar interesse: $e');
    }
  }

  /// NEW: Buscar pedidos por filtros
  static Future<List<CollaborativeAdoptionRequest>> getFilteredRequests({
    List<String>? petTypes,
    int? maxDaysRemaining,
    String? region,
  }) async {
    try {
      Query query = collaborativeRequests
          .where('status', isEqualTo: AdoptionRequestStatus.pending.toString())
          .where('expiresAt', isGreaterThan: Timestamp.now());

      if (region != null && region.isNotEmpty) {
        query = query.where('region', isEqualTo: region);
      }

      final snapshot = await query
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: true)
          .get();

      var requests = snapshot.docs
          .map((doc) => CollaborativeAdoptionRequest.fromFirestore(doc))
          .toList();

      // Filtrar por dias restantes
      if (maxDaysRemaining != null) {
        requests = requests
            .where((req) => req.daysRemaining <= maxDaysRemaining)
            .toList();
      }

      return requests;
    } catch (e) {
      print('❌ Erro ao buscar pedidos filtrados: $e');
      return [];
    }
  }

  /// NEW: Gerar link de compartilhamento
  static Future<String> generateShareLink(String requestId) async {
    try {
      final shareLink = 'https://petverse.app/adopt/$requestId';

      await collaborativeRequests.doc(requestId).update({
        'shareLink': shareLink,
      });

      return shareLink;
    } catch (e) {
      print('❌ Erro ao gerar link: $e');
      throw Exception('Erro ao gerar link de compartilhamento: $e');
    }
  }

  /// NEW: Buscar pets do usuário
  static Future<List<FirebasePetModel>> getUserPets(String userId) async {
    try {
      final query = await collaborativePets
          .where('ownerIds', arrayContains: userId)
          .get();

      return query.docs
          .map((doc) => FirebasePetModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar pets do usuário: $e');
      return [];
    }
  }

  /// NEW: Cancelar pedido de adoção
  static Future<void> cancelAdoptionRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final requestDoc = await transaction.get(
          collaborativeRequests.doc(requestId),
        );

        if (!requestDoc.exists) return;

        final request = CollaborativeAdoptionRequest.fromFirestore(requestDoc);

        // Atualizar status do pedido
        transaction.update(
          collaborativeRequests.doc(requestId),
          {'status': AdoptionRequestStatus.cancelled.toString()},
        );

        // Marcar pets como disponíveis novamente
        for (final petId in request.selectedPetIds) {
          transaction.update(
            collaborativePets.doc(petId),
            {
              'isAvailable': true,
              'adoptionRequestId': FieldValue.delete(),
            },
          );
        }
      });

      print('✅ Pedido cancelado com sucesso!');
    } catch (e) {
      print('❌ Erro ao cancelar pedido: $e');
      rethrow;
    }
  }

  /// NEW: Verificar se usuário já tem solicitação ativa
  static Future<CollaborativeAdoptionRequest?> getUserActiveRequest(
      String userId) async {
    try {
      final query = await collaborativeRequests
          .where('requesterId', isEqualTo: userId)
          .where('status', isEqualTo: AdoptionRequestStatus.pending.toString())
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;

      return CollaborativeAdoptionRequest.fromFirestore(query.docs.first);
    } catch (e) {
      print('❌ Erro ao buscar solicitação ativa: $e');
      return null;
    }
  }

  /// NEW: Stream para monitorar solicitação ativa do usuário
  static Stream<CollaborativeAdoptionRequest?> watchUserActiveRequest(
      String userId) {
    return collaborativeRequests
        .where('requesterId', isEqualTo: userId)
        .where('status', isEqualTo: AdoptionRequestStatus.pending.toString())
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return CollaborativeAdoptionRequest.fromFirestore(snapshot.docs.first);
    });
  }
}






// lib/core/services/firebase_adoption_service.dart - MÉTODOS ADICIONAIS

// Adicionar estes métodos à classe FirebaseAdoptionService existente:
 

/// UPDATE: Aceitar pedido com verificação de proprietário
