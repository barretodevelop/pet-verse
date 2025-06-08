// SEMANA 3: SHOP & ITEMS SYSTEM
// ============================================================================

// File: lib/domain/entities/shop_item_entity.dart

import 'package:equatable/equatable.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';

class ShopItemEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int price;
  final CurrencyType currency;
  final ItemCategory category;
  final ItemRarity rarity;
  final Map<ItemEffectType, int> effects; // hunger: +30, happiness: +20
  final bool isAvailable;
  final int? limitPerUser;
  final Duration? effectDuration;

  const ShopItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.currency,
    required this.category,
    required this.rarity,
    required this.effects,
    this.isAvailable = true,
    this.limitPerUser,
    this.effectDuration,
  });

  ShopItemEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? price,
    CurrencyType? currency,
    ItemCategory? category,
    ItemRarity? rarity,
    Map<ItemEffectType, int>? effects,
    bool? isAvailable,
    int? limitPerUser,
    Duration? effectDuration,
  }) {
    return ShopItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      effects: effects ?? this.effects,
      isAvailable: isAvailable ?? this.isAvailable,
      limitPerUser: limitPerUser ?? this.limitPerUser,
      effectDuration: effectDuration ?? this.effectDuration,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        currency,
        category,
        rarity,
        effects,
        isAvailable,
        limitPerUser,
        effectDuration,
      ];
}
