// File: lib/data/models/pet_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/domain/entities/pet_entity.dart';

/// Pet model for data layer, handles Firestore serialization
class PetModel extends PetEntity {
  const PetModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.type,
    required super.description,
    super.isAdopted,
    super.hunger,
    super.happiness,
    super.energy,
    super.health,
    super.level,
    super.xp,
    super.xpToNextLevel,
    required super.lastFed,
    required super.lastPlayed,
    required super.lastSlept,
    super.evolutionStage,
    super.skills,
    super.generatedByUserId,
  });

  /// Create PetModel from PetEntity
  factory PetModel.fromEntity(PetEntity entity) {
    return PetModel(
      id: entity.id,
      name: entity.name,
      imageUrl: entity.imageUrl,
      type: entity.type,
      description: entity.description,
      isAdopted: entity.isAdopted,
      hunger: entity.hunger,
      happiness: entity.happiness,
      energy: entity.energy,
      health: entity.health,
      level: entity.level,
      xp: entity.xp,
      xpToNextLevel: entity.xpToNextLevel,
      lastFed: entity.lastFed,
      lastPlayed: entity.lastPlayed,
      lastSlept: entity.lastSlept,
      evolutionStage: entity.evolutionStage,
      skills: entity.skills,
      generatedByUserId: entity.generatedByUserId,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'type': type,
      'description': description,
      'isAdopted': isAdopted,
      'hunger': hunger,
      'happiness': happiness,
      'energy': energy,
      'health': health,
      'level': level,
      'xp': xp,
      'xpToNextLevel': xpToNextLevel,
      'lastFed': Timestamp.fromDate(lastFed),
      'lastPlayed': Timestamp.fromDate(lastPlayed),
      'lastSlept': Timestamp.fromDate(lastSlept),
      'evolutionStage': evolutionStage,
      'skills': skills,
      'generatedByUserId': generatedByUserId,
    };
  }

  /// Create PetModel from Firestore document
  factory PetModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final now = DateTime.now();

    return PetModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown Pet',
      imageUrl: data['imageUrl'] ?? '',
      type: data['type'] ?? 'Normal',
      description: data['description'] ?? 'A mysterious pet.',
      isAdopted: data['isAdopted'] ?? false,
      hunger: data['hunger'] ?? 100,
      happiness: data['happiness'] ?? 100,
      energy: data['energy'] ?? 100,
      health: data['health'] ?? 100,
      level: data['level'] ?? 1,
      xp: data['xp'] ?? 0,
      xpToNextLevel: data['xpToNextLevel'] ?? 100,
      lastFed: (data['lastFed'] as Timestamp? ?? Timestamp.fromDate(now)).toDate(),
      lastPlayed: (data['lastPlayed'] as Timestamp? ?? Timestamp.fromDate(now)).toDate(),
      lastSlept: (data['lastSlept'] as Timestamp? ?? Timestamp.fromDate(now)).toDate(),
      evolutionStage: data['evolutionStage'] ?? 1,
      skills: List<String>.from(data['skills'] ?? []),
      generatedByUserId: data['generatedByUserId'],
    );
  }

  /// Create PetModel from JSON
  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      type: json['type'],
      description: json['description'],
      isAdopted: json['isAdopted'] ?? false,
      hunger: json['hunger'] ?? 100,
      happiness: json['happiness'] ?? 100,
      energy: json['energy'] ?? 100,
      health: json['health'] ?? 100,
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      xpToNextLevel: json['xpToNextLevel'] ?? 100,
      lastFed: DateTime.parse(json['lastFed']),
      lastPlayed: DateTime.parse(json['lastPlayed']),
      lastSlept: DateTime.parse(json['lastSlept']),
      evolutionStage: json['evolutionStage'] ?? 1,
      skills: List<String>.from(json['skills'] ?? []),
      generatedByUserId: json['generatedByUserId'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'type': type,
      'description': description,
      'isAdopted': isAdopted,
      'hunger': hunger,
      'happiness': happiness,
      'energy': energy,
      'level': level,
      'xp': xp,
      'xpToNextLevel': xpToNextLevel,
      'lastFed': lastFed.toIso8601String(),
      'lastPlayed': lastPlayed.toIso8601String(),
      'lastSlept': lastSlept.toIso8601String(),
      'evolutionStage': evolutionStage,
      'skills': skills,
      'generatedByUserId': generatedByUserId,
    };
  }

  @override
  PetModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? type,
    String? description,
    bool? isAdopted,
    int? hunger,
    int? happiness,
    int? energy,
    int? level,
    int? xp,
    int? xpToNextLevel,
    int? health,
    DateTime? lastFed,
    DateTime? lastPlayed,
    DateTime? lastSlept,
    int? evolutionStage,
    List<String>? skills,
    String? generatedByUserId,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      description: description ?? this.description,
      isAdopted: isAdopted ?? this.isAdopted,
      hunger: hunger ?? this.hunger,
      happiness: happiness ?? this.happiness,
      energy: energy ?? this.energy,
      health: health ?? this.health,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      lastFed: lastFed ?? this.lastFed,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      lastSlept: lastSlept ?? this.lastSlept,
      evolutionStage: evolutionStage ?? this.evolutionStage,
      skills: skills ?? this.skills,
      generatedByUserId: generatedByUserId ?? this.generatedByUserId,
    );
  }
}
