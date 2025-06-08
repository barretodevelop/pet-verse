// File: lib/presentation/widgets/animations/shake_animation.dart

import 'package:flutter/material.dart';

/// Shake animation widget for error feedback
class ShakeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;
  final int shakeCount;
  final GlobalKey<ShakeAnimationState>? shakeKey;

  const ShakeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.offset = 6.0,
    this.shakeCount = 2,
    this.shakeKey,
  });

  @override
  State<ShakeAnimation> createState() => ShakeAnimationState();
}

class ShakeAnimationState extends State<ShakeAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _createAnimation();
  }

  void _createAnimation() {
    final shakeCount = widget.shakeCount * 2; // Each shake is left-right
    final List<TweenSequenceItem<double>> sequence = [];

    for (int i = 0; i < shakeCount; i++) {
      sequence.add(
        TweenSequenceItem(
          tween: Tween(
            begin: i.isEven ? 0.0 : widget.offset,
            end: i.isEven ? widget.offset : -widget.offset,
          ),
          weight: 1,
        ),
      );
    }

    // Return to center
    if (sequence.isNotEmpty && sequence.last.tween is Tween<double>) {
      final Tween<double> lastTween = sequence.last.tween as Tween<double>;

      sequence.add(
        TweenSequenceItem(
          tween: Tween<double>(
            begin: lastTween.end,
            end: 0.0,
          ),
          weight: 1,
        ),
      );
    } else {
      // Fallback se a lista estiver vazia ou não for um Tween<double>
      sequence.add(
        TweenSequenceItem(
          tween: Tween<double>(
            begin: 1.0, // valor inicial padrão
            end: 0.0,
          ),
          weight: 1,
        ),
      );
    }

    _animation = TweenSequence<double>(sequence).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
    );
  }

  void shake() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void didUpdateWidget(ShakeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration ||
        oldWidget.offset != widget.offset ||
        oldWidget.shakeCount != widget.shakeCount) {
      _controller.duration = widget.duration;
      _createAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: widget.child,
        );
      },
    );
  }
}
