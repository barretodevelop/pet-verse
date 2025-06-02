// lib/shared/models/quest.dart
import 'package:flutter/material.dart';
import 'package:petverse/shared/enums/enums.dart';

@immutable
class Quest {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final int targetCount;
  final int rewardCoins;
  final int rewardGems;

  const Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.targetCount,
    this.rewardCoins = 0,
    this.rewardGems = 0,
    required String detail,
  });
}
