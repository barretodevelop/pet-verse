// File: lib/presentation/providers/inventory_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';

// class InventoryState {
//   final List<InventoryItemEntity> items;
//   final LoadingState status;
//   final String? errorMessage;

//   const InventoryState({
//     this.items = const [],
//     this.status = LoadingState.initial,
//     this.errorMessage,
//   });

//   InventoryState copyWith({
//     List<InventoryItemEntity>? items,
//     LoadingState? status,
//     String? errorMessage,
//     bool clearError = false,
//   }) {
//     return InventoryState(
//       items: items ?? this.items,
//       status: status ?? this.status,
//       errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
//     );
//   }

//   // Get item with shop data
//   List<InventoryItemWithData> get itemsWithData {
//     return items
//         .map((inventoryItem) {
//           final shopItem = ShopService.getItemById(inventoryItem.itemId);
//           return InventoryItemWithData(
//             inventoryItem: inventoryItem,
//             shopItem: shopItem,
//           );
//         })
//         .where((item) => item.shopItem != null)
//         .toList();
//   }

//   bool get isLoading => status == LoadingState.loading;
//   bool get hasError => status == LoadingState.error;
// }

// class InventoryItemWithData {
//   final InventoryItemEntity inventoryItem;
//   final ShopItemEntity? shopItem;

//   InventoryItemWithData({
//     required this.inventoryItem,
//     required this.shopItem,
//   });
// }

// class InventoryNotifier extends StateNotifier<InventoryState> {
//   final Ref _ref;

//   InventoryNotifier(this._ref) : super(const InventoryState()) {
//     _listenToAuthChanges();
//   }

//   void _listenToAuthChanges() {
//     _ref.listen<AuthState>(authProvider, (previous, next) {
//       if (next.isAuthenticated && next.firebaseUser != null) {
//         loadInventory();
//       } else {
//         state = const InventoryState();
//       }
//     });

//     final authState = _ref.read(authProvider);
//     if (authState.isAuthenticated && authState.firebaseUser != null) {
//       loadInventory();
//     }
//   }

//   Future<void> loadInventory() async {
//     final authState = _ref.read(authProvider);
//     if (!authState.isAuthenticated || authState.firebaseUser == null) return;

//     state = state.copyWith(status: LoadingState.loading);

//     // TODO: Load from Firestore
//     // For now, use mock data
//     final mockItems = [
//       InventoryItemEntity(
//         id: '1',
//         itemId: 'food_basic_meat',
//         userId: authState.firebaseUser!.uid,
//         quantity: 5,
//         acquiredAt: DateTime.now(),
//       ),
//     ];

//     state = state.copyWith(
//       items: mockItems,
//       status: LoadingState.success,
//     );
//   }

//   Future<ItemActionResult> addItem(String itemId, int quantity) async {
//     final authState = _ref.read(authProvider);
//     if (!authState.isAuthenticated || authState.firebaseUser == null) {
//       return ItemActionResult(success: false, message: 'User not authenticated');
//     }

//     final existingItemIndex = state.items.indexWhere((item) => item.itemId == itemId);
//     List<InventoryItemEntity> updatedItems = [...state.items];

//     if (existingItemIndex >= 0) {
//       // Update existing item quantity
//       final existingItem = updatedItems[existingItemIndex];
//       updatedItems[existingItemIndex] = existingItem.copyWith(
//         quantity: existingItem.quantity + quantity,
//       );
//     } else {
//       // Add new item
//       final newItem = InventoryItemEntity(
//         id: Helpers.generateId(),
//         itemId: itemId,
//         userId: authState.firebaseUser!.uid,
//         quantity: quantity,
//         acquiredAt: DateTime.now(),
//       );
//       updatedItems.add(newItem);
//     }

//     state = state.copyWith(items: updatedItems);

//     // TODO: Save to Firestore

//     return ItemActionResult(success: true, message: 'Item added to inventory');
//   }

//   Future<ItemActionResult> useItem(String itemId, int quantity, String targetPetId) async {
//     final itemIndex = state.items.indexWhere((item) => item.itemId == itemId);
//     if (itemIndex < 0) {
//       return ItemActionResult(success: false, message: 'Item not found in inventory');
//     }

//     final inventoryItem = state.items[itemIndex];
//     if (inventoryItem.quantity < quantity) {
//       return ItemActionResult(success: false, message: 'Insufficient quantity');
//     }

//     final shopItem = ShopService.getItemById(itemId);
//     if (shopItem == null) {
//       return ItemActionResult(success: false, message: 'Item data not found');
//     }

//     // Apply item effects to pet
//     final petProvider = _ref.read(enhancedPetGameProvider.notifier);
//     final applyResult = await _applyItemEffectsToPet(shopItem, targetPetId);

//     if (!applyResult.success) {
//       return applyResult;
//     }

