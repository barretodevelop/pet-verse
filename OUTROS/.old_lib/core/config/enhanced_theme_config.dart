// File: lib/core/config/enhanced_theme_config.dart

import 'package:flutter/material.dart';

/// Enhanced theme configuration with gaming-focused design system
class EnhancedThemeConfig {
  // IMPROVED PRIMARY PALETTE - Better accessibility and modern look
  static const Color primaryColor = Color(0xFF6366F1); // Indigo-500 - Less saturated
  static const Color primaryColorDark = Color(0xFF4F46E5); // Indigo-600
  static const Color primaryColorLight = Color(0xFF8B5CF6); // Violet-500
  static const Color primaryColorLighter = Color(0xFFA78BFA); // Violet-400

  // GAMING ACCENT COLORS - Vibrant and playful
  static const Color accentPink = Color(0xFFEC4899); // Pink-500
  static const Color accentBlue = Color(0xFF06B6D4); // Cyan-500
  static const Color accentGreen = Color(0xFF10B981); // Emerald-500
  static const Color accentYellow = Color(0xFFF59E0B); // Amber-500
  static const Color accentOrange = Color(0xFFF97316); // Orange-500
  static const Color accentRed = Color(0xFFEF4444); // Red-500

  // IMPROVED CURRENCY COLORS - Better visibility and contrast
  static const Color coinsColor = Color(0xFFFFB800); // Brighter gold
  static const Color gemsColor = Color(0xFF00D2FF); // Electric blue
  static const Color xpColor = Color(0xFF7C3AED); // Purple
  static const Color premiumColor = Color(0xFFFF6B9D); // Premium pink

  // ENHANCED PET STAT COLORS - More intuitive and accessible
  static const Color hungerColor = Color(0xFFFF6B35); // Orange-red (warm, food-related)
  static const Color happinessColor = Color(0xFF34D399); // Green (positive emotion)
  static const Color energyColor = Color(0xFF3B82F6); // Blue (dynamic energy)
  static const Color healthColor = Color(0xFFEF4444); // Red (medical/health)
  static const Color loveColor = Color(0xFFEC4899); // Pink (affection)

  // RARITY SYSTEM COLORS - For shop items and achievements
  static const Color rarityCommon = Color(0xFF9CA3AF); // Gray-400
  static const Color rarityUncommon = Color(0xFF22C55E); // Green-500
  static const Color rarityRare = Color(0xFF3B82F6); // Blue-500
  static const Color rarityEpic = Color(0xFF8B5CF6); // Purple-500
  static const Color rarityLegendary = Color(0xFFFFB800); // Gold
  static const Color rarityMythic = Color(0xFFFF6B9D); // Pink

  // STATUS AND FEEDBACK COLORS
  static const Color successColor = Color(0xFF10B981); // Emerald-500
  static const Color warningColor = Color(0xFFF59E0B); // Amber-500
  static const Color errorColor = Color(0xFFEF4444); // Red-500
  static const Color infoColor = Color(0xFF3B82F6); // Blue-500
  static const Color neutralColor = Color(0xFF6B7280); // Gray-500

  // NEUTRAL PALETTE - Better contrast ratios
  static const Color backgroundColor = Color(0xFFFAFAFA); // Almost white
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure white
  static const Color cardColor = Color(0xFFFFFFFF); // White cards

  // Dark mode colors
  static const Color backgroundColorDark = Color(0xFF0F0F23); // Dark navy
  static const Color surfaceColorDark = Color(0xFF1A1A2E); // Slightly lighter navy
  static const Color cardColorDark = Color(0xFF16213E); // Card background

  // TEXT COLORS - Improved readability
  static const Color textPrimary = Color(0xFF1F2937); // Gray-800
  static const Color textSecondary = Color(0xFF6B7280); // Gray-500
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray-400
  static const Color textOnDark = Color(0xFFFFFFFF); // White
  static const Color textOnColor = Color(0xFFFFFFFF); // White on colored backgrounds

  // IMPROVED SPACING SYSTEM - More consistent, mobile-optimized
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0; // Primary spacing unit
  static const double spacing16 = 16.0; // Secondary spacing unit
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing28 = 28.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;

  // BORDER RADIUS SYSTEM - More modern, consistent
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusXXLarge = 20.0;
  static const double radiusRound = 999.0; // For pills/badges

  // ELEVATION SYSTEM - Material 3 inspired
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation4 = 4.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;
  static const double elevation16 = 16.0;
  static const double elevation24 = 24.0;

  // ICON SIZES - Consistent scale
  static const double iconXSmall = 12.0;
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXLarge = 32.0;
  static const double iconXXLarge = 48.0;
  static const double iconXXXLarge = 64.0;

