import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themePrefsKey = 'selectedThemeMode';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  // Para carregar o tema salvo, precisaríamos de SharedPreferences.
  // Por enquanto, vamos começar com o tema do sistema.
  // A inicialização do SharedPreferences será feita no main.dart e passada para o provider.
  // Este provider dependerá de um provider de SharedPreferences injetado.
  // Por simplicidade AGORA, vamos apenas retornar o Notifier.
  // Em um passo futuro, injetaremos SharedPreferences aqui.
  return ThemeModeNotifier(ref);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this.ref) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  final Ref ref; // Para acessar outros providers, como SharedPreferences

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance(); // Idealmente injetado
    final themeIndex = prefs.getInt(_themePrefsKey) ?? ThemeMode.system.index;
    state = ThemeMode.values[themeIndex];
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = themeMode;
    final prefs = await SharedPreferences.getInstance(); // Idealmente injetado
    await prefs.setInt(_themePrefsKey, themeMode.index);
  }
}
