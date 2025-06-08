// File: lib/presentation/providers/shop_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';

// class ShopState {
//   final List<ShopItemEntity> items;
//   final ItemType? selectedCategory;
//   final LoadingState status;
//   final String? errorMessage;

//   const ShopState({
//     this.items = const [],
//     this.selectedCategory,
//     this.status = LoadingState.initial,
//     this.errorMessage,
//   });

//   ShopState copyWith({
//     List<ShopItemEntity>? items,
//     ItemType? selectedCategory,
//     bool clearCategory = false,
//     LoadingState? status,
//     String? errorMessage,
//     bool clearError = false,
//   }) {
//     return ShopState(
//       items: items ?? this.items,
//       selectedCategory: clearCategory ? null : selectedCategory ?? this.selectedCategory,
//       status: status ?? this.status,
//       errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
//     );
//   }

//   bool get isLoading => status == LoadingState.loading;
//   bool get hasError => status == LoadingState.error;
// }

// class ShopNotifier extends StateNotifier<ShopState> {
//   final Ref _ref;

//   ShopNotifier(this._ref) : super(const ShopState()) {
//     loadAllItems();
//   }

//   void loadAllItems() {
//     state = state.copyWith(status: LoadingState.loading);
//     final items = ShopService.getAllItems();
//     state = state.copyWith(
//       items: items,
//       status: LoadingState.success,
//     );
//   }

//   void filterByCategory(ItemType? category) {
//     final filteredItems =
//         category == null ? ShopService.getAllItems() : ShopService.getItemsByCategory(category);

//     state = state.copyWith(
//       items: filteredItems,
//       selectedCategory: category,
//       clearCategory: category == null,
//     );
//   }

//   Future<PurchaseResult> purchaseItem(ShopItemEntity item, int quantity) async {
//     final userState = _ref.read(userGameDataProvider);

//     if (!userState.hasUser) {
//       return PurchaseResult(success: false, message: 'User not found');
//     }

//     final user = userState.user!;
//     final totalCost = item.price * quantity;

//     // Check if user has enough currency
//     bool hasEnoughCurrency = false;
//     switch (item.currency) {
//       case CurrencyType.coins:
//         hasEnoughCurrency = user.coins >= totalCost;
//         break;
//       case CurrencyType.gems:
//         hasEnoughCurrency = user.gems >= totalCost;
//         break;
//       case CurrencyType.xp:
//         hasEnoughCurrency = user.totalXp >= totalCost;
//         break;
//     }

//     if (!hasEnoughCurrency) {
//       return PurchaseResult(
//         success: false,
//         message: 'Insufficient ${item.currency.name}',
//       );
//     }

//     // Deduct currency
//     Map<String, dynamic> updateData = {};
//     switch (item.currency) {
//       case CurrencyType.coins:
//         updateData['coins'] = user.coins - totalCost;
//         break;
//       case CurrencyType.gems:
//         updateData['gems'] = user.gems - totalCost;
//         break;
//       case CurrencyType.xp:
//         updateData['totalXp'] = user.totalXp - totalCost;
//         break;
//     }

//     // Update user currency
//     final userRepository = _ref.read(userRepositoryProvider);
//     final updateResult = await userRepository.updateUser(user.id, updateData);

//     return updateResult.fold(
//       (failure) => PurchaseResult(success: false, message: failure.message),
//       (_) async {
//         // Add item to inventory
//         final inventoryResult =
//             await _ref.read(inventoryProvider.notifier).addItem(item.id, quantity);

//         if (inventoryResult.success) {
//           return PurchaseResult(
//             success: true,
//             message: 'Purchased ${item.name} x$quantity!',
//           );
//         } else {
//           return PurchaseResult(success: false, message: inventoryResult.message);
//         }
//       },
//     );
//   }
// }

// final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
//   return ShopNotifier(ref);
// });

// class PurchaseResult {
//   final bool success;
//   final String message;

//   PurchaseResult({required this.success, required this.message});
// }

