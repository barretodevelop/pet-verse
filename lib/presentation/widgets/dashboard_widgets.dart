// lib/presentation/widgets/dashboard_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/service/dashboard_service.dart';
import 'package:petverse/presentation/providers/dashboard_provider.dart';
import 'package:petverse/presentation/providers/theme_provider.dart';

/// Widget para exibir card de estatística animado
class AnimatedStatCard extends ConsumerStatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue;

  const AnimatedStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
  });

  @override
  ConsumerState<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends ConsumerState<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(isLightThemeProvider);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLightTheme ? Colors.white : Colors.grey[800],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.color.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.color,
                            size: 24,
                          ),
                        ),
                        if (widget.showTrend && widget.trendValue != null)
                          _buildTrendIndicator(widget.trendValue!),
                      ],
                    ),
                    const Spacer(),
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                          begin: 0,
                          end: double.tryParse(widget.value
                                  .replaceAll(RegExp(r'[^0-9.]'), '')) ??
                              0),
                      duration: const Duration(milliseconds: 1200),
                      builder: (context, value, child) {
                        return Text(
                          widget.value.contains(RegExp(r'[KM]'))
                              ? _formatNumberWithSuffix(value)
                              : value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: isLightTheme
                                ? Colors.grey[800]
                                : Colors.grey[100],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isLightTheme ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatNumberWithSuffix(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toInt().toString();
  }

  Widget _buildTrendIndicator(double trend) {
    final isPositive = trend >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '${trend.abs().toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Widget para atividade recente
class RecentActivityTile extends ConsumerWidget {
  final RecentActivity activity;
  final VoidCallback? onTap;

  const RecentActivityTile({
    super.key,
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLightTheme = ref.watch(isLightThemeProvider);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _getActivityColor(activity.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getActivityIcon(activity.type),
                color: _getActivityColor(activity.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activity.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isLightTheme ? Colors.grey[600] : Colors.grey[400],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              _formatTimeAgo(activity.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: isLightTheme ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'pet_care':
        return Icons.pets;
      case 'achievement':
        return Icons.emoji_events;
      case 'adoption':
        return Icons.favorite;
      case 'game':
        return Icons.games;
      default:
        return Icons.notifications;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'pet_care':
        return Colors.orange;
      case 'achievement':
        return Colors.amber;
      case 'adoption':
        return Colors.red;
      case 'game':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'agora';
    }
  }
}

/// Widget para dica do dia animada
class DailyTipCard extends ConsumerStatefulWidget {
  final DailyTip tip;
  final VoidCallback? onDismiss;

  const DailyTipCard({
    super.key,
    required this.tip,
    this.onDismiss,
  });

  @override
  ConsumerState<DailyTipCard> createState() => _DailyTipCardState();
}

class _DailyTipCardState extends ConsumerState<DailyTipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(isLightThemeProvider);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getTipGradient(widget.tip.category),
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _getTipColor(widget.tip.category).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTipIcon(widget.tip.category),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tip.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.tip.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.onDismiss != null)
                IconButton(
                  onPressed: widget.onDismiss,
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTipIcon(String category) {
    switch (category) {
      case 'pet_care':
        return Icons.pets;
      case 'game':
        return Icons.games;
      case 'social':
        return Icons.people;
      default:
        return Icons.lightbulb;
    }
  }

  Color _getTipColor(String category) {
    switch (category) {
      case 'pet_care':
        return Colors.purple;
      case 'game':
        return Colors.blue;
      case 'social':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  List<Color> _getTipGradient(String category) {
    switch (category) {
      case 'pet_care':
        return [Colors.purple[400]!, Colors.purple[600]!];
      case 'game':
        return [Colors.blue[400]!, Colors.blue[600]!];
      case 'social':
        return [Colors.green[400]!, Colors.green[600]!];
      default:
        return [Colors.orange[400]!, Colors.orange[600]!];
    }
  }
}

/// Widget para ação rápida sugerida
class QuickActionCard extends ConsumerWidget {
  final QuickActionSuggestion suggestion;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLightTheme = ref.watch(isLightThemeProvider);
    final color = _getActionColor(suggestion.action);
    final icon = _getActionIcon(suggestion.action);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLightTheme ? Colors.white : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              suggestion.title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getActionColor(QuickActionType type) {
    switch (type) {
      case QuickActionType.adoptPet:
        return Colors.red;
      case QuickActionType.carePet:
        return Colors.orange;
      case QuickActionType.playGame:
        return Colors.blue;
      case QuickActionType.visitStore:
        return Colors.green;
      case QuickActionType.checkFeed:
        return Colors.purple;
    }
  }

  IconData _getActionIcon(QuickActionType type) {
    switch (type) {
      case QuickActionType.adoptPet:
        return Icons.favorite_border;
      case QuickActionType.carePet:
        return Icons.pets;
      case QuickActionType.playGame:
        return Icons.games;
      case QuickActionType.visitStore:
        return Icons.store;
      case QuickActionType.checkFeed:
        return Icons.article;
    }
  }
}
