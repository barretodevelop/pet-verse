// File: lib/data/repositories/auth_repository_impl.dart

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:petverse/core/errors/exceptions.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/data/datasources/remote/firebase_auth_datasource.dart';
import 'package:petverse/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _authDatasource;

  AuthRepositoryImpl(this._authDatasource);

  @override
  Future<Either<Failure, fb_auth.User>> signInWithGoogle() async {
    try {
      final user = await _authDatasource.signInWithGoogle();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure('Unexpected error during Google sign in: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _authDatasource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, code: e.code));
    } catch (e) {
      return Left(AuthFailure('Unexpected error during sign out: $e'));
    }
  }

  @override
  fb_auth.User? getCurrentUser() {
    return _authDatasource.getCurrentUser();
  }

  @override
  Stream<fb_auth.User?> get authStateChanges {
    return _authDatasource.authStateChanges;
  }

  @override
  bool get isAuthenticated {
    return _authDatasource.isAuthenticated;
  }
}
