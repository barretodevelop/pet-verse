// File: lib/presentation/widgets/enhanced/enhanced_gaming_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/core/config/enhanced_theme_config.dart';

/// Gaming-style stat bar with animated progress
class GameStatBar extends StatefulWidget {
  final String label;
  final int currentValue;
  final int maxValue;
  final Color color;
  final IconData icon;
  final bool showPercentage;
  final Duration animationDuration;

  const GameStatBar({
    super.key,
    required this.label,
    required this.currentValue,
    required this.maxValue,
    required this.color,
    required this.icon,
    this.showPercentage = true,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<GameStatBar> createState() => _GameStatBarState();
}

class _GameStatBarState extends State<GameStatBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _updateProgress();
    _controller.forward();
  }

  @override
  void didUpdateWidget(GameStatBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentValue != widget.currentValue || oldWidget.maxValue != widget.maxValue) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    final progress = widget.currentValue / widget.maxValue;
    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value ?? 0.0,
      end: progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Row
        Row(
          children: [
            Icon(widget.icon, color: widget.color, size: EnhancedThemeConfig.iconMedium),
            const SizedBox(width: EnhancedThemeConfig.spacing8),
            Expanded(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            Text(
              widget.showPercentage
                  ? '${(widget.currentValue / widget.maxValue * 100).round()}%'
                  : '${widget.currentValue}/${widget.maxValue}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.color,
                fontSize: EnhancedThemeConfig.fontSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: EnhancedThemeConfig.spacing6),

        // Progress Bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(EnhancedThemeConfig.radiusSmall),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color,
                        widget.color.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(EnhancedThemeConfig.radiusSmall),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Gaming-style currency display with icon and amount
class CurrencyDisplay extends StatelessWidget {
  final String label;
  final int amount;
  final IconData icon;
  final Color color;
  final bool compact;
  final VoidCallback? onTap;

  const CurrencyDisplay({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? EnhancedThemeConfig.spacing8 : EnhancedThemeConfig.spacing12,
        vertical: compact ? EnhancedThemeConfig.spacing4 : EnhancedThemeConfig.spacing8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(
          compact ? EnhancedThemeConfig.radiusMedium : EnhancedThemeConfig.radiusLarge,
        ),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: compact ? EnhancedThemeConfig.iconSmall : EnhancedThemeConfig.iconMedium,
          ),
          SizedBox(width: compact ? EnhancedThemeConfig.spacing4 : EnhancedThemeConfig.spacing6),
          if (!compact) ...[
            Text(
              label,
              style: TextStyle(
                fontSize: EnhancedThemeConfig.fontSmall,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: EnhancedThemeConfig.spacing4),
          ],
          Text(
            _formatAmount(amount),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: compact ? EnhancedThemeConfig.fontSmall : EnhancedThemeConfig.fontMedium,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap!();
        },
        child: content,
      );
    }

    return content;
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }
}

/// Gaming-style achievement badge
class AchievementBadge extends StatelessWidget {
  final String title;
  final String emoji;
  final Color color;
  final bool unlocked;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.title,
    required this.emoji,
    required this.color,
    this.unlocked = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: EnhancedThemeConfig.spacing8,
          vertical: EnhancedThemeConfig.spacing6,
        ),
        decoration: BoxDecoration(
          gradient: unlocked
              ? LinearGradient(
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                )
              : null,
          color: unlocked ? null : EnhancedThemeConfig.neutralColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(EnhancedThemeConfig.radiusMedium),
          border: Border.all(
            color: unlocked
                ? color.withOpacity(0.3)
                : EnhancedThemeConfig.neutralColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              unlocked ? emoji : '🔒',
              style: TextStyle(
                fontSize: EnhancedThemeConfig.fontSmall,
                // grayscale: unlocked ? 0 : 1,
              ),
            ),
            const SizedBox(width: EnhancedThemeConfig.spacing4),
            Text(
              title,
              style: TextStyle(
                fontSize: EnhancedThemeConfig.fontXSmall,
                fontWeight: FontWeight.w600,
                color: unlocked ? null : EnhancedThemeConfig.neutralColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gaming-style action button with gradient and effects
class GameActionButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool loading;
  final String? subtitle;
  final double? progress; // 0.0 to 1.0 for cooldown

  const GameActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.onPressed,
    this.enabled = true,
    this.loading = false,
    this.subtitle,
    this.progress,
  });

  @override
  State<GameActionButton> createState() => _GameActionButtonState();
}

class _GameActionButtonState extends State<GameActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !widget.enabled || widget.loading;
    final hasCooldown = widget.progress != null && widget.progress! < 1.0;

    return GestureDetector(
      onTapDown: isDisabled
          ? null
          : (_) {
              HapticFeedback.selectionClick();
              _controller.forward();
            },
      onTapUp: isDisabled
          ? null
          : (_) {
              _controller.reverse();
              widget.onPressed?.call();
            },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(EnhancedThemeConfig.spacing16),
              decoration: BoxDecoration(
                gradient: isDisabled
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color.withOpacity(0.2),
                          widget.color.withOpacity(0.1),
                        ],
                      ),
                color: isDisabled ? EnhancedThemeConfig.neutralColor.withOpacity(0.1) : null,
                borderRadius: BorderRadius.circular(EnhancedThemeConfig.radiusLarge),
                border: Border.all(
                  color: isDisabled
                      ? EnhancedThemeConfig.neutralColor.withOpacity(0.3)
                      : widget.color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Cooldown overlay
                  if (hasCooldown)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(EnhancedThemeConfig.radiusLarge),
                        ),
                      ),
                    ),

