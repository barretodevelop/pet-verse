import '../../core/errors/failures.dart';
import '../../core/types/either.dart';
import '../entities/inventory_item_entity.dart';

abstract class InventoryRepository {
  Future<Either<Failure, List<InventoryItemEntity>>> getUserInventory(String userId);
  Future<Either<Failure, InventoryItemEntity?>> getInventoryItem(String userId, String itemId);
  Future<Either<Failure, void>> addItem({
    required String userId,
    required String shopItemId,
    required int quantity,
  });
  Future<Either<Failure, void>> useItem({
    required String userId,
    required String inventoryItemId,
    required String petId,
    int quantity = 1,
  });
  Future<Either<Failure, void>> removeItem({
    required String userId,
    required String inventoryItemId,
    required int quantity,
  });
}
