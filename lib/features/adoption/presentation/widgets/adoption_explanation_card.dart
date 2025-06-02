// lib/features/adoption/presentation/widgets/adoption_explanation_card.dart
import 'package:flutter/material.dart';
import 'package:petverse/core/theme/bck-app_theme.dart';

class AdoptionExplanationCard extends StatelessWidget {
  const AdoptionExplanationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.primary,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Como funciona?',
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            'A adoção colaborativa permite que duas pessoas cuidem de um pet juntas, '
            'dividindo responsabilidades e criando laços especiais com o animal.',
            style: AppTheme.bodyMedium.copyWith(
              height: 1.6,
              color: AppTheme.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // Benefits
          _buildBenefit('🤝', 'Responsabilidade compartilhada'),
          const SizedBox(height: 8),
          _buildBenefit('💰', 'Custos divididos'),
          const SizedBox(height: 8),
          _buildBenefit('❤️', 'Mais amor e atenção para o pet'),
          const SizedBox(height: 8),
          _buildBenefit('👥', 'Conexão entre pessoas'),
        ],
      ),
    );
  }

  Widget _buildBenefit(String emoji, String text) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
