// File: lib/domain/repositories/inventory_repository.dart

import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/inventory_item_entity.dart';

/// Repository interface para operações de inventário
abstract class InventoryRepository {
  /// Adiciona um item ao inventário do usuário
  Future<Either<Failure, void>> addItem({
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
  Future<Either<Failure, List<InventoryItemEntity>>> getUserInventory(String userId);

  /// Obtém um item específico do inventário
  Future<Either<Failure, InventoryItemEntity?>> getInventoryItem(String userId, String itemId);

  /// Remove uma quantidade específica de um item do inventário
  Future<Either<Failure, void>> removeItem({
    required String userId,
    required String itemId,
    required int quantity,
  });

  /// Usa um item do inventário (decrementa quantidade em 1)
  Future<Either<Failure, void>> useItem({
    required String userId,
    required String itemId,
  });

  /// Atualiza a quantidade de um item específico
  Future<Either<Failure, void>> updateItemQuantity({
    required String userId,
    required String itemId,
    required int newQuantity,
  });

  /// Remove todos os itens do inventário de um usuário
  Future<Either<Failure, void>> clearInventory(String userId);

  /// Obtém itens do inventário filtrados por categoria
  Future<Either<Failure, List<InventoryItemEntity>>> getItemsByCategory({
    required String userId,
    required String category,
  });
}

// ============================================================================
