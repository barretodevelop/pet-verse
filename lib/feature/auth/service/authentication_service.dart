// lib/features/auth/services/authentication_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petverse/core/model/user_model.dart'; // Importe o UserModel

class AuthenticationService {
  final FirebaseAuth _auth; // Instância do Firebase Authentication
  final FirebaseFirestore _firestore; // Instância do Cloud Firestore
  final FirebaseAnalytics
      _analytics; // Instância do Firebase Analytics para logs
  final GoogleSignIn _googleSignIn; // Instância do GoogleSignIn

  // Construtor: as dependências são injetadas (recebidas de fora)
  AuthenticationService(this._auth, this._firestore, this._analytics)
      : _googleSignIn = GoogleSignIn();

  // Retorna o usuário Firebase atualmente logado.
  User? get currentUser => _auth.currentUser;

  // Retorna um Stream que emite eventos sempre que o estado de autenticação muda no Firebase.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Realiza o login com e-mail e senha.
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
      // A atualização do último login e a criação do documento Firestore serão feitas no Notifier
      return credential;
    } on FirebaseAuthException {
      rethrow; // Relança a exceção para ser tratada em camadas superiores
    } catch (e) {
      await _analytics.logEvent(
          name: 'login_error',
          parameters: {'error': e.toString(), 'method': 'email'});
      rethrow;
    }
  }

  // Realiza o cadastro de um novo usuário com e-mail e senha.
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
      await credential.user!
          .updateDisplayName(displayName); // Atualiza o nome no Firebase Auth
      await _analytics.logSignUp(signUpMethod: 'email');
      // A criação do documento Firestore será feita no Notifier
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

  // Realiza o login usando o Google.
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
      // A atualização do último login e a criação do documento Firestore serão feitas no Notifier
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

  // Envia um e-mail de redefinição de senha.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      await _analytics.logEvent(name: 'password_reset_requested');
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // Realiza o logout do usuário (Firebase e Google).
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn
          .signOut(); // Importante para deslogar do Google também
      await _analytics.logEvent(name: 'logout');
    } catch (e) {
      rethrow;
    }
  }

  // Cria um documento de usuário no Firestore se ele não existir, ou o atualiza.
  Future<void> createUserDocumentIfNotExists(User user,
      {String? displayName}) async {
    final userDocRef = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDocRef.get();

    if (!docSnapshot.exists) {
      // Se o documento não existe, cria um novo
      final userData = {
        'uid': user.uid,
        'email': user.email,
        'displayName': displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'coins': 100, // Initial coins
        'gems': 0,
        'level': 1,
        'xp': 0,
        'totalXP': 0,
        'unlockedSlots': 2,
        'inventory': [],
        'achievements': [],
        'settings': {
          'notifications': {
            'feeding': true,
            'playing': true,
            'cleaning': true,
            'luckyHour': true,
            'collaboration': true,
          },
          'privacy': {
            'showOnlinStatus': true,
            'allowCollaboration': true,
          },
          'gameplay': {
            'autoSave': true,
            'soundEffects': true,
            'animations': true,
          }
        },
        'stats': {
          'totalPetsCared': 0,
          'totalCoinsEarned': 0,
          'totalXPEarned': 0,
          'totalMissionsCompleted': 0,
          'totalAchievementsUnlocked': 0,
          'totalTimeSpent': 0,
          'loginStreak': 1,
          'lastLoginDate': FieldValue.serverTimestamp(),
        },
        'isEmailVerified': user.emailVerified,
        'provider': 'email',
        'petIds': [],
      };
      // Converte o modelo para Map para salvar no Firestore

      await userDocRef.set(userData);
    } else {
      // Se o documento já existe, apenas atualiza o lastLogin e provider
      await _updateLastLogin(user.uid);
      await userDocRef.update({
        'provider': user.providerData.isNotEmpty
            ? user.providerData[0].providerId
            : 'unknown',
      });
    }
  }

  // Atualiza apenas a data do último login do usuário no Firestore.
  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
      'stats.lastLoginDate': FieldValue.serverTimestamp(),
    });
  }

  // Busca o UserModel do Firestore para um dado UID.
  Future<UserModel?> getUserModel(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data());
    }
    return null;
  }

  // Atualiza o saldo de moedas do usuário.
  Future<void> updateCoins(String uid, int amount) async {
    await _firestore.collection('users').doc(uid).update({
      'coins': FieldValue.increment(amount),
      'stats.totalCoinsEarned': FieldValue.increment(amount > 0 ? amount : 0),
    });
  }

  // Atualiza a experiência (XP) e o nível do usuário.
  Future<void> updateXP(String uid, int xp) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final currentXP = userDoc.data()?['xp'] ?? 0;
    final currentLevel = userDoc.data()?['level'] ?? 1;
    final newXP = currentXP + xp;
    final newLevel = (newXP ~/ 100) + 1; // Supondo 100 XP por nível

    final updates = <String, dynamic>{
      'xp': newXP % 100, // XP restante para o próximo nível
      'totalXP': FieldValue.increment(xp),
      'stats.totalXPEarned': FieldValue.increment(xp),
    };

    if (newLevel > currentLevel) {
      updates['level'] = newLevel;
      updates['coins'] = FieldValue.increment(50); // Bônus de nível
      await _analytics.logLevelUp(level: newLevel.toDouble());
    }

    await _firestore.collection('users').doc(uid).update(updates);
  }
}
