import 'package:equatable/equatable.dart';

class InventoryItemEntity extends Equatable {
  final String id;
  final String userId;
  final String shopItemId;
  final int quantity;
  final DateTime purchasedAt;
  final DateTime? lastUsedAt;
  final DateTime? acquiredAt;
  final Map<String, dynamic> metadata;

  const InventoryItemEntity({
    required this.id,
    required this.userId,
    required this.shopItemId,
    required this.quantity,
    required this.purchasedAt,
    this.lastUsedAt,
    this.acquiredAt,
    this.metadata = const {},
  });

  InventoryItemEntity copyWith({
    String? id,
    String? userId,
    String? shopItemId,
    int? quantity,
    DateTime? purchasedAt,
    DateTime? lastUsedAt,
    DateTime? acquiredAt,
    Map<String, dynamic>? metadata,
  }) {
    return InventoryItemEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopItemId: shopItemId ?? this.shopItemId,
      quantity: quantity ?? this.quantity,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      metadata: metadata ?? this.metadata,
      acquiredAt: this.acquiredAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        shopItemId,
        quantity,
        purchasedAt,
        lastUsedAt,
        metadata,
        acquiredAt,
      ];
}
