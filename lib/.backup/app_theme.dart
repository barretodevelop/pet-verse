// // lib/core/theme/app_theme.dart
// import 'package:flutter/material.dart';
//
// import 'package:google_fonts/google_fonts.dart';

// class AppTheme {
//   // Cores principais - Paleta suave e acolhedora
//   static const Color primary = Color(0xFF6B73FF);
//   static const Color primaryVariant = Color(0xFF5A63E8);
//   static const Color secondaryColor = Color(0xFFFF9F43);
//   static const Color secondaryVariant = Color(0xFFFF8C2B);

//   // Cores de apoio
//   static const Color backgroundColor = Color(0xFFF8F9FF);
//   static const Color surfaceColor = Color(0xFFFFFFFF);
//   static const Color cardColor = Color(0xFFFFFFFF);

//   // Status colors
//   static const Color successColor = Color(0xFF2ECC71);
//   static const Color warningColor = Color(0xFFF39C12);
//   static const Color errorColor = Color(0xFFE74C3C);
//   static const Color infoColor = Color(0xFF3498DB);

//   static const Gradient successGradient = LinearGradient(
//     colors: [Color(0xFF2ECC71), Color.fromARGB(255, 122, 195, 169)],
//   );
//   // Pet mood colors
//   static const Map<String, Color> moodColors = {
//     'happy': Color(0xFF2ECC71),
//     'sad': Color(0xFF3498DB),
//     'hungry': Color(0xFFE67E22),
//     'sleepy': Color(0xFF9B59B6),
//     'playful': Color(0xFFFF9F43),
//     'sick': Color(0xFF95A5A6),
//     'energetic': Color(0xFFF1C40F),
//     'dirty': Color(0xFF8D6E63),
//   };

//   // Gradients
//   static const LinearGradient primaryGradient = LinearGradient(
//     colors: [primary, primaryVariant],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );

//   static const LinearGradient backgroundGradient = LinearGradient(
//     colors: [Color(0xFFF8F9FF), Color(0xFFE8EAFF)],
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//   );

//   // Text Styles usando Google Fonts
//   static TextTheme get textTheme => TextTheme(
//         displayLarge: GoogleFonts.nunito(
//           fontSize: 32,
//           fontWeight: FontWeight.w700,
//           color: const Color(0xFF2C3E50),
//         ),
//         displayMedium: GoogleFonts.nunito(
//           fontSize: 28,
//           fontWeight: FontWeight.w600,
//           color: const Color(0xFF2C3E50),
//         ),
//         displaySmall: GoogleFonts.nunito(
//           fontSize: 24,
//           fontWeight: FontWeight.w600,
//           color: const Color(0xFF2C3E50),
//         ),
//         headlineLarge: GoogleFonts.nunito(
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           color: const Color(0xFF2C3E50),
//         ),
//         headlineMedium: GoogleFonts.nunito(
//           fontSize: 18,
//           fontWeight: FontWeight.w500,
//           color: const Color(0xFF2C3E50),
//         ),
//         headlineSmall: GoogleFonts.nunito(
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//           color: const Color(0xFF2C3E50),
//         ),
//         bodyLarge: GoogleFonts.nunito(
//           fontSize: 16,
//           fontWeight: FontWeight.w400,
//           color: const Color(0xFF34495E),
//         ),
//         bodyMedium: GoogleFonts.nunito(
//           fontSize: 14,
//           fontWeight: FontWeight.w400,
//           color: const Color(0xFF34495E),
//         ),
//         bodySmall: GoogleFonts.nunito(
//           fontSize: 12,
//           fontWeight: FontWeight.w400,
//           color: const Color(0xFF7F8C8D),
//         ),
//         labelLarge: GoogleFonts.nunito(
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//           color: const Color(0xFF2C3E50),
//         ),
//         labelMedium: GoogleFonts.nunito(
//           fontSize: 12,
//           fontWeight: FontWeight.w500,
//           color: const Color(0xFF7F8C8D),
//         ),
//         labelSmall: GoogleFonts.nunito(
//           fontSize: 10,
//           fontWeight: FontWeight.w400,
//           color: const Color(0xFF95A5A6),
//         ),
//       );

