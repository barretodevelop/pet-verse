// lib/features/home/presentation/widgets/loading_shimmer.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding.w),
      child: Column(
        children: [
          // Card shimmer 1
          _buildShimmerCard(),
          SizedBox(height: 16.h),

          // Card shimmer 2
          _buildShimmerCard(),
          SizedBox(height: 16.h),

          // Card shimmer 3
          _buildShimmerCard(),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      width: double.infinity,
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // Circle shimmer
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppTheme.textLight.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                  duration: 1500.ms,
                  color: Colors.white.withOpacity(0.8),
                ),

            SizedBox(width: 16.w),

            // Text shimmers
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title shimmer
                  Container(
                    width: double.infinity,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: AppTheme.textLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 1500.ms,
                        color: Colors.white.withOpacity(0.8),
                      ),

                  SizedBox(height: 8.h),

                  // Subtitle shimmer
                  Container(
                    width: 200.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: AppTheme.textLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 1500.ms,
                        color: Colors.white.withOpacity(0.8),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
