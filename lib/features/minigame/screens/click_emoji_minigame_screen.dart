// lib/features/minigame/screens/click_emoji_minigame_screen.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/constants/app_colors.dart';
import 'package:petverse/data/game_data.dart';
import 'package:petverse/shared/enums/enums.dart';
import 'package:petverse/shared/providers/global_providers.dart';
import 'package:petverse/shared/widgets/styled_app_bar.dart';

class ClickEmojiMinigameScreen extends ConsumerStatefulWidget {
  const ClickEmojiMinigameScreen({super.key});
  @override
  ConsumerState<ClickEmojiMinigameScreen> createState() =>
      _ClickEmojiMinigameScreenState();
}

class _ClickEmojiMinigameScreenState
    extends ConsumerState<ClickEmojiMinigameScreen> {
  static const int gameDurationSeconds = 20;
  static const int maxEmojisOnScreen = 8;
  final List<String> _possibleEmojis = GameData.getShopItems(null)
      .where((item) =>
          item.category == ItemCategory.food ||
          item.category == ItemCategory.toy)
      .map((item) => item.emoji)
      .toList()
    ..shuffle();

  String _targetEmoji = '';
  List<String> _visibleEmojis = [];
  int _score = 0;
  int _timeLeft = gameDurationSeconds;
  Timer? _timer;
  final Random _random = Random();
  bool _gameEnded = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _score = 0;
    _timeLeft = gameDurationSeconds;
    _gameEnded = false;
    _generateNewTarget();
    _populateVisibleEmojis();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _endGame();
      }
    });
  }

  void _generateNewTarget() {
    if (_possibleEmojis.isNotEmpty) {
      _targetEmoji = _possibleEmojis[_random.nextInt(_possibleEmojis.length)];
    } else {
      _targetEmoji = '❓';
    }
  }

  void _populateVisibleEmojis() {
    _visibleEmojis.clear();
    if (_possibleEmojis.isEmpty) return;
    if (!_visibleEmojis.contains(_targetEmoji)) {
      _visibleEmojis.add(_targetEmoji);
    }
    while (_visibleEmojis.length < maxEmojisOnScreen &&
        _possibleEmojis.length > _visibleEmojis.length) {
      String randomEmoji =
          _possibleEmojis[_random.nextInt(_possibleEmojis.length)];
      if (!_visibleEmojis.contains(randomEmoji)) {
        _visibleEmojis.add(randomEmoji);
      }
    }
    _visibleEmojis.shuffle();
  }

  void _onEmojiTapped(String tappedEmoji) {
    if (_gameEnded || !mounted) return;
    setState(() {
      if (tappedEmoji == _targetEmoji) {
        _score += 10;
      } else {
        _score -= 5;
      }
      _score = _score.clamp(0, 9999);
      _generateNewTarget();
      _populateVisibleEmojis();
    });
  }

  void _endGame() {
    _timer?.cancel();
    if (!mounted) return;
    setState(() {
      _gameEnded = true;
    });
    ref.read(userProvider.notifier).addCoins(_score ~/ 2);
    ref
        .read(userProvider.notifier)
        .updateQuestProgress(QuestType.playMinigame, 1);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Fim de Jogo!"),
        content:
            Text("Sua pontuação: $_score\nVocê ganhou ${_score ~/ 2} moedas!"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                if (mounted) _startGame();
              },
              child: const Text("Jogar Novamente")),
          TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                if (mounted && context.canPop()) context.pop();
              },
              child: const Text("Sair")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const StyledAppBar(title: "Clique no Emoji!"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Pontuação: $_score",
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(color: theme.colorScheme.onBackground)),
                Text("Tempo: $_timeLeft s",
                    style: theme.textTheme.headlineSmall?.copyWith(
                        color: _timeLeft <= 5
                            ? AppColors.error
                            : theme.colorScheme.onBackground)),
              ]),
              if (!_gameEnded && _targetEmoji.isNotEmpty)
                Column(children: [
                  Text("Clique em:",
                      style: theme.textTheme.titleLarge
                          ?.copyWith(color: theme.colorScheme.onBackground)),
                  Text(_targetEmoji, style: const TextStyle(fontSize: 60)),
                ]),
              if (_gameEnded)
                Center(
                    child: Text("Jogo Encerrado!",
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(color: theme.colorScheme.onBackground))),
              Expanded(
                  child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (maxEmojisOnScreen / 2).ceil(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10),
                itemCount: _visibleEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = _visibleEmojis[index];
                  return GestureDetector(
                    onTap: () => _onEmojiTapped(emoji),
                    child: Card(
                        color: theme.colorScheme.surfaceVariant,
                        elevation: 2,
                        child: Center(
                            child: Text(emoji,
                                style: const TextStyle(fontSize: 40)))),
                  )
                      .animate(target: _gameEnded ? 0 : 1)
                      .shake(hz: 4, duration: 200.ms)
                      .then()
                      .scaleXY(begin: 0.8, end: 1, duration: 300.ms);
                },
                physics: const NeverScrollableScrollPhysics(),
              )),
              if (_gameEnded)
                ElevatedButton(
                    onPressed: _startGame, child: const Text("Recomeçar Jogo"))
            ]),
      ),
    );
  }
}
