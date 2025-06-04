import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/src/core/navigation/app_routes.dart'; // Para o botão de Configurações
import 'package:petverse/src/features/adoption/presentation/screens/adoption_initial_screen.dart'; // Importar AdoptionInitialScreen
import 'package:petverse/src/features/auth/presentation/providers/user_data_provider.dart'; // Importar userHasPetProvider
import 'package:petverse/src/features/pets/presentation/screens/feed_screen.dart';
import 'package:petverse/src/features/pets/presentation/screens/my_pets_screen.dart';
import 'package:petverse/src/features/profile/presentation/screens/profile_screen.dart';

// StateProvider para gerenciar o índice da aba selecionada na BottomNavigationBar
final homeScreenIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeScreenIndexProvider);
    final userHasPetAsyncValue = ref.watch(userHasPetProvider);

    // Construir a lista de telas dinamicamente com base no estado de userHasPetProvider
    final List<Widget> screens = [
      const FeedScreen(), // Tela de Feed
      userHasPetAsyncValue.when(
        data: (hasPet) {
          // Se o usuário tem pet, e o índice atual é o da aba "Meus Pets" (1),
          // e ele está tentando acessar a AdoptionInitialScreen (o que não deveria acontecer
          // devido às regras do router), o router já deve ter redirecionado.
          // Aqui, simplesmente mostramos a tela correta para a aba.
          return hasPet ? const MyPetsScreen() : const AdoptionInitialScreen();
        },
        loading: () => const Center(
            child:
                CircularProgressIndicator()), // Tela de carregamento para a aba "Meus Pets"
        error: (error, stack) => Center(
          child: Text(
              'Erro ao verificar status do pet: $error'), // Tela de erro para a aba "Meus Pets"
        ),
      ),
      const ProfileScreen(), // Tela de Perfil
    ];

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
        children: screens, // Usar a lista de telas construída dinamicamente
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
