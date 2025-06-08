// File: lib/core/dependency_injection/dependency_injection.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petverse/data/datasources/local/local_storage_datasource.dart';
import 'package:petverse/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:petverse/data/datasources/remote/firestore_pet_datasource.dart';
import 'package:petverse/data/datasources/remote/firestore_user_datasource.dart';
import 'package:petverse/data/repositories/auth_repository_impl.dart';
import 'package:petverse/data/repositories/pet_repository_impl.dart';
import 'package:petverse/data/repositories/user_repository_impl.dart';
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
import 'package:petverse/services/analytics_service.dart';
import 'package:petverse/services/firebase_service.dart';
import 'package:petverse/services/game_data_service.dart';
import 'package:petverse/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Repositories

// Use Cases

// Services

/// Dependency injection container using GetIt
final GetIt getIt = GetIt.instance;

/// Initialize all dependencies for the application
class DependencyInjection {
  /// Setup all dependencies
  static Future<void> initialize() async {
    await _registerExternalDependencies();
    _registerDataSources();
    _registerRepositories();
    _registerUseCases();
    _registerServices();
  }

  /// Register external dependencies that require async initialization
  static Future<void> _registerExternalDependencies() async {
    // Shared Preferences
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);

    // Firebase instances
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
    getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  }

  /// Register data sources
  static void _registerDataSources() {
    // Remote data sources
    getIt.registerLazySingleton<FirebaseAuthDatasource>(
      () => FirebaseAuthDatasourceImpl(
        firebaseAuth: getIt<FirebaseAuth>(),
        googleSignIn: getIt<GoogleSignIn>(),
      ),
    );

    getIt.registerLazySingleton<FirestoreUserDatasource>(
      () => FirestoreUserDatasourceImpl(
        firestore: getIt<FirebaseFirestore>(),
      ),
    );

    getIt.registerLazySingleton<FirestorePetDatasource>(
      () => FirestorePetDatasourceImpl(
        firestore: getIt<FirebaseFirestore>(),
      ),
    );

    // Local data source
    getIt.registerLazySingleton<LocalStorageDatasource>(
      () => LocalStorageDatasourceImpl(getIt<SharedPreferences>()),
    );
  }

  /// Register repositories
  static void _registerRepositories() {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<FirebaseAuthDatasource>()),
    );

    getIt.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(
        getIt<FirestoreUserDatasource>(),
        getIt<LocalStorageDatasource>(),
      ),
    );

    getIt.registerLazySingleton<PetRepository>(
      () => PetRepositoryImpl(getIt<FirestorePetDatasource>()),
    );
  }

  /// Register use cases
  static void _registerUseCases() {
    // Auth use cases
    getIt.registerLazySingleton(() => SignInWithGoogle(getIt<AuthRepository>()));
    getIt.registerLazySingleton(() => SignOut(getIt<AuthRepository>()));
    getIt.registerLazySingleton(() => GetCurrentUser(getIt<AuthRepository>()));

    // User use cases
    getIt.registerLazySingleton(() => GetUserData(getIt<UserRepository>()));
    getIt.registerLazySingleton(() => UpdateUserData(getIt<UserRepository>()));
    getIt.registerLazySingleton(() => ClaimDailyReward(getIt<UserRepository>()));

    // Pet use cases
    getIt.registerLazySingleton(() => AdoptPet(
          getIt<PetRepository>(),
          getIt<UserRepository>(),
        ));
    getIt.registerLazySingleton(() => FeedPet(
          getIt<PetRepository>(),
          getIt<UserRepository>(),
        ));
    getIt.registerLazySingleton(() => PlayWithPet(
          getIt<PetRepository>(),
          getIt<UserRepository>(),
        ));
    getIt.registerLazySingleton(() => RestPet(
          getIt<PetRepository>(),
          getIt<UserRepository>(),
        ));
  }

  /// Register services
  static void _registerServices() {
    getIt.registerLazySingleton(() => FirebaseService());
    getIt.registerLazySingleton(() => GameDataService());
    getIt.registerLazySingleton(() => AnalyticsService());
    getIt.registerLazySingleton(() => NotificationService());
  }

  /// Clean up all dependencies
  static Future<void> dispose() async {
    await getIt.reset();
  }
}
