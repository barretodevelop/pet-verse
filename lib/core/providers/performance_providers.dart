// lib/core/providers/performance_providers.dart
import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../cache/provider_cache.dart';

/// Métricas de rebuild de widgets
class RebuildMetrics {
  final String widgetName;
  final int rebuildCount;
  final DateTime lastRebuild;
  final Duration averageRebuildTime;
  final List<DateTime> rebuildHistory;

  const RebuildMetrics({
    required this.widgetName,
    required this.rebuildCount,
    required this.lastRebuild,
    required this.averageRebuildTime,
    required this.rebuildHistory,
  });

  RebuildMetrics copyWith({
    int? rebuildCount,
    DateTime? lastRebuild,
    Duration? averageRebuildTime,
    List<DateTime>? rebuildHistory,
  }) {
    return RebuildMetrics(
      widgetName: widgetName,
      rebuildCount: rebuildCount ?? this.rebuildCount,
      lastRebuild: lastRebuild ?? this.lastRebuild,
      averageRebuildTime: averageRebuildTime ?? this.averageRebuildTime,
      rebuildHistory: rebuildHistory ?? this.rebuildHistory,
    );
  }

  /// Taxa de rebuilds por minuto
  double get rebuildRate {
    if (rebuildHistory.length < 2) return 0.0;

    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(minutes: 1));

    final recentRebuilds = rebuildHistory
        .where(
          (rebuild) => rebuild.isAfter(oneMinuteAgo),
        )
        .length;

    return recentRebuilds.toDouble();
  }

  /// Verifica se está rebuilding excessivamente
  bool get isExcessiveRebuilding => rebuildRate > 30; // Mais de 30 rebuilds/min

  Map<String, dynamic> toJson() {
    return {
      'widgetName': widgetName,
      'rebuildCount': rebuildCount,
      'lastRebuild': lastRebuild.toIso8601String(),
      'averageRebuildTime': averageRebuildTime.inMilliseconds,
      'rebuildRate': rebuildRate,
      'isExcessiveRebuilding': isExcessiveRebuilding,
    };
  }
}

/// Monitor de performance de providers
class ProviderPerformanceMonitor {
  static final Logger _logger = Logger();
  static ProviderPerformanceMonitor? _instance;

  final Map<String, RebuildMetrics> _rebuildMetrics = {};
  final Map<String, Stopwatch> _activeStopwatches = {};
  final Queue<String> _recentEvents = Queue();

  Timer? _cleanupTimer;
  bool _isEnabled = kDebugMode;

  ProviderPerformanceMonitor._() {
    _startCleanupTimer();
  }

  static ProviderPerformanceMonitor get instance {
    return _instance ??= ProviderPerformanceMonitor._();
  }

