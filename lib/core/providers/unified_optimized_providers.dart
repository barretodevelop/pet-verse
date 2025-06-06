// lib/core/providers/unified_optimized_providers.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../data/models/pet.dart';
import '../../presentation/providers/optimized_currency_provider.dart';
import '../../presentation/providers/optimized_pet_provider.dart';
import '../cache/provider_cache.dart';
import '../providers/firebase_providers.dart';

/// Estado global da aplicação unificado
class UnifiedAppState {
  final OptimizedPetsState pets;
  final OptimizedCurrencyState? currency;
  final bool isInitialized;
  final bool isOnline;
  final String? globalError;
  final DateTime lastSync;

  const UnifiedAppState({
    required this.pets,
    this.currency,
    this.isInitialized = false,
    this.isOnline = true,
    this.globalError,
    required this.lastSync,
  });

  UnifiedAppState copyWith({
    OptimizedPetsState? pets,
    OptimizedCurrencyState? currency,
    bool? isInitialized,
    bool? isOnline,
    String? globalError,
    DateTime? lastSync,
  }) {
    return UnifiedAppState(
      pets: pets ?? this.pets,
      currency: currency ?? this.currency,
      isInitialized: isInitialized ?? this.isInitialized,
      isOnline: isOnline ?? this.isOnline,
      globalError: globalError,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  /// Verifica se está em estado de carregamento
  bool get isLoading => pets.isLoading || (currency?.isLoading ?? false);

  /// Verifica se tem erro
  bool get hasError =>
      pets.error != null || currency?.error != null || globalError != null;

  /// Obtém lista de erros
  List<String> get errors => [
        if (pets.error != null) pets.error!,
        if (currency?.error != null) currency!.error!,
        if (globalError != null) globalError!,
      ];

  /// Verifica se tem mudanças locais pendentes
  bool get hasLocalChanges => currency?.hasLocalChanges ?? false;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnifiedAppState &&
          pets == other.pets &&
          currency == other.currency &&
          isInitialized == other.isInitialized &&
          isOnline == other.isOnline &&
          globalError == other.globalError;

  @override
  int get hashCode => Object.hash(
        pets,
        currency,
        isInitialized,
        isOnline,
        globalError,
      );
}

/// Notifier unificado que coordena todos os providers
class UnifiedAppNotifier extends StateNotifier<UnifiedAppState> {
  static final Logger _logger = Logger();

  final ProviderCache _cache;
  final Ref _ref;

  Timer? _syncTimer;
  StreamSubscription? _connectivitySubscription;

  UnifiedAppNotifier(this._cache, this._ref)
      : super(UnifiedAppState(
          pets: OptimizedPetsState(lastUpdated: DateTime.now()),
          lastSync: DateTime.now(),
        )) {
    _initialize();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  // ========================================
  // MÉTODOS DE INICIALIZAÇÃO
  // ========================================

  /// Inicializa o estado unificado
  Future<void> _initialize() async {
    try {
      _logger.d('Initializing unified app state...');

      // Inicia monitoramento de conectividade
      _startConnectivityMonitoring();

      // Inicia sincronização periódica
      _startPeriodicSync();

      // Carrega dados iniciais
      await _loadInitialData();

      state = state.copyWith(isInitialized: true);
      _logger.i('Unified app state initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize app state',
          error: e, stackTrace: stackTrace);
      state = state.copyWith(
        globalError: 'Erro na inicialização: $e',
        isInitialized: true,
      );
    }
  }

  /// Carrega dados iniciais
  Future<void> _loadInitialData() async {
    final userId = _ref.read(firebaseCurrentUserProvider)?.uid;

    // Carrega pets
    await _ref.read(optimizedPetsProvider.notifier).loadPets();

    // Carrega moeda se usuário autenticado
    if (userId != null) {
      await _ref
          .read(optimizedCurrencyProvider(userId).notifier)
          .loadCurrency();
    }

    _updateStateFromProviders();
  }

  /// Atualiza estado baseado nos providers
  void _updateStateFromProviders() {
    final userId = _ref.read(firebaseCurrentUserProvider)?.uid;

    final petsState = _ref.read(optimizedPetsProvider);
    final currencyState =
        userId != null ? _ref.read(optimizedCurrencyProvider(userId)) : null;

    state = state.copyWith(
      pets: petsState,
      currency: currencyState,
      lastSync: DateTime.now(),
    );
  }

  // ========================================
  // MÉTODOS PÚBLICOS
  // ========================================

  /// Força refresh completo de todos os dados
  Future<void> refreshAll() async {
    try {
      _logger.d('Refreshing all app data...');

      final userId = _ref.read(firebaseCurrentUserProvider)?.uid;

      // Refresh pets
      await _ref.read(optimizedPetsProvider.notifier).refresh();

      // Refresh currency se usuário autenticado
      if (userId != null) {
        await _ref
            .read(optimizedCurrencyProvider(userId).notifier)
            .loadCurrency(
              forceRefresh: true,
            );
      }

      _updateStateFromProviders();
      _logger.d('App data refreshed successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to refresh app data', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        globalError: 'Erro ao atualizar dados: $e',
      );
    }
  }

  /// Sincroniza dados pendentes
  Future<void> syncPendingData() async {
    try {
      if (!state.hasLocalChanges) return;

      _logger.d('Syncing pending data...');

      final userId = _ref.read(firebaseCurrentUserProvider)?.uid;

      if (userId != null && state.currency?.hasLocalChanges == true) {
        await _ref.read(optimizedCurrencyProvider(userId).notifier).forcSync();
      }

      _updateStateFromProviders();
      _logger.d('Pending data synced successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to sync pending data',
          error: e, stackTrace: stackTrace);
      state = state.copyWith(
        globalError: 'Erro ao sincronizar dados: $e',
      );
    }
  }

  /// Limpa cache global
  void clearCache() {
    _cache.clear();
    _logger.d('Global cache cleared');
  }

  /// Limpa erros
  void clearErrors() {
    state = state.copyWith(globalError: null);
  }

  /// Atualiza status de conectividade
  void updateConnectivity(bool isOnline) {
    if (state.isOnline != isOnline) {
      state = state.copyWith(isOnline: isOnline);

      if (isOnline) {
        // Recarrega dados quando volta online
        Future.microtask(() => refreshAll());
      }
    }
  }

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  /// Inicia monitoramento de conectividade
  void _startConnectivityMonitoring() {
    // Implementação simplificada - em produção usaria connectivity_plus
    Timer.periodic(const Duration(seconds: 30), (_) {
      // Simula check de conectividade
      _checkConnectivity();
    });
  }

  /// Verifica conectividade
  Future<void> _checkConnectivity() async {
    try {
      // Implementação simplificada
      const isOnline = true; // Em produção, verificaria conectividade real
      updateConnectivity(isOnline);
    } catch (e) {
      updateConnectivity(false);
    }
  }

  /// Inicia sincronização periódica
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (state.isOnline) {
        syncPendingData();
      }
    });
  }
}

