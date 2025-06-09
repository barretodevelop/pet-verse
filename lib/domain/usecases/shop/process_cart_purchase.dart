// File: lib/domain/usecases/shop/process_cart_purchase.dart

import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/user_entity.dart';
import 'package:petverse/domain/repositories/inventory_repository.dart';
import 'package:petverse/domain/repositories/user_repository.dart';
import 'package:petverse/domain/usecases/usecase.dart';
import 'package:petverse/entities/cart_item_entity.dart';

class ProcessCartPurchase implements UseCase<PurchaseResult, ProcessCartPurchaseParams> {
  final UserRepository _userRepository;
  final InventoryRepository _inventoryRepository;

  ProcessCartPurchase(this._userRepository, this._inventoryRepository);

  @override
  Future<Either<Failure, PurchaseResult>> call(ProcessCartPurchaseParams params) async {
    try {
      // === VALIDAÇÕES ===
      if (params.cartItems.isEmpty) {
        return const Left(ValidationFailure('Carrinho vazio'));
      }

      // Calcular totais por moeda
      final totals = _calculateTotals(params.cartItems);
      final coinsNeeded = totals[CurrencyType.coins] ?? 0;
      final gemsNeeded = totals[CurrencyType.gems] ?? 0;

      // Verificar saldo
      if (params.user.coins < coinsNeeded || params.user.gems < gemsNeeded) {
        return const Left(TransactionFailure('Saldo insuficiente'));
      }

      // === PROCESSAR TRANSAÇÃO ===

      // 1. Deduzir moedas
      final updateResult = await _userRepository.updateUserCurrency(
        userId: params.user.id,
        coins: params.user.coins - coinsNeeded,
        gems: params.user.gems - gemsNeeded,
        xp: params.user.totalXp,
        level: params.user.level,
      );

      return updateResult.fold(
        (failure) => Left(failure),
        (_) async {
          // 2. Adicionar itens ao inventário
          final List<String> addedItems = [];

          for (final cartItem in params.cartItems) {
            final addResult = await _inventoryRepository.addItem(
              userId: params.user.id,
              shopItemId: cartItem.shopItem.id,
              quantity: cartItem.quantity,
            );

            addResult.fold(
              (failure) => null, // Log error but continue
              (_) => addedItems.add(cartItem.shopItem.id),
            );
          }

          // 3. Criar resultado
          return Right(PurchaseResult.success(
            coinsSpent: coinsNeeded,
            gemsSpent: gemsNeeded,
            itemsAdded: addedItems.length,
            totalItems: params.cartItems.fold(0, (sum, item) => sum + item.quantity),
          ));
        },
      );
    } catch (e) {
      return Left(ValidationFailure('Erro na compra: $e'));
    }
  }

  Map<CurrencyType, int> _calculateTotals(List<CartItemEntity> items) {
    final totals = <CurrencyType, int>{};

    for (final item in items) {
      totals[item.currency] = (totals[item.currency] ?? 0) + item.totalPrice;
    }

    return totals;
  }
}

class ProcessCartPurchaseParams {
  final UserEntity user;
  final List<CartItemEntity> cartItems;

  const ProcessCartPurchaseParams({
    required this.user,
    required this.cartItems,
  });
}

class PurchaseResult {
  final bool success;
  final String message;
  final int coinsSpent;
  final int gemsSpent;
  final int itemsAdded;
  final int totalItems;

  const PurchaseResult({
    required this.success,
    required this.message,
    this.coinsSpent = 0,
    this.gemsSpent = 0,
    this.itemsAdded = 0,
    this.totalItems = 0,
  });

  factory PurchaseResult.success({
    required int coinsSpent,
    required int gemsSpent,
    required int itemsAdded,
    required int totalItems,
  }) {
    return PurchaseResult(
      success: true,
      message: 'Compra realizada com sucesso!',
      coinsSpent: coinsSpent,
      gemsSpent: gemsSpent,
      itemsAdded: itemsAdded,
      totalItems: totalItems,
    );
  }

  factory PurchaseResult.failure(String message) {
    return PurchaseResult(success: false, message: message);
  }
}
