// lib/core/widgets/error_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petverse/core/theme/app_theme.dart';
import 'package:petverse/core/widgets/custom_button.dart';

class ErrorPage extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const ErrorPage({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppTheme.errorColor,
                  ),
                ),

                const SizedBox(height: AppTheme.spaceLg),

                // Error Title
                Text(
                  'Oops! Algo deu errado',
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppTheme.spaceMd),

                // Error Message
                Text(
                  error.isNotEmpty ? error : 'Ocorreu um erro inesperado.',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppTheme.space2xl),

                // Retry Button
                if (onRetry != null)
                  CustomButton(
                    text: 'Tentar Novamente',
                    onPressed: onRetry,
                    icon: Icons.refresh,
                    gradient: AppTheme.primaryGradient,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
