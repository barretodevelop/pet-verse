import 'package:flutter/material.dart';
import 'package:petverse/shared/enums/enums.dart';

@immutable
class ShopItem {
  final String id;
  final String name;
  final String emoji;
  final String? assetPath;
  final Color? itemColor;
  final int coinPrice;
  final int gemPrice;
  final String description;
  final ItemCategory category;
  final bool isStackable;

  const ShopItem({
    required this.id,
    required this.name,
    this.emoji = '❓',
    this.assetPath,
    this.itemColor,
    this.coinPrice = 0,
    this.gemPrice = 0,
    this.description = 'Um item incrível!',
    this.category = ItemCategory.accessory,
    this.isStackable = true,
  })  : assert(coinPrice >= 0 || gemPrice >= 0),
        assert(
            category != ItemCategory.environment ||
                assetPath != null ||
                itemColor != null,
            "Itens de ambiente devem ter assetPath ou itemColor");

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'assetPath': assetPath,
        'itemColor': itemColor?.value,
        'coinPrice': coinPrice,
        'gemPrice': gemPrice,
        'description': description,
        'category': category.toString(),
        'isStackable': isStackable,
      };

  factory ShopItem.fromJson(Map<String, dynamic> json) => ShopItem(
        id: json['id'],
        name: json['name'],
        emoji: json['emoji'] ?? '❓',
        assetPath: json['assetPath'],
        itemColor: json['itemColor'] != null ? Color(json['itemColor']) : null,
        coinPrice: json['coinPrice'] ?? 0,
        gemPrice: json['gemPrice'] ?? 0,
        description: json['description'] ?? 'Um item incrível!',
        category: ItemCategory.values.firstWhere(
            (e) => e.toString() == json['category'],
            orElse: () => ItemCategory.accessory),
        isStackable: json['isStackable'] ?? true,
      );
}
