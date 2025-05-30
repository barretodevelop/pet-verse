// import 'package:petverse/core/model/economy/daily_reward_result.dart';
// import 'package:petverse/core/model/economy/game_item.dart';
// import 'package:petverse/core/model/economy/price.dart';
// import 'package:petverse/core/model/economy/purchase_transaction.dart';
// import 'package:petverse/core/model/economy/transaction.dart';
// import 'package:petverse/core/model/user_inventory.dart';

// class EconomyService {
//   // Executar compra completa
//   static PurchaseTransaction executePurchase({
//     required UserInventory inventory,
//     required GameItem item,
//     required int quantity,
//     String? notes,
//   }) {
//     final totalPrice = Price(
//       coins: (item.price.coins ?? 0) * quantity,
//       gems: (item.price.gems ?? 0) * quantity,
//       bothRequired: item.price.bothRequired,
//     );

//     final purchaseResult = inventory.canAffordAndGetCurrency(totalPrice);

//     if (!purchaseResult.canAfford) {
//       return PurchaseTransaction(
//         success: false,
//         transaction: null,
//         updatedInventory: inventory,
//         error: 'Moedas insuficientes',
//       );
//     }

//     final transaction = Transaction.purchase(
//       id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
//       itemId: item.id,
//       quantity: quantity,
//       price: totalPrice,
//       currencyUsed: purchaseResult.currencyUsed,
//       notes: notes,
//     );

//     final updatedInventory = inventory
//         .subtractCostWithCurrency(totalPrice, purchaseResult.currencyUsed)
//         .addItem(item.id, quantity);

//     return PurchaseTransaction(
//       success: true,
//       transaction: transaction,
//       updatedInventory: updatedInventory,
//     );
//   }

//   // Coletar recompensa diária
//   static DailyRewardResult collectDailyReward(UserInventory inventory) {
//     if (!inventory.canCollectDailyReward()) {
//       return DailyRewardResult(
//         success: false,
//         updatedInventory: inventory,
//         coinsEarned: 0,
//         gemsEarned: 0,
//         itemsEarned: {},
//         error: 'Recompensa diária já coletada hoje',
//       );
//     }

//     const dailyCoins = 100;
//     const dailyGems = 2;
//     const dailyItems = {'food_basic': 1};

//     var updatedInventory = inventory
//         .addCurrency(coinsToAdd: dailyCoins, gemsToAdd: dailyGems)
//         .copyWith(lastDailyReward: DateTime.now());

//     for (final entry in dailyItems.entries) {
//       updatedInventory = updatedInventory.addItem(entry.key, entry.value);
//     }

//     return DailyRewardResult(
//       success: true,
//       updatedInventory: updatedInventory,
//       coinsEarned: dailyCoins,
//       gemsEarned: dailyGems,
//       itemsEarned: dailyItems,
//     );
//   }
// }
