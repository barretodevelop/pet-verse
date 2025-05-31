// lib/core/services/firebase_adoption_service.dart
// VERSÃO CORRIGIDA - Service expandido para conectar Firebase com adoção colaborativa

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/firebase_pet_model.dart';

class FirebaseAdoptionService {
  // Coleções do Firebase para adoção colaborativa
  static const String collaborativePetsCollection = 'collaborative_pets';
  static const String collaborativeRequestsCollection =
      'collaborative_requests';
  static const String petInteractionsCollection = 'pet_interactions';

  // Referências das coleções
  static CollectionReference get collaborativePets =>
      FirebaseFirestore.instance.collection(collaborativePetsCollection);

  static CollectionReference get collaborativeRequests =>
      FirebaseFirestore.instance.collection(collaborativeRequestsCollection);

  static CollectionReference get petInteractions =>
      FirebaseFirestore.instance.collection(petInteractionsCollection);

  // =====================================================
  // DADOS MOCK PARA INICIALIZAÇÃO DO FIREBASE
  // =====================================================

  /// CORRIGIDO: Inicializa dados mock no Firebase (com retry e verificação melhorada)
  static Future<void> initializeMockDataInFirebase() async {
    try {
      print('🔄 Inicializando dados mock no Firebase...');

      // CORRIGIDO: Verificar se já existem dados com retry
      bool hasData = false;
      int retries = 0;
      const maxRetries = 3;

      while (!hasData && retries < maxRetries) {
        try {
          final existingPets = await collaborativePets.limit(1).get();
          hasData = existingPets.docs.isNotEmpty;

          if (hasData) {
            print(
                '✅ Dados já existem no Firebase. Total: ${existingPets.docs.length}');
            return;
          }
        } catch (e) {
          retries++;
          print('⚠️ Tentativa $retries falhou: $e');
          if (retries < maxRetries) {
            await Future.delayed(Duration(seconds: retries * 2));
          }
        }
      }

      if (retries >= maxRetries) {
        throw Exception(
            'Falha ao conectar com Firebase após $maxRetries tentativas');
      }

      // CORRIGIDO: Pets mock com dados mais robustos
      final mockPets = [
        {
          'name': 'Luna',
          'type': 'cat',
          'breed': 'Persa',
          'age': '2 anos',
          'photo': '🐱',
          'traits': ['carinhoso', 'brincalhão', 'calmo'],
          'description':
              'Luna é uma gatinha muito dócil e carinhosa. Adora brincar e é muito tranquila.',
          'happiness': 85,
          'health': 92,
          'energy': 78,
          'hygiene': 90,
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Max',
          'type': 'dog',
          'breed': 'Golden Retriever',
          'age': '3 anos',
          'photo': '🐕',
          'traits': ['leal', 'energético', 'protetor'],
          'description':
              'Max é um cachorro muito leal e protetor. Adora correr e brincar no parque.',
          'happiness': 72,
          'health': 88,
          'energy': 95,
          'hygiene': 70,
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Bella',
          'type': 'rabbit',
          'breed': 'Holland Lop',
          'age': '1 ano',
          'photo': '🐰',
          'traits': ['tímido', 'fofo', 'tranquilo'],
          'description':
              'Bella é uma coelhinha muito fofa e tranquila. É um pouco tímida mas muito carinhosa.',
          'happiness': 90,
          'health': 95,
          'energy': 60,
          'hygiene': 85,
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Charlie',
          'type': 'dog',
          'breed': 'Beagle',
          'age': '4 anos',
          'photo': '🐕‍🦺',
          'traits': ['amigável', 'obediente', 'carinhoso'],
          'description':
              'Charlie é muito amigável e obediente. Adora fazer novos amigos.',
          'happiness': 88,
          'health': 85,
          'energy': 80,
          'hygiene': 75,
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Mimi',
          'type': 'cat',
          'breed': 'Siamês',
          'age': '1 ano',
          'photo': '🐈',
          'traits': ['curioso', 'ativo', 'brincalhão'],
          'description':
              'Mimi é uma gatinha muito curiosa e ativa. Adora explorar novos lugares.',
          'happiness': 80,
          'health': 90,
          'energy': 85,
          'hygiene': 88,
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Rocky',
          'type': 'dog',
          'breed': 'Bulldog',
          'age': '5 anos',
          'photo': '🐶',
          'traits': ['forte', 'protetor', 'leal'],
          'description':
              'Rocky é um cachorro grande e muito protetor. É muito leal à sua família.',
          'happiness': 75,
          'health': 80,
          'energy': 70,
          'hygiene': 65,
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Snow',
          'type': 'hamster',
          'breed': 'Anão Russo',
          'age': '6 meses',
          'photo': '🐹',
          'traits': ['pequeno', 'ativo', 'fofo'],
          'description':
              'Snow é um hamster branquinho muito fofo. É pequeno mas muito ativo.',
          'happiness': 95,
          'health': 100,
          'energy': 90,
          'hygiene': 95,
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Kiwi',
          'type': 'bird',
          'breed': 'Calopsita',
          'age': '2 anos',
          'photo': '🦜',
          'traits': ['colorido', 'falante', 'inteligente'],
          'description':
              'Kiwi é uma calopsita muito colorida e falante. É muito inteligente.',
          'happiness': 85,
          'health': 88,
          'energy': 92,
          'hygiene': 90,
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      // CORRIGIDO: Inserir pets no Firebase com tratamento de erro individual
      print('🔄 Inserindo ${mockPets.length} pets no Firebase...');

      for (int i = 0; i < mockPets.length; i++) {
        try {
          final petData = mockPets[i];
          final petRef = collaborativePets.doc();

          final pet = FirebasePetModel.fromMockPet({
            'id': petRef.id,
            ...petData,
          });

          await petRef.set(pet.toFirestore());
          print('✅ Pet ${i + 1}/${mockPets.length} criado: ${pet.name}');
        } catch (e) {
          print('❌ Erro ao criar pet ${i + 1}: $e');
          // Continuar mesmo se um pet falhar
        }
      }

      print('✅ Inserção de pets concluída!');

      // Aguardar um pouco antes de criar os pedidos
      await Future.delayed(const Duration(seconds: 2));

      // Criar alguns pedidos de adoção mock
      await _createMockAdoptionRequests();

      print('✅ Inicialização completa!');
    } catch (e) {
      print('❌ Erro ao inicializar dados mock: $e');
      rethrow;
    }
  }

  /// CORRIGIDO: Criar pedidos de adoção mock com verificação robusta
  static Future<void> _createMockAdoptionRequests() async {
    try {
      print('🔄 Criando pedidos de adoção mock...');

      // Buscar pets para os pedidos
      final petsSnapshot = await collaborativePets.limit(10).get();
      final pets = petsSnapshot.docs
          .map((doc) => FirebasePetModel.fromFirestore(doc))
          .toList();

      if (pets.length < 6) {
        print(
            '⚠️ Poucos pets disponíveis (${pets.length}). Criando pelo menos alguns pedidos...');
      }

      final mockRequests = [
        {
          'requesterCodename': 'Guardian Azul',
          'requesterColorTheme': 0xFF3B82F6,
          'requesterLevel': 12,
          'selectedPetIds': pets.length >= 3
              ? [pets[0].id, pets[1].id, pets[2].id]
              : [pets.first.id], // Fallback se poucos pets
          'codedMessage':
              'Colaborador experiente busca parceiro dedicado para missão especial',
          'personalityTags': ['dedicado', 'organizado', 'carinhoso'],
          'region': 'Zona Sul - SP',
          'views': 47,
          'interested': 12,
        },
        if (pets.length >= 6)
          {
            'requesterCodename': 'Protetor Rosa',
            'requesterColorTheme': 0xFFEC4899,
            'requesterLevel': 8,
            'selectedPetIds': [pets[3].id, pets[4].id, pets[5].id],
            'codedMessage':
                'Primeira missão em grupo, procuro mentor experiente',
            'personalityTags': ['iniciante', 'entusiasmado', 'responsável'],
            'region': 'Centro - RJ',
            'views': 23,
            'interested': 8,
          },
      ];

      for (final requestData in mockRequests) {
        try {
          final request = CollaborativeAdoptionRequest(
            id: '',
            requesterId: 'mock_user_${Random().nextInt(1000)}',
            requesterDisplayName: 'Usuário Mock',
            requesterCodename: requestData['requesterCodename'] as String,
            requesterColorTheme: requestData['requesterColorTheme'] as int,
            requesterLevel: requestData['requesterLevel'] as int,
            selectedPetIds: requestData['selectedPetIds'] as List<String>,
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(const Duration(days: 5)),
            codedMessage: requestData['codedMessage'] as String,
            personalityTags: requestData['personalityTags'] as List<String>,
            region: requestData['region'] as String,
            views: requestData['views'] as int,
            interested: requestData['interested'] as int,
          );

          await collaborativeRequests.add(request.toFirestore());
          print('✅ Pedido criado: ${request.requesterCodename}');
        } catch (e) {
          print('❌ Erro ao criar pedido: $e');
          // Continuar mesmo se um pedido falhar
        }
      }

      print('✅ Pedidos de adoção mock criados!');
    } catch (e) {
      print('❌ Erro ao criar pedidos mock: $e');
      // Não relançar erro - isso é opcional
    }
  }

  // =====================================================
  // MÉTODOS PRINCIPAIS DO SERVICE
  // =====================================================

  /// CORRIGIDO: Buscar pets disponíveis com retry e fallback
  static Future<List<FirebasePetModel>>
      getAvailablePetsForCollaboration() async {
    try {
      print('🔄 Buscando pets disponíveis...');

      final query = await collaborativePets
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final pets =
          query.docs.map((doc) => FirebasePetModel.fromFirestore(doc)).toList();

      print('✅ ${pets.length} pets encontrados');
      return pets;
    } catch (e) {
      print('❌ Erro ao buscar pets disponíveis: $e');

      // FALLBACK: Se falhar, tentar buscar sem filtros
      try {
        print('🔄 Tentando buscar todos os pets como fallback...');
        final fallbackQuery = await collaborativePets.limit(20).get();

        final fallbackPets = fallbackQuery.docs
            .map((doc) => FirebasePetModel.fromFirestore(doc))
            .toList();

        print('✅ Fallback: ${fallbackPets.length} pets encontrados');
        return fallbackPets;
      } catch (fallbackError) {
        print('❌ Fallback também falhou: $fallbackError');
        return [];
      }
    }
  }

  /// CORRIGIDO: Criar pedido de adoção com validação robusta
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
      // CORRIGIDO: Validações antes da transação
      if (selectedPetIds.length != 3) {
        throw Exception('Deve selecionar exatamente 3 pets');
      }

      if (requesterId.isEmpty ||
          requesterDisplayName.isEmpty ||
          requesterCodename.isEmpty) {
        throw Exception('Dados do usuário inválidos');
      }

      // Verificar se usuário já tem solicitação ativa ANTES da transação
      final existingQuery = await collaborativeRequests
          .where('requesterId', isEqualTo: requesterId)
          .where('status', isEqualTo: AdoptionRequestStatus.pending.toString())
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        throw Exception('Você já possui uma solicitação ativa');
      }

      final petDocs = await Future.wait(
          selectedPetIds.map((petId) => collaborativePets.doc(petId).get()));

      for (int i = 0; i < petDocs.length; i++) {
        final doc = petDocs[i];
        if (!doc.exists) {
          throw Exception('Pet ${selectedPetIds[i]} não encontrado');
        }

        final petData = doc.data() as Map<String, dynamic>?;
        if (petData?['isAvailable'] != true) {
          final pet = FirebasePetModel.fromFirestore(doc);
          throw Exception('Pet ${pet.name} não está mais disponível');
        }
      }

      // Executar transação
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

  /// CORRIGIDO: Buscar pedidos de adoção públicos com fallback
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

      final requests = query.docs
          .map((doc) => CollaborativeAdoptionRequest.fromFirestore(doc))
          .toList();

      print('✅ ${requests.length} pedidos públicos encontrados');
      return requests;
    } catch (e) {
      print('❌ Erro ao buscar pedidos públicos: $e');

      // FALLBACK: buscar sem ordenação complexa
      try {
        final fallbackQuery = await collaborativeRequests
            .where('status',
                isEqualTo: AdoptionRequestStatus.pending.toString())
            .limit(20)
            .get();

        final fallbackRequests = fallbackQuery.docs
            .map((doc) => CollaborativeAdoptionRequest.fromFirestore(doc))
            .where((req) => !req.isExpired) // Filtrar expirados manualmente
            .toList();

        print('✅ Fallback: ${fallbackRequests.length} pedidos encontrados');
        return fallbackRequests;
      } catch (fallbackError) {
        print('❌ Fallback também falhou: $fallbackError');
        return [];
      }
    }
  }

  /// Stream para pedidos em tempo real
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

  /// Buscar pets de um pedido específico
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

  /// Aceitar pedido de adoção
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

        // Verificar se não é o próprio dono tentando aceitar
        if (request.requesterId == coParentId) {
          throw Exception(
              'Você não pode aceitar sua própria solicitação de adoção');
        }

        if (request.status != AdoptionRequestStatus.pending ||
            request.isExpired) {
          throw Exception('Pedido de adoção não está mais disponível');
        }

        // Verificar se o pet está na lista de pets selecionados
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
      });

      print('✅ Adoção aceita com sucesso!');
    } catch (e) {
      print('❌ Erro ao aceitar adoção: $e');
      rethrow;
    }
  }

  /// Incrementar visualizações de um pedido
  static Future<void> incrementViews(String requestId) async {
    try {
      await collaborativeRequests.doc(requestId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('❌ Erro ao incrementar views: $e');
    }
  }

  /// Incrementar interesse em um pedido
  static Future<void> incrementInterest(String requestId) async {
    try {
      await collaborativeRequests.doc(requestId).update({
        'interested': FieldValue.increment(1),
      });
    } catch (e) {
      print('❌ Erro ao incrementar interesse: $e');
    }
  }

  /// Buscar pedidos por filtros
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

  /// Gerar link de compartilhamento
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

  /// Buscar pets do usuário
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

  /// Cancelar pedido de adoção
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

  /// Verificar se usuário já tem solicitação ativa
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

  /// Stream para monitorar solicitação ativa do usuário
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
