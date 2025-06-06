// lib/presentation/widgets/performance_debug_widget.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/data/models/pet.dart';
import 'package:petverse/presentation/widgets/optimized_widgets.dart';

import '../../core/cache/provider_cache.dart';
import '../../core/performance/performance_monitor.dart';
import '../../core/providers/unified_optimized_providers.dart';
import '../providers/optimized_currency_provider.dart';

/// Widget principal de debug de performance
class PerformanceDebugWidget extends ConsumerStatefulWidget {
  const PerformanceDebugWidget({super.key});

  @override
  ConsumerState<PerformanceDebugWidget> createState() =>
      _PerformanceDebugWidgetState();
}

class _PerformanceDebugWidgetState extends ConsumerState<PerformanceDebugWidget>
    with TickerProviderStateMixin, PerformanceMixin {
  late TabController _tabController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget buildWithPerformance(BuildContext context) {
    final performanceStats = ref.watch(performanceStatsProvider);
    final issues = ref.watch(performanceIssuesProvider);
    final cacheStats = ref.watch(cacheStatsProvider);
    final globalStats = ref.watch(globalStatsProvider);

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header com resumo
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Performance Monitor',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  _PerformanceIndicator(
                    score: performanceStats.performanceScore,
                    grade: performanceStats.performanceGrade,
                  ),
                  const SizedBox(width: 8),
                  _FrameRateIndicator(
                      frameRate: performanceStats.averageFrameRate),
                  const SizedBox(width: 8),
                  _IssuesIndicator(issues: issues),
                ],
              ),
            ),
          ),

          // Conteúdo expandido
          if (_isExpanded) ...[
            const Divider(height: 1),
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _OverviewTab(
                    performanceStats: performanceStats,
                    globalStats: globalStats,
                    cacheStats: cacheStats,
                  ),
                  _RebuildsTab(performanceStats: performanceStats),
                  _ProvidersTab(performanceStats: performanceStats),
                  _IssuesTab(issues: issues),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Visão Geral'),
                Tab(text: 'Rebuilds'),
                Tab(text: 'Providers'),
                Tab(text: 'Problemas'),
              ],
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
            // Botões de ação
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => ref.clearPerformanceData(),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Limpar Dados'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => ref.clearGlobalCache(),
                    icon: const Icon(Icons.cached, size: 16),
                    label: const Text('Limpar Cache'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => ref.refreshAllData(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _simulateLoad,
                    icon: const Icon(Icons.speed, size: 16),
                    label: const Text('Simular Carga'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Simula carga para testar performance
  void _simulateLoad() {
    // Simula rebuilds
    for (int i = 0; i < 10; i++) {
      PerformanceMonitor.instance.recordRebuild('SimulatedWidget$i');
    }

    // Simula operações lentas
    PerformanceMonitor.instance.measureSync(
      'Simulated Heavy Operation',
      () {
        // Simula operação pesada
        var sum = 0;
        for (int i = 0; i < 1000000; i++) {
          sum += i;
        }
        return sum;
      },
      type: 'simulation',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Carga simulada aplicada')),
    );
  }
}

/// Indicador de performance geral
class _PerformanceIndicator extends StatelessWidget {
  final double score;
  final String grade;

  const _PerformanceIndicator({
    required this.score,
    required this.grade,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(score);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            grade,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.lightGreen;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.deepOrange;
    return Colors.red;
  }
}

/// Indicador de frame rate
class _FrameRateIndicator extends StatelessWidget {
  final double frameRate;

  const _FrameRateIndicator({required this.frameRate});

  @override
  Widget build(BuildContext context) {
    final color = frameRate >= 55
        ? Colors.green
        : frameRate >= 45
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${frameRate.toStringAsFixed(0)} FPS',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Indicador de problemas
class _IssuesIndicator extends StatelessWidget {
  final List<PerformanceIssue> issues;

  const _IssuesIndicator({required this.issues});

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 16);
    }

    final criticalCount = issues
        .where((i) => i.severity == PerformanceIssueSeverity.critical)
        .length;
    final errorCount = issues
        .where((i) => i.severity == PerformanceIssueSeverity.error)
        .length;

    final color = criticalCount > 0
        ? Colors.red
        : errorCount > 0
            ? Colors.orange
            : Colors.yellow;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: color, size: 12),
          const SizedBox(width: 2),
          Text(
            '${issues.length}',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Aba de visão geral
class _OverviewTab extends StatelessWidget {
  final PerformanceStats performanceStats;
  final GlobalStats globalStats;
  final CacheStats cacheStats;

  const _OverviewTab({
    required this.performanceStats,
    required this.globalStats,
    required this.cacheStats,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Performance Geral'),
          _MetricRow('Score',
              '${performanceStats.performanceScore.toStringAsFixed(1)}/100'),
          _MetricRow('Frame Rate',
              '${performanceStats.averageFrameRate.toStringAsFixed(1)} FPS'),
          _MetricRow('Eventos Recentes', '${performanceStats.recentEvents}'),
          const SizedBox(height: 16),
          const _SectionHeader('Cache'),
          _MetricRow('Entradas',
              '${cacheStats.validEntries}/${cacheStats.totalEntries}'),
          _MetricRow('Taxa de Hit',
              '${(cacheStats.hitRate * 100).toStringAsFixed(1)}%'),
          _MetricRow(
              'Utilização', '${cacheStats.utilization.toStringAsFixed(1)}%'),
          const SizedBox(height: 16),
          const _SectionHeader('Dados Globais'),
          _MetricRow('Total de Pets', '${globalStats.totalPets}'),
          _MetricRow('Pets Disponíveis', '${globalStats.availablePets}'),
          _MetricRow('Taxa de Adoção',
              '${globalStats.adoptionRate.toStringAsFixed(1)}%'),
          _MetricRow(
              'Mudanças Locais', globalStats.hasLocalChanges ? 'Sim' : 'Não'),
        ],
      ),
    );
  }
}

/// Aba de rebuilds
class _RebuildsTab extends StatelessWidget {
  final PerformanceStats performanceStats;

  const _RebuildsTab({required this.performanceStats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Top Rebuilds'),
          ...performanceStats.topRebuilds.take(10).map(
                (entry) => _MetricRow(
                  entry.key,
                  '${entry.value} rebuilds',
                  color: entry.value > 20
                      ? Colors.red
                      : entry.value > 10
                          ? Colors.orange
                          : null,
                ),
              ),
          if (performanceStats.topRebuilds.isEmpty)
            const Text('Nenhum rebuild registrado'),
        ],
      ),
    );
  }
}

