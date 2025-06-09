// File: lib/domain/usecases/shop/remove_from_cart.dart

import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/usecases/usecase.dart';
import 'package:petverse/entities/cart_item_entity.dart';

/// Use case para remover um item do carrinho de compras
class RemoveFromCart implements UseCase<RemoveFromCartResult, RemoveFromCartParams> {
  @override
  Future<Either<Failure, RemoveFromCartResult>> call(RemoveFromCartParams params) async {
    try {
      // === VALIDAÇÕES ===

      // Verificar se o item existe no carrinho
      final existingItem = params.cartItems.firstWhere(
        (item) => item.id == params.cartItemId,
        orElse: () => throw Exception('Item não encontrado'),
      );

      // === OPERAÇÃO DE REMOÇÃO ===

      if (params.removeType == RemoveType.decreaseQuantity) {
        // Diminuir quantidade
        if (params.quantityToRemove <= 0) {
          return const Left(ValidationFailure('Quantidade a remover deve ser maior que zero'));
        }

        if (params.quantityToRemove >= existingItem.quantity) {
          // Se vai remover tudo, remove o item completamente
          return _removeItemCompletely(existingItem, params.cartItems);
        } else {
          // Apenas diminui a quantidade
          return _decreaseQuantity(existingItem, params.quantityToRemove, params.cartItems);
        }
      } else {
        // Remover item completamente
        return _removeItemCompletely(existingItem, params.cartItems);
      }
    } catch (e) {
      if (e.toString().contains('Item não encontrado')) {
        return const Left(ValidationFailure('Item não encontrado no carrinho'));
      }
      return Left(ValidationFailure('Erro ao remover item do carrinho: $e'));
    }
  }

  /// Remove o item completamente do carrinho
  Either<Failure, RemoveFromCartResult> _removeItemCompletely(
    CartItemEntity item,
    List<CartItemEntity> cartItems,
  ) {
    final updatedCart = cartItems.where((cartItem) => cartItem.id != item.id).toList();

    return Right(RemoveFromCartResult.success(
      removedItem: item,
      updatedCart: updatedCart,
      operationType: CartOperation.removeItem,
      message: '${item.shopItem.name} removido do carrinho',
    ));
  }

  /// Diminui a quantidade do item no carrinho
  Either<Failure, RemoveFromCartResult> _decreaseQuantity(
    CartItemEntity item,
    int quantityToRemove,
    List<CartItemEntity> cartItems,
  ) {
    final newQuantity = item.quantity - quantityToRemove;
    final updatedItem = item.copyWith(quantity: newQuantity);

    final updatedCart = cartItems.map((cartItem) {
      return cartItem.id == item.id ? updatedItem : cartItem;
    }).toList();

    return Right(RemoveFromCartResult.success(
      removedItem: item,
      updatedItem: updatedItem,
      updatedCart: updatedCart,
      operationType: CartOperation.updateQuantity,
      message: 'Quantidade de ${item.shopItem.name} atualizada',
    ));
  }
}

/// Parâmetros para remover item do carrinho
class RemoveFromCartParams {
  final String cartItemId;
  final List<CartItemEntity> cartItems;
  final RemoveType removeType;
  final int quantityToRemove;

  const RemoveFromCartParams({
    required this.cartItemId,
    required this.cartItems,
    this.removeType = RemoveType.removeCompletely,
    this.quantityToRemove = 1,
  });
}

/// Tipos de remoção do carrinho
enum RemoveType {
  /// Remove o item completamente do carrinho
  removeCompletely,

  /// Apenas diminui a quantidade
  decreaseQuantity,
}

/// Resultado detalhado da operação de remoção do carrinho
class RemoveFromCartResult {
  final bool success;
  final CartItemEntity? removedItem;
  final CartItemEntity? updatedItem; // Item com quantidade atualizada
  final List<CartItemEntity> updatedCart;
  final CartOperation operationType;
  final CartError? error;
  final String? message;
  final int totalCartValue; // Valor total do carrinho após remoção
  final int itemsCount; // Número de itens no carrinho após remoção

  const RemoveFromCartResult({
    required this.success,
    this.removedItem,
    this.updatedItem,
    this.updatedCart = const [],
    required this.operationType,
    this.error,
    this.message,
    this.totalCartValue = 0,
    this.itemsCount = 0,
  });

  factory RemoveFromCartResult.success({
    required CartItemEntity removedItem,
    CartItemEntity? updatedItem,
    required List<CartItemEntity> updatedCart,
    required CartOperation operationType,
    String? message,
  }) {
    // Calcular valor total do carrinho
    final totalValue = updatedCart.fold<int>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    // Calcular número total de itens
    final totalItems = updatedCart.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return RemoveFromCartResult(
      success: true,
      removedItem: removedItem,
      updatedItem: updatedItem,
      updatedCart: updatedCart,
      operationType: operationType,
      message: message ?? 'Item removido com sucesso',
      totalCartValue: totalValue,
      itemsCount: totalItems,
    );
  }

  factory RemoveFromCartResult.failure({
    required CartError error,
    String? customMessage,
  }) {
    return RemoveFromCartResult(
      success: false,
      error: error,
      operationType: CartOperation.removeItem,
      message: customMessage ?? error.message,
    );
  }

  /// Verifica se o carrinho ficou vazio após a operação
  bool get isCartEmpty => updatedCart.isEmpty;

  /// Verifica se a operação foi apenas uma atualização de quantidade
  bool get isQuantityUpdate => operationType == CartOperation.updateQuantity;
}
