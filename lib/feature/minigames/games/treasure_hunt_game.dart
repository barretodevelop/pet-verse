import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/feature/minigames/mini_game.dart';

// Jogo Caça ao Tesouro
class TreasureHuntGame implements MiniGame {
  @override
  String get name => "Caça ao Tesouro";

  @override
  String get description => "Encontre todos os tesouros escondidos no quintal!";

  @override
  IconData get icon => Icons.search;

  @override
  Color get color => Colors.brown;

  @override
  Widget buildGame(BuildContext context, Function(int) onGameComplete) {
    return TreasureHuntScreen(onGameComplete: onGameComplete);
  }
}

enum TreasureType { bone, ball, treat, toy, gem }

class _Treasure {
  final TreasureType type;
  final Offset position;
  bool isFound;
  final int points;

  _Treasure({
    required this.type,
    required this.position,
    this.isFound = false,
    required this.points,
  });
}

class _Obstacle {
  final Offset position;
  final IconData icon;
  final Color color;

  _Obstacle({required this.position, required this.icon, required this.color});
}

class TreasureHuntScreen extends StatefulWidget {
  final Function(int) onGameComplete;

  const TreasureHuntScreen({super.key, required this.onGameComplete});

  @override
  _TreasureHuntScreenState createState() => _TreasureHuntScreenState();
}

