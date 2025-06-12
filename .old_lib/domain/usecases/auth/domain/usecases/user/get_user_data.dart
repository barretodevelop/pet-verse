// File: lib/domain/usecases/user/get_user_data.dart

import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/user_entity.dart';
import 'package:petverse/domain/repositories/user_repository.dart';

/// Use case for getting user data
class GetUserData {
  final UserRepository _userRepository;

  GetUserData(this._userRepository);

  Future<Either<Failure, UserEntity?>> call(String userId) async {
    return await _userRepository.getUserData(userId);
  }
}
