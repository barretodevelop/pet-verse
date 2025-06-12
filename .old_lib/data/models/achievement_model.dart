// File: lib/data/models/achievement_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/core/utils/helpers.dart';
import 'package:petverse/data/repositories/achievement_entity.dart';

/// Achievement model for data layer
class AchievementModel extends AchievementEntity {
  const AchievementModel({
    required super.id,
    required super.title,
    required super.description,
    required super.iconUrl,
    required super.type,
    required super.targetValue,
    super.currentValue,
    super.isCompleted,
    super.completedAt,
    super.rewardCoins,
    super.rewardGems,
    super.rewardXp,
  });

  /// Create AchievementModel from AchievementEntity
  factory AchievementModel.fromEntity(AchievementEntity entity) {
    return AchievementModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      iconUrl: entity.iconUrl,
      type: entity.type,
      targetValue: entity.targetValue,
      currentValue: entity.currentValue,
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
      rewardCoins: entity.rewardCoins,
      rewardGems: entity.rewardGems,
      rewardXp: entity.rewardXp,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'type': Helpers.enumToString(type),
      'targetValue': targetValue,
      'currentValue': currentValue,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'rewardCoins': rewardCoins,
      'rewardGems': rewardGems,
      'rewardXp': rewardXp,
    };
  }

  /// Create AchievementModel from Firestore document
  factory AchievementModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return AchievementModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      type: Helpers.stringToEnum(AchievementType.values, data['type']) ?? AchievementType.petCare,
      targetValue: data['targetValue'] ?? 0,
      currentValue: data['currentValue'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      rewardCoins: data['rewardCoins'] ?? 0,
      rewardGems: data['rewardGems'] ?? 0,
      rewardXp: data['rewardXp'] ?? 0,
    );
  }

  @override
  AchievementModel copyWith({
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
    return AchievementModel(
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
}
