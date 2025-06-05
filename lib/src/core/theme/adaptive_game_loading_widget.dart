// lib/src/core/widgets/adaptive_game_loading_widget.dart
// NOVO - Widget de loading animado game-like

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:petverse/src/core/theme/adaptive_game_colors.dart';

class AdaptiveGameLoadingWidget extends StatefulWidget {
  final double size;
  final String? message;
  final Color? color;
  final bool showMessage;
  final LoadingStyle style;

  const AdaptiveGameLoadingWidget({
    super.key,
    this.size = 40.0,
    this.message,
    this.color,
    this.showMessage = true,
    this.style = LoadingStyle.circular,
  });

  /// Loading pequeno para botões
  const AdaptiveGameLoadingWidget.small({
    super.key,
    this.size = 20.0,
    this.message,
    this.color,
    this.showMessage = false,
    this.style = LoadingStyle.circular,
  });

  /// Loading médio para cards
  const AdaptiveGameLoadingWidget.medium({
    super.key,
    this.size = 32.0,
    this.message,
    this.color,
    this.showMessage = true,
    this.style = LoadingStyle.dots,
  });

  /// Loading grande para telas completas
  const AdaptiveGameLoadingWidget.large({
    super.key,
    this.size = 60.0,
    this.message = 'Carregando...',
    this.color,
    this.showMessage = true,
    this.style = LoadingStyle.pulse,
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
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
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
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? context.gameColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLoadingIndicator(effectiveColor),
        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    switch (widget.style) {
      case LoadingStyle.circular:
        return _buildCircularLoader(color);
      case LoadingStyle.dots:
        return _buildDotsLoader(color);
      case LoadingStyle.pulse:
        return _buildPulseLoader(color);
      case LoadingStyle.spinner:
        return _buildSpinnerLoader(color);
    }
  }

  Widget _buildCircularLoader(Color color) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        strokeWidth: widget.size * 0.1,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        backgroundColor: color.withOpacity(0.2),
      ),
    );
  }

  Widget _buildDotsLoader(Color color) {
    return SizedBox(
      width: widget.size,
      height: widget.size * 0.3,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index * 0.2;
              final value = (_controller.value + delay) % 1.0;
              final opacity =
                  (0.4 + 0.6 * (0.5 + 0.5 * math.sin(value * 2 * math.pi)))
                      .clamp(0.0, 1.0);

              return Container(
                width: widget.size * 0.15,
                height: widget.size * 0.15,
                decoration: BoxDecoration(
                  color: color.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildPulseLoader(Color color) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets,
              color: Colors.white,
              size: widget.size * 0.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpinnerLoader(Color color) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * math.pi,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              gradient: SweepGradient(
                colors: [
                  color.withOpacity(0.1),
                  color,
                  color.withOpacity(0.1),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

enum LoadingStyle {
  circular,
  dots,
  pulse,
  spinner,
}
