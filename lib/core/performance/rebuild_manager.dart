// lib/core/performance/rebuild_manager.dart
import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

/// Informações sobre rebuild de um widget
class RebuildInfo {
  final String widgetName;
  final DateTime timestamp;
  final String reason;
  final Map<String, dynamic> metadata;

  const RebuildInfo({
    required this.widgetName,
    required this.timestamp,
    required this.reason,
    this.metadata = const {},
  });

  Duration get age => DateTime.now().difference(timestamp);

  Map<String, dynamic> toJson() {
    return {
      'widgetName': widgetName,
      'timestamp': timestamp.toIso8601String(),
      'reason': reason,
      'age': age.inMilliseconds,
      'metadata': metadata,
    };
  }
}

/// Estatísticas de rebuild
class RebuildStats {
  final int totalRebuilds;
  final Map<String, int> rebuildsByWidget;
  final Map<String, int> rebuildsByReason;
  final double averageRebuildsPerMinute;
  final List<RebuildInfo> recentRebuilds;

  const RebuildStats({
    required this.totalRebuilds,
    required this.rebuildsByWidget,
    required this.rebuildsByReason,
    required this.averageRebuildsPerMinute,
    required this.recentRebuilds,
  });

  /// Widgets mais problemáticos
  List<MapEntry<String, int>> get topRebuildingWidgets {
    final sorted = rebuildsByWidget.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(10).toList();
  }

  /// Principais causas de rebuild
  List<MapEntry<String, int>> get topRebuildReasons {
    final sorted = rebuildsByReason.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  /// Score de performance (0-100, maior é melhor)
  double get performanceScore {
    if (totalRebuilds == 0) return 100;

    // Penaliza muitos rebuilds
    var score = 100.0;
    if (averageRebuildsPerMinute > 10) {
      score -= (averageRebuildsPerMinute - 10) * 2;
    }

    // Penaliza widgets com muitos rebuilds
    final maxWidgetRebuilds =
        rebuildsByWidget.values.fold(0, (a, b) => a > b ? a : b);
    if (maxWidgetRebuilds > 50) {
      score -= (maxWidgetRebuilds - 50) * 0.5;
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

/// Gerenciador de rebuilds para monitoramento de performance
class RebuildManager {
  static final Logger _logger = Logger();
  static RebuildManager? _instance;

  final Queue<RebuildInfo> _rebuildHistory = Queue<RebuildInfo>();
  final Map<String, int> _rebuildsByWidget = <String, int>{};
  final Map<String, int> _rebuildsByReason = <String, int>{};
  final Map<String, DateTime> _lastRebuildByWidget = <String, DateTime>{};

  Timer? _cleanupTimer;
  bool _isEnabled = false;

  static const int _maxHistorySize = 1000;
  static const Duration _historyRetention = Duration(minutes: 30);

  RebuildManager._() {
    _startCleanupTimer();
  }

  /// Singleton instance
  static RebuildManager get instance {
    return _instance ??= RebuildManager._();
  }

  /// Habilita/desabilita o monitoramento
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (enabled) {
      _logger.d('Rebuild monitoring enabled');
    } else {
      _logger.d('Rebuild monitoring disabled');
      clear();
    }
  }

  /// Registra um rebuild
  void recordRebuild({
    required String widgetName,
    required String reason,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isEnabled) return;

    final rebuildInfo = RebuildInfo(
      widgetName: widgetName,
      timestamp: DateTime.now(),
      reason: reason,
      metadata: metadata ?? {},
    );

    _rebuildHistory.add(rebuildInfo);
    _rebuildsByWidget[widgetName] = (_rebuildsByWidget[widgetName] ?? 0) + 1;
    _rebuildsByReason[reason] = (_rebuildsByReason[reason] ?? 0) + 1;
    _lastRebuildByWidget[widgetName] = rebuildInfo.timestamp;

    // Limita o tamanho do histórico
    while (_rebuildHistory.length > _maxHistorySize) {
      _rebuildHistory.removeFirst();
    }

    // Log para widgets problemáticos
    final widgetRebuilds = _rebuildsByWidget[widgetName] ?? 0;
    if (widgetRebuilds > 0 && widgetRebuilds % 20 == 0) {
      _logger.w('Widget $widgetName has rebuilt $widgetRebuilds times');
    }
  }

  /// Obtém estatísticas atuais
  RebuildStats getStats() {
    final now = DateTime.now();
    final recentRebuilds = _rebuildHistory
        .where((rebuild) =>
            now.difference(rebuild.timestamp) < const Duration(minutes: 5))
        .toList();

    final totalInLastMinute = _rebuildHistory
        .where((rebuild) =>
            now.difference(rebuild.timestamp) < const Duration(minutes: 1))
        .length;

    return RebuildStats(
      totalRebuilds: _rebuildHistory.length,
      rebuildsByWidget: Map.from(_rebuildsByWidget),
      rebuildsByReason: Map.from(_rebuildsByReason),
      averageRebuildsPerMinute: totalInLastMinute.toDouble(),
      recentRebuilds: recentRebuilds,
    );
  }

  /// Obtém histórico de um widget específico
  List<RebuildInfo> getWidgetHistory(String widgetName) {
    return _rebuildHistory
        .where((rebuild) => rebuild.widgetName == widgetName)
        .toList();
  }

  /// Verifica se um widget está sendo rebuild frequentemente
  bool isWidgetRebuildingFrequently(String widgetName) {
    final lastRebuild = _lastRebuildByWidget[widgetName];
    if (lastRebuild == null) return false;

    final timeSinceLastRebuild = DateTime.now().difference(lastRebuild);
    final totalRebuilds = _rebuildsByWidget[widgetName] ?? 0;

    // Widget problemático se: rebuild nos últimos 5 segundos OU mais de 10 rebuilds total
    return timeSinceLastRebuild < const Duration(seconds: 5) ||
        totalRebuilds > 10;
  }

  /// Limpa dados antigos
  void _cleanup() {
    final cutoff = DateTime.now().subtract(_historyRetention);

    // Remove rebuilds antigos
    _rebuildHistory
        .removeWhere((rebuild) => rebuild.timestamp.isBefore(cutoff));

    // Recomputa estatísticas
    _rebuildsByWidget.clear();
    _rebuildsByReason.clear();

    for (final rebuild in _rebuildHistory) {
      _rebuildsByWidget[rebuild.widgetName] =
          (_rebuildsByWidget[rebuild.widgetName] ?? 0) + 1;
      _rebuildsByReason[rebuild.reason] =
          (_rebuildsByReason[rebuild.reason] ?? 0) + 1;
    }
  }

  /// Inicia timer de limpeza
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanup();
    });
  }

