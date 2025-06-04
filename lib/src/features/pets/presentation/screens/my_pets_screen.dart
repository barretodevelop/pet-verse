import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/pets/presentation/providers/user_adopted_pets_provider.dart'; // Importa o provider de pets adotados
import 'package:petverse/src/features/pets/presentation/widgets/adopted_pet_card.dart'; // Importa o widget do card de pet adotado

class MyPetsScreen extends ConsumerWidget {
  // Mudar para ConsumerWidget
  const MyPetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Adicionar WidgetRef ref
    final adoptedPetsAsyncValue = ref.watch(userAdoptedPetsProvider);

    return Scaffold(
      // AppBar opcional, pode ser removido se a HomeScreen já tiver uma AppBar global
      // appBar: AppBar(
      //   title: const Text('Meus Pets Adotados'),
      // ),
      body: adoptedPetsAsyncValue.when(
        data: (pets) {
          if (pets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons
                          .pets_outlined, // Ou um ícone mais específico se preferir
                      size: 80,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Você ainda não adotou nenhum pet.\nExplore o feed ou inicie uma adoção!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return AdoptedPetCard(pet: pet);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Erro ao carregar seus pets: $error')),
      ),
    );
  }
}
