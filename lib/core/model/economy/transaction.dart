import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/economy/price.dart';

class Transaction {
  final String id;
  final String itemId;
  final int quantity;
  final Price originalPrice; // Preço original do item
  final CurrencyType currencyUsed; // NOVO: Qual moeda foi efetivamente usada
  final int actualCoinsSpent; // NOVO: Moedas realmente gastas
  final int actualGemsSpent; // NOVO: Gemas realmente gastas
  final DateTime timestamp;
  final TransactionType type;
  final String? notes; // NOVO: Notas adicionais (ex: "Compra com desconto")

  Transaction({
    required this.id,
    required this.itemId,
    required this.quantity,
    required this.originalPrice,
    required this.currencyUsed,
    required this.actualCoinsSpent,
    required this.actualGemsSpent,
    required this.timestamp,
    required this.type,
    this.notes,
  });

  // NOVO: Construtor para compras simples
  factory Transaction.purchase({
    required String id,
    required String itemId,
    required int quantity,
    required Price price,
    required CurrencyType currencyUsed,
    String? notes,
  }) {
    int coinsSpent = 0;
    int gemsSpent = 0;

    switch (currencyUsed) {
      case CurrencyType.coins:
        coinsSpent = price.coins ?? 0;
        break;
      case CurrencyType.gems:
        gemsSpent = price.gems ?? 0;
        break;
      case CurrencyType.both:
        coinsSpent = price.coins ?? 0;
        gemsSpent = price.gems ?? 0;
        break;
      case CurrencyType.free:
        // Nada
        break;
    }

    return Transaction(
      id: id,
      itemId: itemId,
      quantity: quantity,
      originalPrice: price,
      currencyUsed: currencyUsed,
      actualCoinsSpent: coinsSpent,
      actualGemsSpent: gemsSpent,
      timestamp: DateTime.now(),
      type: TransactionType.purchase,
      notes: notes,
    );
  }

  double get totalValueInCoins {
    // Assumindo 1 gem = 10 coins para conversão
    return actualCoinsSpent.toDouble() + (actualGemsSpent * 10.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'quantity': quantity,
      'originalPrice': originalPrice.toJson(),
      'currencyUsed': currencyUsed.toString(),
      'actualCoinsSpent': actualCoinsSpent,
      'actualGemsSpent': actualGemsSpent,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
      'notes': notes,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      itemId: json['itemId'],
      quantity: json['quantity'],
      originalPrice: Price.fromJson(json['originalPrice']),
      currencyUsed: CurrencyType.values.firstWhere(
        (e) => e.toString() == json['currencyUsed'],
      ),
      actualCoinsSpent: json['actualCoinsSpent'],
      actualGemsSpent: json['actualGemsSpent'],
      timestamp: DateTime.parse(json['timestamp']),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      notes: json['notes'],
    );
  }
}