// /// Shop state
// class ShopState {
//   final List<ShopItemEntity> items;
//   final List<ShopItemEntity> filteredItems;
//   final ItemCategory? selectedCategory;
//   final LoadingState status;
//   final String? errorMessage;
//   final bool isPurchasing;

//   const ShopState({
//     this.items = const [],
//     this.filteredItems = const [],
//     this.selectedCategory,
//     this.status = LoadingState.initial,
//     this.errorMessage,
//     this.isPurchasing = false,
//   });

//   ShopState copyWith({
//     List<ShopItemEntity>? items,
//     List<ShopItemEntity>? filteredItems,
//     ItemCategory? selectedCategory,
//     bool clearCategory = false,
//     LoadingState? status,
//     String? errorMessage,
//     bool clearError = false,
//     bool? isPurchasing,
//   }) {
//     return ShopState(
//       items: items ?? this.items,
//       filteredItems: filteredItems ?? this.filteredItems,
//       selectedCategory: clearCategory ? null : selectedCategory ?? this.selectedCategory,
//       status: status ?? this.status,
//       errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
//       isPurchasing: isPurchasing ?? this.isPurchasing,
//     );
//   }

//   bool get isLoading => status == LoadingState.loading;
//   bool get hasError => status == LoadingState.error;
//   bool get hasItems => items.isNotEmpty;

//   List<ShopItemEntity> getItemsByCategory(ItemCategory category) {
//     return items.where((item) => item.category == category).toList();
//   }

//   List<ItemCategory> get availableCategories {
//     return items.map((item) => item.category).toSet().toList();
//   }
// }

// /// Shop notifier
// class ShopNotifier extends StateNotifier<ShopState> {
//   final Ref _ref;

//   ShopNotifier(this._ref) : super(const ShopState()) {
//     loadShopItems();
//   }

//   /// Load all shop items
//   Future<void> loadShopItems() async {
//     state = state.copyWith(status: LoadingState.loading, clearError: true);

//     try {
//       // Mock shop items - em produção viria do repository
//       final mockItems = _generateMockShopItems();

//       state = state.copyWith(
//         items: mockItems,
//         filteredItems: mockItems,
//         status: LoadingState.success,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         status: LoadingState.error,
//         errorMessage: 'Failed to load shop items: $e',
//       );
//     }
//   }

//   /// Filter items by category
//   void filterByCategory(ItemCategory? category) {
//     final filteredItems = category == null
//         ? state.items
//         : state.items.where((item) => item.category == category).toList();

//     state = state.copyWith(
//       selectedCategory: category,
//       filteredItems: filteredItems,
//       clearCategory: category == null,
//     );
//   }

//   /// Purchase item
//   Future<PurchaseResult> purchaseItem(ShopItemEntity item) async {
//     final authState = _ref.read(authProvider);
//     if (!authState.isAuthenticated || authState.firebaseUser == null) {
//       return PurchaseResult(
//         success: false,
//         message: 'User not authenticated',
//       );
//     }

//     final userGameData = _ref.read(userGameDataProvider);
//     if (!userGameData.hasUser) {
//       return PurchaseResult(
//         success: false,
//         message: 'User data not available',
//       );
//     }

//     final user = userGameData.user!;

//     // Check if user has enough currency
//     final requiredAmount = item.price;
//     final userCurrency = item.currency == CurrencyType.coins ? user.coins : user.gems;

//     if (userCurrency < requiredAmount) {
//       return PurchaseResult(
//         success: false,
//         message: 'Insufficient ${item.currency.name}',
//       );
//     }

//     state = state.copyWith(isPurchasing: true);

//     try {
//       // Deduct currency from user
//       final newCoins =
//           item.currency == CurrencyType.coins ? user.coins - requiredAmount : user.coins;
//       final newGems = item.currency == CurrencyType.gems ? user.gems - requiredAmount : user.gems;

//       final updateResult = await _ref.read(userRepositoryProvider).updateUserCurrency(
//             userId: user.id,
//             coins: newCoins,
//             gems: newGems,
//             xp: user.totalXp,
//             level: user.level,
//           );

