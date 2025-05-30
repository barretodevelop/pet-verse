import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/feature/minigames/mini_game.dart';

// Jogo 2: Jogo da Memória (Melhorado)
class MemoryGame implements MiniGame {
  @override
  String get name => "Jogo da Memória";

  @override
  String get description => "Encontre os pares de cartas iguais!";

  @override
  IconData get icon => Icons.grid_view;

  @override
  Color get color => Colors.purple;

  @override
  Widget buildGame(BuildContext context, Function(int) onGameComplete) {
    return MemoryGameScreen(onGameComplete: onGameComplete);
  }
}

// Tela do Jogo da Memória (Melhorada)
class MemoryGameScreen extends StatefulWidget {
  final Function(int) onGameComplete;

  const MemoryGameScreen({super.key, required this.onGameComplete});

  @override
  _MemoryGameScreenState createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen>
    with TickerProviderStateMixin {
  final List<String> _icons = [
    'pets',
    'favorite',
    'star',
    'home',
    'cake',
    'toys',
    'sports_basketball',
    'emoji_nature',
  ];

  late List<_MemoryCard> _cards;
  List<int> _flippedCardIndexes = [];
  int _matchedPairs = 0;
  int _moves = 0;
  bool _isProcessing = false;
  late AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _initializeGame();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    final allIcons = [..._icons, ..._icons];
    allIcons.shuffle();

    _cards = List.generate(
      allIcons.length,
      (index) => _MemoryCard(
        icon: allIcons[index],
        isFlipped: false,
        isMatched: false,
      ),
    );

    _flippedCardIndexes = [];
    _matchedPairs = 0;
    _moves = 0;
  }

  void _flipCard(int index) {
    if (_isProcessing || _cards[index].isFlipped || _cards[index].isMatched) {
      return;
    }

    setState(() {
      _cards[index].isFlipped = true;
      _flippedCardIndexes.add(index);
    });

    HapticFeedback.selectionClick();

    if (_flippedCardIndexes.length == 2) {
      _moves++;
      _isProcessing = true;

      final firstIndex = _flippedCardIndexes[0];
      final secondIndex = _flippedCardIndexes[1];

      if (_cards[firstIndex].icon == _cards[secondIndex].icon) {
        // Par encontrado
        setState(() {
          _cards[firstIndex].isMatched = true;
          _cards[secondIndex].isMatched = true;
          _matchedPairs++;
          _flippedCardIndexes = [];
          _isProcessing = false;
        });

        HapticFeedback.mediumImpact();

        if (_matchedPairs == _icons.length) {
          _endGame();
        }
      } else {
        // Par não encontrado
        Future.delayed(const Duration(milliseconds: 1200), () {
          setState(() {
            _cards[firstIndex].isFlipped = false;
            _cards[secondIndex].isFlipped = false;
            _flippedCardIndexes = [];
            _isProcessing = false;
          });
        });
      }
    }
  }

  void _endGame() {
    final maxMoves = _icons.length * 2;
    final score = max(100 - (_moves - _icons.length) * 3, 10);

    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.orange),
              SizedBox(width: 8),
              Text('Parabéns!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Você completou o jogo!'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Movimentos: $_moves',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pontuação: $score',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
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
                setState(() {
                  _initializeGame();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
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
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: const Text('Jogo da Memória'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Estatísticas do jogo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.purple.shade300],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.touch_app, color: Colors.white),
                    const SizedBox(height: 4),
                    const Text(
                      'Movimentos',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      '$_moves',
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
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(height: 4),
                    const Text(
                      'Pares',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      '$_matchedPairs/${_icons.length}',
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

          // Grid de cartas
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _flipCard(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color:
                            _cards[index].isFlipped || _cards[index].isMatched
                                ? Colors.white
                                : Colors.purple,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child:
                            _cards[index].isFlipped || _cards[index].isMatched
                                ? Icon(
                                    _getIconData(_cards[index].icon),
                                    color: Colors.purple,
                                    size: 32,
                                  )
                                : const Icon(
                                    Icons.help_outline,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'pets':
        return Icons.pets;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'home':
        return Icons.home;
      case 'cake':
        return Icons.cake;
      case 'toys':
        return Icons.toys;
      case 'sports_basketball':
        return Icons.sports_basketball;
      case 'emoji_nature':
        return Icons.emoji_nature;
      default:
        return Icons.help;
    }
  }
}

class _MemoryCard {
  final String icon;
  bool isFlipped;
  bool isMatched;

  _MemoryCard({
    required this.icon,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
