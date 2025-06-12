// File: lib/domain/repositories/auth_repository.dart

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Sign in with Google
  Future<Either<Failure, fb_auth.User>> signInWithGoogle();

  /// Sign out current user
  Future<Either<Failure, void>> signOut();

  /// Get current authenticated user
  fb_auth.User? getCurrentUser();

  /// Stream of authentication state changes
  Stream<fb_auth.User?> get authStateChanges;

  /// Check if user is authenticated
  bool get isAuthenticated;
}
