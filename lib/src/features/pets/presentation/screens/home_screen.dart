import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/src/core/navigation/app_routes.dart';
import 'package:petverse/src/features/pets/presentation/screens/feed_screen.dart';
import 'package:petverse/src/features/pets/presentation/screens/my_pets_screen.dart';
import 'package:petverse/src/features/profile/presentation/screens/profile_screen.dart';

// StateProvider para gerenciar o índice da aba selecionada na BottomNavigationBar
final homeScreenIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // Lista das telas que serão exibidas no corpo da HomeScreen
  final List<Widget> _screens = const [
    FeedScreen(),
    MyPetsScreen(),
    ProfileScreen(),
    // Adicione mais telas aqui se necessário no futuro
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeScreenIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ComPets Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navega para a tela de configurações
              // Usar context.push para empilhar a tela de configurações sobre a home
              // ou context.go se quiser substituir a navegação (depende do seu fluxo desejado)
              context.push(AppRoutes.settings);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(homeScreenIndexProvider.notifier).state = index;
        },
        // type: BottomNavigationBarType.fixed, // Para garantir que todos os labels apareçam se tiver mais itens
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Feed'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'Meus Pets'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
