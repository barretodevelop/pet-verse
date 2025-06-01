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
