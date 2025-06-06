// lib/core/performance/performance_monitor.dart
import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Evento de performance
class PerformanceEvent {
  final String name;
  final DateTime timestamp;
  final Duration duration;
  final String type;
  final Map<String, dynamic> metadata;

  PerformanceEvent({
    required this.name,
    required this.timestamp,
    required this.duration,
    required this.type,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration.inMilliseconds,
      'type': type,
      'metadata': metadata,
    };
  }
}

/// Contador de rebuilds para widgets
class RebuildCounter {
  final Map<String, int> _rebuilds = {};
  final Map<String, DateTime> _lastRebuild = {};

  /// Incrementa contador de rebuild
  void increment(String widgetName) {
    _rebuilds[widgetName] = (_rebuilds[widgetName] ?? 0) + 1;
    _lastRebuild[widgetName] = DateTime.now();
  }

  /// Obtém contagem de rebuilds
  int getCount(String widgetName) => _rebuilds[widgetName] ?? 0;

  /// Obtém último rebuild
  DateTime? getLastRebuild(String widgetName) => _lastRebuild[widgetName];

  /// Obtém estatísticas
  Map<String, Map<String, dynamic>> getStats() {
    return _rebuilds.map((key, value) => MapEntry(key, {
          'count': value,
          'lastRebuild': _lastRebuild[key]?.toIso8601String(),
        }));
  }

  /// Limpa estatísticas
  void clear() {
    _rebuilds.clear();
    _lastRebuild.clear();
  }

  /// Obtém widgets com mais rebuilds
  List<MapEntry<String, int>> getTopRebuilds({int limit = 10}) {
    final entries = _rebuilds.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }
}

/// Monitor de performance para providers e widgets
class PerformanceMonitor {
  static final Logger _logger = Logger();
  static PerformanceMonitor? _instance;

  final Queue<PerformanceEvent> _events = Queue();
  final RebuildCounter _rebuildCounter = RebuildCounter();
  final Map<String, Stopwatch> _activeTimers = {};
  final Map<String, int> _providerReads = {};
  final Map<String, int> _providerWrites = {};

  Timer? _frameRateTimer;
  int _frameCount = 0;
  double _averageFrameRate = 60.0;

  bool _isEnabled = kDebugMode;
  int _maxEvents = 1000;

  PerformanceMonitor._();

  /// Singleton instance
  static PerformanceMonitor get instance {
    return _instance ??= PerformanceMonitor._();
  }

  /// Inicializa o monitor
  void initialize({
    bool enabled = true,
    int maxEvents = 1000,
  }) {
    _isEnabled = enabled && kDebugMode;
    _maxEvents = maxEvents;

    if (_isEnabled) {
      _startFrameRateMonitoring();
      _logger.i('Performance Monitor initialized');
    }
  }

  // ========================================
  // MÉTODOS DE MEDIÇÃO
  // ========================================

  /// Inicia medição de tempo
  void startTimer(String name) {
    if (!_isEnabled) return;

    _activeTimers[name] = Stopwatch()..start();
  }

  /// Finaliza medição de tempo
  void stopTimer(String name,
      {String type = 'generic', Map<String, dynamic>? metadata}) {
    if (!_isEnabled) return;

    final stopwatch = _activeTimers.remove(name);
    if (stopwatch != null) {
      stopwatch.stop();

      final event = PerformanceEvent(
        name: name,
        timestamp: DateTime.now(),
        duration: stopwatch.elapsed,
        type: type,
        metadata: metadata ?? {},
      );

      _addEvent(event);

      // Log eventos demorados
      if (stopwatch.elapsedMilliseconds > 100) {
        _logger
            .w('Slow operation: $name took ${stopwatch.elapsedMilliseconds}ms');
      }
    }
  }

