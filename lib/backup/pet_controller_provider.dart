// // lib/features/pet/presentation/providers/pet_controller_provider.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:petverse/core/providers/firebase_providers.dart';
// import 'package:petverse/feature/auth/providers/authentication_provider.dart';
// import 'package:petverse/feature/pet/model/pet.dart';
// import 'package:petverse/feature/pet/service/pet_service.dart';
// import 'package:petverse/feature/room/model/room.dart';
// import 'package:petverse/feature/room/provider/room_provider.dart';

// final petServiceProvider = Provider<PetService>((ref) {
//   final firestore = ref.read(firebaseFirestoreProvider);
//   final auth = ref.read(firebaseAuthProvider);
//   return PetService(firestore, auth);
// });

// class PetState {
//   final List<Pet> userPets;
//   final Pet? favoritePet;
//   final bool isLoading;
//   final String? error;

//   PetState({
//     this.userPets = const [],
//     this.favoritePet,
//     this.isLoading = true,
//     this.error,
//   });

//   PetState copyWith({
//     List<Pet>? userPets,
//     Pet? favoritePet,
//     bool? isLoading,
//     String? error,
//   }) {
//     return PetState(
//       userPets: userPets ?? this.userPets,
//       favoritePet: favoritePet ?? this.favoritePet,
//       isLoading: isLoading ?? this.isLoading,
//       error: error,
//     );
//   }
// }

// class PetController extends StateNotifier<PetState> {
//   final PetService _petService;
//   final Ref _ref;

//   PetController(this._petService, this._ref) : super(PetState()) {
//     _init();
//   }

//   void _init() {
//     _ref.listen<AsyncValue<Room?>>(roomControllerProvider,
//         (prevRoomState, nextRoomState) {
//       nextRoomState.when(
//         data: (room) {
//           if (room != null && room.id.isNotEmpty) {
//             _petService.getPetsForRoom(room.id).listen((pets) {
//               final currentFavoritePetId = state.favoritePet?.id;
//               Pet? newFavoritePet;

//               if (pets.isNotEmpty) {
//                 newFavoritePet = pets.firstWhere(
//                   (pet) => pet.id == currentFavoritePetId,
//                   orElse: () => pets.first,
//                 );
//               }

//               state = state.copyWith(
//                 userPets: pets,
//                 favoritePet: newFavoritePet,
//                 isLoading: false,
//                 error: null,
//               );
//             }, onError: (e) {
//               state = state.copyWith(
//                 isLoading: false,
//                 error: 'Erro ao carregar pets da sala: ${e.toString()}',
//               );
//             });
//           } else {
//             state = state.copyWith(
//                 userPets: [], favoritePet: null, isLoading: false, error: null);
//           }
//         },
//         loading: () {
//           state = state.copyWith(isLoading: true, error: null);
//         },
//         error: (e, st) {
//           state = state.copyWith(
//               isLoading: false,
//               error: 'Erro ao carregar sala: ${e.toString()}');
//         },
//       );
//     });
//   }

//   Future<void> feedPet(String petId) async {
//     final userId = _ref.read(authenticationNotifierProvider).user?.uid;
//     if (userId == null) {
//       state = state.copyWith(
//           error: 'Usuário não autenticado para alimentar o pet.');
//       return;
//     }
//     try {
//       state = state.copyWith(isLoading: true, error: null);
//       await _petService.feedPet(petId, userId);
//       state = state.copyWith(isLoading: false);
//     } catch (e) {
//       state = state.copyWith(
//           isLoading: false, error: 'Erro ao alimentar pet: ${e.toString()}');
//     }
//   }

//   Future<void> playWithPet(String petId) async {
//     final userId = _ref.read(authenticationNotifierProvider).user?.uid;
//     if (userId == null) {
//       state = state.copyWith(
//           error: 'Usuário não autenticado para brincar com o pet.');
//       return;
//     }
//     try {
//       state = state.copyWith(isLoading: true, error: null);
//       await _petService.playWithPet(petId, userId);
//       state = state.copyWith(isLoading: false);
//     } catch (e) {
//       state = state.copyWith(
//           isLoading: false, error: 'Erro ao brincar com pet: ${e.toString()}');
//     }
//   }

