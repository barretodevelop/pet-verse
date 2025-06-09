// File: lib/domain/entities/cart_item_entity.dart

import 'package:equatable/equatable.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/domain/entities/shop_item_entity.dart';

/// Entidade para representar um item no carrinho de compras
class CartItemEntity extends Equatable {
  final String id;
  final ShopItemEntity shopItem;
  final int quantity;
  final DateTime addedAt;
  final int unitPrice; // Preço unitário no momento da adição
  final CurrencyType currency;

  const CartItemEntity({
    required this.id,
    required this.shopItem,
    required this.quantity,
    required this.addedAt,
    required this.unitPrice,
    required this.currency,
  });

  /// Calcula o preço total do item (quantidade * preço unitário)
  int get totalPrice => quantity * unitPrice;

  /// Calcula os efeitos totais do item (quantidade * efeitos)
  Map<ItemEffectType, int> get totalEffects {
    final Map<ItemEffectType, int> total = {};
    for (final effect in shopItem.effects.entries) {
      total[effect.key] = effect.value * quantity;
    }
    return total;
  }

  /// Verifica se o item ainda está disponível na loja
  bool get isStillAvailable => shopItem.isAvailable;

  /// Verifica se o preço mudou desde que foi adicionado
  bool get priceChanged => unitPrice != shopItem.basePrice;

  /// Verifica se há estoque suficiente (se aplicável)
  bool hasEnoughStock(int requestedQuantity) {
    if (shopItem.stockQuantity == null) return true;
    return requestedQuantity <= shopItem.stockQuantity!;
  }

  CartItemEntity copyWith({
    String? id,
    ShopItemEntity? shopItem,
    int? quantity,
    DateTime? addedAt,
    int? unitPrice,
    CurrencyType? currency,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      shopItem: shopItem ?? this.shopItem,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
      unitPrice: unitPrice ?? this.unitPrice,
      currency: currency ?? this.currency,
    );
  }

  /// Cria um novo CartItem incrementando a quantidade
  CartItemEntity incrementQuantity([int amount = 1]) {
    return copyWith(quantity: quantity + amount);
  }

  /// Cria um novo CartItem decrementando a quantidade
  CartItemEntity decrementQuantity([int amount = 1]) {
    final newQuantity = quantity - amount;
    if (newQuantity <= 0) {
      throw ArgumentError('Quantidade não pode ser menor ou igual a zero');
    }
    return copyWith(quantity: newQuantity);
  }

  /// Atualiza o preço unitário para o preço atual do item
  CartItemEntity updatePrice() {
    return copyWith(
      unitPrice: shopItem.basePrice,
      currency: shopItem.currency,
    );
  }

  @override
  List<Object?> get props => [
        id,
        shopItem.id,
        quantity,
        addedAt,
        unitPrice,
        currency,
      ];

  @override
  String toString() {
    return 'CartItemEntity(id: $id, item: ${shopItem.name}, quantity: $quantity, totalPrice: $totalPrice)';
  }
}
