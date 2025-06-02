// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF8E44AD);
  static const Color secondary = Color(0xFFF39C12);
  static const Color accent = Color(0xFF3498DB);
  static const Color backgroundLight = Color(0xFFFDFEFE);
  static const Color backgroundDark = Color(0xFF1C1C1E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2C2C2E);
  static const Color textLight = Color(0xFF17202A);
  static const Color textDark = Color(0xFFEAECEE);
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color goldCoin = Color(0xFFFFD700);
  static const Color gemStone = Color(0xFF00BFFF);
  static const Color happinessColor = Color(0xFFF1C40F);
  static const Color hungerColor = Color(0xFFE67E22);
  static const Color xpColor = Color(0xFF27AE60);
  static const Color questColor = Color(0xFF9B59B6);
  static const Color toyColor = Color(0xFF1ABC9C);
  static const Color medicineColor = Color(0xFF2ECC71);
  static const Color groomingColor = Color(0xFF3498DB);
  static const Color bathColor = Color(0xFF16A085);
  static const Color userXpColor = Color(0xFF34495E);
  static const Color environmentItemColor = Color(0xFF95A5A6);
  static const Color petDisplayCircleBgLight = Color(0xAAE0E0E0);
  static const Color petDisplayCircleBgDark = Color(0xAA303030);
  static const Color achievementLockedColor = Color(0xFFBDC3C7);
  static const Color achievementUnlockedColor = Color(0xFFF1C40F);
  static const Color achievementClaimedColor = Color(0xFF2ECC71);

  // Cores para Ciclo Dia/Noite e Overlays
  static const Gradient morningSkyGradient = LinearGradient(
      colors: [Color(0xFFFAD961), Color(0xFFF7A072)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter);
  static const Gradient afternoonSkyGradient = LinearGradient(
      colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter);
  static const Gradient nightSkyGradient = LinearGradient(
      colors: [Color(0xFF2C3E50), Color(0xFF000000)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter);
  static const Gradient eveningSkyGradient = LinearGradient(
      colors: [Color(0xFFFFA751), Color(0xFFFFE259)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter);

  static final Color morningOverlay = Colors.orange.withOpacity(0.15);
  static final Color eveningOverlay = Colors.deepOrange.withOpacity(0.25);
  static final Color nightOverlay = Colors.black.withOpacity(0.45);
  static final Color afternoonOverlay = Colors.blue.withOpacity(0.05);
}
