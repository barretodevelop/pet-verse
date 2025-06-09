// File: lib/data/models/collaboration/user_collaboration_data_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/domain/entities/collaboration/reveal_request_entity.dart';
import 'package:petverse/domain/entities/collaboration/user_collaboration_data_entity.dart';

class UserCollaborationDataModel {
  final String userId;
  final int experienceLevel;
  final int maxCollaborativeSlots;
  final List<String> activePetIds;
  final List<String> completedCollaborations;
  final int totalSuccessfulReveals;
  final double cooperationRating;
  final Map<CollaborativeActionType, int> preferredActions;
  final DateTime lastActiveAt;
  final Map<String, dynamic> badges;
  final CollaborationStats stats;

  UserCollaborationDataModel({
    required this.userId,
    required this.experienceLevel,
    required this.maxCollaborativeSlots,
    required this.activePetIds,
    required this.completedCollaborations,
    required this.totalSuccessfulReveals,
    required this.cooperationRating,
    required this.preferredActions,
    required this.lastActiveAt,
    required this.badges,
    required this.stats,
  });

  factory UserCollaborationDataModel.fromMap(Map<String, dynamic> map) {
    // Parse preferred actions
    final preferredActionsMap = <CollaborativeActionType, int>{};
    final actionsData = map['preferredActions'] as Map<String, dynamic>? ?? {};

    actionsData.forEach((key, value) {
      try {
        final actionType = CollaborativeActionType.values.firstWhere(
          (type) => type.name == key,
        );
        preferredActionsMap[actionType] = value as int? ?? 0;
      } catch (e) {
        // Ignorar tipos de ação inválidos
      }
    });

    // Parse stats
    final statsData = map['stats'] as Map<String, dynamic>? ?? {};
    final stats = CollaborationStats(
      totalCollaborations: statsData['totalCollaborations'] ?? 0,
      successfulReveals: statsData['successfulReveals'] ?? 0,
      averagePetLevel: (statsData['averagePetLevel'] as num?)?.toDouble() ?? 0.0,
      totalActionsPerformed: statsData['totalActionsPerformed'] ?? 0,
      partnerSatisfactionRating:
          (statsData['partnerSatisfactionRating'] as num?)?.toDouble() ?? 5.0,
      preferredPetTypes: List<String>.from(statsData['preferredPetTypes'] ?? []),
      totalXpGained: statsData['totalXpGained'] ?? 0,
      actionCounts: Map<String, int>.from(statsData['actionCounts'] ?? {}),
    );

    return UserCollaborationDataModel(
      userId: map['userId'] ?? '',
      experienceLevel: map['experienceLevel'] ?? 1,
      maxCollaborativeSlots: map['maxCollaborativeSlots'] ?? 3,
      activePetIds: List<String>.from(map['activePetIds'] ?? []),
      completedCollaborations: List<String>.from(map['completedCollaborations'] ?? []),
      totalSuccessfulReveals: map['totalSuccessfulReveals'] ?? 0,
      cooperationRating: (map['cooperationRating'] as num?)?.toDouble() ?? 5.0,
      preferredActions: preferredActionsMap,
      lastActiveAt: _parseTimestamp(map['lastActiveAt']),
      badges: Map<String, dynamic>.from(map['badges'] ?? {}),
      stats: stats,
    );
  }

  Map<String, dynamic> toMap() {
    // Convert preferred actions
    final preferredActionsMap = <String, int>{};
    preferredActions.forEach((actionType, count) {
      preferredActionsMap[actionType.name] = count;
    });

    return {
      'experienceLevel': experienceLevel,
      'maxCollaborativeSlots': maxCollaborativeSlots,
      'activePetIds': activePetIds,
      'completedCollaborations': completedCollaborations,
      'totalSuccessfulReveals': totalSuccessfulReveals,
      'cooperationRating': cooperationRating,
      'preferredActions': preferredActionsMap,
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'badges': badges,
      'stats': {
        'totalCollaborations': stats.totalCollaborations,
        'successfulReveals': stats.successfulReveals,
        'averagePetLevel': stats.averagePetLevel,
        'totalActionsPerformed': stats.totalActionsPerformed,
        'partnerSatisfactionRating': stats.partnerSatisfactionRating,
        'preferredPetTypes': stats.preferredPetTypes,
        'totalXpGained': stats.totalXpGained,
        'actionCounts': stats.actionCounts,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  UserCollaborationDataEntity toEntity() {
    return UserCollaborationDataEntity(
      userId: userId,
      experienceLevel: experienceLevel,
      maxCollaborativeSlots: maxCollaborativeSlots,
      activePetIds: activePetIds,
      completedCollaborations: completedCollaborations,
      totalSuccessfulReveals: totalSuccessfulReveals,
      cooperationRating: cooperationRating,
      preferredActions: preferredActions,
      lastActiveAt: lastActiveAt,
      badges: badges,
      stats: stats,
    );
  }

  factory UserCollaborationDataModel.fromEntity(UserCollaborationDataEntity entity) {
    return UserCollaborationDataModel(
      userId: entity.userId,
      experienceLevel: entity.experienceLevel,
      maxCollaborativeSlots: entity.maxCollaborativeSlots,
      activePetIds: entity.activePetIds,
      completedCollaborations: entity.completedCollaborations,
      totalSuccessfulReveals: entity.totalSuccessfulReveals,
      cooperationRating: entity.cooperationRating,
      preferredActions: entity.preferredActions,
      lastActiveAt: entity.lastActiveAt,
      badges: entity.badges,
      stats: entity.stats,
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }
}
