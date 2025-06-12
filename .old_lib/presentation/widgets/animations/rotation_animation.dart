// File: lib/presentation/widgets/animations/rotation_animation.dart

import 'package:flutter/material.dart';

/// Rotation animation widget
class RotationAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double beginAngle;
  final double endAngle;
  final Curve curve;
  final bool repeat;
  final bool autoStart;

  const RotationAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.beginAngle = 0.0,
    this.endAngle = 1.0, // 1.0 = 360 degrees
    this.curve = Curves.linear,
    this.repeat = true,
    this.autoStart = true,
  });

  @override
  State<RotationAnimation> createState() => _RotationAnimationState();
}

class _RotationAnimationState extends State<RotationAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: widget.beginAngle,
      end: widget.endAngle,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.autoStart) {
      if (widget.repeat) {
        _controller.repeat();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void didUpdateWidget(RotationAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.autoStart != widget.autoStart) {
      if (widget.autoStart) {
        if (widget.repeat) {
          _controller.repeat();
        } else {
          _controller.forward();
        }
      } else {
        _controller.stop();
      }
    }
  }

  void startRotation() {
    if (widget.repeat) {
      _controller.repeat();
    } else {
      _controller.forward();
    }
  }

  void stopRotation() {
    _controller.stop();
  }

  void resetRotation() {
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
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * 3.14159, // Convert to radians
          child: widget.child,
        );
      },
    );
  }
}
