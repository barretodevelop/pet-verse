// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ============ CORES - TODAS DEFINIDAS ============

  // Cores principais
  static const Color primary = Color(0xFF6B73FF);
  static const Color primaryLight = Color(0xFF9BA3FF);
  static const Color primaryDark = Color(0xFF5A63E8);

  // Cor secundária - DEFINIDA AQUI
  static const Color secondary = Color(0xFFFF8A80);
  static const Color secondaryLight = Color(0xFFFFB74D);
  static const Color secondaryDark = Color(0xFFFF8C2B);

  // Cores semânticas
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFF56565);
  static const Color info = Color(0xFF3B82F6);

  // Cores neutras
  static const Color backgroundLight = Color(0xFFFAFBFF);
  static const Color backgroundDark = Color(0xFF1A1D29);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF242834);

  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textTertiary = Color(0xFFA0AEC0);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Cores específicas do pet
  static const Color petHappy = Color(0xFF48BB78);
  static const Color petSad = Color(0xFF3B82F6);
  static const Color petHungry = Color(0xFFED8936);
  static const Color petSleepy = Color(0xFF9B59B6);
  static const Color petSick = Color(0xFFF56565);
  static const Color petPlayful = Color(0xFFFF8A80);

  // ============ GRADIENTES ============

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundLight, Color(0xFFF7FAFC)],
  );

  // ============ SOMBRAS ============

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  // ============ TEXT STYLES - TODOS DEFINIDOS ============

  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get displaySmall => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textTertiary,
        height: 1.3,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textTertiary,
        letterSpacing: 0.5,
      );

  // ============ ESPAÇAMENTOS - TODOS DEFINIDOS ============

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double space2xl = 48;

  // ============ BORDER RADIUS - TODOS DEFINIDOS ============

  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radius2xl = 32;

  // ============ ANIMAÇÕES ============

  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration extraLongAnimation = Duration(milliseconds: 800);

  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOut;
  static const Curve sharpCurve = Curves.easeOutQuart;

  // ============ TEMA LIGHT ============

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
          secondary: secondary,
          tertiary: info,
          surface: surfaceLight,
          error: error,
        ),
        scaffoldBackgroundColor: backgroundLight,
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge: displayLarge,
          displayMedium: displayMedium,
          displaySmall: displaySmall,
          headlineLarge: headlineLarge,
          headlineMedium: headlineMedium,
          headlineSmall: headlineSmall,
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
          labelLarge: labelLarge,
          labelMedium: labelMedium,
          labelSmall: labelSmall,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: headlineMedium,
          iconTheme: const IconThemeData(
            color: textPrimary,
            size: 24,
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: textInverse,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: labelLarge.copyWith(color: textInverse),
            minimumSize: const Size(0, 48),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary, width: 1.5),
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: labelLarge.copyWith(color: primary),
            minimumSize: const Size(0, 48),
          ),
        ),
        cardTheme: CardThemeData(
          color: surfaceLight,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: bodyMedium.copyWith(color: textTertiary),
          labelStyle: labelMedium,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primary,
          linearTrackColor: Color(0xFFE8EAFF),
          circularTrackColor: Color(0xFFE8EAFF),
        ),
      );

  // ============ TEMA DARK ============

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          primary: primaryLight,
          secondary: secondary,
          tertiary: info,
          surface: surfaceDark,
          error: error,
        ),
        scaffoldBackgroundColor: backgroundDark,
        textTheme:
            GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: displayLarge.copyWith(color: textInverse),
          displayMedium: displayMedium.copyWith(color: textInverse),
          displaySmall: displaySmall.copyWith(color: textInverse),
          headlineLarge: headlineLarge.copyWith(color: textInverse),
          headlineMedium: headlineMedium.copyWith(color: textInverse),
          headlineSmall: headlineSmall.copyWith(color: textInverse),
          bodyLarge: bodyLarge.copyWith(color: Colors.white70),
          bodyMedium: bodyMedium.copyWith(color: Colors.white60),
          bodySmall: bodySmall.copyWith(color: Colors.white54),
          labelLarge: labelLarge.copyWith(color: textInverse),
          labelMedium: labelMedium.copyWith(color: Colors.white70),
          labelSmall: labelSmall.copyWith(color: Colors.white60),
        ),
        cardTheme: CardThemeData(
          color: surfaceDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          margin: EdgeInsets.zero,
        ),
      );

  // ============ MÉTODOS UTILITÁRIOS ============

  static Color getPetMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'feliz':
        return petHappy;
      case 'sad':
      case 'triste':
        return petSad;
      case 'hungry':
      case 'com fome':
        return petHungry;
      case 'sleepy':
      case 'sonolento':
        return petSleepy;
      case 'sick':
      case 'doente':
        return petSick;
      case 'playful':
      case 'brincalhão':
        return petPlayful;
      default:
        return textSecondary;
    }
  }

  static Color getStatusColor(double percentage) {
    if (percentage >= 80) return success;
    if (percentage >= 50) return warning;
    return error;
  }

  static BoxDecoration petCardDecoration({
    required Color backgroundColor,
    double borderRadius = 16,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          backgroundColor.withOpacity(0.1),
          backgroundColor.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: backgroundColor.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: withShadow ? cardShadow : null,
    );
  }
}
