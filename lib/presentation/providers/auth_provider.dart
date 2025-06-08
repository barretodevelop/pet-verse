// File: lib/presentation/providers/auth_provider.dart

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/domain/usecases/auth/get_current_user.dart';
import 'package:petverse/domain/usecases/auth/sign_in_with_google.dart';
import 'package:petverse/domain/usecases/auth/sign_out.dart';
import 'package:petverse/presentation/providers/dependencies_provider.dart';

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

  AuthNotifier(
    this._signInWithGoogle,
    this._signOut,
    this._getCurrentUser,
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
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: _getErrorMessage(failure),
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          firebaseUser: user,
          status: AuthStatus.authenticated,
          clearError: true,
        );
        return true;
      },
    );
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
  );
});

/// Auth stream provider for listening to auth state changes
final authStreamProvider = StreamProvider<fb_auth.User?>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});
