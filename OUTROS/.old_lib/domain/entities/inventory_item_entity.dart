// File: lib/domain/entities/inventory_item_entity.dart

import 'package:equatable/equatable.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';

/// Entidade que representa um item no inventário do usuário
class InventoryItemEntity extends Equatable {
  final String id;
  final String userId;
  final String shopItemId;
  final String name;
  final String description;
  final String imageUrl;
  final ItemCategory category;
  final ItemRarity rarity;
  final int quantity;
  final Map<ItemEffectType, int> effects;
  final DateTime acquiredAt;
  final DateTime? lastUsedAt;
  final int timesUsed;
  final bool isStackable;
  final int? maxStack;

  const InventoryItemEntity({
    required this.id,
    required this.userId,
    required this.shopItemId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.rarity,
    required this.quantity,
    required this.effects,
    required this.acquiredAt,
    this.lastUsedAt,
    this.timesUsed = 0,
    this.isStackable = true,
    this.maxStack,
  });

  /// Verifica se o item pode ser usado
  bool get canBeUsed => quantity > 0;

  /// Verifica se o item pode ser empilhado
  bool get canStack => isStackable && (maxStack == null || quantity < maxStack!);

  /// Obtém a raridade como cor
  String get rarityEmoji {
    switch (rarity) {
      case ItemRarity.common:
        return '⚪';
      case ItemRarity.uncommon:
        return '🟢';
      case ItemRarity.rare:
        return '🔵';
      case ItemRarity.epic:
        return '🟣';
      case ItemRarity.legendary:
        return '🟠';
    }
  }

  /// Calcula o valor total dos efeitos considerando a quantidade
  Map<ItemEffectType, int> get totalEffects {
    final Map<ItemEffectType, int> total = {};
    for (final effect in effects.entries) {
      total[effect.key] = effect.value * quantity;
    }
    return total;
  }

  /// Verifica se o item é recente (adquirido nos últimos 7 dias)
  bool get isRecent {
    final daysSinceAcquired = DateTime.now().difference(acquiredAt).inDays;
    return daysSinceAcquired <= 7;
  }

  /// Verifica se o item foi usado recentemente
  bool get wasUsedRecently {
    if (lastUsedAt == null) return false;
    final hoursSinceLastUse = DateTime.now().difference(lastUsedAt!).inHours;
    return hoursSinceLastUse <= 24;
  }

  InventoryItemEntity copyWith({
    String? id,
    String? userId,
    String? shopItemId,
    String? name,
    String? description,
    String? imageUrl,
    ItemCategory? category,
    ItemRarity? rarity,
    int? quantity,
    Map<ItemEffectType, int>? effects,
    DateTime? acquiredAt,
    DateTime? lastUsedAt,
    int? timesUsed,
    bool? isStackable,
    int? maxStack,
  }) {
    return InventoryItemEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopItemId: shopItemId ?? this.shopItemId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      quantity: quantity ?? this.quantity,
      effects: effects ?? this.effects,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      timesUsed: timesUsed ?? this.timesUsed,
      isStackable: isStackable ?? this.isStackable,
      maxStack: maxStack ?? this.maxStack,
    );
  }

  /// Cria uma nova instância com quantidade decrementada
  InventoryItemEntity decrementQuantity([int amount = 1]) {
    final newQuantity = quantity - amount;
    if (newQuantity < 0) {
      throw ArgumentError('Quantidade não pode ser negativa');
    }

    return copyWith(
      quantity: newQuantity,
      lastUsedAt: DateTime.now(),
      timesUsed: timesUsed + 1,
    );
  }

  /// Cria uma nova instância com quantidade incrementada
  InventoryItemEntity incrementQuantity([int amount = 1]) {
    if (!canStack && amount > 0) {
      throw ArgumentError('Item não pode ser empilhado');
    }

    final newQuantity = quantity + amount;
    if (maxStack != null && newQuantity > maxStack!) {
      throw ArgumentError('Quantidade excede limite máximo de empilhamento');
    }

    return copyWith(quantity: newQuantity);
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        shopItemId,
        quantity,
        acquiredAt,
        lastUsedAt,
        timesUsed,
      ];

  @override
  String toString() {
    return 'InventoryItemEntity(id: $id, name: $name, quantity: $quantity)';
  }
}
