import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/feature/minigames/mini_game.dart';

class ReflexGame implements MiniGame {
  @override
  String get name => "Reflexo do Pet";

  @override
  String get description => "Toque nos alvos o mais rápido que puder!";

  @override
  IconData get icon => Icons.my_location;

  @override
  Color get color => Colors.red;

  @override
  Widget buildGame(BuildContext context, Function(int) onGameComplete) {
    return ReflexGameScreen(onGameComplete: onGameComplete);
  }
}

// Tela do Jogo de Reflexo
class ReflexGameScreen extends StatefulWidget {
  final Function(int) onGameComplete;

  const ReflexGameScreen({super.key, required this.onGameComplete});

  @override
  _ReflexGameScreenState createState() => _ReflexGameScreenState();
}

class _ReflexGameScreenState extends State<ReflexGameScreen> {
  final List<_Target> _targets = [];
  int _score = 0;
  int _targetCount = 0;
  bool _isPlaying = false;
  bool _gameOver = false;
  late Timer _gameTimer;
  final Random _random = Random();

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
      _targets.clear();
      _score = 0;
      _targetCount = 0;
      _isPlaying = true;
      _gameOver = false;
    });

    _spawnTarget();
  }

  void _spawnTarget() {
    if (!_isPlaying || _targetCount >= 20) {
      _endGame();
      return;
    }

    final target = _Target(
      x: _random.nextDouble() * 0.8 + 0.1,
      y: _random.nextDouble() * 0.6 + 0.2,
      id: _targetCount,
    );

    setState(() {
      _targets.add(target);
      _targetCount++;
    });

    Timer(const Duration(milliseconds: 1500), () {
      if (_targets.any((t) => t.id == target.id)) {
        setState(() {
          _targets.removeWhere((t) => t.id == target.id);
        });
        _spawnTarget();
      }
    });
  }

  void _hitTarget(int targetId) {
    setState(() {
      _targets.removeWhere((t) => t.id == targetId);
      _score += 10;
    });

    HapticFeedback.mediumImpact();
    _spawnTarget();
  }

  void _endGame() {
    setState(() {
      _isPlaying = false;
      _gameOver = true;
    });

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
              const Icon(Icons.my_location, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Alvos atingidos:',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                '${_score ~/ 10}/20',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        title: const Text('Reflexo do Pet'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Estatísticas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.red.shade300],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.my_location, color: Colors.white),
                    const SizedBox(height: 4),
                    const Text(
                      'Pontuação',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      '$_score',
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
                    const Icon(Icons.visibility, color: Colors.white),
                    const SizedBox(height: 4),
                    const Text(
                      'Alvos',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      '$_targetCount/20',
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.red[100]!, Colors.red[50]!],
                ),
              ),
              child: Stack(
                children: [
                  // Alvos
                  ..._targets.map(
                    (target) => Positioned(
                      left: target.x * MediaQuery.of(context).size.width - 30,
                      top:
                          target.y * (MediaQuery.of(context).size.height * 0.7),
                      child: GestureDetector(
                        onTap: () => _hitTarget(target.id),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [Colors.red[300]!, Colors.red[600]!],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Instruções
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade300, Colors.red],
              ),
            ),
            child: const Text(
              '🎯 Toque nos alvos vermelhos o mais rápido possível!\n⚡ Você tem 1.5 segundos para cada alvo!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _Target {
  double x;
  double y;
  int id;

  _Target({required this.x, required this.y, required this.id});
}
