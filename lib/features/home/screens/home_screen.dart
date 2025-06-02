import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.navigationShell});

  // O navigationShell é fornecido pelo StatefulShellRoute
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Você pode obter o índice atual do navigationShell para destacar o item correto
    // ou usar o próprio GoRouter para gerenciar o estado da BottomNavigationBar.
    // Para simplicidade, vamos usar o navigationShell.currentIndex.

    return Scaffold(
      // A AppBar pode ser global aqui, ou cada aba pode ter a sua.
      // Se for global, o título e as ações precisariam ser dinâmicos.
      // Por enquanto, vamos deixar que cada aba gerencie sua própria AppBar.
      // appBar: StyledAppBar(title: _getTitleForIndex(navigationShell.currentIndex)),
      body: navigationShell, // Exibe a tela da aba atual
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          // Navega para a aba correspondente.
          // O `goBranch` preserva o estado da navegação dentro de cada branch (aba).
          navigationShell.goBranch(
            index,
            // Se a aba já estiver selecionada, volta para a rota inicial daquela aba.
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Pet'),
          BottomNavigationBarItem(
              icon: Icon(Icons.store_outlined), label: 'Loja'),
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_esports_outlined), label: 'Jogos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined), label: 'Eventos'),
        ],
        type: BottomNavigationBarType
            .fixed, // Para mais de 3 itens, ou 'shifting'
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
}
