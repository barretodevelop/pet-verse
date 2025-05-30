import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/feature/minigames/mini_game.dart';

class PetPuzzleGame implements MiniGame {
  @override
  String get name => "Quebra-cabeça do Pet";

  @override
  String get description => "Organize as peças para formar a imagem!";

  @override
  IconData get icon => Icons.extension;

  @override
  Color get color => Colors.green;

  @override
  Widget buildGame(BuildContext context, Function(int) onGameComplete) {
    return PetPuzzleGameScreen(onGameComplete: onGameComplete);
  }
}

// Tela do Quebra-cabeça do Pet
class PetPuzzleGameScreen extends StatefulWidget {
  final Function(int) onGameComplete;

  const PetPuzzleGameScreen({super.key, required this.onGameComplete});

  @override
  _PetPuzzleGameScreenState createState() => _PetPuzzleGameScreenState();
}

class _PetPuzzleGameScreenState extends State<PetPuzzleGameScreen> {
  List<int> _puzzlePieces = [];
  int _moves = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializePuzzle();
  }

  void _initializePuzzle() {
    _puzzlePieces = List.generate(16, (index) => index);
    _puzzlePieces.shuffle();
    _moves = 0;
    _isCompleted = false;
  }

  void _movePiece(int index) {
    final emptyIndex = _puzzlePieces.indexOf(15);
    final canMove = _canMovePiece(index, emptyIndex);

    if (canMove) {
      setState(() {
        final temp = _puzzlePieces[index];
        _puzzlePieces[index] = _puzzlePieces[emptyIndex];
        _puzzlePieces[emptyIndex] = temp;
        _moves++;
      });

      HapticFeedback.selectionClick();

      if (_isPuzzleCompleted()) {
        _endGame();
      }
    }
  }

  bool _canMovePiece(int index, int emptyIndex) {
    final row = index ~/ 4;
    final col = index % 4;
    final emptyRow = emptyIndex ~/ 4;
    final emptyCol = emptyIndex % 4;

    return (row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1);
  }

  bool _isPuzzleCompleted() {
    for (int i = 0; i < 15; i++) {
      if (_puzzlePieces[i] != i) return false;
    }
    return true;
  }

  void _endGame() {
    setState(() {
      _isCompleted = true;
    });

    final score = max(500 - _moves * 5, 50);

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
              Icon(Icons.emoji_events, color: Colors.green),
              SizedBox(width: 8),
              Text('Parabéns!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Você completou o quebra-cabeça!'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
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
                        color: Colors.green,
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
                  _initializePuzzle();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
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
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Quebra-cabeça do Pet'),
        backgroundColor: Colors.green,
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
                colors: [Colors.green, Colors.green.shade300],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.touch_app, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Movimentos: $_moves',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Puzzle
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    final piece = _puzzlePieces[index];
                    return GestureDetector(
                      onTap: () => _movePiece(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: piece == 15
                              ? Colors.transparent
                              : Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                piece == 15 ? Colors.transparent : Colors.green,
                            width: 2,
                          ),
                        ),
                        child: piece == 15
                            ? null
                            : Center(
                                child: Text(
                                  '${piece + 1}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Instruções
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade300, Colors.green],
              ),
            ),
            child: const Text(
              '🎯 Toque nas peças para movê-las\n📱 Organize os números de 1 a 15!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
