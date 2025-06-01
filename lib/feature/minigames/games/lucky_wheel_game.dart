// lib/features/minigames/lucky_wheel/lucky_wheel_game.dart
// NOVO: Implementação completa da Roleta da Sorte com arquitetura limpa

// lib/features/minigames/lucky_wheel/lucky_wheel_mini_game.dart
// NOVO: Interface para integração com o sistema de minijogos

import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/feature/minigames/mini_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LuckyWheelMiniGame implements MiniGame {
  @override
  String get name => "Roleta da Sorte Pro";

  @override
  String get description =>
      "Gire a roleta e ganhe moedas, gemas e prêmios incríveis!";

  @override
  IconData get icon => Icons.casino_outlined;

  @override
  Color get color => Colors.deepPurple;

  @override
  Widget buildGame(BuildContext context, Function(int) onGameComplete) {
    return LuckyWheelGame(onGameComplete: onGameComplete);
  }
}

// ==========================================================================

// ==== Modelos de Dados ====
class PrizeModel {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final int value;
  final PrizeType type;
  final double probability;

  const PrizeModel({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.type,
    required this.probability,
  });
}

enum PrizeType { coins, gems, spins, mystery, jackpot }

class GameState {
  final int coins;
  final int spins;
  final int level;
  final double multiplier;
  final int dailySpins;
  final DateTime? lastPlayDate;

  const GameState({
    required this.coins,
    required this.spins,
    required this.level,
    required this.multiplier,
    required this.dailySpins,
    required this.lastPlayDate,
  });

  GameState copyWith({
    int? coins,
    int? spins,
    int? level,
    double? multiplier,
    int? dailySpins,
    DateTime? lastPlayDate,
  }) {
    return GameState(
      coins: coins ?? this.coins,
      spins: spins ?? this.spins,
      level: level ?? this.level,
      multiplier: multiplier ?? this.multiplier,
      dailySpins: dailySpins ?? this.dailySpins,
      lastPlayDate: lastPlayDate ?? this.lastPlayDate,
    );
  }
}

// ==== Controlador do Jogo ====
class LuckyWheelController extends ChangeNotifier {
  static const String _coinsKey = 'lucky_wheel_coins';
  static const String _spinsKey = 'lucky_wheel_spins';
  static const String _levelKey = 'lucky_wheel_level';
  static const String _multiplierKey = 'lucky_wheel_multiplier';
  static const String _dailySpinsKey = 'lucky_wheel_daily_spins';
  static const String _lastPlayDateKey = 'lucky_wheel_last_play_date';

  GameState _gameState = const GameState(
    coins: 0,
    spins: 5,
    level: 1,
    multiplier: 1.0,
    dailySpins: 5,
    lastPlayDate: null,
  );

  bool _isSpinning = false;
  PrizeModel? _lastPrize;

  GameState get gameState => _gameState;
  bool get isSpinning => _isSpinning;
  PrizeModel? get lastPrize => _lastPrize;

  // Lista de prêmios configurada para melhor balanceamento
  final List<PrizeModel> _prizes = [
    PrizeModel(
      id: '1',
      label: '10',
      icon: Icons.monetization_on,
      color: Colors.blue.shade400,
      value: 10,
      type: PrizeType.coins,
      probability: 0.25,
    ),
    PrizeModel(
      id: '2',
      label: '25',
      icon: Icons.monetization_on,
      color: Colors.green.shade400,
      value: 25,
      type: PrizeType.coins,
      probability: 0.20,
    ),
    PrizeModel(
      id: '3',
      label: '50',
      icon: Icons.monetization_on,
      color: Colors.orange.shade400,
      value: 50,
      type: PrizeType.coins,
      probability: 0.15,
    ),
    PrizeModel(
      id: '4',
      label: '💎',
      icon: Icons.diamond,
      color: Colors.cyan.shade400,
      value: 5,
      type: PrizeType.gems,
      probability: 0.10,
    ),
    PrizeModel(
      id: '5',
      label: '100',
      icon: Icons.monetization_on,
      color: Colors.purple.shade400,
      value: 100,
      type: PrizeType.coins,
      probability: 0.10,
    ),
    PrizeModel(
      id: '6',
      label: '+3',
      icon: Icons.refresh,
      color: Colors.amber.shade400,
      value: 3,
      type: PrizeType.spins,
      probability: 0.08,
    ),
    PrizeModel(
      id: '7',
      label: '🎁',
      icon: Icons.card_giftcard,
      color: Colors.pink.shade400,
      value: 0,
      type: PrizeType.mystery,
      probability: 0.07,
    ),
    PrizeModel(
      id: '8',
      label: '500',
      icon: Icons.stars,
      color: Colors.deepOrange.shade400,
      value: 500,
      type: PrizeType.jackpot,
      probability: 0.05,
    ),
  ];

