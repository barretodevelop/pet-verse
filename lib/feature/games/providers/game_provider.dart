// lib/features/games/providers/game_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/feature/economy/providers/economy_provider.dart';

class GameController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  GameController(this._ref) : super(const AsyncData(null));

  Future<void> completeGame({
    required String gameType,
    required int score,
  }) async {
    state = const AsyncLoading();
    try {
      // Calcular moedas baseado no score
      final coins = _calculateCoins(gameType, score);

      // Adicionar moedas
      await _ref.read(economyControllerProvider.notifier).addCoins(coins);

      // TODO: Salvar estatísticas do jogo

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  int _calculateCoins(String gameType, int score) {
    switch (gameType) {
      case 'catch_food':
        return score * 2; // 2 moedas por ponto
      case 'pet_jump':
        return (score / 10).floor(); // 1 moeda a cada 10 metros
      default:
        return score;
    }
  }
}

final gameControllerProvider =
    StateNotifierProvider<GameController, AsyncValue<void>>((ref) {
  return GameController(ref);
});
