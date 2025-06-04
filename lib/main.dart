import 'package:firebase_core/firebase_core.dart'; // Mantemos o import do core
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/app.dart'; // Importa o widget App que criamos
// import 'package:petverse/firebase_options.dart'; // Comentado temporariamente
import 'package:shared_preferences/shared_preferences.dart'; // Necessário para o tema

void main() async {
  // Garante que os bindings do Flutter sejam inicializados antes de qualquer outra coisa.
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa o Firebase.
  await Firebase
      .initializeApp(); // Tentará inicializar com configurações padrão/nativas
  // sem o firebase_options.dart

  // Inicializa SharedPreferences.
  // Em um cenário ideal, você poderia criar um provider para SharedPreferences
  // e sobrescrevê-lo aqui com a instância carregada, para injeção de dependência.
  // Ex: ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(await SharedPreferences.getInstance())], child: App())
  // Por enquanto, o ThemeModeNotifier chamará SharedPreferences.getInstance() diretamente.
  // Apenas garantir que está disponível antes do runApp é suficiente para o _loadThemeMode inicial.
  await SharedPreferences.getInstance();

  // Envolve o widget raiz (App) com ProviderScope para habilitar Riverpod.
  runApp(const ProviderScope(child: App()));
}
