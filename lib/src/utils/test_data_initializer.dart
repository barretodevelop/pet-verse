import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/adoption/data/repositories/adoption_repository.dart';
import 'package:petverse/src/features/auth/data/repositories/auth_repository.dart';

// Provider que inicializa os dados de teste no Firebase (Firestore)
final testDataInitializerProvider = FutureProvider<void>((ref) async {
  // Usamos ref.read aqui porque não queremos que este provider seja reavaliado
  // se os repositórios mudarem, apenas queremos executar a lógica uma vez.
  final firestore = FirebaseFirestore.instance;
  final adoptionRepository = ref.read(adoptionRepositoryProvider);
  final authRepository = ref.read(authRepositoryProvider);

  // Define um marcador para verificar se os dados de teste já foram criados
  const String testDataMarkerDocId = 'test_data_created';
  final markerRef = firestore.collection('app_meta').doc(testDataMarkerDocId);

  try {
    final markerDoc = await markerRef.get();

    if (markerDoc.exists) {
      debugPrint('Dados de teste já existem. Pulando inicialização.');
      return; // Dados já criados, não faz nada
    }

    debugPrint('Inicializando dados de teste...');

    // --- 1. Criar Usuários de Teste (se não existirem) ---
    // Precisamos garantir que o usuário logado tenha um documento na coleção 'users'
    // e criar um usuário fictício para ser o 'iniciador' da solicitação de adoção.
    final currentUser = authRepository.getCurrentUser();
    if (currentUser != null) {
      final currentUserRef = firestore.collection('users').doc(currentUser.uid);
      final currentUserDoc = await currentUserRef.get();
      if (!currentUserDoc.exists) {
        await currentUserRef.set({
          'uid': currentUser.uid,
          'username': currentUser.displayName ?? 'Usuário Teste',
          'email': currentUser.email,
          'photoUrl': currentUser.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'pets': [], // Inicializa a lista de pets
          // TODO: Adicionar outros campos padrão do usuário
        });
        debugPrint('Documento do usuário logado criado/verificado.');
      }
    }

    const String initiatorTestUserId =
        'test_initiator_user_id'; // ID fictício para o iniciador
    final initiatorUserRef =
        firestore.collection('users').doc(initiatorTestUserId);
    final initiatorUserDoc = await initiatorUserRef.get();
    if (!initiatorUserDoc.exists) {
      await initiatorUserRef.set({
        'uid': initiatorTestUserId,
        'username': 'Iniciador Teste',
        'email': 'initiator.test@example.com',
        'photoUrl': 'https://via.placeholder.com/150?text=Iniciador',
        'createdAt': FieldValue.serverTimestamp(),
        'pets': [], // Inicializa a lista de pets
        // TODO: Adicionar outros campos padrão do usuário
      });
      debugPrint('Documento do usuário iniciador de teste criado.');
    }

    // --- 2. Criar Pets de Teste ---
    final List<Map<String, dynamic>> testPetsData = [
      {
        'name': 'Buddy',
        'species': 'Cachorro',
        'breed': 'Labrador',
        'age': 3,
        'gender': 'Macho',
        'description': 'Amigável e brincalhão.',
        'imageUrl': 'https://via.placeholder.com/150/FF5733/FFFFFF?text=Buddy',
        'isAdopted': false
      },
      {
        'name': 'Mia',
        'species': 'Gato',
        'breed': 'Siamês',
        'age': 1,
        'gender': 'Fêmea',
        'description': 'Curiosa e independente.',
        'imageUrl': 'https://via.placeholder.com/150/33FF57/FFFFFF?text=Mia',
        'isAdopted': false
      },
      {
        'name': 'Rocky',
        'species': 'Cachorro',
        'breed': 'Pastor Alemão',
        'age': 5,
        'gender': 'Macho',
        'description': 'Leal e protetor.',
        'imageUrl': 'https://via.placeholder.com/150/3357FF/FFFFFF?text=Rocky',
        'isAdopted': false
      },
      {
        'name': 'Luna',
        'species': 'Gato',
        'breed': 'Persa',
        'age': 2,
        'gender': 'Fêmea',
        'description': 'Calma e carinhosa.',
        'imageUrl': 'https://via.placeholder.com/150/FFFF33/000000?text=Luna',
        'isAdopted': false
      },
      {
        'name': 'Max',
        'species': 'Cachorro',
        'breed': 'Poodle',
        'age': 4,
        'gender': 'Macho',
        'description': 'Inteligente e ativo.',
        'imageUrl': 'https://via.placeholder.com/150/33FFFF/000000?text=Max',
        'isAdopted': false
      },
    ];

    final List<String> petIds = [];
    for (final petData in testPetsData) {
      final docRef = await firestore.collection('pets').add(petData);
      petIds.add(docRef.id);
    }
    debugPrint('${petIds.length} pets de teste criados.');

    // --- 3. Criar Solicitações de Adoção de Teste ---
    // Criar uma solicitação pendente usando 3 dos pets criados
    if (petIds.length >= 3) {
      await firestore.collection('adoptionRequests').add({
        'initiatorUserId':
            initiatorTestUserId, // Usar o ID do iniciador de teste
        'petOptionsIds': [
          petIds[0],
          petIds[1],
          petIds[2]
        ], // Usar os IDs dos 3 primeiros pets
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'friendCode': 'TESTCODE123',
        'isPublic': false, // Esta é uma solicitação por convite
      });
      debugPrint('Solicitação de adoção de teste POR CONVITE criada.');
    }

    // --- 4. Marcar dados de teste como criados ---
    await markerRef
        .set({'created': true, 'createdAt': FieldValue.serverTimestamp()});

    // Adicionar uma solicitação pública de teste
    if (petIds.length >= 3) {
      await firestore.collection('adoptionRequests').add({
        'initiatorUserId': initiatorTestUserId,
        'petOptionsIds': [
          petIds.length > 3 ? petIds[3] : petIds[0],
          petIds.length > 4 ? petIds[4] : petIds[1],
          petIds.length > 2 ? petIds[2] : petIds[0]
        ], // Usar outros pets se disponíveis
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'friendCode': null,
        'isPublic': true, // Solicitação pública
      });
      debugPrint('Solicitação de adoção de teste PÚBLICA criada.');
    }
    debugPrint('Marcação de dados de teste criada.');
  } catch (e, s) {
    debugPrint('ERRO ao inicializar dados de teste: $e');
    debugPrint('Stacktrace: $s');
  }
});
