// lib/src/core/theme/adaptive_game_colors.dart
// NOVO - Sistema de cores adaptativo para experiência game-like

import 'package:flutter/material.dart';

class AdaptiveGameColors {
  // CORES PRIMÁRIAS - Adaptáveis ao tema
  static const Color _primaryLight = Color(0xFF820AD1); // Nubank Ultra Violeta
  static const Color _primaryDark =
      Color(0xFF9D4EDD); // Violeta mais suave no dark

  // CORES SECUNDÁRIAS GAME-LIKE
  static const Color _accentGreen = Color(0xFF00D4AA);
  static const Color _accentOrange = Color(0xFFFF6B35);
  static const Color _accentBlue = Color(0xFF4CC9F0);
  static const Color _accentPink = Color(0xFFE91E63);

  // CORES DE STATUS - Game feedback
  static const Color _successLight = Color(0xFF2E7D32);
  static const Color _successDark = Color(0xFF4CAF50);
  static const Color _errorLight = Color(0xFFD32F2F);
  static const Color _errorDark = Color(0xFFF44336);
  static const Color _warningLight = Color(0xFFF57C00);
  static const Color _warningDark = Color(0xFFFF9800);
  static const Color _infoLight = Color(0xFF1976D2);
  static const Color _infoDark = Color(0xFF2196F3);

  // CORES DE FUNDO ADAPTÁVEIS
  static const Color _surfaceLight = Color(0xFFFAFAFA);
  static const Color _surfaceDark = Color(0xFF121212);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _cardDark = Color(0xFF1E1E1E);

  // CORES DE OVERLAY GAME-LIKE
  static const Color _overlayLight = Color(0x0A000000);
  static const Color _overlayDark = Color(0x0AFFFFFF);
  static const Color _shimmerBase = Color(0xFFE0E0E0);
  static const Color _shimmerHighlight = Color(0xFFF5F5F5);

  // GRADIENTES ADAPTATIVOS
  static const List<Color> _primaryGradientLight = [
    Color(0xFF820AD1),
    Color(0xFF9D4EDD),
  ];

  static const List<Color> _primaryGradientDark = [
    Color(0xFF9D4EDD),
    Color(0xFFB968E6),
  ];

  static const List<Color> _successGradient = [
    Color(0xFF00D4AA),
    Color(0xFF4CAF50),
  ];

  static const List<Color> _errorGradient = [
    Color(0xFFFF6B35),
    Color(0xFFF44336),
  ];

  // GETTERS ADAPTATIVOS POR BRIGHTNESS
  static Color primary(Brightness brightness) {
    return brightness == Brightness.light ? _primaryLight : _primaryDark;
  }

  static Color success(Brightness brightness) {
    return brightness == Brightness.light ? _successLight : _successDark;
  }

  static Color error(Brightness brightness) {
    return brightness == Brightness.light ? _errorLight : _errorDark;
  }

  static Color warning(Brightness brightness) {
    return brightness == Brightness.light ? _warningLight : _warningDark;
  }

  static Color info(Brightness brightness) {
    return brightness == Brightness.light ? _infoLight : _infoDark;
  }

  static Color surface(Brightness brightness) {
    return brightness == Brightness.light ? _surfaceLight : _surfaceDark;
  }

  static Color cardBackground(Brightness brightness) {
    return brightness == Brightness.light ? _cardLight : _cardDark;
  }

  static Color overlay(Brightness brightness) {
    return brightness == Brightness.light ? _overlayLight : _overlayDark;
  }

  // GRADIENTES ADAPTATIVOS
  static List<Color> primaryGradient(Brightness brightness) {
    return brightness == Brightness.light
        ? _primaryGradientLight
        : _primaryGradientDark;
  }

  static const List<Color> successGradient = _successGradient;
  static const List<Color> errorGradient = _errorGradient;

  // CORES ESPECÍFICAS PARA GAME ELEMENTS
  static const Color accentGreen = _accentGreen;
  static const Color accentOrange = _accentOrange;
  static const Color accentBlue = _accentBlue;
  static const Color accentPink = _accentPink;

  // CORES PARA SHIMMER LOADING
  static const Color shimmerBase = _shimmerBase;
  static const Color shimmerHighlight = _shimmerHighlight;

  // MÉTODO UTILITÁRIO: Obter cores para o contexto atual
  static AdaptiveGameColorsData of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AdaptiveGameColorsData(brightness);
  }

  // MÉTODO PARA COLORSCHEME PERSONALIZADO
  static ColorScheme createColorScheme(Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: primary(brightness),
      brightness: brightness,
      primary: primary(brightness),
      secondary: accentGreen,
      tertiary: accentBlue,
      error: error(brightness),
      surface: surface(brightness),
      onPrimary: brightness == Brightness.light ? Colors.white : Colors.black,
      onSecondary: Colors.white,
      onError: Colors.white,
      onSurface:
          brightness == Brightness.light ? Colors.black87 : Colors.white54,
    );
  }
}

// Classe helper para acessar cores no contexto atual
class AdaptiveGameColorsData {
  final Brightness brightness;

  const AdaptiveGameColorsData(this.brightness);

  // CORES PRINCIPAIS
  Color get primary => AdaptiveGameColors.primary(brightness);
  Color get success => AdaptiveGameColors.success(brightness);
  Color get error => AdaptiveGameColors.error(brightness);
  Color get warning => AdaptiveGameColors.warning(brightness);
  Color get info => AdaptiveGameColors.info(brightness);

  // CORES DE FUNDO
  Color get surface => AdaptiveGameColors.surface(brightness);
  Color get cardBackground => AdaptiveGameColors.cardBackground(brightness);
  Color get overlay => AdaptiveGameColors.overlay(brightness);

  // CORES ACCENT
  Color get accentGreen => AdaptiveGameColors.accentGreen;
  Color get accentOrange => AdaptiveGameColors.accentOrange;
  Color get accentBlue => AdaptiveGameColors.accentBlue;
  Color get accentPink => AdaptiveGameColors.accentPink;

  // GRADIENTES
  List<Color> get primaryGradient =>
      AdaptiveGameColors.primaryGradient(brightness);
  List<Color> get successGradient => AdaptiveGameColors.successGradient;
  List<Color> get errorGradient => AdaptiveGameColors.errorGradient;

  // SHIMMER
  Color get shimmerBase => AdaptiveGameColors.shimmerBase;
  Color get shimmerHighlight => AdaptiveGameColors.shimmerHighlight;
}

// EXTENSÃO para facilitar uso no BuildContext
extension AdaptiveGameColorsExtension on BuildContext {
  AdaptiveGameColorsData get gameColors => AdaptiveGameColors.of(this);
}
