// lib/shared/models/achievement_progress.dart (NOVO)
import 'package:flutter/material.dart';

@immutable
class AchievementProgress {
  final String achievementId;
  final int currentProgress;
  final bool isCompleted;
  final bool isClaimed;

  const AchievementProgress({
    required this.achievementId,
    this.currentProgress = 0,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  AchievementProgress copyWith(
      {int? currentProgress, bool? isCompleted, bool? isClaimed}) {
    return AchievementProgress(
      achievementId: achievementId,
      currentProgress: currentProgress ?? this.currentProgress,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }

  Map<String, dynamic> toJson() => {
        'achievementId': achievementId,
        'currentProgress': currentProgress,
        'isCompleted': isCompleted,
        'isClaimed': isClaimed,
      };

  factory AchievementProgress.fromJson(Map<String, dynamic> json) =>
      AchievementProgress(
        achievementId: json['achievementId'] ??
            '', // Adicionado fallback para evitar erro se 'achievementId' for null
        currentProgress: json['currentProgress'] ?? 0,
        isCompleted: json['isCompleted'] ?? false,
        isClaimed: json['isClaimed'] ?? false,
      );
}
