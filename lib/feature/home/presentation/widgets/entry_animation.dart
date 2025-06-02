// lib/features/home/presentation/widgets/entry_animation.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:petverse/core/theme/bck-app_theme.dart';

// lib/features/home/presentation/widgets/entry_animation.dart
class EntryAnimation extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color color;

  const EntryAnimation({
    super.key,
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  State<EntryAnimation> createState() => _EntryAnimationState();
}

class _EntryAnimationState extends State<EntryAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated Icon
        AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _rotateAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Transform.rotate(
                angle: _rotateAnimation.value * 0.1, // Subtle rotation
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.color,
                        widget.color.withOpacity(0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 32),

        // Message
        Text(
          widget.message,
          style: AppTheme.bodyLarge.copyWith(
            color: widget.color,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: 0.3, end: 0),

        const SizedBox(height: 24),

        // Progress indicator
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            backgroundColor: widget.color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(widget.color),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .scaleX(begin: 0, end: 1),
      ],
    );
  }
}
