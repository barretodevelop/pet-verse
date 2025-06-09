// File: lib/presentation/providers/shop_provider.dart
// ATUALIZADO - Usando UserProvider simplificado

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/constants/economy_constants.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/domain/entities/shop_item_entity.dart';
import 'package:petverse/presentation/providers/cart_provider.dart';
import 'package:petverse/presentation/providers/dependencies_provider.dart';
import 'package:petverse/presentation/providers/user_provider.dart';
import 'package:petverse/services/shop_service.dart';

class ShopState {
  final List<ShopItemEntity> items;
  final List<ShopItemEntity> filteredItems;
  final ItemCategory? selectedCategory;
  final LoadingState status;
  final String? errorMessage;
  final bool isPurchasing;
  final ShopSortType sortType;
  final String searchQuery;

  const ShopState({
    this.items = const [],
    this.filteredItems = const [],
    this.selectedCategory,
    this.status = LoadingState.initial,
    this.errorMessage,
    this.isPurchasing = false,
    this.sortType = ShopSortType.nameAsc,
    this.searchQuery = '',
  });

  ShopState copyWith({
    List<ShopItemEntity>? items,
    List<ShopItemEntity>? filteredItems,
    ItemCategory? selectedCategory,
    bool clearCategory = false,
    LoadingState? status,
    String? errorMessage,
    bool clearError = false,
    bool? isPurchasing,
    ShopSortType? sortType,
    String? searchQuery,
  }) {
    return ShopState(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      selectedCategory: clearCategory ? null : selectedCategory ?? this.selectedCategory,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      sortType: sortType ?? this.sortType,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get isLoading => status == LoadingState.loading;
  bool get hasError => status == LoadingState.error;
  bool get hasItems => items.isNotEmpty;
}

class ShopNotifier extends StateNotifier<ShopState> {
  final Ref _ref;

  ShopNotifier(this._ref) : super(const ShopState()) {
    loadShopItems();
  }

  Future<void> loadShopItems() async {
    state = state.copyWith(status: LoadingState.loading, clearError: true);

    try {
      final mockItems = ShopService.getAllItems(); // Pega da sua classe
      state = state.copyWith(
        items: mockItems,
        filteredItems: mockItems,
        status: LoadingState.success,
      );
      _applyFiltersAndSort();
    } catch (e) {
      state = state.copyWith(
        status: LoadingState.error,
        errorMessage: 'Falha ao carregar itens: $e',
      );
    }
  }

  void filterByCategory(ItemCategory? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
    );
    _applyFiltersAndSort();
  }

  void searchItems(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFiltersAndSort();
  }

  void sortItems(ShopSortType sortType) {
    state = state.copyWith(sortType: sortType);
    _applyFiltersAndSort();
  }

  void _applyFiltersAndSort() {
    var filtered = state.items.where((item) => item.isAvailable);

    // Aplicar filtro de categoria
    if (state.selectedCategory != null) {
      filtered = filtered.where((item) => item.category == state.selectedCategory);
    }

    // Aplicar busca
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered.where((item) => item.matchesSearch(state.searchQuery));
    }

    // Aplicar ordenação
    final sortedList = filtered.toList();
    _sortItemsList(sortedList, state.sortType);

    state = state.copyWith(filteredItems: sortedList);
  }

  void _sortItemsList(List<ShopItemEntity> items, ShopSortType sortType) {
    switch (sortType) {
      case ShopSortType.nameAsc:
        items.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ShopSortType.nameDesc:
        items.sort((a, b) => b.name.compareTo(a.name));
        break;
      case ShopSortType.priceAsc:
        items.sort((a, b) => a.basePrice.compareTo(b.basePrice));
        break;
      case ShopSortType.priceDesc:
        items.sort((a, b) => b.basePrice.compareTo(a.basePrice));
        break;
      case ShopSortType.category:
        items.sort((a, b) => a.category.name.compareTo(b.category.name));
        break;
      case ShopSortType.popularity:
        items.sort((a, b) => b.popularity.compareTo(a.popularity));
        break;
      case ShopSortType.newest:
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ShopSortType.rarity:
        items.sort((a, b) => b.rarity.index.compareTo(a.rarity.index));
        break;
    }
  }

  Future<void> addToCart(ShopItemEntity item, int quantity) async {
    final userState = _ref.read(userGameDataProvider);
    if (userState.user == null) return;

    await _ref.read(cartProvider.notifier).addItem(
          shopItem: item,
          quantity: quantity,
          userLevel: userState.user!.level,
        );
  }

