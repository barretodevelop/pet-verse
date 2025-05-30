import 'package:petverse/core/enums/enums.dart';

class PurchaseResult {
  final bool canAfford;
  final CurrencyType currencyUsed;
  final String? reason; // Motivo caso não possa comprar

  PurchaseResult({
    required this.canAfford,
    required this.currencyUsed,
    this.reason,
  });
}
