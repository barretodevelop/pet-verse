import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            return const Center(
              child: Text('Nenhum pet disponível para adoção no momento.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return PetDisplayCard(
                pet: pet,
                onTap: () {
                  // TODO: Navegar para uma tela de detalhes do pet
                  debugPrint('Pet ${pet.name} clicado no Feed!');
                },
              );
            },
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
