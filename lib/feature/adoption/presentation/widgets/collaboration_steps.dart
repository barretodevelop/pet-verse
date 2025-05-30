// lib/features/adoption/presentation/widgets/collaboration_steps.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';

class CollaborationSteps extends StatelessWidget {
  const CollaborationSteps({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primarySoft.withOpacity(0.05),
            AppTheme.accentCoral.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppTheme.primarySoft.withOpacity(0.1),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: AppTheme.primarySoft,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Como funciona o processo',
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.primarySoft,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Steps
          _buildStep(
            number: 1,
            title: 'Escolha seus pets favoritos',
            description: 'Selecione até 3 pets que gostaria de adotar',
            icon: Icons.pets,
            color: AppTheme.primarySoft,
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
              width: 40.w,
              height: 40.w,
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
                width: 2.w,
                height: 60.h,
                margin: EdgeInsets.symmetric(vertical: 8.h),
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

        SizedBox(width: 16.w),

        // Step content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4.h, bottom: isLast ? 0 : 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with icon
                Row(
                  children: [
                    Icon(
                      icon,
                      color: color,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
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

                SizedBox(height: 4.h),

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
