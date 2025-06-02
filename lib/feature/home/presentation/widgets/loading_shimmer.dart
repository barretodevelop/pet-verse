// lib/features/home/presentation/widgets/loading_shimmer.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        children: [
          // Card shimmer 1
          _buildShimmerCard(),
          const SizedBox(height: 16),

          // Card shimmer 2
          _buildShimmerCard(),
          const SizedBox(height: 16),

          // Card shimmer 3
          _buildShimmerCard(),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.primary,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Circle shimmer
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.textLight.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                  duration: 1500.ms,
                  color: Colors.white.withOpacity(0.8),
                ),

            const SizedBox(width: 16),

            // Text shimmers
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title shimmer
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.textLight.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 1500.ms,
                        color: Colors.white.withOpacity(0.8),
                      ),

                  const SizedBox(height: 8),

                  // Subtitle shimmer
                  Container(
                    width: 200,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.textLight.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
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
