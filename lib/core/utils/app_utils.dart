// lib/core/utils/app_utils.dart
// CORRIGIDO: Adicionar métodos de SnackBar que estão faltando

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AppUtils {
  // ===== HAPTIC FEEDBACK =====
  static void lightImpact() {
    if (Platform.isIOS || Platform.isAndroid) {
      HapticFeedback.lightImpact();
    }
  }

  static void mediumImpact() {
    if (Platform.isIOS || Platform.isAndroid) {
      HapticFeedback.mediumImpact();
    }
  }

  static void heavyImpact() {
    if (Platform.isIOS || Platform.isAndroid) {
      HapticFeedback.heavyImpact();
    }
  }

  static void selectionClick() {
    if (Platform.isIOS || Platform.isAndroid) {
      HapticFeedback.selectionClick();
    }
  }

  // ===== SNACKBAR METHODS =====
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981), // Verde sucesso
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444), // Vermelho erro
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF3B82F6), // Azul info
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showWarningSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_amber_outlined,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF59E0B), // Amarelo warning
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ===== DATE FORMATTING =====
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ano${years > 1 ? 's' : ''} atrás';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months mês${months > 1 ? 'es' : ''} atrás';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora mesmo';
    }
  }

  // ===== STRING UTILITIES =====
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // ===== VALIDATION =====
  static bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // ===== NUMBER FORMATTING =====
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    ).format(amount);
  }

  // ===== COLOR UTILITIES =====
  static Color getHealthColor(int health) {
    if (health >= 80) return const Color(0xFF10B981); // Verde
    if (health >= 50) return const Color(0xFFF59E0B); // Amarelo
    return const Color(0xFFEF4444); // Vermelho
  }

  static Color getEnergyColor(int energy) {
    if (energy >= 70) return const Color(0xFF3B82F6); // Azul
    if (energy >= 40) return const Color(0xFFF59E0B); // Amarelo
    return const Color(0xFFEF4444); // Vermelho
  }

  // ===== DIALOG UTILITIES =====
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  // ===== NETWORK UTILITIES =====
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ===== CLIPBOARD =====
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  // ===== DEVICE INFO =====
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;

  // ===== LOADING OVERLAY =====
  static void showLoadingOverlay(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void hideLoadingOverlay(BuildContext context) {
    Navigator.of(context).pop();
  }
}

// Extension para adicionar métodos úteis aos tipos básicos
extension StringExtensions on String {
  String get capitalized => AppUtils.capitalize(this);

  String truncate(int maxLength) => AppUtils.truncateText(this, maxLength);

  bool get isValidEmail => AppUtils.isValidEmail(this);
}

extension DateTimeExtensions on DateTime {
  String get formatted => AppUtils.formatDate(this);

  String get timeAgo => AppUtils.formatTimeAgo(this);

  String get dateTimeFormatted => AppUtils.formatDateTime(this);
}

extension NumberExtensions on int {
  String get formatted => AppUtils.formatNumber(this);

  Color get asHealthColor => AppUtils.getHealthColor(this);

  Color get asEnergyColor => AppUtils.getEnergyColor(this);
}
