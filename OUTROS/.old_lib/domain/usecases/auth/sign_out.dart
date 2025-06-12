// File: lib/domain/usecases/auth/sign_out.dart

import '../../../core/errors/failures.dart';
import '../../../core/types/either.dart';
import '../../repositories/auth_repository.dart';

/// Use case for signing out current user
class SignOut {
  final AuthRepository _authRepository;

  SignOut(this._authRepository);

  Future<Either<Failure, void>> call() async {
    return await _authRepository.signOut();
  }
}
