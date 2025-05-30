// lib/core/services/adoption_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/adoption_request_model.dart';
import 'package:petverse/core/services/firebase_service.dart';
import 'package:petverse/core/services/user_service.dart';

class AdoptionService {
  static Future<String> createAdoptionRequest({
    required String requesterId,
    required String requesterdisplayName,
    required List<String> selectedPetIds,
  }) async {
    try {
      final now = DateTime.now();
      final request = AdoptionRequestModel(
        id: '', // Will be set by Firestore
        requesterId: requesterId,
        requesterdisplayName: requesterdisplayName,
        selectedPetIds: selectedPetIds,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 5)),
      );

      final docRef =
          await FirebaseService.adoptionRequests.add(request.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar pedido de adoção: $e');
    }
  }

  static Future<List<AdoptionRequestModel>> getPublicAdoptionRequests() async {
    try {
      final now = Timestamp.now();
      final query = await FirebaseService.adoptionRequests
          .where('status', isEqualTo: AdoptionRequestStatus.pending.toString())
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => AdoptionRequestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar pedidos públicos: $e');
    }
  }

  static Future<void> acceptAdoptionRequest({
    required String requestId,
    required String petId,
    required String coParentId,
    required String coParentdisplayName,
  }) async {
    try {
      await FirebaseService.runTransaction((transaction) async {
        // Get the adoption request
        final requestDoc = await transaction.get(
          FirebaseService.adoptionRequests.doc(requestId),
        );

        if (!requestDoc.exists) {
          throw Exception('Pedido de adoção não encontrado');
        }

        final request = AdoptionRequestModel.fromFirestore(requestDoc);

        if (request.status != AdoptionRequestStatus.pending ||
            request.isExpired) {
          throw Exception('Pedido de adoção não está mais disponível');
        }

        // Update adoption request
        transaction.update(
          FirebaseService.adoptionRequests.doc(requestId),
          {
            'acceptedPetId': petId,
            'coParentId': coParentId,
            'coParentdisplayName': coParentdisplayName,
            'status': AdoptionRequestStatus.accepted.toString(),
          },
        );

        // Assign pet to both users
        await UserService.assignPetToUser(request.requesterId, petId);
        await UserService.assignPetToUser(coParentId, petId);
      });
    } catch (e) {
      throw Exception('Erro ao aceitar pedido de adoção: $e');
    }
  }

  static Future<String> generateShareLink(String requestId) async {
    try {
      // Generate a unique share link
      final shareLink = 'https://yourapp.com/adopt/$requestId';

      await FirebaseService.adoptionRequests.doc(requestId).update({
        'shareLink': shareLink,
      });

      return shareLink;
    } catch (e) {
      throw Exception('Erro ao gerar link de compartilhamento: $e');
    }
  }

  static Stream<List<AdoptionRequestModel>> watchPublicAdoptionRequests() {
    final now = Timestamp.now();
    return FirebaseService.adoptionRequests
        .where('status', isEqualTo: AdoptionRequestStatus.pending.toString())
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AdoptionRequestModel.fromFirestore(doc))
            .toList());
  }
}
