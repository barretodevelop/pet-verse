import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/feature/minigames/mini_game.dart';

// Jogo 3: Captura de Comida (Corrigido)
class FoodCatcherGame implements MiniGame {
  @override
  String get name => "Captura de Comida";

  @override
  String get description => "Pegue a comida que cai do céu!";

  @override
  IconData get icon => Icons.fastfood;

  @override
  Color get color => Colors.orange;

  @override
  Widget buildGame(BuildContext context, Function(int) onGameComplete) {
    return FoodCatcherGameScreen(onGameComplete: onGameComplete);
  }
}

// Tela do Jogo Captura de Comida
class FoodCatcherGameScreen extends StatefulWidget {
  final Function(int) onGameComplete;

  const FoodCatcherGameScreen({super.key, required this.onGameComplete});

  @override
  _FoodCatcherGameScreenState createState() => _FoodCatcherGameScreenState();
}

class _FoodCatcherGameScreenState extends State<FoodCatcherGameScreen> {
  double _petPosition = 0.5;
  int _score = 0;
  bool _isPlaying = false;
  bool _gameOver = false;
  final List<_FallingFood> _foods = [];
  final Random _random = Random();
  late Timer _gameTimer;

  final List<String> _foodEmojis = [
    '🍎',
    '🍌',
    '🍓',
    '🥕',
    '🥪',
    '🍪',
    '🧀',
    '🥛',
  ];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _petPosition = 0.5;
      _score = 0;
      _isPlaying = true;
      _gameOver = false;
      _foods.clear();
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }

      setState(() {
        // Mover comidas
        for (var food in _foods) {
          food.y += 0.015;
        }

        // Remover comidas fora da tela
        _foods.removeWhere((food) => food.y > 1.1);

        // Adicionar nova comida
        if (_random.nextDouble() < 0.03) {
          _foods.add(
            _FallingFood(
              x: _random.nextDouble() * 0.8 + 0.1,
              y: -0.1,
              emoji: _foodEmojis[_random.nextInt(_foodEmojis.length)],
            ),
          );
        }

        // Verificar colisões
        _checkCollisions();
      });
    });
  }

  void _checkCollisions() {
    for (var i = _foods.length - 1; i >= 0; i--) {
      if (_foods[i].y > 0.8 && _foods[i].y < 0.95) {
        final dx = (_petPosition - _foods[i].x).abs();
        if (dx < 0.08) {
          setState(() {
            _score += 10;
            _foods.removeAt(i);
          });
          HapticFeedback.lightImpact();
        }
      }
    }

    // Verificar se perdeu alguma comida
    if (_foods.any((food) => food.y > 1.0)) {
      _endGame();
    }
  }

  void _movePet(double position) {
    setState(() {
      _petPosition = position.clamp(0.1, 0.9);
    });
  }

  void _endGame() {
    setState(() {
      _isPlaying = false;
      _gameOver = true;
    });

    _gameTimer.cancel();

    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Fim de Jogo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fastfood, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Comidas capturadas:',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '${_score ~/ 10}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                'Pontuação: $_score',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onGameComplete(_score);
                Navigator.of(context).pop();
              },
              child: const Text('Sair'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startGame();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text('Captura de Comida'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Pontuação
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.orange.shade300],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fastfood, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Pontuação: $_score',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Área do jogo
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final screenWidth = MediaQuery.of(context).size.width;
                _movePet(_petPosition + details.delta.dx / screenWidth);
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.orange[100]!, Colors.orange[50]!],
                  ),
                ),
                child: Stack(
                  children: [
                    // Comidas caindo
                    ..._foods.map(
                      (food) => Positioned(
                        left: food.x * MediaQuery.of(context).size.width,
                        top:
                            food.y * (MediaQuery.of(context).size.height * 0.7),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              food.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Pet
                    Positioned(
                      left:
                          _petPosition * MediaQuery.of(context).size.width - 30,
                      bottom: 60,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Colors.orange[300]!, Colors.orange[600]!],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.pets,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Instruções
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade300, Colors.orange],
              ),
            ),
            child: const Text(
              '👆 Arraste para os lados para mover o pet\n🍎 Capture todas as comidas que caem!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _FallingFood {
  double x;
  double y;
  String emoji;

  _FallingFood({required this.x, required this.y, required this.emoji});
}
