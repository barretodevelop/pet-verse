// File: lib/core/constants/economy_constants.dart

import 'package:petverse/core/enums/enums/app_enums.dart';

/// Constantes para balanceamento do sistema econômico do jogo
class EconomyConstants {
  // ============================================================================
  // CONFIGURAÇÕES DE DIFICULDADE
  // ============================================================================

  /// Níveis considerados como fase inicial (fácil)
  static const int easyPhaseMaxLevel = 5;

  /// Níveis considerados como fase intermediária
  static const int intermediatePhasMaxLevel = 15;

  /// Nível máximo considerado no balanceamento
  static const int maxBalancedLevel = 50;

  // ============================================================================
  // MOEDAS E RECOMPENSAS BASE
  // ============================================================================

  /// Coins iniciais que o usuário ganha ao criar conta
  static const int initialCoins = 500;

  /// Gems iniciais que o usuário ganha ao criar conta
  static const int initialGems = 10;

  /// XP inicial do usuário
  static const int initialXp = 0;

  // ============================================================================
  // GANHOS POR AÇÃO (BASE)
  // ============================================================================

  /// Coins ganhos por alimentar o pet (base)
  static const int feedPetCoinsBase = 10;

  /// Coins ganhos por brincar com o pet (base)
  static const int playPetCoinsBase = 15;

  /// Coins ganhos por fazer o pet descansar (base)
  static const int restPetCoinsBase = 5;

  /// XP ganho por alimentar o pet
  static const int feedPetXp = 20;

  /// XP ganho por brincar com o pet
  static const int playPetXp = 30;

  /// XP ganho por fazer o pet descansar
  static const int restPetXp = 10;

  // ============================================================================
  // RECOMPENSAS DIÁRIAS
  // ============================================================================

  /// Coins base para daily reward
  static const int dailyRewardCoinsBase = 100;

  /// Gems base para daily reward
  static const int dailyRewardGemsBase = 2;

  /// Multiplicador de streak para daily rewards (max 7 dias)
  static const double dailyStreakMultiplier = 0.2; // +20% por dia consecutivo

  // ============================================================================
  // FÓRMULAS DE SCALING
  // ============================================================================

  /// Multiplicador base para crescimento de preços por nível
  static const double priceScalingBase = 1.15;

  /// Multiplicador base para crescimento de ganhos por nível
  static const double rewardScalingBase = 1.10;

  /// Fator de redução do scaling em níveis altos (evita inflação descontrolada)
  static const double scalingDamping = 0.98;

  // ============================================================================
  // LIMITES E CAPS
  // ============================================================================

  /// Máximo de coins que um usuário pode ter
  static const int maxCoins = 1000000;

  /// Máximo de gems que um usuário pode ter
  static const int maxGems = 50000;

  /// Máximo de itens no carrinho
  static const int maxCartItems = 20;

  /// Máximo de quantidade por item no carrinho
  static const int maxQuantityPerItem = 99;

  // ============================================================================
  // DESCONTO POR QUANTIDADE
  // ============================================================================

  /// Quantidade mínima para desconto por volume
  static const int bulkDiscountMinQuantity = 5;

  /// Desconto por volume (5% para 5+ itens, 10% para 10+ itens)
  static const Map<int, double> bulkDiscountTiers = {
    5: 0.05, // 5% de desconto
    10: 0.10, // 10% de desconto
    20: 0.15, // 15% de desconto
  };

  // ============================================================================
  // PREÇOS BASE DOS ITENS (COINS)
  // ============================================================================

  static const Map<String, int> basePricesCoins = {
    // === COMIDA ===
    'basic_food': 50,
    'premium_food': 120,
    'luxury_food': 300,
    'mega_food': 750,

    // === BRINQUEDOS ===
    'simple_toy': 80,
    'interactive_toy': 200,
    'electronic_toy': 500,
    'premium_toy': 1200,

    // === MEDICINA ===
    'health_potion': 100,
    'energy_drink': 150,
    'happiness_boost': 80,
    'super_medicine': 400,

    // === DECORAÇÃO ===
    'basic_decoration': 200,
    'themed_decoration': 500,
    'luxury_decoration': 1000,
    'epic_decoration': 2500,
  };

