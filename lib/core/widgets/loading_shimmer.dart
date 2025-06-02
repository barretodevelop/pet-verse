import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:petverse/core/theme/app_thema.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMd),
      child: Column(
        children: [
          _buildShimmerCard(isDark),
          const SizedBox(height: 16),
          _buildShimmerCard(isDark),
          const SizedBox(height: 16),
          _buildShimmerCard(isDark),
        ],
      ),
    );
  }

  Widget _buildShimmerCard(bool isDark) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: isDark ? null : AppTheme.cardShadowMedium,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Row(
          children: [
            // Circle shimmer
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.textTertiaryDark : AppTheme.textLight)
                    .withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                  duration: 1500.ms,
                  color: Colors.white.withOpacity(0.8),
                ),

            const SizedBox(width: AppTheme.spaceMd),

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
                      color: (isDark
                              ? AppTheme.textTertiaryDark
                              : AppTheme.textLight)
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 1500.ms,
                        color: Colors.white.withOpacity(0.8),
                      ),

                  const SizedBox(height: AppTheme.spaceSm),

                  // Subtitle shimmer
                  Container(
                    width: 200,
                    height: 12,
                    decoration: BoxDecoration(
                      color: (isDark
                              ? AppTheme.textTertiaryDark
                              : AppTheme.textLight)
                          .withOpacity(0.2),
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
