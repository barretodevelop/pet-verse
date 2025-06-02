// lib/shared/models/user_state.dart
import 'package:flutter/material.dart';
import 'package:petverse/shared/models/achievement_progress.dart';
import 'package:petverse/shared/models/quest_progress.dart';
import 'package:petverse/shared/models/shop_item.dart';

@immutable
class UserProfile {
  // RENOMEADO de User para UserProfile para evitar conflito com firebase_auth.User
  final String? firebaseUserId; // NOVO: Para vincular ao usuário do Firebase
  final int coins;
  final int gems;
  final Map<String, int> itemQuantities;
  final String? equippedItemId;
  final Map<String, QuestProgress> dailyQuests;
  final String lastQuestResetDate;
  final int uxp;
  final String? activeWallpaperId;
  final String? activeFloorId;
  final Set<String> collectedItemIds;
  final Set<String> collectedPetIds;
  final Map<String, AchievementProgress> achievementProgress;

  const UserProfile({
    this.firebaseUserId, // NOVO
    this.coins = 0,
    this.gems = 0,
    this.itemQuantities = const {},
    this.equippedItemId,
    this.dailyQuests = const {},
    this.lastQuestResetDate = '',
    this.uxp = 0,
    this.activeWallpaperId,
    this.activeFloorId,
    this.collectedItemIds = const {},
    this.collectedPetIds = const {},
    this.achievementProgress = const {},
  });

  bool canAfford(ShopItem item) {
    /* ... */ return true;
  } // Implementação completa omitida

  bool hasItem(String itemId) => (itemQuantities[itemId] ?? 0) > 0;
  int getItemQuantity(String itemId) => itemQuantities[itemId] ?? 0;

  UserProfile copyWith({
    String? firebaseUserId, // NOVO
    int? coins,
    int? gems,
    Map<String, int>? itemQuantities,
    String? equippedItemId,
    bool clearEquippedItem = false,
    Map<String, QuestProgress>? dailyQuests,
    String? lastQuestResetDate,
    int? uxp,
    String? activeWallpaperId,
    String? activeFloorId,
    bool clearWallpaper = false,
    bool clearFloor = false,
    Set<String>? collectedItemIds,
    Set<String>? collectedPetIds,
    Map<String, AchievementProgress>? achievementProgress,
  }) =>
      UserProfile(
        firebaseUserId: firebaseUserId ?? this.firebaseUserId, // NOVO
        coins: coins ?? this.coins, gems: gems ?? this.gems,
        itemQuantities: itemQuantities ?? this.itemQuantities,
        equippedItemId:
            clearEquippedItem ? null : (equippedItemId ?? this.equippedItemId),
        dailyQuests: dailyQuests ?? this.dailyQuests,
        lastQuestResetDate: lastQuestResetDate ?? this.lastQuestResetDate,
        uxp: uxp ?? this.uxp,
        activeWallpaperId:
            clearWallpaper ? null : activeWallpaperId ?? this.activeWallpaperId,
        activeFloorId: clearFloor ? null : activeFloorId ?? this.activeFloorId,
        collectedItemIds: collectedItemIds ?? this.collectedItemIds,
        collectedPetIds: collectedPetIds ?? this.collectedPetIds,
        achievementProgress: achievementProgress ?? this.achievementProgress,
      );

  Map<String, dynamic> toJson() => {
        'firebaseUserId': firebaseUserId, // NOVO
        'coins': coins, 'gems': gems, 'itemQuantities': itemQuantities,
        'equippedItemId': equippedItemId,
        'dailyQuests': dailyQuests.map((k, v) => MapEntry(k, v.toJson())),
        'lastQuestResetDate': lastQuestResetDate, 'uxp': uxp,
        'activeWallpaperId': activeWallpaperId, 'activeFloorId': activeFloorId,
        'collectedItemIds': collectedItemIds.toList(),
        'collectedPetIds': collectedPetIds.toList(),
        'achievementProgress':
            achievementProgress.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final questsJson = json['dailyQuests'] as Map<String, dynamic>? ?? {};
    final quests = questsJson.map((k, v) =>
        MapEntry(k, QuestProgress.fromJson(v as Map<String, dynamic>)));
    final quantitiesJson = json['itemQuantities'] as Map<String, dynamic>?;
    final quantities =
        quantitiesJson?.map((k, v) => MapEntry(k, v as int)) ?? {};
    final achievementProgressJson =
        json['achievementProgress'] as Map<String, dynamic>? ?? {};
    final achievements = achievementProgressJson.map((k, v) =>
        MapEntry(k, AchievementProgress.fromJson(v as Map<String, dynamic>)));

    return UserProfile(
      firebaseUserId: json['firebaseUserId'], // NOVO
      coins: json['coins'] ?? 0, gems: json['gems'] ?? 0,
      itemQuantities: quantities,
      equippedItemId: json['equippedItemId'], dailyQuests: quests,
      lastQuestResetDate: json['lastQuestResetDate'] ?? '',
      uxp: json['uxp'] ?? 0,
      activeWallpaperId: json['activeWallpaperId'],
      activeFloorId: json['activeFloorId'],
      collectedItemIds: Set<String>.from(json['collectedItemIds'] ?? []),
      collectedPetIds: Set<String>.from(json['collectedPetIds'] ?? []),
      achievementProgress: achievements,
    );
  }
}