//   Future<void> cleanPet(String petId) async {
//     final userId = _ref.read(authenticationNotifierProvider).user?.uid;
//     if (userId == null) {
//       state =
//           state.copyWith(error: 'Usuário não autenticado para limpar o pet.');
//       return;
//     }
//     try {
//       state = state.copyWith(isLoading: true, error: null);
//       await _petService.cleanPet(petId, userId);
//       state = state.copyWith(isLoading: false);
//     } catch (e) {
//       state = state.copyWith(
//           isLoading: false, error: 'Erro ao limpar pet: ${e.toString()}');
//     }
//   }

//   void setFavoritePet(Pet pet) {
//     state = state.copyWith(favoritePet: pet);
//   }

//   Future<void> adoptPet({
//     required String petName,
//     required String roomId,
//     required List<String> parentIds,
//   }) async {
//     try {
//       state = state.copyWith(isLoading: true, error: null);
//       await _petService.createPet(
//           petName: petName, roomId: roomId, parentIds: parentIds);
//       state = state.copyWith(isLoading: false, error: null);
//     } catch (e) {
//       state = state.copyWith(
//           isLoading: false, error: 'Erro ao adotar pet: ${e.toString()}');
//       rethrow;
//     }
//   }
// }

// final petControllerProvider =
//     StateNotifierProvider<PetController, PetState>((ref) {
//   final petService = ref.watch(petServiceProvider);
//   return PetController(petService, ref);
// });

// final favoritePetProvider = Provider<Pet?>((ref) {
//   return ref.watch(petControllerProvider).favoritePet;
// });

// final userPetsListProvider = Provider<List<Pet>>((ref) {
//   return ref.watch(petControllerProvider).userPets;
// });

// final petStreamProvider = StreamProvider.family<Pet?, String>((ref, petId) {
//   final petService = ref.watch(petServiceProvider);
//   return petService.getPetStream(petId);
// });

// final allPetsInRoomStreamProvider =
//     StreamProvider.family<List<Pet>, String>((ref, roomId) {
//   final petService = ref.watch(petServiceProvider);
//   return petService.getPetsForRoom(roomId);
// });





// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Para pegar o UID do usuário
// import 'package:petverse/feature/pet/model/pet.dart'; // Assumindo que você tem UserModel

// class PetService {
//   final FirebaseFirestore _firestore;
//   final FirebaseAuth _auth;

//   PetService(this._firestore, this._auth);

//   // Método para obter um stream de todos os pets de uma sala específica
//   Stream<List<Pet>> getPetsForRoom(String roomId) {
//     return _firestore
//         .collection('pets')
//         .where('roomId', isEqualTo: roomId)
//         .snapshots()
//         .map((snapshot) =>
//             snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList());
//   }

//   // Método para obter um stream de UM pet específico (pode ser o favorito)
//   Stream<Pet?> getPetStream(String petId) {
//     return _firestore.collection('pets').doc(petId).snapshots().map((doc) {
//       if (doc.exists) {
//         return Pet.fromFirestore(doc);
//       }
//       return null;
//     });
//   }

//   // Método para criar um novo pet (chamado na adoção)
//   Future<void> createPet({
//     required String petName,
//     required String roomId,
//     required List<String> parentIds, // UIDs dos usuários na sala
//   }) async {
//     final newPetRef =
//         _firestore.collection('pets').doc(); // Firestore gera o ID
//     final newPet = Pet(
//       id: newPetRef.id,
//       name: petName,
//       roomId: roomId,
//       parentIds: parentIds,
//       hunger: 100, // Valores iniciais
//       happiness: 100,
//       cleanliness: 100,
//       lastFed: DateTime.now(),
//       lastPlayed: DateTime.now(),
//       lastCleaned: DateTime.now(),
//       createdAt: DateTime.now(),
//     );
//     await newPetRef.set(newPet.toFirestore());

