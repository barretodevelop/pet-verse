// Extensões para facilitar conversões entre UserModel e estruturas da UI
import 'package:petverse/core/model/user_model.dart';
import 'package:petverse/core/providers/profile_provider.dart';

extension UserModelDashboard on UserModel {
  Map<String, dynamic> toDashboardData() {
    return {
      'codename': displayName ?? 'Guardian Anônimo',
      'level': level,
      'xp': xp,
      'xpToNext': level * 100,
      'colorTheme': 0xFF3B82F6,
      'successRate': _calculateSuccessRate(),
      'totalAdoptions': stats.totalPetsCared,
      'currentStreak': stats.loginStreak,
      'badges': _getBadges(),
      'coins': coins,
      'gems': gems,
      'totalXP': totalXP,
    };
  }

  int _calculateSuccessRate() {
    if (stats.totalMissionsCompleted == 0) return 100;
    return ((stats.totalMissionsCompleted /
                (stats.totalMissionsCompleted + 1)) *
            100)
        .round();
  }

  List<String> _getBadges() {
    final badges = <String>[];

    if (level >= 10) badges.add('experienced_guardian');
    if (level >= 20) badges.add('master_guardian');
    if (stats.totalPetsCared >= 5) badges.add('pet_lover');
    if (stats.totalPetsCared >= 15) badges.add('pet_master');
    if (stats.loginStreak >= 7) badges.add('dedicated');
    if (stats.loginStreak >= 30) badges.add('legendary_dedication');

    return badges;
  }
}

extension UserModelProfile on UserModel {
  UserProfile toProfileData() {
    return UserProfile(
      codename: displayName ?? 'Guardian Anônimo',
      level: level,
      currentXP: xp,
      xpToNextLevel: level * 100,
      colorTheme: 0xFF3B82F6,
      totalPetsAdopted: stats.totalPetsCared,
      activePets: petIds.length,
      successRate: _calculateSuccessRate().toDouble(),
      currentStreak: stats.loginStreak,
      longestStreak: stats.loginStreak + 5, // Placeholder
      daysActive: DateTime.now().difference(createdAt).inDays,
      totalXPEarned: totalXP,
      achievements: [], // Será populado pelo ProfileNotifier
      adoptionHistory: [], // Será populado pelo ProfileNotifier
      rankingPosition: _calculateRankingPosition(),
      joinedDate: createdAt,
    );
  }

  int _calculateRankingPosition() {
    final basePosition = (totalXP / 1000).floor() + 1;
    return basePosition.clamp(1, 100);
  }
}
