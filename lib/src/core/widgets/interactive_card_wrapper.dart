// lib/src/core/widgets/interactive_card_wrapper.dart
// NOVO ARQUIVO - Wrapper para adicionar micro-interações a cards

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum InteractionType {
  tap,
  longPress,
  hover,
  selection,
}

class InteractiveCardWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isEnabled;
  final Duration animationDuration;
  final Color? hoverColor;
  final Color? selectedColor;
  final double? elevation;
  final double? hoverElevation;
  final BorderRadius? borderRadius;
  final bool enableHapticFeedback;
  final InteractionType primaryInteraction;

  const InteractiveCardWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isEnabled = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.hoverColor,
    this.selectedColor,
    this.elevation,
    this.hoverElevation,
    this.borderRadius,
    this.enableHapticFeedback = true,
    this.primaryInteraction = InteractionType.tap,
  });

  @override
  State<InteractiveCardWrapper> createState() => _InteractiveCardWrapperState();
}

class _InteractiveCardWrapperState extends State<InteractiveCardWrapper>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _elevationController;
  late AnimationController _colorController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _elevationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _colorController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 2.0,
      end: widget.hoverElevation ?? 8.0,
    ).animate(CurvedAnimation(
      parent: _elevationController,
      curve: Curves.easeInOut,
    ));

    _setupColorAnimation();
  }

  void _setupColorAnimation() {
    final theme = Theme.of(context);
    final defaultHoverColor =
        widget.hoverColor ?? theme.primaryColor.withOpacity(0.05);
    final defaultSelectedColor =
        widget.selectedColor ?? theme.primaryColor.withOpacity(0.1);

    _colorAnimation = ColorTween(
      begin: widget.isSelected ? defaultSelectedColor : Colors.transparent,
      end: _isHovered
          ? defaultHoverColor
          : (widget.isSelected ? defaultSelectedColor : Colors.transparent),
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(InteractiveCardWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      _setupColorAnimation();
      _colorController.forward();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _elevationController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;

    setState(() {
      _isPressed = true;
    });

    _scaleController.forward();

    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (!mounted) return;

    setState(() {
      _isPressed = false;
    });

    _scaleController.reverse();
  }

  void _handleTap() {
    if (!widget.isEnabled) return;

    if (widget.enableHapticFeedback) {
      switch (widget.primaryInteraction) {
        case InteractionType.selection:
          HapticFeedback.selectionClick();
          break;
        case InteractionType.tap:
        default:
          HapticFeedback.lightImpact();
          break;
      }
    }

    widget.onTap?.call();
  }

  void _handleLongPress() {
    if (!widget.isEnabled) return;

    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    widget.onLongPress?.call();
  }

  void _handleHoverEnter(PointerEnterEvent event) {
    if (!widget.isEnabled) return;

    setState(() {
      _isHovered = true;
    });

    _elevationController.forward();
    _setupColorAnimation();
    _colorController.forward();
  }

  void _handleHoverExit(PointerExitEvent event) {
    setState(() {
      _isHovered = false;
    });

    _elevationController.reverse();
    _setupColorAnimation();
    _colorController.forward();
  }

  Widget _buildRippleEffect() {
    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        child: InkWell(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          onTap: widget.isEnabled ? _handleTap : null,
          onLongPress: widget.isEnabled ? _handleLongPress : null,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          splashColor: (widget.hoverColor ?? Theme.of(context).primaryColor)
              .withOpacity(0.1),
          highlightColor: (widget.hoverColor ?? Theme.of(context).primaryColor)
              .withOpacity(0.05),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _handleHoverEnter,
      onExit: _handleHoverExit,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _elevationAnimation,
          _colorAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: _elevationAnimation.value,
                    offset: Offset(0, _elevationAnimation.value / 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background color overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(12),
                      color: _colorAnimation.value,
                    ),
                    child: widget.child,
                  ),

                  // Ripple effect
                  _buildRippleEffect(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
