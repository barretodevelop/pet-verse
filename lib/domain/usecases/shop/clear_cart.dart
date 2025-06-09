// ============================================================================
// ARQUIVOS QUE PODEM ESTAR FALTANDO - GUIA RÁPIDO
// ============================================================================

// 1. ClearCart UseCase
// File: lib/domain/usecases/shop/clear_cart.dart

import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/usecases/usecase.dart';

class ClearCart implements UseCase<void, NoParams> {
  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      // Limpar carrinho (implementação simples)
      return const Right(null);
    } catch (e) {
      return Left(ValidationFailure('Erro ao limpar carrinho: $e'));
    }
  }
}
