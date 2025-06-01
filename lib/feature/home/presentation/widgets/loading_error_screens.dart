import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/theme/app_theme.dart';
import 'package:petverse/core/utils/app_utils.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60.w,
              height: 60.w,
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 3.w,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Carregando...',
              style: TextStyle(
                fontSize: 14.sp,
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
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: AppTheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Algo deu errado',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
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
