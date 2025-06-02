// lib/shared/models/user_state.dart
// ALTERADO: Implementação completa com validações e métodos corrigidos usando tipos seguros
import 'package:flutter/material.dart';
import 'package:petverse/shared/models/achievement_progress.dart';
import 'package:petverse/shared/models/quest_progress.dart';
import 'package:petverse/shared/models/shop_item.dart';

@immutable
class UserProfile {
  final String? firebaseUserId;
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
    this.firebaseUserId,
    this.coins = 100, // Valor inicial padrão
    this.gems = 10, // Valor inicial padrão
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

  // CORRIGIDO: Implementação completa da validação de compra
  bool canAfford(ShopItem item) {
    if (item.coinPrice > 0 && coins < item.coinPrice) {
      return false;
    }
    if (item.gemPrice > 0 && gems < item.gemPrice) {
      return false;
    }
    return true;
  }

  // NOVO: Validação mais específica com detalhes
  Map<String, dynamic> getAffordabilityDetails(ShopItem item) {
    final details = <String, dynamic>{
      'canAfford': true,
      'reasons': <String>[],
      'missing': <String, int>{},
    };

    if (item.coinPrice > 0 && coins < item.coinPrice) {
      details['canAfford'] = false;
      details['reasons'].add('Moedas insuficientes');
      details['missing']['coins'] = item.coinPrice - coins;
    }

    if (item.gemPrice > 0 && gems < item.gemPrice) {
      details['canAfford'] = false;
      details['reasons'].add('Gemas insuficientes');
      details['missing']['gems'] = item.gemPrice - gems;
    }

    return details;
  }

  // MELHORADO: Verificação de item com validação
  bool hasItem(String itemId) {
    if (itemId.isEmpty) return false;
    return (itemQuantities[itemId] ?? 0) > 0;
  }

  // MELHORADO: Quantidade de item com validação
  int getItemQuantity(String itemId) {
    if (itemId.isEmpty) return 0;
    return itemQuantities[itemId] ?? 0;
  }

  // NOVO: Verificar se pode comprar mais de um item
  bool canBuyMore(ShopItem item) {
    return item.isStackable || !hasItem(item.id);
  }

  // NOVO: Métodos de validação
  bool get isValid => firebaseUserId != null && firebaseUserId!.isNotEmpty;

  bool get hasEnoughResourcesForBasicPurchase => coins >= 1 || gems >= 1;

  int get totalItemsOwned =>
      itemQuantities.values.fold(0, (sum, qty) => sum + qty);

  int get uniqueItemsOwned => itemQuantities.keys.length;

  // MELHORADO: copyWith com validações
  UserProfile copyWith({
    String? firebaseUserId,
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
  }) {
    // Validações para evitar valores inválidos
    final newCoins = (coins ?? this.coins).clamp(0, 999999);
    final newGems = (gems ?? this.gems).clamp(0, 999999);
    final newUxp = (uxp ?? this.uxp).clamp(0, 999999999);

    return UserProfile(
      firebaseUserId: firebaseUserId ?? this.firebaseUserId,
      coins: newCoins,
      gems: newGems,
      itemQuantities: itemQuantities ?? this.itemQuantities,
      equippedItemId:
          clearEquippedItem ? null : (equippedItemId ?? this.equippedItemId),
      dailyQuests: dailyQuests ?? this.dailyQuests,
      lastQuestResetDate: lastQuestResetDate ?? this.lastQuestResetDate,
      uxp: newUxp,
      activeWallpaperId:
          clearWallpaper ? null : (activeWallpaperId ?? this.activeWallpaperId),
      activeFloorId: clearFloor ? null : (activeFloorId ?? this.activeFloorId),
      collectedItemIds: collectedItemIds ?? this.collectedItemIds,
      collectedPetIds: collectedPetIds ?? this.collectedPetIds,
      achievementProgress: achievementProgress ?? this.achievementProgress,
    );
  }

