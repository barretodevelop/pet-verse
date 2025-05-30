// lib/features/adoption/presentation/widgets/adoption_explanation_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/theme/app_theme.dart';

class AdoptionExplanationCard extends StatelessWidget {
  const AdoptionExplanationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadow,
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
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Como funciona?',
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.primarySoft,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Description
          Text(
            'A adoção colaborativa permite que duas pessoas cuidem de um pet juntas, '
            'dividindo responsabilidades e criando laços especiais com o animal.',
            style: AppTheme.bodyMedium.copyWith(
              height: 1.6,
              color: AppTheme.textSecondary,
            ),
          ),

          SizedBox(height: 16.h),

          // Benefits
          _buildBenefit('🤝', 'Responsabilidade compartilhada'),
          SizedBox(height: 8.h),
          _buildBenefit('💰', 'Custos divididos'),
          SizedBox(height: 8.h),
          _buildBenefit('❤️', 'Mais amor e atenção para o pet'),
          SizedBox(height: 8.h),
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
          style: TextStyle(fontSize: 16.sp),
        ),
        SizedBox(width: 12.w),
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
