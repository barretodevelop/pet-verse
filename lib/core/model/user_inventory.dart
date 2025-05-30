import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/economy/price.dart';
import 'package:petverse/core/model/economy/purchase_result.dart';

class UserInventory {
  final Map<String, int> items; // itemId: quantidade
  final int coins;
  final int gems;
  final DateTime lastDailyReward;
  final Map<String, DateTime> activeEffects; // NOVO: Efeitos temporários ativos

  UserInventory({
    required this.items,
    required this.coins,
    required this.gems,
    required this.lastDailyReward,
    this.activeEffects = const {},
  });

  UserInventory copyWith({
    Map<String, int>? items,
    int? coins,
    int? gems,
    DateTime? lastDailyReward,
    Map<String, DateTime>? activeEffects,
  }) {
    return UserInventory(
      items: items ?? this.items,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      lastDailyReward: lastDailyReward ?? this.lastDailyReward,
      activeEffects: activeEffects ?? this.activeEffects,
    );
  }

  // Verificar se pode pagar e determinar qual moeda usar
  PurchaseResult canAffordAndGetCurrency(Price price) {
    if (price.isFree) {
      return PurchaseResult(canAfford: true, currencyUsed: CurrencyType.free);
    }

    if (price.bothRequired) {
      bool canAfford = (price.coins ?? 0) <= coins && (price.gems ?? 0) <= gems;
      return PurchaseResult(
          canAfford: canAfford, currencyUsed: CurrencyType.both);
    }

    // Verificar opções disponíveis
    bool canPayWithCoins = price.hasCoins && coins >= (price.coins ?? 0);
    bool canPayWithGems = price.hasGems && gems >= (price.gems ?? 0);

    if (canPayWithCoins && canPayWithGems) {
      // Preferir coins se ambos são possíveis
      return PurchaseResult(canAfford: true, currencyUsed: CurrencyType.coins);
    } else if (canPayWithCoins) {
      return PurchaseResult(canAfford: true, currencyUsed: CurrencyType.coins);
    } else if (canPayWithGems) {
      return PurchaseResult(canAfford: true, currencyUsed: CurrencyType.gems);
    }

    return PurchaseResult(canAfford: false, currencyUsed: CurrencyType.coins);
  }

  // Versão antiga mantida para compatibilidade
  bool canAfford(Price price) {
    return canAffordAndGetCurrency(price).canAfford;
  }

  // Subtrair custo usando moeda específica
  UserInventory subtractCostWithCurrency(
      Price price, CurrencyType currencyUsed) {
    int newCoins = coins;
    int newGems = gems;

    switch (currencyUsed) {
      case CurrencyType.coins:
        newCoins -= (price.coins ?? 0);
        break;
      case CurrencyType.gems:
        newGems -= (price.gems ?? 0);
        break;
      case CurrencyType.both:
        newCoins -= (price.coins ?? 0);
        newGems -= (price.gems ?? 0);
        break;
      case CurrencyType.free:
        // Nada a fazer
        break;
    }

    return copyWith(coins: newCoins, gems: newGems);
  }

  // Versão antiga mantida para compatibilidade
  UserInventory subtractCost(Price price) {
    final result = canAffordAndGetCurrency(price);
    return subtractCostWithCurrency(price, result.currencyUsed);
  }

  // Adicionar item ao inventário
  UserInventory addItem(String itemId, int quantity) {
    final newItems = Map<String, int>.from(items);
    newItems[itemId] = (newItems[itemId] ?? 0) + quantity;
    return copyWith(items: newItems);
  }

  // Usar item do inventário
  UserInventory useItem(String itemId, int quantity) {
    final newItems = Map<String, int>.from(items);
    final currentQuantity = newItems[itemId] ?? 0;

    if (currentQuantity >= quantity) {
      newItems[itemId] = currentQuantity - quantity;
      if (newItems[itemId] == 0) {
        newItems.remove(itemId);
      }
    }

    return copyWith(items: newItems);
  }

  // Verificar se tem item suficiente
  bool hasItem(String itemId, int quantity) {
    return (items[itemId] ?? 0) >= quantity;
  }

  // NOVO: Verificar se pode coletar recompensa diária
  bool canCollectDailyReward() {
    final now = DateTime.now();
    final lastReward = lastDailyReward;
    return now.difference(lastReward).inDays >= 1;
  }

  // NOVO: Adicionar moedas/gemas
  UserInventory addCurrency({int? coinsToAdd, int? gemsToAdd}) {
    return copyWith(
      coins: coins + (coinsToAdd ?? 0),
      gems: gems + (gemsToAdd ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items,
      'coins': coins,
      'gems': gems,
      'lastDailyReward': lastDailyReward.toIso8601String(),
      'activeEffects': activeEffects.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
    };
  }

  factory UserInventory.fromJson(Map<String, dynamic> json) {
    return UserInventory(
      items: Map<String, int>.from(json['items']),
      coins: json['coins'],
      gems: json['gems'],
      lastDailyReward: DateTime.parse(json['lastDailyReward']),
      activeEffects: (json['activeEffects'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, DateTime.parse(value)),
          ) ??
          {},
    );
  }
}
