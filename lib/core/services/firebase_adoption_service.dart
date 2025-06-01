// lib/core/services/firebase_adoption_service.dart
// CORRIGIDO: UID vs ID, melhorada criação de pets e validações

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/firebase_pet_model.dart';
import 'package:petverse/core/services/notification_service.dart';

class FirebaseAdoptionService {
  // Coleções do Firebase para adoção colaborativa
  static const String collaborativePetsCollection = 'collaborative_pets';
  static const String collaborativeRequestsCollection =
      'collaborative_requests';
  static const String petInteractionsCollection = 'pet_interactions';
  static const String notificationsCollection = 'notifications';

  // Referências das coleções
  static CollectionReference get collaborativePets =>
      FirebaseFirestore.instance.collection(collaborativePetsCollection);

  static CollectionReference get collaborativeRequests =>
      FirebaseFirestore.instance.collection(collaborativeRequestsCollection);

  static CollectionReference get petInteractions =>
      FirebaseFirestore.instance.collection(petInteractionsCollection);

  static CollectionReference get notifications =>
      FirebaseFirestore.instance.collection(notificationsCollection);

  // =====================================================
  // MÉTODOS CORRIGIDOS E MELHORADOS
  // =====================================================

  /// CORRIGIDO: Aceitar pedido de adoção com validações melhoradas e correção de UID
  static Future<void> acceptAdoptionRequest({
    required String requestId,
    required String petId,
    required String coParentId, // Este é o UID do Firebase Auth
    required String coParentDisplayName,
    required String coParentCodename,
  }) async {
    try {
      print('🔄 Iniciando aceitação de adoção...');
      print('Request ID: $requestId');
      print('Pet ID: $petId');
      print('Co-Parent UID: $coParentId'); // CORRIGIDO: Agora é UID

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Buscar o pedido
        final requestDoc = await transaction.get(
          collaborativeRequests.doc(requestId),
        );

        if (!requestDoc.exists) {
          throw Exception('Pedido de adoção não encontrado');
        }

        final request = CollaborativeAdoptionRequest.fromFirestore(requestDoc);

        // CORREÇÃO 1: Verificar se não é o próprio dono tentando aceitar
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

        // Buscar dados do pet para notificação
        final petDoc = await transaction.get(collaborativePets.doc(petId));
        if (!petDoc.exists) {
          throw Exception('Pet não encontrado');
        }
        final pet = FirebasePetModel.fromFirestore(petDoc);

        // Atualizar pedido de adoção
        transaction.update(
          collaborativeRequests.doc(requestId),
          {
            'acceptedPetId': petId,
            'coParentId': coParentId, // UID do co-parent
            'coParentDisplayName': coParentDisplayName,
            'coParentCodename': coParentCodename,
            'status': AdoptionRequestStatus.accepted.toString(),
            'acceptedAt': FieldValue.serverTimestamp(),
          },
        );

        // Atualizar pet escolhido com UIDs corretos
        transaction.update(
          collaborativePets.doc(petId),
          {
            'ownerIds': [request.requesterId, coParentId], // Ambos UIDs
            'primaryOwnerId':
                request.requesterId, // UID do solicitante original
            'coOwnerId': coParentId, // UID do co-parent
            'isAvailable': false,
            'adoptedAt': FieldValue.serverTimestamp(),
            'adoptionRequestId': requestId,
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

        // CORREÇÃO 2: Criar notificação para o solicitante original
        final notificationRef = notifications.doc();
        transaction.set(notificationRef, {
          'id': notificationRef.id,
          'userId': request.requesterId, // UID do solicitante
          'type': 'adoption_accepted',
          'title': 'Adoção Aceita! 🎉',
          'message':
              '$coParentCodename aceitou cuidar de ${pet.name} com você!',
          'data': {
            'requestId': requestId,
            'petId': petId,
            'petName': pet.name,
            'coParentCodename': coParentCodename,
          },
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // CORREÇÃO 3: Criar notificação para o co-parent que aceitou
        final coParentNotificationRef = notifications.doc();
        transaction.set(coParentNotificationRef, {
          'id': coParentNotificationRef.id,
          'userId': coParentId, // UID do co-parent
          'type': 'adoption_confirmed',
          'title': 'Adoção Confirmada! 🐾',
          'message': 'Você agora é co-guardião de ${pet.name}!',
          'data': {
            'requestId': requestId,
            'petId': petId,
            'petName': pet.name,
            'originalRequesterCodename': request.requesterCodename,
          },
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print('✅ Transação de adoção concluída com sucesso');
      });

      // CORREÇÃO 4: Enviar notificações push após a transação
      await _sendAdoptionNotifications(requestId, petId, coParentCodename);

      print('✅ Adoção aceita com sucesso!');
    } catch (e) {
      print('❌ Erro ao aceitar adoção: $e');
      rethrow;
    }
  }

  /// MELHORADO: Inicializa dados mock no Firebase com melhor estrutura
  static Future<void> initializeMockDataInFirebase() async {
    try {
      print('🔄 Inicializando dados mock no Firebase...');

      // Verificar se já existem dados
      final existingPets = await collaborativePets.limit(1).get();
      if (existingPets.docs.isNotEmpty) {
        print('✅ Dados já existem no Firebase.');
        return;
      }

      // MELHORADO: Pets mock com dados mais robustos e estrutura correta
      final mockPetsData = [
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
          'careLevel': 'Fácil',
          'isAvailable': true,
          'ownerIds': <String>[], // Lista vazia de UIDs
          'primaryOwnerId': null,
          'coOwnerId': null,
          'adoptionRequestId': null,
          'adoptedAt': null,
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
          'careLevel': 'Médio',
          'isAvailable': true,
          'ownerIds': <String>[],
          'primaryOwnerId': null,
          'coOwnerId': null,
          'adoptionRequestId': null,
          'adoptedAt': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Bella',
          'type': 'rabbit',
          'breed': 'Mini Lop',
          'age': '1 ano',
          'photo': '🐰',
          'traits': ['fofo', 'tranquilo', 'tímido'],
          'description':
              'Bella é uma coelhinha muito fofa e tranquila, adora cenouras.',
          'happiness': 95,
          'health': 98,
          'energy': 60,
          'hygiene': 85,
          'careLevel': 'Fácil',
          'isAvailable': true,
          'ownerIds': <String>[],
          'primaryOwnerId': null,
          'coOwnerId': null,
          'adoptionRequestId': null,
          'adoptedAt': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Charlie',
          'type': 'dog',
          'breed': 'Beagle',
          'age': '4 anos',
          'photo': '🐕',
          'traits': ['amigável', 'obediente', 'calmo'],
          'description':
              'Charlie é um cachorro muito amigável e obediente, perfeito para famílias.',
          'happiness': 88,
          'health': 85,
          'energy': 80,
          'hygiene': 75,
          'careLevel': 'Fácil',
          'isAvailable': true,
          'ownerIds': <String>[],
          'primaryOwnerId': null,
          'coOwnerId': null,
          'adoptionRequestId': null,
          'adoptedAt': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Mimi',
          'type': 'cat',
          'breed': 'Siamês',
          'age': '6 meses',
          'photo': '🐱',
          'traits': ['filhote', 'curioso', 'brincalhão'],
          'description':
              'Mimi é uma gatinha filhote muito curiosa e brincalhona.',
          'happiness': 68,
          'health': 95,
          'energy': 90,
          'hygiene': 80,
          'careLevel': 'Médio',
          'isAvailable': true,
          'ownerIds': <String>[],
          'primaryOwnerId': null,
          'coOwnerId': null,
          'adoptionRequestId': null,
          'adoptedAt': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Rocky',
          'type': 'dog',
          'breed': 'Husky Siberiano',
          'age': '5 anos',
          'photo': '🐕‍🦺',
          'traits': ['aventureiro', 'energético', 'inteligente'],
          'description':
              'Rocky é um husky muito ativo e aventureiro, ideal para pessoas ativas.',
          'happiness': 75,
          'health': 90,
          'energy': 98,
          'hygiene': 65,
          'careLevel': 'Difícil',
          'isAvailable': true,
          'ownerIds': <String>[],
          'primaryOwnerId': null,
          'coOwnerId': null,
          'adoptionRequestId': null,
          'adoptedAt': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      // MELHORADO: Inserir pets com estrutura correta no Firebase
      for (int i = 0; i < mockPetsData.length; i++) {
        try {
          final petData = mockPetsData[i];
          final petRef = collaborativePets.doc();

          // Criar o pet com ID correto
          final petWithId = {
            'id': petRef.id,
            ...petData,
          };

          await petRef.set(petWithId);
          print(
              '✅ Pet ${i + 1}/${mockPetsData.length} criado: ${petData['name']}');
        } catch (e) {
          print('❌ Erro ao criar pet ${i + 1}: $e');
        }
      }

      print('✅ Inicialização de pets completa!');
    } catch (e) {
      print('❌ Erro ao inicializar dados mock: $e');
      rethrow;
    }
  }

  /// CORRIGIDO: Criar pedido de adoção colaborativa com UID correto
  static Future<String> createCollaborativeAdoptionRequest({
    required String requesterId, // Este é o UID do Firebase Auth
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
      print('🔄 Criando pedido de adoção colaborativa...');
      print('Requester UID: $requesterId'); // CORRIGIDO: Agora é UID

      if (selectedPetIds.length != 3) {
        throw Exception('Deve selecionar exatamente 3 pets');
      }

      // MELHORADO: Verificar se usuário já tem solicitação ativa usando UID
      final existingQuery = await collaborativeRequests
          .where('requesterId', isEqualTo: requesterId) // UID
          .where('status', isEqualTo: AdoptionRequestStatus.pending.toString())
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        throw Exception('Você já possui uma solicitação ativa');
      }

      // Verificar disponibilidade dos pets
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
        final request = CollaborativeAdoptionRequest(
          id: '',
          requesterId: requesterId, // UID correto
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

        final docRef = collaborativeRequests.doc();
        transaction.set(docRef, request.copyWith(id: docRef.id).toFirestore());

        // Marcar pets como não disponíveis temporariamente
        for (final petId in selectedPetIds) {
          final petRef = collaborativePets.doc(petId);
          transaction.update(petRef, {
            'isAvailable': false,
            'adoptionRequestId': docRef.id,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        print('✅ Pedido criado com ID: ${docRef.id}');
        return docRef.id;
      });

      print('✅ Pedido de adoção criado: $requestId');
      return requestId;
    } catch (e) {
      print('❌ Erro ao criar pedido de adoção: $e');
      rethrow;
    }
  }

  /// CORRIGIDO: Buscar pets do usuário usando UID
  static Future<List<FirebasePetModel>> getUserPets(String userUid) async {
    try {
      print('🔍 Buscando pets do usuário: $userUid');

      final query = await collaborativePets
          .where('ownerIds', arrayContains: userUid) // UID correto
          .get();

      final pets =
          query.docs.map((doc) => FirebasePetModel.fromFirestore(doc)).toList();

      print('✅ Encontrados ${pets.length} pets para o usuário');
      return pets;
    } catch (e) {
      print('❌ Erro ao buscar pets do usuário: $e');
      return [];
    }
  }

  /// CORRIGIDO: Verificar se usuário já tem solicitação ativa usando UID
  static Future<CollaborativeAdoptionRequest?> getUserActiveRequest(
      String userUid) async {
    try {
      print('🔍 Buscando solicitação ativa do usuário: $userUid');

      final query = await collaborativeRequests
          .where('requesterId', isEqualTo: userUid) // UID correto
          .where('status', isEqualTo: AdoptionRequestStatus.pending.toString())
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print('✅ Nenhuma solicitação ativa encontrada');
        return null;
      }

      final request =
          CollaborativeAdoptionRequest.fromFirestore(query.docs.first);
      print('✅ Solicitação ativa encontrada: ${request.id}');
      return request;
    } catch (e) {
      print('❌ Erro ao buscar solicitação ativa: $e');
      return null;
    }
  }

  /// CORRIGIDO: Stream para monitorar solicitação ativa do usuário usando UID
  static Stream<CollaborativeAdoptionRequest?> watchUserActiveRequest(
      String userUid) {
    return collaborativeRequests
        .where('requesterId', isEqualTo: userUid) // UID correto
        .where('status', isEqualTo: AdoptionRequestStatus.pending.toString())
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return CollaborativeAdoptionRequest.fromFirestore(snapshot.docs.first);
    });
  }

  // =====================================================
  // MÉTODOS EXISTENTES MANTIDOS (sem alteração de UID)
  // =====================================================

  /// Buscar pets disponíveis para colaboração
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

  /// Buscar pedidos de adoção públicos
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

  /// Cancelar pedido de adoção
  static Future<void> cancelAdoptionRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final requestDoc = await transaction.get(
          collaborativeRequests.doc(requestId),
        );

        if (!requestDoc.exists) return;

        final request = CollaborativeAdoptionRequest.fromFirestore(requestDoc);

        transaction.update(
          collaborativeRequests.doc(requestId),
          {'status': AdoptionRequestStatus.cancelled.toString()},
        );

        // Liberar pets para disponibilidade
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

  // =====================================================
  // MÉTODOS AUXILIARES
  // =====================================================

  /// Buscar pet específico pelo ID
  static Future<FirebasePetModel?> getPetById(String petId) async {
    try {
      final petDoc = await collaborativePets.doc(petId).get();
      if (petDoc.exists) {
        return FirebasePetModel.fromFirestore(petDoc);
      }
      return null;
    } catch (e) {
      print('❌ Erro ao buscar pet por ID: $e');
      return null;
    }
  }

  /// Buscar notificações não lidas do usuário (usando UID)
  static Future<List<Map<String, dynamic>>> getUserNotifications(
      String userUid) async {
    try {
      final query = await notifications
          .where('userId', isEqualTo: userUid) // UID correto
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return query.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar notificações: $e');
      return [];
    }
  }

  /// Marcar notificação como lida
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await notifications.doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Erro ao marcar notificação como lida: $e');
    }
  }

  /// Verificar se usuário pode aceitar solicitação (usando UID)
  static Future<bool> canAcceptRequest(String requestId, String userUid) async {
    try {
      final requestDoc = await collaborativeRequests.doc(requestId).get();
      if (!requestDoc.exists) return false;

      final request = CollaborativeAdoptionRequest.fromFirestore(requestDoc);

      // Não pode aceitar própria solicitação (comparando UIDs)
      if (request.requesterId == userUid) return false;

      // Verificar se ainda está pendente e não expirou
      return request.status == AdoptionRequestStatus.pending &&
          !request.isExpired;
    } catch (e) {
      print('❌ Erro ao verificar permissão de aceitação: $e');
      return false;
    }
  }

  /// Enviar notificações push para ambos os usuários
  static Future<void> _sendAdoptionNotifications(
    String requestId,
    String petId,
    String coParentCodename,
  ) async {
    try {
      // Buscar dados do pedido e pet para as notificações
      final requestDoc = await collaborativeRequests.doc(requestId).get();
      final petDoc = await collaborativePets.doc(petId).get();

      if (requestDoc.exists && petDoc.exists) {
        final request = CollaborativeAdoptionRequest.fromFirestore(requestDoc);
        final pet = FirebasePetModel.fromFirestore(petDoc);

        // Notificação para o solicitante original
        await NotificationService().showCoParentCareNotification(
          coParentCodename,
          'aceitou cuidar de ${pet.name} com você!',
        );

        print('📱 Notificações push enviadas com sucesso');
      }
    } catch (e) {
      print('❌ Erro ao enviar notificações push: $e');
      // Não relança o erro para não afetar o fluxo principal
    }
  }
}
