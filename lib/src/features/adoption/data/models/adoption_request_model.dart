import 'package:cloud_firestore/cloud_firestore.dart';

class AdoptionRequest {
  final String id; // ID do documento no Firestore
  final String initiatorUserId; // ID do usuário que iniciou
  final List<String>
      petOptionsIds; // IDs dos 3 pets selecionados pelo iniciador
  final String? friendCode; // Código para amigo (opcional)
  final Timestamp createdAt;
  final String status; // Ex: 'pending', 'completed', 'cancelled'

  AdoptionRequest({
    required this.id,
    required this.initiatorUserId,
    required this.petOptionsIds,
    this.friendCode,
    required this.createdAt,
    required this.status,
  });

  factory AdoptionRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdoptionRequest(
      id: doc.id,
      initiatorUserId: data['initiatorUserId'] ?? '',
      petOptionsIds: List<String>.from(data['petOptionsIds'] ?? []),
      friendCode: data['friendCode'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      status: data['status'] ?? 'pending',
    );
  }
}
