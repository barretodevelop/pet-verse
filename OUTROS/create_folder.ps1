# Script PowerShell para criar estrutura do projeto
New-Item -ItemType Directory -Path "lib" -Force
New-Item -ItemType Directory -Path "lib/models" -Force  
New-Item -ItemType Directory -Path "lib/services" -Force
New-Item -ItemType Directory -Path "lib/providers" -Force
New-Item -ItemType Directory -Path "lib/screens" -Force
New-Item -ItemType Directory -Path "lib/widgets" -Force
New-Item -ItemType Directory -Path "lib/utils" -Force
New-Item -ItemType Directory -Path "lib/config" -Force
New-Item -ItemType Directory -Path "lib/animations" -Force

# Models
"// UserModel" | Out-File "lib/models/user_model.dart"
"// PetModel" | Out-File "lib/models/pet_model.dart" 
"// ItemModel" | Out-File "lib/models/item_model.dart"
"// MissionModel" | Out-File "lib/models/mission_model.dart"
"// FeedPostModel" | Out-File "lib/models/feed_post_model.dart"
"// ChatMessageModel" | Out-File "lib/models/chat_message_model.dart"
"// NotificationModel" | Out-File "lib/models/notification_model.dart"
"// InventoryItemModel" | Out-File "lib/models/inventory_item_model.dart"
"// PendingAdoptionModel" | Out-File "lib/models/pending_adoption_model.dart"
"// ParticleModel" | Out-File "lib/models/particle_model.dart"

# Services  
"// AuthService" | Out-File "lib/services/auth_service.dart"
"// FirestoreService" | Out-File "lib/services/firestore_service.dart"
"// StorageService" | Out-File "lib/services/storage_service.dart" 
"// AIService" | Out-File "lib/services/ai_service.dart"
"// NotificationService" | Out-File "lib/services/notification_service.dart"
"// MatchingService" | Out-File "lib/services/matching_service.dart"
"// MissionService" | Out-File "lib/services/mission_service.dart"
"// PetCareService" | Out-File "lib/services/pet_care_service.dart"
"// FeedService" | Out-File "lib/services/feed_service.dart"
"// ChatService" | Out-File "lib/services/chat_service.dart"

# Providers
"// AppProvider" | Out-File "lib/providers/app_provider.dart"
"// UserProvider" | Out-File "lib/providers/user_provider.dart"
"// PetProvider" | Out-File "lib/providers/pet_provider.dart"
"// InventoryProvider" | Out-File "lib/providers/inventory_provider.dart"
"// MissionProvider" | Out-File "lib/providers/mission_provider.dart"
"// FeedProvider" | Out-File "lib/providers/feed_provider.dart"
"// ChatProvider" | Out-File "lib/providers/chat_provider.dart"
"// ThemeProvider" | Out-File "lib/providers/theme_provider.dart"
"// NotificationProvider" | Out-File "lib/providers/notification_provider.dart"
"// ParticleProvider" | Out-File "lib/providers/particle_provider.dart"

# Screens
"// SplashScreen" | Out-File "lib/screens/splash_screen.dart"
"// LoginScreen" | Out-File "lib/screens/login_screen.dart"
"// HomeScreen" | Out-File "lib/screens/home_screen.dart"
"// PetScreen" | Out-File "lib/screens/pet_screen.dart"
"// FeedScreen" | Out-File "lib/screens/feed_screen.dart"
"// MissionsScreen" | Out-File "lib/screens/missions_screen.dart"
"// ShopScreen" | Out-File "lib/screens/shop_screen.dart"
"// DashboardScreen" | Out-File "lib/screens/dashboard_screen.dart"
"// UserProfileScreen" | Out-File "lib/screens/user_profile_screen.dart"
"// AIGenerationScreen" | Out-File "lib/screens/ai_generation_screen.dart"

# Widgets
"// PetSlots" | Out-File "lib/widgets/pet_slots.dart"
"// PetCircle" | Out-File "lib/widgets/pet_circle.dart"
"// CircularProgress" | Out-File "lib/widgets/circular_progress.dart"
"// BottomSheetBase" | Out-File "lib/widgets/bottom_sheet_base.dart"
"// AdoptionFlow" | Out-File "lib/widgets/adoption_flow.dart"
"// PetActionsSheet" | Out-File "lib/widgets/pet_actions_sheet.dart"
"// InventorySheet" | Out-File "lib/widgets/inventory_sheet.dart"
"// ChatSheet" | Out-File "lib/widgets/chat_sheet.dart"
"// NotificationBar" | Out-File "lib/widgets/notification_bar.dart"
"// FloatingParticles" | Out-File "lib/widgets/floating_particles.dart"

# Utils & Config
"// Constants" | Out-File "lib/utils/constants.dart"
"// Helpers" | Out-File "lib/utils/helpers.dart"
"// Validators" | Out-File "lib/utils/validators.dart"
"// AppTheme" | Out-File "lib/config/app_theme.dart"
"// FirebaseConfig" | Out-File "lib/config/firebase_config.dart"
"// AppRouter" | Out-File "lib/config/app_router.dart"
"// ParticleAnimations" | Out-File "lib/animations/particle_animations.dart"
"// PetAnimations" | Out-File "lib/animations/pet_animations.dart"
"// UIAnimations" | Out-File "lib/animations/ui_animations.dart"

# Main
"// Main" | Out-File "lib/main.dart"

Write-Host "Estrutura do projeto Flutter criada com sucesso!" -ForegroundColor Green
Write-Host "Total: 49 arquivos organizados em 9 diretórios" -ForegroundColor Cyan