  /// Habilita/desabilita monitoramento
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      clear();
    }
  }

  /// Inicia medição de rebuild
  void startRebuildMeasurement(String widgetName) {
    if (!_isEnabled) return;

    final stopwatch = Stopwatch()..start();
    _activeStopwatches[widgetName] = stopwatch;
  }

  /// Finaliza medição de rebuild
  void endRebuildMeasurement(String widgetName) {
    if (!_isEnabled) return;

    final stopwatch = _activeStopwatches.remove(widgetName);
    if (stopwatch == null) return;

    stopwatch.stop();
    final duration = stopwatch.elapsed;
    final now = DateTime.now();

    // Atualiza métricas
    final existing = _rebuildMetrics[widgetName];

    if (existing == null) {
      _rebuildMetrics[widgetName] = RebuildMetrics(
        widgetName: widgetName,
        rebuildCount: 1,
        lastRebuild: now,
        averageRebuildTime: duration,
        rebuildHistory: [now],
      );
    } else {
      final newHistory = [...existing.rebuildHistory, now];

      // Mantém apenas últimos 100 rebuilds
      if (newHistory.length > 100) {
        newHistory.removeAt(0);
      }

      // Calcula nova média
      final totalDuration =
          existing.averageRebuildTime * existing.rebuildCount + duration;
      final newCount = existing.rebuildCount + 1;
      final newAverage =
          Duration(microseconds: totalDuration.inMicroseconds ~/ newCount);

      _rebuildMetrics[widgetName] = existing.copyWith(
        rebuildCount: newCount,
        lastRebuild: now,
        averageRebuildTime: newAverage,
        rebuildHistory: newHistory,
      );
    }

    // Log se está rebuilding excessivamente
    final metrics = _rebuildMetrics[widgetName]!;
    if (metrics.isExcessiveRebuilding) {
      _logger.w(
          'Excessive rebuilding detected: $widgetName (${metrics.rebuildRate}/min)');
    }

    // Adiciona evento recente
    _recentEvents.add('$widgetName rebuilt in ${duration.inMilliseconds}ms');
    if (_recentEvents.length > 50) {
      _recentEvents.removeFirst();
    }
  }

  /// Obtém métricas de um widget específico
  RebuildMetrics? getMetrics(String widgetName) {
    return _rebuildMetrics[widgetName];
  }

  /// Obtém todas as métricas
  Map<String, RebuildMetrics> getAllMetrics() {
    return Map.unmodifiable(_rebuildMetrics);
  }

  /// Obtém widgets com rebuilding excessivo
  List<RebuildMetrics> getExcessiveRebuildingWidgets() {
    return _rebuildMetrics.values
        .where((metrics) => metrics.isExcessiveRebuilding)
        .toList();
  }

  /// Obtém eventos recentes
  List<String> getRecentEvents() {
    return _recentEvents.toList();
  }

  /// Obtém estatísticas gerais
  PerformanceStats getOverallStats() {
    if (_rebuildMetrics.isEmpty) {
      return const PerformanceStats(
        totalWidgets: 0,
        totalRebuilds: 0,
        averageRebuildTime: Duration.zero,
        excessiveRebuildingWidgets: 0,
      );
    }

    final totalRebuilds = _rebuildMetrics.values
        .map((m) => m.rebuildCount)
        .reduce((a, b) => a + b);

    final averageTime = Duration(
      microseconds: _rebuildMetrics.values
              .map((m) => m.averageRebuildTime.inMicroseconds)
              .reduce((a, b) => a + b) ~/
          _rebuildMetrics.length,
    );

    final excessiveCount =
        _rebuildMetrics.values.where((m) => m.isExcessiveRebuilding).length;

    return PerformanceStats(
      totalWidgets: _rebuildMetrics.length,
      totalRebuilds: totalRebuilds,
      averageRebuildTime: averageTime,
      excessiveRebuildingWidgets: excessiveCount,
    );
  }

  /// Limpa métricas antigas
  void _performCleanup() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));

    _rebuildMetrics.removeWhere((name, metrics) {
      return metrics.lastRebuild.isBefore(cutoff);
    });

    _logger.d('Performance monitor cleanup completed');
  }

  /// Inicia timer de limpeza
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      _performCleanup();
    });
  }

  /// Limpa todas as métricas
  void clear() {
    _rebuildMetrics.clear();
    _activeStopwatches.clear();
    _recentEvents.clear();
  }

  /// Dispose
  void dispose() {
    _cleanupTimer?.cancel();
    clear();
  }
}

/// Estatísticas gerais de performance
class PerformanceStats {
  final int totalWidgets;
  final int totalRebuilds;
  final Duration averageRebuildTime;
  final int excessiveRebuildingWidgets;

  const PerformanceStats({
    required this.totalWidgets,
    required this.totalRebuilds,
    required this.averageRebuildTime,
    required this.excessiveRebuildingWidgets,
  });