  List<PrizeModel> get prizes => _prizes;

  Future<void> initialize() async {
    await _loadGameState();
    _checkDailyReset();
  }

  Future<void> _loadGameState() async {
    final prefs = await SharedPreferences.getInstance();

    final lastPlayDateStr = prefs.getString(_lastPlayDateKey);
    DateTime? lastPlayDate;
    if (lastPlayDateStr != null) {
      lastPlayDate = DateTime.tryParse(lastPlayDateStr);
    }

    _gameState = GameState(
      coins: prefs.getInt(_coinsKey) ?? 0,
      spins: prefs.getInt(_spinsKey) ?? 5,
      level: prefs.getInt(_levelKey) ?? 1,
      multiplier: prefs.getDouble(_multiplierKey) ?? 1.0,
      dailySpins: prefs.getInt(_dailySpinsKey) ?? 5,
      lastPlayDate: lastPlayDate ?? DateTime.now(),
    );
    notifyListeners();
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setInt(_coinsKey, _gameState.coins),
      prefs.setInt(_spinsKey, _gameState.spins),
      prefs.setInt(_levelKey, _gameState.level),
      prefs.setDouble(_multiplierKey, _gameState.multiplier),
      prefs.setInt(_dailySpinsKey, _gameState.dailySpins),
      prefs.setString(
          _lastPlayDateKey, _gameState.lastPlayDate!.toIso8601String()),
    ]);
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    final lastPlay = _gameState.lastPlayDate;

    if (now.day != lastPlay!.day ||
        now.month != lastPlay.month ||
        now.year != lastPlay.year) {
      _gameState = _gameState.copyWith(
        spins: 5,
        dailySpins: 5,
        lastPlayDate: now,
      );
      _saveGameState();
      notifyListeners();
    }
  }

  Future<PrizeModel> spin() async {
    if (_isSpinning || _gameState.spins <= 0) {
      throw Exception('Cannot spin');
    }

    _isSpinning = true;
    notifyListeners();

    // Simula tempo de spin
    await Future.delayed(const Duration(milliseconds: 500));

    // Seleciona prêmio baseado em probabilidade
    final selectedPrize = _selectPrizeByProbability();
    _lastPrize = selectedPrize;

    // Aplica o prêmio
    await _applyPrize(selectedPrize);

    // Atualiza spins
    _gameState = _gameState.copyWith(spins: _gameState.spins - 1);

    // Atualiza multiplicador
    _updateMultiplier();

    await _saveGameState();

    _isSpinning = false;
    notifyListeners();

    return selectedPrize;
  }

  PrizeModel _selectPrizeByProbability() {
    final random = Random();
    double totalProbability =
        _prizes.fold(0.0, (sum, prize) => sum + prize.probability);
    double randomValue = random.nextDouble() * totalProbability;

    double currentSum = 0.0;
    for (final prize in _prizes) {
      currentSum += prize.probability;
      if (randomValue <= currentSum) {
        return prize;
      }
    }

    return _prizes.first; // Fallback
  }

  Future<void> _applyPrize(PrizeModel prize) async {
    switch (prize.type) {
      case PrizeType.coins:
        final amount = (prize.value * _gameState.multiplier).round();
        _gameState = _gameState.copyWith(coins: _gameState.coins + amount);
        break;
      case PrizeType.gems:
        // Implementar sistema de gemas
        break;
      case PrizeType.spins:
        _gameState = _gameState.copyWith(spins: _gameState.spins + prize.value);
        break;
      case PrizeType.mystery:
        // Prêmio aleatório
        final bonusCoins = Random().nextInt(100) + 50;
        _gameState = _gameState.copyWith(coins: _gameState.coins + bonusCoins);
        break;
      case PrizeType.jackpot:
        final jackpotAmount =
            (prize.value * (_gameState.multiplier + 1.0)).round();
        _gameState =
            _gameState.copyWith(coins: _gameState.coins + jackpotAmount);
        break;
    }
  }

  void _updateMultiplier() {
    final newMultiplier = (_gameState.multiplier + 0.1).clamp(1.0, 3.0);
    _gameState = _gameState.copyWith(multiplier: newMultiplier);
  }

  Future<void> resetDailySpins() async {
    _gameState = _gameState.copyWith(spins: 5, multiplier: 1.0);
    await _saveGameState();
    notifyListeners();
  }
}

