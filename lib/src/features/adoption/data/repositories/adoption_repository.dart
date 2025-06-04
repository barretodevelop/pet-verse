import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importar Firebase Auth para User
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/adoption/data/models/adoption_request_model.dart';
import 'package:petverse/src/features/auth/data/repositories/auth_repository.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart'; // Corrigido: Import Pet model do local correto
import 'package:uuid/uuid.dart'; // Importar o pacote uuid

final adoptionRepositoryProvider = Provider<AdoptionRepository>((ref) {
  final authRepository =
      ref.watch(authRepositoryProvider); // Lê o AuthRepositoryProvider
  return AdoptionRepository(
      FirebaseFirestore.instance, authRepository); // Passa as duas dependências
});

class AdoptionRepository {
  final FirebaseFirestore _firestore;

  // Precisamos do AuthRepository para obter o ID do usuário logado
  final AuthRepository _authRepository;

  AdoptionRepository(this._firestore, this._authRepository);

  // Busca todas as solicitações de adoção com status 'pending'
  // E que são públicas
  Stream<List<AdoptionRequest>> getPendingAdoptionRequests() {
    return _firestore
        .collection('adoptionRequests') // Nome da coleção no Firestore
        .where('status', isEqualTo: 'pending')
        .where('isPublic', isEqualTo: true) // Apenas solicitações públicas
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AdoptionRequest.fromFirestore(doc))
          .toList();
    });
  }

  Future<AdoptionRequest?> getAdoptionRequestById(String requestId) async {
    final doc =
        await _firestore.collection('adoptionRequests').doc(requestId).get();
    if (doc.exists) {
      return AdoptionRequest.fromFirestore(doc);
    }
    return null; // Retorna null se o documento não for encontrado
  }

  // Busca uma solicitação de adoção pendente pelo código de amigo
  Future<AdoptionRequest?> getAdoptionRequestByFriendCode(
      String friendCode) async {
    final querySnapshot = await _firestore
        .collection('adoptionRequests')
        .where('friendCode', isEqualTo: friendCode)
        .where('status', isEqualTo: 'pending') // Apenas solicitações pendentes
        .limit(
            1) // Espera-se que o código de amigo seja único para solicitações pendentes
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return AdoptionRequest.fromFirestore(querySnapshot.docs.first);
    }
    return null; // Retorna null se nenhuma solicitação for encontrada
  }

  // Busca uma lista de pets pelos seus IDs
  Future<List<Pet>> getPetsByIds(List<String> petIds) async {
    if (petIds.isEmpty) return [];
    final snapshot = await _firestore
        .collection('pets')
        .where(FieldPath.documentId, whereIn: petIds)
        .get();
    return snapshot.docs
        .map((doc) => Pet.fromFirestore(doc))
        .toList()
        .cast<Pet>();
  }

  // Busca todos os pets que NÃO foram adotados
  Stream<List<Pet>> getAvailablePets() {
    return _firestore
        .collection('pets')
        .where('isAdopted', isEqualTo: false) // Filtra por pets não adotados
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();
    });
  }

  // Cria uma nova solicitação de adoção
  Future<String?> createAdoptionRequest(List<String> petOptionIds,
      {required bool isPublic}) async {
    final User? currentUser = _authRepository.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Usuário não autenticado para criar solicitação.');
    }
    if (petOptionIds.length != 3) {
      throw Exception('É necessário selecionar exatamente 3 pets.');
    }

    String? friendCode;
    if (!isPublic) {
      // Gerar um código de amigo simples e único (parte do UUID) somente se não for pública
      friendCode = const Uuid().v4().substring(0, 8).toUpperCase();
    }

    final newRequestRef = _firestore.collection('adoptionRequests').doc();
    await newRequestRef.set({
      'id': newRequestRef.id, // Opcional, mas útil ter o ID no documento
      'initiatorUserId': currentUser.uid,
      'petOptionsIds': petOptionIds,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'friendCode': friendCode, // Será null se isPublic for true
      'isPublic': isPublic, // Novo campo para indicar visibilidade
    });
    return friendCode; // Retorna o código de amigo gerado (ou null se pública)
  }

  // Confirma a adoção de um pet para uma solicitação pendente
  Future<void> confirmAdoption(String requestId, String selectedPetId) async {
    final User? currentUser =
        _authRepository.getCurrentUser(); // Usar o método corrigido
    if (currentUser == null) {
      throw Exception('Usuário não autenticado.');
    }

    final batch = _firestore.batch();

    // 1. Atualizar o status da AdoptionRequest
    final requestRef = _firestore.collection('adoptionRequests').doc(requestId);
    batch.update(requestRef, {
      'status': 'completed',
      'completedAt':
          FieldValue.serverTimestamp(), // Opcional: registrar data de conclusão
      'selectedPetId':
          selectedPetId, // Opcional: registrar qual pet foi escolhido
      'completerUserId': currentUser.uid, // Opcional: registrar quem completou
    });

    // 2. Criar um novo documento na coleção 'adoptions'
    // Precisamos obter o initiatorUserId da solicitação primeiro
    final requestDoc = await requestRef.get();
    if (!requestDoc.exists) {
      throw Exception('Solicitação de adoção não encontrada.');
    }
    final requestData = requestDoc.data() as Map<String, dynamic>;
    final initiatorUserId = requestData['initiatorUserId'];

    final newAdoptionRef =
        _firestore.collection('adoptions').doc(); // Novo ID de documento
    batch.set(newAdoptionRef, {
      'requestId': requestId,
      'petId': selectedPetId,
      'adopter1Id': initiatorUserId,
      'adopter2Id': currentUser.uid, // O usuário logado é o segundo adotante
      'createdAt': FieldValue.serverTimestamp(),
      // TODO: Adicionar campos para adoção anônima vs amigo, etc.
    });

    // 3. Atualizar o documento do pet escolhido
    final petRef = _firestore.collection('pets').doc(selectedPetId);
    batch.update(petRef, {
      'isAdopted': true,
      'currentAdoptionRequestId': null, // Remover a referência à solicitação
      // TODO: Adicionar referência à nova adoção se necessário
    });

    // 4. Atualizar os documentos dos usuários (adopter1 e adopter2) para adicionar o pet adotado
    final adopter1Ref = _firestore.collection('users').doc(initiatorUserId);
    final adopter2Ref = _firestore.collection('users').doc(currentUser.uid);

    // Assumindo que o documento do usuário tem um campo 'pets' que é uma lista de IDs de pets
    // Se a estrutura for diferente, ajuste aqui.
    batch.update(adopter1Ref, {
      'pets': FieldValue.arrayUnion([selectedPetId])
    });
    batch.update(adopter2Ref, {
      'pets': FieldValue.arrayUnion([selectedPetId])
    });

    // Executar a escrita em lote
    await batch.commit();
  }

  // Rejeita uma solicitação de adoção pendente
  Future<void> rejectAdoptionRequest(String requestId) async {
    final requestRef = _firestore.collection('adoptionRequests').doc(requestId);
    // Atualiza o status da solicitação para 'cancelled' ou 'rejected'
    await requestRef.update({
      'status': 'cancelled', // Ou 'rejected', defina um padrão
    });
  }
}
