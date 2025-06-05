import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/data/models/user_currency.dart';

/// StateNotifier para gerenciar a moeda do usuário
class UserCurrencyNotifier extends StateNotifier<UserCurrency> {
  UserCurrencyNotifier() : super(_createInitialUser());

  /// Cria um usuário inicial com ID único
  static UserCurrency _createInitialUser() {
    final userId = _generateUserId();
    return UserCurrency.initial(userId);
  }

  /// Gera um ID único para o usuário
  static String _generateUserId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = String.fromCharCodes(
      Iterable.generate(
          8, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
    return 'user_${timestamp}_$randomPart';
  }

  /// Define a quantidade de coins
  void setCoins(int amount) {
    state = state.copyWith(coins: amount);
  }

  /// Adiciona coins ao saldo atual
  void addCoins(int amount) {
    if (amount <= 0) return;
    state = state.addCoins(amount);
  }

  /// Remove coins do saldo atual
  bool removeCoins(int amount) {
    if (amount <= 0 || !state.canAffordCoins(amount)) return false;
    state = state.removeCoins(amount);
    return true;
  }

  /// Tenta gastar coins - retorna true se bem-sucedido
  bool spendCoins(int cost) {
    final newState = state.spendCoins(cost);
    if (newState != null) {
      state = newState;
      return true;
    }
    return false;
  }

  /// Define a quantidade de gems
  void setGems(int amount) {
    state = state.copyWith(gems: amount);
  }

  /// Adiciona gems ao saldo atual
  void addGems(int amount) {
    if (amount <= 0) return;
    state = state.addGems(amount);
  }

  /// Remove gems do saldo atual
  bool removeGems(int amount) {
    if (amount <= 0 || !state.canAffordGems(amount)) return false;
    state = state.removeGems(amount);
    return true;
  }

  /// Tenta gastar gems - retorna true se bem-sucedido
  bool spendGems(int cost) {
    final newState = state.spendGems(cost);
    if (newState != null) {
      state = newState;
      return true;
    }
    return false;
  }

  /// Define a quantidade de XP
  void setXp(int amount) {
    state = state.copyWith(xp: amount);
  }

  /// Adiciona XP ao total atual
  void addXp(int amount) {
    if (amount <= 0) return;
    state = state.addXP(amount);
  }

  /// Executa uma transação completa (coins e gems)
  bool executeTransaction({
    int coinsCost = 0,
    int gemsCost = 0,
    int coinsReward = 0,
    int gemsReward = 0,
    int xpReward = 0,
  }) {
    // Verifica se pode pagar os custos
    if (!state.canAffordCoins(coinsCost) || !state.canAffordGems(gemsCost)) {
      return false;
    }

    // Executa a transação
    var newState = state;

    // Remove custos
    if (coinsCost > 0) {
      newState = newState.removeCoins(coinsCost);
    }
    if (gemsCost > 0) {
      newState = newState.removeGems(gemsCost);
    }

    // Adiciona recompensas
    if (coinsReward > 0) {
      newState = newState.addCoins(coinsReward);
    }
    if (gemsReward > 0) {
      newState = newState.addGems(gemsReward);
    }
    if (xpReward > 0) {
      newState = newState.addXP(xpReward);
    }

    state = newState;
    return true;
  }

  /// Converte gems em coins (taxa de câmbio: 1 gem = 10 coins)
  bool convertGemsToCoins(int gemsAmount) {
    if (gemsAmount <= 0 || !state.canAffordGems(gemsAmount)) return false;

    const conversionRate = 10;
    return executeTransaction(
      gemsCost: gemsAmount,
      coinsReward: gemsAmount * conversionRate,
    );
  }

  /// Compra gems com coins (taxa de câmbio: 15 coins = 1 gem)
  bool buyGemsWithCoins(int gemsAmount) {
    if (gemsAmount <= 0) return false;

    const conversionRate = 15;
    final coinsCost = gemsAmount * conversionRate;

    return executeTransaction(
      coinsCost: coinsCost,
      gemsReward: gemsAmount,
    );
  }

  /// Redefine a moeda para valores iniciais (usado para reset/debug)
  void reset() {
    state = UserCurrency.initial(state.currentUserId);
  }

  /// Carrega dados da moeda a partir de JSON
  void loadFromJson(Map<String, dynamic> json) {
    try {
      state = UserCurrency.fromJson(json);
    } catch (e) {
      // Se houver erro na deserialização, mantém o estado atual
      print('Erro ao carregar moeda do usuário: $e');
    }
  }

  /// Recompensa diária - pode ser chamada uma vez por dia
  bool claimDailyReward() {
    // Verifica se já recebeu hoje (simplificado)
    final lastUpdate = state.lastUpdated;
    final now = DateTime.now();
    final daysDifference = now.difference(lastUpdate).inDays;

    if (daysDifference >= 1) {
      return executeTransaction(
        coinsReward: 100,
        gemsReward: 5,
        xpReward: 50,
      );
    }
    return false;
  }

  /// Recompensa por assistir anúncio (simulada)
  bool claimAdReward() {
    return executeTransaction(
      coinsReward: 50,
      gemsReward: 1,
    );
  }

  /// Recompensa por achievement
  bool claimAchievementReward({
    required int coins,
    required int gems,
    required int xp,
  }) {
    return executeTransaction(
      coinsReward: coins,
      gemsReward: gems,
      xpReward: xp,
    );
  }
}

/// Provider principal para a moeda do usuário
final userCurrencyProvider =
    StateNotifierProvider<UserCurrencyNotifier, UserCurrency>((ref) {
  return UserCurrencyNotifier();
});

/// Provider computado para verificar se o usuário pode pagar custos específicos
final canAffordProvider = Provider.family<bool, Map<String, int>>((ref, costs) {
  final currency = ref.watch(userCurrencyProvider);
  final coinsCost = costs['coins'] ?? 0;
  final gemsCost = costs['gems'] ?? 0;

  return currency.canAffordCoins(coinsCost) && currency.canAffordGems(gemsCost);
});

/// Provider computado para o nível do usuário
final userLevelProvider = Provider<int>((ref) {
  final currency = ref.watch(userCurrencyProvider);
  return currency.level;
});

/// Provider computado para o progresso do nível
final levelProgressProvider = Provider<double>((ref) {
  final currency = ref.watch(userCurrencyProvider);
  return currency.levelProgress;
});

/// Provider computado para XP até o próximo nível
final xpToNextLevelProvider = Provider<int>((ref) {
  final currency = ref.watch(userCurrencyProvider);
  return currency.xpToNextLevel;
});

/// Provider computado para status de riqueza
final wealthStatusProvider = Provider<WealthStatus>((ref) {
  final currency = ref.watch(userCurrencyProvider);

  if (currency.isWealthy) return WealthStatus.wealthy;
  if (currency.isLowResources) return WealthStatus.poor;
  return WealthStatus.average;
});

/// Provider para formatação de valores
final formattedCurrencyProvider = Provider<FormattedCurrency>((ref) {
  final currency = ref.watch(userCurrencyProvider);

  return FormattedCurrency(
    coins: currency.coinsFormatted,
    gems: currency.gemsFormatted,
    xp: currency.xpFormatted,
  );
});

/// Enum para status de riqueza
enum WealthStatus {
  poor,
  average,
  wealthy,
}

/// Classe para valores formatados
class FormattedCurrency {
  final String coins;
  final String gems;
  final String xp;

