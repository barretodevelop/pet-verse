// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static ThemeData lightTheme() {
    const primaryColor = Color(0xFF8B5CF6);
    const secondaryColor = Color(0xFFEC4899);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ).copyWith(
        secondary: secondaryColor,
      ),

      // Fontes personalizadas
      fontFamily: 'Poppins',

      // AppBar customizada
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Botões com bordas arredondadas
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // // Cards com sombras suaves
      // cardTheme: CardTheme(
      //   elevation: 0,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(16),
      //   ),
      //   shadowColor: Colors.black.withOpacity(0.08),
      // ),

      // Input fields bonitos
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),

      // BottomNav customizada
      navigationBarTheme: NavigationBarThemeData(
        height: 65,
        elevation: 0,
        backgroundColor: Colors.white,
        indicatorColor: primaryColor.withOpacity(0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
