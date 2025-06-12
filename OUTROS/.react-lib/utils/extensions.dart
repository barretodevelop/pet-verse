import '../models/accessory.dart'; // Importa o modelo Accessory
import '../models/shop_item.dart'; // Importa o modelo ShopItem

// Extensão para ShopItem para converter em Accessory
extension ShopItemToAccessory on ShopItem {
  Accessory toAccessory() {
    return Accessory(
      id: id,
      name: name,
      emoji: emoji,
      type: type,
      effect: effect,
      category: category,
    );
  }
}