  /// Performance score (0-100)
  double get performanceScore {
    if (totalWidgets == 0) return 100.0;

    var score = 100.0;

    // Penaliza widgets com rebuilding excessivo
    final excessivePercentage = excessiveRebuildingWidgets / totalWidgets;
    score -= excessivePercentage * 50;

    // Penaliza tempo médio de rebuild alto
    if (averageRebuildTime.inMilliseconds > 16) {
      // 60fps = 16ms por frame
      score -= (averageRebuildTime.inMilliseconds - 16) * 2;
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

  Map<String, dynamic> toJson() {
    return {
      'totalWidgets': totalWidgets,
      'totalRebuilds': totalRebuilds,
      'averageRebuildTime': averageRebuildTime.inMilliseconds,
      'excessiveRebuildingWidgets': excessiveRebuildingWidgets,
      'performanceScore': performanceScore,
      'performanceGrade': performanceGrade,
    };
  }
}

/// Provider para monitoramento de performance
final performanceMonitorProvider = Provider<ProviderPerformanceMonitor>((ref) {
  return ProviderPerformanceMonitor.instance;
});

/// Provider para métricas de rebuild
final rebuildMetricsProvider = Provider<Map<String, RebuildMetrics>>((ref) {
  final monitor = ref.watch(performanceMonitorProvider);
  return monitor.getAllMetrics();
});

/// Provider para estatísticas de performance
final performanceStatsProvider = Provider<PerformanceStats>((ref) {
  final monitor = ref.watch(performanceMonitorProvider);
  return monitor.getOverallStats();
});

/// Provider para widgets com rebuilding excessivo
final excessiveRebuildingProvider = Provider<List<RebuildMetrics>>((ref) {
  final monitor = ref.watch(performanceMonitorProvider);
  return monitor.getExcessiveRebuildingWidgets();
});

/// Provider para eventos recentes
final recentPerformanceEventsProvider = Provider<List<String>>((ref) {
  final monitor = ref.watch(performanceMonitorProvider);
  return monitor.getRecentEvents();
});

/// Mixin para widgets que querem ser monitorados
mixin PerformanceMonitorMixin<T extends ConsumerWidget> on ConsumerWidget {
  String get monitoredWidgetName => T.toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDebugMode) {
      final monitor = ref.read(performanceMonitorProvider);
      monitor.startRebuildMeasurement(monitoredWidgetName);

      // Build o widget
      final result = buildMonitored(context, ref);

      // Finaliza medição após o próximo frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        monitor.endRebuildMeasurement(monitoredWidgetName);
      });

      return result;
    } else {
      return buildMonitored(context, ref);
    }
  }

  /// Método que deve ser implementado em vez de build()
  Widget buildMonitored(BuildContext context, WidgetRef ref);
}

/// StateNotifier para configurações de performance
class PerformanceSettingsNotifier extends StateNotifier<PerformanceSettings> {
  static final Logger _logger = Logger();

  PerformanceSettingsNotifier() : super(const PerformanceSettings()) {
    _applySettings();
  }

  void toggleMonitoring() {
    state = state.copyWith(monitoringEnabled: !state.monitoringEnabled);
    _applySettings();
  }

  void toggleCacheOptimization() {
    state = state.copyWith(
        cacheOptimizationEnabled: !state.cacheOptimizationEnabled);
    _applySettings();
  }

  void toggleSelectorOptimization() {
    state = state.copyWith(
        selectorOptimizationEnabled: !state.selectorOptimizationEnabled);
    _applySettings();
  }

  void setRebuildThreshold(double threshold) {
    state = state.copyWith(rebuildThreshold: threshold);
    _applySettings();
  }

  void _applySettings() {
    // Aplica configurações ao monitor de performance
    ProviderPerformanceMonitor.instance.setEnabled(state.monitoringEnabled);

    _logger.d('Performance settings applied: ${state.toJson()}');
  }
}

/// Configurações de performance
class PerformanceSettings {
  final bool monitoringEnabled;
  final bool cacheOptimizationEnabled;
  final bool selectorOptimizationEnabled;
  final double rebuildThreshold;

  const PerformanceSettings({
    this.monitoringEnabled = true,
    this.cacheOptimizationEnabled = true,
    this.selectorOptimizationEnabled = true,
    this.rebuildThreshold = 30.0, // rebuilds per minute
  });

  PerformanceSettings copyWith({
    bool? monitoringEnabled,
    bool? cacheOptimizationEnabled,
    bool? selectorOptimizationEnabled,
    double? rebuildThreshold,
  }) {
    return PerformanceSettings(
      monitoringEnabled: monitoringEnabled ?? this.monitoringEnabled,
      cacheOptimizationEnabled:
          cacheOptimizationEnabled ?? this.cacheOptimizationEnabled,
      selectorOptimizationEnabled:
          selectorOptimizationEnabled ?? this.selectorOptimizationEnabled,
      rebuildThreshold: rebuildThreshold ?? this.rebuildThreshold,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monitoringEnabled': monitoringEnabled,
      'cacheOptimizationEnabled': cacheOptimizationEnabled,
      'selectorOptimizationEnabled': selectorOptimizationEnabled,
      'rebuildThreshold': rebuildThreshold,
    };
  }
}

/// Provider para configurações de performance
final performanceSettingsProvider =
    StateNotifierProvider<PerformanceSettingsNotifier, PerformanceSettings>(
        (ref) {
  return PerformanceSettingsNotifier();
});

