// =============================================================================
// DOMAIN MODELS (Firebase-ready)
// =============================================================================

import 'package:petverse/core/enums/enums.dart';

class GameItem {
  final String id;
  final String name;
  final String emoji;
  final ItemCategory category;
  final ItemRarity rarity;
  final Map<String, double> effects;
  final int? coins;
  final int? gems;
  final String description;
  final DateTime? createdAt;
  final bool isActive;

  GameItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.rarity,
    required this.effects,
    this.coins,
    this.gems,
    required this.description,
    this.createdAt,
    this.isActive = true,
  });

  // Firebase-ready serialization
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'category': category.name,
      'rarity': rarity.name,
      'effects': effects,
      'coins': coins,
      'gems': gems,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory GameItem.fromFirestore(Map<String, dynamic> data, String documentId) {
    return GameItem(
      id: data['id'] ?? documentId,
      name: data['name'] ?? '',
      emoji: data['emoji'] ?? '❓',
      category: ItemCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => ItemCategory.food,
      ),
      rarity: ItemRarity.values.firstWhere(
        (r) => r.name == data['rarity'],
        orElse: () => ItemRarity.common,
      ),
      effects: Map<String, double>.from(data['effects'] ?? {}),
      coins: data['coins'],
      gems: data['gems'],
      description: data['description'] ?? '',
      createdAt:
          data['createdAt'] != null ? DateTime.parse(data['createdAt']) : null,
      isActive: data['isActive'] ?? true,
    );
  }

  // Local storage compatibility
  Map<String, dynamic> toJson() => toFirestore();
  factory GameItem.fromJson(Map<String, dynamic> json) =>
      GameItem.fromFirestore(json, json['id']);

  // Helper methods
  bool get isFree => coins == null && gems == null;
  bool get isPremium => gems != null;

  int get totalCost {
    return (coins ?? 0) + ((gems ?? 0) * 10); // Gems worth 10x coins
  }

  GameItem copyWith({
    String? id,
    String? name,
    String? emoji,
    ItemCategory? category,
    ItemRarity? rarity,
    Map<String, double>? effects,
    int? coins,
    int? gems,
    String? description,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return GameItem(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      effects: effects ?? this.effects,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GameItem(id: $id, name: $name, category: $category)';
}

class UserWallet {
  final int coins;
  final int gems;
  final DateTime? lastUpdated;

  UserWallet({
    required this.coins,
    required this.gems,
    this.lastUpdated,
  });

  UserWallet copyWith({
    int? coins,
    int? gems,
    DateTime? lastUpdated,
  }) {
    return UserWallet(
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  // Firebase-ready serialization
  Map<String, dynamic> toFirestore() {
    return {
      'coins': coins,
      'gems': gems,
      'lastUpdated':
          lastUpdated?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory UserWallet.fromFirestore(Map<String, dynamic> data) {
    return UserWallet(
      coins: data['coins'] ?? 1250,
      gems: data['gems'] ?? 25,
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.parse(data['lastUpdated'])
          : DateTime.now(),
    );
  }

  // Local storage compatibility
  Map<String, dynamic> toJson() => toFirestore();
  factory UserWallet.fromJson(Map<String, dynamic> json) =>
      UserWallet.fromFirestore(json);

  // Helper methods
  bool canAfford(GameItem item) {
    if (item.coins != null && item.gems != null) {
      return coins >= item.coins! && gems >= item.gems!;
    } else if (item.coins != null) {
      return coins >= item.coins!;
    } else if (item.gems != null) {
      return gems >= item.gems!;
    }
    return true; // Free item
  }

  UserWallet afterPurchase(GameItem item) {
    if (!canAfford(item)) return this;

    return copyWith(
      coins: item.coins != null ? coins - item.coins! : coins,
      gems: item.gems != null ? gems - item.gems! : gems,
      lastUpdated: DateTime.now(),
    );
  }

  UserWallet addCurrency({int? coins, int? gems}) {
    return copyWith(
      coins: coins != null ? this.coins + coins : this.coins,
      gems: gems != null ? this.gems + gems : this.gems,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserWallet &&
          runtimeType == other.runtimeType &&
          coins == other.coins &&
          gems == other.gems;

  @override
  int get hashCode => coins.hashCode ^ gems.hashCode;

  @override
  String toString() => 'UserWallet(coins: $coins, gems: $gems)';
}

class InventoryItem {
  final String id;
  final GameItem item;
  final int quantity;
  final DateTime purchasedAt;
  final DateTime? usedAt;

  InventoryItem({
    String? id,
    required this.item,
    required this.quantity,
    required this.purchasedAt,
    this.usedAt,
  }) : id = id ?? '${item.id}_${DateTime.now().millisecondsSinceEpoch}';

  InventoryItem copyWith({
    String? id,
    GameItem? item,
    int? quantity,
    DateTime? purchasedAt,
    DateTime? usedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      usedAt: usedAt ?? this.usedAt,
    );
  }

  // Firebase-ready serialization
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'itemId': item.id,
      'item': item.toFirestore(), // Denormalized for easier queries
      'quantity': quantity,
      'purchasedAt': purchasedAt.toIso8601String(),
      'usedAt': usedAt?.toIso8601String(),
    };
  }

  factory InventoryItem.fromFirestore(
      Map<String, dynamic> data, String? documentId) {
    return InventoryItem(
      id: data['id'] ?? documentId,
      item: GameItem.fromFirestore(data['item'], data['itemId']),
      quantity: data['quantity'] ?? 1,
      purchasedAt: DateTime.parse(data['purchasedAt']),
      usedAt: data['usedAt'] != null ? DateTime.parse(data['usedAt']) : null,
    );
  }

  // Local storage compatibility
  Map<String, dynamic> toJson() => toFirestore();
  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      InventoryItem.fromFirestore(json, json['id']);

  // Helper methods
  bool get isUsed => usedAt != null;
  bool get isConsumable =>
      item.category == ItemCategory.food ||
      item.category == ItemCategory.care ||
      item.effects.containsKey('energy');

  Duration get ageInInventory => DateTime.now().difference(purchasedAt);

  double get totalValue {
    return item.totalCost * quantity.toDouble();
  }

  InventoryItem use({int amount = 1}) {
    final newQuantity = quantity - amount;
    if (newQuantity <= 0) {
      return copyWith(quantity: 0, usedAt: DateTime.now());
    }
    return copyWith(quantity: newQuantity);
  }

  InventoryItem addQuantity(int amount) {
    return copyWith(quantity: quantity + amount);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'InventoryItem(id: $id, item: ${item.name}, quantity: $quantity)';
}

// =============================================================================
// HELPER EXTENSIONS
// =============================================================================

extension ItemCategoryExtension on ItemCategory {
  String get displayName {
    switch (this) {
      case ItemCategory.food:
        return 'Alimentos';
      case ItemCategory.toys:
        return 'Brinquedos';
      case ItemCategory.care:
        return 'Cuidados';
      case ItemCategory.special:
        return 'Especiais';
    }
  }

  String get emoji {
    switch (this) {
      case ItemCategory.food:
        return '🍖';
      case ItemCategory.toys:
        return '🎾';
      case ItemCategory.care:
        return '🧼';
      case ItemCategory.special:
        return '⭐';
    }
  }

  String get description {
    switch (this) {
      case ItemCategory.food:
        return 'Itens nutritivos para manter seu pet saudável';
      case ItemCategory.toys:
        return 'Diversão garantida para seu companheiro';
      case ItemCategory.care:
        return 'Produtos de higiene e saúde';
      case ItemCategory.special:
        return 'Itens mágicos com efeitos únicos';
    }
  }
}

extension ItemRarityExtension on ItemRarity {
  String get displayName {
    switch (this) {
      case ItemRarity.common:
        return 'Comum';
      case ItemRarity.rare:
        return 'Raro';
      case ItemRarity.epic:
        return 'Épico';
      case ItemRarity.legendary:
        return 'Lendário';
    }
  }

  int get colorValue {
    switch (this) {
      case ItemRarity.common:
        return 0xFF64748B;
      case ItemRarity.rare:
        return 0xFF3B82F6;
      case ItemRarity.epic:
        return 0xFF8B5CF6;
      case ItemRarity.legendary:
        return 0xFFF59E0B;
    }
  }

  double get dropRate {
    switch (this) {
      case ItemRarity.common:
        return 60.0;
      case ItemRarity.rare:
        return 25.0;
      case ItemRarity.epic:
        return 12.0;
      case ItemRarity.legendary:
        return 3.0;
    }
  }
}

// =============================================================================
// STATIC FACTORIES FOR MOCK DATA
// =============================================================================

class GameItemFactory {
  static GameItem fromMockData(Map<String, dynamic> data) {
    return GameItem(
      id: data['id'],
      name: data['name'],
      emoji: data['emoji'],
      category: ItemCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => ItemCategory.food,
      ),
      rarity: ItemRarity.values.firstWhere(
        (r) => r.name == data['rarity'],
        orElse: () => ItemRarity.common,
      ),
      effects: Map<String, double>.from(data['effects']),
      coins: data['coins'],
      gems: data['gems'],
      description: data['description'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  static List<GameItem> fromMockDataList(List<Map<String, dynamic>> dataList) {
    return dataList.map((data) => fromMockData(data)).toList();
  }
}

class UserWalletFactory {
  static UserWallet fromMockData(Map<String, dynamic> data) {
    return UserWallet(
      coins: data['coins'] ?? 1250,
      gems: data['gems'] ?? 25,
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.parse(data['lastUpdated'])
          : DateTime.now(),
    );
  }
}

class InventoryItemFactory {
  static InventoryItem fromMockData(Map<String, dynamic> data) {
    return InventoryItem(
      id: data['id'],
      item: GameItemFactory.fromMockData(data['item']),
      quantity: data['quantity'] ?? 1,
      purchasedAt: DateTime.parse(data['purchasedAt']),
      usedAt: data['usedAt'] != null ? DateTime.parse(data['usedAt']) : null,
    );
  }

  static List<InventoryItem> fromMockDataList(
      List<Map<String, dynamic>> dataList) {
    return dataList.map((data) => fromMockData(data)).toList();
  }
}
