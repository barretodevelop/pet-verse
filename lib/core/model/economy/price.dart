import 'package:petverse/core/enums/enums.dart';

class Price {
  final int? coins;
  final int? gems;
  final bool bothRequired; // true = precisa dos dois

  Price({
    this.coins,
    this.gems,
    this.bothRequired = false,
  });

  bool get isFree => (coins ?? 0) == 0 && (gems ?? 0) == 0;
  bool get hasCoins => coins != null && coins! > 0;
  bool get hasGems => gems != null && gems! > 0;

  // NOVO: Determinar o tipo de moeda principal
  CurrencyType get primaryCurrency {
    if (isFree) return CurrencyType.free;
    if (bothRequired) return CurrencyType.both;
    if (hasCoins && hasGems) {
      // Se tem ambos mas não é obrigatório, preferir coins
      return CurrencyType.coins;
    }
    if (hasCoins) return CurrencyType.coins;
    if (hasGems) return CurrencyType.gems;
    return CurrencyType.free;
  }

  Price copyWith({
    int? coins,
    int? gems,
    bool? bothRequired,
  }) {
    return Price(
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      bothRequired: bothRequired ?? this.bothRequired,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'gems': gems,
      'bothRequired': bothRequired,
    };
  }

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      coins: json['coins'],
      gems: json['gems'],
      bothRequired: json['bothRequired'] ?? false,
    );
  }
}
