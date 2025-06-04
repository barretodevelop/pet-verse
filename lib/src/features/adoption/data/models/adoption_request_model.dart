import 'package:cloud_firestore/cloud_firestore.dart';

class AdoptionRequest {
  final String id; // ID do documento no Firestore
  final String initiatorUserId; // ID do usuário que iniciou
  final List<String>
      petOptionsIds; // IDs dos 3 pets selecionados pelo iniciador
  final Timestamp createdAt;
  final String status; // Ex: 'pending', 'completed', 'cancelled'
  final String? friendCode; // Código para amigo (opcional, nulo se for pública)
  final bool isPublic; // Indica se a solicitação é pública ou por convite
  final Timestamp? completedAt; // Data de quando a adoção foi completada
  final String? selectedPetId; // ID do pet que foi efetivamente adotado
  final String?
      completerUserId; // ID do usuário que completou a adoção (o segundo adotante)

  AdoptionRequest({
    required this.id,
    required this.initiatorUserId,
    required this.petOptionsIds,
    required this.createdAt,
    required this.status,
    this.friendCode,
    required this.isPublic,
    this.completedAt,
    this.selectedPetId,
    this.completerUserId,
  });

  factory AdoptionRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdoptionRequest(
      id: doc.id,
      initiatorUserId: data['initiatorUserId'] ?? '',
      petOptionsIds: List<String>.from(data['petOptionsIds'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      status: data['status'] ?? 'pending',
      friendCode: data['friendCode'] as String?,
      isPublic: data['isPublic'] ??
          false, // Default para false se o campo não existir
      completedAt: data['completedAt'] as Timestamp?,
      selectedPetId: data['selectedPetId'] as String?,
      completerUserId: data['completerUserId'] as String?,
    );
  }

  // Opcional: Método toFirestore se você precisar converter o objeto de volta para um Map
  // Map<String, dynamic> toFirestore() {
  //   return {
  //     // ... preencher todos os campos
  //   };
  // }
}
