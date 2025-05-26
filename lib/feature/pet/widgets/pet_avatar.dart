import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:petverse/feature/pet/model/pet.dart';

class PetAvatar extends StatelessWidget {
  final Pet pet;
  final double size;

  const PetAvatar({
    super.key,
    required this.pet,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getPetColor(pet),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _getPetColor(pet).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Corpo do pet (placeholder - substituir por sprite real)
          Text(
            _getPetEmoji(pet),
            style: TextStyle(fontSize: size * 0.5),
          ),

          // Olhos piscando
          Positioned(
            top: size * 0.3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildEye(),
                SizedBox(width: size * 0.1),
                _buildEye(),
              ],
            ),
          ),

          // Expressão baseada no mood
          if (pet.mood == 'sleepy')
            Positioned(
              top: size * 0.25,
              right: size * 0.2,
              child: const Text('💤', style: TextStyle(fontSize: 20))
                  .animate(onPlay: (controller) => controller.repeat())
                  .fade(begin: 0.5, end: 1.0, duration: 2.seconds)
                  .moveY(begin: 0, end: -10, duration: 2.seconds),
            ),
        ],
      ),
    );
  }

  Widget _buildEye() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .scaleY(
          begin: 1.0,
          end: 0.1,
          duration: 200.ms,
          delay: 3.seconds,
        )
        .then()
        .scaleY(
          begin: 0.1,
          end: 1.0,
          duration: 200.ms,
        );
  }

  Color _getPetColor(Pet pet) {
    // Baseado no tipo do pet (será definido durante adoção)
    // Por enquanto, retorna uma cor padrão
    return Colors.orange.shade200;
  }

  String _getPetEmoji(Pet pet) {
    // Baseado no tipo do pet
    // Por enquanto, retorna um emoji padrão
    return '🐱';
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:petverse/feature/pet/model/pet.dart';

// class PetAvatar extends StatelessWidget {
//   final Pet pet;
//   final double size;

//   const PetAvatar({
//     super.key,
//     required this.pet,
//     this.size = 100,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: _getPetColor(pet).withOpacity(0.9),
//         boxShadow: [
//           BoxShadow(
//             color: _getPetColor(pet).withOpacity(0.25),
//             blurRadius: 25,
//             spreadRadius: 8,
//             offset: const Offset(0, 10),
//           ),
//         ],
//         border: Border.all(
//           color: Colors.white.withOpacity(0.6),
//           width: 4,
//         ),
//         gradient: RadialGradient(
//           colors: [
//             // _getPetColor(pet).lighten(0.1),
//             _getPetColor(pet),
//           ],
//           center: Alignment.center,
//           radius: 0.7,
//         ),
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Emoji central (representa o corpo ou rosto)
//           Text(
//             _getPetEmoji(pet),
//             style: TextStyle(
//               fontSize: size * 0.6,
//               shadows: [
//                 Shadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 )
//               ],
//             ),
//           ).animate().scaleXY(begin: 0.8, end: 1.0, duration: 0.8.seconds),

//           // Olhos piscando
//           Positioned(
//             top: size * 0.3,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _buildEye(),
//                 SizedBox(width: size * 0.1),
//                 _buildEye(),
//               ],
//             ),
//           ),

//           // Expressão baseada no mood
//           if (pet.mood == 'sleepy')
//             Positioned(
//               top: size * 0.2,
//               right: size * 0.15,
//               child: const Text('💤', style: TextStyle(fontSize: 24))
//                   .animate(onPlay: (controller) => controller.repeat())
//                   .fade(begin: 0.4, end: 1.0, duration: 2.seconds)
//                   .moveY(begin: 0, end: -10, duration: 2.seconds),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEye() {
//     return Container(
//       width: 10,
//       height: 10,
//       decoration: const BoxDecoration(
//         color: Colors.black,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.white,
//             blurRadius: 2,
//             spreadRadius: 1,
//           )
//         ],
//       ),
//     )
//         .animate(onPlay: (controller) => controller.repeat())
//         .scaleY(
//           begin: 1.0,
//           end: 0.1,
//           duration: 200.ms,
//           delay: 3.seconds,
//         )
//         .then()
//         .scaleY(
//           begin: 0.1,
//           end: 1.0,
//           duration: 200.ms,
//         );
//   }

//   Color _getPetColor(Pet pet) {
//     return const Color.fromARGB(255, 4, 194, 90);
//   }

//   String _getPetEmoji(Pet pet) {
//     return '🐱';
//   }
// }

// // Extension pra clareza de cor (opcional)
// // extension ColorUtils on Color {
// //   Color darken([double amount = .1]) => HSLColor.fromColor(this)
// //       .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
// //       .toColor();

// //   Color lighten([double amount = .1]) => HSLColor.fromColor(this)
// //       .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
// //       .toColor();
// // }
