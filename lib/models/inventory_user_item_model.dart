// TODO Implement this library.
// lib/models/inventory_user_item_model.dart
import 'package:petverse/models/item_model.dart'; // Para ter acesso ao ItemModel base

class InventoryUserItem {
  final String docId; // ID do documento na subcoleção inventory do usuário
  final String itemId; // ID do ItemModel original (de Constants.shopItems)
  final int quantity;
  final DateTime acquiredAt;
  // Opcional: Você pode carregar o ItemModel completo aqui se precisar
  final ItemModel? baseItem;

  InventoryUserItem({
    required this.docId,
    required this.itemId,
    required this.quantity,
    required this.acquiredAt,
    this.baseItem,
  });

  factory InventoryUserItem.fromJson(String docId, Map<String, dynamic> json,
      {ItemModel? baseItemDetails}) {
    return InventoryUserItem(
      docId: docId,
      itemId: json['itemId'] as String,
      quantity: json['quantity'] as int? ?? 1,
      acquiredAt:
          DateTime.fromMillisecondsSinceEpoch(json['acquiredAt'] as int),
      baseItem: baseItemDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'quantity': quantity,
      'acquiredAt': acquiredAt.millisecondsSinceEpoch,
    };
  }

  InventoryUserItem copyWith({
    String? docId,
    String? itemId,
    int? quantity,
    DateTime? acquiredAt,
    ItemModel? baseItem,
  }) {
    return InventoryUserItem(
      docId: docId ?? this.docId,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      baseItem: baseItem ?? this.baseItem,
    );
  }
}
