// File: lib/domain/usecases/auth/sign_in_with_google.dart

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../../../core/errors/failures.dart';
import '../../../core/types/either.dart';
import '../../repositories/auth_repository.dart';

/// Use case for signing in with Google
class SignInWithGoogle {
  final AuthRepository _authRepository;

  SignInWithGoogle(this._authRepository);

  Future<Either<Failure, fb_auth.User>> call() async {
    return await _authRepository.signInWithGoogle();
  }
}