// ==== Interface Principal ====
class LuckyWheelGame extends StatefulWidget {
  final Function(int) onGameComplete;

  const LuckyWheelGame({super.key, required this.onGameComplete});

  @override
  State<LuckyWheelGame> createState() => _LuckyWheelGameState();
}

class _LuckyWheelGameState extends State<LuckyWheelGame>
    with TickerProviderStateMixin {
  late LuckyWheelController _controller;
  late AnimationController _wheelAnimationController;
  late AnimationController _prizeAnimationController;
  late AnimationController _buttonAnimationController;

  late Animation<double> _wheelRotation;
  late Animation<double> _prizeScale;
  late Animation<double> _buttonScale;

  late ConfettiController _confettiController;

  double _currentRotation = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = LuckyWheelController();
    _controller.initialize();
    _controller.addListener(_onGameStateChanged);

    _setupAnimations();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  void _setupAnimations() {
    _wheelAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _prizeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _wheelRotation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _wheelAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _prizeScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _prizeAnimationController,
      curve: Curves.elasticOut,
    ));

    _buttonScale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _onGameStateChanged() {
    setState(() {});
  }

  Future<void> _spinWheel() async {
    if (_controller.isSpinning || _controller.gameState.spins <= 0) return;

    HapticFeedback.mediumImpact();

    // Animação do botão
    await _buttonAnimationController.forward();
    _buttonAnimationController.reverse();

    // Calcula rotação final
    final random = Random();
    final spins = 5 + random.nextInt(3); // 5-7 voltas completas
    final finalAngle = (spins * 2 * pi) + (random.nextDouble() * 2 * pi);

    _wheelRotation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation + finalAngle,
    ).animate(CurvedAnimation(
      parent: _wheelAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _wheelAnimationController.reset();
    _wheelAnimationController.forward().then((_) async {
      _currentRotation = _wheelRotation.value % (2 * pi);

      try {
        final prize = await _controller.spin();
        await _showPrizeAnimation(prize);
        widget.onGameComplete(prize.type == PrizeType.coins ? prize.value : 0);
      } catch (e) {
        _showNoSpinsDialog();
      }
    });
  }

  Future<void> _showPrizeAnimation(PrizeModel prize) async {
    HapticFeedback.heavyImpact();

    if (prize.type == PrizeType.jackpot || prize.type == PrizeType.mystery) {
      _confettiController.play();
    }

    await _prizeAnimationController.forward();
    await Future.delayed(const Duration(seconds: 2));
    _prizeAnimationController.reverse();
  }

  void _showNoSpinsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 12),
            Text('Sem Giros!',
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ],
        ),
        content: const Text(
          'Você usou todos os seus giros diários. Volte amanhã para mais!',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: Colors.amber, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildStatsBar(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildWheelContainer(),
                    const SizedBox(height: 40),
                    _buildPrizeDisplay(),
                    const SizedBox(height: 40),
                    _buildSpinButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Roleta da Sorte',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _controller.resetDailySpins,
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.withOpacity(0.3),
            Colors.blue.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.monetization_on,
            label: 'Moedas',
            value: _controller.gameState.coins.toString(),
            color: Colors.amber,
          ),
          _buildStatItem(
            icon: Icons.casino,
            label: 'Giros',
            value: _controller.gameState.spins.toString(),
            color: Colors.cyan,
          ),
          _buildStatItem(
            icon: Icons.trending_up,
            label: 'Mult.',
            value: '${_controller.gameState.multiplier.toStringAsFixed(1)}x',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWheelContainer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Efeito de brilho de fundo
        Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.deepPurple.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Roleta
        AnimatedBuilder(
          animation: _wheelRotation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _wheelRotation.value,
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: WheelPainter(_controller.prizes),
                ),
              ),
            );
          },
        ),
        // Ponteiro
        Positioned(
          top: 0,
          child: Container(
            width: 40,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        // Confetes
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 50,
          colors: const [Colors.amber, Colors.cyan, Colors.pink, Colors.purple],
        ),
      ],
    );
  }

  Widget _buildPrizeDisplay() {
    if (_controller.lastPrize == null) {
      return const SizedBox(height: 60);
    }

    return AnimatedBuilder(
      animation: _prizeScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _prizeScale.value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _controller.lastPrize!.color.withOpacity(0.3),
                  _controller.lastPrize!.color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _controller.lastPrize!.color),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _controller.lastPrize!.icon,
                  color: _controller.lastPrize!.color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _getPrizeText(_controller.lastPrize!),
                  style: TextStyle(
                    color: _controller.lastPrize!.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getPrizeText(PrizeModel prize) {
    switch (prize.type) {
      case PrizeType.coins:
        final amount = (prize.value * _controller.gameState.multiplier).round();
        return '+$amount Moedas!';
      case PrizeType.gems:
        return '+${prize.value} Gemas!';
      case PrizeType.spins:
        return '+${prize.value} Giros!';
      case PrizeType.mystery:
        return 'Prêmio Surpresa!';
      case PrizeType.jackpot:
        return 'JACKPOT!';
    }
  }

  Widget _buildSpinButton() {
    final canSpin = !_controller.isSpinning && _controller.gameState.spins > 0;

    return AnimatedBuilder(
      animation: _buttonScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _buttonScale.value,
          child: GestureDetector(
            onTapDown:
                canSpin ? (_) => _buttonAnimationController.forward() : null,
            onTapUp: canSpin ? (_) => _spinWheel() : null,
            onTapCancel: () => _buttonAnimationController.reverse(),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: canSpin
                      ? [Colors.amber, Colors.orange]
                      : [Colors.grey.shade600, Colors.grey.shade800],
                ),
                boxShadow: [
                  BoxShadow(
                    color: canSpin
                        ? Colors.amber.withOpacity(0.5)
                        : Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _controller.isSpinning ? Icons.hourglass_empty : Icons.casino,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onGameStateChanged);
    _controller.dispose();
    _wheelAnimationController.dispose();
    _prizeAnimationController.dispose();
    _buttonAnimationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}

// ==== Pintor da Roleta ====
class WheelPainter extends CustomPainter {
  final List<PrizeModel> prizes;

  WheelPainter(this.prizes);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final anglePerSegment = 2 * pi / prizes.length;

    for (int i = 0; i < prizes.length; i++) {
      final prize = prizes[i];
      final startAngle = i * anglePerSegment - pi / 2;

      // Desenha o segmento
      final paint = Paint()
        ..color = prize.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        anglePerSegment,
        true,
        paint,
      );

      // Desenha a borda
      final borderPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        anglePerSegment,
        true,
        borderPaint,
      );

      // Desenha o texto/ícone
      _drawSegmentContent(
          canvas, center, radius, startAngle, anglePerSegment, prize);
    }

    // Círculo central
    canvas.drawCircle(
      center,
      30,
      Paint()
        ..color = const Color(0xFF1E1E2E)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawSegmentContent(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double anglePerSegment,
    PrizeModel prize,
  ) {
    final textAngle = startAngle + anglePerSegment / 2;
    final textRadius = radius * 0.7;

    final textPosition = Offset(
      center.dx + cos(textAngle) * textRadius,
      center.dy + sin(textAngle) * textRadius,
    );

    canvas.save();
    canvas.translate(textPosition.dx, textPosition.dy);
    canvas.rotate(textAngle + pi / 2);

    final textPainter = TextPainter(
      text: TextSpan(
        text: prize.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 2,
              color: Colors.black54,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
