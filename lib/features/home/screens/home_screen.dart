// lib/features/home/screens/home_screen.dart
// ALTERADO: Sistema de navegação com bottom navigation melhorado
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/constants/app_colors.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.navigationShell});

  // O navigationShell é fornecido pelo StatefulShellRoute
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: widget.navigationShell, // Exibe a tela da aba atual
      bottomNavigationBar: _buildBottomNavigationBar(theme),
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.pets_outlined, 0),
            activeIcon: _buildNavIcon(Icons.pets, 0, active: true),
            label: 'Meu Pet',
            tooltip: 'Cuidar do seu pet',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.store_outlined, 1),
            activeIcon: _buildNavIcon(Icons.store, 1, active: true),
            label: 'Loja',
            tooltip: 'Comprar itens',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.sports_esports_outlined, 2),
            activeIcon: _buildNavIcon(Icons.sports_esports, 2, active: true),
            label: 'Jogos',
            tooltip: 'Mini-jogos divertidos',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.event_outlined, 3),
            activeIcon: _buildNavIcon(Icons.event, 3, active: true),
            label: 'Eventos',
            tooltip: 'Eventos especiais',
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {bool active = false}) {
    final isSelected = widget.navigationShell.currentIndex == index;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: active
          ? BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Icon(
        icon,
        size: active ? 26 : 24,
        color: isSelected
            ? AppColors.primary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    // Evitar navegação desnecessária
    if (index == widget.navigationShell.currentIndex) {
      return;
    }

    try {
      // Navegar para a aba correspondente
      widget.navigationShell.goBranch(
        index,
        // Se a aba já estiver selecionada, volta para a rota inicial daquela aba
        initialLocation: index == widget.navigationShell.currentIndex,
      );

      // Feedback háptico sutil
      _provideFeedback();
    } catch (e) {
      debugPrint('❌ Erro na navegação do bottom nav: $e');

      // Fallback para navegação direta
      switch (index) {
        case 0:
          context.go('/main');
          break;
        case 1:
          context.go('/shop');
          break;
        case 2:
          context.go('/minigames');
          break;
        case 3:
          context.go('/events');
          break;
      }
    }
  }

  void _provideFeedback() {
    try {
      // Feedback háptico leve
      HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('⚠️ Feedback háptico não disponível: $e');
    }
  }
}

// NOVO: Widget para navegação de emergência
class EmergencyNavigationScreen extends StatelessWidget {
  final String error;

  const EmergencyNavigationScreen({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navegação'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.navigation_outlined,
              size: 80,
              color: AppColors.error.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'Erro na Navegação',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Houve um problema no sistema de navegação.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Erro: $error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontFamily: 'monospace',
                  ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.pets),
                  label: const Text('Meu Pet'),
                  onPressed: () => context.go('/main'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.store),
                  label: const Text('Loja'),
                  onPressed: () => context.go('/shop'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.games),
                  label: const Text('Jogos'),
                  onPressed: () => context.go('/minigames'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.event),
                  label: const Text('Eventos'),
                  onPressed: () => context.go('/events'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => context.go('/'),
              child: const Text('Reiniciar App'),
            ),
          ],
        ),
      ),
    );
  }
}

// NOVO: Provider para estado da navegação (se necessário)
final bottomNavigationIndexProvider = StateProvider<int>((ref) => 0);

// NOVO: Extensão para facilitar navegação
extension HomeNavigationExtension on BuildContext {
  void goToTab(int index) {
    switch (index) {
      case 0:
        go('/main');
        break;
      case 1:
        go('/shop');
        break;
      case 2:
        go('/minigames');
        break;
      case 3:
        go('/events');
        break;
      default:
        go('/main');
    }
  }

  void goToPetCare() => go('/main');
  void goToShop() => go('/shop');
  void goToMinigames() => go('/minigames');
  void goToEvents() => go('/events');
}
