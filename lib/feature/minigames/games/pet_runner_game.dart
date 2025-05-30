// Jogo 1: Corrida do Pet (Melhorado)
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/feature/minigames/mini_game.dart';

class PetRunnerGame implements MiniGame {
  @override
  String get name => "Corrida do Pet";

  @override
  String get description => "Desvie dos obstáculos e colete moedas!";

  @override
  IconData get icon => Icons.directions_run;

  @override
  Color get color => Colors.blue;

  @override
  Widget buildGame(BuildContext context, Function(int) onGameComplete) {
    return PetRunnerGameScreen(onGameComplete: onGameComplete);
  }
}

// Tela do jogo Corrida do Pet (Melhorada)
class PetRunnerGameScreen extends StatefulWidget {
  final Function(int) onGameComplete;

  const PetRunnerGameScreen({super.key, required this.onGameComplete});

  @override
  _PetRunnerGameScreenState createState() => _PetRunnerGameScreenState();
}

class _PetRunnerGameScreenState extends State<PetRunnerGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _petPosition = 0.5;
  int _score = 0;
  bool _isPlaying = false;
  bool _gameOver = false;

  final List<_RunnerGameObject> _obstacles = [];
  final List<_RunnerGameObject> _coins = [];

  final Random _random = Random();
  late Timer _gameTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _startGame();
  }

  @override
  void dispose() {
    _controller.dispose();
    _gameTimer.cancel();
    super.dispose();
  }

  void _startGame() {
    setState(() {
      _petPosition = 0.5;
      _score = 0;
      _isPlaying = true;
      _gameOver = false;
      _obstacles.clear();
      _coins.clear();
    });

    _gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }

      setState(() {
        // Velocidade aumenta com o tempo
        final speed = 0.02 + (_score / 5000);

        // Mover obstáculos e moedas
        for (var obstacle in _obstacles) {
          obstacle.y += speed;
        }

        for (var coin in _coins) {
          coin.y += speed * 0.8;
        }

        // Remover objetos fora da tela
        _obstacles.removeWhere((obstacle) => obstacle.y > 1.1);
        _coins.removeWhere((coin) => coin.y > 1.1);

        // Adicionar novos obstáculos (frequência aumenta)
        if (_random.nextDouble() < 0.04 + (_score / 10000)) {
          _obstacles.add(
            _RunnerGameObject(
              x: _random.nextDouble() * 0.7 + 0.15,
              y: -0.1,
              size: 0.08 + _random.nextDouble() * 0.04,
            ),
          );
        }

        // Adicionar novas moedas
        if (_random.nextDouble() < 0.025) {
          _coins.add(
            _RunnerGameObject(
              x: _random.nextDouble() * 0.7 + 0.15,
              y: -0.1,
              size: 0.06,
            ),
          );
        }

        // Verificar colisões
        _checkCollisions();

        // Aumentar pontuação
        _score += 1;
      });
    });
  }

  void _checkCollisions() {
    // Colisão com obstáculos (melhorada)
    for (var obstacle in _obstacles) {
      if (_isColliding(
        _petPosition,
        0.85,
        0.08,
        obstacle.x,
        obstacle.y,
        obstacle.size * 0.8, // Colisão mais generosa
      )) {
        _endGame();
        return;
      }
    }

    // Colisão com moedas (corrigida)
    for (var i = _coins.length - 1; i >= 0; i--) {
      if (_isColliding(
        _petPosition,
        0.85,
        0.08,
        _coins[i].x,
        _coins[i].y,
        _coins[i].size,
      )) {
        setState(() {
          _score += 50; // Mais pontos por moeda
          _coins.removeAt(i); // Remove a moeda coletada
        });
        // Feedback visual
        HapticFeedback.lightImpact();
      }
    }
  }

  bool _isColliding(
    double x1,
    double y1,
    double size1,
    double x2,
    double y2,
    double size2,
  ) {
    final dx = (x1 - x2).abs();
    final dy = (y1 - y2).abs();
    final maxDistance = (size1 + size2) / 2;
    return dx < maxDistance && dy < maxDistance;
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
    HapticFeedback.mediumImpact();

    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Fim de Jogo',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 48,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              const Text('Sua pontuação:', style: TextStyle(fontSize: 16)),
              Text(
                '$_score',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text('Corrida do Pet'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Pontuação melhorada
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue.shade300],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.white),
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

          // Área do jogo melhorada
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
                    colors: [Colors.lightBlue[100]!, Colors.blue[50]!],
                  ),
                ),
                child: Stack(
                  children: [
                    // Obstáculos melhorados
                    ..._obstacles.map(
                      (obstacle) => Positioned(
                        left: obstacle.x * MediaQuery.of(context).size.width,
                        top: obstacle.y *
                            (MediaQuery.of(context).size.height * 0.7),
                        child: Container(
                          width:
                              obstacle.size * MediaQuery.of(context).size.width,
                          height:
                              obstacle.size * MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [Colors.red[400]!, Colors.red[700]!],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),

                    // Moedas melhoradas
                    ..._coins.map(
                      (coin) => Positioned(
                        left: coin.x * MediaQuery.of(context).size.width,
                        top:
                            coin.y * (MediaQuery.of(context).size.height * 0.7),
                        child: Container(
                          width: coin.size * MediaQuery.of(context).size.width,
                          height: coin.size * MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [Colors.amber[300]!, Colors.amber[600]!],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.monetization_on,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),

                    // Pet melhorado
                    Positioned(
                      left:
                          _petPosition * MediaQuery.of(context).size.width - 30,
                      bottom: 60,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [Colors.blue[300]!, Colors.blue[600]!],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
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

                    // Game Over melhorado
                    if (_gameOver)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.crop_rotate_sharp,
                                color: Colors.white,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Fim de Jogo!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Instruções melhoradas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade300, Colors.blue],
              ),
            ),
            child: const Text(
              '👆 Arraste para os lados para mover o pet\n🔴 Desvie dos obstáculos vermelhos\n🪙 Colete as moedas douradas!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// Objeto do jogo melhorado
class _RunnerGameObject {
  double x;
  double y;
  double size;

  _RunnerGameObject({required this.x, required this.y, required this.size});
}
