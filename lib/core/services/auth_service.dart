// lib/core/services/auth_service.dart
// NOVO: Implementação completa do serviço de autenticação
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Exportar User para evitar conflitos de importação
export 'package:firebase_auth/firebase_auth.dart' show User;

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService(this._firebaseAuth, this._googleSignIn);

  /// Stream do estado de autenticação
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Usuário atual
  User? get currentUser => _firebaseAuth.currentUser;

  /// Login com Google
  Future<User?> signInWithGoogle() async {
    try {
      // Verificar se está em ambiente web ou móvel
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Usuário cancelou o login
        return null;
      }

      // Obter credenciais de autenticação
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Criar credencial do Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Fazer login no Firebase
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        // Salvar/atualizar dados do usuário no Firestore
        await _saveUserToFirestore(
            user, userCredential.additionalUserInfo?.isNewUser ?? false);

        debugPrint('✅ Login realizado com sucesso: ${user.email}');
        return user;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Erro FirebaseAuth: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } on Exception catch (e) {
      debugPrint('❌ Erro geral no login: $e');
      throw Exception('Erro inesperado durante o login. Tente novamente.');
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      // Fazer logout do Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Fazer logout do Firebase
      await _firebaseAuth.signOut();

      debugPrint('✅ Logout realizado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro no logout: $e');
      throw Exception('Erro ao fazer logout. Tente novamente.');
    }
  }

  /// Salvar dados do usuário no Firestore
  Future<void> _saveUserToFirestore(User user, bool isNewUser) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);

      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isNewUser) {
        // Novo usuário - criar documento completo
        userData.addAll({
          'createdAt': FieldValue.serverTimestamp(),
          'isNewUser': true,
          'totalLogins': 1,
        });

        await userDoc.set(userData);
        debugPrint('✅ Novo usuário criado no Firestore: ${user.uid}');
      } else {
        // Usuário existente - atualizar apenas dados necessários
        final docSnapshot = await userDoc.get();
        if (docSnapshot.exists) {
          final currentData = docSnapshot.data() as Map<String, dynamic>;
          userData['totalLogins'] = (currentData['totalLogins'] ?? 0) + 1;
          userData['isNewUser'] = false;
        }

        await userDoc.set(userData, SetOptions(merge: true));
        debugPrint('✅ Usuário atualizado no Firestore: ${user.uid}');
      }
    } catch (e) {
      debugPrint('❌ Erro ao salvar usuário no Firestore: $e');
      // Não propagar o erro para não interromper o fluxo de login
    }
  }

  /// Tratamento de erros específicos do Firebase Auth
  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return Exception(
            'Uma conta já existe com o mesmo email, mas com credenciais diferentes.');
      case 'invalid-credential':
        return Exception('As credenciais fornecidas são inválidas.');
      case 'operation-not-allowed':
        return Exception('Login com Google não está habilitado.');
      case 'user-disabled':
        return Exception('Esta conta foi desabilitada.');
      case 'user-not-found':
        return Exception('Nenhuma conta encontrada com este email.');
      case 'wrong-password':
        return Exception('Senha incorreta.');
      case 'invalid-verification-code':
        return Exception('Código de verificação inválido.');
      case 'invalid-verification-id':
        return Exception('ID de verificação inválido.');
      case 'network-request-failed':
        return Exception('Falha na conexão. Verifique sua internet.');
      case 'too-many-requests':
        return Exception('Muitas tentativas. Tente novamente mais tarde.');
      default:
        return Exception('Erro de autenticação: ${e.message}');
    }
  }

  /// Reautenticar usuário (útil para operações sensíveis)
  Future<bool> reauthenticateWithGoogle() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      debugPrint('❌ Erro na reautenticação: $e');
      return false;
    }
  }

  /// Deletar conta do usuário
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('Nenhum usuário logado');

      // Reautenticar antes de deletar
      final reauthenticated = await reauthenticateWithGoogle();
      if (!reauthenticated) {
        throw Exception('Reautenticação necessária para deletar a conta');
      }

      // Deletar dados do Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Deletar conta do Firebase Auth
      await user.delete();

      debugPrint('✅ Conta deletada com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao deletar conta: $e');
      throw Exception('Erro ao deletar conta: $e');
    }
  }

  /// Verificar se o usuário está logado
  bool get isLoggedIn => currentUser != null;

  /// Obter dados do usuário do Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('❌ Erro ao buscar dados do usuário: $e');
      return null;
    }
  }

  /// Atualizar dados do usuário
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('Nenhum usuário logado');

      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(user.uid).update(data);
      debugPrint('✅ Dados do usuário atualizados');
    } catch (e) {
      debugPrint('❌ Erro ao atualizar dados do usuário: $e');
      throw Exception('Erro ao atualizar dados: $e');
    }
  }
}
