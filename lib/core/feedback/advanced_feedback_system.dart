// lib/core/feedback/advanced_feedback_system.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum FeedbackType {
  success,
  warning,
  error,
  info,
  petHappy,
  petSad,
  levelUp,
  achievement,
  coins,
  gems
}

class AdvancedFeedbackSystem {
  static OverlayEntry? _currentOverlay;

  // 🎉 Feedback com overlay animado
  static void showAnimatedFeedback({
    required BuildContext context,
    required FeedbackType type,
    required String message,
    String? subtitle,
    int? value,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Remover overlay anterior se existir
    _currentOverlay?.remove();

    // Haptic feedback baseado no tipo
    _triggerHapticFeedback(type);

    final overlay = Overlay.of(context);

    _currentOverlay = OverlayEntry(
      builder: (context) => _AnimatedFeedbackWidget(
        type: type,
        message: message,
        subtitle: subtitle,
        value: value,
        onComplete: () {
          _currentOverlay?.remove();
          _currentOverlay = null;
        },
      ),
    );

    overlay.insert(_currentOverlay!);

    // Auto remove após duration
    Future.delayed(duration, () {
      _currentOverlay?.remove();
      _currentOverlay = null;
    });
  }

  // 💫 Toast personalizado com tema do app
  static void showCustomToast({
    required BuildContext context,
    required String message,
    FeedbackType type = FeedbackType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => _CustomToastWidget(
        message: message,
        type: type,
        onComplete: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () => overlayEntry.remove());
  }

  // 🎊 Celebração épica para conquistas
  static void showEpicCelebration({
    required BuildContext context,
    required String achievement,
    String? description,
    Color? color,
  }) {
    HapticFeedback.mediumImpact();

    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => _EpicCelebrationWidget(
        achievement: achievement,
        description: description,
        color: color ?? const Color(0xFFFFD93D),
        onComplete: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  static void _triggerHapticFeedback(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
      case FeedbackType.petHappy:
      case FeedbackType.levelUp:
      case FeedbackType.achievement:
        HapticFeedback.mediumImpact();
        break;
      case FeedbackType.error:
      case FeedbackType.petSad:
        HapticFeedback.heavyImpact();
        break;
      case FeedbackType.coins:
      case FeedbackType.gems:
        HapticFeedback.lightImpact();
        break;
      default:
        HapticFeedback.selectionClick();
    }
  }
}

class _AnimatedFeedbackWidget extends StatefulWidget {
  final FeedbackType type;
  final String message;
  final String? subtitle;
  final int? value;
  final VoidCallback onComplete;

  const _AnimatedFeedbackWidget({
    required this.type,
    required this.message,
    this.subtitle,
    this.value,
    required this.onComplete,
  });

  @override
  State<_AnimatedFeedbackWidget> createState() =>
      _AnimatedFeedbackWidgetState();
}

class _AnimatedFeedbackWidgetState extends State<_AnimatedFeedbackWidget> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2500), widget.onComplete);
  }

  Color get _typeColor {
    switch (widget.type) {
      case FeedbackType.success:
      case FeedbackType.petHappy:
        return const Color(0xFF4ECDC4);
      case FeedbackType.warning:
        return const Color(0xFFFF9500);
      case FeedbackType.error:
      case FeedbackType.petSad:
        return const Color(0xFFFF4757);
      case FeedbackType.info:
        return const Color(0xFF5D9CEC);
      case FeedbackType.levelUp:
        return const Color(0xFFFFD93D);
      case FeedbackType.achievement:
        return const Color(0xFFFF6B9D);
      case FeedbackType.coins:
        return const Color(0xFFFFA500);
      case FeedbackType.gems:
        return const Color(0xFF00CED1);
    }
  }

  IconData get _typeIcon {
    switch (widget.type) {
      case FeedbackType.success:
        return Icons.check_circle;
      case FeedbackType.warning:
        return Icons.warning_amber;
      case FeedbackType.error:
        return Icons.error;
      case FeedbackType.info:
        return Icons.info;
      case FeedbackType.petHappy:
        return Icons.sentiment_very_satisfied;
      case FeedbackType.petSad:
        return Icons.sentiment_very_dissatisfied;
      case FeedbackType.levelUp:
        return Icons.emoji_events;
      case FeedbackType.achievement:
        return Icons.star;
      case FeedbackType.coins:
        return Icons.monetization_on;
      case FeedbackType.gems:
        return Icons.diamond;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.1,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                _typeColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _typeColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _typeColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_typeColor, _typeColor.withOpacity(0.8)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _typeIcon,
                  color: Colors.white,
                  size: 24,
                ),
              )
                  .animate()
                  .scale(begin: const Offset(0.5, 0.5), duration: 300.ms)
                  .then()
                  .shimmer(duration: 800.ms),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ),
                        if (widget.value != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _typeColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+${widget.value}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _typeColor,
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 200.ms)
                              .scale(begin: const Offset(0.8, 0.8)),
                      ],
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .slideY(begin: -1, end: 0, duration: 400.ms, curve: Curves.elasticOut)
          .fadeIn()
          .then(delay: 2000.ms)
          .slideY(begin: 0, end: -1, duration: 300.ms)
          .fadeOut(),
    );
  }
}

