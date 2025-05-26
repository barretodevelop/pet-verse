import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetJumpGame extends ConsumerStatefulWidget {
  const PetJumpGame({super.key});

  @override
  ConsumerState<PetJumpGame> createState() => _PetJumpGameState();
}

class _PetJumpGameState extends ConsumerState<PetJumpGame>
    with TickerProviderStateMixin {
  late AnimationController _jumpController;
  late AnimationController _obstacleController;
  late Timer _gameTimer;
  late Timer _obstacleTimer;

  bool _isJumping = false;
  bool _isGameActive = false;
  int _score = 0;
  double _petBottom = 0;
  final List<Obstacle> _obstacles = [];

  @override
  void initState() {
    super.initState();
    _jumpController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _obstacleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _jumpController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _jumpController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _isJumping = false;
          _petBottom = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _jumpController.dispose();
    _obstacleController.dispose();
    _gameTimer.cancel();
    _obstacleTimer.cancel();
    super.dispose();
  }

  void _jump() {
    if (!_isJumping && _isGameActive) {
      setState(() {
        _isJumping = true;
      });
      _jumpController.forward();
    }
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _isGameActive = true;
      _obstacles.clear();
    });

    // Score timer
    _gameTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isGameActive) {
        setState(() {
          _score++;
        });
        _checkCollisions();
      }
    });

    // Spawn obstacles
    _obstacleTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isGameActive) {
        _spawnObstacle();
      }
    });
  }

  void _spawnObstacle() {
    final random = math.Random();
    final obstacle = Obstacle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      height: random.nextDouble() * 30 + 50,
    );

    setState(() {
      _obstacles.add(obstacle);
    });

    // Remove após sair da tela
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _obstacles.removeWhere((o) => o.id == obstacle.id);
      });
    });
  }

  void _checkCollisions() {
    const petLeft = 50.0;
    const petRight = 100.0;
    final petTop = _petBottom + 100;
    final petBottomPos = _petBottom;

    for (final obstacle in _obstacles) {
      if (obstacle.x < petRight && obstacle.x + 50 > petLeft) {
        if (petBottomPos < obstacle.height) {
          _endGame();
          break;
        }
      }
    }
  }

  void _endGame() {
    _gameTimer.cancel();
    _obstacleTimer.cancel();
    setState(() {
      _isGameActive = false;
    });

    _showResultDialog();
  }

  void _showResultDialog() {
    final coins = (_score / 10).floor();

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
                '🏃 Fim de Jogo! 🏃',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Distância: ${_score}m',
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
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startGame();
                },
                child: const Text('Jogar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _jump,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF87CEEB), Color(0xFFDEB887)],
            ),
          ),
          child: Stack(
            children: [
              // Score
              Positioned(
                top: 50,
                right: 20,
                child: Text(
                  'Score: $_score',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              // Ground
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  color: Colors.green,
                ),
              ),

              // Pet
              AnimatedBuilder(
                animation: _jumpController,
                builder: (context, child) {
                  final jumpHeight = _jumpController.value * 150;
                  return Positioned(
                    bottom: 100 + jumpHeight,
                    left: 50,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),

              // Obstacles
              if (_isGameActive)
                ..._obstacles.map((obstacle) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: MediaQuery.of(context).size.width,
                      end: -100.0,
                    ),
                    duration: const Duration(seconds: 3),
                    builder: (context, value, child) {
                      obstacle.x = value;
                      return Positioned(
                        bottom: 100,
                        left: value,
                        child: Container(
                          width: 50,
                          height: obstacle.height,
                          decoration: BoxDecoration(
                            color: Colors.brown,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  );
                }),

              // Start button
              if (!_isGameActive)
                Center(
                  child: ElevatedButton(
                    onPressed: _startGame,
                    child:
                        const Text('Iniciar', style: TextStyle(fontSize: 24)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class Obstacle {
  final String id;
  final double height;
  double x = 0;

  Obstacle({
    required this.id,
    required this.height,
  });
}
