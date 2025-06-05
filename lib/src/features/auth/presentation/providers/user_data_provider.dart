// lib/src/features/auth/presentation/providers/user_data_provider.dart
// CORREÇÃO CRÍTICA - Provider que estava travando navegação em loading infinito

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/auth/data/repositories/auth_repository.dart';
import 'package:petverse/src/features/auth/presentation/providers/auth_state_provider.dart'
    hide authRepositoryProvider;

// Provider para verificar se o usuário tem pets - VERSÃO CORRIGIDA
final userHasPetProvider = FutureProvider.autoDispose<bool>((ref) async {
  try {
    debugPrint('[userHasPetProvider] 🔍 Iniciando verificação...');

    final authRepository = ref.watch(authRepositoryProvider);
    final currentUser = authRepository.getCurrentUser();

    if (currentUser == null) {
      debugPrint('[userHasPetProvider] ❌ Usuário não logado');
      return false;
    }

    debugPrint('[userHasPetProvider] ✅ Usuário logado: ${currentUser.uid}');

    final firestore = FirebaseFirestore.instance;
    final userDocRef = firestore.collection('users').doc(currentUser.uid);

    // Timeout para evitar travamento
    final userDocSnapshot = await userDocRef.get().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('[userHasPetProvider] ⏰ Timeout - assumindo false');
        throw TimeoutException('Timeout ao buscar dados do usuário');
      },
    );

    if (!userDocSnapshot.exists) {
      debugPrint('[userHasPetProvider] 📝 Documento não existe - criando...');

      // Criar documento do usuário se não existir
      await userDocRef.set({
        'uid': currentUser.uid,
        'username': currentUser.displayName ?? 'Usuário',
        'email': currentUser.email,
        'photoUrl': currentUser.photoURL,
        'pets': [], // Lista vazia de pets
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('[userHasPetProvider] ✅ Documento criado - retornando false');
      return false;
    }

    final userData = userDocSnapshot.data();

    if (userData == null) {
      debugPrint('[userHasPetProvider] ❌ Dados do usuário nulos');
      return false;
    }

    // Verificar se tem pets
    final hasPets = userData.containsKey('pets') &&
        userData['pets'] is List &&
        (userData['pets'] as List).isNotEmpty;

    debugPrint('[userHasPetProvider] 🎯 Resultado final: $hasPets');
    return hasPets;
  } catch (e, stackTrace) {
    debugPrint('[userHasPetProvider] 💥 ERRO: $e');
    debugPrint('[userHasPetProvider] 📋 Stack: $stackTrace');

    // Em caso de erro, assumir que não tem pets para não travar a navegação
    return false;
  }
});

// Provider simplificado para status do usuário (sem cache complexo)
final userStatusProvider = Provider<UserStatus>((ref) {
  final authState = ref.watch(authStateProvider);

  // Se não estiver autenticado, retorna notLoggedIn
  if (authState.status != AuthStatus.authenticated) {
    return UserStatus.notLoggedIn;
  }

  final userHasPetAsync = ref.watch(userHasPetProvider);

  return userHasPetAsync.when(
    data: (hasPet) => hasPet ? UserStatus.hasPets : UserStatus.noPets,
    loading: () => UserStatus.loading,
    error: (_, __) =>
        UserStatus.noPets, // Em caso de erro, assumir que não tem pets
  );
});

enum UserStatus {
  notLoggedIn,
  loading,
  hasPets,
  noPets,
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
