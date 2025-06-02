// lib/features/adoption/presentation/widgets/collaboration_steps.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/bck-app_theme.dart';

class CollaborationSteps extends StatelessWidget {
  const CollaborationSteps({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withOpacity(0.05),
            AppTheme.accentCoral.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              const Icon(
                Icons.timeline,
                color: AppTheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Como funciona o processo',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Steps
          _buildStep(
            number: 1,
            title: 'Escolha seus pets favoritos',
            description: 'Selecione até 3 pets que gostaria de adotar',
            icon: Icons.pets,
            color: AppTheme.primary,
            isFirst: true,
          ),

          _buildStep(
            number: 2,
            title: 'Crie seu pedido',
            description: 'Publique na lista pública por 5 dias',
            icon: Icons.publish,
            color: AppTheme.accentCoral,
          ),

          _buildStep(
            number: 3,
            title: 'Aguarde um co-parent',
            description: 'Alguém escolherá um dos seus pets',
            icon: Icons.favorite,
            color: AppTheme.accentPeach,
          ),

          _buildStep(
            number: 4,
            title: 'Adoção confirmada!',
            description: 'Vocês dois receberão o pet',
            icon: Icons.celebration,
            color: AppTheme.success,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required int number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator
        Column(
          children: [
            // Number circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
                .animate()
                .scale(delay: Duration(milliseconds: number * 100))
                .fadeIn(),

            // Connecting line
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
                  .animate()
                  .scaleY(delay: Duration(milliseconds: number * 100 + 200)),
          ],
        ),

        const SizedBox(width: 16),

        // Step content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: isLast ? 0 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with icon
                Row(
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Description
                Text(
                  description,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: number * 100 + 100))
            .slideX(begin: 0.2, end: 0),
      ],
    );
  }
}
