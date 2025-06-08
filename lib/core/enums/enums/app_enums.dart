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
enum PetMood {
  happy,
  sad,
  excited,
  tired,
  hungry,
  playful,
  sleepy,
}

enum PetAction {
  feeding,
  playing,
  sleeping,
  idle,
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

/// Pet evolution stages
enum EvolutionStage {
  baby,
  child,
  teenager,
  adult,
  elder,
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
