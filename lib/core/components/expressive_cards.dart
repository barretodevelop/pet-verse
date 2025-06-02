// lib/core/components/expressive_cards.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum CardMood { happy, playful, sleepy, hungry, excited, calm }

class ExpressivePetCard extends StatefulWidget {
  final String petName;
  final String petEmoji;
  final CardMood mood;
  final int happiness;
  final int energy;
  final int hunger;
  final VoidCallback? onTap;
  final List<String> recentActions;

  const ExpressivePetCard({
    super.key,
    required this.petName,
    required this.petEmoji,
    required this.mood,
    required this.happiness,
    required this.energy,
    required this.hunger,
    this.onTap,
    this.recentActions = const [],
  });

  @override
  State<ExpressivePetCard> createState() => _ExpressivePetCardState();
}

class _ExpressivePetCardState extends State<ExpressivePetCard>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatController.repeat(reverse: true);

    // Pulse diferente baseado no humor
    if (widget.mood == CardMood.excited) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color get _moodColor {
    switch (widget.mood) {
      case CardMood.happy:
        return const Color(0xFF4ECDC4);
      case CardMood.playful:
        return const Color(0xFFFF6B9D);
      case CardMood.sleepy:
        return const Color(0xFF9B59B6);
      case CardMood.hungry:
        return const Color(0xFFFF9500);
      case CardMood.excited:
        return const Color(0xFFFF4757);
      case CardMood.calm:
        return const Color(0xFF5D9CEC);
    }
  }

  String get _moodText {
    switch (widget.mood) {
      case CardMood.happy:
        return 'Feliz e contente! 😊';
      case CardMood.playful:
        return 'Quer brincar! 🎾';
      case CardMood.sleepy:
        return 'Está com sono... 😴';
      case CardMood.hungry:
        return 'Está com fome! 🍖';
      case CardMood.excited:
        return 'Super animado! ⚡';
      case CardMood.calm:
        return 'Relaxado e zen 🧘';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                _moodColor.withOpacity(0.05),
                _moodColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _moodColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _moodColor.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: _moodColor.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 16),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Pet Avatar com animação baseada no humor
                _buildAnimatedAvatar(),

                const SizedBox(height: 20),

                // Nome e humor
                _buildPetInfo(),

                const SizedBox(height: 20),

                // Status bars com visual melhorado
                _buildStatusBars(),

                const SizedBox(height: 16),

                // Ações recentes
                if (widget.recentActions.isNotEmpty) _buildRecentActions(),

                const SizedBox(height: 12),

                // Call to action
                _buildCallToAction(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedAvatar() {
    Widget avatar = Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            _moodColor.withOpacity(0.2),
            _moodColor.withOpacity(0.1),
            _moodColor.withOpacity(0.05),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.petEmoji,
          style: const TextStyle(fontSize: 50),
        ),
      ),
    );

    // Animações diferentes por humor
    switch (widget.mood) {
      case CardMood.excited:
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.1),
              child: avatar,
            );
          },
        );

      case CardMood.sleepy:
        return AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatController.value * 4),
              child: avatar,
            );
          },
        );

      case CardMood.playful:
        return avatar
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(end: 0.02, duration: 1000.ms)
            .then()
            .rotate(end: -0.02, duration: 1000.ms);

      default:
        return AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatController.value * 6),
              child: avatar,
            );
          },
        );
    }
  }

  Widget _buildPetInfo() {
    return Column(
      children: [
        Text(
          widget.petName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: _moodColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _moodText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _moodColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBars() {
    return Column(
      children: [
        _buildStatusBar(
            'Felicidade', widget.happiness, const Color(0xFF4ECDC4), '❤️'),
        const SizedBox(height: 12),
        _buildStatusBar('Energia', widget.energy, const Color(0xFF5D9CEC), '⚡'),
        const SizedBox(height: 12),
        _buildStatusBar(
            'Fome', 100 - widget.hunger, const Color(0xFFFF9500), '🍖'),
      ],
    );
  }

  Widget _buildStatusBar(String label, int value, Color color, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A5568),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Atividades recentes:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF718096),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          children: widget.recentActions.take(3).map((action) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: _moodColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                action,
                style: TextStyle(
                  fontSize: 10,
                  color: _moodColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCallToAction() {
    String actionText;
    IconData actionIcon;

    if (widget.happiness < 60) {
      actionText = 'Precisa de carinho';
      actionIcon = Icons.favorite;
    } else if (widget.energy < 40) {
      actionText = 'Hora de descansar';
      actionIcon = Icons.bedtime;
    } else if (widget.hunger > 70) {
      actionText = 'Está com fome';
      actionIcon = Icons.restaurant;
    } else {
      actionText = 'Toque para interagir';
      actionIcon = Icons.touch_app;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          actionIcon,
          color: _moodColor.withOpacity(0.7),
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          actionText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _moodColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
