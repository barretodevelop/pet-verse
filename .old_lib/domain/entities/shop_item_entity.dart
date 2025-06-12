// File: lib/domain/entities/shop_item_entity.dart
// ATUALIZADA - Sistema de Shop & Items melhorado

import 'package:equatable/equatable.dart';
import 'package:petverse/core/constants/economy_constants.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';

class ShopItemEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int basePrice; // Preço base (será multiplicado por nível)
  final CurrencyType currency;
  final ItemCategory category;
  final ItemRarity rarity;
  final Map<ItemEffectType, int> effects;
  final bool isAvailable;
  final int? limitPerUser;
  final Duration? effectDuration;

  // === NOVOS CAMPOS ===
  final int popularity; // Para ordenação por popularidade
  final DateTime createdAt; // Para ordenação por data
  final List<String> tags; // Para busca e filtros
  final bool isFeatured; // Item em destaque
  final bool isNew; // Item novo (últimos 7 dias)
  final int? stockQuantity; // Quantidade em estoque (null = ilimitado)
  final double discountPercentage; // Desconto aplicado (0.0 a 1.0)
  final DateTime? discountExpiry; // Quando o desconto expira
  final String? bundleId; // ID do pacote se faz parte de um

  const ShopItemEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.basePrice,
    required this.currency,
    required this.category,
    required this.rarity,
    required this.effects,
    this.isAvailable = true,
    this.limitPerUser,
    this.effectDuration,
    this.popularity = 0,
    required this.createdAt,
    this.tags = const [],
    this.isFeatured = false,
    this.isNew = false,
    this.stockQuantity,
    this.discountPercentage = 0.0,
    this.discountExpiry,
    this.bundleId,
  });

  /// Calcula o preço real considerando nível do usuário, desconto e quantidade
  int calculatePrice({
    required int userLevel,
    int quantity = 1,
  }) {
    // Aplica scaling baseado no nível
    final priceMultiplier = EconomyConstants.getPriceMultiplier(userLevel);
    double adjustedPrice = basePrice * priceMultiplier;

    // Aplica desconto se houver
    if (hasActiveDiscount) {
      adjustedPrice = adjustedPrice * (1 - discountPercentage);
    }

    // Aplica desconto por quantidade
    if (quantity > 1) {
      final bulkDiscount = EconomyConstants.getBulkDiscount(quantity);
      adjustedPrice = adjustedPrice * (1 - bulkDiscount);
    }

    return (adjustedPrice * quantity).round();
  }

  /// Verifica se o item tem desconto ativo
  bool get hasActiveDiscount {
    if (discountPercentage <= 0) return false;
    if (discountExpiry == null) return true;
    return DateTime.now().isBefore(discountExpiry!);
  }

  /// Verifica se o item é novo (criado nos últimos 7 dias)
  bool get isNewItem {
    if (isNew) return true;
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreation <= 7;
  }

  /// Verifica se há estoque suficiente
  bool hasStock([int requestedQuantity = 1]) {
    if (stockQuantity == null) return true; // Estoque ilimitado
    return stockQuantity! >= requestedQuantity;
  }

  /// Verifica se o usuário pode comprar considerando limite
  bool canUserBuy(int userPurchases, [int requestedQuantity = 1]) {
    if (limitPerUser == null) return true;
    return (userPurchases + requestedQuantity) <= limitPerUser!;
  }

  /// Obtém o preço formatado como string
  String getFormattedPrice({
    required int userLevel,
    int quantity = 1,
  }) {
    final price = calculatePrice(userLevel: userLevel, quantity: quantity);
    final currencySymbol = currency == CurrencyType.coins ? '💰' : '💎';
    return '$currencySymbol $price';
  }

  /// Obtém a economia de desconto
  int getSavingsAmount({
    required int userLevel,
    int quantity = 1,
  }) {
    if (!hasActiveDiscount) return 0;

    final fullPrice = basePrice * EconomyConstants.getPriceMultiplier(userLevel) * quantity;
    final discountedPrice = calculatePrice(userLevel: userLevel, quantity: quantity);

    return (fullPrice - discountedPrice).round();
  }

  /// Verifica se o item corresponde a uma busca
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;

    final searchQuery = query.toLowerCase();
    return name.toLowerCase().contains(searchQuery) ||
        description.toLowerCase().contains(searchQuery) ||
        tags.any((tag) => tag.toLowerCase().contains(searchQuery)) ||
        category.name.toLowerCase().contains(searchQuery);
  }

  ShopItemEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    int? basePrice,
    CurrencyType? currency,
    ItemCategory? category,
    ItemRarity? rarity,
    Map<ItemEffectType, int>? effects,
    bool? isAvailable,
    int? limitPerUser,
    Duration? effectDuration,
    int? popularity,
    DateTime? createdAt,
    List<String>? tags,
    bool? isFeatured,
    bool? isNew,
    int? stockQuantity,
    double? discountPercentage,
    DateTime? discountExpiry,
    String? bundleId,
  }) {
    return ShopItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      basePrice: basePrice ?? this.basePrice,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      rarity: rarity ?? this.rarity,
      effects: effects ?? this.effects,
      isAvailable: isAvailable ?? this.isAvailable,
      limitPerUser: limitPerUser ?? this.limitPerUser,
      effectDuration: effectDuration ?? this.effectDuration,
      popularity: popularity ?? this.popularity,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountExpiry: discountExpiry ?? this.discountExpiry,
      bundleId: bundleId ?? this.bundleId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        basePrice,
        currency,
        category,
        rarity,
        effects,
        isAvailable,
        limitPerUser,
        effectDuration,
        popularity,
        createdAt,
        tags,
        isFeatured,
        isNew,
        stockQuantity,
        discountPercentage,
        discountExpiry,
        bundleId,
      ];

  @override
  String toString() {
    return 'ShopItemEntity(id: $id, name: $name, basePrice: $basePrice $currency)';
  }
}
