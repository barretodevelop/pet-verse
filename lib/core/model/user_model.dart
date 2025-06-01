// lib/core/model/user_model.dart
// CORRIGIDO: Mapeamento correto para usar UID do Firebase Auth

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/model/user_settings.dart';
import 'package:petverse/core/model/user_stats.dart';

class UserModel {
  final String uid; // CORRIGIDO: Usar UID ao invés de id genérico
  final String? email;
  final String? displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final DateTime updatedAt;

  // Economia do jogo
  final int coins;
  final int gems;
  final int level;
  final int xp;
  final int totalXP;

  // Sistema de pets
  final int unlockedSlots;
  final List<String> petIds; // IDs dos pets que o usuário possui
  final String? currentPetId; // Pet atualmente ativo

  // Inventário e conquistas
  final List<String> inventory;
  final List<String> achievements;

  // Configurações
  final UserSettings settings;
  final UserStats stats;

  // Estado da conta
  final bool isEmailVerified;
  final String provider;

  const UserModel({
    required this.uid, // CORRIGIDO: UID obrigatório
    this.email,
    this.displayName,
    this.photoURL,
    required this.createdAt,
    this.lastLogin,
    required this.updatedAt,
    this.coins = 100,
    this.gems = 0,
    this.level = 1,
    this.xp = 0,
    this.totalXP = 0,
    this.unlockedSlots = 2,
    this.petIds = const [],
    this.currentPetId,
    this.inventory = const [],
    this.achievements = const [],
    required this.settings,
    required this.stats,
    this.isEmailVerified = false,
    this.provider = 'email',
  });

  // Getters de conveniência
  bool get hasPet => petIds.isNotEmpty || currentPetId != null;
  bool get canAdoptMorePets => petIds.length < unlockedSlots;
  int get availableSlots => unlockedSlots - petIds.length;
  String get id =>
      uid; // ADICIONADO: Getter para compatibilidade com código existente