                  // Content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.loading)
                        SizedBox(
                          width: EnhancedThemeConfig.iconLarge,
                          height: EnhancedThemeConfig.iconLarge,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                          ),
                        )
                      else
                        Icon(
                          widget.icon,
                          color: isDisabled ? EnhancedThemeConfig.neutralColor : widget.color,
                          size: EnhancedThemeConfig.iconLarge,
                        ),
                      const SizedBox(height: EnhancedThemeConfig.spacing8),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: EnhancedThemeConfig.fontMedium,
                          color: isDisabled ? EnhancedThemeConfig.neutralColor : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: EnhancedThemeConfig.spacing2),
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            fontSize: EnhancedThemeConfig.fontXSmall,
                            color: isDisabled
                                ? EnhancedThemeConfig.neutralColor
                                : EnhancedThemeConfig.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      // Cooldown progress
                      if (hasCooldown) ...[
                        const SizedBox(height: EnhancedThemeConfig.spacing8),
                        LinearProgressIndicator(
                          value: widget.progress,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                          minHeight: 3,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Gaming-style notification badge
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color color;
  final bool showZero;

  const NotificationBadge({
    super.key,
    required this.child,
    required this.count,
    this.color = EnhancedThemeConfig.errorColor,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0 || showZero)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(EnhancedThemeConfig.spacing4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(EnhancedThemeConfig.radiusRound),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 0,
                    spreadRadius: 1,
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: EnhancedThemeConfig.fontXSmall,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

/// Gaming-style level progress indicator
class LevelProgressIndicator extends StatefulWidget {
  final int currentLevel;
  final int currentXP;
  final int xpToNextLevel;
  final Color color;

  const LevelProgressIndicator({
    super.key,
    required this.currentLevel,
    required this.currentXP,
    required this.xpToNextLevel,
    this.color = EnhancedThemeConfig.xpColor,
  });

  @override
  State<LevelProgressIndicator> createState() => _LevelProgressIndicatorState();
}

class _LevelProgressIndicatorState extends State<LevelProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _updateProgress();
    _controller.forward();
  }

  @override
  void didUpdateWidget(LevelProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentXP != widget.currentXP ||
        oldWidget.xpToNextLevel != widget.xpToNextLevel) {
      _updateProgress();
    }
  }

  void _updateProgress() {
    final progress = widget.currentXP / widget.xpToNextLevel;
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(EnhancedThemeConfig.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.color.withOpacity(0.1),
            widget.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(EnhancedThemeConfig.radiusLarge),
        border: Border.all(
          color: widget.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.color, widget.color.withOpacity(0.8)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.currentLevel.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: EnhancedThemeConfig.fontLarge,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: EnhancedThemeConfig.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${widget.currentLevel}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: EnhancedThemeConfig.spacing4),
                    Text(
                      '${widget.currentXP} / ${widget.xpToNextLevel} XP',
                      style: TextStyle(
                        color: EnhancedThemeConfig.textSecondary,
                        fontSize: EnhancedThemeConfig.fontSmall,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'LEVEL ${widget.currentLevel + 1}',
                style: TextStyle(
                  color: widget.color,
                  fontSize: EnhancedThemeConfig.fontSmall,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: EnhancedThemeConfig.spacing12),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: widget.color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                minHeight: 8,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Gaming-style mood indicator
class MoodIndicator extends StatelessWidget {
  final String mood;
  final String emoji;
  final Color color;
  final String description;

  const MoodIndicator({
    super.key,
    required this.mood,
    required this.emoji,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(EnhancedThemeConfig.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(EnhancedThemeConfig.radiusLarge),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: EnhancedThemeConfig.fontXXLarge),
              ),
            ),
          ),
          const SizedBox(width: EnhancedThemeConfig.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Mood',
                  style: TextStyle(
                    fontSize: EnhancedThemeConfig.fontSmall,
                    color: EnhancedThemeConfig.textSecondary,
                  ),
                ),
                Text(
                  mood,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: EnhancedThemeConfig.fontSmall,
                    color: EnhancedThemeConfig.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
