// lib/feature/auth/service/authentication_service.dart
// CORRIGIDO: Usar UID correto do Firebase Auth para criar e gerenciar usuários

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petverse/core/model/user_model.dart';
import 'package:petverse/core/model/user_settings.dart';
import 'package:petverse/core/model/user_stats.dart';

class AuthenticationService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;
  final GoogleSignIn _googleSignIn;

  AuthenticationService(this._auth, this._firestore, this._analytics)
      : _googleSignIn = GoogleSignIn();

  // Retorna o usuário Firebase atualmente logado
  User? get currentUser => _auth.currentUser;

  // Retorna um Stream que emite eventos sempre que o estado de autenticação muda
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Realiza o login com e-mail e senha
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _analytics.logLogin(loginMethod: 'email');

      // MELHORADO: Garantir que o documento do usuário existe
      if (credential.user != null) {
        await createUserDocumentIfNotExists(credential.user!);
      }

      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      await _analytics.logEvent(
          name: 'login_error',
          parameters: {'error': e.toString(), 'method': 'email'});
      rethrow;
    }
  }

  // Realiza o cadastro de um novo usuário com e-mail e senha
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Atualizar o nome no Firebase Auth
      await credential.user!.updateDisplayName(displayName);
      await _analytics.logSignUp(signUpMethod: 'email');

      // MELHORADO: Criar documento do usuário automaticamente
      if (credential.user != null) {
        await createUserDocumentIfNotExists(
          credential.user!,
          displayName: displayName,
        );
      }

      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      await _analytics.logEvent(
          name: 'signup_error',
          parameters: {'error': e.toString(), 'method': 'email'});
      rethrow;
    }
  }

  // Realiza o login usando o Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // Usuário cancelou o login
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _analytics.logLogin(loginMethod: 'google');

      // MELHORADO: Garantir que o documento do usuário existe
      if (userCredential.user != null) {
        await createUserDocumentIfNotExists(userCredential.user!);
      }

      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      await _analytics.logEvent(
          name: 'login_error',
          parameters: {'error': e.toString(), 'method': 'google'});
      rethrow;
    }
  }

  // Envia um e-mail de redefinição de senha
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      await _analytics.logEvent(name: 'password_reset_requested');
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Realiza o logout do usuário (Firebase e Google)
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _analytics.logEvent(name: 'logout');
    } catch (e) {
      rethrow;
    }
  }

  // CORRIGIDO: Cria um documento de usuário no Firestore com UID correto
  Future<void> createUserDocumentIfNotExists(User user,
      {String? displayName}) async {
    try {
      print('🔄 Criando/verificando documento do usuário...');
      print('User UID: ${user.uid}'); // CORRIGIDO: Usar UID

      final userDocRef = _firestore
          .collection('users')
          .doc(user.uid); // CORRIGIDO: Usar UID como ID do documento
      final docSnapshot = await userDocRef.get();

      if (!docSnapshot.exists) {
        print('📝 Criando novo documento de usuário...');

        // CORRIGIDO: Criar UserModel com UID correto
        final newUser = UserModel(
          uid: user.uid, // CORRIGIDO: UID correto
          email: user.email,
          displayName: displayName ?? user.displayName,
          photoURL: user.photoURL,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          updatedAt: DateTime.now(),
          coins: 100, // Coins iniciais
          gems: 0,
          level: 1,
          xp: 0,
          totalXP: 0,
          unlockedSlots: 2,
          inventory: [],
          achievements: [],
          settings: const UserSettings(
            notifications: NotificationSettings(
                feeding: true,
                playing: true,
                cleaning: true,
                luckyHour: true,
                collaboration: true,
                missions: true,
                achievements: true,
                social: true),
            privacy: PrivacySettings(
              showOnlineStatus: true,
              allowCollaboration: true,
              showInLeaderboards: true,
              allowFriendRequests: true,
            ),
            gameplay: GameplaySettings(
                autoSave: true,
                soundEffects: true,
                animations: true,
                hapticFeedback: true,
                volume: 10),
          ),
          stats: UserStats(
            loginStreak: 1,
            lastLoginDate: DateTime.now(),
          ),
          isEmailVerified: user.emailVerified,
          provider: _getProviderName(user),
          petIds: [],
        );

        // CORRIGIDO: Salvar usando toFirestore() que inclui UID
        await userDocRef.set(newUser.toFirestore());
        print('✅ Documento de usuário criado com sucesso!');
      } else {
        print('✅ Documento de usuário já existe, atualizando lastLogin...');
        // Se o documento já existe, apenas atualizar o lastLogin
        await _updateLastLogin(user.uid);
        await userDocRef.update({
          'provider': _getProviderName(user),
          'isEmailVerified': user.emailVerified,
        });
      }
    } catch (e) {
      print('❌ Erro ao criar/atualizar documento do usuário: $e');
      rethrow;
    }
  }

  // CORRIGIDO: Atualiza apenas a data do último login usando UID
  Future<void> _updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        // CORRIGIDO: Usar UID
        'lastLogin': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'stats.lastLoginDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Erro ao atualizar lastLogin: $e');
      rethrow;
    }
  }

  // CORRIGIDO: Busca o UserModel do Firestore usando UID
  Future<UserModel?> getUserModel(String uid) async {
    try {
      print('🔍 Buscando UserModel para UID: $uid');

      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get(); // CORRIGIDO: Usar UID
      if (doc.exists) {
        final userModel = UserModel.fromFirestore(doc);
        print('✅ UserModel encontrado: ${userModel.displayName}');
        return userModel;
      } else {
        print('⚠️ Documento do usuário não encontrado para UID: $uid');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao buscar UserModel: $e');
      return null;
    }
  }

  // CORRIGIDO: Atualiza o saldo de moedas do usuário usando UID
  Future<void> updateCoins(String uid, int amount) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        // CORRIGIDO: Usar UID
        'coins': FieldValue.increment(amount),
        'stats.totalCoinsEarned': FieldValue.increment(amount > 0 ? amount : 0),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Erro ao atualizar coins: $e');
      rethrow;
    }
  }

  // CORRIGIDO: Atualiza a experiência (XP) e o nível do usuário usando UID
  Future<void> updateXP(String uid, int xp) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get(); // CORRIGIDO: Usar UID
      if (!userDoc.exists) {
        throw Exception('Usuário não encontrado');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final currentXP = userData['xp'] ?? 0;
      final currentLevel = userData['level'] ?? 1;
      final currentTotalXP = userData['totalXP'] ?? 0;

      final newTotalXP = currentTotalXP + xp;
      final newLevel = (newTotalXP ~/ 100) + 1; // 100 XP por nível
      final newXP = newTotalXP % 100;

      final updates = <String, dynamic>{
        'xp': newXP,
        'totalXP': newTotalXP,
        'stats.totalXPEarned': FieldValue.increment(xp),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Se subiu de nível, dar bônus de coins
      if (newLevel > currentLevel) {
        updates['level'] = newLevel;
        updates['coins'] = FieldValue.increment(50); // Bônus de nível
        await _analytics.logLevelUp(level: newLevel.toDouble());
        print('🎉 Usuário subiu para o nível $newLevel!');
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .update(updates); // CORRIGIDO: Usar UID
    } catch (e) {
      print('❌ Erro ao atualizar XP: $e');
      rethrow;
    }
  }

  // NOVO: Método para atualizar pet atual do usuário
  Future<void> updateCurrentPet(String uid, String? petId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        // CORRIGIDO: Usar UID
        'currentPetId': petId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Erro ao atualizar pet atual: $e');
      rethrow;
    }
  }

  // NOVO: Método para adicionar pet aos pets do usuário
  Future<void> addPetToUser(String uid, String petId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        // CORRIGIDO: Usar UID
        'petIds': FieldValue.arrayUnion([petId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Erro ao adicionar pet ao usuário: $e');
      rethrow;
    }
  }

  // NOVO: Método para remover pet dos pets do usuário
  Future<void> removePetFromUser(String uid, String petId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        // CORRIGIDO: Usar UID
        'petIds': FieldValue.arrayRemove([petId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Erro ao remover pet do usuário: $e');
      rethrow;
    }
  }

  // NOVO: Método para atualizar estatísticas do usuário
  Future<void> updateUserStats(
    String uid, {
    int? coinsEarned,
    int? xpEarned,
    int? missionsCompleted,
    int? petsCared,
    bool? incrementLoginStreak,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (coinsEarned != null) {
        updates['stats.totalCoinsEarned'] = FieldValue.increment(coinsEarned);
      }

      if (xpEarned != null) {
        updates['stats.totalXPEarned'] = FieldValue.increment(xpEarned);
      }

      if (missionsCompleted != null) {
        updates['stats.totalMissionsCompleted'] =
            FieldValue.increment(missionsCompleted);
      }

      if (petsCared != null) {
        updates['stats.totalPetsCared'] = FieldValue.increment(petsCared);
      }

      if (incrementLoginStreak == true) {
        updates['stats.loginStreak'] = FieldValue.increment(1);
        updates['stats.lastLoginDate'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .update(updates); // CORRIGIDO: Usar UID
    } catch (e) {
      print('❌ Erro ao atualizar estatísticas: $e');
      rethrow;
    }
  }

  // Helper para determinar o provider do usuário
  String _getProviderName(User user) {
    if (user.providerData.isNotEmpty) {
      final provider = user.providerData.first.providerId;
      switch (provider) {
        case 'google.com':
          return 'google';
        case 'password':
          return 'email';
        default:
          return provider;
      }
    }
    return 'unknown';
  }

  // NOVO: Método para verificar se usuário existe
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get(); // CORRIGIDO: Usar UID
      return doc.exists;
    } catch (e) {
      print('❌ Erro ao verificar se usuário existe: $e');
      return false;
    }
  }

  // NOVO: Método para deletar conta do usuário (GDPR compliance)
  Future<void> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Nenhum usuário logado');
      }

      // Deletar documento do Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .delete(); // CORRIGIDO: Usar UID

      // Deletar conta do Firebase Auth
      await user.delete();

      await _analytics.logEvent(name: 'account_deleted');
    } catch (e) {
      print('❌ Erro ao deletar conta: $e');
      rethrow;
    }
  }
}
