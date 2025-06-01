import 'dart:math';

import 'package:flutter/material.dart';
import 'package:petverse/feature/minigames/mini_game.dart';

class RockPaperScissorsGame implements MiniGame {
  @override
  String get name => "Pedra ,  Papael , Tessoura";

  @override
  String get description => "Toque nos alvos o mais rápido que puder!";

  @override
  IconData get icon => Icons.my_location;

  @override
  Color get color => Colors.red;

  @override
  Widget buildGame(BuildContext context, Function(int) onGameComplete) {
    return RockPaperScissorsScreen(onGameComplete: onGameComplete);
  }
}

class RockPaperScissorsScreen extends StatefulWidget {
  final Function(int) onGameComplete;
  const RockPaperScissorsScreen({super.key, required this.onGameComplete});

  @override
  State<RockPaperScissorsScreen> createState() =>
      _RockPaperScissorsScreenState();
}

class _RockPaperScissorsScreenState extends State<RockPaperScissorsScreen> {
  int playerScore = 0;
  int computerScore = 0;
  String? playerChoice;
  String? computerChoice;
  String gameResult = '';
  bool showResult = false;
  final Random random = Random();

  final List<String> choices = ['pedra', 'papel', 'tesoura'];
  final Map<String, IconData> choiceIcons = {
    'pedra': Icons.circle,
    'papel': Icons.description,
    'tesoura': Icons.content_cut,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fundo claro para evitar tela escura
      appBar: AppBar(
        title: const Text('Pedra, Papel e Tesoura'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Evita overflow
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildScoreBoard(),
              const SizedBox(height: 20),
              _buildGameArea(),
              const SizedBox(height: 20),
              _buildChoiceButtons(),
              const SizedBox(height: 20),
              _buildResultArea(),
            ],
          ),
        ),
      ),
    );
  } // Widgets auxiliares para a tela do jogo

  Widget _buildScoreBoard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildScoreItem('Você', playerScore, Colors.blue),
          const Text('VS',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          _buildScoreItem('Computador', computerScore, Colors.red),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 16, color: color, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          '$score',
          style: TextStyle(
              fontSize: 32, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildGameArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildChoiceDisplay('Sua escolha', playerChoice, Colors.blue),
          const Icon(Icons.sports_mma, size: 40, color: Colors.grey),
          _buildChoiceDisplay('Computador', computerChoice, Colors.red),
        ],
      ),
    );
  }

  Widget _buildChoiceDisplay(String label, String? choice, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 14, color: color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: choice != null
                ? Icon(
                    choiceIcons[choice],
                    size: 40,
                    color: color,
                  )
                : const Icon(
                    Icons.help_outline,
                    size: 40,
                    color: Colors.grey,
                  ),
          ),
        ],
      ),
    );
  } // Botões de escolha e área de resultado

  Widget _buildChoiceButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Faça sua escolha:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: choices.map((choice) {
              return _buildChoiceButton(choice);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(String choice) {
    return ElevatedButton(
      onPressed: () => _playGame(choice),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(choiceIcons[choice], size: 24),
          const SizedBox(height: 4),
          Text(
            choice.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildResultArea() {
    if (!showResult) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getResultColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getResultColor(), width: 2),
      ),
      child: Column(
        children: [
          Icon(
            _getResultIcon(),
            size: 48,
            color: _getResultColor(),
          ),
          const SizedBox(height: 12),
          Text(
            gameResult,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _getResultColor(),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _resetGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Jogar Novamente'),
          ),
        ],
      ),
    );
  }
  // Lógica do jogo e métodos auxiliares

  void _playGame(String playerChoice) {
    final computerChoice = choices[random.nextInt(choices.length)];

    setState(() {
      this.playerChoice = playerChoice;
      this.computerChoice = computerChoice;
      showResult = true;

      final result = _determineWinner(playerChoice, computerChoice);

      if (result == 'win') {
        playerScore++;
        gameResult = 'Você ganhou!';
      } else if (result == 'lose') {
        computerScore++;
        gameResult = 'Você perdeu!';
      } else {
        gameResult = 'Empate!';
      }
    });

    // Verificar se alguém chegou a 3 pontos
    if (playerScore >= 3 || computerScore >= 3) {
      _endGame();
    }
  }

  String _determineWinner(String player, String computer) {
    if (player == computer) return 'tie';

    if ((player == 'pedra' && computer == 'tesoura') ||
        (player == 'papel' && computer == 'pedra') ||
        (player == 'tesoura' && computer == 'papel')) {
      return 'win';
    }

    return 'lose';
  }

  void _resetGame() {
    setState(() {
      playerChoice = null;
      computerChoice = null;
      gameResult = '';
      showResult = false;
    });
  }

  void _endGame() {
    final finalScore =
        playerScore > computerScore ? playerScore : computerScore;
    widget.onGameComplete(finalScore);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fim de Jogo!'),
          content: Text(
            playerScore > computerScore
                ? 'Parabéns! Você venceu por $playerScore x $computerScore!'
                : 'Que pena! Você perdeu por $computerScore x $playerScore.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Voltar ao Menu'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  playerScore = 0;
                  computerScore = 0;
                  playerChoice = null;
                  computerChoice = null;
                  gameResult = '';
                  showResult = false;
                });
              },
              child: const Text('Jogar Novamente'),
            ),
          ],
        );
      },
    );
  }

  Color _getResultColor() {
    if (gameResult.contains('ganhou')) return Colors.green;
    if (gameResult.contains('perdeu')) return Colors.red;
    return Colors.orange;
  }

  IconData _getResultIcon() {
    if (gameResult.contains('ganhou')) return Icons.emoji_events;
    if (gameResult.contains('perdeu')) return Icons.sentiment_dissatisfied;
    return Icons.handshake;
  }
}
