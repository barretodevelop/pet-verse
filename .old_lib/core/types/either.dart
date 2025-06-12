
// File: lib/core/types/either.dart

/// Represents a value that can be either a failure or a success
abstract class Either<L, R> {
  const Either();
  
  /// Returns true if this is a Left (failure)
  bool get isLeft;
  
  /// Returns true if this is a Right (success)
  bool get isRight;
  
  /// Fold the either into a single value
  T fold<T>(T Function(L failure) onLeft, T Function(R success) onRight);
  
  /// Get the left value (failure) or null
  L? get leftOrNull;
  
  /// Get the right value (success) or null
  R? get rightOrNull;
}

/// Left side of Either (failure)
class Left<L, R> extends Either<L, R> {
  final L value;
  
  const Left(this.value);
  
  @override
  bool get isLeft => true;
  
  @override
  bool get isRight => false;
  
  @override
  T fold<T>(T Function(L failure) onLeft, T Function(R success) onRight) {
    return onLeft(value);
  }
  
  @override
  L? get leftOrNull => value;
  
  @override
  R? get rightOrNull => null;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Left && runtimeType == other.runtimeType && value == other.value;
  
  @override
  int get hashCode => value.hashCode;
  
  @override
  String toString() => 'Left($value)';
}

/// Right side of Either (success)
class Right<L, R> extends Either<L, R> {
  final R value;
  
  const Right(this.value);
  
  @override
  bool get isLeft => false;
  
  @override
  bool get isRight => true;
  
  @override
  T fold<T>(T Function(L failure) onLeft, T Function(R success) onRight) {
    return onRight(value);
  }
  
  @override
  L? get leftOrNull => null;
  
  @override
  R? get rightOrNull => value;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Right && runtimeType == other.runtimeType && value == other.value;
  
  @override
  int get hashCode => value.hashCode;
  
  @override
  String toString() => 'Right($value)';
}