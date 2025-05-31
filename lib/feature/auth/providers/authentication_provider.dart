// lib/feature/auth/providers/authentication_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/model/user_model.dart';
import 'package:petverse/core/providers/firebase_providers.dart';
import 'package:petverse/feature/auth/service/authentication_service.dart';
import 'package:petverse/feature/auth/state/authentication_state.dart';

// --- Authentication Notifier ---
class AuthenticationNotifier extends StateNotifier<AuthenticationState> {
  final AuthenticationService _authService;
  final Ref _ref;

  AuthenticationNotifier(this._authService, this._ref)
      : super(const AuthenticationState()) {
    _init();
  }

  // Configura um listener para observar mudanças no estado de autenticação
  void _init() {
    _authService.authStateChanges.listen((user) async {
      await _handleAuthStateChange(user);
    });
  }

  // Manipula mudanças no estado de autenticação
  Future<void> _handleAuthStateChange(User? user) async {
    if (user != null) {
      try {
        // Define estado de loading enquanto carrega dados
        state = state.copyWith(
          user: user,
          userModel: null,
          isLoading: true,
          error: null,
        );

        // Garante que o documento existe no Firestore
        await _authService.createUserDocumentIfNotExists(user);

        // Carrega o UserModel
        final userModel = await _authService.getUserModel(user.uid);

        // Define estado final com usuário autenticado
        state = state.copyWith(
          user: user,
          userModel: userModel,
          isLoading: false,
          error: null,
        );
      } catch (e) {
        // Em caso de erro, mantém o user mas sem userModel
        state = state.copyWith(
          user: user,
          userModel: null,
          isLoading: false,
          error: 'Erro ao carregar dados do usuário: ${e.toString()}',
        );
      }
    } else {
      // Usuário deslogado
      state = const AuthenticationState(
        user: null,
        userModel: null,
        isLoading: false,
        error: null,
      );
    }
  }

  // Carrega o UserModel do Firestore
  Future<void> _loadUserModel(String uid) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final userModel = await _authService.getUserModel(uid);

      state = state.copyWith(
        user: _authService.currentUser,
        userModel: userModel,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar dados do usuário: ${e.toString()}',
      );
    }
  }

  // Força o reload do userModel
  Future<void> refreshUserModel() async {
    if (state.user != null) {
      await _loadUserModel(state.user!.uid);
    }
  }

  // --- Métodos de Autenticação ---

  // Login com e-mail e senha
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // O _handleAuthStateChange será chamado automaticamente
        // pelo listener do authStateChanges
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e.code),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro inesperado: ${e.toString()}',
      );
    }
  }

  // Login com Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = await _authService.signInWithGoogle();

      if (credential?.user != null) {
        // O _handleAuthStateChange será chamado automaticamente
      } else {
        state = state.copyWith(
          isLoading: false,
          error: _getErrorMessage('canceled'),
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e.code),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro inesperado: ${e.toString()}',
      );
    }
  }

  // Cadastro com e-mail e senha
  Future<void> createAccount({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (credential.user != null) {
        // O _handleAuthStateChange será chamado automaticamente
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e.code),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro inesperado: ${e.toString()}',
      );
    }
  }

  // Redefinir senha
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e.toString()));
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.signOut();
      // O state será resetado automaticamente pelo _handleAuthStateChange
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao fazer logout: ${e.toString()}',
      );
    }
  }

  // Tradutor de mensagens de erro
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Esta conta foi desabilitada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      case 'account-exists-with-different-credential':
        return 'Uma conta já existe com este e-mail usando outro método de login.';
      case 'canceled':
        return 'Operação cancelada.';
      default:
        return 'Erro de autenticação: $code';
    }
  }
}

// Provedor para o AuthenticationNotifier
final authenticationNotifierProvider =
    StateNotifierProvider<AuthenticationNotifier, AuthenticationState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthenticationNotifier(authService, ref);
});

// Provedor para acessar o UserModel do usuário atualmente logado
final currentUserModelProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authenticationNotifierProvider);
  return authState.userModel;
});

// Provedor para verificar se está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authenticationNotifierProvider);
  return authState.isAuthenticated;
});

// Provedor para o Firebase User
final currentFirebaseUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authenticationNotifierProvider);
  return authState.user;
});

// Provedor para estado de loading da autenticação
final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authenticationNotifierProvider);
  return authState.isLoading;
});

// Provedor para erros de autenticação
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authenticationNotifierProvider);
  return authState.error;
});
