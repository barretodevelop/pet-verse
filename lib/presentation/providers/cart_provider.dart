// File: lib/presentation/providers/cart_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/constants/economy_constants.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/domain/entities/shop_item_entity.dart';
import 'package:petverse/domain/entities/user_entity.dart';
import 'package:petverse/domain/usecases/shop/add_to_cart.dart';
import 'package:petverse/domain/usecases/shop/remove_from_cart.dart';
import 'package:petverse/entities/cart_item_entity.dart';

/// Estado do carrinho de compras
class CartState {
  final List<CartItemEntity> items;
  final CartStatus status;
  final CartLoadingState loadingState;
  final String? errorMessage;
  final CartError? lastError;
  final int totalValue; // Valor total em coins
  final int totalValueGems; // Valor total em gems
  final int totalItems; // Quantidade total de itens
  final int uniqueItems; // Número de tipos únicos de itens
  final double totalSavings; // Economia total por descontos
  final Map<CurrencyType, int> currencyTotals; // Total por tipo de moeda

  const CartState({
    this.items = const [],
    this.status = CartStatus.empty,
    this.loadingState = CartLoadingState.initial,
    this.errorMessage,
    this.lastError,
    this.totalValue = 0,
    this.totalValueGems = 0,
    this.totalItems = 0,
    this.uniqueItems = 0,
    this.totalSavings = 0.0,
    this.currencyTotals = const {},
  });

  CartState copyWith({
    List<CartItemEntity>? items,
    CartStatus? status,
    CartLoadingState? loadingState,
    String? errorMessage,
    bool clearError = false,
    CartError? lastError,
    int? totalValue,
    int? totalValueGems,
    int? totalItems,
    int? uniqueItems,
    double? totalSavings,
    Map<CurrencyType, int>? currencyTotals,
  }) {
    return CartState(
      items: items ?? this.items,
      status: status ?? this.status,
      loadingState: loadingState ?? this.loadingState,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      lastError: lastError ?? this.lastError,
      totalValue: totalValue ?? this.totalValue,
      totalValueGems: totalValueGems ?? this.totalValueGems,
      totalItems: totalItems ?? this.totalItems,
      uniqueItems: uniqueItems ?? this.uniqueItems,
      totalSavings: totalSavings ?? this.totalSavings,
      currencyTotals: currencyTotals ?? this.currencyTotals,
    );
  }

  // Getters de conveniência
  bool get isEmpty => items.isEmpty;
  bool get hasItems => items.isNotEmpty;
  bool get isLoading =>
      loadingState != CartLoadingState.initial &&
      loadingState != CartLoadingState.success &&
      loadingState != CartLoadingState.error;
  bool get hasError => loadingState == CartLoadingState.error;
  bool get canPurchase => hasItems && !isLoading;

  /// Verifica se o usuário pode comprar o carrinho com o saldo atual
  bool canAfford(UserEntity user) {
    final coinsNeeded = currencyTotals[CurrencyType.coins] ?? 0;
    final gemsNeeded = currencyTotals[CurrencyType.gems] ?? 0;

    return user.coins >= coinsNeeded && user.gems >= gemsNeeded;
  }

