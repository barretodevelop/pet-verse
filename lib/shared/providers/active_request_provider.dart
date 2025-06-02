// lib/core/providers/active_request_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/firebase_pet_model.dart';
import 'package:petverse/core/services/firebase_adoption_service.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';

// Provider para verificar se usuário tem solicitação ativa
// final userActiveRequestProvider =
//     FutureProvider<CollaborativeAdoptionRequest?>((ref) async {
//   final authState = ref.watch(authenticationNotifierProvider);
//   if (authState.user?.uid == null) return null;

//   return await FirebaseAdoptionService.getUserActiveRequest(
//       authState.user!.uid);
// });
// Provider para a solicitação ativa atual do usuário (única)
final userActiveRequestProvider =
    FutureProvider<CollaborativeAdoptionRequest?>((ref) async {
  final authState = ref.watch(authenticationNotifierProvider);
  if (authState.user?.uid == null) return null;

  try {
    final query = await FirebaseFirestore.instance
        .collection('collaborative_requests')
        .where('requesterId', isEqualTo: authState.user!.uid)
        .where('status', isEqualTo: AdoptionRequestStatus.pending.toString())
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    return CollaborativeAdoptionRequest.fromFirestore(query.docs.first);
  } catch (e) {
    print('Erro ao buscar solicitação ativa: $e');
    return null;
  }
});

// Stream provider para monitorar solicitação ativa em tempo real
final watchUserActiveRequestProvider =
    StreamProvider<CollaborativeAdoptionRequest?>((ref) {
  final authState = ref.watch(authenticationNotifierProvider);
  if (authState.user?.uid == null) {
    return Stream.value(null);
  }

  return FirebaseAdoptionService.watchUserActiveRequest(authState.user!.uid);
});

// Provider para verificar se usuário pode criar nova solicitação
final canCreateNewRequestProvider = Provider<bool>((ref) {
  final activeRequestAsync = ref.watch(userActiveRequestProvider);

  return activeRequestAsync.when(
    data: (activeRequest) => activeRequest == null,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Provider para pets da solicitação ativa do usuário
final userActiveRequestPetsProvider =
    FutureProvider<List<FirebasePetModel>>((ref) async {
  final activeRequestAsync = ref.watch(userActiveRequestProvider);

  return activeRequestAsync.when(
    data: (activeRequest) async {
      if (activeRequest == null) return [];
      return await FirebaseAdoptionService.getPetsFromRequest(activeRequest.id);
    },
    loading: () => <FirebasePetModel>[],
    error: (_, __) => <FirebasePetModel>[],
  );
});
