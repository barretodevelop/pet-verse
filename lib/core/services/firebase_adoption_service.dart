// lib/core/services/firebase_adoption_service.dart
// CORRIGIDO: Adicionando validações para impedir auto-adoção e melhorar fluxo

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
  // MÉTODOS CORRIGIDOS
  // =====================================================

  /// CORRIGIDO: Aceitar pedido de adoção com validações melhoradas
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
            'coParentId': coParentId,
            'coParentDisplayName': coParentDisplayName,
            'coParentCodename': coParentCodename,
            'status': AdoptionRequestStatus.accepted.toString(),
            'acceptedAt': FieldValue.serverTimestamp(),
          },
        );

        // Atualizar pet escolhido
        transaction.update(
          collaborativePets.doc(petId),
          {
            'ownerIds': [request.requesterId, coParentId],
            'primaryOwnerId': request.requesterId,
            'coOwnerId': coParentId,
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
          'userId': request.requesterId,
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
          'userId': coParentId,
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
      });

      // CORREÇÃO 4: Enviar notificações push após a transação
      await _sendAdoptionNotifications(requestId, petId, coParentCodename);

      print('✅ Adoção aceita com sucesso!');
    } catch (e) {
      print('❌ Erro ao aceitar adoção: $e');
      rethrow;
    }
  }

  /// NOVO: Enviar notificações push para ambos os usuários
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

  /// NOVO: Buscar pet específico pelo ID
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

  /// NOVO: Buscar notificações não lidas do usuário
  static Future<List<Map<String, dynamic>>> getUserNotifications(
      String userId) async {
    try {
      final query = await notifications
          .where('userId', isEqualTo: userId)
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

  /// NOVO: Marcar notificação como lida
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

  /// NOVO: Verificar se usuário pode aceitar solicitação
  static Future<bool> canAcceptRequest(String requestId, String userId) async {
    try {
      final requestDoc = await collaborativeRequests.doc(requestId).get();
      if (!requestDoc.exists) return false;

      final request = CollaborativeAdoptionRequest.fromFirestore(requestDoc);

      // Não pode aceitar própria solicitação
      if (request.requesterId == userId) return false;

      // Verificar se ainda está pendente e não expirou
      return request.status == AdoptionRequestStatus.pending &&
          !request.isExpired;
    } catch (e) {
      print('❌ Erro ao verificar permissão de aceitação: $e');
      return false;
    }
  }

  // =====================================================
  // MÉTODOS EXISTENTES (mantidos sem alteração)
  // =====================================================

  /// Inicializa dados mock no Firebase
  static Future<void> initializeMockDataInFirebase() async {
    try {
      print('🔄 Inicializando dados mock no Firebase...');

      // Verificar se já existem dados
      final existingPets = await collaborativePets.limit(1).get();
      if (existingPets.docs.isNotEmpty) {
        print('✅ Dados já existem no Firebase.');
        return;
      }

      // Pets mock com dados robustos
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
        // ... outros pets
      ];

      // Inserir pets no Firebase
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
        }
      }

      print('✅ Inicialização completa!');
    } catch (e) {
      print('❌ Erro ao inicializar dados mock: $e');
      rethrow;
    }
  }

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

  /// Criar pedido de adoção colaborativa
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
      if (selectedPetIds.length != 3) {
        throw Exception('Deve selecionar exatamente 3 pets');
      }

      // Verificar se usuário já tem solicitação ativa
      final existingQuery = await collaborativeRequests
          .where('requesterId', isEqualTo: requesterId)
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

        final docRef = collaborativeRequests.doc();
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

        transaction.update(
          collaborativeRequests.doc(requestId),
          {'status': AdoptionRequestStatus.cancelled.toString()},
        );

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



// erro ao solicitar adocao e cancelar e tentar novamente nao permite dizedo que ja tenho , porem nao existe mais solicitacao pendindg so cancelameda parece erro de atualizacao de stado
// a tela esta refheshando de tempo em tempo evoltando pra tela de adote um pet apos ter ido para a pagina de criacao ou a tela de aguardando sempre refesh 
// snack bar de aviso demora muito pra sair da tela

// esta gravando o id do usuario e deveria ser  o uid

// deveria ter chamado o provider pra criar o pet 