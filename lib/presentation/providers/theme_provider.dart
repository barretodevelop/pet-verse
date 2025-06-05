import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum para representar os temas disponíveis
enum AppTheme {
  light('light'),
  dark('dark'),
  system('system');

  const AppTheme(this.value);
  final String value;

  static AppTheme fromString(String value) {
    return AppTheme.values.firstWhere(
      (theme) => theme.value == value,
      orElse: () => AppTheme.system,
    );
  }
}

/// StateNotifier para gerenciar o estado do tema
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  /// Alterna entre tema claro e escuro
  void toggleTheme() {
    switch (state) {
      case ThemeMode.light:
        state = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        state = ThemeMode.light;
        break;
      case ThemeMode.system:
        // Se está em system, vai para light
        state = ThemeMode.light;
        break;
    }
  }

  /// Define um tema específico
  void setTheme(ThemeMode themeMode) {
    state = themeMode;
  }

  /// Define tema baseado no enum AppTheme
  void setAppTheme(AppTheme appTheme) {
    switch (appTheme) {
      case AppTheme.light:
        state = ThemeMode.light;
        break;
      case AppTheme.dark:
        state = ThemeMode.dark;
        break;
      case AppTheme.system:
        state = ThemeMode.system;
        break;
    }
  }

  /// Retorna o AppTheme atual
  AppTheme get currentAppTheme {
    switch (state) {
      case ThemeMode.light:
        return AppTheme.light;
      case ThemeMode.dark:
        return AppTheme.dark;
      case ThemeMode.system:
        return AppTheme.system;
    }
  }

  /// Verifica se o tema atual é claro
  bool get isLightTheme => state == ThemeMode.light;

  /// Verifica se o tema atual é escuro
  bool get isDarkTheme => state == ThemeMode.dark;

  /// Verifica se está seguindo o sistema
  bool get isSystemTheme => state == ThemeMode.system;
}

/// Provider para o estado do tema
final themeModeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Provider computado para verificar se é tema claro
final isLightThemeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.light;
});

/// Provider computado para verificar se é tema escuro
final isDarkThemeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  return themeMode == ThemeMode.dark;
});

/// Provider para o tema claro customizado
final lightThemeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    primarySwatch: Colors.purple,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF8A05BE),
    scaffoldBackgroundColor: Colors.grey[50],
    cardColor: Colors.white,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF4A148C),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8A05BE),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 4,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: Colors.white,
      shadowColor: Colors.black26,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF8A05BE), width: 2),
      ),
      fillColor: Colors.grey[50],
      filled: true,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF8A05BE),
      unselectedItemColor: Colors.grey[500],
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Color(0xFF8A05BE),
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Color(0xFF4A148C),
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
    ),

    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8A05BE),
      brightness: Brightness.light,
    ),

    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Inter',
    useMaterial3: true,
  );
});

/// Provider para o tema escuro customizado
final darkThemeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    primarySwatch: Colors.deepPurple,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF9C27B0),
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 4,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      shadowColor: Colors.black54,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF9C27B0), width: 2),
      ),
      fillColor: const Color(0xFF2A2A2A),
      filled: true,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFF9C27B0),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Color(0xFF9C27B0),
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Color(0xFFBB86FC),
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white70,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.white60,
      ),
    ),

    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF9C27B0),
      brightness: Brightness.dark,
    ),

    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'Inter',
    useMaterial3: true,
  );
});

/// Provider computado que retorna o tema ativo baseado no modo
final activeThemeProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  final lightTheme = ref.watch(lightThemeProvider);
  final darkTheme = ref.watch(darkThemeProvider);

  switch (themeMode) {
    case ThemeMode.light:
      return lightTheme;
    case ThemeMode.dark:
      return darkTheme;
    case ThemeMode.system:
      // Por padrão, retorna o tema claro se não conseguir detectar o sistema
      return lightTheme;
  }
});

/// Extension para facilitar acesso ao tema atual
extension ThemeContextExtension on BuildContext {
  /// Retorna se o tema atual é claro
  bool get isLightTheme => Theme.of(this).brightness == Brightness.light;

  /// Retorna se o tema atual é escuro
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;

  /// Retorna as cores do tema atual
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Retorna os estilos de texto do tema atual
  TextTheme get textStyles => Theme.of(this).textTheme;
}
