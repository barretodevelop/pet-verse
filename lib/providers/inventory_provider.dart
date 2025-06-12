﻿// InventoryProvider
// lib/providers/inventory_provider.dart - InventoryProvider
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/models/inventory_user_item_model.dart'; // Novo modelo
import 'package:petverse/models/item_model.dart';
import 'package:petverse/providers/user_provider.dart'; // Para obter o userId
import 'package:petverse/services/firestore_service.dart';
import 'package:petverse/utils/constants.dart'; // Para mapear itemId para ItemModel

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, List<InventoryUserItem>>((ref) {
  final userId = ref.watch(userProvider.select((user) => user?.id));
  return InventoryNotifier(ref, userId, FirestoreService());
});

class InventoryNotifier extends StateNotifier<List<InventoryUserItem>> {
  final Ref _ref;
  final String? _userId;
  final FirestoreService _firestoreService;
  StreamSubscription? _inventorySubscription;

  InventoryNotifier(this._ref, this._userId, this._firestoreService)
      : super([]) {
    if (_userId != null) {
      _listenToInventoryChanges(_userId!);
    } else {
      print('⚠️ InventoryNotifier: UserId is null, cannot load inventory.');
    }
  }

  void _listenToInventoryChanges(String userId) {
    _inventorySubscription?.cancel(); // Cancela a inscrição anterior, se houver
    _inventorySubscription = _firestoreService.getUserInventory(userId).listen(
      (inventoryItems) {
        // Mapeia InventoryUserItem para ItemModel se necessário, ou mantenha InventoryUserItem
        // Para simplificar, vamos manter InventoryUserItem e popular o baseItem

        // ✅ NOVO: Agrupar itens por itemId e somar quantidades
        final Map<String, InventoryUserItem> groupedItemsMap = {};
        for (var invItem in inventoryItems) {
          if (groupedItemsMap.containsKey(invItem.itemId)) {
            // If item already exists in our grouped map, update its quantity
            final existingItem = groupedItemsMap[invItem.itemId]!;
            groupedItemsMap[invItem.itemId] = existingItem.copyWith(
                quantity: existingItem.quantity + invItem.quantity);
          } else {
            // Otherwise, add the item to the grouped map
            // We use the docId of the first occurrence for simplicity,
            // as the quantity is now aggregated.
            groupedItemsMap[invItem.itemId] = invItem;
          }
        }

        // Now populate baseItem for the grouped items (using the aggregated items from the map)
        final populatedItems = groupedItemsMap.values.map((invItem) {
          final baseItemDetails = Constants.shopItems.firstWhere(
            (shopItem) => shopItem.id == invItem.itemId,
            orElse: () => ItemModel(
                id: invItem.itemId,
                name: 'Item Desconhecido',
                emoji: '❓',
                type: 'desconhecido', // ✅ ADICIONADO: Campo 'type' obrigatório
                category:
                    'desconhecido', // ✅ ADICIONADO: Campo 'category' obrigatório
                effects: {}, // ✅ Usar o novo campo 'effects' como um mapa vazio
                cost: 0),
          );
          return invItem.copyWith(baseItem: baseItemDetails);
        }).toList();
        state = populatedItems;
        print(
            '✅ InventoryProvider: Inventário atualizado com ${state.length} itens para o usuário $_userId');
      },
      onError: (error) {
        print(
            '❌ InventoryProvider: Erro ao ouvir mudanças no inventário: $error');
        state = []; // Limpa o estado em caso de erro
      },
    );
  }

  // Chamado quando o userId muda (ex: login/logout)
  void updateUserContext(String? newUserId) {
    if (newUserId != null && newUserId != _userId) {
      _listenToInventoryChanges(newUserId);
    } else if (newUserId == null) {
      _inventorySubscription?.cancel();
      state = [];
    }
    // _userId é final, então não podemos reatribuí-lo. O provider será recriado.
  }

  Future<void> addItem(ItemModel item, {int quantity = 1}) async {
    if (_userId == null) {
      print(
          '❌ InventoryProvider: Não é possível adicionar item, usuário não logado.');
      throw Exception('Usuário não logado.');
    }
    try {
      // Adiciona ao Firestore. O listener atualizará o estado local.
      await _firestoreService.addUserInventoryItem(_userId!, item,
          quantity: quantity);
      print(
          '✅ InventoryProvider: Solicitação para adicionar ${item.name} enviada ao Firestore.');
    } catch (e) {
      print('❌ InventoryProvider: Falha ao adicionar item ${item.name}: $e');
      rethrow;
    }
  }

  Future<void> removeItem(InventoryUserItem inventoryUserItem,
      {int quantityToRemove = 1}) async {
    if (_userId == null) {
      print(
          '❌ InventoryProvider: Não é possível remover item, usuário não logado.');
      throw Exception('Usuário não logado.');
    }
    try {
      // Remove do Firestore. O listener atualizará o estado local.
      await _firestoreService.removeUserInventoryItem(
          _userId!, inventoryUserItem.docId,
          quantityToRemove: quantityToRemove);
      print(
          '✅ InventoryProvider: Solicitação para remover ${inventoryUserItem.itemId} enviada ao Firestore.');
    } catch (e) {
      print(
          '❌ InventoryProvider: Falha ao remover item ${inventoryUserItem.itemId}: $e');
      rethrow;
    }
  }

  // Este método pode precisar de ajuste se o estado agora é List<InventoryUserItem>
  List<InventoryUserItem> getItemsByCategory(String category) {
    return state
        .where((invItem) => invItem.baseItem?.category == category)
        .toList();
  }

  @override
  void dispose() {
    _inventorySubscription?.cancel();
    super.dispose();
  }
}
