// File: lib/core/utils/helpers.dart

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Utility class for common helper functions
class Helpers {
  /// Generates a random integer between min and max (inclusive)
  static int randomInt(int min, int max) {
    final random = math.Random();
    return min + random.nextInt(max - min + 1);
  }

  /// Generates a random double between min and max
  static double randomDouble(double min, double max) {
    final random = math.Random();
    return min + random.nextDouble() * (max - min);
  }

  /// Calculates XP required for next level
  static int calculateXpForLevel(int level) {
    return level * 100; // Base XP per level
  }

  /// Calculates level from total XP
  static int calculateLevelFromXp(int totalXp) {
    return (totalXp / 100).floor() + 1;
  }

  /// Calculates pet happiness based on stats
  static double calculatePetHappiness({
    required int hunger,
    required int energy,
    required int cleanliness,
  }) {
    final averageStat = (hunger + energy + cleanliness) / 3;
    return averageStat / 100;
  }

  /// Determines pet mood based on stats
  static String getPetMood({
    required int hunger,
    required int happiness,
    required int energy,
  }) {
    if (hunger < 20) return 'Hungry';
    if (energy < 20) return 'Tired';
    if (happiness > 80) return 'Happy';
    if (happiness < 30) return 'Sad';
    return 'Content';
  }

  /// Calculates color based on stat value
  static Color getStatColor(int statValue) {
    if (statValue >= 80) return Colors.green;
    if (statValue >= 50) return Colors.orange;
    return Colors.red;
  }

  /// Debounces function calls
  static void debounce(
    VoidCallback function,
    Duration delay,
  ) {
    Timer? timer;
    timer?.cancel();
    timer = Timer(delay, function);
  }

  /// Shows snackbar with custom styling
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Shows loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Hides loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Checks if current time is within daily reward window
  static bool canClaimDailyReward(DateTime? lastClaimTime) {
    if (lastClaimTime == null) return true;

    final now = DateTime.now();
    final lastClaim = lastClaimTime;

    return now.year > lastClaim.year || now.month > lastClaim.month || now.day > lastClaim.day;
  }

  /// Calculates days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// Generates unique ID
  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = math.Random().nextInt(9999);
    return '${timestamp}_$random';
  }

  /// Clamps value between min and max
  static T clamp<T extends num>(T value, T min, T max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Converts enum to readable string
  static String enumToString(dynamic enumValue) {
    return enumValue.toString().split('.').last;
  }

  /// Converts string to enum
  static T? stringToEnum<T>(List<T> enumValues, String value) {
    try {
      return enumValues.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Valida email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Verifica se é um número válido
  static bool isNumeric(String str) {
    return double.tryParse(str) != null;
  }

  /// Calcula porcentagem
  static double calculatePercentage(num value, num total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  static final Map<String, Timer> _debounceTimers = {};

  /// Gera cor aleatória
  static Color generateRandomColor() {
    final random = math.Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  /// Converte hex para Color
  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  /// Converte Color para hex
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
