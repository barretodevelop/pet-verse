// lib/features/settings/notifiers/theme_mode_notifier.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/services/persistence_service.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final PersistenceService _persistenceService;
  ThemeModeNotifier(this._persistenceService) : super(ThemeMode.dark);

  Future<void> loadTheme() async {
    state = await _persistenceService.loadThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _persistenceService.saveThemeMode(mode);
  }
}
