import 'package:flutter/material.dart';
import 'package:petverse/core/theme/bck-app_theme.dart';

extension AppThemeExtension on BuildContext {
  // 🎨 Cores
  Color get primary => AppTheme.primary;
  Color get secondaryColor => AppTheme.secondary;
  Color get successColor => AppTheme.success;
  Color get warningColor => AppTheme.warning;
  Color get errorColor => AppTheme.error;
  Color get textPrimary => AppTheme.textPrimary;
  Color get textSecondary => AppTheme.textSecondary;

  // 📝 Text Styles
  TextStyle get displayLarge => AppTheme.displayLarge;
  TextStyle get displayMedium => AppTheme.displayMedium;
  TextStyle get displaySmall => AppTheme.displaySmall;
  TextStyle get headlineLarge => AppTheme.headlineLarge;
  TextStyle get headlineMedium => AppTheme.headlineMedium;
  TextStyle get headlineSmall => AppTheme.headlineSmall;
  TextStyle get bodyLarge => AppTheme.bodyLarge;
  TextStyle get bodyMedium => AppTheme.bodyMedium;
  TextStyle get bodySmall => AppTheme.bodySmall;
  TextStyle get labelLarge => AppTheme.labelLarge;
  TextStyle get labelMedium => AppTheme.labelMedium;
  TextStyle get labelSmall => AppTheme.labelSmall;

  // 📏 Espaçamentos
  double get spaceXs => AppTheme.spaceXs;
  double get spaceSm => AppTheme.spaceSm;
  double get spaceMd => AppTheme.spaceMd;
  double get spaceLg => AppTheme.spaceLg;
  double get spaceXl => AppTheme.spaceXl;
  double get space2xl => AppTheme.space2xl;

  // 🔄 Border Radius
  double get radiusXs => AppTheme.radiusXs;
  double get radiusSm => AppTheme.radiusSm;
  double get radiusMd => AppTheme.radiusMd;
  double get radiusLg => AppTheme.radiusLg;
  double get radiusXl => AppTheme.radiusXl;
  double get radius2xl => AppTheme.radius2xl;

  // ⏱️ Animações
  Duration get shortAnimation => AppTheme.shortAnimation;
  Duration get mediumAnimation => AppTheme.mediumAnimation;
  Duration get longAnimation => AppTheme.longAnimation;
  Duration get extraLongAnimation => AppTheme.extraLongAnimation;
}

/// Extensão para widgets com tema
extension ThemedWidgets on BuildContext {
  /// Container com tema padrão
  Widget themedContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    bool withShadow = false,
    double? borderRadius,
  }) {
    return Container(
      padding: padding ?? EdgeInsets.all(spaceMd),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(
          borderRadius ?? radiusLg,
        ),
        boxShadow: withShadow ? AppTheme.cardShadow : null,
      ),
      child: child,
    );
  }

  /// Card com tema padrão
  Widget themedCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    VoidCallback? onTap,
  }) {
    Widget cardContent = Container(
      padding: padding ?? EdgeInsets.all(spaceLg),
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(radiusLg),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: AppTheme.textTertiary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return cardContent;
  }

  /// Botão com tema padrão
  Widget themedButton({
    required String text,
    required VoidCallback onPressed,
    bool isOutlined = false,
    bool isLoading = false,
    IconData? icon,
    Color? backgroundColor,
    Color? textColor,
    double? width,
  }) {
    if (isOutlined) {
      return SizedBox(
        width: width,
        child: OutlinedButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: textColor ?? primary,
                  ),
                )
              : Icon(icon),
          label: Text(text),
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? primary,
            side: BorderSide(
              color: backgroundColor ?? primary,
              width: 1.5,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: textColor ?? Colors.white,
                ),
              )
            : Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? primary,
          foregroundColor: textColor ?? Colors.white,
        ),
      ),
    );
  }
}