//       return updateResult.fold(
//         (failure) {
//           state = state.copyWith(isPurchasing: false);
//           return PurchaseResult(
//             success: false,
//             message: 'Purchase failed: ${failure.message}',
//           );
//         },
//         (_) async {
//           // Add item to inventory
//           final inventoryResult = await _ref.read(inventoryProvider.notifier).addItem(item.id, 1);

//           state = state.copyWith(isPurchasing: false);

//           if (inventoryResult.success) {
//             // Refresh user data
//             _ref.invalidate(userGameDataProvider);

//             return PurchaseResult(
//               success: true,
//               message: '${item.name} purchased successfully!',
//             );
//           } else {
//             return PurchaseResult(
//               success: false,
//               message: 'Failed to add item to inventory',
//             );
//           }
//         },
//       );
//     } catch (e) {
//       state = state.copyWith(isPurchasing: false);
//       return PurchaseResult(
//         success: false,
//         message: 'Purchase error: $e',
//       );
//     }
//   }

//   /// Generate mock shop items
//   List<ShopItemEntity> _generateMockShopItems() {
//     return [
//       // FOOD ITEMS
//       const ShopItemEntity(
//         id: 'food_basic_01',
//         name: 'Pet Food',
//         description: 'Basic nutritious food for your pet',
//         imageUrl: '🍖',
//         price: 10,
//         currency: CurrencyType.coins,
//         category: ItemCategory.food,
//         rarity: ItemRarity.common,
//         effects: {
//           ItemEffectType.hunger: 30,
//         },
//       ),
//       const ShopItemEntity(
//         id: 'food_premium_01',
//         name: 'Premium Steak',
//         description: 'High-quality meat that pets love',
//         imageUrl: '🥩',
//         price: 25,
//         currency: CurrencyType.coins,
//         category: ItemCategory.food,
//         rarity: ItemRarity.rare,
//         effects: {
//           ItemEffectType.hunger: 50,
//           ItemEffectType.happiness: 10,
//         },
//       ),
//       const ShopItemEntity(
//         id: 'food_super_01',
//         name: 'Golden Feast',
//         description: 'Legendary meal fit for champions',
//         imageUrl: '🍗',
//         price: 3,
//         currency: CurrencyType.gems,
//         category: ItemCategory.food,
//         rarity: ItemRarity.legendary,
//         effects: {
//           ItemEffectType.hunger: 80,
//           ItemEffectType.happiness: 20,
//           ItemEffectType.xp: 50,
//         },
//       ),

//       // TOYS
//       const ShopItemEntity(
//         id: 'toy_ball_01',
//         name: 'Tennis Ball',
//         description: 'Classic ball for endless fun',
//         imageUrl: '🎾',
//         price: 15,
//         currency: CurrencyType.coins,
//         category: ItemCategory.toys,
//         rarity: ItemRarity.common,
//         effects: {
//           ItemEffectType.happiness: 25,
//         },
//       ),
//       const ShopItemEntity(
//         id: 'toy_rope_01',
//         name: 'Rope Toy',
//         description: 'Durable rope for tugging games',
//         imageUrl: '🪢',
//         price: 20,
//         currency: CurrencyType.coins,
//         category: ItemCategory.toys,
//         rarity: ItemRarity.uncommon,
//         effects: {
//           ItemEffectType.happiness: 35,
//           ItemEffectType.energy: -5,
//         },
//       ),

//       // MEDICINE
//       const ShopItemEntity(
//         id: 'med_potion_01',
//         name: 'Health Potion',
//         description: 'Restores pet vitality',
//         imageUrl: '🧪',
//         price: 30,
//         currency: CurrencyType.coins,
//         category: ItemCategory.medicine,
//         rarity: ItemRarity.rare,
//         effects: {
//           ItemEffectType.health: 40,
//           ItemEffectType.energy: 20,
//         },
//       ),
//       const ShopItemEntity(
//         id: 'med_energy_01',
//         name: 'Energy Drink',
//         description: 'Instant energy boost',
//         imageUrl: '⚡',
//         price: 1,
//         currency: CurrencyType.gems,
//         category: ItemCategory.medicine,
//         rarity: ItemRarity.epic,
//         effects: {
//           ItemEffectType.energy: 60,
//         },
//       ),

