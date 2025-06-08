// File: lib/core/config/app_config.dart

/// Application configuration constants and settings
class AppConfig {
  static const String appName = 'Pet Game Deluxe';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your favorite virtual pet companion';

  // Database settings
  static const String firestoreUsersCollection = 'users';
  static const String firestorePetsCollection = 'pets';
  static const String firestoreTransactionsCollection = 'transactions';
  static const String firestoreAchievementsCollection = 'achievements';

  // Game settings
  static const int initialCoins = 1000;
  static const int initialGems = 50;
  static const int initialXp = 0;
  static const int initialLevel = 1;

  // Pet care settings
  static const int petHungerDecayRate = 3; // per minute
  static const int petHappinessDecayRate = 2; // per minute
  static const int petEnergyDecayRate = 1; // per 5 minutes

  // Transaction costs
  static const int feedPetCost = 10;
  static const int playWithPetCost = 5;
  static const int adoptPetCost = 100;

  // Rewards
  static const int feedPetXpReward = 10;
  static const int playWithPetXpReward = 15;
  static const int restPetXpReward = 5;
  static const int dailyRewardBaseCoins = 50;
  static const int dailyRewardBaseGems = 0;
  static const int dailyRewardBaseXp = 20;

  // Timers (in milliseconds)
  static const int petDecayTimerInterval = 60000; // 1 minute
  static const int dailyRewardCheckInterval = 30000; // 30 seconds

  // Animation durations
  static const int defaultAnimationDuration = 300;
  static const int fastAnimationDuration = 150;
  static const int slowAnimationDuration = 600;

  // Cache settings
  static const int imageCacheMaxAge = 7; // days
  static const int dataCacheMaxAge = 1; // day

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // URLs and endpoints
  static const String supportEmail = 'support@petgame.com';
  static const String privacyPolicyUrl = 'https://petgame.com/privacy';
  static const String termsOfServiceUrl = 'https://petgame.com/terms';
}

// File: lib/core/constants/app_constants.dart

/// Application constants and configuration values
class AppConstants {
  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 600);

  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration authTimeout = Duration(seconds: 60);

  // Cache keys
  static const String userDataCacheKey = 'user_data';
  static const String petDataCacheKey = 'pet_data';
  static const String themeCacheKey = 'app_theme';

  // Shared preferences keys
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String lastDailyRewardKey = 'last_daily_reward';
  static const String userPreferencesKey = 'user_preferences';

  // Error messages
  static const String networkErrorMessage = 'Please check your internet connection';
  static const String authErrorMessage = 'Authentication failed';
  static const String unknownErrorMessage = 'Something went wrong';

  // Success messages
  static const String petFedSuccessMessage = 'Pet fed successfully!';
  static const String petPlaySuccessMessage = 'Pet is happy after playing!';
  static const String petRestSuccessMessage = 'Pet is well rested!';
  static const String dailyRewardClaimedMessage = 'Daily reward claimed!';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 200;
}
