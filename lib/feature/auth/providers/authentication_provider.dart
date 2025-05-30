// lib/features/auth/presentation/providers/auth_notifier_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/model/user_model.dart';
import 'package:petverse/core/providers/firebase_providers.dart'; // Importe os provedores Firebase
import 'package:petverse/feature/auth/service/authentication_service.dart';
import 'package:petverse/feature/auth/state/authentication_state.dart';

// --- Authentication Notifier ---
// Gerencia o estado da autenticação para a UI, usando o AuthenticationService.
class AuthenticationNotifier extends StateNotifier<AuthenticationState> {
  final AuthenticationService _authService; // O serviço de autenticação
  final Ref
      _ref; // Referência do Riverpod para acessar outros provedores (ex: firestore)

  AuthenticationNotifier(this._authService, this._ref)
      : super(const AuthenticationState()) {
    _init(); // Inicia o listener de estado do Firebase Auth
  }

  // Configura um listener para observar mudanças no estado de autenticação do Firebase.
  void _init() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        // Se um usuário está logado, tenta carregar seu UserModel
        // (Isso também garante a criação do documento se não existir)
        await _authService.createUserDocumentIfNotExists(user);
        final userModel = await _authService.getUserModel(user.uid);
        state = state.copyWith(
            user: user, userModel: userModel, isLoading: false, error: null);
      } else {
        // Se deslogado, redefine o estado
        state = const AuthenticationState();
      }
    });
  }

  // Carrega o UserModel do Firestore (chamado internamente após login)
  Future<void> _loadUserModel(String uid) async {
    try {
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
          error: 'Erro ao carregar dados do usuário: ${e.toString()}');
    }
  }

  // --- Métodos de Autenticação para a UI ---

  // Login com e-mail e senha
  Future<void> signInWithEmail(
      {required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await _authService.signInWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        await _authService.createUserDocumentIfNotExists(
            credential.user!); // Garante doc Firestore
        await _loadUserModel(credential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e.code));
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Erro inesperado: ${e.toString()}');
    }
  }

  // Login com Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await _authService.signInWithGoogle();
      if (credential?.user != null) {
        await _authService.createUserDocumentIfNotExists(
            credential!.user!); // Garante doc Firestore
        await _loadUserModel(credential.user!.uid);
      } else {
        state = state.copyWith(
            isLoading: false,
            error: _getErrorMessage('canceled')); // Usuário cancelou
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e.code));
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Erro inesperado: ${e.toString()}');
    }
  }

  // Cadastro com e-mail e senha
  Future<void> createAccount(
      {required String email,
      required String password,
      required String displayName}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await _authService.createUserWithEmailAndPassword(
          email: email, password: password, displayName: displayName);
      if (credential.user != null) {
        await _authService.createUserDocumentIfNotExists(credential.user!,
            displayName: displayName); // Garante doc Firestore
        await _loadUserModel(credential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: _getErrorMessage(e.code));
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Erro inesperado: ${e.toString()}');
    }
  }

  // Redefinir senha
  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e.toString()));
      rethrow; // Relança para que a UI possa saber do erro
    }
  }

  // Logout
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.signOut();
      state = const AuthenticationState(); // Reseta o estado
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Erro ao fazer logout: ${e.toString()}');
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

// Provedor para o AuthenticationNotifier (o que a UI vai 'watch')
final authenticationNotifierProvider =
    StateNotifierProvider<AuthenticationNotifier, AuthenticationState>((ref) {
  final authService = ref
      .watch(authServiceProvider); // Obtém a instância do AuthenticationService
  return AuthenticationNotifier(authService, ref);
});

// Provedor para acessar o UserModel do usuário atualmente logado (convenience provider)
final currentUserModelProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authenticationNotifierProvider);
  return authState.userModel;
});