  /// Mede duração de uma operação assíncrona
  Future<T> measureAsync<T>(
    String name,
    Future<T> Function() operation, {
    String type = 'async',
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isEnabled) return await operation();

    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      final event = PerformanceEvent(
        name: name,
        timestamp: DateTime.now(),
        duration: stopwatch.elapsed,
        type: type,
        metadata: metadata ?? {},
      );

      _addEvent(event);
      return result;
    } catch (e) {
      stopwatch.stop();

      final event = PerformanceEvent(
        name: '$name (error)',
        timestamp: DateTime.now(),
        duration: stopwatch.elapsed,
        type: 'error',
        metadata: {
          ...?metadata,
          'error': e.toString(),
        },
      );

      _addEvent(event);
      rethrow;
    }
  }

  /// Mede duração de uma operação síncrona
  T measureSync<T>(
    String name,
    T Function() operation, {
    String type = 'sync',
    Map<String, dynamic>? metadata,
  }) {
    if (!_isEnabled) return operation();

    final stopwatch = Stopwatch()..start();

    try {
      final result = operation();
      stopwatch.stop();

      final event = PerformanceEvent(
        name: name,
        timestamp: DateTime.now(),
        duration: stopwatch.elapsed,
        type: type,
        metadata: metadata ?? {},
      );

      _addEvent(event);
      return result;
    } catch (e) {
      stopwatch.stop();

      final event = PerformanceEvent(
        name: '$name (error)',
        timestamp: DateTime.now(),
        duration: stopwatch.elapsed,
        type: 'error',
        metadata: {
          ...?metadata,
          'error': e.toString(),
        },
      );

      _addEvent(event);
      rethrow;
    }
  }

  // ========================================
  // MEDIÇÃO DE REBUILDS
  // ========================================

  /// Registra rebuild de widget
  void recordRebuild(String widgetName, {Map<String, dynamic>? context}) {
    if (!_isEnabled) return;

    _rebuildCounter.increment(widgetName);

    final event = PerformanceEvent(
      name: 'Widget Rebuild',
      timestamp: DateTime.now(),
      duration: Duration.zero,
      type: 'rebuild',
      metadata: {
        'widget': widgetName,
        'count': _rebuildCounter.getCount(widgetName),
        ...?context,
      },
    );

    _addEvent(event);
  }

  /// Registra leitura de provider
  void recordProviderRead(String providerName) {
    if (!_isEnabled) return;

    _providerReads[providerName] = (_providerReads[providerName] ?? 0) + 1;
  }

  /// Registra escrita em provider
  void recordProviderWrite(String providerName, {Map<String, dynamic>? data}) {
    if (!_isEnabled) return;

    _providerWrites[providerName] = (_providerWrites[providerName] ?? 0) + 1;

    final event = PerformanceEvent(
      name: 'Provider Update',
      timestamp: DateTime.now(),
      duration: Duration.zero,
      type: 'provider_write',
      metadata: {
        'provider': providerName,
        'writes': _providerWrites[providerName],
        ...?data,
      },
    );

    _addEvent(event);
  }

  // ========================================
  // ANÁLISE DE PERFORMANCE
  // ========================================

  /// Obtém estatísticas gerais
  PerformanceStats getStats() {
    final now = DateTime.now();
    final lastMinute = now.subtract(const Duration(minutes: 1));
    final lastHour = now.subtract(const Duration(hours: 1));

    final recentEvents =
        _events.where((e) => e.timestamp.isAfter(lastMinute)).toList();
    final hourlyEvents =
        _events.where((e) => e.timestamp.isAfter(lastHour)).toList();

    // Calcula médias de duração por tipo
    final avgDurations = <String, double>{};
    final eventsByType = <String, List<PerformanceEvent>>{};

    for (final event in recentEvents) {
      eventsByType.putIfAbsent(event.type, () => []).add(event);
    }

    for (final entry in eventsByType.entries) {
      final events = entry.value;
      final totalDuration = events.fold<int>(
        0,
        (sum, event) => sum + event.duration.inMilliseconds,
      );
      avgDurations[entry.key] = totalDuration / events.length;
    }

    return PerformanceStats(
      totalEvents: _events.length,
      recentEvents: recentEvents.length,
      hourlyEvents: hourlyEvents.length,
      averageFrameRate: _averageFrameRate,
      averageDurations: avgDurations,
      rebuildsStats: _rebuildCounter.getStats(),
      topRebuilds: _rebuildCounter.getTopRebuilds(),
      providerReads: Map.from(_providerReads),
      providerWrites: Map.from(_providerWrites),
    );
  }

  /// Obtém eventos recentes
  List<PerformanceEvent> getRecentEvents({Duration? within}) {
    final cutoff =
        DateTime.now().subtract(within ?? const Duration(minutes: 5));
    return _events.where((e) => e.timestamp.isAfter(cutoff)).toList();
  }

  /// Obtém eventos por tipo
  List<PerformanceEvent> getEventsByType(String type) {
    return _events.where((e) => e.type == type).toList();
  }

  /// Obtém eventos mais demorados
  List<PerformanceEvent> getSlowestEvents({int limit = 10}) {
    final events = _events.toList();
    events.sort((a, b) => b.duration.compareTo(a.duration));
    return events.take(limit).toList();
  }

  /// Detecta problemas de performance
  List<PerformanceIssue> detectIssues() {
    final issues = <PerformanceIssue>[];

    // Verifica frame rate baixo
    if (_averageFrameRate < 50) {
      issues.add(PerformanceIssue(
        type: PerformanceIssueType.lowFrameRate,
        severity: PerformanceIssueSeverity.warning,
        description:
            'Frame rate baixo: ${_averageFrameRate.toStringAsFixed(1)} FPS',
        suggestion: 'Verifique rebuilds desnecessários e operações pesadas',
      ));
    }

    // Verifica operações lentas
    final slowEvents =
        _events.where((e) => e.duration.inMilliseconds > 100).toList();
    if (slowEvents.isNotEmpty) {
      issues.add(PerformanceIssue(
        type: PerformanceIssueType.slowOperations,
        severity: PerformanceIssueSeverity.error,
        description: '${slowEvents.length} operações lentas detectadas',
        suggestion: 'Otimize as operações mais demoradas',
      ));
    }

    // Verifica rebuilds excessivos
    final topRebuilds = _rebuildCounter.getTopRebuilds(limit: 5);
    for (final entry in topRebuilds) {
      if (entry.value > 50) {
        issues.add(PerformanceIssue(
          type: PerformanceIssueType.excessiveRebuilds,
          severity: PerformanceIssueSeverity.warning,
          description: '${entry.key} teve ${entry.value} rebuilds',
          suggestion: 'Use selectors específicos ou memo',
        ));
      }
    }

    return issues;
  }

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  /// Adiciona evento à lista
  void _addEvent(PerformanceEvent event) {
    _events.add(event);

    // Remove eventos antigos se necessário
    while (_events.length > _maxEvents) {
      _events.removeFirst();
    }
  }

  /// Inicia monitoramento de frame rate
  void _startFrameRateMonitoring() {
    _frameRateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _averageFrameRate = _frameCount.toDouble();
      _frameCount = 0;
    });

    // Conta frames
    SchedulerBinding.instance.addPersistentFrameCallback((_) {
      _frameCount++;
    });
  }

  /// Limpa dados
  void clear() {
    _events.clear();
    _rebuildCounter.clear();
    _activeTimers.clear();
    _providerReads.clear();
    _providerWrites.clear();
  }

  /// Para o monitor
  void dispose() {
    _frameRateTimer?.cancel();
    clear();
  }
}

