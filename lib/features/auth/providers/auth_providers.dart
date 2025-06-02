import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petverse/core/services/auth_service.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn());
final authServiceProvider = Provider<AuthService>((ref) => AuthService(
    ref.watch(firebaseAuthProvider), ref.watch(googleSignInProvider)));
final authStateChangesProvider = StreamProvider<firebase_auth.User?>(
    (ref) => ref.watch(authServiceProvider).authStateChanges);
