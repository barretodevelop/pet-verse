// lib/src/core/theme/adaptive_game_text_styles.dart
// NOVO - Typography system game-like com Google Fonts

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdaptiveTextStyles {
  // CONFIGURAÇÕES BASE
  static const String _primaryFontFamily = 'Poppins';
  static const String _headingFontFamily = 'Quicksand';
  static const String _monospaceFamily = 'JetBrains Mono';

  // TAMANHOS PADRONIZADOS
  static const double _headingLargeSize = 32.0;
  static const double _headingMediumSize = 28.0;
  static const double _headingSmallSize = 24.0;
  static const double _titleLargeSize = 20.0;
  static const double _titleMediumSize = 18.0;
  static const double _titleSmallSize = 16.0;
  static const double _bodyLargeSize = 16.0;
  static const double _bodyMediumSize = 14.0;
  static const double _bodySmallSize = 12.0;
  static const double _labelLargeSize = 14.0;
  static const double _labelMediumSize = 12.0;
  static const double _labelSmallSize = 10.0;

  // PESOS PADRONIZADOS
  static const FontWeight _lightWeight = FontWeight.w300;
  static const FontWeight _regularWeight = FontWeight.w400;
  static const FontWeight _mediumWeight = FontWeight.w500;
  static const FontWeight _semiBoldWeight = FontWeight.w600;
  static const FontWeight _boldWeight = FontWeight.w700;
  static const FontWeight _extraBoldWeight = FontWeight.w800;

  // ESTILOS PARA HEADINGS - Quicksand para impacto visual
  static TextStyle headingLarge(BuildContext context) {
    return GoogleFonts.quicksand(
      fontSize: _headingLargeSize,
      fontWeight: _boldWeight,
      color: _getOnSurfaceColor(context),
      letterSpacing: -0.5,
      height: 1.2,
    );
  }

  static TextStyle headingMedium(BuildContext context) {
    return GoogleFonts.quicksand(
      fontSize: _headingMediumSize,
      fontWeight: _semiBoldWeight,
      color: _getOnSurfaceColor(context),
      letterSpacing: -0.25,
      height: 1.3,
    );
  }

  static TextStyle headingSmall(BuildContext context) {
    return GoogleFonts.quicksand(
      fontSize: _headingSmallSize,
      fontWeight: _semiBoldWeight,
      color: _getOnSurfaceColor(context),
      height: 1.3,
    );
  }

  // ESTILOS PARA TÍTULOS - Poppins para legibilidade
  static TextStyle titleLarge(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: _titleLargeSize,
      fontWeight: _mediumWeight,
      color: _getOnSurfaceColor(context),
      letterSpacing: 0.15,
      height: 1.4,
    );
  }

  static TextStyle titleMedium(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: _titleMediumSize,
      fontWeight: _mediumWeight,
      color: _getOnSurfaceColor(context),
      letterSpacing: 0.1,
      height: 1.4,
    );
  }

  static TextStyle titleSmall(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: _titleSmallSize,
      fontWeight: _mediumWeight,
      color: _getOnSurfaceColor(context),
      letterSpacing: 0.1,
      height: 1.4,
    );
  }

  // ESTILOS PARA CORPO DE TEXTO
  static TextStyle bodyLarge(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: _bodyLargeSize,
      fontWeight: _regularWeight,
      color: _getOnSurfaceColor(context),
      letterSpacing: 0.5,
      height: 1.5,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: _bodyMediumSize,
      fontWeight: _regularWeight,
      color: _getOnSurfaceColor(context),
      letterSpacing: 0.25,
      height: 1.5,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: _bodySmallSize,
      fontWeight: _regularWeight,
      color: _getOnSurfaceColor(context).withOpacity(0.8),
      letterSpacing: 0.25,
      height: 1.4,
    );
  }

  // ESTILOS PARA LABELS E BOTÕES
  static TextStyle labelLarge(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: _labelLargeSize,
      fontWeight: _mediumWeight,
      color: _getOnSurfaceColor(context),
      letterSpacing: 0.1,
      height: 1.4,
    );
  }

  static TextStyle labelMedium(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: _labelMediumSize,
      fontWeight: _mediumWeight,
      color: _getOnSurfaceColor(context),
      letterSpacing: 0.5,
      height: 1.3,
    );
  }

  static TextStyle labelSmall(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: _labelSmallSize,
      fontWeight: _mediumWeight,
      color: _getOnSurfaceColor(context).withOpacity(0.8),
      letterSpacing: 0.5,
      height: 1.3,
    );
  }

  // ESTILOS ESPECÍFICOS PARA GAME ELEMENTS
  static TextStyle gameTitle(BuildContext context) {
    return GoogleFonts.quicksand(
      fontSize: 36.0,
      fontWeight: _extraBoldWeight,
      color: _getPrimaryColor(context),
      letterSpacing: -1.0,
      height: 1.1,
      shadows: [
        Shadow(
          offset: const Offset(0, 2),
          blurRadius: 4,
          color: _getOnSurfaceColor(context).withOpacity(0.25),
        ),
      ],
    );
  }

  static TextStyle gameSubtitle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 18.0,
      fontWeight: _mediumWeight,
      color: _getOnSurfaceColor(context).withOpacity(0.8),
      letterSpacing: 0.5,
      height: 1.4,
    );
  }

  static TextStyle gameButton(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 16.0,
      fontWeight: _semiBoldWeight,
      color: Colors.white,
      letterSpacing: 0.75,
      height: 1.2,
    );
  }

  static TextStyle gameStatus(BuildContext context, {required Color color}) {
    return GoogleFonts.poppins(
      fontSize: 12.0,
      fontWeight: _semiBoldWeight,
      color: color,
      letterSpacing: 0.5,
      height: 1.2,
    );
  }

  static TextStyle gameCode(BuildContext context) {
    return GoogleFonts.jetBrainsMono(
      fontSize: 18.0,
      fontWeight: _boldWeight,
      color: _getPrimaryColor(context),
      letterSpacing: 2.0,
      height: 1.2,
    );
  }

  // ESTILOS PARA ESTADOS ESPECIAIS
  static TextStyle success(BuildContext context) {
    return bodyMedium(context).copyWith(
      color: const Color(0xFF2E7D32),
      fontWeight: _mediumWeight,
    );
  }

  static TextStyle error(BuildContext context) {
    return bodyMedium(context).copyWith(
      color: const Color(0xFFD32F2F),
      fontWeight: _mediumWeight,
    );
  }

  static TextStyle warning(BuildContext context) {
    return bodyMedium(context).copyWith(
      color: const Color(0xFFF57C00),
      fontWeight: _mediumWeight,
    );
  }

  static TextStyle info(BuildContext context) {
    return bodyMedium(context).copyWith(
      color: const Color(0xFF1976D2),
      fontWeight: _mediumWeight,
    );
  }

  static TextStyle disabled(BuildContext context) {
    return bodyMedium(context).copyWith(
      color: _getOnSurfaceColor(context).withOpacity(0.38),
    );
  }

  // UTILITÁRIOS PARA CORES
  static Color _getOnSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color _getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  // MÉTODO PARA CRIAR TEXTTHEME PERSONALIZADO
  static TextTheme createTextTheme(BuildContext context) {
    return TextTheme(
      headlineLarge: headingLarge(context),
      headlineMedium: headingMedium(context),
      headlineSmall: headingSmall(context),
      titleLarge: titleLarge(context),
      titleMedium: titleMedium(context),
      titleSmall: titleSmall(context),
      bodyLarge: bodyLarge(context),
      bodyMedium: bodyMedium(context),
      bodySmall: bodySmall(context),
      labelLarge: labelLarge(context),
      labelMedium: labelMedium(context),
      labelSmall: labelSmall(context),
    );
  }

  // MÉTODO PARA OBTER INSTÂNCIA NO CONTEXTO
  static AdaptiveTextStylesData of(BuildContext context) {
    return AdaptiveTextStylesData(context);
  }
}

