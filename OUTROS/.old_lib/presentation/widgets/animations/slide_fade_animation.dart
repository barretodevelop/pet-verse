// File: lib/presentation/widgets/animations/slide_fade_animation.dart

import 'package:flutter/material.dart';

/// Combined slide and fade animation widget
class SlideFadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;
  final Offset endOffset;
  final double beginOpacity;
  final double endOpacity;
  final Curve curve;
  final bool autoStart;

  const SlideFadeAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.beginOffset = const Offset(0, 0.1),
    this.endOffset = Offset.zero,
    this.beginOpacity = 0.0,
    this.endOpacity = 1.0,
    this.curve = Curves.easeOutCubic,
    this.autoStart = true,
  });

  @override
  State<SlideFadeAnimation> createState() => _SlideFadeAnimationState();
}

class _SlideFadeAnimationState extends State<SlideFadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset,
      end: widget.endOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _fadeAnimation = Tween<double>(
      begin: widget.beginOpacity,
      end: widget.endOpacity,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.autoStart) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(SlideFadeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  void startAnimation() {
    _controller.forward();
  }

  void reverseAnimation() {
    _controller.reverse();
  }

  void resetAnimation() {
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}
