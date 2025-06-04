import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/auth/data/repositories/auth_repository.dart';

// Provider to check if the currently authenticated user has adopted any pets.
// It returns a Future<bool> which resolves to true if the user has pets, false otherwise.
// It will re-evaluate when the auth state changes.
final userHasPetProvider = FutureProvider<bool>((ref) async {
  debugPrint(
      '[userHasPetProvider] Iniciando busca do status de pet do usuário.');
  final authRepository = ref.watch(authRepositoryProvider);
  final currentUser = authRepository.getCurrentUser();

  if (currentUser == null) {
    // If no user is logged in, they don't have a pet in the context of the app.
    return false;
  }
  debugPrint(
      '[userHasPetProvider] Usuário logado: ${currentUser.uid}. Buscando documento...');

  // Fetch the user's document from Firestore.
  // Assumes a 'users' collection and user documents are keyed by UID.
  final firestore = FirebaseFirestore.instance;
  final userDocRef = firestore.collection('users').doc(currentUser.uid);

  final userDocSnapshot = await userDocRef.get();

  if (userDocSnapshot.exists && userDocSnapshot.data() != null) {
    final userData = userDocSnapshot.data()!;
    // Check if the 'pets' field exists and is a non-empty list.
    final bool hasPet =
        userData.containsKey('pets') && (userData['pets'] as List).isNotEmpty;
    debugPrint(
        '[userHasPetProvider] Status de pet do usuário encontrado: $hasPet');
    return hasPet;
  }
  debugPrint(
      '[userHasPetProvider] Documento do usuário não existe ou não tem campo de pets. Retornando false.');
  return false; // User document doesn't exist or doesn't have a 'pets' field.
});
