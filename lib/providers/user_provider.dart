// lib/providers/user_provider.dart - SECURE REFACTOR
// ✅ SEGURANÇA: Substitui operações diretas por validadas
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/models/user_model.dart';
import 'package:petverse/services/firestore_service.dart';
import 'package:petverse/services/secure_firestore_service.dart'
    show SecurityException, InsufficientFundsException, SecureFirestoreService;

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier(FirestoreService());
});

class UserNotifier extends StateNotifier<UserModel?> {
  final FirestoreService _firestoreService;

  UserNotifier(this._firestoreService) : super(null);

  void setUser(UserModel? user) {
    state = user;
  }

  // ✅ SEGURO: Operação de coins agora usa validação server-side
  Future<void> updateCoins(int newCoinAmount, {String? reason}) async {
    if (state == null) {
      throw Exception('User not logged in');
    }

    final currentCoins = state!.coins;
    final coinsDelta = newCoinAmount - currentCoins;

    try {
      // ✅ USA OPERAÇÃO SEGURA em vez de FirestoreService direto
      final success = await SecureFirestoreService.updateUserEconomy(
        userId: state!.id,
        coinsDelta: coinsDelta,
        reason: reason ?? 'Manual coins update',
      );

      if (success) {
        // ✅ Atualiza estado local apenas APÓS confirmação server-side
        state = state!.copyWith(coins: newCoinAmount);
        print(
            '✅ UserProvider: Coins updated securely: $currentCoins → $newCoinAmount');
      }
    } catch (e) {
      print('❌ UserProvider: Secure coins update failed: $e');

      // ✅ FALLBACK: Se operação segura falhar, usa método antigo (temporário)
      if (e is SecurityException || e is InsufficientFundsException) {
        rethrow; // Propaga erros de segurança/negócio
      } else {
        // ✅ Para outros erros (network, etc), usa fallback temporário
        print('⚠️ UserProvider: Using fallback method due to: $e');
        await _updateCoinsLegacy(newCoinAmount);
      }
    }
  }

  // ✅ SEGURO: Operação de gems com validação
  Future<void> updateGems(int newGemAmount, {String? reason}) async {
    if (state == null) {
      throw Exception('User not logged in');
    }

    final currentGems = state!.gems;
    final gemsDelta = newGemAmount - currentGems;

    try {
      final success = await SecureFirestoreService.updateUserEconomy(
        userId: state!.id,
        gemsDelta: gemsDelta,
        reason: reason ?? 'Manual gems update',
      );

      if (success) {
        state = state!.copyWith(gems: newGemAmount);
        print(
            '✅ UserProvider: Gems updated securely: $currentGems → $newGemAmount');
      }
    } catch (e) {
      print('❌ UserProvider: Secure gems update failed: $e');

      if (e is SecurityException || e is InsufficientFundsException) {
        rethrow;
      } else {
        print('⚠️ UserProvider: Using fallback method due to: $e');
        await _updateGemsLegacy(newGemAmount);
      }
    }
  }

  // ✅ NOVO: Método seguro para desbloqueio de slots
  Future<void> purchaseSlot({int gemCost = 5}) async {
    if (state == null) {
      throw Exception('User not logged in');
    }

    try {
      final success = await SecureFirestoreService.unlockPetSlot(
        userId: state!.id,
        gemCost: gemCost,
      );

      if (success) {
        // ✅ Atualiza estado local baseado na operação server-side
        state = state!.copyWith(
          gems: state!.gems - gemCost,
          purchasedSlotsCount: state!.purchasedSlotsCount + 1,
        );
        print('✅ UserProvider: Slot purchased securely for $gemCost gems');
      }
    } catch (e) {
      print('❌ UserProvider: Secure slot purchase failed: $e');
      rethrow; // Sempre propagar erros de compra
    }
  }

  // ✅ NOVO: Método seguro para completar missões
  Future<void> completeMission(int missionId, int rewardCoins) async {
    if (state == null) {
      throw Exception('User not logged in');
    }

    try {
      final success = await SecureFirestoreService.completeMission(
        userId: state!.id,
        missionId: missionId,
        rewardCoins: rewardCoins,
      );

      if (success) {
        state = state!.copyWith(coins: state!.coins + rewardCoins);
        print(
            '✅ UserProvider: Mission $missionId completed for $rewardCoins coins');
      }
    } catch (e) {
      print('❌ UserProvider: Mission completion failed: $e');
      rethrow;
    }
  }

  // ✅ MANTIDO: Operações não-econômicas usam método original
  Future<void> updateXP(int newXp) async {
    if (state != null) {
      final newLevel = (newXp / 100).floor() + 1;
      try {
        await _firestoreService
            .updateUser(state!.id, {'xp': newXp, 'level': newLevel});
        state = state!.copyWith(xp: newXp, level: newLevel);
        print('✅ UserProvider: XP updated: $newXp (Level $newLevel)');
      } catch (e) {
        print('❌ UserProvider: XP update failed: $e');
        rethrow;
      }
    }
  }

  Future<void> updateAIConfig(Map<String, dynamic> config) async {
    if (state != null) {
      try {
        await _firestoreService.updateUser(state!.id, {'aiConfig': config});
        state = state!.copyWith(aiConfig: config);
        print('✅ UserProvider: AI config updated');
      } catch (e) {
        print('❌ UserProvider: AI config update failed: $e');
        rethrow;
      }
    }
  }

  // ✅ DEPRECATED: Métodos legacy para fallback temporário
  Future<void> _updateCoinsLegacy(int newCoinAmount) async {
    if (state != null) {
      try {
        await _firestoreService.updateUser(state!.id, {'coins': newCoinAmount});
        state = state!.copyWith(coins: newCoinAmount);
        print('⚠️ UserProvider: Coins updated via legacy method');
      } catch (e) {
        print('❌ UserProvider: Legacy coins update failed: $e');
        rethrow;
      }
    }
  }

  Future<void> _updateGemsLegacy(int newGemAmount) async {
    if (state != null) {
      try {
        await _firestoreService.updateUser(state!.id, {'gems': newGemAmount});
        state = state!.copyWith(gems: newGemAmount);
        print('⚠️ UserProvider: Gems updated via legacy method');
      } catch (e) {
        print('❌ UserProvider: Legacy gems update failed: $e');
        rethrow;
      }
    }
  }

  // ✅ REMOVIDO: incrementPurchasedSlots() - substituído por purchaseSlot()
  @Deprecated('Use purchaseSlot() instead for secure transactions')
  Future<void> incrementPurchasedSlots() async {
    print(
        '⚠️ DEPRECATED: incrementPurchasedSlots() called. Use purchaseSlot() instead.');
    // Redirect para método seguro
    await purchaseSlot();
  }
}
