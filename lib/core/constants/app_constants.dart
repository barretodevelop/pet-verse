class AppConstants {
  static const String appName = 'PetVerse';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Cuidado Virtual de Pets Colaborativo';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String petsCollection = 'pets';
  static const String adoptionSessionsCollection = 'adoption_sessions';
  static const String collaborativePetsCollection = 'collaborative_pets';
  static const String shopItemsCollection = 'shop_items';
  static const String missionsCollection = 'missions';
  static const String achievementsCollection = 'achievements';
  static const String socialFeedCollection = 'social_feed';

  // SharedPreferences Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyUserPrefs = 'user_preferences';
  static const String keyOfflineData = 'offline_data';
  static const String keyLastSync = 'last_sync';
  static const String keyNotificationSettings = 'notification_settings';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keySelectedLanguage = 'selected_language';
  static const String keyThemeMode = 'theme_mode';

  // Hive Boxes
  static const String userBox = 'user_box';
  static const String petBox = 'pet_box';
  static const String missionBox = 'mission_box';
  static const String cacheBox = 'cache_box';

  // Pet Care Limits
  static const int maxPetsPerUser = 3;
  static const int maxCollaborativeSuggestions = 3;
  static const int collaborativeExpirationDays = 5;
  static const int maxDailyCoins = 1000;
  static const int maxDailyGems = 20;

  // Status Thresholds
  static const double hungerCriticalThreshold = 20.0;
  static const double happinessCriticalThreshold = 20.0;
  static const double cleanlinessCriticalThreshold = 20.0;
  static const double healthCriticalThreshold = 30.0;
  static const double energyCriticalThreshold = 20.0;

  // Game Balance
  static const int feedingCoins = 5;
  static const int playingCoins = 3;
  static const int cleaningCoins = 4;
  static const int veterinaryCoins = 10;
  static const int levelUpBonus = 50;
  static const int dailyLoginBonus = 20;

  // XP System
  static const int feedingXP = 10;
  static const int playingXP = 8;
  static const int cleaningXP = 6;
  static const int veterinaryXP = 15;
  static const int missionCompleteXP = 25;
  static const int achievementXP = 100;

  // Timers (in seconds)
  static const int petStatusUpdateInterval = 300; // 5 minutes
  static const int hungerDecreaseInterval = 3600; // 1 hour
  static const int happinessDecreaseInterval = 7200; // 2 hours
  static const int cleanlinessDecreaseInterval = 10800; // 3 hours
  static const int energyDecreaseInterval = 14400; // 4 hours

  // Notification IDs
  static const int petHungryNotificationId = 1;
  static const int petSadNotificationId = 2;
  static const int petDirtyNotificationId = 3;
  static const int missionCompleteNotificationId = 4;
  static const int collaborationInviteNotificationId = 5;
  static const int luckyHourNotificationId = 6;
  static const int dailyReminderNotificationId = 7;

  // Asset Paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  static const String petsPath = 'assets/pets/';
  static const String lottiePath = 'assets/lottie/';

  // Pet Types
  static const List<String> petTypes = ['dog', 'cat', 'bird', 'rabbit'];

  static const Map<String, List<String>> petBreeds = {
    'dog': [
      'golden_retriever',
      'labrador',
      'husky',
      'pug',
      'beagle',
      'bulldog',
      'german_shepherd',
      'chihuahua'
    ],
    'cat': [
      'persian',
      'siamese',
      'tabby',
      'calico',
      'maine_coon',
      'british_shorthair',
      'ragdoll',
      'sphinx'
    ],
    'bird': [
      'canary',
      'cockatiel',
      'parakeet',
      'lovebird',
      'macaw',
      'cockatoo'
    ],
    'rabbit': ['holland_lop', 'angora', 'mini_rex', 'dwarf_hotot', 'lionhead'],
  };

  static const List<String> petColors = [
    'white',
    'black',
    'brown',
    'gray',
    'golden',
    'cream',
    'tan',
    'multicolor',
    'tricolor',
    'spotted'
  ];

  // Mission Types
  static const List<String> missionTypes = [
    'feed_pet',
    'play_with_pet',
    'clean_pet',
    'level_up_pet',
    'earn_coins',
    'complete_minigame',
    'collaborative_care',
    'social_interaction'
  ];

  // Achievement Categories
  static const List<String> achievementCategories = [
    'caregiver',
    'social',
    'collector',
    'gamer',
    'explorer',
    'veteran'
  ];

  // Shop Categories
  static const List<String> shopCategories = [
    'food',
    'toys',
    'accessories',
    'backgrounds',
    'special_items',
    'currency_packs'
  ];

  // Error Messages
  static const String errorGeneric = 'Algo deu errado. Tente novamente.';
  static const String errorNetwork = 'Verifique sua conexão com a internet.';
  static const String errorAuth = 'Erro de autenticação. Faça login novamente.';
  static const String errorPetNotFound = 'Pet não encontrado.';
  static const String errorInsufficientCoins = 'Moedas insuficientes.';
  static const String errorInsufficientGems = 'Gemas insuficientes.';
  static const String errorMaxPetsReached = 'Limite máximo de pets atingido.';
  static const String errorItemAlreadyOwned = 'Você já possui este item.';

  // Success Messages
  static const String successLogin = 'Login realizado com sucesso!';
  static const String successRegister = 'Conta criada com sucesso!';
  static const String successPetAdopted = 'Pet adotado com sucesso!';
  static const String successItemPurchased = 'Item comprado com sucesso!';
  static const String successMissionCompleted = 'Missão completada!';
  static const String successAchievementUnlocked = 'Conquista desbloqueada!';

  // Validation
  static const int minNameLength = 2;
  static const int maxNameLength = 20;
  static const int maxDescriptionLength = 500;

  static const int minEmailLength = 5;
  static const int minPasswordLength = 6;

  // API Limits
  static const int maxRetryAttempts = 3;
  static const int requestTimeoutSeconds = 30;
  static const int cacheExpirationMinutes = 30;

  // Features Flags
  static const bool enableCollaborativeAdoption = true;
  static const bool enableMiniGames = true;
  static const bool enableSocialFeed = true;
  static const bool enableNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;

  // Environment
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const bool enableDebugMode = !isProduction;

  // URLs
  static const String privacyPolicyUrl = 'https://petverse.app/privacy';
  static const String termsOfServiceUrl = 'https://petverse.app/terms';
  static const String supportUrl = 'https://petverse.app/support';
  static const String websiteUrl = 'https://petverse.app';

  // Social Media
  static const String instagramUrl = 'https://instagram.com/petverse.app';
  static const String twitterUrl = 'https://twitter.com/petverse_app';
  static const String facebookUrl = 'https://facebook.com/petverse.app';

  // Regex Patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String namePattern = r'^[a-zA-ZÀ-ÿ\s]{2,20}$';
  static const String petNamePattern = r'^[a-zA-ZÀ-ÿ0-9\s]{2,15}$';

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-ddTHH:mm:ss.SSSZ';

  // Animation Durations
  static const int shortAnimationMs = 200;
  static const int mediumAnimationMs = 300;
  static const int longAnimationMs = 500;
  static const int splashDurationMs = 2000;

  // File Sizes
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxCacheSizeBytes = 100 * 1024 * 1024; // 100MB

  // Helper Methods
  static String getPetImagePath(String type, String breed, String color) {
    return '$petsPath${type}_${breed}_$color.png';
  }

  static String getMoodIconPath(String mood) {
    return '${iconsPath}mood_$mood.png';
  }

  static String getLottieAnimationPath(String animation) {
    return '$lottiePath$animation.json';
  }

  // static bool isEmailValid(String email) {
  //   return RegExp(emailPattern)asMatch(email) &&
  //       email.length >= minEmailLength;
  // }

  static int getXPForLevel(int level) {
    return level * 100; // Linear progression for simplicity
  }

  static int getMaxSlotsForLevel(int level) {
    if (level >= 20) return 5;
    if (level >= 15) return 4;
    if (level >= 10) return 3;
    return 2;
  }

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Adoption Settings
  static const int maxPetsPerRequest = 3;
  static const int adoptionExpirationDays = 5;
  static const int maxPublicAdoptionRequests = 50;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double smallPadding = 8.0;
  static const double defaultRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double smallRadius = 8.0;

  // Asset Paths
  static const String lottieAnimationsPath = 'assets/animations/';
  // static const String imagesPath = 'assets/images/';
  // static const String iconsPath = 'assets/icons/';

  // Lottie Animations
  static const String loadingAnimation = '${lottieAnimationsPath}loading.json';
  static const String successAnimation = '${lottieAnimationsPath}success.json';
  static const String errorAnimation = '${lottieAnimationsPath}error.json';
  static const String emptyStateAnimation =
      '${lottieAnimationsPath}empty_state.json';
  static const String petAnimation = '${lottieAnimationsPath}pet_heart.json';
  static const String adoptionAnimation =
      '${lottieAnimationsPath}adoption_celebrate.json';

  // Images
  static const String petPlaceholder = '${imagesPath}pet_placeholder.png';
  static const String userPlaceholder = '${imagesPath}user_placeholder.png';
  static const String adoptionIllustration =
      '${imagesPath}adoption_illustration.png';

  // Shared Preferences Keys
  static const String userPrefsKey = 'user_prefs';
  static const String themePrefsKey = 'theme_prefs';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String lastSyncKey = 'last_sync';

  // Error Messages
  static const String networkError = 'Erro de conexão. Verifique sua internet.';
  static const String unknownError = 'Algo deu errado. Tente novamente.';
  static const String authError = 'Erro de autenticação. Faça login novamente.';
  static const String adoptionError =
      'Erro ao processar adoção. Tente novamente.';

  // Success Messages
  static const String adoptionRequestCreated =
      'Pedido de adoção criado com sucesso!';
  static const String adoptionAccepted =
      'Adoção aceita! Bem-vindo ao seu novo pet!';
  static const String linkCopied = 'Link copiado para a área de transferência!';
}