// ========================================
// PROVIDERS UNIFICADOS
// ========================================

/// Provider principal unificado
final unifiedAppProvider =
    StateNotifierProvider<UnifiedAppNotifier, UnifiedAppState>((ref) {
  final cache = ref.watch(providerCacheProvider);
  return UnifiedAppNotifier(cache, ref);
});

/// Provider para monitorar mudanças de usuário
final currentUserWatcherProvider = Provider<String?>((ref) {
  return ref.watch(firebaseCurrentUserProvider)?.uid;
});

/// Provider que escuta mudanças de usuário e atualiza contexto
final userContextProvider = Provider<UserContext?>((ref) {
  final userId = ref.watch(currentUserWatcherProvider);
  final appState = ref.watch(unifiedAppProvider);

  if (userId == null) return null;

  return UserContext(
    userId: userId,
    currency: appState.currency,
    pets: appState.pets.pets
        .where((pet) => pet.generatedByUserId == userId)
        .toList(),
    isOnline: appState.isOnline,
  );
});

/// Provider para estatísticas globais
final globalStatsProvider = Provider<GlobalStats>((ref) {
  final appState = ref.watch(unifiedAppProvider);
  final cacheStats = ref.watch(cacheStatsProvider);

  return GlobalStats(
    totalPets: appState.pets.pets.length,
    availablePets: appState.pets.availablePets.length,
    criticalPets: appState.pets.criticalPets.length,
    cacheHitRate: cacheStats.hitRate,
    lastSync: appState.lastSync,
    hasLocalChanges: appState.hasLocalChanges,
  );
});

