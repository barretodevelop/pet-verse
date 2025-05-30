// lib/core/utils/app_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/core/constants/app_constants.dart';
import 'package:petverse/core/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';

class AppUtils {
  // Haptic Feedback
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  // Clipboard
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  // Share
  static Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  static Future<void> shareAdoptionRequest(
      String requestId, String requesterName) async {
    final link = 'https://yourapp.com/adopt/$requestId';
    final text =
        '$requesterName está procurando um co-parent para adotar um pet! '
        'Ajude clicando no link: $link';

    await Share.share(text, subject: 'Pedido de Adoção Colaborativa');
  }

  // Date Formatting
  static String formatTimeRemaining(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.isNegative) return 'Expirado';

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return '$days ${days == 1 ? 'dia' : 'dias'}';
    } else if (hours > 0) {
      return '$hours ${hours == 1 ? 'hora' : 'horas'}';
    } else {
      return '$minutes ${minutes == 1 ? 'minuto' : 'minutos'}';
    }
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.trim().length < AppConstants.minNameLength) {
      return 'Nome deve ter pelo menos ${AppConstants.minNameLength} caracteres';
    }
    if (value.trim().length > AppConstants.maxNameLength) {
      return 'Nome deve ter no máximo ${AppConstants.maxNameLength} caracteres';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null && value.length > AppConstants.maxDescriptionLength) {
      return 'Descrição deve ter no máximo ${AppConstants.maxDescriptionLength} caracteres';
    }
    return null;
  }

  // Snackbar Helpers
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primarySoft,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