//   // Theme Data
//   static ThemeData get lightTheme => ThemeData(
//         useMaterial3: true,
//         brightness: Brightness.light,
//         colorScheme: const ColorScheme.light(
//           primary: primary,
//           primaryContainer: Color(0xFFE8EAFF),
//           secondary: secondaryColor,
//           secondaryContainer: Color(0xFFFFE8D6),
//           surface: surfaceColor,
//           error: errorColor,
//           onPrimary: Colors.white,
//           onSecondary: Colors.white,
//           onSurface: Color(0xFF2C3E50),
//           onError: Colors.white,
//         ),
//         textTheme: textTheme,
//         scaffoldBackgroundColor: backgroundColor,

//         // AppBar Theme
//         appBarTheme: AppBarTheme(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           centerTitle: true,
//           titleTextStyle: GoogleFonts.nunito(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: const Color(0xFF2C3E50),
//           ),
//           iconTheme: const IconThemeData(
//             color: Color(0xFF2C3E50),
//             size: 24,
//           ),
//         ),

//         // Card Theme
//         // cardTheme: CardTheme(
//         //   color: cardColor,
//         //   elevation: 2,
//         //   shadowColor: Colors.black.withOpacity(0.05),
//         //   shape: RoundedRectangleBorder(
//         //     borderRadius: BorderRadius.circular(16),
//         //   ),
//         // ),

//         // Elevated Button Theme
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: primary,
//             foregroundColor: Colors.white,
//             elevation: 2,
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             textStyle: GoogleFonts.nunito(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),

//         // Input Decoration Theme
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: primary, width: 2),
//           ),
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//           hintStyle: GoogleFonts.nunito(
//             color: Colors.grey.shade500,
//             fontSize: 14,
//           ),
//         ),

//         // Bottom Navigation Bar Theme
//         bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//           backgroundColor: Colors.white,
//           selectedItemColor: primary,
//           unselectedItemColor: Color(0xFF95A5A6),
//           type: BottomNavigationBarType.fixed,
//           elevation: 8,
//         ),

//         // Progress Indicator Theme
//         progressIndicatorTheme: const ProgressIndicatorThemeData(
//           color: primary,
//           linearTrackColor: Color(0xFFE8EAFF),
//         ),
//       );

//   // Spacing System
//   static const double spaceXs = 4;
//   static const double spaceSm = 8;
//   static const double spaceMd = 16;
//   static const double spaceLg = 24;
//   static const double spaceXl = 32;
//   static const double space2xl = 48;

//   // Border Radius
//   static const double radiusXs = 4;
//   static const double radiusSm = 8;
//   static const double radiusMd = 12;
//   static const double radiusLg = 16;
//   static const double radiusXl = 24;

//   // Shadows
//   static List<BoxShadow> get cardShadow => [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 10,
//           offset: const Offset(0, 2),
//         ),
//       ];

//   static List<BoxShadow> get elevatedShadow => [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.1),
//           blurRadius: 20,
//           offset: const Offset(0, 4),
//         ),
//       ];

//   // Pet specific styling
//   static BoxDecoration petCardDecoration(Color backgroundColor) =>
//       BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             backgroundColor.withOpacity(0.1),
//             backgroundColor.withOpacity(0.05),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(radiusLg),
//         border: Border.all(
//           color: backgroundColor.withOpacity(0.2),
//           width: 1,
//         ),
//       );

//   // Status indicators
//   static Color getStatusColor(double percentage) {
//     if (percentage >= 80) return successColor;
//     if (percentage >= 50) return warningColor;
//     return errorColor;
//   }

//   // Animated containers
//   static Duration get animationDuration => const Duration(milliseconds: 300);
//   static Curve get animationCurve => Curves.easeInOut;