/// Provider para selectors de performance
final performanceMetricsProvider = Provider<PerformanceMetrics>((ref) {
  final cacheStats = ref.watch(cacheStatsProvider);
  final appState = ref.watch(unifiedAppProvider);

  return PerformanceMetrics(
    cacheStats: cacheStats,
    lastUpdateDuration: DateTime.now().difference(appState.lastSync),
    memoryUsage: cacheStats.totalEntries,
    isOptimized: !appState.isLoading && cacheStats.hitRate > 0.8,
  );
});

// ========================================
// CLASSES DE APOIO
// ========================================

/// Contexto do usuário atual
class UserContext {
  final String userId;
  final OptimizedCurrencyState? currency;
  final List<Pet> pets;
  final bool isOnline;

  const UserContext({
    required this.userId,
    this.currency,
    this.pets = const [],
    this.isOnline = true,
  });

  /// Verifica se o usuário pode fazer ações
  bool get canPerformActions => isOnline && currency != null;

  /// Verifica se tem pets
  bool get hasPets => pets.isNotEmpty;

  /// Obtém pet atual (primeiro da lista)
  Pet? get currentPet => pets.isNotEmpty ? pets.first : null;
}

/// Estatísticas globais da aplicação
class GlobalStats {
  final int totalPets;
  final int availablePets;
  final int criticalPets;
  final double cacheHitRate;
  final DateTime lastSync;
  final bool hasLocalChanges;

  const GlobalStats({
    required this.totalPets,
    required this.availablePets,
    required this.criticalPets,
    required this.cacheHitRate,
    required this.lastSync,
    required this.hasLocalChanges,
  });

  /// Taxa de adoção (estimada)
  double get adoptionRate =>
      totalPets > 0 ? ((totalPets - availablePets) / totalPets) * 100 : 0;

  /// Saúde geral dos pets
  double get petsHealthScore =>
      totalPets > 0 ? ((totalPets - criticalPets) / totalPets) * 100 : 100;

  Map<String, dynamic> toJson() {
    return {
      'totalPets': totalPets,
      'availablePets': availablePets,
      'criticalPets': criticalPets,
      'adoptionRate': adoptionRate,
      'petsHealthScore': petsHealthScore,
      'cacheHitRate': cacheHitRate,
      'lastSync': lastSync.toIso8601String(),
      'hasLocalChanges': hasLocalChanges,
    };
  }
}

/// Métricas de performance
class PerformanceMetrics {
  final CacheStats cacheStats;
  final Duration lastUpdateDuration;
  final int memoryUsage;
  final bool isOptimized;

  const PerformanceMetrics({
    required this.cacheStats,
    required this.lastUpdateDuration,
    required this.memoryUsage,
    required this.isOptimized,
  });

  /// Score de performance (0-100)
  double get performanceScore {
    var score = 100.0;

    // Penaliza cache hit rate baixo
    if (cacheStats.hitRate < 0.8) {
      score -= (0.8 - cacheStats.hitRate) * 50;
    }

    // Penaliza updates muito demorados
    if (lastUpdateDuration.inSeconds > 5) {
      score -= (lastUpdateDuration.inSeconds - 5) * 2;
    }

    // Penaliza uso excessivo de memória
    if (memoryUsage > 100) {
      score -= (memoryUsage - 100) * 0.5;
    }

    return score.clamp(0, 100);
  }

