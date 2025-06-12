import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petverse/models/user_model.dart';
import 'package:petverse/services/firestore_service.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn();
  static final _firestore = FirestoreService();

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // Check if user exists in Firestore
      final UserModel? existingUser =
          await _firestore.getUser(firebaseUser.uid);
      if (existingUser != null) return existingUser;

      // Create new user
      final newUser = UserModel(
        id: firebaseUser.uid,
        username: firebaseUser.displayName ?? 'Usuário Petverse',
        avatar: firebaseUser.photoURL ?? '👨',
        email: firebaseUser.email ?? '',
        level: 1,
        xp: 0,
        coins: 200,
        gems: 20,
        createdAt: DateTime.now(),
        ownedPetIds: [],
        aiConfig: {
          'apiUrl': '',
          'apiKey': '',
          'enabled': false
        }, // Default AI config
      );

      await _firestore.createUser(newUser);
      return newUser;
    } catch (e) {
      print('[AuthService.signInWithGoogle] Error: $e');
      return null;
    }
  }

  static Future<UserModel?> getOrCreateUserInFirestore(User user) async {
    try {
      // Check if user exists in Firestore
      final UserModel? existingUser = await _firestore.getUser(user.uid);
      if (existingUser != null) {
        print(
            '[AuthService.getOrCreateUserInFirestore] User ${user.uid} data successfully fetched: ${existingUser.username}');
        return existingUser;
      }

      // Create new user if not found
      print(
          '[AuthService.getOrCreateUserInFirestore] User ${user.uid} not found. Creating new document.');
      final newUser = UserModel(
        id: user.uid,
        username: user.displayName ?? 'Usuário Petverse',
        avatar: user.photoURL ?? '👨', // Default avatar
        email: user.email ?? '',
        level: 1,
        xp: 0,
        coins: 200, // Initial coins
        gems: 20, // Initial gems
        createdAt: DateTime.now(),
        ownedPetIds: [],
        aiConfig: {
          'apiUrl': '',
          'apiKey': '',
          'enabled': false
        }, // Default AI config
      );

      await _firestore.createUser(newUser);
      print(
          '[AuthService.getOrCreateUserInFirestore] New user ${newUser.username} (ID: ${newUser.id}) created.');
      return newUser;
    } catch (e) {
      print(
          '[AuthService.getOrCreateUserInFirestore] Error for user ${user.uid}: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
