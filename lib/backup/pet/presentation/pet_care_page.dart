// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:petverse/feature/pet/presentation/widgets/pet_action_buttons.dart';
// import 'package:petverse/feature/pet/presentation/widgets/pet_card_mini.dart';
// import 'package:petverse/feature/pet/provider/pet_provider.dart';

// class PetCarePage extends ConsumerWidget {
//   const PetCarePage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Observa o pet favorito (o principal no centro)
//     final favoritePet = ref.watch(favoritePetProvider);
//     // Observa a lista de todos os pets do usuário na sala
//     final otherPets = ref
//         .watch(userPetsListProvider)
//         .where((pet) => pet.id != favoritePet?.id)
//         .toList();
//     // Observa o controller para acessar os métodos de ação
//     final petController = ref.read(petControllerProvider.notifier);

//     if (favoritePet == null) {
//       // Isso teoricamente não deve acontecer se a PetPage já filtrou,
//       // mas é um fallback seguro.
//       return const Center(child: Text('Nenhum pet favorito para exibir.'));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(favoritePet.name), // Nome do pet favorito no AppBar
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               // context.push('/pet/settings/${favoritePet.id}'); // Navegar para configurações do pet
//               ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Configurações do Pet')));
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Área dos outros pets (cards acima do pet principal)
//           if (otherPets.isNotEmpty)
//             SizedBox(
//               height: 120, // Altura para os cards dos outros pets
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 itemCount: otherPets.length,
//                 itemBuilder: (context, index) {
//                   final pet = otherPets[index];
//                   return PetCardMini(
//                     pet: pet,
//                     onTap: () {
//                       petController.setFavoritePet(
//                           pet); // Define este pet como favorito ao tocar
//                     },
//                   );
//                 },
//               ),
//             ),
//           const SizedBox(height: 16),

//           // Pet Principal no Centro
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Imagem/Animação do Pet Favorito (substitua por seu asset ou widget de animação)
//                 Image.asset(
//                   'assets/images/pet_placeholder.png', // Placeholder, substitua pela imagem do pet
//                   height: 250,
//                   width: 250,
//                   fit: BoxFit.contain,
//                 ),
//                 const SizedBox(height: 24),

//                 // Status do Pet
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           _buildStatusIndicator(
//                               Icons.restaurant, favoritePet.hunger, 'Fome'),
//                           _buildStatusIndicator(Icons.sentiment_satisfied_alt,
//                               favoritePet.happiness, 'Felicidade'),
//                           _buildStatusIndicator(Icons.clean_hands,
//                               favoritePet.cleanliness, 'Limpeza'),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Status Geral: ${favoritePet.status}',
//                         style: Theme.of(context).textTheme.titleMedium,
//                       ),
//                       Text(
//                         'Humor: ${favoritePet.mood}',
//                         style: Theme.of(context).textTheme.bodyMedium,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 32),

//                 // Botões de Ação (Alimentar, Brincar, Limpar)
//                 PetActionButtons(
//                   pet: favoritePet,
//                   onFeed: () => petController.feedPet(favoritePet.id),
//                   onPlay: () => petController.playWithPet(favoritePet.id),
//                   onClean: () => petController.cleanPet(favoritePet.id),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget auxiliar para mostrar o status (fome, felicidade, limpeza)
//   Widget _buildStatusIndicator(IconData icon, int value, String label) {
//     Color color;
//     if (value < 30) {
//       color = Colors.red;
//     } else if (value < 70) {
//       color = Colors.orange;
//     } else {
//       color = Colors.green;
//     }

//     return Column(
//       children: [
//         Icon(icon, color: color, size: 30),
//         Text('$value%',
//             style: TextStyle(color: color, fontWeight: FontWeight.bold)),
//         Text(label, style: const TextStyle(fontSize: 12)),
//       ],
//     );
//   }
// }
