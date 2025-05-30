// import 'dart:async';

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:petverse/feature/pet/model/pet.dart';
// import 'package:petverse/feature/pet/provider/pet_controller_provider.dart'
//     hide PetState;
// import 'package:petverse/feature/room/model/room.dart';
// import 'package:petverse/feature/room/provider/room_provider.dart';

// class PetController extends StateNotifier<PetState> {
//   final PetService _petService;
//   final PetGameLogic _gameLogic;
//   final Ref _ref;
//   Timer? _degradationTimer;

//   PetController(this._petService, Ref ref)
//       : _gameLogic = PetGameLogic(),
//         _ref = ref,
//         super(const PetState()) {
//     _init();
//     _startDegradationTimer();
//   }

//   @override
//   void dispose() {
//     _degradationTimer?.cancel();
//     super.dispose();
//   }

//   void _init() {
//     _ref.listen<AsyncValue<Room?>>(roomControllerProvider,
//         (prevRoomState, nextRoomState) {
//       nextRoomState.when(
//         data: (room) {
//           if (room != null && room.id.isNotEmpty) {
//             _petService.getPetsForRoom(room.id).listen((pets) {
//               // Aplica degradação temporal a todos os pets
//               final updatedPets =
//                   pets.map((pet) => pet.updateWithCurrentTime()).toList();

//               final currentFavoritePetId = state.favoritePet?.id;
//               Pet? newFavoritePet;

//               if (updatedPets.isNotEmpty) {
//                 newFavoritePet = updatedPets.firstWhere(
//                   (pet) => pet.id == currentFavoritePetId,
//                   orElse: () => updatedPets.first,
//                 );
//               }

//               state = state.copyWith(
//                 userPets: updatedPets,
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

//   // Timer para atualizar degradação a cada 5 minutos
//   void _startDegradationTimer() {
//     _degradationTimer = Timer.periodic(const Duration(minutes: 5), (_) {
//       if (state.userPets.isNotEmpty) {
//         final updatedPets =
//             state.userPets.map((pet) => pet.updateWithCurrentTime()).toList();

//         final updatedFavorite = state.favoritePet?.updateWithCurrentTime();

//         state = state.copyWith(
//           userPets: updatedPets,
//           favoritePet: updatedFavorite,
//         );
//       }
//     });
//   }

//   // Método genérico para executar ações
//   Future<void> _performPetAction(
//     String petId,
//     String actionName,
//     Pet Function(PetStats) actionFunction,
//   ) async {
//     final userId = _ref.read(authenticationNotifierProvider).user?.uid;
//     if (userId == null) {
//       state = state.copyWith(
//         lastActionResult: const PetActionResultData(
//           result: PetActionResult.error,
//           message: 'Usuário não autenticado.',
//         ),
//       );
//       return;
//     }

//     final pet = state.userPets.firstWhere(
//       (p) => p.id == petId,
//       orElse: () => throw Exception('Pet não encontrado'),
//     );

//     try {
//       // Aplica degradação temporal primeiro
//       final currentPet = pet.updateWithCurrentTime();

//       // Tenta executar a ação na lógica do jogo
//       final updatedStats = actionFunction(currentPet.stats);
//       final updatedProgression =
//           currentPet.progression.addExperience(actionName);

//       final updatedPet = currentPet.copyWith(
//         stats: updatedStats,
//         progression: updatedProgression,
//       );

//       // Atualiza estado local primeiro (feedback imediato)
//       _updatePetInState(updatedPet);

//       // Sincroniza com servidor
//       await _petService.updatePet(updatedPet);