//       // ACCESSORIES
//       const ShopItemEntity(
//         id: 'acc_collar_01',
//         name: 'Gold Collar',
//         description: 'Fancy collar for stylish pets',
//         imageUrl: '👑',
//         price: 50,
//         currency: CurrencyType.coins,
//         category: ItemCategory.accessories,
//         rarity: ItemRarity.epic,
//         effects: {
//           ItemEffectType.happiness: 15,
//           ItemEffectType.xp: 25,
//         },
//       ),
//     ];
//   }
// }

// /// Shop provider
// final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
//   return ShopNotifier(ref);
// });

// /// Purchase result class
// class PurchaseResult {
//   final bool success;
//   final String message;

//   PurchaseResult({
//     required this.success,
//     required this.message,
//   });
// }

/// Shop provider for managing shop items and purchases
class ShopState {
  final List<ShopItem> items;
  final ItemCategory? selectedCategory;
  final LoadingState status;
  final String? errorMessage;
  final bool isPurchasing;

  const ShopState({
    this.items = const [],
    this.selectedCategory,
    this.status = LoadingState.initial,
    this.errorMessage,
    this.isPurchasing = false,
  });

  ShopState copyWith({
    List<ShopItem>? items,
    ItemCategory? selectedCategory,
    bool clearCategory = false,
    LoadingState? status,
    String? errorMessage,
    bool clearError = false,
    bool? isPurchasing,
  }) {
    return ShopState(
      items: items ?? this.items,
      selectedCategory: clearCategory ? null : selectedCategory ?? this.selectedCategory,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isPurchasing: isPurchasing ?? this.isPurchasing,
    );
  }

  List<ShopItem> get filteredItems {
    if (selectedCategory == null) return items;
    return items.where((item) => item.category == selectedCategory).toList();
  }

  bool get isLoading => status == LoadingState.loading;
  bool get hasError => status == LoadingState.error;
  bool get hasItems => items.isNotEmpty;
}

class ShopNotifier extends StateNotifier<ShopState> {
  ShopNotifier() : super(const ShopState()) {
    _loadShopItems();
  }

  void _loadShopItems() {
    // Mock shop items for now
    final mockItems = [
      ShopItem(
        id: '1',
        name: 'Premium Food',
        description: 'Delicious food that restores 50 hunger',
        price: 100,
        currency: CurrencyType.coins,
        category: ItemCategory.food,
        effects: {ItemEffectType.hunger: 50},
        imageUrl: 'food_premium.png',
      ),
      ShopItem(
        id: '2',
        name: 'Super Toy',
        description: 'Fun toy that boosts happiness by 40',
        price: 80,
        currency: CurrencyType.coins,
        category: ItemCategory.toys,
        effects: {ItemEffectType.happiness: 40},
        imageUrl: 'toy_ball.png',
      ),
      ShopItem(
        id: '3',
        name: 'Energy Drink',
        description: 'Restores 60 energy instantly',
        price: 5,
        currency: CurrencyType.gems,
        category: ItemCategory.medicine,
        effects: {ItemEffectType.energy: 60},
        imageUrl: 'energy_drink.png',
      ),
    ];

    state = state.copyWith(
      items: mockItems,
      status: LoadingState.success,
    );
  }

  void selectCategory(ItemCategory? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
    );
  }

  Future<PurchaseResult> purchaseItem(ShopItem item) async {
    state = state.copyWith(isPurchasing: true);

    // Simulate purchase process
    await Future.delayed(const Duration(seconds: 1));

    // Mock successful purchase
    state = state.copyWith(isPurchasing: false);

    return PurchaseResult(
      success: true,
      message: '${item.name} purchased successfully!',
      item: item,
    );
  }
}

final shopProvider = StateNotifierProvider<ShopNotifier, ShopState>((ref) {
  return ShopNotifier();
});
