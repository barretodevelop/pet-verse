import 'package:petverse/core/enums/enums/app_enums.dart';

import '../../core/errors/failures.dart';
import '../../core/types/either.dart';
import '../entities/shop_item_entity.dart';

abstract class ShopRepository {
  Future<Either<Failure, List<ShopItemEntity>>> getShopItems();
  Future<Either<Failure, List<ShopItemEntity>>> getItemsByCategory(ItemCategory category);
  Future<Either<Failure, ShopItemEntity?>> getItemById(String itemId);
  Future<Either<Failure, void>> purchaseItem({
    required String userId,
    required String itemId,
    required int quantity,
  });
}
