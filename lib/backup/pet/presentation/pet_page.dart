// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:petverse/feature/pet/presentation/pet_care_screen.dart';
// import 'package:petverse/feature/pet/provider/pet_controller_provider.dart';
// import 'package:petverse/feature/room/provider/room_provider.dart';

// class PetPage extends ConsumerWidget {
//   const PetPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Observa o estado da sala (se o usuário está em uma sala)
//     final roomState = ref.watch(roomControllerProvider);
//     // Observa o estado dos pets gerenciado pelo PetController
//     final petState = ref.watch(petControllerProvider);

//     // Listener para erros globais do PetController (opcional, pode ser na Home Screen principal)
//     ref.listen<PetState>(petControllerProvider, (previous, next) {
//       if (next.error != null && previous?.error != next.error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
//         );
//       }
//     });

//     return roomState.when(
//       data: (room) {
//         if (room == null) {
//           // Caso 1: Usuário não está em nenhuma sala
//           return _buildInfoView(
//             context,
//             'Entre em uma sala para ter um pet!',
//             icon: Icons.meeting_room_outlined,
//             buttonText: 'Entrar/Criar Sala',
//             onButtonPressed: () {
//               // Navegue para a tela de gerenciamento de salas
//               // context.push('/rooms/manage'); // Exemplo
//               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                   content: Text('Navegar para Gerenciamento de Salas')));
//             },
//             showButton: true,
//           );
//         }

//         // Se o usuário está em uma sala, verifica o estado dos pets
//         return petState.isLoading
//             ? const Center(
//                 child: CircularProgressIndicator()) // Carregando pets
//             : petState.favoritePet == null
//                 ? _buildPetAdoptionPrompt(
//                     context, room.id, room.isActive) // Sem pet, mas em sala
//                 : const PetCarePage(); // Tem pet(s) - mostra a tela de cuidados
//       },
//       loading: () => const Center(
//           child: CircularProgressIndicator()), // Carregando estado da sala
//       error: (error, _) => Center(
//         child: Text('Erro ao carregar sala: $error'),
//       ),
//     );
//   }

//   // Nova função para construir a tela de "sem pet" e adoção
//   Widget _buildPetAdoptionPrompt(
//       BuildContext context, String roomId, bool isRoomActive) {
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
//             Text(
//               'Você ainda não tem um pet!',
//               style: theme.textTheme.headlineSmall
//                   ?.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               isRoomActive
//                   ? 'Vocês podem adotar um pet agora!'
//                   : 'Aguardando parceiro para adotar um pet',
//               style: theme.textTheme.titleMedium
//                   ?.copyWith(color: Colors.grey[600]),
//               textAlign: TextAlign.center,
//             ),
//             if (isRoomActive) ...[
//               const SizedBox(height: 24),
//               ElevatedButton.icon(
//                 onPressed: () {
//                   // Navega para a página de adoção colaborativa
//                   context.push('/pet/adopt/$roomId');
//                 },
//                 icon: const Icon(Icons.favorite_border),
//                 label: const Text('Adotar um Pet'),
//                 style: ElevatedButton.styleFrom(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // Função genérica para exibir mensagens informativas
//   Widget _buildInfoView(
//     BuildContext context,
//     String message, {
//     required bool showButton,
//     String? buttonText,
//     VoidCallback? onButtonPressed,
//     IconData? icon,
//   }) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       appBar: AppBar(title: const Text('PetVerse')),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon ?? Icons.info_outline,
//                   size: 80, color: theme.colorScheme.secondary),
//               const SizedBox(height: 24),
//               Text(
//                 message,
//                 style: theme.textTheme.headlineSmall
//                     ?.copyWith(fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               if (showButton &&
//                   buttonText != null &&
//                   onButtonPressed != null) ...[
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: onButtonPressed,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 32, vertical: 16),
//                   ),
//                   child: Text(buttonText),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