  /// Obtém item do carrinho por ID
  CartItemEntity? getItemById(String itemId) {
    try {
      return items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se um shop item já está no carrinho
  bool containsShopItem(String shopItemId) {
    return items.any((item) => item.shopItem.id == shopItemId);
  }

  /// Obtém a quantidade total de um shop item no carrinho
  int getShopItemQuantity(String shopItemId) {
    final cartItem = items.where((item) => item.shopItem.id == shopItemId);
    return cartItem.fold(0, (sum, item) => sum + item.quantity);
  }
}

/// Notifier do carrinho de compras
class CartNotifier extends StateNotifier<CartState> {
  final AddToCart _addToCart;
  final RemoveFromCart _removeFromCart;
  final Ref _ref;

  Timer? _autoSaveTimer;
  static const Duration _autoSaveInterval = Duration(seconds: 30);

  CartNotifier(
    this._addToCart,
    this._removeFromCart,
    this._ref,
  ) : super(const CartState()) {
    _startAutoSave();
    _calculateTotals();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  /// Adiciona um item ao carrinho
  Future<void> addItem({
    required ShopItemEntity shopItem,
    required int quantity,
    required int userLevel,
    int userPurchaseCount = 0,
  }) async {
    if (quantity <= 0) {
      _setError(CartError.invalidQuantity);
      return;
    }

    // Verificar limite de itens no carrinho
    if (state.uniqueItems >= EconomyConstants.maxCartItems) {
      _setError(CartError.cartLimitExceeded);
      return;
    }

    state = state.copyWith(loadingState: CartLoadingState.addingItem);

    try {
      // Verificar se o item já existe no carrinho
      final existingItemIndex = state.items.indexWhere(
        (item) => item.shopItem.id == shopItem.id,
      );

      if (existingItemIndex != -1) {
        // Item já existe, atualizar quantidade
        await _updateItemQuantity(
          state.items[existingItemIndex].id,
          state.items[existingItemIndex].quantity + quantity,
          userLevel,
        );
      } else {
        // Novo item
        final result = await _addToCart(AddToCartParams(
          shopItem: shopItem,
          quantity: quantity,
          userLevel: userLevel,
          userPurchaseCount: userPurchaseCount,
        ));

        result.fold(
          (failure) => _setError(CartError.unknown, failure.message),
          (cartItem) {
            final updatedItems = [...state.items, cartItem];
            state = state.copyWith(
              items: updatedItems,
              loadingState: CartLoadingState.success,
              clearError: true,
            );
            _calculateTotals();
          },
        );
      }
    } catch (e) {
      _setError(CartError.unknown, 'Erro ao adicionar item: $e');
    }
  }

  /// Remove um item do carrinho
  Future<void> removeItem(String cartItemId) async {
    state = state.copyWith(loadingState: CartLoadingState.removingItem);

    try {
      final result = await _removeFromCart(RemoveFromCartParams(
        cartItemId: cartItemId,
        cartItems: state.items,
        removeType: RemoveType.removeCompletely,
      ));

      result.fold(
        (failure) => _setError(CartError.unknown, failure.message),
        (removeResult) {
          state = state.copyWith(
            items: removeResult.updatedCart,
            loadingState: CartLoadingState.success,
            clearError: true,
          );
          _calculateTotals();
        },
      );
    } catch (e) {
      _setError(CartError.unknown, 'Erro ao remover item: $e');
    }
  }

  /// Atualiza a quantidade de um item no carrinho
  Future<void> updateItemQuantity(String cartItemId, int newQuantity, int userLevel) async {
    if (newQuantity <= 0) {
      await removeItem(cartItemId);
      return;
    }

    await _updateItemQuantity(cartItemId, newQuantity, userLevel);
  }

  Future<void> _updateItemQuantity(String cartItemId, int newQuantity, int userLevel) async {
    if (newQuantity > EconomyConstants.maxQuantityPerItem) {
      _setError(CartError.invalidQuantity);
      return;
    }

    state = state.copyWith(loadingState: CartLoadingState.updatingQuantity);

    try {
      final itemIndex = state.items.indexWhere((item) => item.id == cartItemId);
      if (itemIndex == -1) {
        _setError(CartError.itemNotFound);
        return;
      }

      final item = state.items[itemIndex];
      final updatedItem = item.copyWith(quantity: newQuantity);

      final updatedItems = [...state.items];
      updatedItems[itemIndex] = updatedItem;

      state = state.copyWith(
        items: updatedItems,
        loadingState: CartLoadingState.success,
        clearError: true,
      );
      _calculateTotals();
    } catch (e) {
      _setError(CartError.unknown, 'Erro ao atualizar quantidade: $e');
    }
  }

  /// Limpa o carrinho completamente
  Future<void> clearCart() async {
    state = state.copyWith(loadingState: CartLoadingState.clearing);

    await Future.delayed(const Duration(milliseconds: 300));

    state = state.copyWith(
      items: [],
      loadingState: CartLoadingState.success,
      clearError: true,
    );
    _calculateTotals();
  }

  /// Valida o carrinho antes da compra
  CartValidation validateCart(UserEntity user) {
    if (state.isEmpty) {
      return CartValidation.exceedsLimits;
    }

    // Verificar saldo
    if (!state.canAfford(user)) {
      return CartValidation.insufficientBalance;
    }

    // Verificar disponibilidade dos itens
    final unavailableItems = state.items.where((item) => !item.isStillAvailable);
    if (unavailableItems.isNotEmpty) {
      return CartValidation.itemsUnavailable;
    }

    // Verificar se preços mudaram
    final changedPriceItems = state.items.where((item) => item.priceChanged);
    if (changedPriceItems.isNotEmpty) {
      return CartValidation.pricesChanged;
    }

    return CartValidation.valid;
  }

  /// Calcula os totais do carrinho
  void _calculateTotals() {
    if (state.items.isEmpty) {
      state = state.copyWith(
        status: CartStatus.empty,
        totalValue: 0,
        totalValueGems: 0,
        totalItems: 0,
        uniqueItems: 0,
        totalSavings: 0.0,
        currencyTotals: {},
      );
      return;
    }

    int coinsTotal = 0;
    int gemsTotal = 0;
    int itemsCount = 0;
    double savings = 0.0;

    for (final item in state.items) {
      itemsCount += item.quantity;

      if (item.currency == CurrencyType.coins) {
        coinsTotal += item.totalPrice;
      } else {
        gemsTotal += item.totalPrice;
      }

      // Calcular economia (se houver descontos)
      if (item.shopItem.hasActiveDiscount) {
        final fullPrice = item.shopItem.basePrice * item.quantity;
        savings += fullPrice - item.totalPrice;
      }
    }

    final currencyTotals = <CurrencyType, int>{};
    if (coinsTotal > 0) currencyTotals[CurrencyType.coins] = coinsTotal;
    if (gemsTotal > 0) currencyTotals[CurrencyType.gems] = gemsTotal;

    state = state.copyWith(
      status: CartStatus.hasItems,
      totalValue: coinsTotal,
      totalValueGems: gemsTotal,
      totalItems: itemsCount,
      uniqueItems: state.items.length,
      totalSavings: savings,
      currencyTotals: currencyTotals,
    );
  }

  /// Define um erro no estado
  void _setError(CartError error, [String? customMessage]) {
    state = state.copyWith(
      loadingState: CartLoadingState.error,
      lastError: error,
      errorMessage: customMessage ?? error.message,
    );
  }

  /// Inicia o auto-save do carrinho
  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(_autoSaveInterval, (_) {
      // Aqui implementaria a persistência do carrinho
      // Por enquanto apenas log
      print('Auto-saving cart with ${state.items.length} items');
    });
  }
}

/// Provider do carrinho de compras
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(
    AddToCart(), // Será injetado pelo dependencies_provider
    RemoveFromCart(), // Será injetado pelo dependencies_provider
    ref,
  );
});
