// File: lib/data/models/collaboration/collaborative_pet_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_action_entity.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';

class CollaborativePetModel {
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
  final int xpToNextLevel;
  final DateTime lastFed;
  final DateTime lastPlayed;
  final DateTime lastSlept;
  final int evolutionStage;
  final List<String> skills;
  final String? generatedByUserId;
  final String collaborationId;
  final List<String> caretakerIds;
  final CollaborationStatus status;
  final CollaborationDifficulty difficulty;
  final int revealLevel;
  final bool revealRequested;
  final List<String> revealAccepted;
  final DateTime matchedAt;
  final Map<String, int> contributionStats;
  final List<CollaborativeActionEntity> recentActions;
  final DateTime? revealRequestedAt;
  final String? createdByUserId;
  final Map<String, dynamic> collaborationRewards;

  CollaborativePetModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.description,
    required this.isAdopted,
    required this.hunger,
    required this.happiness,
    required this.energy,
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    required this.lastFed,
    required this.lastPlayed,
    required this.lastSlept,
    required this.evolutionStage,
    required this.skills,
    this.generatedByUserId,
    required this.collaborationId,
    required this.caretakerIds,
    required this.status,
    required this.difficulty,
    required this.revealLevel,
    required this.revealRequested,
    required this.revealAccepted,
    required this.matchedAt,
    required this.contributionStats,
    required this.recentActions,
    this.revealRequestedAt,
    this.createdByUserId,
    required this.collaborationRewards,
  });

  factory CollaborativePetModel.fromMap(Map<String, dynamic> map) {
    return CollaborativePetModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      isAdopted: map['isAdopted'] ?? false,
      hunger: map['hunger'] ?? 100,
      happiness: map['happiness'] ?? 100,
      energy: map['energy'] ?? 100,
      level: map['level'] ?? 1,
      xp: map['xp'] ?? 0,
      xpToNextLevel: map['xpToNextLevel'] ?? 100,
      lastFed: _parseTimestamp(map['lastFed']),
      lastPlayed: _parseTimestamp(map['lastPlayed']),
      lastSlept: _parseTimestamp(map['lastSlept']),
      evolutionStage: map['evolutionStage'] ?? 1,
      skills: List<String>.from(map['skills'] ?? []),
      generatedByUserId: map['generatedByUserId'],
      collaborationId: map['collaborationId'] ?? '',
      caretakerIds: List<String>.from(map['caretakerIds'] ?? []),
      status: CollaborationStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => CollaborationStatus.waitingForPartner,
      ),
      difficulty: CollaborationDifficulty.values.firstWhere(
        (difficulty) => difficulty.name == map['difficulty'],
        orElse: () => CollaborationDifficulty.beginner,
      ),
      revealLevel: map['revealLevel'] ?? 10,
      revealRequested: map['revealRequested'] ?? false,
      revealAccepted: List<String>.from(map['revealAccepted'] ?? []),
      matchedAt: _parseTimestamp(map['matchedAt']),
      contributionStats: Map<String, int>.from(map['contributionStats'] ?? {}),
      recentActions: [], // Será carregado separadamente
      revealRequestedAt:
          map['revealRequestedAt'] != null ? _parseTimestamp(map['revealRequestedAt']) : null,
      createdByUserId: map['createdByUserId'],
      collaborationRewards: Map<String, dynamic>.from(map['collaborationRewards'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
      'lastFed': Timestamp.fromDate(lastFed),
      'lastPlayed': Timestamp.fromDate(lastPlayed),
      'lastSlept': Timestamp.fromDate(lastSlept),
      'evolutionStage': evolutionStage,
      'skills': skills,
      'generatedByUserId': generatedByUserId,
      'collaborationId': collaborationId,
      'caretakerIds': caretakerIds,
      'status': status.name,
      'difficulty': difficulty.name,
      'revealLevel': revealLevel,
      'revealRequested': revealRequested,
      'revealAccepted': revealAccepted,
      'matchedAt': Timestamp.fromDate(matchedAt),
      'contributionStats': contributionStats,
      'revealRequestedAt':
          revealRequestedAt != null ? Timestamp.fromDate(revealRequestedAt!) : null,
      'createdByUserId': createdByUserId,
      'collaborationRewards': collaborationRewards,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CollaborativePetEntity toEntity() {
    return CollaborativePetEntity(
      id: id,
      name: name,
      imageUrl: imageUrl,
      type: type,
      description: description,
      isAdopted: isAdopted,
      hunger: hunger,
      happiness: happiness,
      energy: energy,
      level: level,
      xp: xp,
      xpToNextLevel: xpToNextLevel,
      lastFed: lastFed,
      lastPlayed: lastPlayed,
      lastSlept: lastSlept,
      evolutionStage: evolutionStage,
      skills: skills,
      generatedByUserId: generatedByUserId,
      collaborationId: collaborationId,
      caretakerIds: caretakerIds,
      status: status,
      difficulty: difficulty,
      revealLevel: revealLevel,
      revealRequested: revealRequested,
      revealAccepted: revealAccepted,
      matchedAt: matchedAt,
      contributionStats: contributionStats,
      recentActions: recentActions,
      revealRequestedAt: revealRequestedAt,
      createdByUserId: createdByUserId,
      collaborationRewards: collaborationRewards,
    );
  }

  factory CollaborativePetModel.fromEntity(CollaborativePetEntity entity) {
    return CollaborativePetModel(
      id: entity.id,
      name: entity.name,
      imageUrl: entity.imageUrl,
      type: entity.type,
      description: entity.description,
      isAdopted: entity.isAdopted,
      hunger: entity.hunger,
      happiness: entity.happiness,
      energy: entity.energy,
      level: entity.level,
      xp: entity.xp,
      xpToNextLevel: entity.xpToNextLevel,
      lastFed: entity.lastFed,
      lastPlayed: entity.lastPlayed,
      lastSlept: entity.lastSlept,
      evolutionStage: entity.evolutionStage,
      skills: entity.skills,
      generatedByUserId: entity.generatedByUserId,
      collaborationId: entity.collaborationId,
      caretakerIds: entity.caretakerIds,
      status: entity.status,
      difficulty: entity.difficulty,
      revealLevel: entity.revealLevel,
      revealRequested: entity.revealRequested,
      revealAccepted: entity.revealAccepted,
      matchedAt: entity.matchedAt,
      contributionStats: entity.contributionStats,
      recentActions: [], // entity.recentActions,
      revealRequestedAt: entity.revealRequestedAt,
      createdByUserId: entity.createdByUserId,
      collaborationRewards: entity.collaborationRewards,
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }
}