  /// Processa compra do carrinho (versão simplificada)
  Future<void> purchaseCart() async {
    final userState = _ref.read(userGameDataProvider);
    final cartState = _ref.read(cartProvider);

    if (userState.user == null || cartState.isEmpty) return;

    state = state.copyWith(isPurchasing: true);

    try {
      // Calcular totais
      int totalCoins = 0;
      int totalGems = 0;

      for (final item in cartState.items) {
        if (item.currency == CurrencyType.coins) {
          totalCoins += item.totalPrice;
        } else {
          totalGems += item.totalPrice;
        }
      }

      // Processar compra usando método simplificado
      final success = await _ref.read(userGameDataProvider.notifier).processPurchase(
            coinsToRemove: totalCoins,
            gemsToRemove: totalGems,
          );

      if (success) {
        // Adicionar itens ao inventário (simulado por enquanto)
        await _addItemsToInventory(cartState.items);

        // Limpar carrinho
        _ref.read(cartProvider.notifier).clearCart();

        state = state.copyWith(
          isPurchasing: false,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isPurchasing: false,
          errorMessage: 'Erro na compra - saldo insuficiente',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isPurchasing: false,
        errorMessage: 'Erro na compra: $e',
      );
    }
  }

  /// Simula adição de itens ao inventário
  Future<void> _addItemsToInventory(List<dynamic> cartItems) async {
    try {
      final inventoryRepository = _ref.read(inventoryRepositoryProvider);
      final userState = _ref.read(userGameDataProvider);

      if (userState.user == null) return;

      for (final cartItem in cartItems) {
        await inventoryRepository.addItem(
          userId: userState.user!.id,
          shopItemId: cartItem.shopItem.id,
          quantity: cartItem.quantity,
          name: cartItem.shopItem.name,
          description: cartItem.shopItem.description,
          imageUrl: cartItem.shopItem.imageUrl,
          category: cartItem.shopItem.category.name,
          rarity: cartItem.shopItem.rarity.name,
          effects: cartItem.shopItem.effects.map((key, value) => MapEntry(key.name, value)),
        );
      }
    } catch (e) {
      // Silenciar erro de inventário por enquanto
      print('Erro ao adicionar ao inventário: $e');
    }
  }

  List<ShopItemEntity> _generateMockShopItems() {
    final now = DateTime.now();
    return [
      // === COMIDA ===
      ShopItemEntity(
        id: 'basic_food',
        name: 'Comida Básica',
        description: 'Alimenta seu pet e restaura fome',
        imageUrl: '🍖',
        basePrice: EconomyConstants.basePricesCoins['basic_food']!,
        currency: CurrencyType.coins,
        category: ItemCategory.food,
        rarity: ItemRarity.common,
        effects: const {ItemEffectType.hunger: 30},
        createdAt: now.subtract(const Duration(days: 10)),
        popularity: 95,
        tags: const ['comida', 'básico', 'fome'],
      ),
      ShopItemEntity(
        id: 'premium_food',
        name: 'Comida Premium',
        description: 'Comida especial que restaura fome e dá felicidade',
        imageUrl: '🥩',
        basePrice: EconomyConstants.basePricesCoins['premium_food']!,
        currency: CurrencyType.coins,
        category: ItemCategory.food,
        rarity: ItemRarity.rare,
        effects: const {ItemEffectType.hunger: 50, ItemEffectType.happiness: 20},
        createdAt: now.subtract(const Duration(days: 5)),
        popularity: 80,
        isFeatured: true,
        tags: const ['comida', 'premium', 'felicidade'],
      ),

      // === BRINQUEDOS ===
      ShopItemEntity(
        id: 'simple_toy',
        name: 'Bolinha',
        description: 'Brinquedo simples que aumenta felicidade',
        imageUrl: '⚽',
        basePrice: EconomyConstants.basePricesCoins['simple_toy']!,
        currency: CurrencyType.coins,
        category: ItemCategory.toy,
        rarity: ItemRarity.common,
        effects: const {ItemEffectType.happiness: 25},
        createdAt: now.subtract(const Duration(days: 8)),
        popularity: 70,
        tags: const ['brinquedo', 'felicidade', 'simples'],
      ),
      ShopItemEntity(
        id: 'interactive_toy',
        name: 'Brinquedo Interativo',
        description: 'Brinquedo que aumenta felicidade e energia',
        imageUrl: '🎾',
        basePrice: EconomyConstants.basePricesCoins['interactive_toy']!,
        currency: CurrencyType.coins,
        category: ItemCategory.toy,
        rarity: ItemRarity.uncommon,
        effects: const {ItemEffectType.happiness: 40, ItemEffectType.energy: 15},
        createdAt: now.subtract(const Duration(days: 3)),
        popularity: 85,
        isNew: true,
        tags: const ['brinquedo', 'interativo', 'energia'],
      ),

      // === MEDICINA ===
      ShopItemEntity(
        id: 'health_potion',
        name: 'Poção de Saúde',
        description: 'Restaura completamente a saúde do pet',
        imageUrl: '🧪',
        basePrice: EconomyConstants.basePricesCoins['health_potion']!,
        currency: CurrencyType.coins,
        category: ItemCategory.medicine,
        rarity: ItemRarity.uncommon,
        effects: const {ItemEffectType.health: 100},
        createdAt: now.subtract(const Duration(days: 12)),
        popularity: 60,
        tags: const ['medicina', 'saúde', 'cura'],
      ),

      // === ITENS PREMIUM (GEMS) ===
      ShopItemEntity(
        id: 'legendary_food',
        name: 'Comida Lendária',
        description: 'Comida mítica que restaura tudo e dá XP',
        imageUrl: '🍗',
        basePrice: EconomyConstants.basePricesGems['legendary_food']!,
        currency: CurrencyType.gems,
        category: ItemCategory.food,
        rarity: ItemRarity.legendary,
        effects: const {
          ItemEffectType.hunger: 100,
          ItemEffectType.happiness: 50,
          ItemEffectType.energy: 50,
          ItemEffectType.xp: 100,
        },
        createdAt: now.subtract(const Duration(days: 1)),
        popularity: 95,
        isFeatured: true,
        isNew: true,
        limitPerUser: 5,
        tags: const ['lendário', 'premium', 'xp'],
      ),
      ShopItemEntity(
        id: 'mythic_toy',
        name: 'Brinquedo Mítico',
        description: 'Brinquedo raro que maximiza felicidade',
        imageUrl: '🎯',
        basePrice: EconomyConstants.basePricesGems['mythic_toy']!,
        currency: CurrencyType.gems,
        category: ItemCategory.toy,
        rarity: ItemRarity.legendary,
        effects: const {ItemEffectType.happiness: 100, ItemEffectType.xp: 50},
        createdAt: now.subtract(const Duration(days: 2)),
        popularity: 90,
        limitPerUser: 3,
        tags: const ['mítico', 'raro', 'máximo'],
      ),
    ];
  }
}

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier(ref);
});
