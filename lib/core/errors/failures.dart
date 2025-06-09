// File: lib/core/errors/failures.dart

import 'package:equatable/equatable.dart';

/// Base failure class for all failures in the app
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Authentication related failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Database related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

/// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Cache related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Pet game specific failures
class PetGameFailure extends Failure {
  const PetGameFailure(super.message, {super.code});
}

/// User data related failures
class UserDataFailure extends Failure {
  const UserDataFailure(super.message, {super.code});
}

/// Transaction/Currency related failures
class TransactionFailure extends Failure {
  const TransactionFailure(super.message, {super.code});
}

/// Server related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Validation related failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

class InventoryFailure extends Failure {
  const InventoryFailure(super.message, {super.code});
}
