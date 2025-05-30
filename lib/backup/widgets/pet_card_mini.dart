// import 'package:flutter/material.dart';
// import 'package:petverse/feature/pet/model/pet.dart';

// class PetCardMini extends StatelessWidget {
//   final Pet pet;
//   final VoidCallback onTap;

//   const PetCardMini({
//     super.key,
//     required this.pet,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 8),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         elevation: 2,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircleAvatar(
//                 radius: 30,
//                 backgroundColor: theme.colorScheme.primaryContainer,
//                 // Substitua pela imagem do pet
//                 child:
//                     Image.asset('assets/images/pet_icon_mini.png', height: 40),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 pet.name,
//                 style: theme.textTheme.labelSmall
//                     ?.copyWith(fontWeight: FontWeight.bold),
//                 overflow: TextOverflow.ellipsis,
//               ),
//               Text(
//                 pet.status,
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: pet.isHungry || pet.isSad || pet.isDirty
//                       ? Colors.red
//                       : Colors.green,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
