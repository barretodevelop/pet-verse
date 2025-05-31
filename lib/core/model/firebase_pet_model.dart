// lib/core/model/firebase_pet_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/enums/enums.dart';

class FirebasePetModel {
  final String id;
  final String name;
  final String type; // PetType enum convertido para string
  final String breed;
  final String age;
  final String photo; // emoji ou URL da imagem
  final List<String> traits; // NEW: características do pet
  final String? description; // NEW: descrição detalhada
  final int happiness;
  final int health;
  final int energy;
  final int hygiene; // NEW: higiene do pet
  final List<String> ownerIds; // UPDATE: suporte a múltiplos donos
  final String? primaryOwnerId; // UPDATE: dono principal
  final DateTime createdAt;
  final DateTime? updatedAt; // NEW: última atualização
  final bool isAvailable; // UPDATE: disponível para adoção
  final String? adoptionRequestId; // NEW: ID do pedido de adoção colaborativa
  final Map<String, dynamic>? metadata; // NEW: dados extras flexíveis

  const FirebasePetModel({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.age,
    required this.photo,
    this.traits = const [],
    this.description,
    this.happiness = 50,
    this.health = 100,
    this.energy = 75,
    this.hygiene = 80, // NEW
    this.ownerIds = const [],
    this.primaryOwnerId,
    required this.createdAt,
    this.updatedAt, // NEW
    this.isAvailable = true,
    this.adoptionRequestId, // NEW
    this.metadata, // NEW
  });

  // NEW: Factory para dados mocados
  factory FirebasePetModel.fromMockPet(Map<String, dynamic> mockData) {
    return FirebasePetModel(
      id: mockData['id'] ?? '',
      name: mockData['name'] ?? '',
      type: mockData['type'] ?? 'cat',
      breed: mockData['breed'] ?? 'Mixed',
      age: mockData['age'] ?? '1 year',
      photo: mockData['photo'] ?? '🐱',
      traits: List<String>.from(mockData['traits'] ?? []),
      description: mockData['description'],
      happiness: mockData['happiness'] ?? 50,
      health: mockData['health'] ?? 100,
      energy: mockData['energy'] ?? 75,
      hygiene: mockData['hygiene'] ?? 80,
      createdAt: DateTime.now(),
      isAvailable: mockData['isAvailable'] ?? true,
    );
  }

  // UPDATE: Factory melhorado do Firestore
  factory FirebasePetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirebasePetModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'cat',
      breed: data['breed'] ?? '',
      age: data['age'] ?? '',
      photo: data['photo'] ?? '🐱',
      traits: List<String>.from(data['traits'] ?? []), // NEW
      description: data['description'], // NEW
      happiness: data['happiness'] ?? 50,
      health: data['health'] ?? 100,
      energy: data['energy'] ?? 75,
      hygiene: data['hygiene'] ?? 80, // NEW
      ownerIds: List<String>.from(data['ownerIds'] ?? []),
      primaryOwnerId: data['primaryOwnerId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null, // NEW
      isAvailable: data['isAvailable'] ?? true,
      adoptionRequestId: data['adoptionRequestId'], // NEW
      metadata: data['metadata'], // NEW
    );
  }

  // UPDATE: Firestore serialization melhorada
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'breed': breed,
      'age': age,
      'photo': photo,
      'traits': traits, // NEW
      'description': description, // NEW
      'happiness': happiness,
      'health': health,
      'energy': energy,
      'hygiene': hygiene, // NEW
      'ownerIds': ownerIds,
      'primaryOwnerId': primaryOwnerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(), // NEW
      'isAvailable': isAvailable,
      'adoptionRequestId': adoptionRequestId, // NEW
      'metadata': metadata, // NEW
    };
  }

  // NEW: Copy with para atualizações
  FirebasePetModel copyWith({
    String? id,
    String? name,
    String? type,
    String? breed,
    String? age,
    String? photo,
    List<String>? traits,
    String? description,
    int? happiness,
    int? health,
    int? energy,
    int? hygiene,
    List<String>? ownerIds,
    String? primaryOwnerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAvailable,
    String? adoptionRequestId,
    Map<String, dynamic>? metadata,
  }) {
    return FirebasePetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      photo: photo ?? this.photo,
      traits: traits ?? this.traits,
      description: description ?? this.description,
      happiness: happiness ?? this.happiness,
      health: health ?? this.health,
      energy: energy ?? this.energy,
      hygiene: hygiene ?? this.hygiene,
      ownerIds: ownerIds ?? this.ownerIds,
      primaryOwnerId: primaryOwnerId ?? this.primaryOwnerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isAvailable: isAvailable ?? this.isAvailable,
      adoptionRequestId: adoptionRequestId ?? this.adoptionRequestId,
      metadata: metadata ?? this.metadata,
    );
  }

  // NEW: Conversão para PetModel (compatibilidade)
  Map<String, dynamic> toMockPet() {
    return {
      'name': name,
      'type': type,
      'age': age,
      'photo': photo,
      'traits': traits,
      'description': description,
    };
  }
}

