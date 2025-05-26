// lib/features/games/pages/catch_food_game.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:petverse/feature/games/providers/game_provider.dart';
 
class CatchFoodGame extends ConsumerStatefulWidget {
  const CatchFoodGame({super.key});

  @override
  ConsumerState<CatchFoodGame> createState() => _CatchFoodGameState();
}

class _CatchFoodGameState extends ConsumerState<CatchFoodGame>
    with TickerProviderStateMixin {
  late AnimationController _petController;
  late Timer _gameTimer;
  late Timer _spawnTimer;
  
  double _petPosition = 0.5; // 0.0 to 1.0 (left to right)
  int _score = 0;
  int _timeLeft = 30;
  bool _isGameActive = false;
  final List<FallingFood> _fallingFoods = [];
  
  @override
  void initState() {
    super.initState();
    _petController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _petController.dispose();
    _gameTimer.cancel();
    _spawnTimer.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isGameActive = true;
      _fallingFoods.clear();
    });

    // Timer do jogo
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _endGame();
        }
      });
    });

    // Spawnar comidas
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (_isGameActive) {
        _spawnFood();
      }
    });
  }

  void _endGame() {
    _gameTimer.cancel();
    _spawnTimer.cancel();
    setState(() {
      _isGameActive = false;
    });

    // Dar recompensas
    ref.read(gameControllerProvider.notifier).completeGame(
      gameType: 'catch_food',
      score: _score,
    );

    _showResultDialog();
  }

  void _spawnFood() {
    final random = math.Random();
    final food = FallingFood(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      x: random.nextDouble(),
      emoji: _foodEmojis[random.nextInt(_foodEmojis.length)],
      points: random.nextInt(3) + 1,
    );

    setState(() {
      _fallingFoods.add(food);
    });

    // Remover após cair
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _fallingFoods.removeWhere((f) => f.id == food.id);
      });
    });
  }

  void _movePet(double dx) {
    setState(() {
      _petPosition = (_petPosition + dx / 300).clamp(0.0, 1.0);
    });
    _petController.forward(from: 0);
  }

  void _checkCollisions() {
    final petLeft = _petPosition - 0.1;
    final petRight = _petPosition + 0.1;

    final caughtFoods = <FallingFood>[];

    for (final food in _fallingFoods) {
      if (food.y > 0.8 && food.x > petLeft && food.x < petRight) {
        caughtFoods.add(food);
        setState(() {
          _score += food.points;
        });
      }
    }

    if (caughtFoods.isNotEmpty) {
      setState(() {
        _fallingFoods.removeWhere((f) => caughtFoods.contains(f));
      });
      // Feedback visual
      _showCatchFeedback();
    }
  }

  void _showCatchFeedback() {
    // Vibração e animação
    _petController.forward(from: 0);
  }

  void _showResultDialog() {
    final coins = _score * 2;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🎉 Parabéns! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pontuação: $_score',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    '+$coins moedas',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ).animate().scale(delay: 300.ms),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Sair'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _startGame();
                      },
                      child: const Text('Jogar Novamente'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _foodEmojis = ['🍎', '🍖', '🦴', '🥕', '🍗', '🧀', '🥛', '🍪'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87CEEB), Color(0xFF98FB98)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _isGameActive ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '$_timeLeft s',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '$_score',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Área do jogo
              if (_isGameActive) ...[
                // Comidas caindo
                ..._fallingFoods.map((food) {
                  return AnimatedPositioned(
                    duration: const Duration(seconds: 3),
                    curve: Curves.linear,
                    left: food.x * screenWidth - 20,
                    top: food.y * screenHeight,
                    child: Text(
                      food.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                    onEnd: () => _checkCollisions(),
                  );
                }),

                // Pet (cesta)
                Positioned(
                  bottom: 50,
                  left: _petPosition * screenWidth - 50,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      _movePet(details.delta.dx);
                    },
                    child: AnimatedBuilder(
                      animation: _petController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_petController.value * 0.1),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.brown,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shopping_basket,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              // Tela inicial
              if (!_isGameActive)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🍎 Pegue a Comida! 🍖',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Arraste a cesta para pegar as comidas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'Jogar',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FallingFood {
  final String id;
  final double x;
  final String emoji;
  final int points;
  double y = 0;

  FallingFood({
    required this.id,
    required this.x,
    required this.emoji,
    required this.points,
  });
}