  /// Limpa todos os dados
  void clear() {
    _rebuildHistory.clear();
    _rebuildsByWidget.clear();
    _rebuildsByReason.clear();
    _lastRebuildByWidget.clear();
  }

  /// Dispose
  void dispose() {
    _cleanupTimer?.cancel();
    clear();
  }
}

/// Mixin para widgets que querem monitorar rebuilds
mixin RebuildMonitorMixin<T extends StatefulWidget> on State<T> {
  late final String _widgetName;
  int _rebuildCount = 0;

  @override
  void initState() {
    super.initState();
    _widgetName = widget.runtimeType.toString();
    _recordRebuild('initState');
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _recordRebuild('didUpdateWidget');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _recordRebuild('didChangeDependencies');
  }

  @override
  Widget build(BuildContext context) {
    _rebuildCount++;
    _recordRebuild('build');
    return buildWithMonitoring(context);
  }

  /// Método que as subclasses devem implementar ao invés de build
  Widget buildWithMonitoring(BuildContext context);

  void _recordRebuild(String reason) {
    RebuildManager.instance.recordRebuild(
      widgetName: _widgetName,
      reason: reason,
      metadata: {
        'rebuildCount': _rebuildCount,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }
}

/// Mixin para ConsumerWidget que monitora rebuilds
mixin ConsumerRebuildMonitorMixin<T extends ConsumerWidget> on ConsumerWidget {
  String get widgetName => runtimeType.toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    RebuildManager.instance.recordRebuild(
      widgetName: widgetName,
      reason: 'provider_change',
      metadata: {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );

    return buildWithMonitoring(context, ref);
  }

  /// Método que as subclasses devem implementar
  Widget buildWithMonitoring(BuildContext context, WidgetRef ref);
}

/// Widget wrapper que monitora rebuilds automaticamente
class RebuildMonitorWrapper extends StatefulWidget {
  final Widget child;
  final String? name;
  final void Function(RebuildInfo)? onRebuild;

  const RebuildMonitorWrapper({
    super.key,
    required this.child,
    this.name,
    this.onRebuild,
  });

  @override
  State<RebuildMonitorWrapper> createState() => _RebuildMonitorWrapperState();
}

class _RebuildMonitorWrapperState extends State<RebuildMonitorWrapper>
    with RebuildMonitorMixin {
  @override
  Widget buildWithMonitoring(BuildContext context) {
    final rebuildInfo = RebuildInfo(
      widgetName: widget.name ?? widget.child.runtimeType.toString(),
      timestamp: DateTime.now(),
      reason: 'wrapper_build',
    );

    widget.onRebuild?.call(rebuildInfo);

    return widget.child;
  }
}

/// Widget para exibir estatísticas de rebuild (debug)
class RebuildStatsWidget extends StatefulWidget {
  final bool showDetails;

  const RebuildStatsWidget({
    super.key,
    this.showDetails = false,
  });

  @override
  State<RebuildStatsWidget> createState() => _RebuildStatsWidgetState();
}

class _RebuildStatsWidgetState extends State<RebuildStatsWidget> {
  Timer? _updateTimer;
  RebuildStats? _stats;

  @override
  void initState() {
    super.initState();
    _updateStats();
    _startUpdateTimer();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _updateStats() {
    setState(() {
      _stats = RebuildManager.instance.getStats();
    });
  }

  void _startUpdateTimer() {
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updateStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    if (stats == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  size: 20,
                  color: _getPerformanceColor(stats.performanceScore),
                ),
                const SizedBox(width: 8),
                Text(
                  'Rebuilds Performance: ${stats.performanceGrade}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Total',
                    value: stats.totalRebuilds.toString(),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Per Min',
                    value: stats.averageRebuildsPerMinute.toStringAsFixed(1),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Score',
                    value: stats.performanceScore.toStringAsFixed(0),
                  ),
                ),
              ],
            ),
            if (widget.showDetails &&
                stats.topRebuildingWidgets.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Top Rebuilding Widgets:',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              ...stats.topRebuildingWidgets.take(3).map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    RebuildManager.instance.clear();
                    _updateStats();
                  },
                  child: const Text('Clear'),
                ),
                TextButton(
                  onPressed: () {
                    final enabled = !RebuildManager.instance._isEnabled;
                    RebuildManager.instance.setEnabled(enabled);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          enabled
                              ? 'Rebuild monitoring enabled'
                              : 'Rebuild monitoring disabled',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    RebuildManager.instance._isEnabled ? 'Disable' : 'Enable',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPerformanceColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

/// Provider para estatísticas de rebuild
final rebuildStatsProvider = Provider<RebuildStats>((ref) {
  return RebuildManager.instance.getStats();
});

/// Provider para monitoramento específico de widget
final widgetRebuildProvider =
    Provider.family<List<RebuildInfo>, String>((ref, widgetName) {
  return RebuildManager.instance.getWidgetHistory(widgetName);
});

/// Extensions para facilitar o uso
extension RebuildManagerExtensions on RebuildManager {
  /// Inicia monitoramento para debug
  void startDebugMonitoring() {
    setEnabled(true);
    Logger().d('Debug rebuild monitoring started');
  }

  /// Para monitoramento
  void stopDebugMonitoring() {
    setEnabled(false);
    Logger().d('Debug rebuild monitoring stopped');
  }

  /// Obtém relatório detalhado
  Map<String, dynamic> getDetailedReport() {
    final stats = getStats();

    return {
      'summary': {
        'totalRebuilds': stats.totalRebuilds,
        'averagePerMinute': stats.averageRebuildsPerMinute,
        'performanceScore': stats.performanceScore,
        'performanceGrade': stats.performanceGrade,
      },
      'topWidgets': stats.topRebuildingWidgets
          .map((e) => {
                'name': e.key,
                'rebuilds': e.value,
              })
          .toList(),
      'topReasons': stats.topRebuildReasons
          .map((e) => {
                'reason': e.key,
                'count': e.value,
              })
          .toList(),
      'recent': stats.recentRebuilds.map((r) => r.toJson()).toList(),
    };
  }
}

/// Widget base otimizado com monitoramento automático
abstract class OptimizedWidget extends StatefulWidget {
  const OptimizedWidget({super.key});
}

abstract class OptimizedWidgetState<T extends OptimizedWidget> extends State<T>
    with RebuildMonitorMixin {
  /// Flag para evitar rebuilds desnecessários
  bool _shouldRebuild = true;

  /// Dados do último build para comparação
  Object? _lastBuildData;

  @override
  Widget buildWithMonitoring(BuildContext context) {
    final currentBuildData = getBuildData();

    // Só rebuild se os dados mudaram
    if (!_shouldRebuild && _lastBuildData == currentBuildData) {
      return _lastWidget ?? buildOptimized(context);
    }

    _lastBuildData = currentBuildData;
    _shouldRebuild = false;

    final widget = buildOptimized(context);
    _lastWidget = widget;

    return widget;
  }

  Widget? _lastWidget;

  /// Método para construir o widget otimizado
  Widget buildOptimized(BuildContext context);

  /// Dados para comparação de rebuild
  Object? getBuildData() => null;

  /// Força próximo rebuild
  void invalidate() {
    _shouldRebuild = true;
  }
}
