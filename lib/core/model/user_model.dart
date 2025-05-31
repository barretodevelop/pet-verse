import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/user_settings.dart';
import 'package:petverse/core/model/user_stats.dart';

class UserModel extends Equatable {
  final String id; // Firestore document ID
  final String uid; // Firebase Auth UID
  final String email;
  final String? displayName;
  final String? photoURL;
  final String? avatarUrl; // URL do avatar personalizado
  final DateTime createdAt;
  final DateTime lastLogin;
  final DateTime? updatedAt;

  // Economia
  final int coins;
  final int gems;

  // Sistema de níveis
  final int level;
  final int xp;
  final int totalXP;
  final int unlockedSlots;

  // Inventário e conquistas
  final List<String> inventory;
  final List<String> achievements;

  // Configurações
  final UserSettings settings;

  // Estatísticas
  final UserStats stats;

  // Campos adicionais
  final bool isEmailVerified;
  final AuthProviderType provider;
  final List<String> petIds;
  final String? currentPetId; // Pet atualmente ativo

  const UserModel({
    required this.id,
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.avatarUrl,
    required this.createdAt,
    required this.lastLogin,
    this.updatedAt,
    required this.coins,
    required this.gems,
    required this.level,
    required this.xp,
    required this.totalXP,
    required this.unlockedSlots,
    required this.inventory,
    required this.achievements,
    required this.settings,
    required this.stats,
    required this.isEmailVerified,
    required this.provider,
    required this.petIds,
    this.currentPetId,
  });

  // Getters de conveniência
  bool get hasPet => petIds.isNotEmpty && currentPetId != null;

  String get initials {
    final names = displayName?.split(' ') ?? [];
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return displayName?.isNotEmpty == true
        ? displayName![0].toUpperCase()
        : 'U';
  }

  bool get isNewUser {
    return DateTime.now().difference(createdAt).inDays < 7;
  }

  int get daysSinceJoined {
    return DateTime.now().difference(createdAt).inDays;
  }

  // Factory constructors
  factory UserModel.fromMap(Map<String, dynamic>? map) {
    map = map ?? {};
    return UserModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      avatarUrl: map['avatarUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      coins: map['coins'] ?? 100,
      gems: map['gems'] ?? 0,
      level: map['level'] ?? 1,
      xp: map['xp'] ?? 0,
      totalXP: map['totalXP'] ?? 0,
      unlockedSlots: map['unlockedSlots'] ?? 2,
      inventory: List<String>.from(map['inventory'] ?? []),
      achievements: List<String>.from(map['achievements'] ?? []),
      settings: UserSettings.fromMap(map['settings']),
      stats: UserStats.fromMap(map['stats']),
      isEmailVerified: map['isEmailVerified'] ?? false,
      provider: AuthProviderType.values.firstWhere(
        (e) => e.toString() == map?['provider'],
        orElse: () => AuthProviderType.email,
      ),
      petIds: List<String>.from(map['petIds'] ?? []),
      currentPetId: map['currentPetId'],
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return UserModel.fromMap({
      'id': doc.id, // Adiciona o ID do documento
      ...?data,
    });
  }

  factory UserModel.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return UserModel(
      id: json['id'] ?? '',
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      avatarUrl: json['avatarUrl'],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLogin:
          DateTime.parse(json['lastLogin'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      coins: json['coins'] ?? 100,
      gems: json['gems'] ?? 0,
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      totalXP: json['totalXP'] ?? 0,
      unlockedSlots: json['unlockedSlots'] ?? 2,
      inventory: List<String>.from(json['inventory'] ?? []),
      achievements: List<String>.from(json['achievements'] ?? []),
      settings: UserSettings.fromJson(jsonEncode(json['settings'] ?? {})),
      stats: UserStats.fromJson(jsonEncode(json['stats'] ?? {})),
      isEmailVerified: json['isEmailVerified'] ?? false,
      provider: AuthProviderType.values.firstWhere(
        (e) => e.toString() == json['provider'],
        orElse: () => AuthProviderType.email,
      ),
      petIds: List<String>.from(json['petIds'] ?? []),
      currentPetId: json['currentPetId'],
    );
  }

  // Conversion methods
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'coins': coins,
      'gems': gems,
      'level': level,
      'xp': xp,
      'totalXP': totalXP,
      'unlockedSlots': unlockedSlots,
      'inventory': inventory,
      'achievements': achievements,
      'settings': settings.toMap(),
      'stats': stats.toMap(),
      'isEmailVerified': isEmailVerified,
      'provider': provider.toString(),
      'petIds': petIds,
      'currentPetId': currentPetId,
    };
  }

  Map<String, dynamic> toFirestore() {
    final map = toMap();
    map.remove('id'); // Remove o ID para não salvar no documento
    return map;
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  // Copy with method
  UserModel copyWith({
    String? id,
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
    DateTime? updatedAt,
    int? coins,
    int? gems,
    int? level,
    int? xp,
    int? totalXP,
    int? unlockedSlots,
    List<String>? inventory,
    List<String>? achievements,
    UserSettings? settings,
    UserStats? stats,
    bool? isEmailVerified,
    AuthProviderType? provider,
    List<String>? petIds,
    String? currentPetId,
  }) {
    return UserModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      updatedAt: updatedAt ?? this.updatedAt,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      totalXP: totalXP ?? this.totalXP,
      unlockedSlots: unlockedSlots ?? this.unlockedSlots,
      inventory: inventory ?? this.inventory,
      achievements: achievements ?? this.achievements,
      settings: settings ?? this.settings,
      stats: stats ?? this.stats,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      provider: provider ?? this.provider,
      petIds: petIds ?? this.petIds,
      currentPetId: currentPetId ?? this.currentPetId,
    );
  }

  // Business logic methods
  bool canAdoptMorePets(int currentPetsCount) {
    return currentPetsCount < unlockedSlots;
  }

  int getXPForNextLevel() {
    return level * 100;
  }

  double getLevelProgress() {
    final xpForNextLevel = getXPForNextLevel();
    return xpForNextLevel > 0 ? xp / xpForNextLevel : 0.0;
  }

  bool hasEnoughCoins(int cost) {
    return coins >= cost;
  }

  bool hasEnoughGems(int cost) {
    return gems >= cost;
  }

  @override
  String toString() {
    return 'UserModel{id: $id, uid: $uid, email: $email, displayName: $displayName, level: $level, coins: $coins, hasPet: $hasPet}';
  }

  @override
  List<Object?> get props => [
        id,
        uid,
        email,
        displayName,
        photoURL,
        avatarUrl,
        createdAt,
        lastLogin,
        updatedAt,
        coins,
        gems,
        level,
        xp,
        totalXP,
        unlockedSlots,
        inventory,
        achievements,
        settings,
        stats,
        isEmailVerified,
        provider,
        petIds,
        currentPetId,
      ];
}
