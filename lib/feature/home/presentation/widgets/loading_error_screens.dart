import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/theme/bck-app_theme.dart';
import 'package:petverse/core/utils/app_utils.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Carregando...',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends ConsumerWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool showLoginButton;

  const ErrorScreen({
    super.key,
    required this.message,
    this.onRetry,
    this.showLoginButton = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Algo deu errado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (showLoginButton)
              ElevatedButton(
                onPressed: () {
                  AppUtils.mediumImpact();
                  context.go('/auth/login');
                },
                child: const Text('Fazer Login'),
              )
            else if (onRetry != null)
              ElevatedButton(
                onPressed: () {
                  AppUtils.mediumImpact();
                  onRetry!();
                },
                child: const Text('Tentar Novamente'),
              ),
          ],
        ),
      ),
    );
  }
}
