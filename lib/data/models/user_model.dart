// File: lib/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

/// User model for data layer, handles Firestore serialization
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.displayName,
    super.photoURL,
    required super.createdAt,
    required super.lastLoginAt,
    super.totalXp,
    super.level,
    super.coins,
    super.gems,
    super.achievements,
    super.lastDailyReward,
    super.loginStreak,
    super.preferences,
  });

  /// Create UserModel from UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoURL: entity.photoURL,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      totalXp: entity.totalXp,
      level: entity.level,
      coins: entity.coins,
      gems: entity.gems,
      achievements: entity.achievements,
      lastDailyReward: entity.lastDailyReward,
      loginStreak: entity.loginStreak,
      preferences: entity.preferences,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'totalXp': totalXp,
      'level': level,
      'coins': coins,
      'gems': gems,
      'achievements': achievements,
      'lastDailyReward': lastDailyReward != null 
          ? Timestamp.fromDate(lastDailyReward!) 
          : null,
      'loginStreak': loginStreak,
      'preferences': preferences,
    };
  }

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      totalXp: data['totalXp'] ?? 0,
      level: data['level'] ?? 1,
      coins: data['coins'] ?? 1000,
      gems: data['gems'] ?? 50,
      achievements: List<String>.from(data['achievements'] ?? []),
      lastDailyReward: (data['lastDailyReward'] as Timestamp?)?.toDate(),
      loginStreak: data['loginStreak'] ?? 0,
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
    );
  }

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),
      totalXp: json['totalXp'] ?? 0,
      level: json['level'] ?? 1,
      coins: json['coins'] ?? 1000,
      gems: json['gems'] ?? 50,
      achievements: List<String>.from(json['achievements'] ?? []),
      lastDailyReward: json['lastDailyReward'] != null
          ? DateTime.parse(json['lastDailyReward'])
          : null,
      loginStreak: json['loginStreak'] ?? 0,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'totalXp': totalXp,
      'level': level,
      'coins': coins,
      'gems': gems,
      'achievements': achievements,
      'lastDailyReward': lastDailyReward?.toIso8601String(),
      'loginStreak': loginStreak,
      'preferences': preferences,
    };
  }

  @override
  UserModel copyWith({
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
    return UserModel(
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
      lastDailyReward: clearLastDailyReward 
          ? null 
          : lastDailyReward ?? this.lastDailyReward,
      loginStreak: loginStreak ?? this.loginStreak,
      preferences: preferences ?? this.preferences,
    );
  }
}