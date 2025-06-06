// lib/presentation/screens/optimized_home_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/cache/provider_cache.dart';
import 'package:petverse/core/providers/firebase_providers.dart';

import '../../core/providers/performance_providers.dart';
import '../../core/providers/unified_optimized_providers.dart';
import '../../core/widgets/custom_bottom_navigation.dart';
import '../providers/optimized_currency_provider.dart';
import '../providers/optimized_pet_provider.dart';
import '../widgets/optimized_widgets.dart';

/// Tela Home completamente otimizada demonstrando todos os conceitos da FASE 3
class OptimizedHomeScreen extends UnifiedConsumerWidget {
  const OptimizedHomeScreen({super.key});

  @override
  Widget buildContent(
      BuildContext context, WidgetRef ref, UnifiedAppState state) {
    return Scaffold(
      // AppBar customizada que usa selectors otimizados
      appBar: _OptimizedAppBar(),

      body: const Stack(
        children: [
          // Conteúdo principal com cache e selectors
          _OptimizedHomeBody(),

          // Widget de notificações (usa ConsumerStatefulWidget com justificativa)
          // SmartNotificationWidget(),

          // Debug panel em desenvolvimento
          if (kDebugMode) _PerformanceDebugPanel(),
        ],
      ),

      // Bottom navigation otimizada
      bottomNavigationBar: _OptimizedBottomNavigation(),

      // FAB com ação otimizada
      floatingActionButton: const _OptimizedFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  @override
  bool shouldShowError(List<String> errors) {
    // Só mostra tela de erro para erros críticos
    return errors
        .any((error) => error.contains('crítico') || error.contains('fatal'));
  }
}

class SmartNotificationWidget {
  const SmartNotificationWidget();
}

/// AppBar otimizada que usa selectors específicos
class _OptimizedAppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usa selectors específicos para evitar rebuilds desnecessários
    final userCoins = ref.watch(
        coinsSelector(ref.watch(firebaseCurrentUserProvider)?.uid ?? ''));

    final userGems = ref
        .watch(gemsSelector(ref.watch(firebaseCurrentUserProvider)?.uid ?? ''));

    final isLoading =
        ref.watch(unifiedAppProvider.select((state) => state.isLoading));

    return AppBar(
      title: Row(
        children: [
          const Text('PetAdote'),
          if (isLoading) ...[
            const SizedBox(width: 8),
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
      actions: [
        // Moeda exibida na AppBar
        _CurrencyChip(icon: '💰', value: userCoins.toString()),
        const SizedBox(width: 8),
        _CurrencyChip(icon: '💎', value: userGems.toString()),
        const SizedBox(width: 16),

        // Menu de configurações
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, ref, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Atualizar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear_cache',
              child: Row(
                children: [
                  Icon(Icons.clear),
                  SizedBox(width: 8),
                  Text('Limpar Cache'),
                ],
              ),
            ),
            if (kDebugMode) ...[
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'performance',
                child: Row(
                  children: [
                    Icon(Icons.speed),
                    SizedBox(width: 8),
                    Text('Performance'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'refresh':
        ref.refreshAllData();
        break;
      case 'clear_cache':
        ref.clearGlobalCache();
        _showSnackBar(context, 'Cache limpo!');
        break;
      case 'performance':
        _showPerformanceDialog(context, ref);
        break;
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showPerformanceDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _PerformanceDialog(),
    );
  }
}

/// Chip de moeda otimizado
class _CurrencyChip extends StatelessWidget {
  final String icon;
  final String value;

  const _CurrencyChip({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Corpo principal da tela com otimizações
class _OptimizedHomeBody extends ConsumerWidget {
  const _OptimizedHomeBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () => ref.refreshAllData(),
      child: const CustomScrollView(
        slivers: [
          // Header com estatísticas
          SliverToBoxAdapter(
            child: _HomeHeader(),
          ),

          // Lista de pets otimizada
          SliverToBoxAdapter(
            child: _PetsSection(),
          ),

          // Seção de interações (se houver pet)
          SliverToBoxAdapter(
            child: _InteractionsSection(),
          ),

          // Espaçamento inferior para o FAB
          SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }
}

/// Header da home com informações gerais
class _HomeHeader extends ConsumerWidget with PerformanceMonitorMixin {
  const _HomeHeader();

  @override
  Widget buildMonitored(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: const Column(
        children: [
          // Widget de informações simples (não precisa de StatefulWidget)
          // SimpleInfoDisplayWidget(),

          SizedBox(height: 16),

          // Estatísticas globais otimizadas
          OptimizedGlobalStatsWidget(),
        ],
      ),
    );
  }
}

class SimpleInfoDisplayWidget {
  const SimpleInfoDisplayWidget();
}

/// Seção de pets com lista otimizada
class _PetsSection extends ConsumerWidget with PerformanceMonitorMixin {
  const _PetsSection();

  @override
  Widget buildMonitored(BuildContext context, WidgetRef ref) {
    // Usa selector específico para verificar se há pets
    final hasPets = ref
        .watch(optimizedPetsProvider.select((state) => state.pets.isNotEmpty));

    if (!hasPets) {
      return const _EmptyPetsSection();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pets Disponíveis',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          const SizedBox(height: 12),

          // Lista horizontal de pets otimizada
          SizedBox(
            height: 200,
            child: _OptimizedPetsList(),
          ),
        ],
      ),
    );
  }
}

/// Lista otimizada de pets (horizontal)
class _OptimizedPetsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usa selector para apenas pets disponíveis
    final availablePets = ref.availablePets;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: availablePets.length,
      itemBuilder: (context, index) {
        final pet = availablePets[index];

        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          child: OptimizedPetCard(
            petId: pet.id,
            showActions: false, // Ações simplificadas na lista
            onTap: () => _showPetDetails(context, ref, pet.id),
          ),
        );
      },
    );
  }

  void _showPetDetails(BuildContext context, WidgetRef ref, String petId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PetDetailsSheet(petId: petId),
    );
  }
}

/// Sheet de detalhes do pet com interações
class _PetDetailsSheet extends StatelessWidget {
  final String petId;

  const _PetDetailsSheet({required this.petId});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Handle do sheet
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 20),

                // Widget de interação complexo (justifica StatefulWidget)
                // SmartPetInteractionWidget(petId: petId),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Seção vazia de pets
class _EmptyPetsSection extends StatelessWidget {
  const _EmptyPetsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pets_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum pet disponível',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gere um pet único ou espere novos pets aparecerem!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Seção de interações (só aparece se houver pet adotado)
class _InteractionsSection extends ConsumerWidget {
  const _InteractionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userContext = ref.userContext;

    if (userContext?.currentPet == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seu Pet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          // SmartPetInteractionWidget(
          //   petId: userContext!.currentPet!.id,
          // ),
        ],
      ),
    );
  }
}

class SmartPetInteractionWidget {}

/// Bottom navigation otimizada
class _OptimizedBottomNavigation extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Estado local simples pode ser gerenciado sem StatefulWidget
    const selectedIndex = 0; // Home sempre selecionada nesta demo

