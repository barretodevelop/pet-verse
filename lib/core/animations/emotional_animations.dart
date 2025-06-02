// lib/core/animations/emotional_animations.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmotionalAnimations {
  // 🐾 Animação quando pet está feliz
  static Widget petHappyBounce({required Widget child}) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: 1500.ms,
          curve: Curves.easeInOutSine,
        )
        .then()
        .shimmer(
          duration: 2000.ms,
          color: Colors.white.withOpacity(0.3),
        );
  }

  // ❤️ Animação de love quando faz uma ação positiva
  static Widget loveParticles({required Widget child}) {
    return Stack(
      children: [
        child,
        ...List.generate(5, (index) {
          return Positioned(
            top: 20.0 + (index * 15),
            right: 10.0 + (index * 8),
            child: Icon(
              Icons.favorite,
              color: Colors.pink.withOpacity(0.7),
              size: 12,
            )
                .animate(delay: Duration(milliseconds: index * 200))
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0, 0), end: const Offset(1, 1))
                .moveY(begin: 0, end: -50)
                .then()
                .fadeOut(duration: 500.ms),
          );
        }),
      ],
    );
  }

  // ✨ Animação de sucesso com confetti
  static Widget successConfetti({required Widget child}) {
    return Stack(
      children: [
        child,
        ...List.generate(8, (index) {
          final colors = [
            Colors.yellow,
            Colors.pink,
            Colors.blue,
            Colors.green,
          ];

          return Positioned(
            top: 10.0,
            left: 20.0 + (index * 40),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors[index % colors.length],
                shape: BoxShape.circle,
              ),
            )
                .animate(delay: Duration(milliseconds: index * 100))
                .scale(begin: const Offset(0, 0), end: const Offset(1, 1))
                .moveY(begin: 0, end: -80)
                .moveX(begin: 0, end: (index.isEven ? 30 : -30))
                .then()
                .fadeOut(),
          );
        }),
      ],
    );
  }

  // 🌟 Animação de entrada épica
  static Widget epicEntrance({required Widget child}) {
    return child
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.3, 0.3),
          end: const Offset(1.0, 1.0),
          curve: Curves.elasticOut,
        )
        .then(delay: 200.ms)
        .shimmer(duration: 1000.ms);
  }

  // 😴 Animação quando pet está dormindo
  static Widget sleepingBreath({required Widget child}) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.02, 1.02),
          duration: 2500.ms,
          curve: Curves.easeInOutSine,
        );
  }

  // 🎮 Animação de tap feedback melhorada
  static Widget enhancedTapFeedback({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: child
          .animate(onPlay: (controller) => onTap)
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(0.95, 0.95),
            duration: 100.ms,
          )
          .then()
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.0, 1.0),
            duration: 100.ms,
          ),
    );
  }
}

// 🎨 Widget para feedback visual de ações
class ActionFeedbackOverlay extends StatelessWidget {
  final String actionType;
  final Color color;
  final IconData icon;

  const ActionFeedbackOverlay({
    super.key,
    required this.actionType,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 40,
            color: color,
          )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.2, 1.2),
                duration: 300.ms,
              )
              .then()
              .scale(
                begin: const Offset(1.2, 1.2),
                end: const Offset(1.0, 1.0),
                duration: 200.ms,
              ),
          const SizedBox(height: 8),
          Text(
            actionType,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 10, end: 0),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.8, 0.8))
        .then(delay: 1500.ms)
        .fadeOut();
  }
}
