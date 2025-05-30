// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:petverse/feature/pet/presentation/pet_care_screen.dart';
// import 'package:petverse/feature/pet/provider/pet_provider.dart';
// import 'package:petverse/feature/room/provider/room_provider.dart';

// // class PetPage extends ConsumerWidget {
// //   const PetPage({super.key});

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     final roomState = ref.watch(roomControllerProvider);

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Meu Pet'),
// //         centerTitle: true,
// //       ),
// //       body: roomState.when(
// //         data: (room) {
// //           if (room == null || room.petId == null) {
// //             return Center(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Container(
// //                     width: 200,
// //                     height: 200,
// //                     decoration: BoxDecoration(
// //                       color: Theme.of(context).colorScheme.primaryContainer,
// //                       borderRadius: BorderRadius.circular(100),
// //                     ),
// //                     child: Icon(
// //                       Icons.pets,
// //                       size: 100,
// //                       color: Theme.of(context).colorScheme.primary,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 24),
// //                   const Text(
// //                     'Você ainda não tem um pet!',
// //                     style: TextStyle(fontSize: 18),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   if (room != null && room.isActive)
// //                     ElevatedButton.icon(
// //                       onPressed: () {
// //                         // TODO: Navegar para adoção
// //                       },
// //                       icon: const Icon(Icons.add),
// //                       label: const Text('Adotar um Pet'),
// //                     )
// //                   else
// //                     const Text(
// //                       'Entre em uma sala primeiro',
// //                       style: TextStyle(color: Colors.grey),
// //                     ),
// //                 ],
// //               ),
// //             );
// //           }

// //           // TODO: Implementar visualização do pet
// //           return const Center(
// //             child: Text('Pet view - Em desenvolvimento'),
// //           );
// //         },
// //         loading: () => const Center(child: CircularProgressIndicator()),
// //         error: (error, _) => Center(
// //           child: Text('Erro: $error'),
// //         ),
// //       ),
// //     );
// //   }
// // }

// class PetPage extends ConsumerWidget {
//   const PetPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final roomState = ref.watch(roomControllerProvider);
//     final petStream = ref.watch(petStreamProvider as ProviderListenable);

//     return roomState.when(
//       data: (room) {
//         if (room == null) {
//           return _buildNoPetView(
//             context,
//             'Entre em uma sala primeiro',
//             showButton: false,
//           );
//         }

//         return petStream.when(
//           data: (pet) {
//             if (pet == null) {
//               // Tem sala mas não tem pet
//               if (room.isActive) {
//                 return _buildNoPetView(
//                   context,
//                   'Vocês podem adotar um pet agora!',
//                   showButton: true,
//                   onAdopt: () {
//                     context.push('/pet/adopt/${room.id}');
//                   },
//                 );
//               } else {
//                 return _buildNoPetView(
//                   context,
//                   'Aguardando parceiro para adotar um pet',
//                   showButton: false,
//                 );
//               }
//             }

//             // Tem pet - mostrar tela de cuidados
//             return const PetCarePage();
//           },
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (error, _) => Center(
//             child: Text('Erro ao carregar pet: $error'),
//           ),
//         );
//       },
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (error, _) => Center(
//         child: Text('Erro: $error'),
//       ),
//     );
//   }

//   Widget _buildNoPetView(
//     BuildContext context,
//     String message, {
//     required bool showButton,
//     VoidCallback? onAdopt,
//   }) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Meu Pet'),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 200,
//               height: 200,
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primaryContainer,
//                 borderRadius: BorderRadius.circular(100),
//               ),
//               child: Icon(
//                 Icons.pets,
//                 size: 100,
//                 color: theme.colorScheme.primary,
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Você ainda não tem um pet!',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               message,
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//               textAlign: TextAlign.center,
//             ),
//             if (showButton) ...[
//               const SizedBox(height: 24),
//               ElevatedButton.icon(
//                 onPressed: onAdopt,
//                 icon: const Icon(Icons.add),
//                 label: const Text('Adotar um Pet'),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 32,
//                     vertical: 16,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