class _TreasureHuntScreenState extends State<TreasureHuntScreen>
    with TickerProviderStateMixin {
  // Inicializando as listas com valores padrão
  final List<_Treasure> _treasures = [];
  final List<_Obstacle> _obstacles = [];
  late Offset _petPosition;
  late AnimationController _petAnimationController;
  late AnimationController _treasureFoundController;
  late Animation<double> _petBounceAnimation;
  late Animation<double> _treasureFoundAnimation;
  int _foundTreasures = 0;
  final int _totalTreasures = 8;
  int _score = 0;
  int _moves = 0;
  int _timeRemaining = 60;
  bool _gameActive = true;
  Timer? _gameTimer;
  final Random _random = Random();
  final double _gridSize = 40.0;
  final double _searchRadius = 50.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeGame();
    _startTimer();
  }

  @override
  void dispose() {
    _petAnimationController.dispose();
    _treasureFoundController.dispose();
    _gameTimer?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    _petAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _treasureFoundController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _petBounceAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _petAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _treasureFoundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _treasureFoundController,
        curve: Curves.bounceOut,
      ),
    );
  }

  void _initializeGame() {
    _petPosition = const Offset(50, 50);
    _generateTreasures();
    _generateObstacles();
  }

  void _generateTreasures() {
    _treasures.clear();
    final treasureTypes = [
      TreasureType.bone,
      TreasureType.ball,
      TreasureType.treat,
      TreasureType.toy,
      TreasureType.gem,
    ];
    for (int i = 0; i < _totalTreasures; i++) {
      Offset position;
      int attempts = 0;
      do {
        position = Offset(
          _random.nextDouble() * 280 + 20,
          _random.nextDouble() * 400 + 100,
        );
        attempts++;
      } while (_isTooCloseToOthers(position) && attempts < 50);
      _treasures.add(
        _Treasure(
          type: treasureTypes[_random.nextInt(treasureTypes.length)],
          position: position,
          points: _getTreasurePoints(
            treasureTypes[_random.nextInt(treasureTypes.length)],
          ),
        ),
      );
    }
  }

  void _generateObstacles() {
    _obstacles.clear();
    final obstacleIcons = [
      Icons.local_florist,
      Icons.park,
      Icons.grass,
      Icons.waves,
    ];
    final obstacleColors = [
      Colors.green,
      Colors.brown,
      Colors.lightGreen,
      Colors.blue,
    ];
    for (int i = 0; i < 6; i++) {
      Offset position;
      int attempts = 0;
      do {
        position = Offset(
          _random.nextDouble() * 280 + 20,
          _random.nextDouble() * 400 + 100,
        );
        attempts++;
      } while (_isTooCloseToOthers(position) && attempts < 50);
      final iconIndex = _random.nextInt(obstacleIcons.length);
      _obstacles.add(
        _Obstacle(
          position: position,
          icon: obstacleIcons[iconIndex],
          color: obstacleColors[iconIndex],
        ),
      );
    }
  }

  bool _isTooCloseToOthers(Offset position) {
    if ((_petPosition - position).distance < 80) return true;
    for (final treasure in _treasures) {
      if ((position - treasure.position).distance < 60) return true;
    }
    for (final obstacle in _obstacles) {
      if ((position - obstacle.position).distance < 60) return true;
    }
    return false;
  }

  int _getTreasurePoints(TreasureType type) {
    switch (type) {
      case TreasureType.gem:
        return 25;
      case TreasureType.toy:
        return 20;
      case TreasureType.treat:
        return 15;
      case TreasureType.ball:
        return 12;
      case TreasureType.bone:
        return 10;
    }
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0 && _gameActive) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _endGame();
      }
    });
  }

  void _movePet(Offset newPosition) {
    if (!_gameActive) return;
    setState(() {
      _petPosition = newPosition;
      _moves++;
    });
    _petAnimationController.forward().then((_) {
      _petAnimationController.reverse();
    });
    HapticFeedback.selectionClick();
    _checkForTreasures();
  }

  void _checkForTreasures() {
    for (int i = 0; i < _treasures.length; i++) {
      final treasure = _treasures[i];
      if (!treasure.isFound) {
        final distance = (_petPosition - treasure.position).distance;
        if (distance <= _searchRadius) {
          _foundTreasure(i);
          break;
        }
      }
    }
  }

  void _foundTreasure(int index) {
    setState(() {
      _treasures[index].isFound = true;
      _foundTreasures++;
      _score += _treasures[index].points;
    });
    _treasureFoundController.forward().then((_) {
      _treasureFoundController.reverse();
    });
    HapticFeedback.mediumImpact();
    if (_foundTreasures >= _totalTreasures) {
      _endGame();
    }
  }

  void _endGame() {
    setState(() {
      _gameActive = false;
    });
    _gameTimer?.cancel();
    final timeBonus = _timeRemaining * 2;
    final efficiencyBonus = max(0, 100 - _moves);
    final finalScore = _score + timeBonus + efficiencyBonus;
    Future.delayed(const Duration(milliseconds: 500), () {
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
                _foundTreasures >= _totalTreasures
                    ? Icons.emoji_events
                    : Icons.search,
                color: Colors.brown,
              ),
              const SizedBox(width: 8),
              Text(
                _foundTreasures >= _totalTreasures
                    ? 'Missão Completa!'
                    : 'Fim do Tempo!',
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _foundTreasures >= _totalTreasures
                    ? 'Parabéns! Você encontrou todos os tesouros!'
                    : 'Você encontrou $_foundTreasures de $_totalTreasures tesouros!',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.brown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tesouros:'),
                        Text('$_score pts'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tempo:'),
                        Text('+$timeBonus pts'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Eficiência:'),
                        Text('+$efficiencyBonus pts'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$finalScore pts',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ],
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
                widget.onGameComplete(finalScore);
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
                backgroundColor: Colors.brown,
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

  void _resetGame() {
    setState(() {
      _foundTreasures = 0;
      _score = 0;
      _moves = 0;
      _timeRemaining = 60;
      _gameActive = true;
      _petPosition = const Offset(50, 50);
    });
    _initializeGame();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: AppBar(
        title: const Text('Caça ao Tesouro'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header com informações
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.brown, Colors.brown.shade300],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.timer, color: Colors.white),
                    const SizedBox(height: 4),
                    const Text(
                      'Tempo',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      '${_timeRemaining}s',
                      style: TextStyle(
                        color: _timeRemaining <= 10
                            ? Colors.red[200]
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.search, color: Colors.white),
                    const SizedBox(height: 4),
                    const Text(
                      'Tesouros',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      '$_foundTreasures/$_totalTreasures',
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
                    const Icon(Icons.star, color: Colors.white),
                    const SizedBox(height: 4),
                    const Text(
                      'Pontos',
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
              ],
            ),
          ),
          // Área do jogo
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[200],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.brown, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: GestureDetector(
                  onTapDown: (details) {
                    if (_gameActive) {
                      final RenderBox box =
                          context.findRenderObject() as RenderBox;
                      final localOffset = box.globalToLocal(
                        details.globalPosition,
                      );
                      final adjustedOffset = Offset(
                        localOffset.dx - 16,
                        localOffset.dy - 120, // Ajuste para header
                      );
                      if (adjustedOffset.dx >= 0 &&
                          adjustedOffset.dy >= 0 &&
                          adjustedOffset.dx <= 320 &&
                          adjustedOffset.dy <= 500) {
                        _movePet(adjustedOffset);
                      }
                    }
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Stack(
                      children: [
                        // Fundo do quintal
                        ...List.generate(
                          20,
                          (index) => Positioned(
                            left: _random.nextDouble() * 300,
                            top: _random.nextDouble() * 450,
                            child: Icon(
                              Icons.grass,
                              color: Colors.green[300],
                              size: 16,
                            ),
                          ),
                        ),
                        // Obstáculos
                        ..._obstacles.map(
                          (obstacle) => Positioned(
                            left: obstacle.position.dx,
                            top: obstacle.position.dy,
                            child: Icon(
                              obstacle.icon,
                              color: obstacle.color,
                              size: 30,
                            ),
                          ),
                        ),
                        // Tesouros (apenas os encontrados)
                        ..._treasures.asMap().entries.map((entry) {
                          final treasure = entry.value;
                          if (!treasure.isFound) return const SizedBox.shrink();
                          return Positioned(
                            left: treasure.position.dx - 15,
                            top: treasure.position.dy - 15,
                            child: AnimatedBuilder(
                              animation: _treasureFoundAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 0.8 +
                                      (_treasureFoundAnimation.value * 0.4),
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.yellow[100],
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.yellow,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      _getTreasureIcon(treasure.type),
                                      color: Colors.orange[800],
                                      size: 20,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                        // Pet
                        Positioned(
                          left: _petPosition.dx - 20,
                          top: _petPosition.dy - 20,
                          child: AnimatedBuilder(
                            animation: _petBounceAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _petBounceAnimation.value,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.orange[300],
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.brown.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.pets,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Área de busca (círculo ao redor do pet)
                        Positioned(
                          left: _petPosition.dx - _searchRadius,
                          top: _petPosition.dy - _searchRadius,
                          child: Container(
                            width: _searchRadius * 2,
                            height: _searchRadius * 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.brown.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Instruções
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Toque na tela para mover seu pet e encontrar os tesouros escondidos!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.brown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTreasureIcon(TreasureType type) {
    switch (type) {
      case TreasureType.bone:
        return Icons.pets;
      case TreasureType.ball:
        return Icons.sports_tennis;
      case TreasureType.treat:
        return Icons.cookie;
      case TreasureType.toy:
        return Icons.toys;
      case TreasureType.gem:
        return Icons.diamond;
    }
  }
}
