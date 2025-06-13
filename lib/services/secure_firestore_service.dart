// lib/services/secure_firestore_service.dart
// Server-side validation layer mantendo funcionalidades existentes

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:petverse/models/inventory_user_item_model.dart';
import 'package:petverse/models/item_model.dart';
import 'package:petverse/models/pet_model.dart';
import 'package:petverse/models/user_model.dart';
import 'package:petverse/services/firestore_service.dart';

class SecureFirestoreService {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;
  static final _baseService = FirestoreService();

  // ========================
  // SECURE USER OPERATIONS
  // ========================

  /// Operação segura para atualizar economia do usuário
  /// Valida transação antes de executar
  static Future<bool> updateUserEconomy({
    required String userId,
    int? coinsDelta,
    int? gemsDelta,
    required String reason,
    String? transactionId,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser?.uid != userId) {
      throw SecurityException(
          'Usuário não pode alterar dados de outros usuários');
    }

    try {
      // Usar transaction para consistência
      return await _db.runTransaction<bool>((transaction) async {
        final userRef = _db.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('Usuário não encontrado');
        }

        final userData = userDoc.data()!;
        final currentCoins = userData['coins'] as int? ?? 0;
        final currentGems = userData['gems'] as int? ?? 0;

        // Calcular novos valores
        final newCoins = currentCoins + (coinsDelta ?? 0);
        final newGems = currentGems + (gemsDelta ?? 0);

        // Validações de negócio
        if (newCoins < 0) {
          throw InsufficientFundsException('Coins insuficientes');
        }
        if (newGems < 0) {
          throw InsufficientFundsException('Gemas insuficientes');
        }

        // Validar limites de incremento (anti-cheat)
        if (coinsDelta != null && coinsDelta > 200) {
          throw SecurityException('Incremento de coins muito alto');
        }
        if (gemsDelta != null && gemsDelta > 50) {
          throw SecurityException('Incremento de gemas muito alto');
        }

        // Log da transação para auditoria
        await _logEconomyTransaction(
          transaction: transaction,
          userId: userId,
          coinsDelta: coinsDelta,
          gemsDelta: gemsDelta,
          reason: reason,
          transactionId: transactionId,
        );

        // Executar update
        transaction.update(userRef, {
          'coins': newCoins,
          'gems': newGems,
          'lastEconomyUpdate': FieldValue.serverTimestamp(),
        });

        print(
            '✅ [SecureFirestore] Economy update: User $userId, Coins: $currentCoins→$newCoins, Gems: $currentGems→$newGems, Reason: $reason');
        return true;
      });
    } catch (e) {
      print('❌ [SecureFirestore] Economy update failed: $e');
      rethrow;
    }
  }

  /// Operação segura para comprar item da loja
  static Future<bool> purchaseShopItem({
    required String userId,
    required ItemModel item,
    int quantity = 1,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser?.uid != userId) {
      throw SecurityException('Usuário não autorizado');
    }

    final totalCost = item.cost * quantity;

    try {
      return await _db.runTransaction<bool>((transaction) async {
        final userRef = _db.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('Usuário não encontrado');
        }

        final userData = userDoc.data()!;
        final currentCoins = userData['coins'] as int? ?? 0;

        // Verificar se tem coins suficientes
        if (currentCoins < totalCost) {
          throw InsufficientFundsException(
              'Coins insuficientes para comprar ${item.name}');
        }

        // Deduzir coins
        transaction.update(userRef, {
          'coins': currentCoins - totalCost,
          'lastPurchase': FieldValue.serverTimestamp(),
        });

        // Adicionar item ao inventário
        final inventoryRef = userRef.collection('inventory').doc();
        transaction.set(inventoryRef, {
          'itemId': item.id,
          'quantity': quantity,
          'acquiredAt': FieldValue.serverTimestamp(),
          'purchasePrice': item.cost,
        });

        // Log da compra
        await _logPurchaseTransaction(
          transaction: transaction,
          userId: userId,
          item: item,
          quantity: quantity,
          totalCost: totalCost,
        );

        print(
            '✅ [SecureFirestore] Purchase: User $userId bought ${quantity}x ${item.name} for $totalCost coins');
        return true;
      });
    } catch (e) {
      print('❌ [SecureFirestore] Purchase failed: $e');
      rethrow;
    }
  }

  /// Operação segura para desbloquear slot
  static Future<bool> unlockPetSlot({
    required String userId,
    int gemCost = 5,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser?.uid != userId) {
      throw SecurityException('Usuário não autorizado');
    }

    try {
      return await _db.runTransaction<bool>((transaction) async {
        final userRef = _db.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw Exception('Usuário não encontrado');
        }

        final userData = userDoc.data()!;
        final currentGems = userData['gems'] as int? ?? 0;
        final currentSlots = userData['purchasedSlotsCount'] as int? ?? 2;

        // Verificar se tem gemas suficientes
        if (currentGems < gemCost) {
          throw InsufficientFundsException('Gemas insuficientes');
        }

        // Verificar limite máximo de slots
        if (currentSlots >= 10) {
          throw BusinessRuleException('Limite máximo de slots atingido');
        }

        // Executar operação
        transaction.update(userRef, {
          'gems': currentGems - gemCost,
          'purchasedSlotsCount': currentSlots + 1,
          'lastSlotUnlock': FieldValue.serverTimestamp(),
        });

        print(
            '✅ [SecureFirestore] Slot unlock: User $userId unlocked slot ${currentSlots + 1} for $gemCost gems');
        return true;
      });
    } catch (e) {
      print('❌ [SecureFirestore] Slot unlock failed: $e');
      rethrow;
    }
  }

  // ========================
  // SECURE PET OPERATIONS
  // ========================

  /// Operação segura para usar item em pet
  static Future<bool> usePetItem({
    required String userId,
    required String petId,
    required String inventoryItemId,
    required ItemModel item,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser?.uid != userId) {
      throw SecurityException('Usuário não autorizado');
    }

    try {
      return await _db.runTransaction<bool>((transaction) async {
        final petRef = _db.collection('pets').doc(petId);
        final petDoc = await transaction.get(petRef);

        if (!petDoc.exists) {
          throw Exception('Pet não encontrado');
        }

        final petData = petDoc.data()!;

        // Verificar ownership
        if (petData['ownerId'] != userId && petData['partnerId'] != userId) {
          throw SecurityException('Usuário não possui este pet');
        }

        // Verificar se item existe no inventário
        final inventoryRef = _db
            .collection('users')
            .doc(userId)
            .collection('inventory')
            .doc(inventoryItemId);
        final inventoryDoc = await transaction.get(inventoryRef);

        if (!inventoryDoc.exists) {
          throw Exception('Item não encontrado no inventário');
        }

        final inventoryData = inventoryDoc.data()!;
        final currentQuantity = inventoryData['quantity'] as int? ?? 0;

        if (currentQuantity <= 0) {
          throw Exception('Item sem quantidade disponível');
        }

        // Aplicar efeitos do item ao pet
        final updatedStats = _applyItemEffects(petData, item);

        // Atualizar pet
        transaction.update(petRef, {
          ...updatedStats,
          'lastCared': FieldValue.serverTimestamp(),
        });

        // Consumir item (diminuir quantidade ou remover)
        if (currentQuantity > 1) {
          transaction.update(inventoryRef, {
            'quantity': currentQuantity - 1,
          });
        } else {
          transaction.delete(inventoryRef);
        }

        print('✅ [SecureFirestore] Item used: ${item.name} on pet $petId');
        return true;
      });
    } catch (e) {
      print('❌ [SecureFirestore] Use item failed: $e');
      rethrow;
    }
  }

  /// Operação segura para recompensar missão
  static Future<bool> completeMission({
    required String userId,
    required int missionId,
    required int rewardCoins,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser?.uid != userId) {
      throw SecurityException('Usuário não autorizado');
    }

    // Validar reward (anti-cheat)
    if (rewardCoins > 200) {
      throw SecurityException('Recompensa muito alta');
    }

    try {
      return await updateUserEconomy(
        userId: userId,
        coinsDelta: rewardCoins,
        reason: 'Mission completion: $missionId',
        transactionId: 'mission_$missionId',
      );
    } catch (e) {
      print('❌ [SecureFirestore] Mission completion failed: $e');
      rethrow;
    }
  }

  // ========================
  // HELPER METHODS
  // ========================

  /// Aplicar efeitos do item aos stats do pet
  static Map<String, dynamic> _applyItemEffects(
      Map<String, dynamic> petData, ItemModel item) {
    final updatedStats = <String, dynamic>{};

    item.effects.forEach((statName, value) {
      final currentStat = petData[statName] as int? ?? 50;
      final newStat = (currentStat + value).clamp(0, 100);
      updatedStats[statName] = newStat;
    });

    return updatedStats;
  }

  /// Log transações de economia para auditoria
  static Future<void> _logEconomyTransaction({
    required Transaction transaction,
    required String userId,
    int? coinsDelta,
    int? gemsDelta,
    required String reason,
    String? transactionId,
  }) async {
    final logRef = _db.collection('audit_logs').doc();
    transaction.set(logRef, {
      'type': 'economy_update',
      'userId': userId,
      'coinsDelta': coinsDelta,
      'gemsDelta': gemsDelta,
      'reason': reason,
      'transactionId': transactionId,
      'timestamp': FieldValue.serverTimestamp(),
      'userAgent': 'Flutter App',
    });
  }

  /// Log transações de compra para auditoria
  static Future<void> _logPurchaseTransaction({
    required Transaction transaction,
    required String userId,
    required ItemModel item,
    required int quantity,
    required int totalCost,
  }) async {
    final logRef = _db.collection('audit_logs').doc();
    transaction.set(logRef, {
      'type': 'item_purchase',
      'userId': userId,
      'itemId': item.id,
      'itemName': item.name,
      'quantity': quantity,
      'unitPrice': item.cost,
      'totalCost': totalCost,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ========================
  // READONLY OPERATIONS (usando serviço existente)
  // ========================

  static Future<UserModel?> getUser(String uid) => _baseService.getUser(uid);
  static Stream<List<PetModel>> getUserPets(String userId) =>
      _baseService.getUserPets(userId);
  static Stream<List<InventoryUserItem>> getUserInventory(String userId) =>
      _baseService.getUserInventory(userId);
}

// ========================
// CUSTOM EXCEPTIONS
// ========================

class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);
  @override
  String toString() => 'SecurityException: $message';
}

class InsufficientFundsException implements Exception {
  final String message;
  InsufficientFundsException(this.message);
  @override
  String toString() => 'InsufficientFundsException: $message';
}

class BusinessRuleException implements Exception {
  final String message;
  BusinessRuleException(this.message);
  @override
  String toString() => 'BusinessRuleException: $message';
}
