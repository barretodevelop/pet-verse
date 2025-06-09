// File: lib/core/usecases/usecase.dart

import 'package:equatable/equatable.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';

/// Interface base para todos os use cases da aplicação
///
/// [Type] - O tipo de retorno do use case
/// [Params] - O tipo dos parâmetros de entrada do use case
abstract class UseCase<Type, Params> {
  /// Executa o use case com os parâmetros fornecidos
  ///
  /// Retorna [Either<Failure, Type>] onde:
  /// - Left(Failure): Em caso de erro
  /// - Right(Type): Em caso de sucesso
  Future<Either<Failure, Type>> call(Params params);
}

/// Classe para use cases que não precisam de parâmetros
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object> get props => [];
}

/// Use case base para operações síncronas
///
/// [Type] - O tipo de retorno do use case
/// [Params] - O tipo dos parâmetros de entrada do use case
abstract class SyncUseCase<Type, Params> {
  /// Executa o use case síncrono com os parâmetros fornecidos
  ///
  /// Retorna [Either<Failure, Type>] onde:
  /// - Left(Failure): Em caso de erro
  /// - Right(Type): Em caso de sucesso
  Either<Failure, Type> call(Params params);
}

/// Use case base para streams
///
/// [Type] - O tipo de retorno do stream
/// [Params] - O tipo dos parâmetros de entrada do use case
abstract class StreamUseCase<Type, Params> {
  /// Executa o use case e retorna um stream
  ///
  /// Retorna [Stream<Either<Failure, Type>>] onde cada emissão pode ser:
  /// - Left(Failure): Em caso de erro
  /// - Right(Type): Em caso de sucesso
  Stream<Either<Failure, Type>> call(Params params);
}

/// Mixin para use cases que podem ser cancelados
mixin CancellableUseCase {
  /// Cancela a execução do use case se possível
  void cancel();

  /// Verifica se o use case foi cancelado
  bool get isCancelled;
}

/// Use case base para operações em lote
///
/// [Type] - O tipo de retorno individual
/// [Params] - O tipo dos parâmetros de entrada
abstract class BatchUseCase<Type, Params> {
  /// Executa múltiplas operações em lote
  ///
  /// [paramsList] - Lista de parâmetros para executar em lote
  ///
  /// Retorna [Either<Failure, List<Type>>] onde:
  /// - Left(Failure): Em caso de erro em qualquer operação
  /// - Right(List<Type>): Lista com todos os resultados
  Future<Either<Failure, List<Type>>> callBatch(List<Params> paramsList);
}

/// Extensões úteis para Either no contexto de use cases
extension UseCaseEitherExtensions<L, R> on Either<L, R> {
  /// Executa uma função se o resultado for um sucesso (Right)
  Either<L, R> onSuccess(void Function(R value) onSuccess) {
    return fold(
      (failure) => Left(failure),
      (success) {
        onSuccess(success);
        return Right(success);
      },
    );
  }

  /// Executa uma função se o resultado for um erro (Left)
  Either<L, R> onFailure(void Function(L failure) onFailure) {
    return fold(
      (failure) {
        onFailure(failure);
        return Left(failure);
      },
      (success) => Right(success),
    );
  }

  /// Converte o resultado para um Future
  Future<Either<L, R>> toFuture() async => this;
}

/// Extensões para Future<Either>
extension UseCaseFutureEitherExtensions<L, R> on Future<Either<L, R>> {
  /// Executa uma função assíncrona se o resultado for um sucesso
  Future<Either<L, R>> onSuccessAsync(Future<void> Function(R value) onSuccess) async {
    final result = await this;
    return result.fold(
      (failure) => Left(failure),
      (success) async {
        await onSuccess(success);
        return Right(success);
      },
    );
  }

  /// Executa uma função assíncrona se o resultado for um erro
  Future<Either<L, R>> onFailureAsync(Future<void> Function(L failure) onFailure) async {
    final result = await this;
    return result.fold(
      (failure) async {
        await onFailure(failure);
        return Left(failure);
      },
      (success) => Right(success),
    );
  }

  /// Transforma o resultado de sucesso mantendo o tipo de erro
  Future<Either<L, T>> mapSuccess<T>(T Function(R value) mapper) async {
    final result = await this;
    return result.fold(
      (failure) => Left(failure),
      (success) => Right(mapper(success)),
    );
  }

  /// Transforma o resultado de erro mantendo o tipo de sucesso
  Future<Either<T, R>> mapFailure<T>(T Function(L failure) mapper) async {
    final result = await this;
    return result.fold(
      (failure) => Left(mapper(failure)),
      (success) => Right(success),
    );
  }
}

/// Helper para criar use cases simples rapidamente
class SimpleUseCase<Type, Params> implements UseCase<Type, Params> {
  final Future<Either<Failure, Type>> Function(Params params) _execute;

  const SimpleUseCase(this._execute);

  @override
  Future<Either<Failure, Type>> call(Params params) => _execute(params);
}

/// Helper para criar use cases síncronos simples
class SimpleSyncUseCase<Type, Params> implements SyncUseCase<Type, Params> {
  final Either<Failure, Type> Function(Params params) _execute;

  const SimpleSyncUseCase(this._execute);

  @override
  Either<Failure, Type> call(Params params) => _execute(params);
}

/// Constantes úteis para use cases
class UseCaseConstants {
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const int defaultRetryAttempts = 3;
  static const Duration defaultRetryDelay = Duration(seconds: 1);
}
