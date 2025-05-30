import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/feature/minigames/mini_game.dart';

// Jogo de Raspadinhas Virtuais
class ScratchCardsGame implements MiniGame {
  @override
  String get name => "Raspadinhas Virtuais";

  @override
  String get description => "Raspe as cartas e encontre os prêmios!";

  @override
  IconData get icon => Icons.card_giftcard;

  @override
  Color get color => Colors.amber;

  @override
  Widget buildGame(BuildContext context, Function(int) onGameComplete) {
    return ScratchCardsScreen(onGameComplete: onGameComplete);
  }
}

// Tela do Jogo de Raspadinhas
class ScratchCardsScreen extends StatefulWidget {
  final Function(int) onGameComplete;

  const ScratchCardsScreen({super.key, required this.onGameComplete});

  @override
  _ScratchCardsScreenState createState() => _ScratchCardsScreenState();
}

class _ScratchCardsScreenState extends State<ScratchCardsScreen>
    with TickerProviderStateMixin {
  List<ScratchCard> _cards = [];
  int _totalScore = 0;
  int _cardsScratched = 0;
  bool _gameCompleted = false;
  late AnimationController _celebrationController;
  late AnimationController _cardFlipController;

  bool _isScratching = false; // Controle para evitar scroll durante raspagem

  // Tipos de prêmios disponíveis
  final List<Prize> _prizes = [
    Prize(name: "💎 Diamante", value: 100, rarity: PrizeRarity.legendary),
    Prize(name: "🏆 Troféu", value: 80, rarity: PrizeRarity.epic),
    Prize(name: "⭐ Estrela", value: 60, rarity: PrizeRarity.rare),
    Prize(name: "🎁 Presente", value: 40, rarity: PrizeRarity.uncommon),
    Prize(name: "🪙 Moeda", value: 20, rarity: PrizeRarity.common),
    Prize(name: "❌ Vazio", value: 0, rarity: PrizeRarity.common),
  ];

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cardFlipController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _initializeGame();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _cardFlipController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    final random = Random();
    _cards = List.generate(6, (index) {
      // Definir probabilidades dos prêmios
      int prizeIndex;
      final chance = random.nextDouble();
      if (chance < 0.02) {
        // 2% chance - Lendário
        prizeIndex = 0;
      } else if (chance < 0.08) {
        // 6% chance - Épico
        prizeIndex = 1;
      } else if (chance < 0.20) {
        // 12% chance - Raro
        prizeIndex = 2;
      } else if (chance < 0.40) {
        // 20% chance - Incomum
        prizeIndex = 3;
      } else if (chance < 0.70) {
        // 30% chance - Comum
        prizeIndex = 4;
      } else {
        // 30% chance - Vazio
        prizeIndex = 5;
      }
      return ScratchCard(
        id: index,
        prize: _prizes[prizeIndex],
        isScratched: false,
        scratchProgress: 0.0,
      );
    });
    _totalScore = 0;
    _cardsScratched = 0;
    _gameCompleted = false;
  }

  void _onCardScratched(int cardId, double progress) {
    setState(() {
      final cardIndex = _cards.indexWhere((card) => card.id == cardId);
      if (cardIndex != -1) {
        _cards[cardIndex].scratchProgress = progress;
        if (progress >= 0.7 && !_cards[cardIndex].isScratched) {
          _cards[cardIndex].isScratched = true;
          _cardsScratched++;
          _totalScore += _cards[cardIndex].prize.value;
          HapticFeedback.mediumImpact();
          if (_cards[cardIndex].prize.value > 0) {
            _celebrationController.forward().then((_) {
              _celebrationController.reset();
            });
          }
          if (_cardsScratched == _cards.length) {
            _endGame();
          }
        }
      }
    });
  }

  void _endGame() {
    _gameCompleted = true;
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
              Icon(Icons.emoji_events, color: Colors.amber),
              SizedBox(width: 8),
              Text('Jogo Concluído!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Você terminou de raspar todas as cartas!'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Cartas Raspadas: $_cardsScratched',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pontuação Total: $_totalScore',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
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
                widget.onGameComplete(_totalScore);
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
                backgroundColor: Colors.amber,
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
      backgroundColor: Colors.amber[50],
      appBar: AppBar(
        title: const Text('Raspadinhas Virtuais'),
        backgroundColor: Colors.amber,
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
                colors: [Colors.amber, Colors.amber.shade300],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.card_giftcard, color: Colors.white),
                    const SizedBox(height: 4),
                    const Text(
                      'Cartas Raspadas',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      '$_cardsScratched/${_cards.length}',
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
                    const Icon(Icons.stars, color: Colors.white),
                    const SizedBox(height: 4),
                    const Text(
                      'Pontuação',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    AnimatedBuilder(
                      animation: _celebrationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_celebrationController.value * 0.2),
                          child: Text(
                            '$_totalScore',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        );
                      },
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
                physics: const NeverScrollableScrollPhysics(),
                // _isScratching
                //     ? const NeverScrollableScrollPhysics()
                //     : const ScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  // childAspectRatio: 0.8,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return ScratchCardWidget(
                    card: _cards[index],
                    onScratch: _onCardScratched,
                    onScratchingStarted: () {
                      setState(() {
                        _isScratching = true;
                      });
                    },
                    onScratchingEnded: () {
                      setState(() {
                        _isScratching = false;
                      });
                    },
                  );
                },
              ),
            ),
          ),
          // Instruções
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Arraste o dedo sobre as cartas para raspá-las!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.amber[700],
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para cada carta raspável
class ScratchCardWidget extends StatefulWidget {
  final ScratchCard card;
  final Function(int, double) onScratch;
  final VoidCallback onScratchingStarted;
  final VoidCallback onScratchingEnded;

