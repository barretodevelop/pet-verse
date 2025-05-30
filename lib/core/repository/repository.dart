import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/economy/game_item.dart';
import 'package:petverse/core/model/mocks.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your models and mock data
// import 'shop_models.dart';
// import 'mock_data_service.dart';

// =============================================================================
// REPOSITORY INTERFACES (Firebase-ready)
// =============================================================================

abstract class WalletRepository {
  Future<UserWallet> getWallet(String userId);
  Future<void> saveWallet(String userId, UserWallet wallet);
  Stream<UserWallet> watchWallet(String userId);
  Future<void> addCurrency(String userId, {int? coins, int? gems});
}

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventory(String userId);
  Future<void> addItem(String userId, InventoryItem item);
  Future<void> removeItem(String userId, String itemId, {int quantity = 1});
  Future<void> useItem(String userId, String itemId, {int quantity = 1});
  Future<void> updateItemQuantity(
      String userId, String itemId, int newQuantity);
  Stream<List<InventoryItem>> watchInventory(String userId);
  Future<int> getItemQuantity(String userId, String itemId);
}

abstract class ShopRepository {
  Future<List<GameItem>> getShopItems();
  Future<GameItem?> getShopItem(String itemId);
  Stream<List<GameItem>> watchShopItems();
  Future<List<GameItem>> getItemsByCategory(ItemCategory category);
  Future<List<GameItem>> getItemsByRarity(ItemRarity rarity);
  Future<List<GameItem>> searchItems(String query);
}

// =============================================================================
// LOCAL IMPLEMENTATIONS (SharedPreferences + Mock)
// =============================================================================

class LocalWalletRepository implements WalletRepository {
  static const String _walletKey = 'user_wallet_v2';
  final StreamController<UserWallet> _walletController =
      StreamController<UserWallet>.broadcast();

  @override
  Future<UserWallet> getWallet(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final walletString = prefs.getString('${_walletKey}_$userId');

      if (walletString != null) {
        final walletData = json.decode(walletString);
        return UserWalletFactory.fromMockData(walletData);
      }
    } catch (e) {
      debugPrint('Error loading wallet: $e');
    }

    // Return default wallet
    final defaultWallet =
        UserWalletFactory.fromMockData(MockDataService.getInitialWalletData());
    await saveWallet(userId, defaultWallet);
    return defaultWallet;
  }

  @override
  Future<void> saveWallet(String userId, UserWallet wallet) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final walletJson = json.encode(wallet.toJson());
      await prefs.setString('${_walletKey}_$userId', walletJson);

      // Emit to stream
      _walletController.add(wallet);
    } catch (e) {
      debugPrint('Error saving wallet: $e');
      rethrow;
    }
  }

  @override
  Stream<UserWallet> watchWallet(String userId) {
    // Start with current wallet
    getWallet(userId).then((wallet) {
      if (!_walletController.isClosed) {
        _walletController.add(wallet);
      }
    });

    return _walletController.stream;
  }

  @override
  Future<void> addCurrency(String userId, {int? coins, int? gems}) async {
    final currentWallet = await getWallet(userId);
    final updatedWallet = currentWallet.addCurrency(coins: coins, gems: gems);
    await saveWallet(userId, updatedWallet);
  }

  void dispose() {
    _walletController.close();
  }
}

class LocalInventoryRepository implements InventoryRepository {
  static const String _inventoryKey = 'user_inventory_v2';
  final StreamController<List<InventoryItem>> _inventoryController =
      StreamController<List<InventoryItem>>.broadcast();

