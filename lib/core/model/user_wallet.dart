class UserWallet {
  final int coins;
  final int gems;

  UserWallet({required this.coins, required this.gems});

  UserWallet copyWith({int? coins, int? gems}) {
    return UserWallet(
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
    );
  }
}