// NEW: Modelo para pedidos de adoção colaborativa expandido
class CollaborativeAdoptionRequest {
  final String id;
  final String requesterId;
  final String requesterDisplayName;
  final String requesterCodename; // NEW: nome anônimo
  final int requesterColorTheme; // NEW: cor do tema
  final int requesterLevel; // NEW: nível do usuário
  final List<String> selectedPetIds;
  final String? acceptedPetId; // Pet escolhido pelo co-parent
  final String? coParentId;
  final String? coParentDisplayName;
  final String? coParentCodename; // NEW: nome anônimo do co-parent
  final AdoptionRequestStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String codedMessage; // NEW: mensagem codificada
  final List<String> personalityTags; // NEW: tags de personalidade
  final int views; // NEW: visualizações
  final int interested; // NEW: interessados
  final String? shareLink;
  final String region; // NEW: região do usuário

  const CollaborativeAdoptionRequest({
    required this.id,
    required this.requesterId,
    required this.requesterDisplayName,
    required this.requesterCodename,
    required this.requesterColorTheme,
    required this.requesterLevel,
    required this.selectedPetIds,
    this.acceptedPetId,
    this.coParentId,
    this.coParentDisplayName,
    this.coParentCodename,
    this.status = AdoptionRequestStatus.pending,
    required this.createdAt,
    required this.expiresAt,
    required this.codedMessage,
    this.personalityTags = const [],
    this.views = 0,
    this.interested = 0,
    this.shareLink,
    this.region = 'Região não informada',
  });

  // NEW: Propriedades calculadas
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == AdoptionRequestStatus.pending && !isExpired;
  double get daysRemaining =>
      expiresAt.difference(DateTime.now()).inDays.toDouble() +
      (expiresAt.difference(DateTime.now()).inHours % 24) / 24.0;
  bool get isUrgent => daysRemaining < 1.0;
  bool get isHot => views > 50 || interested > 10;
  bool get isNew => DateTime.now().difference(createdAt).inHours < 24;

  // NEW: Factory do Firestore
  factory CollaborativeAdoptionRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollaborativeAdoptionRequest(
      id: doc.id,
      requesterId: data['requesterId'] ?? '',
      requesterDisplayName: data['requesterDisplayName'] ?? '',
      requesterCodename: data['requesterCodename'] ?? 'Guardian Anônimo',
      requesterColorTheme: data['requesterColorTheme'] ?? 0xFF3B82F6,
      requesterLevel: data['requesterLevel'] ?? 1,
      selectedPetIds: List<String>.from(data['selectedPetIds'] ?? []),
      acceptedPetId: data['acceptedPetId'],
      coParentId: data['coParentId'],
      coParentDisplayName: data['coParentDisplayName'],
      coParentCodename: data['coParentCodename'],
      status: AdoptionRequestStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => AdoptionRequestStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      codedMessage: data['codedMessage'] ?? 'Mensagem não informada',
      personalityTags: List<String>.from(data['personalityTags'] ?? []),
      views: data['views'] ?? 0,
      interested: data['interested'] ?? 0,
      shareLink: data['shareLink'],
      region: data['region'] ?? 'Região não informada',
    );
  }

  // NEW: Serialização para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'requesterId': requesterId,
      'requesterDisplayName': requesterDisplayName,
      'requesterCodename': requesterCodename,
      'requesterColorTheme': requesterColorTheme,
      'requesterLevel': requesterLevel,
      'selectedPetIds': selectedPetIds,
      'acceptedPetId': acceptedPetId,
      'coParentId': coParentId,
      'coParentDisplayName': coParentDisplayName,
      'coParentCodename': coParentCodename,
      'status': status.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'codedMessage': codedMessage,
      'personalityTags': personalityTags,
      'views': views,
      'interested': interested,
      'shareLink': shareLink,
      'region': region,
    };
  }

  // NEW: Copy with
  CollaborativeAdoptionRequest copyWith({
    String? id,
    String? requesterId,
    String? requesterDisplayName,
    String? requesterCodename,
    int? requesterColorTheme,
    int? requesterLevel,
    List<String>? selectedPetIds,
    String? acceptedPetId,
    String? coParentId,
    String? coParentDisplayName,
    String? coParentCodename,
    AdoptionRequestStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? codedMessage,
    List<String>? personalityTags,
    int? views,
    int? interested,
    String? shareLink,
    String? region,
  }) {
    return CollaborativeAdoptionRequest(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterDisplayName: requesterDisplayName ?? this.requesterDisplayName,
      requesterCodename: requesterCodename ?? this.requesterCodename,
      requesterColorTheme: requesterColorTheme ?? this.requesterColorTheme,
      requesterLevel: requesterLevel ?? this.requesterLevel,
      selectedPetIds: selectedPetIds ?? this.selectedPetIds,
      acceptedPetId: acceptedPetId ?? this.acceptedPetId,
      coParentId: coParentId ?? this.coParentId,
      coParentDisplayName: coParentDisplayName ?? this.coParentDisplayName,
      coParentCodename: coParentCodename ?? this.coParentCodename,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      codedMessage: codedMessage ?? this.codedMessage,
      personalityTags: personalityTags ?? this.personalityTags,
      views: views ?? this.views,
      interested: interested ?? this.interested,
      shareLink: shareLink ?? this.shareLink,
      region: region ?? this.region,
    );
  }
}
