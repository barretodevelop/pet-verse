// lib/shared/providers/initial_loading_provider.dart
// ALTERADO: Sistema de carregamento inicial com tratamento de erros robusto
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../features/settings/providers/day_night_cycle_provider.dart';
import '../../features/settings/providers/theme_provider.dart';
import 'global_providers.dart';

// Provider para carregamento de dados do jogo específicos do usuário
final gameDataLoadingProvider = FutureProvider<GameLoadingResult>((ref) async {
  try {
    // Verificar se o usuário está autenticado
    final authState = ref.watch(authStateChangesProvider);
    final firebaseUser = authState.asData?.value;

    if (firebaseUser == null) {
      throw Exception('Usuário não autenticado para carregar dados do jogo');
    }

    debugPrint(
        '🎮 Iniciando carregamento de dados do jogo para usuário: ${firebaseUser.uid}');

    // Carregar dados do usuário
    debugPrint('📊 Carregando perfil do usuário...');
    await ref
        .read(userProvider.notifier)
        .loadDataAndCheckQuests(firebaseUser.uid);

    // Carregar pet ativo
    debugPrint('🐾 Carregando pet ativo...');
    await ref.read(activePetProvider.notifier).loadInitialPet(firebaseUser.uid);

    debugPrint('✅ Dados do jogo carregados com sucesso');

    return const GameLoadingResult(
      success: true,
      userLoaded: true,
      petLoaded: true,
      message: 'Dados carregados com sucesso',
    );
  } catch (error, stackTrace) {
    debugPrint('❌ Erro ao carregar dados do jogo: $error');
    debugPrint('Stack trace: $stackTrace');

    // Retornar resultado de erro ao invés de lançar exceção
    return GameLoadingResult(
      success: false,
      userLoaded: false,
      petLoaded: false,
      message: error.toString(),
      error: error,
    );
  }
});

// Provider para carregamento inicial de configurações
final initialLoadingProvider =
    FutureProvider<InitialLoadingResult>((ref) async {
  try {
    debugPrint('⚙️ Iniciando carregamento de configurações iniciais...');

    // Carregar configurações de tema
    debugPrint('🎨 Carregando tema...');
    try {
      await ref.read(themeModeProvider.notifier).loadTheme();
    } catch (e) {
      debugPrint('⚠️ Erro ao carregar tema (usando padrão): $e');
    }

    // Carregar configurações de ciclo dia/noite
    debugPrint('🌅 Carregando preferências de ciclo dia/noite...');
    try {
      await ref
          .read(dayNightCycleProvider.notifier)
          .loadDayNightCyclePreference();
    } catch (e) {
      debugPrint('⚠️ Erro ao carregar ciclo dia/noite (usando padrão): $e');
    }

    // Outras configurações iniciais podem ser adicionadas aqui

    debugPrint('✅ Configurações iniciais carregadas com sucesso');

    return const InitialLoadingResult(
      success: true,
      themeLoaded: true,
      settingsLoaded: true,
      message: 'Configurações carregadas com sucesso',
    );
  } catch (error, stackTrace) {
    debugPrint('❌ Erro ao carregar configurações iniciais: $error');
    debugPrint('Stack trace: $stackTrace');

    return InitialLoadingResult(
      success: false,
      themeLoaded: false,
      settingsLoaded: false,
      message: error.toString(),
      error: error,
    );
  }
});

// Provider combinado para carregamento completo
final fullInitializationProvider =
    FutureProvider<FullInitializationResult>((ref) async {
  try {
    debugPrint('🚀 Iniciando inicialização completa da aplicação...');

    // Carregar configurações iniciais primeiro
    final initialResult = await ref.read(initialLoadingProvider.future);

    // Verificar autenticação
    final authState = await ref.read(authStateChangesProvider.future);
    final isAuthenticated = authState != null;

    GameLoadingResult? gameResult;

    if (isAuthenticated) {
      // Se autenticado, carregar dados do jogo
      gameResult = await ref.read(gameDataLoadingProvider.future);
    }

    debugPrint('✅ Inicialização completa finalizada');

    return FullInitializationResult(
      success: true,
      isAuthenticated: isAuthenticated,
      initialLoading: initialResult,
      gameLoading: gameResult,
      message: 'Aplicação inicializada com sucesso',
    );
  } catch (error, stackTrace) {
    debugPrint('❌ Erro na inicialização completa: $error');

    return FullInitializationResult(
      success: false,
      isAuthenticated: false,
      initialLoading: InitialLoadingResult(
        success: false,
        themeLoaded: false,
        settingsLoaded: false,
        message: 'Erro na inicialização',
        error: error,
      ),
      gameLoading: null,
      message: error.toString(),
      error: error,
    );
  }
});

// Modelos de resultado de carregamento
class GameLoadingResult {
  final bool success;
  final bool userLoaded;
  final bool petLoaded;
  final String message;
  final dynamic error;

  const GameLoadingResult({
    required this.success,
    required this.userLoaded,
    required this.petLoaded,
    required this.message,
    this.error,
  });

  @override
  String toString() =>
      'GameLoadingResult(success: $success, message: $message)';
}

class InitialLoadingResult {
  final bool success;
  final bool themeLoaded;
  final bool settingsLoaded;
  final String message;
  final dynamic error;

  const InitialLoadingResult({
    required this.success,
    required this.themeLoaded,
    required this.settingsLoaded,
    required this.message,
    this.error,
  });

  @override
  String toString() =>
      'InitialLoadingResult(success: $success, message: $message)';
}

class FullInitializationResult {
  final bool success;
  final bool isAuthenticated;
  final InitialLoadingResult initialLoading;
  final GameLoadingResult? gameLoading;
  final String message;
  final dynamic error;

  const FullInitializationResult({
    required this.success,
    required this.isAuthenticated,
    required this.initialLoading,
    this.gameLoading,
    required this.message,
    this.error,
  });

  @override
  String toString() =>
      'FullInitializationResult(success: $success, authenticated: $isAuthenticated)';
}
