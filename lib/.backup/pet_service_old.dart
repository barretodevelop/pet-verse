// // lib/features/pet/services/pet_service.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:petverse/core/providers/firebase_providers.dart';
// import 'package:petverse/feature/pet/model/pet.dart';
// import 'package:petverse/feature/room/provider/room_provider.dart';
 

// class PetService {
//   final Ref _ref;
//   late final FirebaseFirestore _firestore;
//   late final FirebaseAuth _auth;

//   PetService(this._ref, FirebaseAuth auth) {
//     _firestore = _ref.read(firebaseFirestoreProvider);
//     _auth = _ref.read(firebaseAuthProvider);
//   }

//   // Stream do pet baseado na sala ativa
//   Stream<Pet?> streamUserPet() {
//     final user = _auth.currentUser;
//     if (user == null) return Stream.value(null);

//     return _firestore
//         .collection('pets')
//         .where('parentIds', arrayContains: user.uid)
//         .orderBy('createdAt', descending: true)
//         .limit(1)
//         .snapshots()
//         .map((snapshot) {
//       if (snapshot.docs.isEmpty) return null;
//       return Pet.fromFirestore(snapshot.docs.first);
//     });
//   }

//   // Criar pet (chamado da tela de adoção)
//   Future<Pet> createPet({
//     required String roomId,
//     required String petName,
//     required String petType,
//   }) async {
//     final user = _auth.currentUser;
//     if (user == null) throw Exception('Usuário não autenticado');

//     // Buscar dados da sala
//     final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
//     if (!roomDoc.exists) throw Exception('Sala não encontrada');

//     final roomData = roomDoc.data()!;
//     final parentIds = List<String>.from(roomData['parentIds']);

//     if (parentIds.length < 2) {
//       throw Exception('Sala precisa ter 2 participantes para adotar um pet');
//     }

//     // Criar pet
//     final now = DateTime.now();
//     final petData = {
//       'name': petName,
//       'roomId': roomId,
//       'parentIds': parentIds,
//       'hunger': 70,
//       'happiness': 80,
//       'cleanliness': 90,
//       'lastFed': FieldValue.serverTimestamp(),
//       'lastPlayed': FieldValue.serverTimestamp(),
//       'lastCleaned': FieldValue.serverTimestamp(),
//       'lastCaredBy': user.uid,
//       'createdAt': FieldValue.serverTimestamp(),
//       'customization': {
//         'type': petType,
//         'color': 'default',
//         'accessories': [],
//       },
//     };

//     final petRef = await _firestore.collection('pets').add(petData);

//     // Atualizar sala com ID do pet
//     await roomDoc.reference.update({'petId': petRef.id});

//     // Notificar no chat
//     final roomService = _ref.read(roomServiceProvider);
//     await roomService.sendMessage(
//       roomId,
//       '🎊 $petName foi adotado! Cuidem bem dele!',
//       type: 'system',
//     );

//     // Retornar pet criado
//     final petDoc = await petRef.get();
//     return Pet.fromFirestore(petDoc);
//   }

//   // Alimentar pet
//   Future<void> feedPet(String petId) async {
//     final user = _auth.currentUser;
//     if (user == null) throw Exception('Usuário não autenticado');

//     final petRef = _firestore.collection('pets').doc(petId);
//     final petDoc = await petRef.get();
    
//     if (!petDoc.exists) throw Exception('Pet não encontrado');
    
//     final pet = Pet.fromFirestore(petDoc);
    
//     // Verificar se usuário é parent do pet
//     if (!pet.parentIds.contains(user.uid)) {
//       throw Exception('Você não é responsável por este pet');
//     }

//     // Atualizar status
//     await petRef.update({
//       'hunger': FieldValue.increment(20),
//       'lastFed': FieldValue.serverTimestamp(),
//       'lastCaredBy': user.uid,
//     });

