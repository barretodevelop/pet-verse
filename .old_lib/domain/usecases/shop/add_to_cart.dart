// File: lib/domain/usecases/shop/add_to_cart.dart

import 'package:petverse/core/constants/economy_constants.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/shop_item_entity.dart';
import 'package:petverse/domain/usecases/usecase.dart';
import 'package:petverse/entities/cart_item_entity.dart';

/// Use case para adicionar um item ao carrinho de compras
class AddToCart implements UseCase<CartItemEntity, AddToCartParams> {
  @override
  Future<Either<Failure, CartItemEntity>> call(AddToCartParams params) async {
    try {
      // === VALIDAÇÕES ===

      // Validar quantidade
      if (params.quantity <= 0) {
        return const Left(ValidationFailure('Quantidade deve ser maior que zero'));
      }

      if (params.quantity > EconomyConstants.maxQuantityPerItem) {
        return const Left(ValidationFailure(
            'Quantidade não pode exceder ${EconomyConstants.maxQuantityPerItem}'));
      }

      // Validar disponibilidade do item
      if (!params.shopItem.isAvailable) {
        return const Left(ValidationFailure('Item não está disponível'));
      }

      // Validar estoque
      if (!params.shopItem.hasStock(params.quantity)) {
        return Left(ValidationFailure(
            'Estoque insuficiente. Disponível: ${params.shopItem.stockQuantity ?? "Ilimitado"}'));
      }

      // Validar limite por usuário
      if (!params.shopItem.canUserBuy(params.userPurchaseCount, params.quantity)) {
        return Left(ValidationFailure(
            'Limite de compra excedido. Máximo: ${params.shopItem.limitPerUser}'));
      }

      // === CALCULAR PREÇO ===
      final unitPrice = params.shopItem.calculatePrice(
        userLevel: params.userLevel,
        quantity: 1, // Preço unitário
      );

      // === CRIAR ITEM DO CARRINHO ===
      final cartItem = CartItemEntity(
        id: _generateCartItemId(params.shopItem.id),
        shopItem: params.shopItem,
        quantity: params.quantity,
        addedAt: DateTime.now(),
        unitPrice: unitPrice,
        currency: params.shopItem.currency,
      );

      return Right(cartItem);
    } catch (e) {
      return Left(ValidationFailure('Erro ao adicionar item ao carrinho: $e'));
    }
  }

  /// Gera um ID único para o item do carrinho
  String _generateCartItemId(String shopItemId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${shopItemId}_$timestamp';
  }
}

/// Parâmetros para adicionar item ao carrinho
class AddToCartParams {
  final ShopItemEntity shopItem;
  final int quantity;
  final int userLevel;
  final int userPurchaseCount; // Quantos deste item o usuário já comprou

  const AddToCartParams({
    required this.shopItem,
    required this.quantity,
    required this.userLevel,
    this.userPurchaseCount = 0,
  });
}

/// Resultado detalhado da operação de adicionar ao carrinho
class AddToCartResult {
  final bool success;
  final CartItemEntity? cartItem;
  final CartError? error;
  final String? message;
  final int totalPrice;
  final int savings; // Economia por desconto

  const AddToCartResult({
    required this.success,
    this.cartItem,
    this.error,
    this.message,
    this.totalPrice = 0,
    this.savings = 0,
  });

  factory AddToCartResult.success({
    required CartItemEntity cartItem,
    int savings = 0,
  }) {
    return AddToCartResult(
      success: true,
      cartItem: cartItem,
      totalPrice: cartItem.totalPrice,
      savings: savings,
      message: 'Item adicionado ao carrinho com sucesso',
    );
  }

  factory AddToCartResult.failure({
    required CartError error,
    String? customMessage,
  }) {
    return AddToCartResult(
      success: false,
      error: error,
      message: customMessage ?? error.message,
    );
  }
}