  @override
  Future<List<InventoryItem>> getInventory(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inventoryString = prefs.getString('${_inventoryKey}_$userId');

      if (inventoryString != null) {
        final inventoryData = json.decode(inventoryString) as List;
        return InventoryItemFactory.fromMockDataList(
            inventoryData.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint('Error loading inventory: $e');
    }

    // Return default inventory
    final defaultInventory = InventoryItemFactory.fromMockDataList(
        MockDataService.getInitialInventoryData());
    await _saveInventory(userId, defaultInventory);
    return defaultInventory;
  }

  @override
  Future<void> addItem(String userId, InventoryItem item) async {
    final inventory = await getInventory(userId);
    final existingIndex =
        inventory.indexWhere((inv) => inv.item.id == item.item.id);

    if (existingIndex != -1) {
      // Update existing item quantity
      inventory[existingIndex] = inventory[existingIndex].copyWith(
        quantity: inventory[existingIndex].quantity + item.quantity,
      );
    } else {
      // Add new item
      inventory.add(item);
    }

    await _saveInventory(userId, inventory);
  }

  @override
  Future<void> removeItem(String userId, String itemId,
      {int quantity = 1}) async {
    final inventory = await getInventory(userId);
    final existingIndex = inventory.indexWhere((inv) => inv.item.id == itemId);

    if (existingIndex != -1) {
      final currentItem = inventory[existingIndex];
      if (currentItem.quantity <= quantity) {
        // Remove item completely
        inventory.removeAt(existingIndex);
      } else {
        // Decrease quantity
        inventory[existingIndex] = currentItem.copyWith(
          quantity: currentItem.quantity - quantity,
        );
      }

      await _saveInventory(userId, inventory);
    }
  }

  @override
  Future<void> useItem(String userId, String itemId, {int quantity = 1}) async {
    final inventory = await getInventory(userId);
    final existingIndex = inventory.indexWhere((inv) => inv.item.id == itemId);

    if (existingIndex != -1) {
      final currentItem = inventory[existingIndex];
      if (currentItem.quantity <= quantity) {
        // Mark as used and remove
        inventory[existingIndex] = currentItem.copyWith(
          quantity: 0,
          usedAt: DateTime.now(),
        );
        inventory.removeAt(existingIndex);
      } else {
        // Decrease quantity
        inventory[existingIndex] = currentItem.copyWith(
          quantity: currentItem.quantity - quantity,
        );
      }

      await _saveInventory(userId, inventory);
    }
  }

  @override
  Future<void> updateItemQuantity(
      String userId, String itemId, int newQuantity) async {
    final inventory = await getInventory(userId);
    final existingIndex = inventory.indexWhere((inv) => inv.item.id == itemId);

    if (existingIndex != -1) {
      if (newQuantity <= 0) {
        inventory.removeAt(existingIndex);
      } else {
        inventory[existingIndex] = inventory[existingIndex].copyWith(
          quantity: newQuantity,
        );
      }

      await _saveInventory(userId, inventory);
    }
  }

  @override
  Stream<List<InventoryItem>> watchInventory(String userId) {
    // Start with current inventory
    getInventory(userId).then((inventory) {
      if (!_inventoryController.isClosed) {
        _inventoryController.add(inventory);
      }
    });

    return _inventoryController.stream;
  }

  @override
  Future<int> getItemQuantity(String userId, String itemId) async {
    final inventory = await getInventory(userId);
    final item = inventory.firstWhere(
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

  Future<void> _saveInventory(
      String userId, List<InventoryItem> inventory) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final inventoryJson = json.encode(
        inventory.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('${_inventoryKey}_$userId', inventoryJson);

      // Emit to stream
      _inventoryController.add(inventory);
    } catch (e) {
      debugPrint('Error saving inventory: $e');
      rethrow;
    }
  }

  void dispose() {
    _inventoryController.close();
  }
}

class MockShopRepository implements ShopRepository {
  static final List<GameItem> _cachedItems = [];
  static DateTime? _lastCacheUpdate;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  @override
  Future<List<GameItem>> getShopItems() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Check cache
    if (_cachedItems.isNotEmpty &&
        _lastCacheUpdate != null &&
        DateTime.now().difference(_lastCacheUpdate!) < _cacheTimeout) {
      return List.from(_cachedItems);
    }

    // Load fresh data
    final mockData = MockDataService.getShopItemsData();
    _cachedItems.clear();
    _cachedItems.addAll(GameItemFactory.fromMockDataList(mockData));
    _lastCacheUpdate = DateTime.now();

    return List.from(_cachedItems);
  }

  @override
  Future<GameItem?> getShopItem(String itemId) async {
    final allItems = await getShopItems();
    try {
      return allItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<List<GameItem>> watchShopItems() {
    return Stream.periodic(const Duration(minutes: 5), (_) async {
      return await getShopItems();
    }).asyncMap((future) => future);
  }

  @override
  Future<List<GameItem>> getItemsByCategory(ItemCategory category) async {
    final allItems = await getShopItems();
    return allItems
        .where((item) => item.category == category && item.isActive)
        .toList();
  }

  @override
  Future<List<GameItem>> getItemsByRarity(ItemRarity rarity) async {
    final allItems = await getShopItems();
    return allItems
        .where((item) => item.rarity == rarity && item.isActive)
        .toList();
  }

  @override
  Future<List<GameItem>> searchItems(String query) async {
    if (query.isEmpty) return await getShopItems();

    final allItems = await getShopItems();
    final lowerQuery = query.toLowerCase();

    return allItems.where((item) {
      if (!item.isActive) return false;

      final name = item.name.toLowerCase();
      final description = item.description.toLowerCase();

      return name.contains(lowerQuery) || description.contains(lowerQuery);
    }).toList();
  }

  // Clear cache (useful for testing or force refresh)
  static void clearCache() {
    _cachedItems.clear();
    _lastCacheUpdate = null;
  }
}

// =============================================================================
// REPOSITORY EXCEPTIONS
// =============================================================================

class RepositoryException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  RepositoryException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'RepositoryException: $message';
}

class InsufficientFundsException extends RepositoryException {
  InsufficientFundsException() : super('Saldo insuficiente para esta compra');
}

class ItemNotFoundException extends RepositoryException {
  ItemNotFoundException(String itemId) : super('Item não encontrado: $itemId');
}

class InventoryException extends RepositoryException {
  InventoryException(super.message);
}

// =============================================================================
// REPOSITORY HELPERS
// =============================================================================

class RepositoryHelper {
  static Future<bool> isConnected() async {
    // Simulate network check
    await Future.delayed(const Duration(milliseconds: 100));
    return true; // For mock, always connected
  }

  static String generateUniqueId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  static Future<void> clearAllLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs
          .getKeys()
          .where((key) =>
              key.startsWith('user_wallet_') ||
              key.startsWith('user_inventory_'))
          .toList();

      for (String key in keys) {
        await prefs.remove(key);
      }

      MockShopRepository.clearCache();
    } catch (e) {
      debugPrint('Error clearing local data: $e');
    }
  }

  static Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys().toList();
      final shopKeys = allKeys
          .where((key) =>
              key.startsWith('user_wallet_') ||
              key.startsWith('user_inventory_'))
          .toList();

      return {
        'total_keys': allKeys.length,
        'shop_keys': shopKeys.length,
        'cache_items': MockShopRepository._cachedItems.length,
        'last_cache_update':
            MockShopRepository._lastCacheUpdate?.toIso8601String(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
