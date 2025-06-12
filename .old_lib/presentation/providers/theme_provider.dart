// File: lib/presentation/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/presentation/providers/dependencies_provider.dart';

/// Theme state class
class ThemeState {
  final AppTheme currentTheme;
  final bool isAnimating;

  const ThemeState({
    this.currentTheme = AppTheme.light,
    this.isAnimating = false,
  });

  ThemeState copyWith({
    AppTheme? currentTheme,
    bool? isAnimating,
  }) {
    return ThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }

  bool get isDark => currentTheme == AppTheme.dark;
  bool get isLight => currentTheme == AppTheme.light;
  bool get isSystem => currentTheme == AppTheme.system;

  ThemeMode get themeMode {
    switch (currentTheme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }

  ThemeData get lightTheme => ThemeConfig.lightTheme;
  ThemeData get darkTheme => ThemeConfig.darkTheme;
}

/// Theme notifier
class ThemeNotifier extends StateNotifier<ThemeState> {
  final Ref _ref;

  ThemeNotifier(this._ref) : super(const ThemeState()) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final localStorage = _ref.read(localStorageProvider);
      final savedTheme = await localStorage.getThemeMode();

      if (savedTheme != null) {
        final theme = _stringToAppTheme(savedTheme);
        state = state.copyWith(currentTheme: theme);
      }
    } catch (e) {
      // Use default theme if loading fails
      state = state.copyWith(currentTheme: AppTheme.light);
    }
  }

  Future<void> setTheme(AppTheme theme) async {
    state = state.copyWith(isAnimating: true);

    await Future.delayed(const Duration(milliseconds: 150));

    state = state.copyWith(currentTheme: theme);

    // Save to local storage
    try {
      final localStorage = _ref.read(localStorageProvider);
      await localStorage.setThemeMode(_appThemeToString(theme));
    } catch (e) {
      // Handle save error silently
    }

    await Future.delayed(const Duration(milliseconds: 150));

    state = state.copyWith(isAnimating: false);
  }

  Future<void> toggleTheme() async {
    final newTheme = state.isDark ? AppTheme.light : AppTheme.dark;
    await setTheme(newTheme);
  }

  AppTheme _stringToAppTheme(String value) {
    switch (value.toLowerCase()) {
      case 'dark':
        return AppTheme.dark;
      case 'system':
        return AppTheme.system;
      default:
        return AppTheme.light;
    }
  }

  String _appThemeToString(AppTheme theme) {
    switch (theme) {
      case AppTheme.dark:
        return 'dark';
      case AppTheme.system:
        return 'system';
      default:
        return 'light';
    }
  }
}

/// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier(ref);
});

/// Theme mode provider (for MaterialApp)
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeProvider).themeMode;
});

/// Dark theme check provider
final isDarkThemeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider).isDark;
});

/// Light theme data provider
final lightThemeProvider = Provider<ThemeData>((ref) {
  return ref.watch(themeProvider).lightTheme;
});

/// Dark theme data provider
final darkThemeProvider = Provider<ThemeData>((ref) {
  return ref.watch(themeProvider).darkTheme;
});
