// UserProvider

// lib/providers/user_provider.dart - UserProvider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/models/user_model.dart';
import 'package:petverse/services/firestore_service.dart'; // Importar FirestoreService

// Opcional: Se FirestoreService for um provider
// final firestoreServiceProvider = Provider((ref) => FirestoreService());

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  // Se FirestoreService for um provider:
  // final firestoreService = ref.watch(firestoreServiceProvider);
  // return UserNotifier(firestoreService);
  return UserNotifier(
      FirestoreService()); // Instanciando diretamente por enquanto
});

class UserNotifier extends StateNotifier<UserModel?> {
  final FirestoreService _firestoreService;

  UserNotifier(this._firestoreService) : super(null);

  void setUser(UserModel? user) {
    state = user;
  }

  Future<void> updateCoins(int newCoinAmount) async {
    if (state != null) {
      try {
        await _firestoreService.updateUser(state!.id, {'coins': newCoinAmount});
        state = state!.copyWith(coins: newCoinAmount);
        print(
            '✅ UserProvider: Moedas atualizadas para $newCoinAmount e salvas no Firebase.');
      } catch (e) {
        print('❌ UserProvider: Falha ao atualizar moedas no Firebase: $e');
        rethrow; // Propaga o erro para a UI tratar (ex: mostrar SnackBar)
      }
    }
  }

  Future<void> updateGems(int newGemAmount) async {
    if (state != null) {
      try {
        await _firestoreService.updateUser(state!.id, {'gems': newGemAmount});
        state = state!.copyWith(gems: newGemAmount);
        print(
            '✅ UserProvider: Gemas atualizadas para $newGemAmount e salvas no Firebase.');
      } catch (e) {
        print('❌ UserProvider: Falha ao atualizar gemas no Firebase: $e');
        rethrow;
      }
    }
  }

  Future<void> updateXP(int newXp) async {
    if (state != null) {
      final newLevel = (newXp / 100).floor() + 1;
      try {
        await _firestoreService
            .updateUser(state!.id, {'xp': newXp, 'level': newLevel});
        state = state!.copyWith(xp: newXp, level: newLevel);
        print(
            '✅ UserProvider: XP atualizado para $newXp (Nível $newLevel) e salvo no Firebase.');
      } catch (e) {
        print('❌ UserProvider: Falha ao atualizar XP no Firebase: $e');
        rethrow;
      }
    }
  }

  Future<void> updateAIConfig(Map<String, dynamic> config) async {
    if (state != null) {
      try {
        await _firestoreService.updateUser(state!.id, {'aiConfig': config});
        state = state!.copyWith(aiConfig: config);
        print('✅ UserProvider: AIConfig atualizado e salvo no Firebase.');
      } catch (e) {
        print('❌ UserProvider: Falha ao atualizar AIConfig no Firebase: $e');
        rethrow;
      }
    }
  }
}
