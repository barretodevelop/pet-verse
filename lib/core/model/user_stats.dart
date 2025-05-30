// lib/feature/auth/model/user_stats.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserStats {
  final int totalPetsCared;
  final int totalCoinsEarned;
  final int totalXPEarned;
  final int totalMissionsCompleted;
  final int totalAchievementsUnlocked;
  final int totalTimeSpent;
  final int loginStreak;
  final DateTime lastLoginDate;
  final Map<String, int> activityCounts;

  const UserStats({
    required this.totalPetsCared,
    required this.totalCoinsEarned,
    required this.totalXPEarned,
    required this.totalMissionsCompleted,
    required this.totalAchievementsUnlocked,
    required this.totalTimeSpent,
    required this.loginStreak,
    required this.lastLoginDate,
    required this.activityCounts,
  });

  factory UserStats.initial() {
    return UserStats(
      totalPetsCared: 0,
      totalCoinsEarned: 0,
      totalXPEarned: 0,
      totalMissionsCompleted: 0,
      totalAchievementsUnlocked: 0,
      totalTimeSpent: 0,
      loginStreak: 1,
      lastLoginDate: DateTime.now(),
      activityCounts: {
        'totalFed': 0,
        'totalPlayed': 0,
        'totalCleaned': 0,
        'totalShopped': 0,
        'totalCollaborated': 0,
      },
    );
  }

  factory UserStats.fromMap(Map<String, dynamic>? map) {
    map = map ?? {};
    return UserStats(
      totalPetsCared: map['totalPetsCared'] ?? 0,
      totalCoinsEarned: map['totalCoinsEarned'] ?? 0,
      totalXPEarned: map['totalXPEarned'] ?? 0,
      totalMissionsCompleted: map['totalMissionsCompleted'] ?? 0,
      totalAchievementsUnlocked: map['totalAchievementsUnlocked'] ?? 0,
      totalTimeSpent: map['totalTimeSpent'] ?? 0,
      loginStreak: map['loginStreak'] ?? 1,
      lastLoginDate:
          (map['lastLoginDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      activityCounts: Map<String, int>.from(map['activityCounts'] ?? {}),
    );
  }

  factory UserStats.fromJson(String jsonString) {
    return UserStats.fromMap(jsonDecode(jsonString));
  }

  Map<String, dynamic> toMap() {
    return {
      'totalPetsCared': totalPetsCared,
      'totalCoinsEarned': totalCoinsEarned,
      'totalXPEarned': totalXPEarned,
      'totalMissionsCompleted': totalMissionsCompleted,
      'totalAchievementsUnlocked': totalAchievementsUnlocked,
      'totalTimeSpent': totalTimeSpent,
      'loginStreak': loginStreak,
      'lastLoginDate': Timestamp.fromDate(lastLoginDate),
      'activityCounts': activityCounts,
    };
  }

  String toJson() => jsonEncode(toMap());

  UserStats copyWith({
    int? totalPetsCared,
    int? totalCoinsEarned,
    int? totalXPEarned,
    int? totalMissionsCompleted,
    int? totalAchievementsUnlocked,
    int? totalTimeSpent,
    int? loginStreak,
    DateTime? lastLoginDate,
    Map<String, int>? activityCounts,
  }) {
    return UserStats(
      totalPetsCared: totalPetsCared ?? this.totalPetsCared,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
      totalXPEarned: totalXPEarned ?? this.totalXPEarned,
      totalMissionsCompleted:
          totalMissionsCompleted ?? this.totalMissionsCompleted,
      totalAchievementsUnlocked:
          totalAchievementsUnlocked ?? this.totalAchievementsUnlocked,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      loginStreak: loginStreak ?? this.loginStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      activityCounts: activityCounts ?? this.activityCounts,
    );
  }
}
