import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/auth/data/repositories/auth_repository.dart';
import 'package:petverse/src/features/auth/domain/entities/app_user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AppUser? user; // Nosso modelo AppUser
  final fb_auth.User? firebaseUser; // O User do Firebase Auth

  AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.firebaseUser,
  });

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    fb_auth.User? firebaseUser,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      firebaseUser: firebaseUser ?? this.firebaseUser,
    );
  }
}

final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  late final StreamSubscription<fb_auth.User?> _authStateChangesSubscription;

  AuthStateNotifier(this._ref) : super(AuthState()) {
    final authRepository = _ref.read(authRepositoryProvider);
    _authStateChangesSubscription =
        authRepository.authStateChanges.listen((fbUser) {
      debugPrint('Auth state changed: ${fbUser?.uid}');
      if (fbUser == null) {
        state = AuthState(status: AuthStatus.unauthenticated);
      } else {
        // TODO: Buscar/criar AppUser no Firestore aqui na FASE 1
        final appUser = AppUser(
            id: fbUser.uid,
            username: fbUser.displayName ?? 'Usuário',
            email: fbUser.email,
            photoUrl: fbUser.photoURL);
        state = AuthState(
            status: AuthStatus.authenticated,
            user: appUser,
            firebaseUser: fbUser);
      }
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      await _ref.read(authRepositoryProvider).signInWithGoogle();
      // O listener _authStateChangesSubscription cuidará de atualizar o estado
      // para authenticated se o login for bem-sucedido.
    } catch (e) {
      // O AuthState não muda, mas podemos querer mostrar um erro na UI.
      // Isso pode ser tratado na LoginScreen observando um estado de erro.
      debugPrint("Erro no signInWithGoogle (notifier): $e");
      // Re-throw a exceção para que a UI possa capturá-la e mostrar uma mensagem.
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
  }

  @override
  void dispose() {
    _authStateChangesSubscription.cancel();
    super.dispose();
  }
}
