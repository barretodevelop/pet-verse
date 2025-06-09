// File: lib/domain/entities/collaboration/collaborative_action_entity.dart

import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';

class CollaborativeActionEntity {
  final String id;
  final String userId;
  final String petId;
  final CollaborativeActionType actionType;
  final DateTime timestamp;
  final String anonymousName;
  final Map<String, dynamic> effects;
  final int xpGained;
  final Map<String, dynamic> metadata;

  const CollaborativeActionEntity({
    required this.id,
    required this.userId,
    required this.petId,
    required this.actionType,
    required this.timestamp,
    required this.anonymousName,
    required this.effects,
    required this.xpGained,
    this.metadata = const {},
  });

  /// Tempo desde a ação (em minutos)
  int get minutesAgo {
    return DateTime.now().difference(timestamp).inMinutes;
  }

  /// Texto formatado para exibir na UI
  String get displayText {
    final timeText = minutesAgo < 1
        ? 'agora'
        : minutesAgo < 60
            ? '${minutesAgo}min'
            : '${(minutesAgo / 60).floor()}h';

    return '$anonymousName ${actionType.displayName.toLowerCase()} ($timeText)';
  }

  CollaborativeActionEntity copyWith({
    String? id,
    String? userId,
    String? petId,
    CollaborativeActionType? actionType,
    DateTime? timestamp,
    String? anonymousName,
    Map<String, dynamic>? effects,
    int? xpGained,
    Map<String, dynamic>? metadata,
  }) {
    return CollaborativeActionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      petId: petId ?? this.petId,
      actionType: actionType ?? this.actionType,
      timestamp: timestamp ?? this.timestamp,
      anonymousName: anonymousName ?? this.anonymousName,
      effects: effects ?? this.effects,
      xpGained: xpGained ?? this.xpGained,
      metadata: metadata ?? this.metadata,
    );
  }
}