//     // Opcional: Atualizar a sala com o ID do pet (se a sala deve ter um pet principal)
//     await _firestore.collection('rooms').doc(roomId).update({
//       'petIds':
//           FieldValue.arrayUnion([newPet.id]), // Adiciona o pet à lista da sala
//       // 'currentPetId': newPet.id, // Se a sala tem um pet "ativo"
//     });

//     // Opcional: Atualizar o UserModel dos pais com o pet favorito (se o pet for o primeiro)
//     for (String userId in parentIds) {
//       await _firestore.collection('users').doc(userId).update({
//         'petIds': FieldValue.arrayUnion([newPet.id]),
//         // 'favoritePetId': newPet.id, // Se o usuário tiver um pet favorito
//       });
//     }
//   }

//   // Métodos de ação do pet (cuidado)
//   Future<void> feedPet(String petId, String userId) async {
//     await _firestore.collection('pets').doc(petId).update({
//       'hunger': 100, // Enche a fome
//       'lastFed': FieldValue.serverTimestamp(),
//       'lastCaredBy': userId,
//     });
//     // Opcional: recompensar o usuário
//   }

//   Future<void> playWithPet(String petId, String userId) async {
//     await _firestore.collection('pets').doc(petId).update({
//       'happiness': FieldValue.increment(20), // Aumenta felicidade
//       'lastPlayed': FieldValue.serverTimestamp(),
//       'lastCaredBy': userId,
//     });
//     // Opcional: recompensar o usuário
//   }

//   Future<void> cleanPet(String petId, String userId) async {
//     await _firestore.collection('pets').doc(petId).update({
//       'cleanliness': 100, // Limpa o pet
//       'lastCleaned': FieldValue.serverTimestamp(),
//       'lastCaredBy': userId,
//     });
//     // Opcional: recompensar o usuário
//   }

//   // Método para deletar um pet
//   Future<void> deletePet(String petId) async {
//     await _firestore.collection('pets').doc(petId).delete();
//     // Opcional: remover o pet de salas e usuários
//   }
// }



// // lib/features/pet/pages/pet_care_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:petverse/feature/pet/model/pet.dart';
// import 'package:petverse/feature/pet/provider/pet_provider.dart';
// import 'package:petverse/feature/pet/widgets/care_button.dart';
// import 'package:petverse/feature/pet/widgets/floating_emoji.dart';
// import 'package:petverse/feature/pet/widgets/pet_avatar.dart';
// import 'package:petverse/feature/pet/widgets/status_bar.dart';

// class PetCarePage extends ConsumerStatefulWidget {
//   const PetCarePage({super.key});

//   @override
//   ConsumerState<PetCarePage> createState() => _PetCarePageState();
// }

// class _PetCarePageState extends ConsumerState<PetCarePage>
//     with TickerProviderStateMixin {
//   late AnimationController _breathingController;
//   late AnimationController _floatingController;

//   final List<FloatingEmoji> _floatingEmojis = [];
//   final bool _isDraggingFood = false;
//   final bool _isDraggingToy = false;
//   final bool _isDraggingShower = false;

//   @override
//   void initState() {
//     super.initState();
//     _breathingController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     )..repeat(reverse: true);

//     _floatingController = AnimationController(
//       duration: const Duration(seconds: 4),
//       vsync: this,
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _breathingController.dispose();
//     _floatingController.dispose();
//     super.dispose();
//   }

//   void _showFloatingEmoji(String emoji, Offset position) {
//     final newEmoji = FloatingEmoji(
//       emoji: emoji,
//       position: position,
//       key: UniqueKey(),
//     );

//     setState(() {
//       _floatingEmojis.add(newEmoji);
//     });

//     // Remover após animação
//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) {
//         setState(() {
//           _floatingEmojis.removeWhere((e) => e.key == newEmoji.key);
//         });
//       }
//     });
//   }

//   Future<void> _feedPet() async {
//     final offset = Offset(
//       MediaQuery.of(context).size.width / 2,
//       MediaQuery.of(context).size.height / 2,
//     );

//     _showFloatingEmoji('🍖', offset);
//     await ref.read(petControllerProvider.notifier).feedPet();

//     // Vibração suave (adicionar haptic_feedback no pubspec)
//     // HapticFeedback.lightImpact();
//   }