//     // Se hunger estava muito baixo, aumentar felicidade também
//     if (pet.hunger < 30) {
//       await petRef.update({
//         'happiness': FieldValue.increment(10),
//       });
//     }
//   }

//   // Brincar com pet
//   Future<void> playWithPet(String petId) async {
//     final user = _auth.currentUser;
//     if (user == null) throw Exception('Usuário não autenticado');

//     final petRef = _firestore.collection('pets').doc(petId);
//     final petDoc = await petRef.get();
    
//     if (!petDoc.exists) throw Exception('Pet não encontrado');
    
//     final pet = Pet.fromFirestore(petDoc);
    
//     if (!pet.parentIds.contains(user.uid)) {
//       throw Exception('Você não é responsável por este pet');
//     }

//     // Atualizar status
//     await petRef.update({
//       'happiness': FieldValue.increment(25),
//       'hunger': FieldValue.increment(-10), // Brincar dá fome
//       'cleanliness': FieldValue.increment(-5), // Brincar suja um pouco
//       'lastPlayed': FieldValue.serverTimestamp(),
//       'lastCaredBy': user.uid,
//     });
//   }

//   // Dar banho no pet
//   Future<void> cleanPet(String petId) async {
//     final user = _auth.currentUser;
//     if (user == null) throw Exception('Usuário não autenticado');

//     final petRef = _firestore.collection('pets').doc(petId);
//     final petDoc = await petRef.get();
    
//     if (!petDoc.exists) throw Exception('Pet não encontrado');
    
//     final pet = Pet.fromFirestore(petDoc);
    
//     if (!pet.parentIds.contains(user.uid)) {
//       throw Exception('Você não é responsável por este pet');
//     }

//     // Atualizar status
//     await petRef.update({
//       'cleanliness': 100, // Banho deixa 100% limpo
//       'happiness': FieldValue.increment(15), // Pet gosta de estar limpo
//       'lastCleaned': FieldValue.serverTimestamp(),
//       'lastCaredBy': user.uid,
//     });
//   }

//   // Função para degradar status ao longo do tempo (seria chamada por Cloud Function)
//   Future<void> updatePetStatus(String petId) async {
//     final petRef = _firestore.collection('pets').doc(petId);
//     final petDoc = await petRef.get();
    
//     if (!petDoc.exists) return;
    
//     final pet = Pet.fromFirestore(petDoc);
//     final now = DateTime.now();
    
//     // Calcular tempo desde última interação
//     final hoursSinceLastFed = now.difference(pet.lastFed).inHours;
//     final hoursSinceLastPlayed = now.difference(pet.lastPlayed).inHours;
//     final hoursSinceLastCleaned = now.difference(pet.lastCleaned).inHours;
    
//     // Degradar status baseado no tempo
//     final hungerDecrease = hoursSinceLastFed * 5;
//     final happinessDecrease = hoursSinceLastPlayed * 3;
//     final cleanlinessDecrease = hoursSinceLastCleaned * 2;
    
//     await petRef.update({
//       'hunger': FieldValue.increment(-hungerDecrease.clamp(0, pet.hunger)),
//       'happiness': FieldValue.increment(-happinessDecrease.clamp(0, pet.happiness)),
//       'cleanliness': FieldValue.increment(-cleanlinessDecrease.clamp(0, pet.cleanliness)),
//     });
//   }

//   Stream<Pet?> getPetStream(String petId) {}

//   Stream<List<Pet>> getPetsForRoom(String roomId) {}
// }

// // lib/features/pet/providers/pet_provider.dart
// // Atualizar o router para incluir a rota de adoção
// // lib/core/router/app_router.dart (adicionar esta rota)
// /*
// GoRoute(
//   path: '/pet/adopt/:roomId',
//   builder: (context, state) {
//     final roomId = state.pathParameters['roomId']!;
//     return PetAdoptionPage(roomId: roomId);
//   },
// ),
// */