  // ============================================================================
  // PREÇOS BASE DOS ITENS (GEMS)
  // ============================================================================

  static const Map<String, int> basePricesGems = {
    // === ITENS PREMIUM ===
    'legendary_food': 5,
    'mythic_toy': 8,
    'time_accelerator': 3,
    'double_xp_boost': 4,
    'rare_pet_accessory': 10,
    'exclusive_decoration': 15,

    // === UPGRADES ===
    'inventory_expansion': 12,
    'pet_skill_boost': 8,
    'daily_reward_multiplier': 6,
  };

  // ============================================================================
  // MÉTODOS UTILITÁRIOS
  // ============================================================================

  /// Calcula o multiplicador de preço baseado no nível do usuário
  static double getPriceMultiplier(int userLevel) {
    if (userLevel <= easyPhaseMaxLevel) {
      // Fase fácil: preços crescem lentamente
      return 1.0 + (userLevel * 0.05);
    } else if (userLevel <= intermediatePhasMaxLevel) {
      // Fase intermediária: crescimento moderado
      return 1.25 + ((userLevel - easyPhaseMaxLevel) * 0.1);
    } else {
      // Fase avançada: crescimento exponencial controlado
      final baseMultiplier = 2.25 + ((userLevel - intermediatePhasMaxLevel) * 0.15);
      final dampingFactor = scalingDamping * (userLevel - intermediatePhasMaxLevel);
      return baseMultiplier * dampingFactor;
    }
  }

  /// Calcula o multiplicador de recompensa baseado no nível do usuário
  static double getRewardMultiplier(int userLevel) {
    if (userLevel <= easyPhaseMaxLevel) {
      // Fase fácil: ganhos crescem rapidamente
      return 1.0 + (userLevel * 0.08);
    } else if (userLevel <= intermediatePhasMaxLevel) {
      // Fase intermediária: crescimento estável
      return 1.4 + ((userLevel - easyPhaseMaxLevel) * 0.06);
    } else {
      // Fase avançada: crescimento menor, requer skill
      return 2.0 + ((userLevel - intermediatePhasMaxLevel) * 0.04);
    }
  }

  /// Calcula o desconto por quantidade
  static double getBulkDiscount(int quantity) {
    double discount = 0.0;
    for (final tier in bulkDiscountTiers.entries) {
      if (quantity >= tier.key) {
        discount = tier.value;
      }
    }
    return discount;
  }

  /// Calcula o preço final de um item considerando nível e quantidade
  static int calculateFinalPrice({
    required int basePrice,
    required int userLevel,
    required int quantity,
  }) {
    final priceMultiplier = getPriceMultiplier(userLevel);
    final bulkDiscount = getBulkDiscount(quantity);

    final adjustedPrice = basePrice * priceMultiplier;
    final discountAmount = adjustedPrice * bulkDiscount;
    final finalPrice = adjustedPrice - discountAmount;

    return (finalPrice * quantity).round();
  }

  /// Calcula a recompensa de coins por ação
  static int calculateCoinsReward({
    required int baseReward,
    required int userLevel,
  }) {
    final multiplier = getRewardMultiplier(userLevel);
    return (baseReward * multiplier).round();
  }

  /// Verifica se o usuário pode comprar determinado item
  static bool canAfford({
    required int itemPrice,
    required int userCoins,
    required int userGems,
    required CurrencyType currency,
  }) {
    switch (currency) {
      case CurrencyType.coins:
        return userCoins >= itemPrice;
      case CurrencyType.gems:
        return userGems >= itemPrice;
      case CurrencyType.xp:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