/// Aba de providers
class _ProvidersTab extends StatelessWidget {
  final PerformanceStats performanceStats;

  const _ProvidersTab({required this.performanceStats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Provider Reads'),
          ...performanceStats.providerReads.entries.map(
            (entry) => _MetricRow(entry.key, '${entry.value} reads'),
          ),
          const SizedBox(height: 16),
          const _SectionHeader('Provider Writes'),
          ...performanceStats.providerWrites.entries.map(
            (entry) => _MetricRow(
              entry.key,
              '${entry.value} writes',
              color: entry.value > 10 ? Colors.orange : null,
            ),
          ),
          const SizedBox(height: 16),
          const _SectionHeader('Durações Médias'),
          ...performanceStats.averageDurations.entries.map(
            (entry) => _MetricRow(
              entry.key,
              '${entry.value.toStringAsFixed(1)}ms',
              color: entry.value > 50
                  ? Colors.red
                  : entry.value > 20
                      ? Colors.orange
                      : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

/// Aba de problemas
class _IssuesTab extends StatelessWidget {
  final List<PerformanceIssue> issues;

  const _IssuesTab({required this.issues});

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 48, color: Colors.green),
            SizedBox(height: 8),
            Text('Nenhum problema detectado'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: issues.length,
      itemBuilder: (context, index) {
        final issue = issues[index];
        return _IssueCard(issue: issue);
      },
    );
  }
}

/// Card de problema
class _IssueCard extends StatelessWidget {
  final PerformanceIssue issue;

  const _IssueCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(issue.severity);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getSeverityIcon(issue.severity), color: color, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    issue.description,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              issue.suggestion,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(PerformanceIssueSeverity severity) {
    switch (severity) {
      case PerformanceIssueSeverity.info:
        return Colors.blue;
      case PerformanceIssueSeverity.warning:
        return Colors.orange;
      case PerformanceIssueSeverity.error:
        return Colors.red;
      case PerformanceIssueSeverity.critical:
        return Colors.purple;
    }
  }

  IconData _getSeverityIcon(PerformanceIssueSeverity severity) {
    switch (severity) {
      case PerformanceIssueSeverity.info:
        return Icons.info;
      case PerformanceIssueSeverity.warning:
        return Icons.warning;
      case PerformanceIssueSeverity.error:
        return Icons.error;
      case PerformanceIssueSeverity.critical:
        return Icons.dangerous;
    }
  }
}

/// Header de seção
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
      ),
    );
  }
}

