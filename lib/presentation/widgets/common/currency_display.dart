// File: lib/presentation/widgets/common/currency_display.dart

import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import '../../../core/utils/formatters.dart';

/// Widget for displaying currency with icon and value
class CurrencyDisplay extends StatelessWidget {
  final String icon;
  final int value;
  final Color color;
  final VoidCallback? onTap;
  final bool isLarge;

  const CurrencyDisplay({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
    this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? ThemeConfig.spacing12 : ThemeConfig.spacing8,
          vertical: isLarge ? ThemeConfig.spacing8 : ThemeConfig.spacing4,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(
            isLarge ? ThemeConfig.borderRadius16 : ThemeConfig.borderRadius12,
          ),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: isLarge ? ThemeConfig.fontSize20 : ThemeConfig.fontSize16,
              ),
            ),
            SizedBox(width: isLarge ? ThemeConfig.spacing8 : ThemeConfig.spacing4),
            Text(
              Formatters.formatLargeNumber(value),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: isLarge ? ThemeConfig.fontSize16 : ThemeConfig.fontSize14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
