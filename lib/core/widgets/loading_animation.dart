// lib/core/widgets/loading_animation.dart
// ATUALIZADO: Sistema de animações emocionais integrado
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadingAnimation extends StatelessWidget {
  final String? message;
  final LoadingType type;
  final Color? color;

  const LoadingAnimation({
    super.key,
    this.message,
    this.type = LoadingType.general,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedIcon(context, size),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color ?? Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .slideY(begin: 10, end: 0),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedIcon(BuildContext context, Size screenSize) {
    switch (type) {
      case LoadingType.pets:
        return _buildPetLoadingAnimation(screenSize);
      case LoadingType.adoption:
        return _buildAdoptionLoadingAnimation(screenSize);
      case LoadingType.feeding:
        return _buildFeedingLoadingAnimation(screenSize);
      case LoadingType.playing:
        return _buildPlayingLoadingAnimation(screenSize);
      case LoadingType.general:
      default:
        return _buildGeneralLoadingAnimation(context, screenSize);
    }
  }

  Widget _buildPetLoadingAnimation(Size screenSize) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            const Color(0xFF4ECDC4).withOpacity(0.2),
            const Color(0xFF4ECDC4).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '🐾',
          style: TextStyle(fontSize: 40),
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(duration: 3000.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          duration: 1500.ms,
        )
        .then()
        .scale(
          begin: const Offset(1.2, 1.2),
          end: const Offset(0.8, 0.8),
          duration: 1500.ms,
        );
  }

  Widget _buildAdoptionLoadingAnimation(Size screenSize) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                const Color(0xFFFF6B9D).withOpacity(0.2),
                const Color(0xFFFF6B9D).withOpacity(0.1),
                Colors.transparent,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '❤️',
              style: TextStyle(fontSize: 40),
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.1, 1.1),
              duration: 1000.ms,
            )
            .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5)),

        // Corações flutuando
        ...List.generate(3, (index) {
          return Positioned(
            top: 20 + (index * 15.0),
            left: 30 + (index * 10.0),
            child: const Text(
              '💕',
              style: TextStyle(fontSize: 12),
            )
                .animate(
                  delay: Duration(milliseconds: index * 500),
                  onPlay: (controller) => controller.repeat(),
                )
                .fadeIn(duration: 500.ms)
                .moveY(begin: 0, end: -30)
                .then()
                .fadeOut(duration: 500.ms),
          );
        }),
      ],
    );
  }

  Widget _buildFeedingLoadingAnimation(Size screenSize) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            const Color(0xFFFF9500).withOpacity(0.2),
            const Color(0xFFFF9500).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '🍖',
          style: TextStyle(fontSize: 40),
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(end: 0.1, duration: 500.ms)
        .then()
        .rotate(end: -0.1, duration: 500.ms)
        .then()
        .rotate(end: 0, duration: 500.ms);
  }

  Widget _buildPlayingLoadingAnimation(Size screenSize) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            const Color(0xFF5D9CEC).withOpacity(0.2),
            const Color(0xFF5D9CEC).withOpacity(0.1),
            Colors.transparent,
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '🎾',
          style: TextStyle(fontSize: 40),
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .moveY(begin: 0, end: -20, duration: 600.ms)
        .then()
        .moveY(begin: -20, end: 0, duration: 600.ms);
  }

  Widget _buildGeneralLoadingAnimation(BuildContext context, Size screenSize) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1) ??
            Theme.of(context).colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.pets,
        size: 50,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shake(
          hz: 3,
          offset: const Offset(0, 10),
          duration: 1.seconds,
        )
        .then(delay: 1.seconds)
        .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1))
        .then()
        .scale(begin: const Offset(1.1, 1.1), end: const Offset(1.0, 1.0));
  }
}

enum LoadingType {
  general,
  pets,
  adoption,
  feeding,
  playing,
}

// ============ EMOTIONAL ANIMATIONS SYSTEM ============

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
          .animate(onComplete: (controller) => onTap)
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

  // 🏆 Animação de level up
  static Widget levelUpCelebration({required Widget child}) {
    return Stack(
      children: [
        child
            .animate()
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.2, 1.2),
              duration: 300.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.2, 1.2),
              end: const Offset(1.0, 1.0),
              duration: 200.ms,
            ),

        // Partículas douradas
        ...List.generate(12, (index) {
          return Positioned(
            top: 50.0,
            left: 50.0,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD93D),
                shape: BoxShape.circle,
              ),
            )
                .animate(delay: Duration(milliseconds: index * 50))
                .scale(begin: const Offset(0, 0), end: const Offset(1, 1))
                .moveY(begin: 0, end: -100)
                .moveX(begin: 0, end: (index * 20) - 120)
                .then()
                .fadeOut(),
          );
        }),
      ],
    );
  }
}

// 🎨 Widget para feedback visual de ações específicas
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
