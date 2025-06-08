// File: lib/presentation/widgets/animations/bounce_animation.dart

import 'package:flutter/material.dart';

/// Bounce animation widget for interactive feedback
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double scaleFactor;
  final VoidCallback? onTap;
  final bool enableTapAnimation;

  const BounceAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 150),
    this.scaleFactor = 0.95,
    this.onTap,
    this.enableTapAnimation = true,
  });

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(BounceAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.scaleFactor != widget.scaleFactor) {
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: widget.scaleFactor,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    }
  }

  Future<void> _animateBounce() async {
    await _controller.forward();
    await _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enableTapAnimation ? (_) => _controller.forward() : null,
      onTapUp: widget.enableTapAnimation ? (_) => _controller.reverse() : null,
      onTapCancel: widget.enableTapAnimation ? () => _controller.reverse() : null,
      onTap: () {
        if (!widget.enableTapAnimation) {
          _animateBounce();
        }
        widget.onTap?.call();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}
