// lib/shared/models/quest_progress.dart
import 'package:flutter/material.dart';

@immutable
class QuestProgress {
  final String questId;
  final int currentCount;
  final bool isClaimed;

  const QuestProgress(
      {required this.questId, this.currentCount = 0, this.isClaimed = false});

  QuestProgress copyWith({int? currentCount, bool? isClaimed}) => QuestProgress(
      questId: questId,
      currentCount: currentCount ?? this.currentCount,
      isClaimed: isClaimed ?? this.isClaimed);

  Map<String, dynamic> toJson() => {
        'questId': questId,
        'currentCount': currentCount,
        'isClaimed': isClaimed
      };
  factory QuestProgress.fromJson(Map<String, dynamic> json) => QuestProgress(
      questId: json['questId'],
      currentCount: json['currentCount'] ?? 0,
      isClaimed: json['isClaimed'] ?? false);
}
