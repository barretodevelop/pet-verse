// lib/features/shop/application/providers/inventory_providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/economy/game_item.dart';
import 'package:petverse/core/providers/shop_provider.dart';

// Import base providers
// import 'shop_providers.dart';
// import '../../domain/models/shop_models.dart';

// =============================================================================
// INVENTORY-SPECIFIC PROVIDERS
// =============================================================================

// Inventory sorting options
enum InventorySortOption {
  newest,
  quantity,
  rarity,
  alphabetical,
  value,
}

// UI State for Inventory
final inventorySortProvider = StateProvider<InventorySortOption>((ref) {
  return InventorySortOption.newest;
});

final inventoryFilterRarityProvider = StateProvider<Set<ItemRarity>>((ref) {
  return <ItemRarity>{};
});

final selectedInventoryTabProvider = StateProvider<int>((ref) {
  return 0;
});

// =============================================================================
// COMPUTED INVENTORY PROVIDERS
// =============================================================================

// Sorted and filtered inventory
final sortedInventoryProvider = Provider<List<InventoryItem>>((ref) {
  final inventory = ref.watch(userInventoryProvider);
  final sortOption = ref.watch(inventorySortProvider);
  final rarityFilter = ref.watch(inventoryFilterRarityProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  // Apply filters
  List<InventoryItem> filtered = inventory;

  // Filter by rarity
  if (rarityFilter.isNotEmpty) {
    filtered = filtered
        .where((item) => rarityFilter.contains(item.item.rarity))
        .toList();
  }

  // Filter by search query
  if (searchQuery.isNotEmpty) {
    final lowerQuery = searchQuery.toLowerCase();
    filtered = filtered.where((item) {
      final name = item.item.name.toLowerCase();
      final description = item.item.description.toLowerCase();
      return name.contains(lowerQuery) || description.contains(lowerQuery);
    }).toList();
  }

  // Apply sorting
  switch (sortOption) {
    case InventorySortOption.newest:
      filtered.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
      break;
    case InventorySortOption.quantity:
      filtered.sort((a, b) => b.quantity.compareTo(a.quantity));
      break;
    case InventorySortOption.rarity:
      filtered
          .sort((a, b) => b.item.rarity.index.compareTo(a.item.rarity.index));
      break;
    case InventorySortOption.alphabetical:
      filtered.sort((a, b) => a.item.name.compareTo(b.item.name));
      break;
    case InventorySortOption.value:
      filtered.sort((a, b) => b.totalValue.compareTo(a.totalValue));
      break;
  }

  return filtered;
});

// Inventory by category with sorting
final sortedInventoryByCategoryProvider =
    Provider<Map<ItemCategory, List<InventoryItem>>>((ref) {
  final sortedInventory = ref.watch(sortedInventoryProvider);

  final Map<ItemCategory, List<InventoryItem>> categorized = {};

  for (final category in ItemCategory.values) {
    categorized[category] = sortedInventory
        .where((item) => item.item.category == category)
        .toList();
  }

  return categorized;
});

// Inventory statistics
final inventoryStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final inventory = ref.watch(userInventoryProvider);

  final totalItems = inventory.fold(0, (sum, item) => sum + item.quantity);
  final totalValue = inventory.fold(0.0, (sum, item) => sum + item.totalValue);
  final uniqueItems = inventory.length;

  // Category breakdown
  final categoryBreakdown = <ItemCategory, int>{};
  for (final category in ItemCategory.values) {
    categoryBreakdown[category] = inventory
        .where((item) => item.item.category == category)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  // Rarity breakdown
  final rarityBreakdown = <ItemRarity, int>{};
  for (final rarity in ItemRarity.values) {
    rarityBreakdown[rarity] = inventory
        .where((item) => item.item.rarity == rarity)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  // Most valuable items
  final mostValuable = [...inventory]
    ..sort((a, b) => b.totalValue.compareTo(a.totalValue));

  // Recently acquired
  final recentlyAcquired = inventory
      .where((item) => DateTime.now().difference(item.purchasedAt).inDays <= 7)
      .toList();

  return {
    'total_items': totalItems,
    'total_value': totalValue,
    'unique_items': uniqueItems,
    'category_breakdown': categoryBreakdown,
    'rarity_breakdown': rarityBreakdown,
    'most_valuable': mostValuable.take(5).toList(),
    'recently_acquired': recentlyAcquired,
    'average_value': uniqueItems > 0 ? totalValue / uniqueItems : 0.0,
  };
});

// Consumable items count
final consumableItemsProvider = Provider<List<InventoryItem>>((ref) {
  final inventory = ref.watch(userInventoryProvider);
  return inventory.where((item) => item.isConsumable).toList();
});

// Collectible items count
final collectibleItemsProvider = Provider<List<InventoryItem>>((ref) {
  final inventory = ref.watch(userInventoryProvider);
  return inventory.where((item) => !item.isConsumable).toList();
});

// Low stock items (quantity <= 2)
final lowStockItemsProvider = Provider<List<InventoryItem>>((ref) {
  final inventory = ref.watch(userInventoryProvider);
  return inventory.where((item) => item.quantity <= 2).toList();
});

// =============================================================================
// INVENTORY ACTIONS
// =============================================================================

// Bulk use items
final bulkUseItemProvider =
    Provider.family<Future<void>, Map<String, dynamic>>((ref, params) async {
  final itemId = params['itemId'] as String;
  final quantity = params['quantity'] as int;

  final inventoryNotifier = ref.read(userInventoryProvider.notifier);

  for (int i = 0; i < quantity; i++) {
    await inventoryNotifier.useItem(itemId);
  }
});

// Quick sort inventory
final quickSortInventoryProvider =
    Provider.family<void, InventorySortOption>((ref, sortOption) {
  ref.read(inventorySortProvider.notifier).state = sortOption;
});

// Clear all filters
final clearFiltersProvider = Provider<void>((ref) {
  ref.read(inventoryFilterRarityProvider.notifier).state = <ItemRarity>{};
  ref.read(searchQueryProvider.notifier).state = '';
  ref.read(inventorySortProvider.notifier).state = InventorySortOption.newest;
});

// =============================================================================
// INVENTORY HELPERS
// =============================================================================

class InventoryHelper {
  // Get total effect of using multiple items
  static Map<String, double> calculateTotalEffects(
      GameItem item, int quantity) {
    final Map<String, double> totalEffects = {};

    for (final effect in item.effects.entries) {
      totalEffects[effect.key] = effect.value * quantity;
    }

    return totalEffects;
  }

  // Check if item can be used
  static bool canUseItem(InventoryItem inventoryItem) {
    return inventoryItem.isConsumable && inventoryItem.quantity > 0;
  }

  // Get items that expire soon (if we add expiration later)
  static List<InventoryItem> getExpiringSoon(List<InventoryItem> inventory,
      {int days = 3}) {
    // For now, return empty list since items don't expire
    // Can be extended later if needed
    return [];
  }

  // Calculate inventory space (if we add limits later)
  static Map<String, int> calculateInventorySpace(
      List<InventoryItem> inventory) {
    final totalItems = inventory.fold(0, (sum, item) => sum + item.quantity);
    const maxItems = 1000; // Example limit

    return {
      'used': totalItems,
      'total': maxItems,
      'percentage': ((totalItems / maxItems) * 100).round(),
    };
  }

  // Get recommended items to use
  static List<InventoryItem> getRecommendedToUse(
      List<InventoryItem> inventory) {
    return inventory
        .where((item) =>
            item.isConsumable && item.quantity > 5) // High quantity items
        .toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));
  }
}

// =============================================================================
// INVENTORY SORT LABELS
// =============================================================================

extension InventorySortOptionExtension on InventorySortOption {
  String get displayName {
    switch (this) {
      case InventorySortOption.newest:
        return 'Mais recentes';
      case InventorySortOption.quantity:
        return 'Quantidade';
      case InventorySortOption.rarity:
        return 'Raridade';
      case InventorySortOption.alphabetical:
        return 'Nome A-Z';
      case InventorySortOption.value:
        return 'Valor';
    }
  }

  IconData get icon {
    switch (this) {
      case InventorySortOption.newest:
        return Icons.access_time;
      case InventorySortOption.quantity:
        return Icons.format_list_numbered;
      case InventorySortOption.rarity:
        return Icons.star;
      case InventorySortOption.alphabetical:
        return Icons.sort_by_alpha;
      case InventorySortOption.value:
        return Icons.monetization_on;
    }
  }
}
