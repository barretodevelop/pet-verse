// File: lib/domain/usecases/user/update_user_data.dart

import '../../../core/errors/failures.dart';
import '../../../core/types/either.dart';
import '../../repositories/user_repository.dart';

/// Parameters for updating user data
class UpdateUserDataParams {
  final String userId;
  final Map<String, dynamic> data;

  UpdateUserDataParams({
    required this.userId,
    required this.data,
  });
}

/// Use case for updating user data
class UpdateUserData {
  final UserRepository _userRepository;

  UpdateUserData(this._userRepository);

  Future<Either<Failure, void>> call(UpdateUserDataParams params) async {
    return await _userRepository.updateUser(params.userId, params.data);
  }
}
