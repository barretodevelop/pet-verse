// lib/features/economy/providers/economy_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../../auth/providers/auth_provider.dart';

// Provider para moedas do usuário
final userCoinsProvider = StreamProvider<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(0);

  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore.collection('users').doc(user.uid).snapshots().map((doc) {
    if (!doc.exists) return 0;
    return doc.data()?['coins'] ?? 0;
  });
});

// Provider para itens comprados
final ownedItemsProvider = StreamProvider<List<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  final firestore = ref.watch(firebaseFirestoreProvider);
  return firestore.collection('users').doc(user.uid).snapshots().map((doc) {
    if (!doc.exists) return [];
    return List<String>.from(doc.data()?['ownedItems'] ?? []);
  });
});

// Controller de economia
class EconomyController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  EconomyController(this._ref) : super(const AsyncData(null));

  Future<void> addCoins(int amount) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncLoading();
    try {
      final firestore = _ref.read(firebaseFirestoreProvider);
      await firestore.collection('users').doc(user.uid).update({
        'coins': FieldValue.increment(amount),
      });
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> spendCoins(int amount) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final currentCoins = _ref.read(userCoinsProvider).valueOrNull ?? 0;
    if (currentCoins < amount) {
      throw Exception('Moedas insuficientes');
    }

    state = const AsyncLoading();
    try {
      final firestore = _ref.read(firebaseFirestoreProvider);
      await firestore.collection('users').doc(user.uid).update({
        'coins': FieldValue.increment(-amount),
      });
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final economyControllerProvider =
    StateNotifierProvider<EconomyController, AsyncValue<void>>((ref) {
  return EconomyController(ref);
});