  String get performanceGrade {
    final score = performanceScore;
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
}

// ========================================
// EXTENSIONS UNIFICADAS
// ========================================

extension UnifiedAppExtensions on WidgetRef {
  /// Estado unificado da aplicação
  UnifiedAppState get appState => watch(unifiedAppProvider);

  /// Contexto do usuário atual
  UserContext? get userContext => watch(userContextProvider);

  /// Estatísticas globais
  GlobalStats get globalStats => watch(globalStatsProvider);

  /// Métricas de performance
  PerformanceMetrics get performanceMetrics =>
      watch(performanceMetricsProvider);

  /// Verifica se a aplicação está inicializada
  bool get isAppInitialized =>
      watch(unifiedAppProvider.select((state) => state.isInitialized));

  /// Verifica se está online
  bool get isOnline =>
      watch(unifiedAppProvider.select((state) => state.isOnline));

  /// Verifica se tem erros
  bool get hasAppErrors =>
      watch(unifiedAppProvider.select((state) => state.hasError));

  /// Lista de erros da aplicação
  List<String> get appErrors =>
      watch(unifiedAppProvider.select((state) => state.errors));

  /// Verifica se está carregando qualquer coisa
  bool get isAppLoading =>
      watch(unifiedAppProvider.select((state) => state.isLoading));

  /// Força refresh de todos os dados
  Future<void> refreshAllData() async {
    await read(unifiedAppProvider.notifier).refreshAll();
  }

  /// Sincroniza dados pendentes
  Future<void> syncPendingData() async {
    await read(unifiedAppProvider.notifier).syncPendingData();
  }

  /// Limpa cache global
  void clearGlobalCache() {
    read(unifiedAppProvider.notifier).clearCache();
  }

  /// Limpa erros da aplicação
  void clearAppErrors() {
    read(unifiedAppProvider.notifier).clearErrors();
  }
}

/// Widget base para telas que usam o sistema unificado
abstract class UnifiedConsumerWidget extends ConsumerWidget {
  const UnifiedConsumerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(unifiedAppProvider);

    // Mostra loading se não inicializado
    if (!appState.isInitialized) {
      return buildLoading(context, ref);
    }

    // Mostra erro se há erro crítico
    if (appState.hasError && shouldShowError(appState.errors)) {
      return buildError(context, ref, appState.errors);
    }

    return buildContent(context, ref, appState);
  }

  /// Constrói o conteúdo principal
  Widget buildContent(
      BuildContext context, WidgetRef ref, UnifiedAppState state);

  /// Constrói tela de loading
  Widget buildLoading(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Constrói tela de erro
  Widget buildError(BuildContext context, WidgetRef ref, List<String> errors) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erro na aplicação:',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...errors.map((error) => Text(error, textAlign: TextAlign.center)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.refreshAllData(),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  /// Define se deve mostrar tela de erro
  bool shouldShowError(List<String> errors) => errors.isNotEmpty;
}

/// Widget para debug do estado da aplicação
class AppStateDebugWidget extends ConsumerWidget {
  const AppStateDebugWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(unifiedAppProvider);
    final globalStats = ref.watch(globalStatsProvider);
    final performance = ref.watch(performanceMetricsProvider);

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('App State Debug',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Initialized: ${appState.isInitialized}'),
            Text('Online: ${appState.isOnline}'),
            Text('Loading: ${appState.isLoading}'),
            Text('Has Errors: ${appState.hasError}'),
            Text('Local Changes: ${appState.hasLocalChanges}'),
            const Divider(),
            Text(
                'Pets: ${globalStats.totalPets} (${globalStats.availablePets} available)'),
            Text(
                'Cache Hit Rate: ${(globalStats.cacheHitRate * 100).toStringAsFixed(1)}%'),
            Text(
                'Performance: ${performance.performanceGrade} (${performance.performanceScore.toStringAsFixed(1)})'),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => ref.refreshAllData(),
                  child: const Text('Refresh'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => ref.clearGlobalCache(),
                  child: const Text('Clear Cache'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
