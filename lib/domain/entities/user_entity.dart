// File: lib/domain/entities/user_entity.dart

import 'package:equatable/equatable.dart';

/// User entity representing the core user data structure
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final int totalXp;
  final int level;
  final int coins;
  final int gems;
  final List<String> achievements;
  final DateTime? lastDailyReward;
  final int loginStreak;
  final Map<String, dynamic> preferences;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastLoginAt,
    this.totalXp = 0,
    this.level = 1,
    this.coins = 1000,
    this.gems = 50,
    this.achievements = const [],
    this.lastDailyReward,
    this.loginStreak = 0,
    this.preferences = const {},
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? totalXp,
    int? level,
    int? coins,
    int? gems,
    List<String>? achievements,
    DateTime? lastDailyReward,
    bool clearLastDailyReward = false,
    int? loginStreak,
    Map<String, dynamic>? preferences,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      achievements: achievements ?? this.achievements,
      lastDailyReward: clearLastDailyReward ? null : lastDailyReward ?? this.lastDailyReward,
      loginStreak: loginStreak ?? this.loginStreak,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoURL,
        createdAt,
        lastLoginAt,
        totalXp,
        level,
        coins,
        gems,
        achievements,
        lastDailyReward,
        loginStreak,
        preferences,
      ];
}
