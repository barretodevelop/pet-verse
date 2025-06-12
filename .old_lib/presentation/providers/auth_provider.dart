// File: lib/presentation/providers/auth_provider.dart

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/app_config.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/domain/entities/user_entity.dart';
import 'package:petverse/domain/usecases/auth/get_current_user.dart';
import 'package:petverse/domain/usecases/auth/sign_in_with_google.dart';
import 'package:petverse/domain/usecases/auth/sign_out.dart';
import 'package:petverse/presentation/providers/dependencies_provider.dart';
import 'package:petverse/presentation/providers/user_provider.dart';

/// Authentication state class
class AuthState {
  final fb_auth.User? firebaseUser;
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    this.firebaseUser,
    this.status = AuthStatus.unauthenticated,
    this.errorMessage,
  });

  AuthState copyWith({
    fb_auth.User? firebaseUser,
    AuthStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => errorMessage != null;
}

/// Auth provider notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;
  final Ref _ref; // ✅ ADICIONAR REF

  AuthNotifier(
    this._signInWithGoogle,
    this._signOut,
    this._getCurrentUser,
    this._ref, // ✅ ADICIONAR REF
  ) : super(const AuthState()) {
    _init();
  }

  void _init() {
    // Check if user is already authenticated
    final currentUser = _getCurrentUser();
    if (currentUser != null) {
      state = state.copyWith(
        firebaseUser: currentUser,
        status: AuthStatus.authenticated,
      );
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading, clearError: true);

    final result = await _signInWithGoogle();

    return result.fold(
      (failure) {
        print('❌ AUTH: Sign in failed: ${failure.message}');
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: _getErrorMessage(failure),
        );
        return false;
      },
      (user) async {
        print('✅ AUTH: Firebase user obtained: ${user.uid}');
        print('  - Email: ${user.email}');
        print('  - Name: ${user.displayName}');
        state = state.copyWith(
          firebaseUser: user,
          status: AuthStatus.authenticated,
          clearError: true,
        );

        // ✅ CRIAR USUÁRIO NO FIRESTORE APÓS LOGIN
        print('🔄 AUTH: About to create/update user in Firestore...');

        try {
          await _createOrUpdateUserInFirestore(user);
          print('✅ AUTH: User creation/update completed');
        } catch (e) {
          print('❌ AUTH: User creation failed: $e');
        }

        return true;
      },
    );
  }

  // ✅ NOVO MÉTODO PARA CRIAR USUÁRIO NO FIRESTORE
  Future<void> _createOrUpdateUserInFirestore(fb_auth.User firebaseUser) async {
    try {
      print('🔄 Creating/updating user in Firestore...');

      final userRepository = _ref.read(userRepositoryProvider);

      // Verificar se usuário já existe
      final existingUserResult = await userRepository.getUserData(firebaseUser.uid);

      existingUserResult.fold(
        (failure) {
          print('❌ Error checking existing user: ${failure.message}');
        },
        (existingUser) async {
          if (existingUser == null) {
            // ✅ USUÁRIO NÃO EXISTE - CRIAR NOVO
            print('📝 Creating new user in Firestore...');

            final newUser = UserEntity(
              id: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              displayName: firebaseUser.displayName ?? 'User',
              photoURL: firebaseUser.photoURL,
              createdAt: DateTime.now(),
              lastLoginAt: DateTime.now(),
              totalXp: AppConfig.initialXp,
              level: AppConfig.initialLevel,
              coins: AppConfig.initialCoins,
              gems: AppConfig.initialGems,
              achievements: const [],
              loginStreak: 1,
              preferences: const {},
            );

            final createResult = await userRepository.createUser(newUser);

            createResult.fold(
              (failure) {
                print('❌ Failed to create user: ${failure.message}');
              },
              (_) {
                print('✅ User created successfully in Firestore');
                // ✅ TRIGGERAR RELOAD DO USER PROVIDER
                _ref.invalidate(userGameDataProvider);
              },
            );
          } else {
            // ✅ USUÁRIO JÁ EXISTE - ATUALIZAR ÚLTIMO LOGIN
            print('🔄 Updating existing user last login...');

            final updateResult = await userRepository.updateUser(
              firebaseUser.uid,
              {
                'lastLoginAt': DateTime.now(),
                'loginStreak': existingUser.loginStreak + 1,
              },
            );

            updateResult.fold(
              (failure) {
                print('❌ Failed to update user: ${failure.message}');
              },
              (_) {
                print('✅ User updated successfully');
                // ✅ TRIGGERAR RELOAD DO USER PROVIDER
                _ref.invalidate(userGameDataProvider);
              },
            );
          }
        },
      );
    } catch (e) {
      print('❌ Error in _createOrUpdateUserInFirestore: $e');
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _signOut();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: _getErrorMessage(failure),
        );
      },
      (_) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case AuthFailure:
        return failure.message;
      case NetworkFailure:
        return 'Please check your internet connection';
      default:
        return 'An unexpected error occurred';
    }
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(signInWithGoogleProvider),
    ref.read(signOutProvider),
    ref.read(getCurrentUserProvider),
    ref, // ✅ PASSAR REF
  );
});

/// Auth stream provider for listening to auth state changes
final authStreamProvider = StreamProvider<fb_auth.User?>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});