  // MELHORADO: Serialização com tratamento de erros
  Map<String, dynamic> toJson() {
    try {
      return {
        'firebaseUserId': firebaseUserId,
        'coins': coins,
        'gems': gems,
        'itemQuantities': Map<String, dynamic>.from(itemQuantities),
        'equippedItemId': equippedItemId,
        'dailyQuests': dailyQuests.map((k, v) => MapEntry(k, v.toJson())),
        'lastQuestResetDate': lastQuestResetDate,
        'uxp': uxp,
        'activeWallpaperId': activeWallpaperId,
        'activeFloorId': activeFloorId,
        'collectedItemIds': collectedItemIds.toList(),
        'collectedPetIds': collectedPetIds.toList(),
        'achievementProgress':
            achievementProgress.map((k, v) => MapEntry(k, v.toJson())),
        'version': 1, // Versão do schema para futuras migrações
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('❌ Erro na serialização do UserProfile: $e');
      // Retornar versão mínima em caso de erro
      return {
        'firebaseUserId': firebaseUserId,
        'coins': coins,
        'gems': gems,
        'uxp': uxp,
        'error': 'Serialization error: ${e.toString()}',
      };
    }
  }

  // MELHORADO: Desserialização com tratamento de erros e migrações
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    try {
      // Tratamento de migração de versões
      final version = json['version'] ?? 0;

      // Parse de dailyQuests com tratamento de erro
      Map<String, QuestProgress> parseQuests(dynamic questsData) {
        try {
          if (questsData == null) return {};

          final questsJson = questsData as Map<String, dynamic>;
          return questsJson.map((k, v) {
            try {
              return MapEntry(
                  k, QuestProgress.fromJson(v as Map<String, dynamic>));
            } catch (e) {
              debugPrint('❌ Erro ao parsear quest $k: $e');
              return MapEntry(k, QuestProgress(questId: k));
            }
          });
        } catch (e) {
          debugPrint('❌ Erro ao parsear dailyQuests: $e');
          return <String, QuestProgress>{};
        }
      }

      // Parse de itemQuantities com tratamento de erro
      Map<String, int> parseItemQuantities(dynamic itemsData) {
        try {
          if (itemsData == null) return {};

          final itemsJson = itemsData as Map<String, dynamic>;
          return itemsJson.map((k, v) => MapEntry(k, (v as num).toInt()));
        } catch (e) {
          debugPrint('❌ Erro ao parsear itemQuantities: $e');
          return <String, int>{};
        }
      }

      // Parse de achievementProgress com tratamento de erro
      Map<String, AchievementProgress> parseAchievements(
          dynamic achievementsData) {
        try {
          if (achievementsData == null) return {};

          final achievementsJson = achievementsData as Map<String, dynamic>;
          return achievementsJson.map((k, v) {
            try {
              return MapEntry(
                  k, AchievementProgress.fromJson(v as Map<String, dynamic>));
            } catch (e) {
              debugPrint('❌ Erro ao parsear achievement $k: $e');
              return MapEntry(k, AchievementProgress(achievementId: k));
            }
          });
        } catch (e) {
          debugPrint('❌ Erro ao parsear achievementProgress: $e');
          return <String, AchievementProgress>{};
        }
      }

      return UserProfile(
        firebaseUserId: json['firebaseUserId'],
        coins: ((json['coins'] ?? 100) as num).toInt().clamp(0, 999999),
        gems: ((json['gems'] ?? 10) as num).toInt().clamp(0, 999999),
        itemQuantities: parseItemQuantities(json['itemQuantities']),
        equippedItemId: json['equippedItemId'],
        dailyQuests: parseQuests(json['dailyQuests']),
        lastQuestResetDate: json['lastQuestResetDate'] ?? '',
        uxp: ((json['uxp'] ?? 0) as num).toInt().clamp(0, 999999999),
        activeWallpaperId: json['activeWallpaperId'],
        activeFloorId: json['activeFloorId'],
        collectedItemIds: Set<String>.from(json['collectedItemIds'] ?? []),
        collectedPetIds: Set<String>.from(json['collectedPetIds'] ?? []),
        achievementProgress: parseAchievements(json['achievementProgress']),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao parsear UserProfile: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('JSON recebido: $json');

      // Retornar UserProfile padrão em caso de erro crítico
      return UserProfile(
        firebaseUserId: json['firebaseUserId'],
        coins: 100,
        gems: 10,
        uxp: 0,
      );
    }
  }

  // NOVO: Método para validar consistência dos dados
  List<String> validateData() {
    final errors = <String>[];

    if (firebaseUserId == null || firebaseUserId!.isEmpty) {
      errors.add('Firebase User ID é obrigatório');
    }

    if (coins < 0) errors.add('Moedas não podem ser negativas');
    if (gems < 0) errors.add('Gemas não podem ser negativas');
    if (uxp < 0) errors.add('UXP não pode ser negativo');

    // Validar quantidades de itens
    itemQuantities.forEach((itemId, quantity) {
      if (quantity < 0) {
        errors.add('Quantidade negativa para item: $itemId');
      }
      if (itemId.isEmpty) {
        errors.add('ID de item vazio encontrado');
      }
    });

    // Validar quests
    dailyQuests.forEach((questId, progress) {
      if (questId.isEmpty) {
        errors.add('ID de quest vazio encontrado');
      }
      if (progress.currentCount < 0) {
        errors.add('Progresso negativo na quest: $questId');
      }
    });

    return errors;
  }

  // NOVO: Método para criar versão limpa (para debug/export)
  UserProfile createCleanCopy() {
    return UserProfile(
      firebaseUserId: firebaseUserId,
      coins: coins.clamp(0, 999999),
      gems: gems.clamp(0, 999999),
      itemQuantities: Map<String, int>.fromEntries(
        itemQuantities.entries
            .where((entry) => entry.key.isNotEmpty && entry.value > 0),
      ),
      equippedItemId:
          equippedItemId?.isNotEmpty == true ? equippedItemId : null,
      dailyQuests: Map<String, QuestProgress>.fromEntries(
        dailyQuests.entries.where((entry) => entry.key.isNotEmpty),
      ),
      lastQuestResetDate: lastQuestResetDate,
      uxp: uxp.clamp(0, 999999999),
      activeWallpaperId:
          activeWallpaperId?.isNotEmpty == true ? activeWallpaperId : null,
      activeFloorId: activeFloorId?.isNotEmpty == true ? activeFloorId : null,
      collectedItemIds: Set<String>.from(
        collectedItemIds.where((id) => id.isNotEmpty),
      ),
      collectedPetIds: Set<String>.from(
        collectedPetIds.where((id) => id.isNotEmpty),
      ),
      achievementProgress: Map<String, AchievementProgress>.fromEntries(
        achievementProgress.entries.where((entry) => entry.key.isNotEmpty),
      ),
    );
  }

  @override
  String toString() {
    return 'UserProfile(uid: $firebaseUserId, coins: $coins, gems: $gems, uxp: $uxp, items: ${itemQuantities.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.firebaseUserId == firebaseUserId &&
        other.coins == coins &&
        other.gems == gems &&
        other.uxp == uxp;
  }

  @override
  int get hashCode {
    return Object.hash(firebaseUserId, coins, gems, uxp);
  }
}
