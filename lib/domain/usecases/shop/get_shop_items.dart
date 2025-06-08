import '../../../core/errors/failures.dart';
import '../../../core/types/either.dart';
import '../../entities/shop_item_entity.dart';
import '../../repositories/shop_repository.dart';

class GetShopItems {
  final ShopRepository _shopRepository;

  GetShopItems(this._shopRepository);

  Future<Either<Failure, List<ShopItemEntity>>> call() async {
    return await _shopRepository.getShopItems();
  }
}
