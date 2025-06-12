// File: lib/core/utils/responsive_grid_helper.dart
// VERSÃO COMPLETA - Para referência caso precise

import 'package:flutter/material.dart';

/// Helper para calcular parâmetros de grid responsivo
class ResponsiveGridHelper {
  /// Breakpoints para diferentes tamanhos de tela
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Calcula o número de colunas baseado na largura da tela
  static int calculateColumns(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return 3; // Mobile: 3 colunas
    } else if (screenWidth < tabletBreakpoint) {
      return 4; // Tablet pequeno: 4 colunas
    } else if (screenWidth < desktopBreakpoint) {
      return 5; // Tablet grande: 5 colunas
    } else {
      return 6; // Desktop: 6 colunas
    }
  }

  /// Calcula o espaçamento entre itens baseado na largura da tela
  static double calculateSpacing(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return 8.0; // Mobile: espaçamento menor
    } else if (screenWidth < tabletBreakpoint) {
      return 12.0; // Tablet: espaçamento médio
    } else {
      return 16.0; // Desktop: espaçamento maior
    }
  }

  /// Calcula o aspect ratio dos itens baseado na largura da tela
  static double calculateAspectRatio(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return 0.75; // Mobile: mais alto para acomodar texto
    } else if (screenWidth < tabletBreakpoint) {
      return 0.8; // Tablet: proporção intermediária
    } else {
      return 0.85; // Desktop: mais quadrado
    }
  }

  /// Calcula o padding horizontal para o grid
  static double calculateHorizontalPadding(double screenWidth) {
    if (screenWidth < mobileBreakpoint) {
      return 16.0;
    } else if (screenWidth < tabletBreakpoint) {
      return 24.0;
    } else {
      return 32.0;
    }
  }

  /// Calcula o tamanho ideal de um item baseado na largura disponível
  static Size calculateItemSize(double screenWidth, int columns, double spacing) {
    final horizontalPadding = calculateHorizontalPadding(screenWidth);
    final availableWidth = screenWidth - (horizontalPadding * 2);
    final totalSpacing = spacing * (columns - 1);
    final itemWidth = (availableWidth - totalSpacing) / columns;
    final itemHeight = itemWidth / calculateAspectRatio(screenWidth);

    return Size(itemWidth, itemHeight);
  }

  /// Verifica se a tela é considerada mobile
  static bool isMobile(double screenWidth) {
    return screenWidth < mobileBreakpoint;
  }

  /// Verifica se a tela é considerada tablet
  static bool isTablet(double screenWidth) {
    return screenWidth >= mobileBreakpoint && screenWidth < desktopBreakpoint;
  }

  /// Verifica se a tela é considerada desktop
  static bool isDesktop(double screenWidth) {
    return screenWidth >= desktopBreakpoint;
  }

  /// Retorna configurações completas para o grid
  static GridConfiguration getGridConfiguration(double screenWidth) {
    return GridConfiguration(
      columns: calculateColumns(screenWidth),
      spacing: calculateSpacing(screenWidth),
      aspectRatio: calculateAspectRatio(screenWidth),
      horizontalPadding: calculateHorizontalPadding(screenWidth),
      screenType: _getScreenType(screenWidth),
    );
  }

  static ScreenType _getScreenType(double screenWidth) {
    if (isMobile(screenWidth)) return ScreenType.mobile;
    if (isTablet(screenWidth)) return ScreenType.tablet;
    return ScreenType.desktop;
  }
}

/// Configuração completa do grid
class GridConfiguration {
  final int columns;
  final double spacing;
  final double aspectRatio;
  final double horizontalPadding;
  final ScreenType screenType;

  const GridConfiguration({
    required this.columns,
    required this.spacing,
    required this.aspectRatio,
    required this.horizontalPadding,
    required this.screenType,
  });
}

/// Tipos de tela
enum ScreenType {
  mobile,
  tablet,
  desktop,
}

/// Extension para facilitar o uso
extension ScreenTypeExtension on ScreenType {
  bool get isMobile => this == ScreenType.mobile;
  bool get isTablet => this == ScreenType.tablet;
  bool get isDesktop => this == ScreenType.desktop;
}
