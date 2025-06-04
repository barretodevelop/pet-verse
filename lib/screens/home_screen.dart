import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/src/core/navigation/app_routes.dart'; // Para o botão de Configurações
import 'package:petverse/src/features/pets/presentation/screens/feed_screen.dart';
import 'package:petverse/src/features/pets/presentation/screens/my_pets_screen.dart';
import 'package:petverse/src/features/profile/presentation/screens/profile_screen.dart';

// StateProvider para gerenciar o índice da aba selecionada na BottomNavigationBar
final homeScreenIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  // Lista das telas que serão exibidas no corpo da HomeScreen
  final List<Widget> _screens = [
    const FeedScreen(), // Tela de Feed
    const MyPetsScreen(), // Tela de Meus Pets
    const ProfileScreen(), // Tela de Perfil
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeScreenIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PetVerse'), // Título mais genérico para a Home
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
        type: BottomNavigationBarType
            .fixed, // Garante que todos os labels apareçam
        selectedItemColor:
            Theme.of(context).colorScheme.primary, // Cor do item selecionado
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
