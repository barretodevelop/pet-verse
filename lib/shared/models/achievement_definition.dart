import 'package:flutter/material.dart';
import 'package:petverse/shared/enums/enums.dart';

@immutable
class AchievementDefinition {
  final String id;
  final String title;
  final String description;
  final AchievementGoalType goalType;
  final int targetValue;
  final String?
      detail; // Para informações extras, como petId específico ou itemId
  final int rewardCoins;
  final int rewardGems;
  final int rewardUxp;
  final String iconEmoji;

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.goalType,
    required this.targetValue,
    this.detail,
    this.rewardCoins = 0,
    this.rewardGems = 0,
    this.rewardUxp = 0,
    this.iconEmoji = '🏆',
  });
}
