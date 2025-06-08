// File: lib/presentation/providers/dependencies_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petverse/data/datasources/local/local_storage_datasource.dart';
import 'package:petverse/data/datasources/remote/firestore_pet_datasource.dart';
import 'package:petverse/data/datasources/remote/firestore_user_datasource.dart';
import 'package:petverse/domain/repositories/auth_repository.dart';
import 'package:petverse/domain/repositories/pet_repository.dart';
import 'package:petverse/domain/repositories/user_repository.dart';
import 'package:petverse/domain/usecases/auth/domain/usecases/user/get_user_data.dart';
import 'package:petverse/domain/usecases/auth/get_current_user.dart';
import 'package:petverse/domain/usecases/auth/sign_in_with_google.dart';
import 'package:petverse/domain/usecases/auth/sign_out.dart';
import 'package:petverse/domain/usecases/pet/adopt_pet.dart';
import 'package:petverse/domain/usecases/pet/feed_pet.dart';
import 'package:petverse/domain/usecases/pet/play_with_pet.dart';
import 'package:petverse/domain/usecases/pet/rest_pet.dart';
import 'package:petverse/domain/usecases/user/claim_daily_reward.dart';
import 'package:petverse/domain/usecases/user/update_user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Data Sources
import '../../data/datasources/remote/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/pet_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
// Repositories

// Use Cases - Auth

// Use Cases - Pet

// Use Cases - User

// ============================================================================
// EXTERNAL DEPENDENCIES
// ============================================================================

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<fb_auth.FirebaseAuth>((ref) {
  return fb_auth.FirebaseAuth.instance;
});

/// Google Sign In instance provider
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn();
});

/// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Shared Preferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

// ============================================================================
// DATA SOURCES
// ============================================================================

/// Firebase Auth datasource provider
final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  return FirebaseAuthDatasourceImpl(
    firebaseAuth: ref.read(firebaseAuthProvider),
    googleSignIn: ref.read(googleSignInProvider),
  );
});

/// Firestore User datasource provider
final firestoreUserDatasourceProvider = Provider<FirestoreUserDatasource>((ref) {
  return FirestoreUserDatasourceImpl(
    firestore: ref.read(firestoreProvider),
  );
});

/// Firestore Pet datasource provider
final firestorePetDatasourceProvider = Provider<FirestorePetDatasource>((ref) {
  return FirestorePetDatasourceImpl(
    firestore: ref.read(firestoreProvider),
  );
});

/// Local Storage datasource provider
final localStorageProvider = Provider<LocalStorageDatasource>((ref) {
  return LocalStorageDatasourceImpl(
    ref.read(sharedPreferencesProvider),
  );
});

// ============================================================================
// REPOSITORIES
// ============================================================================

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(firebaseAuthDatasourceProvider),
  );
});

/// User repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    ref.read(firestoreUserDatasourceProvider),
    ref.read(localStorageProvider),
  );
});

/// Pet repository provider
final petRepositoryProvider = Provider<PetRepository>((ref) {
  return PetRepositoryImpl(
    ref.read(firestorePetDatasourceProvider),
  );
});

// ============================================================================
// USE CASES - AUTH
// ============================================================================

/// Sign in with Google use case provider
final signInWithGoogleProvider = Provider<SignInWithGoogle>((ref) {
  return SignInWithGoogle(ref.read(authRepositoryProvider));
});

/// Sign out use case provider
final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.read(authRepositoryProvider));
});

/// Get current user use case provider
final getCurrentUserProvider = Provider<GetCurrentUser>((ref) {
  return GetCurrentUser(ref.read(authRepositoryProvider));
});

// ============================================================================
// USE CASES - USER
// ============================================================================

/// Get user data use case provider
final getUserDataProvider = Provider<GetUserData>((ref) {
  return GetUserData(ref.read(userRepositoryProvider));
});

/// Update user data use case provider
final updateUserDataProvider = Provider<UpdateUserData>((ref) {
  return UpdateUserData(ref.read(userRepositoryProvider));
});

/// Claim daily reward use case provider
final claimDailyRewardProvider = Provider<ClaimDailyReward>((ref) {
  return ClaimDailyReward(ref.read(userRepositoryProvider));
});

// ============================================================================
// USE CASES - PET
// ============================================================================

/// Adopt pet use case provider
final adoptPetProvider = Provider<AdoptPet>((ref) {
  return AdoptPet(
    ref.read(petRepositoryProvider),
    ref.read(userRepositoryProvider),
  );
});

/// Feed pet use case provider
final feedPetProvider = Provider<FeedPet>((ref) {
  return FeedPet(
    ref.read(petRepositoryProvider),
    ref.read(userRepositoryProvider),
  );
});

/// Play with pet use case provider
final playWithPetProvider = Provider<PlayWithPet>((ref) {
  return PlayWithPet(
    ref.read(petRepositoryProvider),
    ref.read(userRepositoryProvider),
  );
});

/// Rest pet use case provider
final restPetProvider = Provider<RestPet>((ref) {
  return RestPet(
    ref.read(petRepositoryProvider),
    ref.read(userRepositoryProvider),
  );
});

// ============================================================================
// UTILITY PROVIDERS
// ============================================================================

/// Navigation provider for bottom navigation
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Loading overlay provider
final loadingOverlayProvider = StateProvider<bool>((ref) => false);

/// Snackbar message provider
final snackbarMessageProvider = StateProvider<String?>((ref) => null);

// ============================================================================
// PROVIDER OVERRIDES FOR TESTING
// ============================================================================

/// Provider overrides for testing purposes
class TestProviderOverrides {
  static List<Override> get overrides => [
        // Override with mock implementations for testing
        firebaseAuthProvider.overrideWithValue(MockFirebaseAuth()),
        firestoreProvider.overrideWithValue(MockFirestore()),
        // Add more overrides as needed
      ];
}

/// Mock Firebase Auth for testing
class MockFirebaseAuth implements fb_auth.FirebaseAuth {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock Firestore for testing
class MockFirestore implements FirebaseFirestore {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ============================================================================
// INITIALIZATION HELPERS
// ============================================================================

/// Initialize all providers that need async setup
class ProvidersInitializer {
  static Future<List<Override>> initialize() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    return [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ];
  }
}

// ============================================================================
// PROVIDER OBSERVERS FOR DEBUGGING
// ============================================================================

/// Provider observer for debugging
class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    // Log provider updates in debug mode
    if (kDebugMode) {
      print('Provider Updated: ${provider.name ?? provider.runtimeType}');
    }
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    // Log provider disposal in debug mode
    if (kDebugMode) {
      print('Provider Disposed: ${provider.name ?? provider.runtimeType}');
    }
  }
}

/// Debug mode flag
const bool kDebugMode = bool.fromEnvironment('dart.vm.product') == false;
