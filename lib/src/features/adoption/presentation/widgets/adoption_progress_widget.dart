// lib/src/features/adoption/presentation/widgets/adoption_progress_widget.dart
// NOVA INCLUSÃO - Widget para mostrar o progresso visual das solicitações de adoção

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/src/core/theme/app_colors.dart';
import 'package:petverse/src/features/adoption/data/models/adoption_request_model.dart';

enum AdoptionProgressStage {
  created,
  published,
  matched,
  completed,
  cancelled,
}

class AdoptionProgressWidget extends StatefulWidget {
  final AdoptionRequest request;
  final bool isUserInitiator;
  final VoidCallback? onTap;

  const AdoptionProgressWidget({
    super.key,
    required this.request,
    required this.isUserInitiator,
    this.onTap,
  });

  @override
  State<AdoptionProgressWidget> createState() => _AdoptionProgressWidgetState();
}

class _AdoptionProgressWidgetState extends State<AdoptionProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _getProgressValue(),
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _progressController.forward();

    if (widget.request.status == 'pending') {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AdoptionProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.request.status != oldWidget.request.status) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: _getProgressValue(),
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ));

      _progressController.reset();
      _progressController.forward();

      if (widget.request.status == 'completed') {
        HapticFeedback.heavyImpact();
        _pulseController.stop();
      } else if (widget.request.status == 'pending') {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  double _getProgressValue() {
    switch (widget.request.status) {
      case 'pending':
        return widget.request.isPublic ? 0.5 : 0.3;
      case 'completed':
        return 1.0;
      case 'cancelled':
        return 0.2;
      default:
        return 0.1;
    }
  }

  AdoptionProgressStage _getCurrentStage() {
    switch (widget.request.status) {
      case 'pending':
        return widget.request.isPublic
            ? AdoptionProgressStage.published
            : AdoptionProgressStage.created;
      case 'completed':
        return AdoptionProgressStage.completed;
      case 'cancelled':
        return AdoptionProgressStage.cancelled;
      default:
        return AdoptionProgressStage.created;
    }
  }

  Color _getStageColor(AdoptionProgressStage stage) {
    final currentStage = _getCurrentStage();
    final currentIndex = AdoptionProgressStage.values.indexOf(currentStage);
    final stageIndex = AdoptionProgressStage.values.indexOf(stage);

    if (currentStage == AdoptionProgressStage.cancelled) {
      return stageIndex <= 1 ? Colors.red.shade400 : Colors.grey.shade300;
    }

    if (stageIndex <= currentIndex) {
      return AppColors.primaryPurple;
    } else if (stageIndex == currentIndex + 1 &&
        currentStage == AdoptionProgressStage.published) {
      return AppColors.primaryPurple.withOpacity(0.5);
    } else {
      return Colors.grey.shade300;
    }
  }

  String _getStageTitle(AdoptionProgressStage stage) {
    switch (stage) {
      case AdoptionProgressStage.created:
        return 'Criada';
      case AdoptionProgressStage.published:
        return 'Publicada';
      case AdoptionProgressStage.matched:
        return 'Match!';
      case AdoptionProgressStage.completed:
        return 'Completada';
      case AdoptionProgressStage.cancelled:
        return 'Cancelada';
    }
  }

  String _getStatusDescription() {
    switch (widget.request.status) {
      case 'pending':
        if (widget.request.isPublic) {
          return widget.isUserInitiator
              ? 'Aguardando alguém escolher um dos seus pets'
              : 'Escolha um dos pets para adotar';
        } else {
          return widget.isUserInitiator
              ? 'Compartilhe o código ${widget.request.friendCode} com um amigo'
              : 'Use o código do amigo para adotar';
        }
      case 'completed':
        return 'Parabéns! Adoção realizada com sucesso';
      case 'cancelled':
        return 'Solicitação cancelada';
      default:
        return 'Status desconhecido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStage = _getCurrentStage();

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.cardColor,
              theme.cardColor.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPurple.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.primaryPurple.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _getStageColor(currentStage).withOpacity(0.1),
                    ),
                    child: Text(
                      _getStageTitle(currentStage),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: _getStageColor(currentStage),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (widget.request.status == 'pending')
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryPurple,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primaryPurple.withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Request Info
              Text(
                'Solicitação #${widget.request.id.substring(0, 8)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Status Description
              Text(
                _getStatusDescription(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),

              const SizedBox(height: 16),

              // Progress Bar
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Progresso',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(_progressAnimation.value * 100).toInt()}%',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.grey.shade200,
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: LinearGradient(
                                colors: widget.request.status == 'cancelled'
                                    ? [Colors.red.shade400, Colors.red.shade600]
                                    : [
                                        AppColors.primaryPurple,
                                        AppColors.primaryPurple.withOpacity(0.7)
                                      ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              // Friend Code (if applicable)
              if (widget.request.friendCode != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.primaryPurple.withOpacity(0.1),
                    border: Border.all(
                      color: AppColors.primaryPurple.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.key,
                        color: AppColors.primaryPurple,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Código: ${widget.request.friendCode}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: widget.request.friendCode!));
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Código copiado!'),
                              backgroundColor: AppColors.primaryPurple,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.copy,
                          color: AppColors.primaryPurple,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