  // CORRIGIDO: Factory para criar a partir do Firestore usando UID
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      uid: doc.id, // CORRIGIDO: Usar o ID do documento como UID
      email: data['email'],
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      lastLogin: _parseTimestamp(data['lastLogin']),
      updatedAt: _parseTimestamp(data['updatedAt']) ?? DateTime.now(),
      coins: data['coins'] ?? 100,
      gems: data['gems'] ?? 0,
      level: data['level'] ?? 1,
      xp: data['xp'] ?? 0,
      totalXP: data['totalXP'] ?? 0,
      unlockedSlots: data['unlockedSlots'] ?? 2,
      petIds: List<String>.from(data['petIds'] ?? []),
      currentPetId: data['currentPetId'],
      inventory: List<String>.from(data['inventory'] ?? []),
      achievements: List<String>.from(data['achievements'] ?? []),
      settings: UserSettings.fromMap(data['settings'] ?? {}),
      stats: UserStats.fromMap(data['stats'] ?? {}),
      isEmailVerified: data['isEmailVerified'] ?? false,
      provider: data['provider'] ?? 'email',
    );
  }

  // CORRIGIDO: Factory para criar a partir de Map usando UID
  factory UserModel.fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      throw ArgumentError('Data cannot be null when creating UserModel');
    }

    return UserModel(
      uid: data['uid'] ?? data['id'] ?? '', // CORRIGIDO: Priorizar UID
      email: data['email'],
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      lastLogin: _parseTimestamp(data['lastLogin']),
      updatedAt: _parseTimestamp(data['updatedAt']) ?? DateTime.now(),
      coins: data['coins'] ?? 100,
      gems: data['gems'] ?? 0,
      level: data['level'] ?? 1,
      xp: data['xp'] ?? 0,
      totalXP: data['totalXP'] ?? 0,
      unlockedSlots: data['unlockedSlots'] ?? 2,
      petIds: List<String>.from(data['petIds'] ?? []),
      currentPetId: data['currentPetId'],
      inventory: List<String>.from(data['inventory'] ?? []),
      achievements: List<String>.from(data['achievements'] ?? []),
      settings: UserSettings.fromMap(data['settings'] ?? {}),
      stats: UserStats.fromMap(data['stats'] ?? {}),
      isEmailVerified: data['isEmailVerified'] ?? false,
      provider: data['provider'] ?? 'email',
    );
  }

  // CORRIGIDO: Converter para Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid, // CORRIGIDO: Incluir UID explicitamente
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'coins': coins,
      'gems': gems,
      'level': level,
      'xp': xp,
      'totalXP': totalXP,
      'unlockedSlots': unlockedSlots,
      'petIds': petIds,
      'currentPetId': currentPetId,
      'inventory': inventory,
      'achievements': achievements,
      'settings': settings.toMap(),
      'stats': stats.toMap(),
      'isEmailVerified': isEmailVerified,
      'provider': provider,
    };
  }

  // Converter para Map simples
  Map<String, dynamic> toMap() {
    return {
      'uid': uid, // CORRIGIDO: Usar UID
      'id': uid, // MANTIDO: Para compatibilidade
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'coins': coins,
      'gems': gems,
      'level': level,
      'xp': xp,
      'totalXP': totalXP,
      'unlockedSlots': unlockedSlots,
      'petIds': petIds,
      'currentPetId': currentPetId,
      'inventory': inventory,
      'achievements': achievements,
      'settings': settings.toMap(),
      'stats': stats.toMap(),
      'isEmailVerified': isEmailVerified,
      'provider': provider,
    };
  }

  // MELHORADO: CopyWith para imutabilidade
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastLogin,
    DateTime? updatedAt,
    int? coins,
    int? gems,
    int? level,
    int? xp,
    int? totalXP,
    int? unlockedSlots,
    List<String>? petIds,
    String? currentPetId,
    List<String>? inventory,
    List<String>? achievements,
    UserSettings? settings,
    UserStats? stats,
    bool? isEmailVerified,
    String? provider,
  }) {
    return UserModel(
      uid: uid ?? this.uid, // CORRIGIDO: UID correto
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      updatedAt: updatedAt ?? this.updatedAt,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      totalXP: totalXP ?? this.totalXP,
      unlockedSlots: unlockedSlots ?? this.unlockedSlots,
      petIds: petIds ?? this.petIds,
      currentPetId: currentPetId ?? this.currentPetId,
      inventory: inventory ?? this.inventory,
      achievements: achievements ?? this.achievements,
      settings: settings ?? this.settings,
      stats: stats ?? this.stats,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      provider: provider ?? this.provider,
    );
  }

  // Método para adicionar pet
  UserModel addPet(String petId, {bool setAsCurrent = true}) {
    final newPetIds = List<String>.from(petIds);
    if (!newPetIds.contains(petId)) {
      newPetIds.add(petId);
    }

    return copyWith(
      petIds: newPetIds,
      currentPetId: setAsCurrent ? petId : currentPetId,
      updatedAt: DateTime.now(),
    );
  }

  // Método para remover pet
  UserModel removePet(String petId) {
    final newPetIds = List<String>.from(petIds)..remove(petId);

    return copyWith(
      petIds: newPetIds,
      currentPetId: currentPetId == petId
          ? (newPetIds.isNotEmpty ? newPetIds.first : null)
          : currentPetId,
      updatedAt: DateTime.now(),
    );
  }

  // Método para ganhar XP e calcular nível
  UserModel gainXP(int xpAmount) {
    final newTotalXP = totalXP + xpAmount;
    final newLevel = (newTotalXP ~/ 100) + 1; // 100 XP por nível
    final newXP = newTotalXP % 100;

    return copyWith(
      xp: newXP,
      totalXP: newTotalXP,
      level: newLevel,
      updatedAt: DateTime.now(),
    );
  }

  // Método para adicionar coins
  UserModel addCoins(int amount) {
    return copyWith(
      coins: coins + amount,
      updatedAt: DateTime.now(),
    );
  }

  // Método para gastar coins
  UserModel spendCoins(int amount) {
    if (coins < amount) {
      throw Exception('Coins insuficientes');
    }

    return copyWith(
      coins: coins - amount,
      updatedAt: DateTime.now(),
    );
  }

  // Helper para parsing de timestamps
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;

    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }

    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, displayName: $displayName, level: $level, coins: $coins, petIds: $petIds)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
