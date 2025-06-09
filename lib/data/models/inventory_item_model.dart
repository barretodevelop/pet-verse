// File: lib/data/models/inventory_item_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/domain/entities/inventory_item_entity.dart';

/// Model para conversão entre Firestore e InventoryItemEntity
class InventoryItemModel {
  final String id;
  final String userId;
  final String shopItemId;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final String rarity;
  final int quantity;
  final Map<String, dynamic> effects;
  final DateTime acquiredAt;
  final DateTime? lastUsedAt;
  final int timesUsed;
  final bool isStackable;
  final int? maxStack;

  const InventoryItemModel({
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

  /// Cria um InventoryItemModel a partir de um documento Firestore
  factory InventoryItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return InventoryItemModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      shopItemId: data['shopItemId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'food',
      rarity: data['rarity'] ?? 'common',
      quantity: data['quantity'] ?? 0,
      effects: Map<String, dynamic>.from(data['effects'] ?? {}),
      acquiredAt: (data['acquiredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUsedAt: (data['lastUsedAt'] as Timestamp?)?.toDate(),
      timesUsed: data['timesUsed'] ?? 0,
      isStackable: data['isStackable'] ?? true,
      maxStack: data['maxStack'],
    );
  }

  /// Cria um InventoryItemModel a partir de uma entidade
  factory InventoryItemModel.fromEntity(InventoryItemEntity entity) {
    return InventoryItemModel(
      id: entity.id,
      userId: entity.userId,
      shopItemId: entity.shopItemId,
      name: entity.name,
      description: entity.description,
      imageUrl: entity.imageUrl,
      category: entity.category.name,
      rarity: entity.rarity.name,
      quantity: entity.quantity,
      effects: entity.effects.map((key, value) => MapEntry(key.name, value)),
      acquiredAt: entity.acquiredAt,
      lastUsedAt: entity.lastUsedAt,
      timesUsed: entity.timesUsed,
      isStackable: entity.isStackable,
      maxStack: entity.maxStack,
    );
  }

  /// Converte para Map para salvar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'shopItemId': shopItemId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'rarity': rarity,
      'quantity': quantity,
      'effects': effects,
      'acquiredAt': Timestamp.fromDate(acquiredAt),
      'lastUsedAt': lastUsedAt != null ? Timestamp.fromDate(lastUsedAt!) : null,
      'timesUsed': timesUsed,
      'isStackable': isStackable,
      'maxStack': maxStack,
    };
  }

  /// Converte para entidade de domínio
  InventoryItemEntity toEntity() {
    return InventoryItemEntity(
      id: id,
      userId: userId,
      shopItemId: shopItemId,
      name: name,
      description: description,
      imageUrl: imageUrl,
      category: _stringToItemCategory(category),
      rarity: _stringToItemRarity(rarity),
      quantity: quantity,
      effects: _convertEffectsToEnum(effects),
      acquiredAt: acquiredAt,
      lastUsedAt: lastUsedAt,
      timesUsed: timesUsed,
      isStackable: isStackable,
      maxStack: maxStack,
    );
  }

  /// Converte string para ItemCategory enum
  ItemCategory _stringToItemCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return ItemCategory.food;
      case 'toy':
        return ItemCategory.toy;
      case 'medicine':
        return ItemCategory.medicine;
      case 'decoration':
        return ItemCategory.decoration;
      case 'accessory':
        return ItemCategory.accessory;
      case 'special':
        return ItemCategory.special;
      default:
        return ItemCategory.food;
    }
  }

  /// Converte string para ItemRarity enum
  ItemRarity _stringToItemRarity(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return ItemRarity.common;
      case 'uncommon':
        return ItemRarity.uncommon;
      case 'rare':
        return ItemRarity.rare;
      case 'epic':
        return ItemRarity.epic;
      case 'legendary':
        return ItemRarity.legendary;
      default:
        return ItemRarity.common;
    }
  }

  /// Converte Map de effects para enum
  Map<ItemEffectType, int> _convertEffectsToEnum(Map<String, dynamic> effects) {
    final Map<ItemEffectType, int> converted = {};

    for (final entry in effects.entries) {
      final effectType = _stringToItemEffectType(entry.key);
      if (effectType != null && entry.value is int) {
        converted[effectType] = entry.value;
      }
    }

    return converted;
  }

  /// Converte string para ItemEffectType enum
  ItemEffectType? _stringToItemEffectType(String effect) {
    switch (effect.toLowerCase()) {
      case 'hunger':
        return ItemEffectType.hunger;
      case 'happiness':
        return ItemEffectType.happiness;
      case 'energy':
        return ItemEffectType.energy;
      case 'health':
        return ItemEffectType.health;
      case 'xp':
        return ItemEffectType.xp;
      default:
        return null;
    }
  }

  InventoryItemModel copyWith({
    String? id,
    String? userId,
    String? shopItemId,
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    String? rarity,
    int? quantity,
    Map<String, dynamic>? effects,
    DateTime? acquiredAt,
    DateTime? lastUsedAt,
    int? timesUsed,
    bool? isStackable,
    int? maxStack,
  }) {
    return InventoryItemModel(
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
}
