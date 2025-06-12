// File: lib/domain/entities/achievement_entity.dart

import 'package:equatable/equatable.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';

/// Achievement entity representing user achievements
class AchievementEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final AchievementType type;
  final int targetValue;
  final int currentValue;
  final bool isCompleted;
  final DateTime? completedAt;
  final int rewardCoins;
  final int rewardGems;
  final int rewardXp;

  const AchievementEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    this.isCompleted = false,
    this.completedAt,
    this.rewardCoins = 0,
    this.rewardGems = 0,
    this.rewardXp = 0,
  });

  AchievementEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? iconUrl,
    AchievementType? type,
    int? targetValue,
    int? currentValue,
    bool? isCompleted,
    DateTime? completedAt,
    int? rewardCoins,
    int? rewardGems,
    int? rewardXp,
  }) {
    return AchievementEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      rewardCoins: rewardCoins ?? this.rewardCoins,
      rewardGems: rewardGems ?? this.rewardGems,
      rewardXp: rewardXp ?? this.rewardXp,
    );
  }

  double get progress => targetValue == 0 ? 0 : currentValue / targetValue;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        iconUrl,
        type,
        targetValue,
        currentValue,
        isCompleted,
        completedAt,
        rewardCoins,
        rewardGems,
        rewardXp,
      ];
}
