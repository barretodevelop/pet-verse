// PetSlots Component (Já foi gerado, mas é usado aqui)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_notifier.dart';

class PetSlots extends ConsumerWidget {
  final VoidCallback onSlotClick; // Callback para abrir o fluxo de adoção

  const PetSlots({super.key, required this.onSlotClick});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appServiceProvider);
    final appService = ref.read(appServiceProvider.notifier);

    final pets = appState.pets;
    final activePetIndex = appState.activePetIndex;
    final unlockedSlots = appService.unlockedSlots;
    final pendingAdoptions = appState.pendingAdoptions;
    final gems = appState.gems;
    final isDark = appState.isDark;

    final ValueNotifier<bool> showUnlockConfirm = ValueNotifier<bool>(false);

    void handleUnlockSlot() {
      if (appService.unlockSlot()) {
        showUnlockConfirm.value = false;
      }
    }

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              ...List.generate(appService.maxSlots, (index) {
                final pet = pets.length > index ? pets[index] : null;
                final isActive = index == activePetIndex;
                final isLocked = index >= unlockedSlots;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      if (isLocked) {
                        showUnlockConfirm.value = true;
                      } else if (pet != null) {
                        appService.setActivePetIndex(index);
                      } else {
                        onSlotClick();
                      }
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.purple.shade50
                            : isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: isActive
                              ? Colors.purple.shade500
                              : isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade200,
                          width: 2.0,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: Colors.purple.shade200.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isLocked) ...[
                            const Icon(Icons.lock, size: 32, color: Colors.grey),
                            Positioned(
                              bottom: -4,
                              right: -4,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade500,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.diamond, color: Colors.white, size: 14),
                              ),
                            ),
                          ] else if (pet != null) ...[
                            Text(
                              pet.isUnique ? '✨' : pet.emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey.shade600 : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    pet.level.toString(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (pet.isCollab)
                              Positioned(
                                bottom: -4,
                                left: -4,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade500,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.group, color: Colors.white, size: 14),
                                ),
                              ),
                            if (pet.accessories.isNotEmpty)
                              Positioned(
                                bottom: -4,
                                right: -4,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade500,
                                    shape: BoxShape.circle,
                                  ),
                                  child:
                                      const Icon(Icons.shopping_bag, color: Colors.white, size: 14),
                                ),
                              ),
                          ] else ...[
                            Icon(
                              Icons.add,
                              size: 32,
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (pendingAdoptions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.yellow.shade900.withOpacity(0.2) : Colors.yellow.shade50,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: isDark ? Colors.yellow.shade600 : Colors.yellow.shade400,
                        width: 2.0,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.schedule, size: 32, color: Colors.yellow.shade500),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.yellow.shade500,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                pendingAdoptions.length.toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}




// // PetSlots Component
// class PetSlots extends ConsumerWidget {
//   final VoidCallback onSlotClick; // Callback para abrir o fluxo de adoção ou modal de desbloqueio

//   const PetSlots({super.key, required this.onSlotClick});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final appState = ref.watch(appServiceProvider);
//     final appService = ref.read(appServiceProvider.notifier);

//     final pets = appState.pets;
//     final activePetIndex = appState.activePetIndex;
//     final unlockedSlots = appService.unlockedSlots; // Usar getter do service
//     final pendingAdoptions = appState.pendingAdoptions;
//     final isDark = appState.isDark;

//     return Column(
//       children: [
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//           child: Row(
//             children: [ // Início da lista de children do Row
//               ...List.generate(appService.maxSlots, (index) { // Gerar até o maxSlots
//                 final pet = pets.length > index ? pets[index] : null;
//                 final isActive = index == activePetIndex;
//                 final isLocked = index >= unlockedSlots;

//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                   child: GestureDetector(
//                     onTap: () {
//                       if (isLocked) {
//                         onSlotClick(); // Chamar callback para pedir desbloqueio (gerenciado na HomeScreen)
//                       } else if (pet != null) {
//                         appService.setActivePetIndex(index);
//                       } else {
//                         onSlotClick(); // Chamar callback para abrir fluxo de adoção (gerenciado na HomeScreen)
//                       }
//                     },
//                     child: Container(
//                       width: 64, // w-16
//                       height: 64, // h-16
//                       decoration: BoxDecoration(
//                         color: isActive
//                             ? Colors.purple.shade50 // bg-purple-50
//                             : isDark
//                                 ? Colors.grey.shade700 // bg-gray-700
//                                 : Colors.grey.shade50, // bg-gray-50
//                         borderRadius: BorderRadius.circular(16.0), // rounded-2xl
//                         border: Border.all(
//                           color: isActive
//                               ? Colors.purple.shade500 // border-purple-500
//                               : isDark
//                                   ? Colors.grey.shade600 // border-gray-600
//                                   : Colors.grey.shade200, // border-gray-200
//                           width: 2.0,
//                         ),
//                         boxShadow: isActive
//                             ? [
//                                 BoxShadow(
//                                   color: Colors.purple.shade200.withOpacity(0.5),
//                                   blurRadius: 8,
//                                   spreadRadius: 2,
//                                 )
//                               ]
//                             : [],
//                       ),
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           if (isLocked) ...[
//                             const Icon(Icons.lock, size: 32, color: Colors.grey), // 🔒
//                             Positioned(
//                               bottom: -4,
//                               right: -4,
//                               child: Container(
//                                 width: 24,
//                                 height: 24,
//                                 decoration: BoxDecoration(
//                                   color: Colors.purple.shade500,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(LucideIcons.gem, color: Colors.white, size: 14),
//                               ),
//                             ),
//                           ] else if (pet != null) ...[
//                             Text(
//                               pet.isUnique ? '✨' : pet.emoji,
//                               style: const TextStyle(fontSize: 32),
//                             ),
//                             Positioned(
//                               top: -4,
//                               right: -4,
//                               child: Container(
//                                 width: 24,
//                                 height: 24,
//                                 decoration: BoxDecoration(
//                                   color: isDark ? Colors.grey.shade600 : Colors.white,
//                                   shape: BoxShape.circle,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.1),
//                                       blurRadius: 4,
//                                       spreadRadius: 1,
//                                     ),
//                                   ],
//                                 ),
//                                 child: Center(
//                                   child: Text(
//                                     pet.level.toString(),
//                                     style: TextStyle(
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold,
//                                       color: isDark ? Colors.white : Colors.grey.shade800,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             if (pet.isCollab)
//                               Positioned(
//                                 bottom: -4,
//                                 left: -4,
//                                 child: Container(
//                                   width: 24,
//                                   height: 24,
//                                   decoration: BoxDecoration(
//                                     color: Colors.purple.shade500,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(LucideIcons.users, color: Colors.white, size: 14),
//                                 ),
//                               ),
//                             if (pet.accessories.isNotEmpty)
//                               Positioned(
//                                 bottom: -4,
//                                 right: -4,
//                                 child: Container(
//                                   width: 24,
//                                   height: 24,
//                                   decoration: BoxDecoration(
//                                     color: Colors.green.shade500,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(LucideIcons.package, color: Colors.white, size: 14),
//                                 ),
//                               ),
//                           ] else ...[
//                             Icon(LucideIcons.plus,
//                                 size: 32,
//                                 color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(), // Vírgula adicionada aqui
              
//               // Slot para adoções pendentes (agora corretamente separado pelo comma)
//               if (pendingAdoptions.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                   child: Container(
//                     width: 64,
//                     height: 64,
//                     decoration: BoxDecoration(
//                       color: isDark ? Colors.yellow.shade900.withOpacity(0.2) : Colors.yellow.shade50,
//                       borderRadius: BorderRadius.circular(16.0),
//                       border: Border.all(
//                         color: isDark ? Colors.yellow.shade600 : Colors.yellow.shade400,
//                         width: 2.0,
//                         style: BorderStyle.dashed,
//                       ),
//                     ),
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         Icon(LucideIcons.clock, size: 32, color: Colors.yellow.shade500),
//                         Positioned(
//                           top: -4,
//                           right: -4,
//                           child: Container(
//                             width: 24,
//                             height: 24,
//                             decoration: BoxDecoration(
//                               color: Colors.yellow.shade500,
//                               shape: BoxShape.circle,
//                             ),
//                             child: Center(
//                               child: Text(
//                                 pendingAdoptions.length.toString(),
//                                 style: const TextStyle(
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             ], // Fim da lista de children do Row
//           ),
//         ),
//       ],
//     );
//   }
// }