/// Provider combinado de performance e cache
final combinedPerformanceProvider = Provider<CombinedPerformanceMetrics>((ref) {
  final performanceStats = ref.watch(performanceStatsProvider);
  final cacheStats = ref.watch(cacheStatsProvider);
  final settings = ref.watch(performanceSettingsProvider);

  return CombinedPerformanceMetrics(
    performanceStats: performanceStats,
    cacheStats: cacheStats,
    settings: settings,
  );
});

/// Métricas combinadas de performance
class CombinedPerformanceMetrics {
  final PerformanceStats performanceStats;
  final CacheStats cacheStats;
  final PerformanceSettings settings;

  const CombinedPerformanceMetrics({
    required this.performanceStats,
    required this.cacheStats,
    required this.settings,
  });

  /// Score geral de otimização (0-100)
  double get overallOptimizationScore {
    const performanceWeight = 0.4;
    const cacheWeight = 0.4;
    const configWeight = 0.2;

    final performanceScore = performanceStats.performanceScore;
    final cacheScore = cacheStats.hitRate * 100;
    final configScore = _getConfigurationScore();

    return (performanceScore * performanceWeight +
            cacheScore * cacheWeight +
            configScore * configWeight)
        .clamp(0, 100);
  }

  double _getConfigurationScore() {
    var score = 0.0;
    if (settings.cacheOptimizationEnabled) score += 25;
    if (settings.selectorOptimizationEnabled) score += 25;
    if (settings.monitoringEnabled) score += 25;
    if (settings.rebuildThreshold <= 30) score += 25;
    return score;
  }

  /// Recomendações de otimização
  List<String> get optimizationRecommendations {
    final recommendations = <String>[];

    // Recomendações baseadas em performance
    if (performanceStats.excessiveRebuildingWidgets > 0) {
      recommendations.add(
          'Otimize ${performanceStats.excessiveRebuildingWidgets} widgets com rebuilding excessivo');
    }

    if (performanceStats.averageRebuildTime.inMilliseconds > 16) {
      recommendations.add(
          'Reduza o tempo médio de rebuild de ${performanceStats.averageRebuildTime.inMilliseconds}ms');
    }

    // Recomendações baseadas em cache
    if (cacheStats.hitRate < 0.8) {
      recommendations.add(
          'Melhore a taxa de hit do cache (atual: ${(cacheStats.hitRate * 100).toStringAsFixed(1)}%)');
    }

    if (cacheStats.expiredEntries > cacheStats.validEntries) {
      recommendations.add('Ajuste TTL do cache para reduzir expirações');
    }

    // Recomendações baseadas em configuração
    if (!settings.cacheOptimizationEnabled) {
      recommendations.add('Habilite otimização de cache');
    }

    if (!settings.selectorOptimizationEnabled) {
      recommendations.add('Habilite otimização de selectors');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Sistema bem otimizado! 🎉');
    }

    return recommendations;
  }

  Map<String, dynamic> toJson() {
    return {
      'overallOptimizationScore': overallOptimizationScore,
      'performanceStats': performanceStats.toJson(),
      'cacheStats': cacheStats.toJson(),
      'settings': settings.toJson(),
      'recommendations': optimizationRecommendations,
    };
  }
}

/// Extensions para facilitar uso do monitoramento
extension PerformanceProviderExtensions on WidgetRef {
  /// Obtém métricas de um widget específico
  RebuildMetrics? getWidgetMetrics(String widgetName) {
    return read(performanceMonitorProvider).getMetrics(widgetName);
  }

  /// Obtém estatísticas de performance
  PerformanceStats get performanceStats => watch(performanceStatsProvider);

  /// Obtém métricas combinadas
  CombinedPerformanceMetrics get combinedMetrics =>
      watch(combinedPerformanceProvider);

  /// Verifica se um widget está com rebuilding excessivo
  bool isWidgetRebuildingExcessively(String widgetName) {
    final metrics = getWidgetMetrics(widgetName);
    return metrics?.isExcessiveRebuilding ?? false;
  }

  /// Força limpeza de métricas de performance
  void clearPerformanceMetrics() {
    read(performanceMonitorProvider).clear();
  }

  /// Habilita/desabilita monitoramento
  void togglePerformanceMonitoring() {
    read(performanceSettingsProvider.notifier).toggleMonitoring();
  }
}
