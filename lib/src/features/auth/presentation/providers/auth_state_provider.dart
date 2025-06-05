// lib/src/features/auth/presentation/providers/auth_state_provider.dart
// CORREÇÃO - Provider de auth mais estável para evitar problemas de navegação

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/auth/data/repositories/auth_repository.dart';
import 'package:petverse/src/features/auth/domain/entities/app_user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final fb_auth.User? firebaseUser;

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

  @override
  String toString() => 'AuthState(status: $status, user: ${user?.username})';
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
  StreamSubscription<fb_auth.User?>? _authStateChangesSubscription;

  AuthStateNotifier(this._ref) : super(AuthState()) {
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    try {
      final authRepository = _ref.read(authRepositoryProvider);

      _authStateChangesSubscription = authRepository.authStateChanges.listen(
        (fbUser) {
          _handleAuthStateChange(fbUser);
        },
        onError: (error) {
          debugPrint('🚨 [AuthStateNotifier] Erro no listener: $error');
          // Em caso de erro, definir como não autenticado
          state = AuthState(status: AuthStatus.unauthenticated);
        },
      );

      debugPrint('✅ [AuthStateNotifier] Listener de auth inicializado');
    } catch (e) {
      debugPrint('🚨 [AuthStateNotifier] Erro ao inicializar listener: $e');
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }

  void _handleAuthStateChange(fb_auth.User? fbUser) {
    try {
      debugPrint('🔄 [AuthStateNotifier] Auth mudou: ${fbUser?.uid ?? "null"}');

      if (fbUser == null) {
        debugPrint('❌ [AuthStateNotifier] Usuário deslogado');
        state = AuthState(status: AuthStatus.unauthenticated);
      } else {
        debugPrint('✅ [AuthStateNotifier] Usuário logado: ${fbUser.uid}');

        final appUser = AppUser(
          id: fbUser.uid,
          username: fbUser.displayName ?? 'Usuário',
          email: fbUser.email,
          photoUrl: fbUser.photoURL,
        );

        state = AuthState(
          status: AuthStatus.authenticated,
          user: appUser,
          firebaseUser: fbUser,
        );
      }
    } catch (e) {
      debugPrint(
          '🚨 [AuthStateNotifier] Erro ao processar mudança de auth: $e');
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      debugPrint('🚀 [AuthStateNotifier] Iniciando login com Google...');

      await _ref.read(authRepositoryProvider).signInWithGoogle();

      debugPrint(
          '✅ [AuthStateNotifier] Login iniciado - aguardando resposta do listener');
      // O listener _authStateChangesSubscription vai atualizar o estado automaticamente
    } catch (e) {
      debugPrint('🚨 [AuthStateNotifier] Erro no signInWithGoogle: $e');
      // Re-throw para que a UI possa mostrar o erro
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('🚪 [AuthStateNotifier] Fazendo logout...');

      await _ref.read(authRepositoryProvider).signOut();

      debugPrint('✅ [AuthStateNotifier] Logout realizado');
      // O listener vai atualizar o estado automaticamente
    } catch (e) {
      debugPrint('🚨 [AuthStateNotifier] Erro no signOut: $e');
      // Força estado de não autenticado mesmo em caso de erro
      state = AuthState(status: AuthStatus.unauthenticated);
    }
  }

  @override
  void dispose() {
    debugPrint('🗑️ [AuthStateNotifier] Disposing...');
    _authStateChangesSubscription?.cancel();
    super.dispose();
  }
}

// Provider helper para verificar se está logado (simplificado)
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.status == AuthStatus.authenticated;
});
