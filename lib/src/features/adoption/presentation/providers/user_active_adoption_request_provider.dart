import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/adoption/data/models/adoption_request_model.dart';
import 'package:petverse/src/features/auth/data/repositories/auth_repository.dart';

// Provider para verificar se o usuário logado possui uma solicitação de adoção ativa (pendente).
final userActiveAdoptionRequestProvider =
    FutureProvider<AdoptionRequest?>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  final currentUser = authRepository.getCurrentUser();

  if (currentUser == null) {
    // Nenhum usuário logado, não pode ter solicitação ativa.
    return null;
  }

  final firestore = FirebaseFirestore.instance;

  try {
    final querySnapshot = await firestore
        .collection('adoptionRequests')
        .where('initiatorUserId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'pending')
        .limit(1) // Um usuário só deve ter uma solicitação pendente por vez
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return AdoptionRequest.fromFirestore(querySnapshot.docs.first);
    }
    return null; // Nenhuma solicitação ativa encontrada.
  } catch (e) {
    print('Erro ao buscar solicitação de adoção ativa do usuário: $e');
    return null; // Em caso de erro, assume que não há solicitação ativa.
  }
});
