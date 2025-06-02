// lib/features/home/presentation/widgets/welcome_header.dart
import 'package:flutter/material.dart';
import 'package:petverse/core/constants/app_constants.dart';
import 'package:petverse/core/theme/app_theme.dart';

class WelcomeHeader extends StatelessWidget {
  final AnimationController fadeController;
  final dynamic user;

  const WelcomeHeader({
    super.key,
    required this.fadeController,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Bom dia';
    } else if (hour < 18) {
      greeting = 'Boa tarde';
    } else {
      greeting = 'Boa noite';
    }

    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          FadeTransition(
            opacity: fadeController,
            child: Text(
              '$greeting! 👋',
              style: AppTheme.headlineLarge.copyWith(
                color: AppTheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // User name or welcome
          FadeTransition(
            opacity: fadeController,
            child: Text(
              user?.displayName != null
                  ? 'Olá, ${user.displayName}!'
                  : 'Bem-vindo de volta!',
              style: AppTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