//   Future<void> _playWithPet() async {
//     final offset = Offset(
//       MediaQuery.of(context).size.width / 2,
//       MediaQuery.of(context).size.height / 2,
//     );

//     _showFloatingEmoji('🎾', offset);
//     await ref.read(petControllerProvider.notifier).playWithPet();
//   }

//   Future<void> _cleanPet() async {
//     final offset = Offset(
//       MediaQuery.of(context).size.width / 2,
//       MediaQuery.of(context).size.height / 2,
//     );

//     _showFloatingEmoji('🫧', offset);
//     await ref.read(petControllerProvider.notifier).cleanPet();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final petState = ref.watch(petStreamProvider);
//     final theme = Theme.of(context);

//     return petState.when(
//       data: (pet) {
//         if (pet == null) {
//           return const Center(
//             child: Text('Nenhum pet encontrado'),
//           );
//         }

//         return Scaffold(
//           body: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   _getBackgroundColorForMood(pet.mood).withOpacity(0.3),
//                   theme.colorScheme.surface,
//                 ],
//               ),
//             ),
//             child: SafeArea(
//               child: Stack(
//                 children: [
//                   // Decoração de fundo animada
//                   ..._buildBackgroundDecorations(),

//                   // Conteúdo principal
//                   Column(
//                     children: [
//                       // Header com nome do pet
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   pet.name,
//                                   style:
//                                       theme.textTheme.headlineMedium?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   'Nível ${_calculateLevel(pet)}',
//                                   style: theme.textTheme.bodyLarge?.copyWith(
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 8,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: _getMoodColor(pet.mood),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 pet.status,
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ).animate().fadeIn().slideX(begin: -0.2, end: 0),

//                       // Pet Avatar
//                       Expanded(
//                         child: Center(
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               // Sombra animada
//                               Container(
//                                 width: 200,
//                                 height: 40,
//                                 decoration: BoxDecoration(
//                                   color: Colors.black.withOpacity(0.2),
//                                   borderRadius: BorderRadius.circular(100),
//                                 ),
//                               )
//                                   .animate(
//                                     onPlay: (controller) =>
//                                         controller.repeat(reverse: true),
//                                   )
//                                   .scaleX(
//                                       begin: 0.8, end: 1.0, duration: 3.seconds)
//                                   .fade(begin: 0.3, end: 0.5),

//                               // Pet com animação de respiração
//                               AnimatedBuilder(
//                                 animation: _breathingController,
//                                 builder: (context, child) {
//                                   return Transform.scale(
//                                     scale: 1.0 +
//                                         (_breathingController.value * 0.05),
//                                     child: PetAvatar(
//                                       pet: pet,
//                                       size: 250,
//                                     ),
//                                   );
//                                 },
//                               ),

//                               // Indicadores de status ao redor do pet
//                               ..._buildStatusIndicators(pet),
//                             ],
//                           ),
//                         ),
//                       ),

//                       // Barras de Status
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 24),
//                         child: Column(
//                           children: [
//                             StatusBar(
//                               label: 'Fome',
//                               value: pet.hunger,
//                               color: Colors.orange,
//                               icon: Icons.restaurant,
//                             ),
//                             const SizedBox(height: 12),
//                             StatusBar(
//                               label: 'Felicidade',
//                               value: pet.happiness,
//                               color: Colors.pink,
//                               icon: Icons.favorite,
//                             ),
//                             const SizedBox(height: 12),
//                             StatusBar(
//                               label: 'Limpeza',
//                               value: pet.cleanliness,
//                               color: Colors.blue,
//                               icon: Icons.water_drop,
//                             ),
//                           ],
//                         ),
//                       )
//                           .animate()
//                           .fadeIn(delay: 300.ms)
//                           .slideY(begin: 0.2, end: 0),

