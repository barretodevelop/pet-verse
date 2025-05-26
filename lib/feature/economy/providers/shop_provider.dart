// lib/features/shop/providers/shop_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/providers/firebase_providers.dart';
import 'package:petverse/feature/auth/providers/auth_provider.dart';
import 'package:petverse/feature/economy/providers/economy_provider.dart';
import 'package:petverse/feature/shop/models/shop_item.dart';

class ShopController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ShopController(this._ref) : super(const AsyncData(null));

  Future<void> buyItem(ShopItem item) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) throw Exception('Usuário não autenticado');

    state = const AsyncLoading();
    try {
      // Verificar se já possui o item
      final ownedItems = _ref.read(ownedItemsProvider).valueOrNull ?? [];
      if (ownedItems.contains(item.id)) {
        throw Exception('Você já possui este item');
      }

      // Gastar moedas
      await _ref
          .read(economyControllerProvider.notifier)
          .spendCoins(item.price);

      // Adicionar item à lista de itens do usuário
      final firestore = _ref.read(firebaseFirestoreProvider);
      await firestore.collection('users').doc(user.uid).update({
        'ownedItems': FieldValue.arrayUnion([item.id]),
      });

      // Se for comida ou brinquedo, aplicar efeitos imediatamente
      if (item.effects != null) {
        await _applyItemEffects(item);
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> _applyItemEffects(ShopItem item) async {
    // TODO: Implementar aplicação de efeitos no pet
    // Por exemplo, aumentar fome, felicidade, etc.
  }
}

final shopControllerProvider =
    StateNotifierProvider<ShopController, AsyncValue<void>>((ref) {
  return ShopController(ref);
});
