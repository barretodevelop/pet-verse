// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // Se quiser mostrar loading ou erro
// import 'package:petverse/feature/pet/model/pet.dart';

// class PetActionButtons extends ConsumerWidget {
//   final Pet pet;
//   final VoidCallback onFeed;
//   final VoidCallback onPlay;
//   final VoidCallback onClean;

//   const PetActionButtons({
//     super.key,
//     required this.pet,
//     required this.onFeed,
//     required this.onPlay,
//     required this.onClean,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Você pode observar o isLoading do petControllerProvider aqui
//     // para desabilitar os botões enquanto uma ação está em andamento.
//     // final isLoading = ref.watch(petControllerProvider).isLoading;

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         _buildActionButton(
//           icon: Icons.restaurant,
//           label: 'Alimentar',
//           onPressed: onFeed,
//           // disabled: isLoading, // Desabilita se estiver carregando
//         ),
//         _buildActionButton(
//           icon: Icons.sports_tennis,
//           label: 'Brincar',
//           onPressed: onPlay,
//           // disabled: isLoading,
//         ),
//         _buildActionButton(
//           icon: Icons.bathtub,
//           label: 'Limpar',
//           onPressed: onClean,
//           // disabled: isLoading,
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onPressed,
//     // bool disabled = false, // Adicione este parâmetro
//   }) {
//     return Column(
//       children: [
//         FloatingActionButton(
//           heroTag: label, // Importante para evitar erros de Hero
//           onPressed: onPressed, // disabled ? null : onPressed,
//           child: Icon(icon),
//         ),
//         const SizedBox(height: 8),
//         Text(label),
//       ],
//     );
//   }
// }
