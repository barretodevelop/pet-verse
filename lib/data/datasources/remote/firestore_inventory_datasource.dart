// File: lib/data/datasources/firestore/firestore_inventory_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/data/models/inventory_item_model.dart';
import 'package:petverse/domain/entities/inventory_item_entity.dart';

/// Interface para operações de inventário no Firestore
abstract class FirestoreInventoryDatasource {
  /// Adiciona um item ao inventário do usuário
  Future<void> addItem({
    required String userId,
    required String shopItemId,
    required int quantity,
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    String? rarity,
    Map<String, dynamic>? effects,
  });

  /// Obtém todos os itens do inventário de um usuário
  Future<List<InventoryItemEntity>> getUserInventory(String userId);

  /// Obtém um item específico do inventário
  Future<InventoryItemEntity?> getInventoryItem(String userId, String itemId);

  /// Remove uma quantidade específica de um item do inventário
  Future<void> removeItem({
    required String userId,
    required String itemId,
    required int quantity,
  });

  /// Usa um item do inventário (decrementa quantidade em 1)
  Future<void> useItem({
    required String userId,
    required String itemId,
  });

  /// Atualiza a quantidade de um item específico
  Future<void> updateItemQuantity({
    required String userId,
    required String itemId,
    required int newQuantity,
  });

  /// Remove todos os itens do inventário de um usuário
  Future<void> clearInventory(String userId);

  /// Obtém itens do inventário filtrados por categoria
  Future<List<InventoryItemEntity>> getItemsByCategory({
    required String userId,
    required String category,
  });
}

// ============================================================================

// File: lib/data/datasources/firestore/firestore_inventory_datasource_impl.dart

/// Implementação do datasource de inventário para Firestore
class FirestoreInventoryDatasourceImpl implements FirestoreInventoryDatasource {
  final FirebaseFirestore _firestore;

  FirestoreInventoryDatasourceImpl(this._firestore);

  @override
  Future<void> addItem({
    required String userId,
    required String shopItemId,
    required int quantity,
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    String? rarity,
    Map<String, dynamic>? effects,
  }) async {
    try {
      final inventoryRef = _firestore.collection('users').doc(userId).collection('inventory');

      // Verificar se item já existe no inventário
      final existingItemQuery =
          await inventoryRef.where('shopItemId', isEqualTo: shopItemId).limit(1).get();

      if (existingItemQuery.docs.isNotEmpty) {
        // Item já existe, atualizar quantidade
        final existingDoc = existingItemQuery.docs.first;
        final currentQuantity = existingDoc.data()['quantity'] as int? ?? 0;

        await existingDoc.reference.update({
          'quantity': currentQuantity + quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Criar novo item no inventário
        final newItem = {
          'shopItemId': shopItemId,
          'userId': userId,
          'name': name ?? 'Item',
          'description': description ?? '',
          'imageUrl': imageUrl ?? '',
          'category': category ?? 'food',
          'rarity': rarity ?? 'common',
          'quantity': quantity,
          'effects': effects ?? {},
          'acquiredAt': FieldValue.serverTimestamp(),
          'lastUsedAt': null,
          'timesUsed': 0,
          'isStackable': true,
          'maxStack': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await inventoryRef.add(newItem);
      }
    } catch (e) {
      throw Exception('Erro ao adicionar item ao inventário: $e');
    }
  }

  @override
  Future<List<InventoryItemEntity>> getUserInventory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('inventory')
          .where('quantity', isGreaterThan: 0)
          .orderBy('acquiredAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => InventoryItemModel.fromFirestore(doc).toEntity()).toList();
    } catch (e) {
      throw Exception('Erro ao carregar inventário: $e');
    }
  }

  @override
  Future<InventoryItemEntity?> getInventoryItem(String userId, String itemId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('inventory')
          .doc(itemId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return InventoryItemModel.fromFirestore(doc).toEntity();
    } catch (e) {
      throw Exception('Erro ao buscar item do inventário: $e');
    }
  }

  @override
  Future<void> removeItem({
    required String userId,
    required String itemId,
    required int quantity,
  }) async {
    try {
      final itemRef =
          _firestore.collection('users').doc(userId).collection('inventory').doc(itemId);

      final doc = await itemRef.get();

      if (!doc.exists) {
        throw Exception('Item não encontrado no inventário');
      }

      final currentQuantity = doc.data()!['quantity'] as int? ?? 0;
      final newQuantity = currentQuantity - quantity;

      if (newQuantity <= 0) {
        // Remove o item completamente
        await itemRef.delete();
      } else {
        // Atualiza a quantidade
        await itemRef.update({
          'quantity': newQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Erro ao remover item do inventário: $e');
    }
  }

  @override
  Future<void> useItem({
    required String userId,
    required String itemId,
  }) async {
    try {
      final itemRef =
          _firestore.collection('users').doc(userId).collection('inventory').doc(itemId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(itemRef);

        if (!doc.exists) {
          throw Exception('Item não encontrado no inventário');
        }

        final data = doc.data()!;
        final currentQuantity = data['quantity'] as int? ?? 0;
        final timesUsed = data['timesUsed'] as int? ?? 0;

        if (currentQuantity <= 0) {
          throw Exception('Item sem quantidade disponível');
        }

        final newQuantity = currentQuantity - 1;

        if (newQuantity <= 0) {
          transaction.delete(itemRef);
        } else {
          transaction.update(itemRef, {
            'quantity': newQuantity,
            'lastUsedAt': FieldValue.serverTimestamp(),
            'timesUsed': timesUsed + 1,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw Exception('Erro ao usar item do inventário: $e');
    }
  }

  @override
  Future<void> updateItemQuantity({
    required String userId,
    required String itemId,
    required int newQuantity,
  }) async {
    try {
      final itemRef =
          _firestore.collection('users').doc(userId).collection('inventory').doc(itemId);

      if (newQuantity <= 0) {
        await itemRef.delete();
      } else {
        await itemRef.update({
          'quantity': newQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Erro ao atualizar quantidade do item: $e');
    }
  }

  @override
  Future<void> clearInventory(String userId) async {
    try {
      final inventoryRef = _firestore.collection('users').doc(userId).collection('inventory');

      final snapshot = await inventoryRef.get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao limpar inventário: $e');
    }
  }

  @override
  Future<List<InventoryItemEntity>> getItemsByCategory({
    required String userId,
    required String category,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('inventory')
          .where('category', isEqualTo: category)
          .where('quantity', isGreaterThan: 0)
          .orderBy('acquiredAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => InventoryItemModel.fromFirestore(doc).toEntity()).toList();
    } catch (e) {
      throw Exception('Erro ao buscar itens por categoria: $e');
    }
  }
}
