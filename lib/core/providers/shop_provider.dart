import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/economy/game_item.dart';
import 'package:petverse/core/repository/repository.dart';

// Import your models and repositories
// import 'shop_models.dart';
// import 'shop_repositories.dart';

// =============================================================================
// CORE PROVIDERS
// =============================================================================

// Mock user for development - In production: Firebase Auth user ID
final currentUserProvider = Provider<String>((ref) {
  return 'dev_user_123'; // Will be replaced with Firebase Auth
});

// Repository providers - Easy to switch between Local/Firebase
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return LocalWalletRepository(); // Will switch to FirebaseWalletRepository
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return LocalInventoryRepository(); // Will switch to FirebaseInventoryRepository
});

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return MockShopRepository(); // Will switch to FirebaseShopRepository
});

// =============================================================================
// STATE PROVIDERS
// =============================================================================

// UI State
final selectedCategoryProvider = StateProvider<ItemCategory>((ref) {
  return ItemCategory.food;
});

final isLoadingPurchaseProvider = StateProvider<bool>((ref) {
  return false;
});

final searchQueryProvider = StateProvider<String>((ref) {
  return '';
});

// =============================================================================
// BUSINESS LOGIC PROVIDERS
// =============================================================================

// Wallet Provider
final userWalletProvider =
    StateNotifierProvider<WalletNotifier, UserWallet>((ref) {
  final repository = ref.read(walletRepositoryProvider);
  final userId = ref.read(currentUserProvider);
  return WalletNotifier(repository, userId);
});

// Inventory Provider
final userInventoryProvider =
    StateNotifierProvider<InventoryNotifier, List<InventoryItem>>((ref) {
  final repository = ref.read(inventoryRepositoryProvider);
  final userId = ref.read(currentUserProvider);
  return InventoryNotifier(repository, userId);
});

// =============================================================================
// DATA PROVIDERS
// =============================================================================

// All shop items
final shopItemsProvider = FutureProvider<List<GameItem>>((ref) async {
  final repository = ref.read(shopRepositoryProvider);
  return await repository.getShopItems();
});

