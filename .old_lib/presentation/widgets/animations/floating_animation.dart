// File: lib/presentation/widgets/animations/floating_animation.dart

import 'package:flutter/material.dart';

/// Floating animation widget that moves up and down continuously
class FloatingAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offset;
  final Curve curve;
  final bool autoStart;

  const FloatingAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.offset = 8.0,
    this.curve = Curves.easeInOutSine,
    this.autoStart = true,
  });

  @override
  State<FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<FloatingAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: -widget.offset,
      end: widget.offset,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.autoStart) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FloatingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.autoStart != widget.autoStart) {
      if (widget.autoStart) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  void startFloating() {
    _controller.repeat(reverse: true);
  }

  void stopFloating() {
    _controller.stop();
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
          offset: Offset(0, _animation.value),
          child: widget.child,
        );
      },
    );
  }
}
