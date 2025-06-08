// File: lib/data/datasources/remote/firebase_auth_datasource.dart

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petverse/core/errors/exceptions.dart';

/// Firebase Authentication datasource
abstract class FirebaseAuthDatasource {
  Future<fb_auth.User> signInWithGoogle();
  Future<void> signOut();
  fb_auth.User? getCurrentUser();
  Stream<fb_auth.User?> get authStateChanges;
  bool get isAuthenticated;
}

/// Implementation of Firebase Authentication datasource
class FirebaseAuthDatasourceImpl implements FirebaseAuthDatasource {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthDatasourceImpl({
    fb_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<fb_auth.User> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = fb_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final fb_auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthException('Failed to sign in with Google');
      }

      return userCredential.user!;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException('Firebase Auth Error: ${e.message}', code: e.code);
    } catch (e) {
      throw AuthException('Failed to sign in with Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Failed to sign out: $e');
    }
  }

  @override
  fb_auth.User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Stream<fb_auth.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  @override
  bool get isAuthenticated {
    return _firebaseAuth.currentUser != null;
  }
}
