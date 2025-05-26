import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FloatingEmoji extends StatelessWidget {
  final String emoji;
  final Offset position;

  const FloatingEmoji({
    super.key,
    required this.emoji,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 20,
      top: position.dy - 20,
      child: IgnorePointer(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 40),
        )
            .animate()
            .fadeIn(duration: 200.ms)
            .moveY(
                begin: 0, end: -100, duration: 2.seconds, curve: Curves.easeOut)
            .fadeOut(begin: 1, delay: 1.5.seconds, duration: 500.ms),
      ),
    );
  }
}
