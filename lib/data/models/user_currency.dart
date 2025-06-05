/// Modelo de dados para representar a moeda/economia do usuário
class UserCurrency {
  final int coins;
  final int gems;
  final int xp;
  final String currentUserId;
  final DateTime lastUpdated;

  // Constantes para valores máximos e mínimos
  static const int maxCoins = 999999999;
  static const int maxGems = 999999;
  static const int maxXP = 999999999;
  static const int minValue = 0;

  UserCurrency({
    required this.coins,
    required this.gems,
    required this.xp,
    required this.currentUserId,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Cria uma cópia da moeda com novos valores opcionais
  UserCurrency copyWith({
    int? coins,
    int? gems,
    int? xp,
    String? currentUserId,
    DateTime? lastUpdated,
  }) {
    return UserCurrency(
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      xp: xp ?? this.xp,
      currentUserId: currentUserId ?? this.currentUserId,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// Converte a moeda para Map para serialização
  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'gems': gems,
      'xp': xp,
      'currentUserId': currentUserId,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Cria uma moeda a partir de Map (deserialização)
  factory UserCurrency.fromJson(Map<String, dynamic> json) {
    return UserCurrency(
      coins: _validateAndClamp(json['coins'] as int? ?? 0, maxCoins),
      gems: _validateAndClamp(json['gems'] as int? ?? 0, maxGems),
      xp: _validateAndClamp(json['xp'] as int? ?? 0, maxXP),
      currentUserId: json['currentUserId'] as String? ?? '',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  /// Cria uma instância inicial/padrão para um novo usuário
  factory UserCurrency.initial(String userId) {
    return UserCurrency(
      coins: 1000, // Coins iniciais
      gems: 50, // Gems iniciais
      xp: 0, // XP inicial
      currentUserId: userId,
    );
  }

  /// Valida e limita valores dentro dos ranges permitidos
  static int _validateAndClamp(int value, int maxValue) {
    return value.clamp(minValue, maxValue);
  }

  /// Adiciona coins com validação
  UserCurrency addCoins(int amount) {
    if (amount < 0) return this; // Não permite valores negativos
    final newCoins = _validateAndClamp(coins + amount, maxCoins);
    return copyWith(coins: newCoins);
  }

  /// Remove coins com validação
  UserCurrency removeCoins(int amount) {
    if (amount < 0) return this; // Não permite valores negativos
    final newCoins = _validateAndClamp(coins - amount, maxCoins);
    return copyWith(coins: newCoins);
  }

  /// Adiciona gems com validação
  UserCurrency addGems(int amount) {
    if (amount < 0) return this; // Não permite valores negativos
    final newGems = _validateAndClamp(gems + amount, maxGems);
    return copyWith(gems: newGems);
  }

  /// Remove gems com validação
  UserCurrency removeGems(int amount) {
    if (amount < 0) return this; // Não permite valores negativos
    final newGems = _validateAndClamp(gems - amount, maxGems);
    return copyWith(gems: newGems);
  }

  /// Adiciona XP com validação
  UserCurrency addXP(int amount) {
    if (amount < 0) return this; // Não permite valores negativos
    final newXP = _validateAndClamp(xp + amount, maxXP);
    return copyWith(xp: newXP);
  }

  /// Verifica se o usuário pode pagar um custo em coins
  bool canAffordCoins(int cost) {
    return cost >= 0 && coins >= cost;
  }

  /// Verifica se o usuário pode pagar um custo em gems
  bool canAffordGems(int cost) {
    return cost >= 0 && gems >= cost;
  }

  /// Executa uma transação de coins (retorna nova instância ou null se não puder pagar)
  UserCurrency? spendCoins(int cost) {
    if (!canAffordCoins(cost)) return null;
    return removeCoins(cost);
  }

  /// Executa uma transação de gems (retorna nova instância ou null se não puder pagar)
  UserCurrency? spendGems(int cost) {
    if (!canAffordGems(cost)) return null;
    return removeGems(cost);
  }

  /// Calcula o nível baseado no XP (fórmula simples)
  int get level {
    if (xp < 100) return 1;
    return (xp / 100).floor() + 1;
  }

  /// Calcula o XP necessário para o próximo nível
  int get xpToNextLevel {
    final currentLevelXP = (level - 1) * 100;
    final nextLevelXP = level * 100;
    return nextLevelXP - xp;
  }

  /// Calcula a porcentagem de progresso para o próximo nível
  double get levelProgress {
    final currentLevelXP = (level - 1) * 100;
    final nextLevelXP = level * 100;
    final progressXP = xp - currentLevelXP;
    final totalXPNeeded = nextLevelXP - currentLevelXP;
    return progressXP / totalXPNeeded;
  }

  /// Verifica se o usuário é considerado "rico" (valores altos)
  bool get isWealthy {
    return coins >= 50000 || gems >= 1000;
  }

  /// Verifica se o usuário é considerado "pobre" (valores baixos)
  bool get isLowResources {
    return coins < 100 && gems < 10;
  }

  /// Retorna o valor total estimado (coins + gems * 10)
  int get totalWealth {
    return coins + (gems * 10); // 1 gem = 10 coins para cálculo
  }

  /// Formata coins para exibição amigável
  String get coinsFormatted {
    if (coins >= 1000000) {
      return '${(coins / 1000000).toStringAsFixed(1)}M';
    } else if (coins >= 1000) {
      return '${(coins / 1000).toStringAsFixed(1)}K';
    }
    return coins.toString();
  }

  /// Formata gems para exibição amigável
  String get gemsFormatted {
    if (gems >= 1000) {
      return '${(gems / 1000).toStringAsFixed(1)}K';
    }
    return gems.toString();
  }

  /// Formata XP para exibição amigável
  String get xpFormatted {
    if (xp >= 1000000) {
      return '${(xp / 1000000).toStringAsFixed(1)}M';
    } else if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1)}K';
    }
    return xp.toString();
  }

  @override
  String toString() {
    return 'UserCurrency(coins: $coins, gems: $gems, xp: $xp, userId: $currentUserId, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserCurrency &&
        other.currentUserId == currentUserId &&
        other.coins == coins &&
        other.gems == gems &&
        other.xp == xp;
  }

  @override
  int get hashCode {
    return Object.hash(currentUserId, coins, gems, xp);
  }
}