//   // ----------------------SEGUND LINHA
//   // Paleta de cores suaves
//   static const Color primary = Color(0xFF6B73FF);
//   static const Color primaryLightSoft = Color(0xFF9BA3FF);
//   static const Color accentCoral = Color(0xFFFF8A80);
//   static const Color accentPeach = Color(0xFFFFB74D);
//   static const Color backgroundLight = Color(0xFFFAFBFF);
//   static const Color backgroundDark = Color(0xFF1A1D29);
//   static const Color surfaceLight = Color(0xFFFFFFFF);
//   static const Color surfaceDark = Color(0xFF242834);
//   static const Color textPrimary = Color(0xFF2D3748);
//   static const Color textSecondary = Color(0xFF718096);
//   static const Color textLight = Color(0xFFA0AEC0);
//   static const Color success = Color(0xFF48BB78);
//   static const Color warning = Color(0xFFED8936);
//   static const Color error = Color(0xFFF56565);
//   static const Color cardShadow = Color(0x0F000000);

//   // Gradientes suaves
//   static const LinearGradient primaryGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [primary, primaryLightSoft],
//   );

//   static const LinearGradient accentGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [accentCoral, accentPeach],
//   );

//   // static const LinearGradient backgroundGradient = LinearGradient(
//   //   begin: Alignment.topCenter,
//   //   end: Alignment.bottomCenter,
//   //   colors: [backgroundLight, Color(0xFFF7FAFC)],
//   // );

//   // Text Styles
//   static TextStyle get headingLarge => GoogleFonts.inter(
//         fontSize: 32,
//         fontWeight: FontWeight.w700,
//         color: textPrimary,
//         height: 1.2,
//       );

//   static TextStyle get headingMedium => GoogleFonts.inter(
//         fontSize: 24,
//         fontWeight: FontWeight.w600,
//         color: textPrimary,
//         height: 1.3,
//       );

//   static TextStyle get headingSmall => GoogleFonts.inter(
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//         color: textPrimary,
//         height: 1.3,
//       );

//   static TextStyle get bodyLarge => GoogleFonts.inter(
//         fontSize: 16,
//         fontWeight: FontWeight.w400,
//         color: textPrimary,
//         height: 1.5,
//       );

//   static TextStyle get bodyMedium => GoogleFonts.inter(
//         fontSize: 14,
//         fontWeight: FontWeight.w400,
//         color: textSecondary,
//         height: 1.4,
//       );

//   static TextStyle get bodySmall => GoogleFonts.inter(
//         fontSize: 12,
//         fontWeight: FontWeight.w400,
//         color: textLight,
//         height: 1.3,
//       );

//   static TextStyle get buttonText => GoogleFonts.inter(
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//         color: Colors.white,
//       );

//   static TextStyle get captionText => GoogleFonts.inter(
//         fontSize: 10,
//         fontWeight: FontWeight.w500,
//         color: textLight,
//         letterSpacing: 0.5,
//       );

//   // // Light Theme
//   // static ThemeData get lightTheme => ThemeData(
//   //       useMaterial3: true,
//   //       colorScheme: const ColorScheme.light(
//   //         primary: primary,
//   //         secondary: accentCoral,
//   //         surface: surfaceLight,
//   //         error: error,
//   //       ),
//   //       scaffoldBackgroundColor: backgroundLight,
//   //       textTheme: TextTheme(
//   //         displayLarge: headingLarge,
//   //         displayMedium: headingMedium,
//   //         displaySmall: headingSmall,
//   //         bodyLarge: bodyLarge,
//   //         bodyMedium: bodyMedium,
//   //         bodySmall: bodySmall,
//   //       ),
//   //       elevatedButtonTheme: ElevatedButtonThemeData(
//   //         style: ElevatedButton.styleFrom(
//   //           backgroundColor: primary,
//   //           foregroundColor: Colors.white,
//   //           elevation: 0,
//   //           shadowColor: Colors.transparent,
//   //           shape: RoundedRectangleBorder(
//   //             borderRadius: BorderRadius.circular(12),
//   //           ),
//   //           padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//   //           textStyle: buttonText,
//   //         ),
//   //       ),
//   //       cardTheme: CardTheme(
//   //         color: surfaceLight,
//   //         elevation: 0,
//   //         shape: RoundedRectangleBorder(
//   //           borderRadius: BorderRadius.circular(16),
//   //         ),
//   //         shadowColor: cardShadow,
//   //       ),
//   //       appBarTheme: AppBarTheme(
//   //         backgroundColor: Colors.transparent,
//   //         elevation: 0,
//   //         scrolledUnderElevation: 0,
//   //         centerTitle: true,
//   //         titleTextStyle: headingMedium,
//   //         iconTheme: const IconThemeData(color: textPrimary),
//   //       ),
//   //     );