  const FormattedCurrency({
    required this.coins,
    required this.gems,
    required this.xp,
  });
}

/// Constantes para custos comuns do jogo
class GameCosts {
  // Custos de ações com pets
  static const int feedPetCoins = 10;
  static const int playWithPetCoins = 5;
  static const int restPetCoins = 8;

  // Custos de geração
  static const int generateUniquePetGems = 20;
  static const int premiumFeatureGems = 10;

  // Recompensas
  static const int adoptionRewardCoins = 100;
  static const int dailyRewardCoins = 100;
  static const int dailyRewardGems = 5;
  static const int dailyRewardXP = 50;

  // Conversões
  static const int gemToCoinsRate = 10;
  static const int coinsToGemRate = 15;

  // XP rewards
  static const int playWithPetXP = 10;
  static const int adoptionXP = 50;
  static const int achievementXP = 25;
}

/// Extension para facilitar o uso dos providers
extension CurrencyProviderExtensions on WidgetRef {
  /// Verifica se pode pagar um custo específico
  bool canAfford({int coins = 0, int gems = 0}) {
    return read(canAffordProvider({'coins': coins, 'gems': gems}));
  }

  /// Gasta coins se possível
  bool spendCoins(int amount) {
    return read(userCurrencyProvider.notifier).spendCoins(amount);
  }

  /// Gasta gems se possível
  bool spendGems(int amount) {
    return read(userCurrencyProvider.notifier).spendGems(amount);
  }

  /// Adiciona recompensa
  void addReward({int coins = 0, int gems = 0, int xp = 0}) {
    final notifier = read(userCurrencyProvider.notifier);
    if (coins > 0) notifier.addCoins(coins);
    if (gems > 0) notifier.addGems(gems);
    if (xp > 0) notifier.addXp(xp);
  }
}