//     // Remove item from inventory
//     List<InventoryItemEntity> updatedItems = [...state.items];
//     if (inventoryItem.quantity == quantity) {
//       updatedItems.removeAt(itemIndex);
//     } else {
//       updatedItems[itemIndex] = inventoryItem.copyWith(
//         quantity: inventoryItem.quantity - quantity,
//       );
//     }

//     state = state.copyWith(items: updatedItems);

//     // TODO: Save to Firestore

//     return ItemActionResult(
//       success: true,
//       message: 'Used ${shopItem.name} on pet!',
//     );
//   }

//   Future<ItemActionResult> _applyItemEffectsToPet(ShopItemEntity item, String petId) async {
//     // TODO: Apply effects to specific pet
//     // This would integrate with the pet system to modify pet stats
//     return ItemActionResult(
//       success: true,
//       message: 'Effects applied to pet',
//     );
//   }
// }

// final inventoryProvider = StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
//   return InventoryNotifier(ref);
// });

// class ItemActionResult {
//   final bool success;
//   final String message;

//   ItemActionResult({required this.success, required this.message});
// }

/// Inventory provider for managing user's items
class InventoryState {
  final List<InventoryItem> items;
  final LoadingState status;
  final String? errorMessage;
  final bool isUsingItem;

  const InventoryState({
    this.items = const [],
    this.status = LoadingState.initial,
    this.errorMessage,
    this.isUsingItem = false,
  });

  InventoryState copyWith({
    List<InventoryItem>? items,
    LoadingState? status,
    String? errorMessage,
    bool clearError = false,
    bool? isUsingItem,
  }) {
    return InventoryState(
      items: items ?? this.items,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isUsingItem: isUsingItem ?? this.isUsingItem,
    );
  }

  bool get isLoading => status == LoadingState.loading;
  bool get hasError => status == LoadingState.error;
  bool get hasItems => items.isNotEmpty;

  int getItemQuantity(String itemId) {
    try {
      return items.firstWhere((item) => item.shopItemId == itemId).quantity;
    } catch (e) {
      return 0;
    }
  }

  List<InventoryItem> getItemsByCategory(ItemCategory category) {
    return items.where((item) => item.category == category).toList();
  }
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  InventoryNotifier() : super(const InventoryState()) {
    _loadInventory();
  }

  void _loadInventory() {
    // Mock inventory items
    final mockItems = [
      InventoryItem(
        id: '1',
        userId: 'user1',
        shopItemId: '1',
        name: 'Premium Food',
        category: ItemCategory.food,
        quantity: 3,
        effects: {ItemEffectType.hunger: 50},
        imageUrl: 'food_premium.png',
      ),
      InventoryItem(
        id: '2',
        userId: 'user1',
        shopItemId: '2',
        name: 'Super Toy',
        category: ItemCategory.toy,
        quantity: 1,
        effects: {ItemEffectType.happiness: 40},
        imageUrl: 'toy_ball.png',
      ),
    ];

    state = state.copyWith(
      items: mockItems,
      status: LoadingState.success,
    );
  }

  void addItem(ShopItem shopItem, int quantity) {
    final existingItemIndex = state.items.indexWhere(
      (item) => item.shopItemId == shopItem.id,
    );

    List<InventoryItem> updatedItems;

    if (existingItemIndex != -1) {
      // Update existing item quantity
      updatedItems = [...state.items];
      updatedItems[existingItemIndex] = updatedItems[existingItemIndex].copyWith(
        quantity: updatedItems[existingItemIndex].quantity + quantity,
      );
    } else {
      // Add new item
      final newInventoryItem = InventoryItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'user1', // Should come from auth
        shopItemId: shopItem.id,
        name: shopItem.name,
        category: shopItem.category,
        quantity: quantity,
        effects: shopItem.effects,
        imageUrl: shopItem.imageUrl,
      );
      updatedItems = [...state.items, newInventoryItem];
    }

    state = state.copyWith(items: updatedItems);
  }

  Future<UseItemResult> useItem(String itemId, String petId) async {
    state = state.copyWith(isUsingItem: true);

    final item = state.items.firstWhere((item) => item.id == itemId);

    // Simulate using item
    await Future.delayed(const Duration(milliseconds: 500));

    // Decrease quantity
    if (item.quantity > 1) {
      final updatedItems = state.items.map((inventoryItem) {
        if (inventoryItem.id == itemId) {
          return inventoryItem.copyWith(quantity: inventoryItem.quantity - 1);
        }
        return inventoryItem;
      }).toList();

      state = state.copyWith(items: updatedItems, isUsingItem: false);
    } else {
      // Remove item if quantity is 1
      final updatedItems =
          state.items.where((inventoryItem) => inventoryItem.id != itemId).toList();
      state = state.copyWith(items: updatedItems, isUsingItem: false);
    }

    return UseItemResult(
      success: true,
      message: '${item.name} used on pet successfully!',
      effects: item.effects,
    );
  }
}

final inventoryProvider = StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  return InventoryNotifier();
});
