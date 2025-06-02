// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:petverse/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          secondary: AppColors.secondary,
          brightness: Brightness.light,
          background: AppColors.backgroundLight,
          surface: AppColors.surfaceLight,
          onPrimary: AppColors.surfaceLight,
          onSecondary: AppColors.surfaceLight,
          onBackground: AppColors.textLight,
          onSurface: AppColors.textLight,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surfaceLight,
          elevation: 4,
          titleTextStyle:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: AppColors.surfaceLight,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.surfaceLight,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        // dialogTheme: DialogTheme(
        //   backgroundColor: AppColors.surfaceLight,
        //   shape:
        //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        //   titleTextStyle: TextStyle(
        //       color: AppColors.textLight,
        //       fontSize: 20,
        //       fontWeight: FontWeight.bold),
        //   contentTextStyle: TextStyle(color: AppColors.textLight, fontSize: 16),
        // ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          actionTextColor: AppColors.accent,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.primary.withOpacity(0.2),
          circularTrackColor: AppColors.primary.withOpacity(0.2),
        ),
        useMaterial3: true,
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          secondary: AppColors.secondary,
          brightness: Brightness.dark,
          background: AppColors.backgroundDark,
          surface: AppColors.surfaceDark,
          onPrimary: AppColors.textDark,
          onSecondary: AppColors.textDark,
          onBackground: AppColors.textDark,
          onSurface: AppColors.textDark,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textDark,
          elevation: 2,
          titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: AppColors.surfaceDark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textDark,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        // dialogTheme: DialogTheme(
        //   backgroundColor: AppColors.surfaceDark,
        //   shape:
        //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        //   titleTextStyle: TextStyle(
        //       color: AppColors.textDark,
        //       fontSize: 20,
        //       fontWeight: FontWeight.bold),
        //   contentTextStyle: TextStyle(color: AppColors.textDark, fontSize: 16),
        // ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          contentTextStyle: const TextStyle(color: AppColors.textDark),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          actionTextColor: AppColors.accent,
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.primary.withOpacity(0.2),
          circularTrackColor: AppColors.primary.withOpacity(0.2),
        ),
        useMaterial3: true,
      );
}
