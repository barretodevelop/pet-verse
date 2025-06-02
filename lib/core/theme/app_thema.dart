// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ============ CORES PRINCIPAIS ============
  // 🐾 Cores inspiradas em pets e natureza
  static const Color primaryWarmBlue = Color(0xFF4A90E2);
  static const Color secondaryCoralPink = Color(0xFFFF6B9D);
  static const Color accentSunnyYellow = Color(0xFFFFD93D);
  static const Color backgroundCloudWhite = Color(0xFFFAFBFF);

  // 🌈 Gradientes emotivos
  static const LinearGradient petHappyGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient petPlayfulGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFC44569)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Cores primárias (mantendo consistência)
  static const Color primary = Color(0xFF6B73FF);
  static const Color primaryLight = Color(0xFF9BA3FF);
  static const Color primaryDark = Color(0xFF5A63E8);
  static const Color primarySoft = Color(0xFF8B5FBF);

  // Cores secundárias
  static const Color secondary = Color(0xFFFF8A80);
  static const Color secondaryLight = Color(0xFFFFB3BA);
  static const Color secondaryDark = Color(0xFFE57373);

  // Cores de destaque
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color accentPeach = Color(0xFFFFB347);
  static const Color accentMint = Color(0xFF4ECDC4);

  // Cores semânticas
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Cores neutras para modo light
  static const Color backgroundLight = Color(0xFFFAFBFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF8FAFC);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Cores neutras para modo dark
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
  static const Color borderDark = Color(0xFF475569);

  // Cores de texto para light mode
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFCBD5E1);

  // Cores de texto para dark mode
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF94A3B8);

  // Sombras
  static const Color cardShadow = Color(0x10000000);

  // ============ GRADIENTES ============

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentCoral, accentPeach],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundLight, cardLight],
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, surfaceDark],
  );

  // ============ SOMBRAS ============

  static List<BoxShadow> get cardShadowSmall => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get cardShadowMedium => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get cardShadowButtom => [
        BoxShadow(
          color: primary.withOpacity(0.2),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ];

  // ============ ESPAÇAMENTOS ============

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double space2xl = 48;

  // ============ BORDER RADIUS ============

  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radius2xl = 32;

  // ============ TEXT STYLES ============

  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get displaySmall => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headingLarge => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headingMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get headingSmall => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
      );

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  // ============ THEME DATA ============

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          primary: primary,
          onPrimary: Colors.white,
          primaryContainer: primaryLight.withOpacity(0.2),
          onPrimaryContainer: primaryDark,
          secondary: accentCoral,
          onSecondary: Colors.white,
          secondaryContainer: accentCoral.withOpacity(0.2),
          onSecondaryContainer: accentCoral,
          tertiary: accentMint,
          onTertiary: Colors.white,
          surface: surfaceLight,
          onSurface: textPrimary,
          surfaceContainerHighest: cardLight,
          outline: borderLight,
          error: error,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: backgroundLight,
        textTheme: TextTheme(
          displayLarge: displayLarge.copyWith(color: textPrimary),
          displayMedium: displayMedium.copyWith(color: textPrimary),
          displaySmall: displaySmall.copyWith(color: textPrimary),
          headlineLarge: headingLarge.copyWith(color: textPrimary),
          headlineMedium: headingMedium.copyWith(color: textPrimary),
          headlineSmall: headingSmall.copyWith(color: textPrimary),
          bodyLarge: bodyLarge.copyWith(color: textPrimary),
          bodyMedium: bodyMedium.copyWith(color: textSecondary),
          bodySmall: bodySmall.copyWith(color: textTertiary),
          labelLarge: labelLarge.copyWith(color: textPrimary),
          labelMedium: labelMedium.copyWith(color: textSecondary),
          labelSmall: labelSmall.copyWith(color: textTertiary),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: headingMedium.copyWith(color: textPrimary),
          iconTheme: const IconThemeData(color: textPrimary, size: 24),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: backgroundLight,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: labelLarge.copyWith(color: Colors.white),
            minimumSize: const Size(0, 48),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary, width: 1.5),
            backgroundColor: Colors.transparent,
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
            borderSide: const BorderSide(color: borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: bodyMedium.copyWith(color: textTertiary),
          labelStyle: labelMedium.copyWith(color: textSecondary),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
          primary: primaryLight,
          onPrimary: backgroundDark,
          primaryContainer: primary.withOpacity(0.3),
          onPrimaryContainer: primaryLight,
          secondary: accentCoral,
          onSecondary: backgroundDark,
          secondaryContainer: accentCoral.withOpacity(0.3),
          onSecondaryContainer: accentCoral,
          tertiary: accentMint,
          onTertiary: backgroundDark,
          surface: surfaceDark,
          onSurface: textPrimaryDark,
          surfaceContainerHighest: cardDark,
          outline: borderDark,
          error: error,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: backgroundDark,
        textTheme: TextTheme(
          displayLarge: displayLarge.copyWith(color: textPrimaryDark),
          displayMedium: displayMedium.copyWith(color: textPrimaryDark),
          displaySmall: displaySmall.copyWith(color: textPrimaryDark),
          headlineLarge: headingLarge.copyWith(color: textPrimaryDark),
          headlineMedium: headingMedium.copyWith(color: textPrimaryDark),
          headlineSmall: headingSmall.copyWith(color: textPrimaryDark),
          bodyLarge: bodyLarge.copyWith(color: textPrimaryDark),
          bodyMedium: bodyMedium.copyWith(color: textSecondaryDark),
          bodySmall: bodySmall.copyWith(color: textTertiaryDark),
          labelLarge: labelLarge.copyWith(color: textPrimaryDark),
          labelMedium: labelMedium.copyWith(color: textSecondaryDark),
          labelSmall: labelSmall.copyWith(color: textTertiaryDark),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: headingMedium.copyWith(color: textPrimaryDark),
          iconTheme: const IconThemeData(color: textPrimaryDark, size: 24),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: backgroundDark,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryLight,
            foregroundColor: backgroundDark,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: labelLarge.copyWith(color: backgroundDark),
            minimumSize: const Size(0, 48),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryLight,
            side: const BorderSide(color: primaryLight, width: 1.5),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMd),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: labelLarge.copyWith(color: primaryLight),
            minimumSize: const Size(0, 48),
          ),
        ),
        cardTheme: CardThemeData(
          color: surfaceDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: const BorderSide(color: primaryLight, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: bodyMedium.copyWith(color: textTertiaryDark),
          labelStyle: labelMedium.copyWith(color: textSecondaryDark),
        ),
      );

  // ============ MÉTODOS UTILITÁRIOS ============

  static Color getPetMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'feliz':
        return success;
      case 'sad':
      case 'triste':
        return info;
      case 'hungry':
      case 'com fome':
        return warning;
      case 'sleepy':
      case 'sonolento':
        return accentMint;
      case 'sick':
      case 'doente':
        return error;
      case 'playful':
      case 'brincalhão':
        return accentCoral;
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
    bool isDark = false,
  }) {
    return BoxDecoration(
      color: isDark ? surfaceDark : surfaceLight,
      gradient: LinearGradient(
        colors: [
          backgroundColor.withOpacity(isDark ? 0.2 : 0.1),
          backgroundColor.withOpacity(isDark ? 0.1 : 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: backgroundColor.withOpacity(0.3),
        width: 1,
      ),
      boxShadow: withShadow ? (isDark ? null : cardShadowMedium) : null,
    );
  }

  // Helper para obter cores baseadas no contexto do tema
  static Color getContextualTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimaryDark
        : textPrimary;
  }

  static Color getContextualTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondaryDark
        : textSecondary;
  }

  static Color getContextualSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surfaceLight;
  }

  static Color getContextualBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }
}
