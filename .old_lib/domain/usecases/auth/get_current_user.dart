// File: lib/domain/usecases/auth/get_current_user.dart

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../../repositories/auth_repository.dart';

/// Use case for getting current authenticated user
class GetCurrentUser {
  final AuthRepository _authRepository;

  GetCurrentUser(this._authRepository);

  fb_auth.User? call() {
    return _authRepository.getCurrentUser();
  }
}