/// Estatísticas de performance
class PerformanceStats {
  final int totalEvents;
  final int recentEvents;
  final int hourlyEvents;
  final double averageFrameRate;
  final Map<String, double> averageDurations;
  final Map<String, Map<String, dynamic>> rebuildsStats;
  final List<MapEntry<String, int>> topRebuilds;
  final Map<String, int> providerReads;
  final Map<String, int> providerWrites;

  const PerformanceStats({
    required this.totalEvents,
    required this.recentEvents,
    required this.hourlyEvents,
    required this.averageFrameRate,
    required this.averageDurations,
    required this.rebuildsStats,
    required this.topRebuilds,
    required this.providerReads,
    required this.providerWrites,
  });

  /// Score de performance (0-100)
  double get performanceScore {
    var score = 100.0;

    // Penaliza frame rate baixo
    if (averageFrameRate < 60) {
      score -= (60 - averageFrameRate) * 2;
    }

    // Penaliza rebuilds excessivos
    final excessiveRebuilds = topRebuilds.where((e) => e.value > 20).length;
    score -= excessiveRebuilds * 10;

    // Penaliza operações lentas
    final slowOps = averageDurations.values.where((d) => d > 50).length;
    score -= slowOps * 15;

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
      'totalEvents': totalEvents,
      'recentEvents': recentEvents,
      'hourlyEvents': hourlyEvents,
      'averageFrameRate': averageFrameRate,
      'averageDurations': averageDurations,
      'topRebuilds':
          topRebuilds.map((e) => {'widget': e.key, 'count': e.value}).toList(),
      'providerReads': providerReads,
      'providerWrites': providerWrites,
      'performanceScore': performanceScore,
      'performanceGrade': performanceGrade,
    };
  }
}

