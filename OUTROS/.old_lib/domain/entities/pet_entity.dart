// File: lib/domain/entities/pet_entity.dart

import 'package:equatable/equatable.dart';

/// Pet entity representing the core pet data structure
class PetEntity extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String type;
  final String description;
  final bool isAdopted;
  final int hunger;
  final int happiness;
  final int energy;
  final int level;
  final int xp;
  final int health;
  final int xpToNextLevel;
  final DateTime lastFed;
  final DateTime lastPlayed;
  final DateTime lastSlept;
  final int evolutionStage;
  final List<String> skills;
  final String? generatedByUserId;

  const PetEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.description,
    this.isAdopted = false,
    this.hunger = 100,
    this.happiness = 100,
    this.energy = 100,
    this.level = 1,
    this.xp = 0,
    this.xpToNextLevel = 100,
    this.health = 100,
    required this.lastFed,
    required this.lastPlayed,
    required this.lastSlept,
    this.evolutionStage = 1,
    this.skills = const [],
    this.generatedByUserId,
  });

  PetEntity copyWith({
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
    return PetEntity(
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

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        type,
        description,
        isAdopted,
        hunger,
        happiness,
        energy,
        health,
        level,
        xp,
        xpToNextLevel,
        lastFed,
        lastPlayed,
        lastSlept,
        evolutionStage,
        skills,
        generatedByUserId,
      ];

  Null get avatar => null;

  Null get breed => null;
}
