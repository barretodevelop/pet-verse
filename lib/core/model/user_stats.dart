// Classe para estatísticas do usuário
import 'package:cloud_firestore/cloud_firestore.dart';

class UserStats {
  final int totalPetsCared;
  final int totalCoinsEarned;
  final int totalXPEarned;
  final int totalMissionsCompleted;
  final int totalAchievementsUnlocked;
  final int totalTimeSpent;
  final int loginStreak;
  final DateTime? lastLoginDate;

  const UserStats({
    this.totalPetsCared = 0,
    this.totalCoinsEarned = 0,
    this.totalXPEarned = 0,
    this.totalMissionsCompleted = 0,
    this.totalAchievementsUnlocked = 0,
    this.totalTimeSpent = 0,
    this.loginStreak = 0,
    this.lastLoginDate,
  });

  factory UserStats.fromMap(Map<String, dynamic> data) {
    return UserStats(
        totalPetsCared: data['totalPetsCared'] ?? 0,
        totalCoinsEarned: data['totalCoinsEarned'] ?? 0,
        totalXPEarned: data['totalXPEarned'] ?? 0,
        totalMissionsCompleted: data['totalMissionsCompleted'] ?? 0,
        totalAchievementsUnlocked: data['totalAchievementsUnlocked'] ?? 0,
        totalTimeSpent: data['totalTimeSpent'] ?? 0,
        loginStreak: data['loginStreak'] ?? 0
        // lastLoginDate: UserModel._parseTimestamp(data['lastLoginDate']),
        );
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
      'lastLoginDate':
          lastLoginDate != null ? Timestamp.fromDate(lastLoginDate!) : null,
    };
  }

  UserStats copyWith({
    int? totalPetsCared,
    int? totalCoinsEarned,
    int? totalXPEarned,
    int? totalMissionsCompleted,
    int? totalAchievementsUnlocked,
    int? totalTimeSpent,
    int? loginStreak,
    DateTime? lastLoginDate,
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
    );
  }
}
