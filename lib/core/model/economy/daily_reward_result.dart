import 'package:petverse/core/model/user_inventory.dart';

class DailyRewardResult {
  final bool success;
  final UserInventory updatedInventory;
  final int coinsEarned;
  final int gemsEarned;
  final Map<String, int> itemsEarned;
  final String? error;

  DailyRewardResult({
    required this.success,
    required this.updatedInventory,
    required this.coinsEarned,
    required this.gemsEarned,
    required this.itemsEarned,
    this.error,
  });
}