    return NavigationWithCenterButton(
      selectedIndex: selectedIndex,
      onItemTapped: (index) => _navigateToPage(context, index),
      onCenterButtonPressed: () => _openPetGeneration(context, ref),
    );
  }

  void _navigateToPage(BuildContext context, int index) {
    // Implementar navegação baseada no índice
    switch (index) {
      case 0: // Dashboard - já estamos aqui
        break;
      case 1: // Store
        break;
      case 3: // Games
        break;
      case 4: // Feed
        break;
    }
  }

  void _openPetGeneration(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _PetGenerationDialog(),
    );
  }
}

/// Dialog de geração de pet
class _PetGenerationDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAfford = ref.canAfford(gems: 20);

    return AlertDialog(
      title: const Text('Gerar Pet Único'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Deseja gerar um pet único personalizado?'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text('💎'),
                const SizedBox(width: 8),
                const Text('Custo: '),
                Text(
                  '20 gemas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: canAfford ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: canAfford ? () => _generatePet(context, ref) : null,
          child: const Text('Gerar'),
        ),
      ],
    );
  }

  void _generatePet(BuildContext context, WidgetRef ref) {
    // Implementar geração de pet
    final success = ref.spendGems(20);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet único sendo gerado...'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// FAB otimizado
class _OptimizedFloatingActionButton extends ConsumerWidget {
  const _OptimizedFloatingActionButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usa selector para verificar se há pets críticos
    final criticalPetsCount = ref.watch(
        optimizedPetsProvider.select((state) => state.criticalPets.length));

    return PetFloatingButton(
      onPressed: () => _handleFabPressed(context, ref),
      isSelected: criticalPetsCount > 0,
    );
  }

  void _handleFabPressed(BuildContext context, WidgetRef ref) {
    // Ação baseada no contexto
    final criticalPets = ref.criticalPets;

    if (criticalPets.isNotEmpty) {
      _showCriticalPetsDialog(context, criticalPets.length);
    } else {
      _showQuickActions(context, ref);
    }
  }

  void _showCriticalPetsDialog(BuildContext context, int count) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pets Críticos'),
        content: Text('$count pets precisam de atenção urgente!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _QuickActionsSheet(),
    );
  }
}

/// Sheet de ações rápidas
class _QuickActionsSheet extends ConsumerWidget {
  const _QuickActionsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Ações Rápidas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.refresh,
                  label: 'Atualizar',
                  onPressed: () {
                    ref.refreshAllData();
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.sync,
                  label: 'Sincronizar',
                  onPressed: () {
                    ref.syncPendingData();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Botão de ação rápida
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }
}

/// Panel de debug de performance (apenas desenvolvimento)
class _PerformanceDebugPanel extends ConsumerWidget {
  const _PerformanceDebugPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceStats = ref.performanceStats;
    final combinedMetrics = ref.combinedMetrics;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      right: 16,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Performance Debug',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            _DebugRow('Score',
                combinedMetrics.overallOptimizationScore.toStringAsFixed(1)),
            _DebugRow('Widgets', performanceStats.totalWidgets.toString()),
            _DebugRow('Rebuilds', performanceStats.totalRebuilds.toString()),
            _DebugRow('Avg Time',
                '${performanceStats.averageRebuildTime.inMilliseconds}ms'),
            _DebugRow('Cache Hit',
                '${(ref.watch(cacheStatsProvider).hitRate * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }
}

class _DebugRow extends StatelessWidget {
  final String label;
  final String value;

  const _DebugRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

/// Dialog de performance detalhada
class _PerformanceDialog extends ConsumerWidget {
  const _PerformanceDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final combinedMetrics = ref.combinedMetrics;

    return AlertDialog(
      title: const Text('Métricas de Performance'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetricsCard(
                title: 'Score Geral',
                value:
                    '${combinedMetrics.overallOptimizationScore.toStringAsFixed(1)}/100',
                color: _getScoreColor(combinedMetrics.overallOptimizationScore),
              ),
              const SizedBox(height: 16),
              const Text('Recomendações:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...combinedMetrics.optimizationRecommendations.map(
                (rec) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.blue)),
                      Expanded(
                          child:
                              Text(rec, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

class _MetricsCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MetricsCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
