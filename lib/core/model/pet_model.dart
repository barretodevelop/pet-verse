import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String id;
  final String name;
  final String type; // dog, cat, etc
  final String breed;
  final String imageUrl;
  final String description;
  final int happiness;
  final int health;
  final int energy;
  final List<String> ownerIds;
  final String primaryOwnerId;
  final DateTime createdAt;
  final bool isAvailable;

  const PetModel({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.imageUrl,
    required this.description,
    this.happiness = 50,
    this.health = 100,
    this.energy = 75,
    this.ownerIds = const [],
    required this.primaryOwnerId,
    required this.createdAt,
    this.isAvailable = true,
  });

  factory PetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PetModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      breed: data['breed'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      happiness: data['happiness'] ?? 50,
      health: data['health'] ?? 100,
      energy: data['energy'] ?? 75,
      ownerIds: List<String>.from(data['ownerIds'] ?? []),
      primaryOwnerId: data['primaryOwnerId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'breed': breed,
      'imageUrl': imageUrl,
      'description': description,
      'happiness': happiness,
      'health': health,
      'energy': energy,
      'ownerIds': ownerIds,
      'primaryOwnerId': primaryOwnerId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAvailable': isAvailable,
    };
  }
}
