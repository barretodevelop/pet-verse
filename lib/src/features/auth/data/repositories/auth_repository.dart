import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Importar Riverpod
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petverse/src/features/auth/domain/entities/app_user.dart';

// Provider para o AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(); // Instancia o AuthRepository
});

// Exceção personalizada para erros de autenticação
class SignInException implements Exception {
  final String message;
  SignInException(this.message);

  @override
  String toString() => message;
}

class AuthRepository {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    fb_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // Stream para o estado de autenticação do Firebase (já usado no AuthStateNotifier)
  Stream<fb_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  // Método de login com Google
  Future<AppUser?> signInWithGoogle() async {
    GoogleSignInAccount? googleUser;
    GoogleSignInAuthentication? googleAuth;

    try {
      debugPrint("AuthRepository: Tentando _googleSignIn.signIn()");
      googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Usuário cancelou o login
        debugPrint("AuthRepository: Login com Google cancelado pelo usuário.");
        return null;
      }
      debugPrint(
          "AuthRepository: Usuário Google obtido: ${googleUser.displayName}");
    } catch (e, s) {
      debugPrint("AuthRepository: ERRO durante _googleSignIn.signIn(): $e");
      debugPrint("AuthRepository: Stacktrace para _googleSignIn.signIn(): $s");
      throw SignInException(
          'Falha ao iniciar o login com Google: ${e.toString()}');
    }

    try {
      debugPrint("AuthRepository: Tentando googleUser.authentication");
      googleAuth =
          await googleUser.authentication; // Suspeita para PigeonUserDetails
      debugPrint(
          "AuthRepository: Autenticação Google obtida. idToken: ${googleAuth.idToken != null}, accessToken: ${googleAuth.accessToken != null}");
    } catch (e, s) {
      debugPrint("AuthRepository: ERRO durante googleUser.authentication: $e");
      debugPrint(
          "AuthRepository: Stacktrace para googleUser.authentication: $s");
      // Mesmo que isso falhe, se tivermos tokens, o Firebase pode funcionar.
      // O erro "PigeonUserDetails" geralmente significa que algo fundamental está errado aqui.
      // Vamos relançar por enquanto para ver se esta é a origem.
      throw SignInException(
          'Falha ao obter tokens de autenticação do Google: ${e.toString()}');
    }

    try {
      debugPrint("AuthRepository: Criando credencial Firebase");
      final fb_auth.AuthCredential credential =
          fb_auth.GoogleAuthProvider.credential(
        accessToken:
            googleAuth.accessToken, // Se googleAuth for null, isso falhará.
        idToken: googleAuth.idToken, // Se googleAuth for null, isso falhará.
      );

      debugPrint(
          "AuthRepository: Tentando _firebaseAuth.signInWithCredential()");
      final fb_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      debugPrint("AuthRepository: Firebase signInWithCredential bem-sucedido.");

      if (userCredential.user != null) {
        // TODO: Aqui é um bom lugar para criar/atualizar o usuário no Firestore
        // Por enquanto, apenas retornamos o AppUser mapeado do FirebaseUser
        debugPrint("AuthRepository: Mapeando usuário Firebase para AppUser.");
        return AppUser(
            id: userCredential.user!.uid,
            username: userCredential.user!.displayName ?? 'Usuário Google',
            email: userCredential.user!.email,
            photoUrl: userCredential.user!.photoURL);
      }
      debugPrint(
          "AuthRepository: Firebase userCredential.user é nulo após o login.");
      return null;
    } catch (e, s) {
      // Este catch agora é mais específico para a parte do Firebase.
      debugPrint('AuthRepository: ERRO durante credencial/login Firebase: $e');
      debugPrint('AuthRepository: Stacktrace para parte Firebase: $s');
      throw SignInException(
          'Falha ao autenticar com Firebase usando credenciais do Google: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Importante para Google Sign-In
    await _firebaseAuth.signOut();
  }

  // Método para obter o usuário Firebase atualmente logado
  // Retorna null se nenhum usuário estiver logado
  fb_auth.User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