/// Problema de performance detectado
class PerformanceIssue {
  final PerformanceIssueType type;
  final PerformanceIssueSeverity severity;
  final String description;
  final String suggestion;

  const PerformanceIssue({
    required this.type,
    required this.severity,
    required this.description,
    required this.suggestion,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'severity': severity.name,
      'description': description,
      'suggestion': suggestion,
    };
  }
}

enum PerformanceIssueType {
  lowFrameRate,
  slowOperations,
  excessiveRebuilds,
  memoryLeak,
  providerOveruse,
}

enum PerformanceIssueSeverity {
  info,
  warning,
  error,
  critical,
}

// ========================================
// WIDGETS E MIXINS PARA MEDIÇÃO
// ========================================

/// Mixin para medir rebuilds automaticamente
mixin PerformanceMixin<T extends StatefulWidget> on State<T> {
  late final String _widgetName;

  @override
  void initState() {
    super.initState();
    _widgetName = widget.runtimeType.toString();
  }

  @override
  Widget build(BuildContext context) {
    PerformanceMonitor.instance.recordRebuild(_widgetName, context: {
      'hasContext': true,
      'timestamp': DateTime.now().toIso8601String(),
    });

    return buildWithPerformance(context);
  }

  /// Implementado pelas classes filhas
  Widget buildWithPerformance(BuildContext context);
}

/// Mixin para Consumer widgets
mixin ConsumerPerformanceMixin<T extends ConsumerWidget> on ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final widgetName = runtimeType.toString();
    PerformanceMonitor.instance.recordRebuild(widgetName);

    return buildWithPerformance(context, ref);
  }

  /// Implementado pelas classes filhas
  Widget buildWithPerformance(BuildContext context, WidgetRef ref);
}

/// Provider observer para medir performance
class PerformanceProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    PerformanceMonitor.instance.recordProviderWrite(
      provider.name ?? provider.runtimeType.toString(),
      data: {
        'hasNewValue': newValue != null,
        'valueChanged': previousValue != newValue,
      },
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    // Log disposal para detectar vazamentos
    PerformanceMonitor.instance.measureSync(
      'Provider Disposal: ${provider.name ?? provider.runtimeType.toString()}',
      () => {},
      type: 'disposal',
    );
  }
}

// ========================================
// PROVIDERS
// ========================================

/// Provider para monitor de performance
final performanceMonitorProvider = Provider<PerformanceMonitor>((ref) {
  return PerformanceMonitor.instance;
});

/// Provider para estatísticas atuais
final performanceStatsProvider = Provider<PerformanceStats>((ref) {
  final monitor = ref.watch(performanceMonitorProvider);
  return monitor.getStats();
});

/// Provider para problemas detectados
final performanceIssuesProvider = Provider<List<PerformanceIssue>>((ref) {
  final monitor = ref.watch(performanceMonitorProvider);
  return monitor.detectIssues();
});

/// Provider para eventos recentes
final recentPerformanceEventsProvider = Provider<List<PerformanceEvent>>((ref) {
  final monitor = ref.watch(performanceMonitorProvider);
  return monitor.getRecentEvents();
});

// ========================================
// EXTENSIONS
// ========================================

extension PerformanceExtensions on WidgetRef {
  /// Mede operação assíncrona
  Future<T> measureAsync<T>(String name, Future<T> Function() operation) {
    return PerformanceMonitor.instance.measureAsync(name, operation);
  }

  /// Mede operação síncrona
  T measureSync<T>(String name, T Function() operation) {
    return PerformanceMonitor.instance.measureSync(name, operation);
  }

  /// Registra rebuild manual
  void recordRebuild(String widgetName) {
    PerformanceMonitor.instance.recordRebuild(widgetName);
  }

  /// Obtém estatísticas de performance
  PerformanceStats get performanceStats => watch(performanceStatsProvider);

  /// Obtém problemas de performance
  List<PerformanceIssue> get performanceIssues =>
      watch(performanceIssuesProvider);

  /// Limpa dados de performance
  void clearPerformanceData() {
    PerformanceMonitor.instance.clear();
  }
}
