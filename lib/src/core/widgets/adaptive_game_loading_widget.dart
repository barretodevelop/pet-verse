// lib/src/core/widgets/adaptive_game_loading_widget.dart
// NOVA INCLUSÃO: Widget de loading animado adaptativo para substituir CircularProgressIndicator
// Import statement at the top
import 'dart:math' as math;

import 'package:flutter/material.dart';

enum LoadingType {
  circular,
  paws,
  hearts,
  dots,
  bones,
}

class AdaptiveGameLoadingWidget extends StatefulWidget {
  final LoadingType type;
  final double size;
  final Color? color;
  final String? message;
  final bool showMessage;

  const AdaptiveGameLoadingWidget({
    super.key,
    this.type = LoadingType.circular,
    this.size = 40.0,
    this.color,
    this.message,
    this.showMessage = false,
  });

  @override
  State<AdaptiveGameLoadingWidget> createState() =>
      _AdaptiveGameLoadingWidgetState();
}

class _AdaptiveGameLoadingWidgetState extends State<AdaptiveGameLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = widget.color ?? colorScheme.primary;

    Widget loadingWidget;

    switch (widget.type) {
      case LoadingType.circular:
        loadingWidget = _buildCircularLoader(effectiveColor);
        break;
      case LoadingType.paws:
        loadingWidget = _buildPawsLoader(effectiveColor);
        break;
      case LoadingType.hearts:
        loadingWidget = _buildHeartsLoader(effectiveColor);
        break;
      case LoadingType.dots:
        loadingWidget = _buildDotsLoader(effectiveColor);
        break;
      case LoadingType.bones:
        loadingWidget = _buildBonesLoader(effectiveColor);
        break;
    }

    if (widget.showMessage && widget.message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingWidget,
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return loadingWidget;
  }

  Widget _buildCircularLoader(Color color) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) => Transform.rotate(
        angle: _rotationAnimation.value * 2 * 3.14159,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                color.withOpacity(0.1),
                color,
                color.withOpacity(0.1),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPawsLoader(Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            children: List.generate(4, (index) {
              final angle = (index * 90.0) + (_controller.value * 360);
              final radians = angle * (3.14159 / 180);
              final radius = widget.size * 0.3;

              return Positioned(
                left: (widget.size / 2) + (radius * cos(radians)) - 8,
                top: (widget.size / 2) + (radius * sin(radians)) - 8,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _pulseAnimation.value *
                        (1.0 - (index * 0.1)), // Stagger effect
                    child: Icon(
                      Icons.pets,
                      size: 16,
                      color: color.withOpacity(
                        0.3 +
                            (0.7 *
                                (sin(_controller.value * 2 * 3.14159 + index) +
                                    1) /
                                2),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildHeartsLoader(Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            children: List.generate(3, (index) {
              final scale =
                  0.5 + (0.5 * sin(_controller.value * 2 * 3.14159 + index));
              final opacity =
                  0.3 + (0.7 * sin(_controller.value * 2 * 3.14159 + index));

              return Positioned.fill(
                child: Transform.scale(
                  scale: scale,
                  child: Icon(
                    Icons.favorite,
                    size: widget.size * 0.6,
                    color: color.withOpacity(opacity),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildDotsLoader(Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final animationValue = (_controller.value + delay) % 1.0;
            final scale = 0.5 + (0.5 * sin(animationValue * 2 * 3.14159));

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size * 0.2,
                  height: widget.size * 0.2,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildBonesLoader(Color color) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) => Transform.rotate(
        angle: _rotationAnimation.value * 2 * 3.14159,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) => Transform.scale(
            scale: _pulseAnimation.value,
            child: Icon(
              Icons.sports_esports, // Using as bone placeholder
              size: widget.size,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

// Helper functions
double cos(double angle) => math.cos(angle * math.pi / 180);
double sin(double angle) => math.sin(angle * math.pi / 180);