//       state = state.copyWith(
//         lastActionResult: PetActionResultData(
//           result: PetActionResult.success,
//           message: _getSuccessMessage(actionName),
//         ),
//       );
//     } on PetActionException catch (e) {
//       final cooldownMinutes =
//           _gameLogic.getCooldownRemaining(pet.stats, actionName);
//       state = state.copyWith(
//         lastActionResult: PetActionResultData(
//           result: PetActionResult.cooldown,
//           message: e.message,
//           cooldownMinutes: cooldownMinutes,
//         ),
//       );
//     } catch (e) {
//       state = state.copyWith(
//         lastActionResult: PetActionResultData(
//           result: PetActionResult.error,
//           message: 'Erro ao $actionName: ${e.toString()}',
//         ),
//       );
//     }
//   }

//   void _updatePetInState(Pet updatedPet) {
//     final updatedPets = state.userPets.map((pet) {
//       return pet.id == updatedPet.id ? updatedPet : pet;
//     }).toList();

//     final updatedFavorite =
//         state.favoritePet?.id == updatedPet.id ? updatedPet : state.favoritePet;

//     state = state.copyWith(
//       userPets: updatedPets,
//       favoritePet: updatedFavorite,
//     );
//   }

//   String _getSuccessMessage(String action) {
//     switch (action) {
//       case 'feed':
//         return '🍽️ Pet alimentado com sucesso!';
//       case 'play':
//         return '🎾 Que brincadeira divertida!';
//       case 'clean':
//         return '🛁 Pet está limpinho agora!';
//       case 'sleep':
//         return '😴 Pet descansou bem!';
//       default:
//         return 'Ação realizada com sucesso!';
//     }
//   }

//   // Métodos de ação específicos
//   Future<void> feedPet(String petId) async {
//     await _performPetAction(petId, 'feed', _gameLogic.feedPet);
//   }

//   Future<void> playWithPet(String petId) async {
//     await _performPetAction(petId, 'play', _gameLogic.playWithPet);
//   }

//   Future<void> cleanPet(String petId) async {
//     await _performPetAction(petId, 'clean', _gameLogic.cleanPet);
//   }

//   Future<void> sleepPet(String petId) async {
//     await _performPetAction(petId, 'sleep', _gameLogic.sleepPet);
//   }

//   void setFavoritePet(Pet pet) {
//     state = state.copyWith(favoritePet: pet);
//   }

//   void clearLastActionResult() {
//     state = state.copyWith(lastActionResult: null);
//   }

//   // Métodos de informação
//   bool canPerformAction(String petId, String action) {
//     final pet = state.userPets.firstWhere(
//       (p) => p.id == petId,
//       orElse: () => throw Exception('Pet não encontrado'),
//     );

//     return _gameLogic.canPerformAction(pet.stats, action);
//   }

//   int getCooldownRemaining(String petId, String action) {
//     final pet = state.userPets.firstWhere(
//       (p) => p.id == petId,
//       orElse: () => throw Exception('Pet não encontrado'),
//     );

//     return _gameLogic.getCooldownRemaining(pet.stats, action);
//   }

//   Future<void> adoptPet({
//     required String petName,
//     required String roomId,
//     required List<String> parentIds,
//   }) async {
//     try {
//       state = state.copyWith(isLoading: true, error: null);
//       await _petService.createPet(
//         petName: petName,
//         roomId: roomId,
//         parentIds: parentIds,
//       );
//       state = state.copyWith(isLoading: false, error: null);
//     } catch (e) {
//       state = state.copyWith(
//         isLoading: false,
//         error: 'Erro ao adotar pet: ${e.toString()}',
//       );
//       rethrow;
//     }
//   }
// }

// // Providers atualizados
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

// final lastActionResultProvider = Provider<PetActionResultData?>((ref) {
//   return ref.watch(petControllerProvider).lastActionResult;
// });

// // Provider para pets filtrados (excluindo o favorito)
// final otherPetsProvider = Provider<List<Pet>>((ref) {
//   final state = ref.watch(petControllerProvider);
//   final favoritePetId = state.favoritePet?.id;

//   return state.userPets.where((pet) => pet.id != favoritePetId).toList();
// });