class _CustomToastWidget extends StatelessWidget {
  final String message;
  final FeedbackType type;
  final VoidCallback onComplete;

  const _CustomToastWidget({
    required this.message,
    required this.type,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF2D3748).withOpacity(0.9),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 200.ms)
          .slideY(begin: 1, end: 0)
          .then(delay: 1600.ms)
          .fadeOut(duration: 200.ms)
          .callback(
            callback: (value) => onComplete,
          ),
    );
  }
}

class _EpicCelebrationWidget extends StatefulWidget {
  final String achievement;
  final String? description;
  final Color color;
  final VoidCallback onComplete;

  const _EpicCelebrationWidget({
    required this.achievement,
    this.description,
    required this.color,
    required this.onComplete,
  });

  @override
  State<_EpicCelebrationWidget> createState() => _EpicCelebrationWidgetState();
}

class _EpicCelebrationWidgetState extends State<_EpicCelebrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _confettiController.forward();

    Future.delayed(const Duration(seconds: 4), widget.onComplete);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Stack(
          children: [
            // Confetti particles
            ...List.generate(20, (index) {
              return Positioned(
                top: 100 + (index * 30),
                left: 20 + (index * 15),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: [
                      widget.color,
                      Colors.pink,
                      Colors.blue,
                      Colors.green,
                    ][index % 4],
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(controller: _confettiController)
                    .moveY(begin: 0, end: MediaQuery.of(context).size.height)
                    .moveX(begin: 0, end: (index.isEven ? 50 : -50))
                    .fadeOut(begin: 1, delay: 300.ms),
              );
            }),

            // Main achievement card
            Center(
              child: Container(
                margin: const EdgeInsets.all(40),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      widget.color.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 80,
                      color: widget.color,
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0, 0),
                          end: const Offset(1.2, 1.2),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        )
                        .then()
                        .scale(
                          begin: const Offset(1.2, 1.2),
                          end: const Offset(1, 1),
                          duration: 300.ms,
                        ),
                    const SizedBox(height: 20),
                    Text(
                      'CONQUISTA!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: widget.color,
                        letterSpacing: 2,
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 20, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      widget.achievement,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3748),
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 20, end: 0),
                    if (widget.description != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.description!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 800.ms)
                          .slideY(begin: 20, end: 0),
                    ],
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: widget.onComplete,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.color,
                              widget.color.withOpacity(0.8)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Text(
                          'Continuar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 1000.ms)
                        .scale(begin: const Offset(0.8, 0.8)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