//                       // Botões de Ação
//                       Container(
//                         padding: const EdgeInsets.all(24),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           children: [
//                             CareButton(
//                               icon: Icons.restaurant,
//                               label: 'Alimentar',
//                               color: Colors.orange,
//                               onTap: _feedPet,
//                               isDisabled: pet.hunger > 80,
//                             ),
//                             CareButton(
//                               icon: Icons.sports_baseball,
//                               label: 'Brincar',
//                               color: Colors.pink,
//                               onTap: _playWithPet,
//                               isDisabled: pet.happiness > 80,
//                             ),
//                             CareButton(
//                               icon: Icons.bathtub,
//                               label: 'Banho',
//                               color: Colors.blue,
//                               onTap: _cleanPet,
//                               isDisabled: pet.cleanliness > 80,
//                             ),
//                           ],
//                         ),
//                       )
//                           .animate()
//                           .fadeIn(delay: 400.ms)
//                           .slideY(begin: 0.3, end: 0),
//                     ],
//                   ),

//                   // Emojis flutuantes
//                   ..._floatingEmojis,
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (error, _) => Center(child: Text('Erro: $error')),
//     );
//   }

//   List<Widget> _buildBackgroundDecorations() {
//     return [
//       // Nuvens flutuantes
//       Positioned(
//         top: 50,
//         left: -50,
//         child: AnimatedBuilder(
//           animation: _floatingController,
//           builder: (context, child) {
//             return Transform.translate(
//               offset: Offset(_floatingController.value * 30, 0),
//               child: Container(
//                 width: 100,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//       Positioned(
//         top: 100,
//         right: -30,
//         child: AnimatedBuilder(
//           animation: _floatingController,
//           builder: (context, child) {
//             return Transform.translate(
//               offset: Offset(-_floatingController.value * 20, 0),
//               child: Container(
//                 width: 80,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     ];
//   }

//   List<Widget> _buildStatusIndicators(Pet pet) {
//     final indicators = <Widget>[];

//     if (pet.isHungry) {
//       indicators.add(
//         Positioned(
//           top: 0,
//           right: 0,
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: const BoxDecoration(
//               color: Colors.orange,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.restaurant,
//               color: Colors.white,
//               size: 20,
//             ),
//           )
//               .animate(onPlay: (controller) => controller.repeat())
//               .scale(
//                   begin: const Offset(0.8, 0),
//                   end: const Offset(1.2, 0),
//                   duration: 1.seconds)
//               .then()
//               .scale(
//                   begin: const Offset(1.2, 0),
//                   end: const Offset(0.8, 0),
//                   duration: 1.seconds),
//         ),
//       );
//     }

//     if (pet.isSad) {
//       indicators.add(
//         Positioned(
//           top: 0,
//           left: 0,
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: const BoxDecoration(
//               color: Colors.pink,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.sports_baseball,
//               color: Colors.white,
//               size: 20,
//             ),
//           )
//               .animate(onPlay: (controller) => controller.repeat())
//               .shake(hz: 3, duration: 1.seconds)
//               .then(delay: 1.seconds),
//         ),
//       );
//     }

//     if (pet.isDirty) {
//       indicators.add(
//         Positioned(
//           bottom: 0,
//           right: 0,
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: const BoxDecoration(
//               color: Colors.blue,
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.water_drop,
//               color: Colors.white,
//               size: 20,
//             ),
//           )
//               .animate(onPlay: (controller) => controller.repeat())
//               .rotate(duration: 2.seconds),
//         ),
//       );
//     }

//     return indicators;
//   }

//   Color _getBackgroundColorForMood(String mood) {
//     switch (mood) {
//       case 'sleepy':
//         return Colors.indigo;
//       case 'energetic':
//         return Colors.orange;
//       case 'playful':
//         return Colors.pink;
//       default:
//         return Colors.purple;
//     }
//   }

//   Color _getMoodColor(String mood) {
//     switch (mood) {
//       case 'sleepy':
//         return Colors.indigo;
//       case 'energetic':
//         return Colors.orange;
//       case 'playful':
//         return Colors.pink;
//       default:
//         return Colors.purple;
//     }
//   }

//   int _calculateLevel(Pet pet) {
//     // Lógica simples de nível baseada em interações
//     final totalInteractions =
//         (100 - pet.hunger) + pet.happiness + pet.cleanliness;
//     return (totalInteractions / 100).floor() + 1;
//   }
// }
