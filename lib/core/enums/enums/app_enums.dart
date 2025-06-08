// File: lib/core/enums/app_enums.dart

/// Authentication status enum
enum AuthStatus {
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// App theme mode enum
enum AppTheme {
  light,
  dark,
  system,
}

/// Loading states for UI components
enum LoadingState {
  initial,
  loading,
  success,
  error,
}

/// Pet Game specific enums
enum AchievementType { petCare, gaming, collection, social, progression }

enum RewardType { coins, gems, xp, food, toy }

enum TransactionType {
  purchase,
  reward,
  achievement,
  dailyBonus,
  gameWin,
  petCare,
}

enum FoodRarity { common, uncommon, rare, epic, legendary }

enum ToyRarity { common, uncommon, rare, epic, legendary }

enum ToyType { ball, rope, puzzle, electronic, comfort, training }

/// Pet status enums

/// Pet evolution stages
enum EvolutionStage {
  baby, // Nível 1-4
  child, // Nível 5-9
  teenager, // Nível 10-19
  adult, // Nível 20-34
  elder, // Nível 35+
}

/// Pet action types for interactions
enum PetAction {
  feeding,
  playing,
  sleeping,
  idle,
}

/// Pet mood states
enum PetMood {
  happy,
  sad,
  excited,
  tired,
  hungry,
  playful,
  sleepy,
}

/// Navigation enums
enum BottomNavTab {
  dashboard,
  shop,
  pet,
  games,
  feed,
}

/// User level and progression
enum UserLevel {
  beginner,
  intermediate,
  advanced,
  expert,
  master,
}

/// Connection status
enum ConnectionStatus {
  connected,
  disconnected,
  connecting,
}

/// Notification types
enum NotificationType {
  petNeedsAttention,
  dailyReward,
  achievement,
  levelUp,
  general,
}

/// Gender enum for pets
enum PetGender {
  male,
  female,
  unknown,
}

/// Game difficulty levels
enum GameDifficulty {
  easy,
  medium,
  hard,
  expert,
}

/// Currency types
enum CurrencyType {
  coins,
  gems,
  xp,
}

/// Pet interaction results
enum InteractionResult {
  success,
  failed,
  insufficientResources,
  petTired,
  petNotFound,
}

enum ItemType {
  food,
  toy,
  medicine,
  accessory,
  special,
}

enum ItemRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}

enum ItemCategory {
  food,
  toys,
  medicine,
  accessories,
  special,
}

enum ItemEffectType {
  hunger,
  happiness,
  energy,
  health,
  xp,
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final CurrencyType currency;
  final ItemCategory category;
  final Map<ItemEffectType, int> effects;
  final String imageUrl;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.category,
    required this.effects,
    required this.imageUrl,
  });
}

class InventoryItem {
  final String id;
  final String userId;
  final String shopItemId;
  final String name;
  final ItemCategory category;
  final int quantity;
  final Map<ItemEffectType, int> effects;
  final String imageUrl;

  InventoryItem({
    required this.id,
    required this.userId,
    required this.shopItemId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.effects,
    required this.imageUrl,
  });

  InventoryItem copyWith({
    String? id,
    String? userId,
    String? shopItemId,
    String? name,
    ItemCategory? category,
    int? quantity,
    Map<ItemEffectType, int>? effects,
    String? imageUrl,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopItemId: shopItemId ?? this.shopItemId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      effects: effects ?? this.effects,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class PurchaseResult {
  final bool success;
  final String message;
  final ShopItem? item;

  PurchaseResult({
    required this.success,
    required this.message,
    this.item,
  });
}

class UseItemResult {
  final bool success;
  final String message;
  final Map<ItemEffectType, int> effects;

  UseItemResult({
    required this.success,
    required this.message,
    required this.effects,
  });
}
