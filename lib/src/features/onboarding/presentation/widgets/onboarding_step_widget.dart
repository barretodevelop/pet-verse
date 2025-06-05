// lib/src/features/onboarding/presentation/widgets/onboarding_step_widget.dart
// NOVA INCLUSÃO - Widget reutilizável para steps do onboarding

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class OnboardingStepWidget extends StatefulWidget {
  final String title;
  final String description;
  final String? lottieAsset;
  final IconData? icon;
  final Color primaryColor;
  final Color secondaryColor;
  final VoidCallback? onTap;
  final bool isActive;
  final bool isCompleted;
  final int stepNumber;
  final Widget? customContent;

  const OnboardingStepWidget({
    super.key,
    required this.title,
    required this.description,
    this.lottieAsset,
    this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    this.onTap,
    this.isActive = false,
    this.isCompleted = false,
    required this.stepNumber,
    this.customContent,
  });

  @override
  State<OnboardingStepWidget> createState() => _OnboardingStepWidgetState();
}

class _OnboardingStepWidgetState extends State<OnboardingStepWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _slideController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Animate on mount
    _slideController.forward();
    _scaleController.forward();

    // Pulse if active
    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(OnboardingStepWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _pulseController.repeat(reverse: true);
      HapticFeedback.lightImpact();
    } else if (!widget.isActive && oldWidget.isActive) {
      _pulseController.stop();
      _pulseController.reset();
    }

    if (widget.isCompleted && !oldWidget.isCompleted) {
      HapticFeedback.heavyImpact();
      _scaleController.forward();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isActive ? _pulseAnimation.value : 1.0,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: widget.isActive
                      ? LinearGradient(
                          colors: [
                            widget.primaryColor.withOpacity(0.2),
                            widget.secondaryColor.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  border: Border.all(
                    color: widget.isActive
                        ? widget.primaryColor
                        : theme.dividerColor.withOpacity(0.3),
                    width: widget.isActive ? 2 : 1,
                  ),
                  boxShadow: widget.isActive
                      ? [
                          BoxShadow(
                            color: widget.primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: widget.onTap != null
                        ? () {
                            HapticFeedback.selectionClick();
                            widget.onTap!();
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Step Number Badge
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: widget.isCompleted
                                  ? LinearGradient(
                                      colors: [
                                        Colors.green.shade400,
                                        Colors.green.shade600,
                                      ],
                                    )
                                  : widget.isActive
                                      ? LinearGradient(
                                          colors: [
                                            widget.primaryColor,
                                            widget.secondaryColor,
                                          ],
                                        )
                                      : LinearGradient(
                                          colors: [
                                            theme.disabledColor,
                                            theme.disabledColor
                                                .withOpacity(0.7),
                                          ],
                                        ),
                              boxShadow: widget.isActive || widget.isCompleted
                                  ? [
                                      BoxShadow(
                                        color: (widget.isCompleted
                                                ? Colors.green
                                                : widget.primaryColor)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: widget.isCompleted
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : Center(
                                    child: Text(
                                      '${widget.stepNumber}',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),

                          const SizedBox(width: 16),

                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: widget.isActive
                                        ? widget.primaryColor
                                        : widget.isCompleted
                                            ? Colors.green.shade700
                                            : theme.textTheme.titleLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(0.8),
                                  ),
                                ),
                                if (widget.customContent != null) ...[
                                  const SizedBox(height: 12),
                                  widget.customContent!,
                                ],
                              ],
                            ),
                          ),

                          // Icon or Animation
                          if (widget.lottieAsset != null)
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: Lottie.asset(
                                widget.lottieAsset!,
                                fit: BoxFit.contain,
                                repeat: widget.isActive,
                              ),
                            )
                          else if (widget.icon != null)
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.isActive
                                    ? widget.primaryColor.withOpacity(0.1)
                                    : theme.cardColor,
                              ),
                              child: Icon(
                                widget.icon,
                                color: widget.isActive
                                    ? widget.primaryColor
                                    : theme.iconTheme.color?.withOpacity(0.6),
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
