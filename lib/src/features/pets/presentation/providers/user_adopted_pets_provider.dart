import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/auth/data/repositories/auth_repository.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart';

// Provider para buscar os pets adotados pelo usuário logado.
final userAdoptedPetsProvider = FutureProvider<List<Pet>>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  final currentUser = authRepository.getCurrentUser();

  if (currentUser == null) {
    // Nenhum usuário logado, retorna lista vazia.
    return [];
  }

  final firestore = FirebaseFirestore.instance;
  final userDocRef = firestore.collection('users').doc(currentUser.uid);

  try {
    final userDocSnapshot = await userDocRef.get();

    if (userDocSnapshot.exists && userDocSnapshot.data() != null) {
      final userData = userDocSnapshot.data()!;
      if (userData.containsKey('pets') && (userData['pets'] is List)) {
        final List<dynamic> petIdsDynamic = userData['pets'];
        final List<String> petIds =
            petIdsDynamic.map((id) => id.toString()).toList();

        if (petIds.isEmpty) {
          return []; // Usuário não tem pets na lista.
        }

        // Buscar os documentos dos pets pelos IDs.
        final petDocsSnapshot = await firestore
            .collection('pets')
            .where(FieldPath.documentId, whereIn: petIds)
            .get();
        return petDocsSnapshot.docs
            .map((doc) => Pet.fromFirestore(doc))
            .toList();
      }
    }
    return []; // Documento do usuário não existe, não tem campo 'pets' ou está malformado.
  } catch (e) {
    // Em caso de erro na busca, retorna lista vazia e loga o erro.
    print('Erro ao buscar pets adotados pelo usuário: $e');
    return [];
  }
});
