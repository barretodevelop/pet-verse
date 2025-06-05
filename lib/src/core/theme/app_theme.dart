import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// 🔧 REFACTOR: app_theme.dart
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // 🎮 Cores primárias para dark mode
      primaryColor: const Color(0xFFBB86FC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFBB86FC),
        brightness: Brightness.dark,
        primary: const Color(0xFFBB86FC),
        secondary: const Color(0xFF03DAC6),
        background: const Color(0xFF121212),
        surface: const Color(0xFF1E1E1E),
        onBackground: const Color(0xFFE1E1E1),
        onSurface: const Color(0xFFE1E1E1),
      ),

      // 🎨 Scaffold com cor game-like
      scaffoldBackgroundColor: const Color(0xFF0F0F23),

      // 📱 AppBar dark mode
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A2E),
        foregroundColor: Color(0xFFE1E1E1),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // 📄 Card theme adaptativo
      cardTheme: CardThemeData(
        color: const Color(0xFF2D2D44),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFF444465),
            width: 1,
          ),
        ),
      ),

      // 🎮 Bottom nav theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A2E),
        selectedItemColor: Color(0xFFBB86FC),
        unselectedItemColor: Color(0xFF666666),
        elevation: 20,
      ),

      // 📝 Text theme adaptativo
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: const Color(0xFFE1E1E1),
        displayColor: const Color(0xFFE1E1E1),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // 🎮 Cores primárias para light mode
      primaryColor: const Color(0xFF6C5CE7),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C5CE7),
        brightness: Brightness.light,
        primary: const Color(0xFF6C5CE7),
        secondary: const Color(0xFF00B894),
      ),

      scaffoldBackgroundColor: const Color(0xFFF8F9FF),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    );
  }
}
