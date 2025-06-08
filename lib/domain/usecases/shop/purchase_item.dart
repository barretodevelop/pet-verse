import 'package:petverse/core/enums/enums/app_enums.dart';

import '../../../core/errors/failures.dart';
import '../../../core/types/either.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/shop_repository.dart';
import '../../repositories/user_repository.dart';

class PurchaseItemParams {
  final String userId;
  final String itemId;
  final int quantity;

  PurchaseItemParams({
    required this.userId,
    required this.itemId,
    required this.quantity,
  });
}

class PurchaseItem {
  final ShopRepository _shopRepository;
  final UserRepository _userRepository;
  final InventoryRepository _inventoryRepository;

  PurchaseItem(
    this._shopRepository,
    this._userRepository,
    this._inventoryRepository,
  );

  Future<Either<Failure, void>> call(PurchaseItemParams params) async {
    // Get item details
    final itemResult = await _shopRepository.getItemById(params.itemId);

    return itemResult.fold(
      (failure) => Left(failure),
      (item) async {
        if (item == null) {
          return const Left(DatabaseFailure('Item not found'));
        }

        // Get user data to check currency
        final userResult = await _userRepository.getUserData(params.userId);

        return userResult.fold(
          (failure) => Left(failure),
          (user) async {
            if (user == null) {
              return const Left(UserDataFailure('User not found'));
            }

            final totalCost = item.price * params.quantity;

            // Check if user has enough currency
            final hasEnoughCurrency = item.currency == CurrencyType.coins
                ? user.coins >= totalCost
                : user.gems >= totalCost;

            if (!hasEnoughCurrency) {
              return Left(TransactionFailure(
                  'Insufficient ${item.currency.name}. Need $totalCost, have ${item.currency == CurrencyType.coins ? user.coins : user.gems}'));
            }

            // Deduct currency
            final newCoins =
                item.currency == CurrencyType.coins ? user.coins - totalCost : user.coins;
            final newGems = item.currency == CurrencyType.gems ? user.gems - totalCost : user.gems;

            final updateResult = await _userRepository.updateUserCurrency(
              userId: params.userId,
              coins: newCoins,
              gems: newGems,
              xp: user.totalXp,
              level: user.level,
            );

            return updateResult.fold(
              (failure) => Left(failure),
              (_) async {
                // Add item to inventory
                final addResult = await _inventoryRepository.addItem(
                  userId: params.userId,
                  shopItemId: params.itemId,
                  quantity: params.quantity,
                );

                return addResult.fold(
                  (failure) => Left(failure),
                  (_) => const Right(null),
                );
              },
            );
          },
        );
      },
    );
  }
}
