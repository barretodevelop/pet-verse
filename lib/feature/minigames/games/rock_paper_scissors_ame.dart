import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/feature/minigames/mini_game.dart';

// Jogo de Pedra, Papel e Tesoura
class RockPaperScissorsGame implements MiniGame {
  @override
  String get name => "Pedra, Papel e Tesoura";

  @override
  String get description => "Vença o computador em 5 rodadas!";

  @override
  IconData get icon => Icons.back_hand;

  @override
  Color get color => Colors.orange;

  @override
  Widget buildGame(BuildContext context, Function(int) onGameComplete) {
    return RockPaperScissorsScreen(onGameComplete: onGameComplete);
  }
}

enum GameChoice { rock, paper, scissors }

class _GameResult {
  final GameChoice playerChoice;
  final GameChoice computerChoice;
  final String result; // 'win', 'lose', 'draw'

  _GameResult({
    required this.playerChoice,
    required this.computerChoice,
    required this.result,
  });
}

class RockPaperScissorsScreen extends StatefulWidget {
  final Function(int) onGameComplete;

  const RockPaperScissorsScreen({super.key, required this.onGameComplete});

  @override
  _RockPaperScissorsScreenState createState() =>
      _RockPaperScissorsScreenState();
}

class _RockPaperScissorsScreenState extends State<RockPaperScissorsScreen>
    with TickerProviderStateMixin {
  int _playerScore = 0;
  int _computerScore = 0;
  int _currentRound = 1;
  final int _maxRounds = 5;

  GameChoice? _playerChoice;
  GameChoice? _computerChoice;
  String _roundResult = '';
  bool _isPlaying = false;
  bool _gameFinished = false;

  late AnimationController _shakeController;
  late AnimationController _revealController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _revealAnimation;

  final Random _random = Random();
  final List<_GameResult> _gameHistory = [];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut),
    );

    _revealAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _revealController, curve: Curves.bounceOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _playRound(GameChoice playerChoice) async {
    if (_isPlaying || _gameFinished) return;

    setState(() {
      _isPlaying = true;
      _playerChoice = playerChoice;
      _computerChoice = null;
      _roundResult = '';
    });

    HapticFeedback.selectionClick();

    // Animação de balançar as mãos
    await _shakeController.forward();

    // Gerar escolha do computador
    final computerChoice = _generateComputerChoice();

    setState(() {
      _computerChoice = computerChoice;
    });

    // Animação de revelar
    await _revealController.forward();

    // Determinar resultado
    final result = _determineWinner(playerChoice, computerChoice);

    setState(() {
      _roundResult = result;
      if (result == 'Você ganhou!') {
        _playerScore++;
      } else if (result == 'Computador ganhou!') {
        _computerScore++;
      }
    });

    // Adicionar ao histórico
    _gameHistory.add(
      _GameResult(
        playerChoice: playerChoice,
        computerChoice: computerChoice,
        result: result == 'Você ganhou!'
            ? 'win'
            : result == 'Computador ganhou!'
                ? 'lose'
                : 'draw',
      ),
    );

    // Feedback háptico baseado no resultado
    if (result == 'Você ganhou!') {
      HapticFeedback.mediumImpact();
    } else if (result == 'Computador ganhou!') {
      HapticFeedback.lightImpact();
    }

    // Verificar se o jogo terminou
    if (_currentRound >= _maxRounds) {
      _gameFinished = true;
      _endGame();
    } else {
      // Preparar próxima rodada
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          setState(() {
            _currentRound++;
            _isPlaying = false;
            _playerChoice = null;
            _computerChoice = null;
            _roundResult = '';
          });
          _shakeController.reset();
          _revealController.reset();
        }
      });
    }
  }

  GameChoice _generateComputerChoice() {
    const choices = GameChoice.values;
    return choices[_random.nextInt(choices.length)];
  }

  String _determineWinner(GameChoice player, GameChoice computer) {
    if (player == computer) {
      return 'Empate!';
    }

    switch (player) {
      case GameChoice.rock:
        return computer == GameChoice.scissors
            ? 'Você ganhou!'
            : 'Computador ganhou!';
      case GameChoice.paper:
        return computer == GameChoice.rock
            ? 'Você ganhou!'
            : 'Computador ganhou!';
      case GameChoice.scissors:
        return computer == GameChoice.paper
            ? 'Você ganhou!'
            : 'Computador ganhou!';
    }
  }

  void _endGame() {
    final score = _calculateScore();

    Future.delayed(const Duration(milliseconds: 1000), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                _playerScore > _computerScore
                    ? Icons.emoji_events
                    : _playerScore == _computerScore
                        ? Icons.handshake
                        : Icons.sentiment_neutral,
                color:
                    _playerScore > _computerScore ? Colors.orange : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(_getGameResultTitle()),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_getGameResultMessage()),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Você',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '$_playerScore',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Text('×', style: TextStyle(fontSize: 24)),
                        Column(
                          children: [
                            const Text(
                              'Computador',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '$_computerScore',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pontuação: $score',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onGameComplete(score);
                Navigator.of(context).pop();
              },
              child: const Text('Sair'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                'Jogar Novamente',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _getGameResultTitle() {
    if (_playerScore > _computerScore) {
      return 'Vitória!';
    } else if (_playerScore == _computerScore) {
      return 'Empate!';
    } else {
      return 'Derrota!';
    }
  }

  String _getGameResultMessage() {
    if (_playerScore > _computerScore) {
      return 'Parabéns! Você venceu o computador!';
    } else if (_playerScore == _computerScore) {
      return 'Foi um jogo equilibrado!';
    } else {
      return 'Que pena! O computador foi melhor desta vez.';
    }
  }

  int _calculateScore() {
    // Sistema de pontuação baseado na performance
    final baseScore = _playerScore * 20; // 20 pontos por vitória
    final winRate = _playerScore / _maxRounds;
    final bonus = winRate > 0.6
        ? 30
        : winRate > 0.4
            ? 15
            : 0;

    return max(baseScore + bonus, 10); // Mínimo 10 pontos
  }

  void _resetGame() {
    setState(() {
      _playerScore = 0;
      _computerScore = 0;
      _currentRound = 1;
      _playerChoice = null;
      _computerChoice = null;
      _roundResult = '';
      _isPlaying = false;
      _gameFinished = false;
      _gameHistory.clear();
    });
    _shakeController.reset();
    _revealController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Pedra, Papel e Tesoura'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header com informações do jogo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.orange.shade300],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.casino, color: Colors.white),
                    const SizedBox(height: 4),
                    const Text(
                      'Rodada',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      '$_currentRound/$_maxRounds',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.scoreboard, color: Colors.white),
                    const SizedBox(height: 4),
                    const Text(
                      'Placar',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      '$_playerScore × $_computerScore',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Área do jogo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Área de batalha
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        // Lado do jogador
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Você',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 16),
                              AnimatedBuilder(
                                animation: _shakeAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      _isPlaying
                                          ? sin(
                                                _shakeAnimation.value * 4 * pi,
                                              ) *
                                              10
                                          : 0,
                                      0,
                                    ),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: AnimatedBuilder(
                                          animation: _revealAnimation,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: 0.8 +
                                                  (_revealAnimation.value *
                                                      0.4),
                                              child: Icon(
                                                _getChoiceIcon(_playerChoice),
                                                size: 50,
                                                color: Colors.orange,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Versus
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'VS',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            if (_roundResult.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _getResultColor(_roundResult),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _roundResult,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Lado do computador
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Computador',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 16),
                              AnimatedBuilder(
                                animation: _shakeAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      _isPlaying
                                          ? sin(
                                                _shakeAnimation.value * 4 * pi +
                                                    pi,
                                              ) *
                                              10
                                          : 0,
                                      0,
                                    ),
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange.withOpacity(
                                              0.3,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: AnimatedBuilder(
                                          animation: _revealAnimation,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: 0.8 +
                                                  (_revealAnimation.value *
                                                      0.4),
                                              child: Icon(
                                                _getChoiceIcon(_computerChoice),
                                                size: 50,
                                                color: Colors.orange,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Botões de escolha
                  if (!_gameFinished) ...[
                    const SizedBox(height: 32),
                    const Text(
                      'Faça sua escolha:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildChoiceButton(GameChoice.rock, 'Pedra'),
                        _buildChoiceButton(GameChoice.paper, 'Papel'),
                        _buildChoiceButton(GameChoice.scissors, 'Tesoura'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(GameChoice choice, String label) {
    final isDisabled = _isPlaying || _gameFinished;

    return Column(
      children: [
        GestureDetector(
          onTap: isDisabled ? null : () => _playRound(choice),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDisabled ? Colors.grey[300] : Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(isDisabled ? 0.1 : 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _getChoiceIcon(choice),
                size: 40,
                color: isDisabled ? Colors.grey : Colors.orange,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDisabled ? Colors.grey : Colors.orange,
          ),
        ),
      ],
    );
  }

  IconData _getChoiceIcon(GameChoice? choice) {
    switch (choice) {
      case GameChoice.rock:
        return Icons.circle;
      case GameChoice.paper:
        return Icons.description;
      case GameChoice.scissors:
        return Icons.content_cut;
      case null:
        return Icons.back_hand;
    }
  }

  Color _getResultColor(String result) {
    switch (result) {
      case 'Você ganhou!':
        return Colors.green;
      case 'Computador ganhou!':
        return Colors.red;
      case 'Empate!':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}