//   // // Dark Theme
//   // static ThemeData get darkTheme => ThemeData(
//   //       useMaterial3: true,
//   //       colorScheme: const ColorScheme.dark(
//   //         primary: primaryLightSoft,
//   //         secondary: accentCoral,
//   //         surface: surfaceDark,
//   //         error: error,
//   //       ),
//   //       scaffoldBackgroundColor: backgroundDark,
//   //       textTheme: TextTheme(
//   //         displayLarge: headingLarge.copyWith(color: Colors.white),
//   //         displayMedium: headingMedium.copyWith(color: Colors.white),
//   //         displaySmall: headingSmall.copyWith(color: Colors.white),
//   //         bodyLarge: bodyLarge.copyWith(color: Colors.white70),
//   //         bodyMedium: bodyMedium.copyWith(color: Colors.white60),
//   //         bodySmall: bodySmall.copyWith(color: Colors.white54),
//   //       ),
//   //       elevatedButtonTheme: ElevatedButtonThemeData(
//   //         style: ElevatedButton.styleFrom(
//   //           backgroundColor: primaryLightSoft,
//   //           foregroundColor: backgroundDark,
//   //           elevation: 0,
//   //           shadowColor: Colors.transparent,
//   //           shape: RoundedRectangleBorder(
//   //             borderRadius: BorderRadius.circular(12),
//   //           ),
//   //           padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//   //           textStyle: buttonText.copyWith(color: backgroundDark),
//   //         ),
//   //       ),
//   //       // cardTheme: CardTheme(
//   //       //   color: surfaceDark,
//   //       //   elevation: 0,
//   //       //   shape: RoundedRectangleBorder(
//   //       //     borderRadius: BorderRadius.circular(16),
//   //       //   ),
//   //       // ),
//   //       appBarTheme: AppBarTheme(
//   //         backgroundColor: Colors.transparent,
//   //         elevation: 0,
//   //         scrolledUnderElevation: 0,
//   //         centerTitle: true,
//   //         titleTextStyle: headingMedium.copyWith(color: Colors.white),
//   //         iconTheme: const IconThemeData(color: Colors.white),
//   //       ),
//   //     );

//   // // Animation Durations
//   // static const Duration shortAnimation = Duration(milliseconds: 200);
//   // static const Duration mediumAnimation = Duration(milliseconds: 300);
//   // static const Duration longAnimation = Duration(milliseconds: 500);

//   // // Animation Curves
//   // static const Curve defaultCurve = Curves.easeInOutCubic;
//   // static const Curve bounceCurve = Curves.elasticOut;
//   // static const Curve smoothCurve = Curves.easeInOut;
// }

// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta de cores suaves
  static const Color primary = Color(0xFF6B73FF);
  static const Color primaryLightSoft = Color(0xFF9BA3FF);
  static const Color accentCoral = Color(0xFFFF8A80);
  static const Color accentPeach = Color(0xFFFFB74D);
  static const Color backgroundLight = Color(0xFFFAFBFF);
  static const Color backgroundDark = Color(0xFF1A1D29);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF242834);
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFF56565);
  static const Color cardShadow = Color(0x0F000000);

  // Gradientes suaves
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLightSoft],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentCoral, accentPeach],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundLight, Color(0xFFF7FAFC)],
  );

  // Text Styles
  static TextStyle get headingLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle get headingMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get headingSmall => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.3,
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
        color: textLight,
        height: 1.3,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get captionText => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: textLight,
        letterSpacing: 0.5,
      );

  // Light Theme
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: accentCoral,
          surface: surfaceLight,
          error: error,
        ),
        scaffoldBackgroundColor: backgroundLight,
        textTheme: TextTheme(
          displayLarge: headingLarge,
          displayMedium: headingMedium,
          displaySmall: headingSmall,
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: buttonText,
          ),
        ),
        // cardTheme: CardTheme(
        //   color: surfaceLight,
        //   elevation: 0,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(16),
        //   ),
        //   shadowColor: cardShadow,
        // ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: headingMedium,
          iconTheme: const IconThemeData(color: textPrimary),
        ),
      );

  // Dark Theme
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: primaryLightSoft,
          secondary: accentCoral,
          surface: surfaceDark,
          error: error,
        ),
        scaffoldBackgroundColor: backgroundDark,
        textTheme: TextTheme(
          displayLarge: headingLarge.copyWith(color: Colors.white),
          displayMedium: headingMedium.copyWith(color: Colors.white),
          displaySmall: headingSmall.copyWith(color: Colors.white),
          bodyLarge: bodyLarge.copyWith(color: Colors.white70),
          bodyMedium: bodyMedium.copyWith(color: Colors.white60),
          bodySmall: bodySmall.copyWith(color: Colors.white54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryLightSoft,
            foregroundColor: backgroundDark,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: buttonText.copyWith(color: backgroundDark),
          ),
        ),
        // cardTheme: CardTheme(
        //   color: surfaceDark,
        //   elevation: 0,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(16),
        //   ),
        // ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: headingMedium.copyWith(color: Colors.white),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      );

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Animation Curves
  static const Curve defaultCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOut;

  ///secundario
  ///
  ///

  // Cores principais - Paleta suave e acolhedora
  static const Color primary = Color(0xFF6B73FF);
  static const Color primaryVariant = Color(0xFF5A63E8);
  static const Color secondaryColor = Color(0xFFFF9F43);
  static const Color secondaryVariant = Color(0xFFFF8C2B);

  // Cores de apoio
  static const Color backgroundColor = Color(0xFFF8F9FF);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  // Status colors
  static const Color successColor = Color(0xFF2ECC71);
  static const Color warningColor = Color(0xFFF39C12);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color infoColor = Color(0xFF3498DB);

  static const Gradient successGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color.fromARGB(255, 122, 195, 169)],
  );
  // Pet mood colors
  static const Map<String, Color> moodColors = {
    'happy': Color(0xFF2ECC71),
    'sad': Color(0xFF3498DB),
    'hungry': Color(0xFFE67E22),
    'sleepy': Color(0xFF9B59B6),
    'playful': Color(0xFFFF9F43),
    'sick': Color(0xFF95A5A6),
    'energetic': Color(0xFFF1C40F),
    'dirty': Color(0xFF8D6E63),
  };

  // Gradients
  // static const LinearGradient primaryGradient = LinearGradient(
  //   colors: [primary, primaryVariant],
  //   begin: Alignment.topLeft,
  //   end: Alignment.bottomRight,
  // );

  // static const LinearGradient backgroundGradient = LinearGradient(
  //   colors: [Color(0xFFF8F9FF), Color(0xFFE8EAFF)],
  //   begin: Alignment.topCenter,
  //   end: Alignment.bottomCenter,
  // );

  // Text Styles usando Google Fonts
  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2C3E50),
        ),
        displayMedium: GoogleFonts.nunito(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2C3E50),
        ),
        displaySmall: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2C3E50),
        ),
        headlineLarge: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2C3E50),
        ),
        headlineMedium: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2C3E50),
        ),
        headlineSmall: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2C3E50),
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF34495E),
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF34495E),
        ),
        bodySmall: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF7F8C8D),
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2C3E50),
        ),
        labelMedium: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF7F8C8D),
        ),
        labelSmall: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF95A5A6),
        ),
      );

  // Theme Data
  // static ThemeData get lightTheme => ThemeData(
  //       useMaterial3: true,
  //       brightness: Brightness.light,
  //       colorScheme: const ColorScheme.light(
  //         primary: primary,
  //         primaryContainer: Color(0xFFE8EAFF),
  //         secondary: secondaryColor,
  //         secondaryContainer: Color(0xFFFFE8D6),
  //         surface: surfaceColor,
  //         error: errorColor,
  //         onPrimary: Colors.white,
  //         onSecondary: Colors.white,
  //         onSurface: Color(0xFF2C3E50),
  //         onError: Colors.white,
  //       ),
  //       textTheme: textTheme,
  //       scaffoldBackgroundColor: backgroundColor,

  //       // AppBar Theme
  //       appBarTheme: AppBarTheme(
  //         backgroundColor: Colors.transparent,
  //         elevation: 0,
  //         centerTitle: true,
  //         titleTextStyle: GoogleFonts.nunito(
  //           fontSize: 18,
  //           fontWeight: FontWeight.w600,
  //           color: const Color(0xFF2C3E50),
  //         ),
  //         iconTheme: const IconThemeData(
  //           color: Color(0xFF2C3E50),
  //           size: 24,
  //         ),
  //       ),

  //       // Card Theme
  //       // cardTheme: CardTheme(
  //       //   color: cardColor,
  //       //   elevation: 2,
  //       //   shadowColor: Colors.black.withOpacity(0.05),
  //       //   shape: RoundedRectangleBorder(
  //       //     borderRadius: BorderRadius.circular(16),
  //       //   ),
  //       // ),

  //       // Elevated Button Theme
  //       elevatedButtonTheme: ElevatedButtonThemeData(
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: primary,
  //           foregroundColor: Colors.white,
  //           elevation: 2,
  //           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           textStyle: GoogleFonts.nunito(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ),

  //       // Input Decoration Theme
  //       inputDecorationTheme: InputDecorationTheme(
  //         filled: true,
  //         fillColor: Colors.white,
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(12),
  //           borderSide: BorderSide(color: Colors.grey.shade300),
  //         ),
  //         enabledBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(12),
  //           borderSide: BorderSide(color: Colors.grey.shade300),
  //         ),
  //         focusedBorder: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(12),
  //           borderSide: const BorderSide(color: primary, width: 2),
  //         ),
  //         contentPadding:
  //             const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  //         hintStyle: GoogleFonts.nunito(
  //           color: Colors.grey.shade500,
  //           fontSize: 14,
  //         ),
  //       ),

  //       // Bottom Navigation Bar Theme
  //       bottomNavigationBarTheme: const BottomNavigationBarThemeData(
  //         backgroundColor: Colors.white,
  //         selectedItemColor: primary,
  //         unselectedItemColor: Color(0xFF95A5A6),
  //         type: BottomNavigationBarType.fixed,
  //         elevation: 8,
  //       ),

  //       // Progress Indicator Theme
  //       progressIndicatorTheme: const ProgressIndicatorThemeData(
  //         color: primary,
  //         linearTrackColor: Color(0xFFE8EAFF),
  //       ),
  //     );

  // Spacing System
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double space2xl = 48;

  // Border Radius
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  // // Shadows
  static List<BoxShadow> get cardShadowButtom => [
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

  // Pet specific styling
  static BoxDecoration petCardDecoration(Color backgroundColor) =>
      BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor.withOpacity(0.1),
            backgroundColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(
          color: backgroundColor.withOpacity(0.2),
          width: 1,
        ),
      );

  // Status indicators
  static Color getStatusColor(double percentage) {
    if (percentage >= 80) return successColor;
    if (percentage >= 50) return warningColor;
    return errorColor;
  }

  // Animated containers
  static Duration get animationDuration => const Duration(milliseconds: 300);
  static Curve get animationCurve => Curves.easeInOut;
}
