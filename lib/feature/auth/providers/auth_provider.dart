// lib/features/auth/providers/auth_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petverse/core/model/user.dart';
import 'package:petverse/core/providers/firebase_providers.dart';

// Stream do estado de autenticação
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Provider do usuário atual
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// Provider dos dados do usuário no Firestore
final userDataProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
});

// Controller de autenticação
class AuthController extends StateNotifier<AsyncValue<void>> {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthController({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _googleSignIn = googleSignIn,
        _firestore = firestore,
        super(const AsyncData(null));

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Criar documento do usuário
      await _createUserDocument(credential.user!);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      // Trigger do flow de autenticação
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // Usuário cancelou
        state = const AsyncData(null);
        return;
      }

      // Obter detalhes de autenticação
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Criar credencial
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in no Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Verificar se é novo usuário
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _createUserDocument(userCredential.user!);
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> _createUserDocument(User user) async {
    final userData = AppUser(
      id: user.uid,
      email: user.email!,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      activePets: const [],
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userData.toFirestore());
  }
}

// Provider do controller
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(
    auth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});
