import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // Importar o pacote
import 'package:go_router/go_router.dart'; // Importar GoRouter
import 'package:petverse/src/core/navigation/app_routes.dart'; // Importar AppRoutes
import 'package:petverse/src/features/adoption/presentation/providers/available_pets_provider.dart'; // Usaremos o mesmo provider da AdoptNewPetScreen
import 'package:petverse/src/features/pets/presentation/widgets/pet_display_card.dart'; // Um novo card genérico para pets

class FeedScreen extends ConsumerWidget {
  // Mudar para ConsumerWidget
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Adicionar WidgetRef ref
    final availablePetsAsyncValue = ref.watch(availablePetsProvider);

    return Scaffold(
      // AppBar opcional, pode ser removido se a HomeScreen já tiver uma AppBar global
      // appBar: AppBar(
      //   title: const Text('Pets Disponíveis'),
      // ),
      body: availablePetsAsyncValue.when(
        data: (pets) {
          if (pets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_outlined, // Ícone para "nada encontrado"
                      size: 80,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    const Text('Nenhum pet disponível para adoção no momento.'),
                  ],
                ),
              ),
            );
          }
          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: PetDisplayCard(
                        pet: pet,
                        onTap: () {
                          // Navegar para a tela de detalhes do pet, passando o objeto pet
                          context.pushNamed(AppRoutes.petDetails, extra: pet);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          debugPrint('Erro ao carregar pets para o Feed: $error');
          return Center(
            child: Text('Erro ao carregar pets: ${error.toString()}'),
          );
        },
      ),
    );
  }
}
