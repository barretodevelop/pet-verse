// ========================================
// IMPLEMENTAÇÃO COMPLETA - AUTENTICAÇÃO SOCIAL
// ========================================

// 1. PROVIDER DE AUTENTICAÇÃO SIMPLIFICADO
// lib/core/providers/auth_provider.dart

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../auth/auth_middleware.dart';
import '../firebase/firestore_service.dart';

/// Estado de autenticação
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Notifier para gerenciar autenticação
class AuthNotifier extends StateNotifier<AuthState> {
  static final Logger _logger = Logger();

  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;
  final FirestoreService _firestoreService;

  AuthNotifier({
    required GoogleSignIn googleSignIn,
    required FirebaseAuth firebaseAuth,
    required FirestoreService firestoreService,
  })  : _googleSignIn = googleSignIn,
        _firebaseAuth = firebaseAuth,
        _firestoreService = firestoreService,
        super(const AuthState()) {
    _init();
  }

  /// Inicialização
  void _init() {
    // Escuta mudanças no estado de autenticação
    _firebaseAuth.authStateChanges().listen((User? user) {
      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
        isLoading: false,
        error: null,
      );

      if (user != null) {
        _logger.d('User authenticated: ${user.email}');
        _updateUserInFirestore(user);
      } else {
        _logger.d('User signed out');
      }
    });

    // Verifica usuário atual na inicialização
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      state = state.copyWith(
        user: currentUser,
        isAuthenticated: true,
      );
    }
  }

  /// Login com Google
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _logger.d('Starting Google Sign-In...');

      // 1. Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return; // Usuário cancelou
      }

      // 2. Obter credenciais do Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Criar credencial Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in no Firebase
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      _logger.i('Google Sign-In successful: ${userCredential.user?.email}');

      // Estado será atualizado automaticamente pelo listener
    } catch (error, stackTrace) {
      _logger.e('Google Sign-In failed', error: error, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(error),
      );
    }
  }

  /// Login com Apple (iOS apenas)
  Future<void> signInWithApple() async {
    if (!Platform.isIOS && !kIsWeb) {
      state = state.copyWith(
        error: 'Apple Sign-In disponível apenas no iOS',
        isLoading: false,
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);
      _logger.d('Starting Apple Sign-In...');

      // 1. Verificar disponibilidade
      final bool isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        state = state.copyWith(
          isLoading: false,
          error: 'Apple Sign-In não disponível neste dispositivo',
        );
        return;
      }

      // 2. Obter credencial Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 3. Criar credencial Firebase
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 4. Sign in no Firebase
      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);

      // 5. Atualizar nome se fornecido
      if (userCredential.user != null &&
          userCredential.user!.displayName == null &&
          appleCredential.givenName != null) {
        final displayName = [
          appleCredential.givenName,
          appleCredential.familyName,
        ].where((name) => name != null).join(' ').trim();

        if (displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
        }
      }

      _logger.i('Apple Sign-In successful: ${userCredential.user?.uid}');
    } catch (error, stackTrace) {
      _logger.e('Apple Sign-In failed', error: error, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(error),
      );
    }
  }

  /// Login anônimo (para testar)
  Future<void> signInAnonymously() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      _logger.d('Starting anonymous Sign-In...');

      await _firebaseAuth.signInAnonymously();

      _logger.i('Anonymous Sign-In successful');
    } catch (error, stackTrace) {
      _logger.e('Anonymous Sign-In failed',
          error: error, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(error),
      );
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);

      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);

      _logger.i('Sign out successful');
    } catch (error, stackTrace) {
      _logger.e('Sign out failed', error: error, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao fazer logout',
      );
    }
  }

  /// Atualiza usuário no Firestore
  Future<void> _updateUserInFirestore(User user) async {
    try {
      final authUser = AuthUser(
        id: user.uid,
        email: user.email,
        name: user.displayName,
        avatarUrl: user.photoURL,
        authType: AuthType.google, // Simplificado
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestoreService.saveUser(authUser);
      _logger.d('User updated in Firestore');
    } catch (e) {
      _logger.w('Failed to update user in Firestore: $e');
    }
  }

  /// Converte erros para mensagens amigáveis
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-disabled':
          return 'Conta desabilitada';
        case 'user-not-found':
          return 'Usuário não encontrado';
        case 'too-many-requests':
          return 'Muitas tentativas. Tente novamente mais tarde';
        case 'network-request-failed':
          return 'Erro de conexão. Verifique sua internet';
        default:
          return 'Erro de autenticação: ${error.message}';
      }
    }
    return 'Erro inesperado: $error';
  }

  /// Limpa erro
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}

/// Providers
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    scopes: ['email', 'profile'],
  );
});

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService.instance;
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    googleSignIn: ref.watch(googleSignInProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

// Providers computados para facilitar o uso
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).error;
});

/// Provider para dados do usuário formatados
final userDataProvider = Provider<Map<String, String?>>((ref) {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return {
      'name': null,
      'email': null,
      'photoUrl': null,
    };
  }

  return {
    'name': user.displayName ?? user.email?.split('@').first ?? 'Usuário',
    'email': user.email,
    'photoUrl': user.photoURL,
  };
});
