// lib/src/core/widgets/game_feedback_widget.dart
// NOVA INCLUSÃO: Widget para feedback visual de sucesso, erro e outros estados

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum FeedbackType {
  success,
  error,
  warning,
  info,
  loading,
}

class GameFeedbackWidget extends StatefulWidget {
  final FeedbackType type;
  final String? title;
  final String? message;
  final IconData? customIcon;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showRetryButton;
  final bool showDismissButton;
  final bool animated;
  final Duration animationDuration;

  const GameFeedbackWidget({
    super.key,
    required this.type,
    this.title,
    this.message,
    this.customIcon,
    this.onRetry,
    this.onDismiss,
    this.showRetryButton = false,
    this.showDismissButton = false,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<GameFeedbackWidget> createState() => _GameFeedbackWidgetState();
}

class _GameFeedbackWidgetState extends State<GameFeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _iconController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _iconController = AnimationController(
      duration:
          Duration(milliseconds: widget.animationDuration.inMilliseconds + 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));

    if (widget.animated) {
      _startAnimations();
    } else {
      _scaleController.value = 1.0;
      _slideController.value = 1.0;
      _iconController.value = 1.0;
    }
  }

  void _startAnimations() {
    _scaleController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _iconController.forward();
    });

    // Add haptic feedback for certain types
    if (widget.type == FeedbackType.success) {
      HapticFeedback.lightImpact();
    } else if (widget.type == FeedbackType.error) {
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (widget.type) {
      case FeedbackType.success:
        return colorScheme.primaryContainer.withOpacity(0.3);
      case FeedbackType.error:
        return colorScheme.errorContainer.withOpacity(0.3);
      case FeedbackType.warning:
        return colorScheme.tertiaryContainer.withOpacity(0.3);
      case FeedbackType.info:
        return colorScheme.surfaceContainerHighest.withOpacity(0.5);
      case FeedbackType.loading:
        return colorScheme.surfaceContainerHighest.withOpacity(0.3);
    }
  }

  Color _getBorderColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (widget.type) {
      case FeedbackType.success:
        return colorScheme.primary.withOpacity(0.5);
      case FeedbackType.error:
        return colorScheme.error.withOpacity(0.5);
      case FeedbackType.warning:
        return colorScheme.tertiary.withOpacity(0.5);
      case FeedbackType.info:
        return colorScheme.outline.withOpacity(0.5);
      case FeedbackType.loading:
        return colorScheme.primary.withOpacity(0.3);
    }
  }

  Color _getIconColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (widget.type) {
      case FeedbackType.success:
        return colorScheme.primary;
      case FeedbackType.error:
        return colorScheme.error;
      case FeedbackType.warning:
        return colorScheme.tertiary;
      case FeedbackType.info:
        return colorScheme.onSurfaceVariant;
      case FeedbackType.loading:
        return colorScheme.primary;
    }
  }

  IconData _getDefaultIcon() {
    if (widget.customIcon != null) return widget.customIcon!;

    switch (widget.type) {
      case FeedbackType.success:
        return Icons.check_circle;
      case FeedbackType.error:
        return Icons.error;
      case FeedbackType.warning:
        return Icons.warning;
      case FeedbackType.info:
        return Icons.info;
      case FeedbackType.loading:
        return Icons.hourglass_empty;
    }
  }

  String _getDefaultTitle() {
    if (widget.title != null) return widget.title!;

    switch (widget.type) {
      case FeedbackType.success:
        return 'Sucesso!';
      case FeedbackType.error:
        return 'Ops! Algo deu errado';
      case FeedbackType.warning:
        return 'Atenção';
      case FeedbackType.info:
        return 'Informação';
      case FeedbackType.loading:
        return 'Carregando...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _getBackgroundColor(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getBorderColor(context),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _getIconColor(context).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              ScaleTransition(
                scale: _iconAnimation,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getIconColor(context).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getDefaultIcon(),
                    size: 40,
                    color: _getIconColor(context),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                _getDefaultTitle(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),

              // Message
              if (widget.message != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.message!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.8),
                        height: 1.4,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Buttons
              if (widget.showRetryButton || widget.showDismissButton) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.showDismissButton) ...[
                      TextButton(
                        onPressed: widget.onDismiss,
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.onSurfaceVariant,
                        ),
                        child: const Text('Dispensar'),
                      ),
                      if (widget.showRetryButton) const SizedBox(width: 12),
                    ],
                    if (widget.showRetryButton)
                      ElevatedButton.icon(
                        onPressed: widget.onRetry,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Novamente'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getIconColor(context),
                          foregroundColor: colorScheme.surface,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Utility function to show feedback as bottom sheet
void showGameFeedback(
  BuildContext context, {
  required FeedbackType type,
  String? title,
  String? message,
  IconData? customIcon,
  VoidCallback? onRetry,
  bool showRetryButton = false,
  Duration? duration,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (context) => GameFeedbackWidget(
      type: type,
      title: title,
      message: message,
      customIcon: customIcon,
      onRetry: onRetry,
      showRetryButton: showRetryButton,
      showDismissButton: true,
      onDismiss: () => Navigator.of(context).pop(),
    ),
  );

  // Auto dismiss after duration if specified
  if (duration != null) {
    Future.delayed(duration, () {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }
}

// Utility function to show feedback as dialog
void showGameFeedbackDialog(
  BuildContext context, {
  required FeedbackType type,
  String? title,
  String? message,
  IconData? customIcon,
  VoidCallback? onRetry,
  bool showRetryButton = false,
  bool barrierDismissible = true,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: GameFeedbackWidget(
        type: type,
        title: title,
        message: message,
        customIcon: customIcon,
        onRetry: onRetry,
        showRetryButton: showRetryButton,
        showDismissButton: true,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    ),
  );
}