/// Linha de métrica
class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MetricRow(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget de demonstração do sistema otimizado
class OptimizedSystemDemo extends ConsumerWidget with ConsumerPerformanceMixin {
  const OptimizedSystemDemo({super.key});

  @override
  Widget buildWithPerformance(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo - Sistema Otimizado'),
        actions: [
          IconButton(
            onPressed: () => _showPerformanceDialog(context, ref),
            icon: const Icon(Icons.analytics),
          ),
        ],
      ),
      body: Column(
        children: [
          // Performance Debug Widget
          const PerformanceDebugWidget(),

          // Currency Display otimizado
          const Card(
            margin: EdgeInsets.all(8),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Moeda do Usuário (Otimizada)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  OptimizedCurrencyDisplay(
                    showCoins: true,
                    showGems: true,
                    showXP: true,
                    showLevel: true,
                  ),
                ],
              ),
            ),
          ),

          // Lista de pets otimizada
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Pets Disponíveis (Otimizados)',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: OptimizedPetsList(
                      showOnlyAvailable: true,
                      maxItems: 10,
                      onPetTap: (pet) => _showPetDetails(context, pet),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botões de teste
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _simulateActivity(ref),
                    child: const Text('Simular Atividade'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _stressTest(ref),
                    child: const Text('Teste de Stress'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPerformanceDialog(BuildContext context, WidgetRef ref) {
    final stats = ref.read(performanceStatsProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estatísticas de Performance'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: SingleChildScrollView(
            child: Text('''
Score: ${stats.performanceScore.toStringAsFixed(1)}/100
Grade: ${stats.performanceGrade}
Frame Rate: ${stats.averageFrameRate.toStringAsFixed(1)} FPS
Eventos Totais: ${stats.totalEvents}
Eventos Recentes: ${stats.recentEvents}

Top Rebuilds:
${stats.topRebuilds.take(5).map((e) => '${e.key}: ${e.value}').join('\n')}

Providers:
Reads: ${stats.providerReads.length}
Writes: ${stats.providerWrites.length}
            '''),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showPetDetails(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pet.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${pet.type}'),
            Text('Descrição: ${pet.description}'),
            const SizedBox(height: 8),
            Text('Fome: ${pet.hunger}%'),
            Text('Felicidade: ${pet.happiness}%'),
            Text('Energia: ${pet.energy}%'),
            Text('Nível: ${pet.level}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _simulateActivity(WidgetRef ref) {
    // Simula atividade de usuário
    ref.addCoins(Random().nextInt(100) + 50);
    ref.addGems(Random().nextInt(10) + 1);
    ref.addXP(Random().nextInt(50) + 25);

    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(content: Text('Atividade simulada!')),
    );
  }

  void _stressTest(WidgetRef ref) {
    // Executa múltiplas operações para testar performance
    for (int i = 0; i < 50; i++) {
      ref.addCoins(1);
      PerformanceMonitor.instance.recordRebuild('StressTest$i');
    }

    ref.refreshAllData();

    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(content: Text('Teste de stress executado!')),
    );
  }
}
