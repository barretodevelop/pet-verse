import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/theme/colors/app_colors.dart';
import 'package:petverse/feature/minigames/mini_game.dart';

// // NOVO JOGO 9: Sequencia do PET
class SequenceGame implements MiniGame {
  @override
  String get name => "Sequência do Pet";

  @override
  String get description => "Repita a sequência mostrada pelo pet!";

  @override
  IconData get icon => Icons.replay;

  @override
  Color get color => Colors.indigo;

  @override
  Widget buildGame(BuildContext context, Function(int) onGameComplete) {
    return SequenceGameScreen(onGameComplete: onGameComplete);
  }
}

class SequenceGameScreen extends StatefulWidget {
  final Function(int) onGameComplete;

  const SequenceGameScreen({super.key, required this.onGameComplete});

  @override
  _SequenceGameScreenState createState() => _SequenceGameScreenState();
}

class _SequenceGameScreenState extends State<SequenceGameScreen> {
  late List<int> _sequence;
  late List<int> _playerSequence;
  int _currentLevel = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _sequence = [];
    _playerSequence = [];
    _currentLevel = 0;
    _nextLevel();
  }

  void _nextLevel() {
    setState(() {
      _currentLevel++;
      _sequence.add(_random.nextInt(4));
      _playerSequence.clear();
    });

    Future.delayed(const Duration(seconds: 1), () {
      // Mostrar sequência
    });
  }

  final Random _random = Random();

  void _onTileTapped(int index) {
    _playerSequence.add(index);

    if (_playerSequence.length == _sequence.length) {
      if (listsEqual(_playerSequence, _sequence)) {
        setState(() {
          _score += 100;
        });
        Future.delayed(const Duration(seconds: 1), _nextLevel);
      } else {
        widget.onGameComplete(_score);
      }
    }
  }

  // Função auxiliar para comparar listas
  bool listsEqual(List<int> list1, List<int> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sequência do Pet")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Nível $_currentLevel"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (i) {
                return GestureDetector(
                  onTap: () => _onTileTapped(i),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.indigo.withOpacity(0.5),
                    margin: const EdgeInsets.all(8),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class WordMatchGame implements MiniGame {
  @override
  String get name => "Palavra Correta";

  @override
  String get description => "Escolha a palavra que combina com a imagem.";

  @override
  IconData get icon => Icons.text_fields;

  @override
  Color get color => Colors.indigo;

  @override
  Widget buildGame(BuildContext context, Function(int) onGameComplete) {
    return WordMatchGameScreen(onGameComplete: onGameComplete);
  }
}

class WordMatchGameScreen extends StatefulWidget {
  final Function(int) onGameComplete;

  const WordMatchGameScreen({super.key, required this.onGameComplete});

  @override
  _WordMatchGameScreenState createState() => _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends State<WordMatchGameScreen> {
  int _score = 0;
  late MapEntry<String, String> correctPair;
  late List<String> options;

  final Map<String, String> pairs = {
    'dog': 'https://picsum.photos/id/10/200/300 ',
    'cat': 'https://picsum.photos/id/11/200/300 ',
    'car': 'https://picsum.photos/id/12/200/300 ',
    'tree': 'https://picsum.photos/id/13/200/300 ',
  };

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final allKeys = pairs.keys.toList();
    correctPair = MapEntry(
      allKeys[Random().nextInt(allKeys.length)],
      pairs[allKeys[Random().nextInt(allKeys.length)]]!,
    );

    final wrongWords = pairs.keys.where((k) => k != correctPair.key).toList();
    options = [correctPair.key, wrongWords[0], wrongWords[1]];
    options.shuffle();
  }

  void _selectAnswer(String selected) {
    if (selected == correctPair.key) {
      setState(() {
        _score += 10;
        _generateQuestion();
      });
    } else {
      widget.onGameComplete(_score);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Palavra Correta")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Qual é esta imagem?", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Image.network(correctPair.value, height: 200),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: options.map((word) {
                return ElevatedButton(
                  onPressed: () => _selectAnswer(word),
                  child: Text(word.toUpperCase()),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickTapGame implements MiniGame {
  @override
  String get name => "Acerto Rápido";

  @override
  String get description => "Toque na cor exibida antes que ela mude!";

  @override
  IconData get icon => Icons.touch_app;

  @override
  Color get color => Colors.cyan;

  @override
  Widget buildGame(BuildContext context, Function(int) onGameComplete) {
    return QuickTapGameScreen(onGameComplete: onGameComplete);
  }
}

class QuickTapGameScreen extends StatefulWidget {
  final Function(int) onGameComplete;

  const QuickTapGameScreen({super.key, required this.onGameComplete});

  @override
  _QuickTapGameScreenState createState() => _QuickTapGameScreenState();
}

class _QuickTapGameScreenState extends State<QuickTapGameScreen> {
  late Color currentColor;
  late String targetText;
  late Timer _gameTimer;
  int _score = 0;
  bool _isPlaying = true;

  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];
  final List<String> labels = ['Red', 'Green', 'Blue', 'Orange', 'Purple'];

  @override
  void initState() {
    super.initState();
    startRound();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPlaying) {
        widget.onGameComplete(_score);
        _isPlaying = false;
      }
    });
  }

  void startRound() {
    final randIndex = Random().nextInt(colors.length);
    setState(() {
      currentColor = colors[randIndex];
      targetText = labels[randIndex];
    });
  }

  void tapColor(Color tappedColor) {
    if (!_isPlaying) return;

    final correctColorIndex = colors[labels.indexOf(targetText)];
    if (tappedColor == correctColorIndex) {
      setState(() {
        _score++;
        startRound();
      });
    } else {
      _isPlaying = false;
      widget.onGameComplete(_score);
    }
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Acerto Rápido")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Toque em: $targetText", style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          Container(width: 100, height: 100, color: currentColor),
          const SizedBox(height: 40),
          Wrap(
            spacing: 16,
            children: colors.map((color) {
              return GestureDetector(
                onTap: () => tapColor(color),
                child: Container(
                  width: 60,
                  height: 60,
                  color: color.withOpacity(0.7),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Tela de seleção de minijogos
class MinigamesScreen extends ConsumerStatefulWidget {
  const MinigamesScreen({super.key});

  @override
  _MinigamesScreenState createState() => _MinigamesScreenState();
}

class _MinigamesScreenState extends ConsumerState<MinigamesScreen> {
  final List<MiniGame> _games = [
    // DanceGame(),
    // TreasureHuntGame(),
    // DefenseGame(),
    SequenceGame(),
    QuickTapGame(),
    WordMatchGame(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Minijogos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Cabeçalho com estatísticas melhorado
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.accent.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Moedas',
                  '${0}',
                  Icons.monetization_on,
                  AppColors.accent,
                ),
                _buildStatCard(
                  'Jogos',
                  '${0}',
                  Icons.sports_esports,
                  AppColors.primary,
                ),
              ],
            ),
          ),

          // Lista de jogos melhorada
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _games.length,
              itemBuilder: (context, index) {
                final game = _games[index];
                return _buildGameCard(game);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.darkGray,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard(MiniGame game) {
    return GestureDetector(
      onTap: () => _startGame(game),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: game.color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [game.color.withOpacity(0.8), game.color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(game.icon, color: Colors.white, size: 35),
            ),
            const SizedBox(height: 16),
            Text(
              game.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: game.color,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                game.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 11,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(MiniGame game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => game.buildGame(
          context,
          (score) => _handleGameComplete(game, score),
        ),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _handleGameComplete(MiniGame game, int score) {
    // final pet = ref.watch(petProvider);
    // Aqui você implementaria a lógica de salvar pontuação
    // pet.gamesPlayed = (pet.gamesPlayed ?? 0) + 1;
    // pet.earnCoins(score);
    // savePet();
  }
}
