// lib/src/features/adoption/presentation/widgets/adoption_request_card.dart
// ALTERAÇÃO: Card com status visual, hover effects e animações

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/src/features/adoption/data/models/adoption_request_model.dart';

class AdoptionRequestCard extends StatefulWidget {
  final AdoptionRequest request;
  final VoidCallback? onTap;

  const AdoptionRequestCard({
    super.key,
    required this.request,
    this.onTap,
  });

  @override
  State<AdoptionRequestCard> createState() => _AdoptionRequestCardState();
}

class _AdoptionRequestCardState extends State<AdoptionRequestCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));

    // Start shimmer for pending requests
    if (widget.request.status == 'pending') {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Color _getStatusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (widget.request.status.toLowerCase()) {
      case 'pending':
        return colorScheme.primary;
      case 'completed':
        return colorScheme.tertiary;
      case 'cancelled':
        return colorScheme.error;
      default:
        return colorScheme.outline;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.request.status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText() {
    switch (widget.request.status.toLowerCase()) {
      case 'pending':
        return 'Aguardando Parceiro';
      case 'completed':
        return 'Adoção Concluída';
      case 'cancelled':
        return 'Cancelada';
      default:
        return 'Status Desconhecido';
    }
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final createdAt = widget.request.createdAt.toDate();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'Agora mesmo';
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      HapticFeedback.lightImpact();
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(context);
    final isPending = widget.request.status == 'pending';

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            _scaleController.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _scaleController.reverse();
          },
          child: GestureDetector(
            onTap: _handleTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(_isHovered ? 0.2 : 0.1),
                    blurRadius: _isHovered ? 12 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shimmer effect for pending requests
                  if (isPending)
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment(-1.0 + _shimmerAnimation.value, 0),
                            end: Alignment(1.0 + _shimmerAnimation.value, 0),
                            colors: [
                              colorScheme.surface,
                              statusColor.withOpacity(0.1),
                              colorScheme.surface,
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Main content
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isHovered
                            ? statusColor.withOpacity(0.5)
                            : colorScheme.outline.withOpacity(0.2),
                        width: _isHovered ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with status
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getStatusIcon(),
                                      size: 16,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getStatusText(),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _getTimeAgo(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Request ID and type
                          Row(
                            children: [
                              Icon(
                                widget.request.isPublic
                                    ? Icons.public
                                    : Icons.group,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Solicitação #${widget.request.id.substring(0, 8)}...',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Request type indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget.request.isPublic
                                  ? colorScheme.primaryContainer
                                      .withOpacity(0.5)
                                  : colorScheme.secondaryContainer
                                      .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.request.isPublic
                                  ? 'Adoção Pública'
                                  : 'Convite Privado',
                              style: TextStyle(
                                color: widget.request.isPublic
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSecondaryContainer,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Pet count
                          Row(
                            children: [
                              Icon(
                                Icons.pets,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.request.petOptionsIds.length} pets disponíveis',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const Spacer(),
                              if (widget.onTap != null)
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: colorScheme.primary,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
