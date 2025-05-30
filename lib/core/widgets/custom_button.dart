// lib/core/widgets/custom_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petverse/core/theme/app_theme.dart';

enum CustomButtonStyle { filled, outlined, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final CustomButtonStyle style;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.style = CustomButtonStyle.filled,
    this.gradient,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 56,
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    switch (style) {
      case CustomButtonStyle.filled:
        return _buildFilledButton(context);
      case CustomButtonStyle.outlined:
        return _buildOutlinedButton(context);
      case CustomButtonStyle.text:
        return _buildTextButton(context);
    }
  }

  Widget _buildFilledButton(BuildContext context) {
    if (gradient != null) {
      return Container(
        decoration: BoxDecoration(
          gradient: onPressed != null ? gradient : null,
          color: onPressed == null ? Colors.grey.shade300 : backgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: onPressed != null ? AppTheme.cardShadowButtom : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: _buildButtonContent(
              textColor ?? Colors.white,
            ),
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppTheme.primaryColor,
        foregroundColor: textColor ?? Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        elevation: 2,
      ),
      child: _buildButtonContent(textColor ?? Colors.white),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? AppTheme.primaryColor,
        side: BorderSide(
          color: borderColor ?? AppTheme.primaryColor,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
      child: _buildButtonContent(textColor ?? AppTheme.primaryColor),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppTheme.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
      child: _buildButtonContent(textColor ?? AppTheme.primaryColor),
    );
  }

  Widget _buildButtonContent(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: AppTheme.spaceSm),
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
