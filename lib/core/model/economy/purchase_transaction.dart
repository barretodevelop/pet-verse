import 'package:petverse/core/model/economy/transaction.dart';
import 'package:petverse/core/model/user_inventory.dart';

class PurchaseTransaction {
  final bool success;
  final Transaction? transaction;
  final UserInventory updatedInventory;
  final String? error;

  PurchaseTransaction({
    required this.success,
    required this.transaction,
    required this.updatedInventory,
    this.error,
  });
}