// Filtered shop items by category
final filteredShopItemsProvider = Provider<AsyncValue<List<GameItem>>>((ref) {
  final shopItemsAsync = ref.watch(shopItemsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return shopItemsAsync.when(
    data: (items) {
      final filtered = items
          .where((item) => item.category == selectedCategory && item.isActive)
          .toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Search results
final searchResultsProvider = FutureProvider<List<GameItem>>((ref) async {
  final repository = ref.read(shopRepositoryProvider);
  final query = ref.watch(searchQueryProvider);

  if (query.isEmpty) {
    return await repository.getShopItems();
  }

  return await repository.searchItems(query);
});

// Inventory by category
final inventoryByCategoryProvider =
    Provider<Map<ItemCategory, List<InventoryItem>>>((ref) {
  final inventory = ref.watch(userInventoryProvider);

  final Map<ItemCategory, List<InventoryItem>> categorized = {};

  for (final category in ItemCategory.values) {
    categorized[category] =
        inventory.where((item) => item.item.category == category).toList();
  }

  return categorized;
});

// Statistics providers
final walletStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final wallet = ref.watch(userWalletProvider);
  final inventory = ref.watch(userInventoryProvider);

  final totalItems = inventory.fold(0, (sum, item) => sum + item.quantity);
  final totalValue = inventory.fold(0.0, (sum, item) => sum + item.totalValue);

  return {
    'coins': wallet.coins,
    'gems': wallet.gems,
    'total_items': totalItems,
    'total_inventory_value': totalValue,
    'last_updated': wallet.lastUpdated,
  };
});

// =============================================================================
// BUSINESS LOGIC NOTIFIERS
// =============================================================================

class WalletNotifier extends StateNotifier<UserWallet> {
  final WalletRepository _repository;
  final String _userId;

  WalletNotifier(this._repository, this._userId)
      : super(UserWallet(coins: 0, gems: 0)) {
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final wallet = await _repository.getWallet(_userId);
      if (mounted) {
        state = wallet;
      }
    } catch (e) {
      debugPrint('Error loading wallet: $e');
      // Keep default state on error
    }
  }

  Future<void> _saveWallet() async {
    try {
      await _repository.saveWallet(_userId, state);
    } catch (e) {
      debugPrint('Error saving wallet: $e');
      rethrow;
    }
  }

  // Business logic methods
  bool canAfford(GameItem item) {
    return state.canAfford(item);
  }

  Future<void> purchaseItem(GameItem item) async {
    if (!canAfford(item)) {
      throw InsufficientFundsException();
    }

    final newWallet = state.afterPurchase(item);
    state = newWallet;

    await _saveWallet();
  }

  Future<void> addCurrency({int? coins, int? gems}) async {
    state = state.addCurrency(coins: coins, gems: gems);
    await _saveWallet();
  }

  Future<void> resetWallet() async {
    state = UserWallet(coins: 1250, gems: 25, lastUpdated: DateTime.now());
    await _saveWallet();
  }

  // For daily rewards, achievements, etc.
  Future<void> addReward(Map<String, int> reward) async {
    await addCurrency(coins: reward['coins'], gems: reward['gems']);
  }
}

class InventoryNotifier extends StateNotifier<List<InventoryItem>> {
  final InventoryRepository _repository;
  final String _userId;

  InventoryNotifier(this._repository, this._userId) : super([]) {
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    try {
      final inventory = await _repository.getInventory(_userId);
      if (mounted) {
        state = inventory;
      }
    } catch (e) {
      debugPrint('Error loading inventory: $e');
    }
  }

  Future<void> addItem(GameItem item, {int quantity = 1}) async {
    try {
      final inventoryItem = InventoryItem(
        item: item,
        quantity: quantity,
        purchasedAt: DateTime.now(),
      );

      await _repository.addItem(_userId, inventoryItem);

      // Update local state optimistically
      final existingIndex = state.indexWhere((inv) => inv.item.id == item.id);
      if (existingIndex != -1) {
        state = [
          ...state.sublist(0, existingIndex),
          state[existingIndex].copyWith(
            quantity: state[existingIndex].quantity + quantity,
          ),
          ...state.sublist(existingIndex + 1),
        ];
      } else {
        state = [...state, inventoryItem];
      }
    } catch (e) {
      debugPrint('Error adding item to inventory: $e');
      rethrow;
    }
  }

  Future<void> removeItem(String itemId, {int quantity = 1}) async {
    try {
      await _repository.removeItem(_userId, itemId, quantity: quantity);

      // Update local state optimistically
      final existingIndex = state.indexWhere((inv) => inv.item.id == itemId);
      if (existingIndex != -1) {
        final currentItem = state[existingIndex];
        if (currentItem.quantity <= quantity) {
          state = state.where((inv) => inv.item.id != itemId).toList();
        } else {
          state = [
            ...state.sublist(0, existingIndex),
            currentItem.copyWith(quantity: currentItem.quantity - quantity),
            ...state.sublist(existingIndex + 1),
          ];
        }
      }
    } catch (e) {
      debugPrint('Error removing item from inventory: $e');
      rethrow;
    }
  }

  Future<void> useItem(String itemId, {int quantity = 1}) async {
    try {
      await _repository.useItem(_userId, itemId, quantity: quantity);

      // Update local state
      final existingIndex = state.indexWhere((inv) => inv.item.id == itemId);
      if (existingIndex != -1) {
        final currentItem = state[existingIndex];
        if (currentItem.quantity <= quantity) {
          state = state.where((inv) => inv.item.id != itemId).toList();
        } else {
          state = [
            ...state.sublist(0, existingIndex),
            currentItem.copyWith(quantity: currentItem.quantity - quantity),
            ...state.sublist(existingIndex + 1),
          ];
        }
      }
    } catch (e) {
      debugPrint('Error using item: $e');
      rethrow;
    }
  }

  Future<void> updateItemQuantity(String itemId, int newQuantity) async {
    try {
      await _repository.updateItemQuantity(_userId, itemId, newQuantity);

      final existingIndex = state.indexWhere((inv) => inv.item.id == itemId);
      if (existingIndex != -1) {
        if (newQuantity <= 0) {
          state = state.where((inv) => inv.item.id != itemId).toList();
        } else {
          state = [
            ...state.sublist(0, existingIndex),
            state[existingIndex].copyWith(quantity: newQuantity),
            ...state.sublist(existingIndex + 1),
          ];
        }
      }
    } catch (e) {
      debugPrint('Error updating item quantity: $e');
      rethrow;
    }
  }

  int getItemQuantity(String itemId) {
    final item = state.firstWhere(
      (inv) => inv.item.id == itemId,
      orElse: () => InventoryItem(
        item: GameItem(
          id: '',
          name: '',
          emoji: '',
          category: ItemCategory.food,
          rarity: ItemRarity.common,
          effects: {},
          description: '',
        ),
        quantity: 0,
        purchasedAt: DateTime.now(),
      ),
    );
    return item.quantity;
  }

  bool hasItem(String itemId) {
    return getItemQuantity(itemId) > 0;
  }

  List<InventoryItem> getItemsByCategory(ItemCategory category) {
    return state.where((inv) => inv.item.category == category).toList();
  }

  Future<void> clearInventory() async {
    try {
      for (final item in state) {
        await _repository.removeItem(_userId, item.item.id,
            quantity: item.quantity);
      }
      state = [];
    } catch (e) {
      debugPrint('Error clearing inventory: $e');
      rethrow;
    }
  }
}

// =============================================================================
// COMPUTED PROVIDERS
// =============================================================================

// Categories with item counts
final categoriesWithCountProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final shopItemsAsync = ref.watch(shopItemsProvider);

  return shopItemsAsync.when(
    data: (items) {
      return ItemCategory.values.map((category) {
        final count = items
            .where((item) => item.category == category && item.isActive)
            .length;

        return {
          'category': category,
          'name': category.displayName,
          'emoji': category.emoji,
          'count': count,
          'description': category.description,
        };
      }).toList();
    },
    loading: () => ItemCategory.values
        .map((category) => {
              'category': category,
              'name': category.displayName,
              'emoji': category.emoji,
              'count': 0,
              'description': category.description,
            })
        .toList(),
    error: (_, __) => ItemCategory.values
        .map((category) => {
              'category': category,
              'name': category.displayName,
              'emoji': category.emoji,
              'count': 0,
              'description': category.description,
            })
        .toList(),
  );
});