  // FONT SIZES - Improved typography scale
  static const double fontXSmall = 10.0;
  static const double fontSmall = 12.0;
  static const double fontMedium = 14.0;
  static const double fontLarge = 16.0;
  static const double fontXLarge = 18.0;
  static const double fontXXLarge = 20.0;
  static const double fontXXXLarge = 24.0;
  static const double fontDisplay = 32.0;
  static const double fontDisplayLarge = 48.0;

  // ANIMATION DURATIONS - Optimized for better UX
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 400);
  static const Duration animationSlower = Duration(milliseconds: 600);

  // GRADIENTS - Gaming-inspired
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, primaryColorDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentPink, accentBlue],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  // RARITY GRADIENTS
  static const LinearGradient commonGradient = LinearGradient(
    colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
  );

  static const LinearGradient uncommonGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  );

  static const LinearGradient rareGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
  );

  static const LinearGradient epicGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
  );

  static const LinearGradient legendaryGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFF59E0B)],
  );

  static const LinearGradient mythicGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFEC4899)],
  );

  /// Enhanced Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: textOnColor,
        secondary: accentBlue,
        onSecondary: textOnColor,
        tertiary: accentPink,
        onTertiary: textOnColor,
        surface: surfaceColor,
        onSurface: textPrimary,
        error: errorColor,
        onError: textOnColor,
        outline: Color(0xFFE5E7EB),
        outlineVariant: Color(0xFFF3F4F6),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: fontXXLarge,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: elevation2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textOnColor,
          elevation: elevation2,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing20,
            vertical: spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          textStyle: const TextStyle(
            fontSize: fontLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: fontMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: textOnColor,
        elevation: elevation4,
        shape: CircleBorder(),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing12,
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontDisplayLarge,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: fontDisplay,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontSize: fontXXXLarge,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontSize: fontXXLarge,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: fontXLarge,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: fontLarge,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: fontMedium,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: fontLarge,
          fontWeight: FontWeight.normal,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: fontMedium,
          fontWeight: FontWeight.normal,
          color: textPrimary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: fontSmall,
          fontWeight: FontWeight.normal,
          color: textSecondary,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: fontMedium,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: fontSmall,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: fontXSmall,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          height: 1.4,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: elevation8,
        selectedLabelStyle: TextStyle(
          fontSize: fontSmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: fontSmall,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE5E7EB),
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F4F6),
        deleteIconColor: textSecondary,
        disabledColor: const Color(0xFFF9FAFB),
        selectedColor: primaryColor.withOpacity(0.12),
        secondarySelectedColor: accentBlue.withOpacity(0.12),
        padding: const EdgeInsets.symmetric(horizontal: spacing8),
        labelStyle: const TextStyle(
          fontSize: fontSmall,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: fontSmall,
          fontWeight: FontWeight.w500,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusRound),
        ),
      ),
    );
  }

  /// Enhanced Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryColorLight,
        onPrimary: textPrimary,
        secondary: accentBlue,
        onSecondary: textPrimary,
        tertiary: accentPink,
        onTertiary: textPrimary,
        surface: surfaceColorDark,
        onSurface: textOnDark,
        error: errorColor,
        onError: textOnColor,
        outline: Color(0xFF374151),
        outlineVariant: Color(0xFF4B5563),
      ),

      // Similar theme configurations adapted for dark mode...
      // (Rest of the dark theme configuration would follow the same pattern)
    );
  }

  // UTILITY METHODS

  /// Get rarity color by enum
  static Color getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return rarityCommon;
      case 'uncommon':
        return rarityUncommon;
      case 'rare':
        return rarityRare;
      case 'epic':
        return rarityEpic;
      case 'legendary':
        return rarityLegendary;
      case 'mythic':
        return rarityMythic;
      default:
        return rarityCommon;
    }
  }

  /// Get rarity gradient by enum
  static LinearGradient getRarityGradient(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return commonGradient;
      case 'uncommon':
        return uncommonGradient;
      case 'rare':
        return rareGradient;
      case 'epic':
        return epicGradient;
      case 'legendary':
        return legendaryGradient;
      case 'mythic':
        return mythicGradient;
      default:
        return commonGradient;
    }
  }

  /// Get stat color by type
  static Color getStatColor(String statType) {
    switch (statType.toLowerCase()) {
      case 'hunger':
        return hungerColor;
      case 'happiness':
        return happinessColor;
      case 'energy':
        return energyColor;
      case 'health':
        return healthColor;
      case 'love':
        return loveColor;
      default:
        return neutralColor;
    }
  }

  /// Create custom box shadow
  static List<BoxShadow> getElevationShadow(double elevation) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
    ];
  }

  /// Create glow effect
  static List<BoxShadow> getGlowEffect(Color color, {double intensity = 0.3}) {
    return [
      BoxShadow(
        color: color.withOpacity(intensity),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ];
  }
}
