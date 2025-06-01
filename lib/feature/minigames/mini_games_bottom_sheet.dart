import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/theme/colors/app_colors.dart';
import 'package:petverse/feature/minigames/games/food_catcher_game.dart';
import 'package:petverse/feature/minigames/games/hidden_path_game.dart';
import 'package:petverse/feature/minigames/games/lucky_wheel_game.dart';
import 'package:petverse/feature/minigames/games/memory_game.dart';
import 'package:petverse/feature/minigames/games/pet_puzzle_game.dart';
import 'package:petverse/feature/minigames/games/pet_runner_game.dart';
import 'package:petverse/feature/minigames/games/reflex_game.dart';
import 'package:petverse/feature/minigames/games/rock_paper_scissors_ame.dart';
import 'package:petverse/feature/minigames/games/scratch_cards_game.dart';
import 'package:petverse/feature/minigames/games/treasure_hunt_game.dart';
import 'package:petverse/feature/minigames/mini_game.dart';

class MinigamesBottomSheet extends ConsumerStatefulWidget {
  const MinigamesBottomSheet({super.key});

  @override
  _MinigamesBottomSheetState createState() => _MinigamesBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MinigamesBottomSheet(),
    );
  }
}

class _MinigamesBottomSheetState extends ConsumerState<MinigamesBottomSheet> {
  final List<MiniGame> _games = [
    PetRunnerGame(),
    MemoryGame(),
    FoodCatcherGame(),
    RockPaperScissorsGame(),
    TreasureHuntGame(),
    ScratchCardsGame(),
    PetPuzzleGame(),
    ReflexGame(),
    HiddenPathGame(),
    LuckyWheelMiniGame(),
    // DinoGame(),
    // SequenceGame(),
    // QuickTapGame(),
    // WordMatchGame(),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85, // 85% da altura da tela
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle para arrastar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Cabeçalho compacto
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Minijogos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Estatísticas em linha
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.accent.withOpacity(0.1),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCompactStatCard(
                        'Moedas',
                        '${0}',
                        Icons.monetization_on,
                        AppColors.accent,
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _buildCompactStatCard(
                        'Jogos',
                        '${0}',
                        Icons.sports_esports,
                        AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de jogos scrollável
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Escolha um jogo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Grid de jogos compacto
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1, // Mais largo que alto
                    ),
                    itemCount: _games.length,
                    itemBuilder: (context, index) {
                      final game = _games[index];
                      return _buildCompactGameCard(game);
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.darkGray,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactGameCard(MiniGame game) {
    return GestureDetector(
      onTap: () => _startGame(game),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: game.color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: game.color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone do jogo
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [game.color.withOpacity(0.8), game.color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(game.icon, color: Colors.white, size: 24),
              ),

              const SizedBox(height: 8),

              // Nome do jogo
              Text(
                game.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: game.color,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Descrição compacta
              Text(
                game.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 10,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame(MiniGame game) {
    Navigator.pop(context); // Fecha o bottom sheet primeiro

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => game.buildGame(
          context,
          (score) => _handleGameComplete(game, score),
        ),
      ),
    );
  }

  void _handleGameComplete(MiniGame game, int score) {
    // final pet = ref.watch(petProvider);
    // Implementar lógica de salvar pontuação
    // pet.gamesPlayed = (pet.gamesPlayed ?? 0) + 1;
    // pet.earnCoins(score);
    // savePet();
  }
}

// Classe auxiliar para usar em outras telas
class MinigamesHelper {
  static void showMinigames(BuildContext context) {
    MinigamesBottomSheet.show(context);
  }
}