// Affordable items for current wallet
final affordableItemsProvider = Provider<AsyncValue<List<GameItem>>>((ref) {
  final shopItemsAsync = ref.watch(shopItemsProvider);
  final wallet = ref.watch(userWalletProvider);

  return shopItemsAsync.when(
    data: (items) {
      final affordable = items.where((item) => wallet.canAfford(item)).toList();
      return AsyncValue.data(affordable);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Items by rarity with counts
final rarityStatsProvider = Provider<Map<ItemRarity, int>>((ref) {
  final shopItemsAsync = ref.watch(shopItemsProvider);

  return shopItemsAsync.when(
    data: (items) {
      final Map<ItemRarity, int> rarityCount = {};

      for (final rarity in ItemRarity.values) {
        rarityCount[rarity] = items
            .where((item) => item.rarity == rarity && item.isActive)
            .length;
      }

      return rarityCount;
    },
    loading: () =>
        Map.fromEntries(ItemRarity.values.map((rarity) => MapEntry(rarity, 0))),
    error: (_, __) =>
        Map.fromEntries(ItemRarity.values.map((rarity) => MapEntry(rarity, 0))),
  );
});

// Recent purchases (last 7 days)
final recentPurchasesProvider = Provider<List<InventoryItem>>((ref) {
  final inventory = ref.watch(userInventoryProvider);
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

  return inventory
      .where((item) => item.purchasedAt.isAfter(sevenDaysAgo))
      .toList()
    ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
});

// =============================================================================
// ACTION PROVIDERS
// =============================================================================

final purchaseItemProvider =
    Provider.family<Future<void>, GameItem>((ref, item) async {
  final walletNotifier = ref.read(userWalletProvider.notifier);
  final inventoryNotifier = ref.read(userInventoryProvider.notifier);

  // Check if can afford
  if (!walletNotifier.canAfford(item)) {
    throw InsufficientFundsException();
  }

  // Process purchase
  await walletNotifier.purchaseItem(item);
  await inventoryNotifier.addItem(item);
});

final useItemProvider =
    Provider.family<Future<void>, String>((ref, itemId) async {
  final inventoryNotifier = ref.read(userInventoryProvider.notifier);

  // Check if item exists
  if (!inventoryNotifier.hasItem(itemId)) {
    throw ItemNotFoundException(itemId);
  }

  // Use item
  await inventoryNotifier.useItem(itemId);
});

// =============================================================================
// UTILITY PROVIDERS
// =============================================================================

final debugInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final wallet = ref.read(userWalletProvider);
  final inventory = ref.read(userInventoryProvider);
  final shopItemsAsync = ref.read(shopItemsProvider);

  final shopItems = shopItemsAsync.when(
    data: (items) => items.length,
    loading: () => 0,
    error: (_, __) => -1,
  );

  return {
    'user_id': ref.read(currentUserProvider),
    'wallet': {
      'coins': wallet.coins,
      'gems': wallet.gems,
      'last_updated': wallet.lastUpdated?.toIso8601String(),
    },
    'inventory': {
      'total_items': inventory.fold(0, (sum, item) => sum + item.quantity),
      'unique_items': inventory.length,
      'categories':
          inventory.map((item) => item.item.category.name).toSet().length,
    },
    'shop': {
      'total_items': shopItems,
    },
    'timestamp': DateTime.now().toIso8601String(),
  };
});

// Reset all data provider
final resetAllDataProvider = Provider<Future<void>>((ref) async {
  final walletNotifier = ref.read(userWalletProvider.notifier);
  final inventoryNotifier = ref.read(userInventoryProvider.notifier);

  await walletNotifier.resetWallet();
  await inventoryNotifier.clearInventory();

  // Clear local cache
  await RepositoryHelper.clearAllLocalData();

  // Refresh all providers
  ref.invalidate(shopItemsProvider);
  ref.invalidate(userWalletProvider);
  ref.invalidate(userInventoryProvider);
});
