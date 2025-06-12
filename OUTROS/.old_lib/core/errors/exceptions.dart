// File: lib/core/errors/exceptions.dart

/// Base exception class for all custom exceptions in the app
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code});
}

/// Firestore/Database related exceptions  
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

/// Pet game specific exceptions
class PetGameException extends AppException {
  const PetGameException(super.message, {super.code});
}

/// User data related exceptions
class UserDataException extends AppException {
  const UserDataException(super.message, {super.code});
}

/// Transaction/Currency related exceptions
class TransactionException extends AppException {
  const TransactionException(super.message, {super.code});
}

