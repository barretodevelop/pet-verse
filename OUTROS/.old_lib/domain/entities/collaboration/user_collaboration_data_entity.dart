// File: lib/domain/entities/collaboration/user_collaboration_data_entity.dart

import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/domain/entities/collaboration/reveal_request_entity.dart';

class UserCollaborationDataEntity {
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

  const UserCollaborationDataEntity({
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

  /// Verifica se tem slots disponíveis
  bool get hasAvailableSlots => activePetIds.length < maxCollaborativeSlots;

  /// Número de slots disponíveis
  int get availableSlots => maxCollaborativeSlots - activePetIds.length;

  /// Nível de experiência em colaboração
  String get experienceLevelName {
    if (experienceLevel < 5) return 'Novato';
    if (experienceLevel < 15) return 'Iniciante';
    if (experienceLevel < 30) return 'Intermediário';
    if (experienceLevel < 50) return 'Avançado';
    return 'Especialista';
  }

  UserCollaborationDataEntity copyWith({
    String? userId,
    int? experienceLevel,
    int? maxCollaborativeSlots,
    List<String>? activePetIds,
    List<String>? completedCollaborations,
    int? totalSuccessfulReveals,
    double? cooperationRating,
    Map<CollaborativeActionType, int>? preferredActions,
    DateTime? lastActiveAt,
    Map<String, dynamic>? badges,
    CollaborationStats? stats,
  }) {
    return UserCollaborationDataEntity(
      userId: userId ?? this.userId,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      maxCollaborativeSlots: maxCollaborativeSlots ?? this.maxCollaborativeSlots,
      activePetIds: activePetIds ?? this.activePetIds,
      completedCollaborations: completedCollaborations ?? this.completedCollaborations,
      totalSuccessfulReveals: totalSuccessfulReveals ?? this.totalSuccessfulReveals,
      cooperationRating: cooperationRating ?? this.cooperationRating,
      preferredActions: preferredActions ?? this.preferredActions,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      badges: badges ?? this.badges,
      stats: stats ?? this.stats,
    );
  }
}
