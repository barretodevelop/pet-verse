// lib/features/auth/providers/auth_providers.dart
// ALTERADO: Providers corrigidos para usar o AuthService completo
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petverse/core/services/auth_service.dart';

// Provider para Firebase Auth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Provider para Google Sign In
final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );
});

// Provider para Auth Service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.watch(firebaseAuthProvider),
    ref.watch(googleSignInProvider),
  );
});

// Provider para o stream de mudanças de autenticação
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Provider para o usuário atual
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.asData?.value;
});

// Provider para verificar se o usuário está logado
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Provider para dados do usuário do Firestore
final userDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getUserData();
});

// Notifier para operações de autenticação
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  final AuthService _authService;

  /// Login com Google
  Future<User?> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final user = await _authService.signInWithGoogle();
      state = const AsyncValue.data(null);
      return user;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Logout
  Future<void> signOut() async {
    state = const AsyncValue.loading();

    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Deletar conta
  Future<void> deleteAccount() async {
    state = const AsyncValue.loading();

    try {
      await _authService.deleteAccount();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  /// Atualizar dados do usuário
  Future<void> updateUserData(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();

    try {
      await _authService.updateUserData(data);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

// Provider para o AuthNotifier
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

// Provider para verificar se é um novo usuário
final isNewUserProvider = FutureProvider<bool>((ref) async {
  final userData = await ref.watch(userDataProvider.future);
  return userData?['isNewUser'] ?? false;
});

// Provider para contagem de logins
final totalLoginsProvider = FutureProvider<int>((ref) async {
  final userData = await ref.watch(userDataProvider.future);
  return userData?['totalLogins'] ?? 0;
});