  const ScratchCardWidget({
    super.key,
    required this.card,
    required this.onScratch,
    required this.onScratchingStarted,
    required this.onScratchingEnded,
  });

  @override
  _ScratchCardWidgetState createState() => _ScratchCardWidgetState();
}

class _ScratchCardWidgetState extends State<ScratchCardWidget> {
  List<Offset> _scratchPoints = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const ui.Color.fromARGB(255, 41, 7, 114).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Fundo com o prêmio
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: _getPrizeGradient(widget.card.prize.rarity),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.card.prize.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (widget.card.prize.value > 0)
                    Text(
                      '${widget.card.prize.value} pts',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
            // Camada de "scratch"
            if (!widget.card.isScratched)
              GestureDetector(
                onPanStart: (_) {
                  widget.onScratchingStarted();
                  setState(() {
                    _scratchPoints = [];
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    _scratchPoints.add(details.localPosition);
                  });
                  final progress = _calculateScratchProgress();
                  widget.onScratch(widget.card.id, progress);
                },
                onPanEnd: (_) {
                  widget.onScratchingEnded();
                },
                child: CustomPaint(
                  painter: ScratchPainter(_scratchPoints),
                  size: Size.infinite,
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _calculateScratchProgress() {
    // Estimativa simples baseada no número de pontos raspados
    const totalArea = 200.0 * 140.0; // Aproximação da área da carta
    final scratchedArea =
        _scratchPoints.length * 40.0; // Cada ponto "raspa" ~20 pixels
    return (scratchedArea / totalArea).clamp(0.0, 1.0);
  }

  LinearGradient _getPrizeGradient(PrizeRarity rarity) {
    switch (rarity) {
      case PrizeRarity.legendary:
        return const LinearGradient(
          colors: [Colors.purple, Colors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PrizeRarity.epic:
        return const LinearGradient(
          colors: [Colors.orange, Colors.deepOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PrizeRarity.rare:
        return const LinearGradient(
          colors: [Colors.blue, Colors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PrizeRarity.uncommon:
        return const LinearGradient(
          colors: [Colors.green, Colors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case PrizeRarity.common:
        return const LinearGradient(
          colors: [Colors.grey, Colors.blueGrey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}

// Painter para desenhar o efeito de "scratch"
class ScratchPainter extends CustomPainter {
  final List<Offset> scratchPoints;

  ScratchPainter(this.scratchPoints);

  @override
  void paint(Canvas canvas, Size size) {
    // Fundo prateado/metálico
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE5E5E5), Color(0xFFB8B8B8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Texto "RASPE AQUI"
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'RASPE\nAQUI',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    // Efeito de scratch
    if (scratchPoints.isNotEmpty) {
      final scratchPaint = Paint()
        ..blendMode = BlendMode.clear
        ..strokeWidth = 20.0
        ..strokeCap = StrokeCap.round;
      for (int i = 0; i < scratchPoints.length - 1; i++) {
        canvas.drawLine(scratchPoints[i], scratchPoints[i + 1], scratchPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Modelos de dados
class ScratchCard {
  final int id;
  final Prize prize;
  bool isScratched;
  double scratchProgress;

  ScratchCard({
    required this.id,
    required this.prize,
    this.isScratched = false,
    this.scratchProgress = 0.0,
  });
}

class Prize {
  final String name;
  final int value;
  final PrizeRarity rarity;

  Prize({required this.name, required this.value, required this.rarity});
}

enum PrizeRarity { common, uncommon, rare, epic, legendary }