// Classe helper para acessar estilos no contexto atual
class AdaptiveTextStylesData {
  final BuildContext context;

  const AdaptiveTextStylesData(this.context);

  // HEADINGS
  TextStyle get headingLarge => AdaptiveTextStyles.headingLarge(context);
  TextStyle get headingMedium => AdaptiveTextStyles.headingMedium(context);
  TextStyle get headingSmall => AdaptiveTextStyles.headingSmall(context);

  // TITLES
  TextStyle get titleLarge => AdaptiveTextStyles.titleLarge(context);
  TextStyle get titleMedium => AdaptiveTextStyles.titleMedium(context);
  TextStyle get titleSmall => AdaptiveTextStyles.titleSmall(context);

  // BODY
  TextStyle get bodyLarge => AdaptiveTextStyles.bodyLarge(context);
  TextStyle get bodyMedium => AdaptiveTextStyles.bodyMedium(context);
  TextStyle get bodySmall => AdaptiveTextStyles.bodySmall(context);

  // LABELS
  TextStyle get labelLarge => AdaptiveTextStyles.labelLarge(context);
  TextStyle get labelMedium => AdaptiveTextStyles.labelMedium(context);
  TextStyle get labelSmall => AdaptiveTextStyles.labelSmall(context);

  // GAME ELEMENTS
  TextStyle get gameTitle => AdaptiveTextStyles.gameTitle(context);
  TextStyle get gameSubtitle => AdaptiveTextStyles.gameSubtitle(context);
  TextStyle get gameButton => AdaptiveTextStyles.gameButton(context);
  TextStyle gameStatus(Color color) =>
      AdaptiveTextStyles.gameStatus(context, color: color);
  TextStyle get gameCode => AdaptiveTextStyles.gameCode(context);

  // STATES
  TextStyle get success => AdaptiveTextStyles.success(context);
  TextStyle get error => AdaptiveTextStyles.error(context);
  TextStyle get warning => AdaptiveTextStyles.warning(context);
  TextStyle get info => AdaptiveTextStyles.info(context);
  TextStyle get disabled => AdaptiveTextStyles.disabled(context);
}

// EXTENSÃO para facilitar uso no BuildContext
extension AdaptiveTextStylesExtension on BuildContext {
  AdaptiveTextStylesData get textStyles => AdaptiveTextStyles.of(this);
}
