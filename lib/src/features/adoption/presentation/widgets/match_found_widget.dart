// lib/src/features/adoption/presentation/widgets/match_found_widget.dart
// NOVA INCLUSÃO - Widget de celebração quando um match é encontrado

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/src/core/theme/app_colors.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart';

class MatchFoundWidget extends StatefulWidget {
  final Pet matchedPet;
  final String partnerName; // Nome anônimo do parceiro
  final VoidCallback? onContinue;
  final VoidCallback? onViewPet;

  const MatchFoundWidget({
    super.key,
    required this.matchedPet,
    required this.partnerName,
    this.onContinue,
    this.onViewPet,
  });

  @override
  State<MatchFoundWidget> createState() => _MatchFoundWidgetState();
}

class _MatchFoundWidgetState extends State<MatchFoundWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _particleController;
  late AnimationController _heartController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    ));

    _heartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _startAnimationSequence();

    // Haptic feedback
    HapticFeedback.heavyImpact();

    // Delayed haptics for celebration effect
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.mediumImpact();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      HapticFeedback.lightImpact();
    });
  }

  void _startAnimationSequence() async {
    await _scaleController.forward();
    _rotationController.repeat();
    _particleController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _heartController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _particleController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryPurple.withOpacity(0.1),
            Colors.pink.withOpacity(0.1),
            Colors.orange.withOpacity(0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Particles Background
          AnimatedBuilder(
            animation: _particleAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(size.width, size.height),
                painter: ParticlePainter(_particleAnimation.value),
              );
            },
          ),

          // Main Content
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Match Title with Animation
                    AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 0.1,
                          child: Text(
                            '🎉 MATCH! 🎉',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPurple,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Pet Image with Hearts
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pet Image
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryPurple,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryPurple.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: widget.matchedPet.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.pets,
                                size: 50,
                              ),
                            ),
                          ),
                        ),

                        // Floating Hearts
                        AnimatedBuilder(
                          animation: _heartAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: -10 - (_heartAnimation.value * 20),
                              right: -10 + (_heartAnimation.value * 15),
                              child: Opacity(
                                opacity: 1.0 - _heartAnimation.value,
                                child: Transform.scale(
                                  scale: 1.0 + (_heartAnimation.value * 0.5),
                                  child: const Text(
                                    '❤️',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        AnimatedBuilder(
                          animation: _heartAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: -5 - (_heartAnimation.value * 25),
                              left: -15 + (_heartAnimation.value * 10),
                              child: Opacity(
                                opacity: 1.0 - _heartAnimation.value,
                                child: Transform.scale(
                                  scale: 1.0 + (_heartAnimation.value * 0.3),
                                  child: const Text(
                                    '💖',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Pet Info
                    Text(
                      widget.matchedPet.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPurple,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    Text(
                      '${widget.matchedPet.species} • ${widget.matchedPet.breed}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color:
                            theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Partner Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.primaryPurple.withOpacity(0.1),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.people,
                                color: AppColors.primaryPurple,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Seu parceiro de cuidados:',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.partnerName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Success Message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.green.withOpacity(0.1),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Parabéns! Vocês agora são parceiros de cuidados. Trabalhem juntos para manter ${widget.matchedPet.name} feliz e saudável!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.green.shade700,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onViewPet,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(
                                  color: AppColors.primaryPurple),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Ver Pet'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              widget.onContinue?.call();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Começar a Cuidar!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw floating particles
    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20) * i + (animationValue * 50) % size.width;
      final y = size.height * 0.2 +
          (i % 3) * 100 +
          (animationValue * 100) % size.height;
      final opacity = (1.0 - animationValue).clamp(0.0, 1.0);

      // Alternate between different particle colors
      final colors = [
        AppColors.primaryPurple.withOpacity(opacity * 0.6),
        Colors.pink.withOpacity(opacity * 0.4),
        Colors.orange.withOpacity(opacity * 0.3),
      ];

      paint.color = colors[i % colors.length];

      canvas.drawCircle(
        Offset(x, y),
        2.0 + (animationValue * 3),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
