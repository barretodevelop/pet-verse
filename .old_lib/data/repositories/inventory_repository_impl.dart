// File: lib/data/repositories/inventory_repository_impl.dart

import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/data/datasources/remote/firestore_inventory_datasource.dart';
import 'package:petverse/domain/entities/inventory_item_entity.dart';
import 'package:petverse/domain/repositories/inventory_repository.dart';

/// Implementação do repository de inventário
class InventoryRepositoryImpl implements InventoryRepository {
  final FirestoreInventoryDatasource _datasource;

  InventoryRepositoryImpl(this._datasource);

  @override
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
  }) async {
    try {
      await _datasource.addItem(
        userId: userId,
        shopItemId: shopItemId,
        quantity: quantity,
        name: name,
        description: description,
        imageUrl: imageUrl,
        category: category,
        rarity: rarity,
        effects: effects,
      );
      return const Right(null);
    } catch (e) {
      return Left(InventoryFailure('Erro ao adicionar item ao inventário: $e'));
    }
  }

  @override
  Future<Either<Failure, List<InventoryItemEntity>>> getUserInventory(String userId) async {
    try {
      final items = await _datasource.getUserInventory(userId);
      return Right(items);
    } catch (e) {
      return Left(InventoryFailure('Erro ao carregar inventário: $e'));
    }
  }

  @override
  Future<Either<Failure, InventoryItemEntity?>> getInventoryItem(
      String userId, String itemId) async {
    try {
      final item = await _datasource.getInventoryItem(userId, itemId);
      return Right(item);
    } catch (e) {
      return Left(InventoryFailure('Erro ao buscar item do inventário: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeItem({
    required String userId,
    required String itemId,
    required int quantity,
  }) async {
    try {
      await _datasource.removeItem(
        userId: userId,
        itemId: itemId,
        quantity: quantity,
      );
      return const Right(null);
    } catch (e) {
      return Left(InventoryFailure('Erro ao remover item do inventário: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> useItem({
    required String userId,
    required String itemId,
  }) async {
    try {
      await _datasource.useItem(
        userId: userId,
        itemId: itemId,
      );
      return const Right(null);
    } catch (e) {
      return Left(InventoryFailure('Erro ao usar item do inventário: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateItemQuantity({
    required String userId,
    required String itemId,
    required int newQuantity,
  }) async {
    try {
      await _datasource.updateItemQuantity(
        userId: userId,
        itemId: itemId,
        newQuantity: newQuantity,
      );
      return const Right(null);
    } catch (e) {
      return Left(InventoryFailure('Erro ao atualizar quantidade do item: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearInventory(String userId) async {
    try {
      await _datasource.clearInventory(userId);
      return const Right(null);
    } catch (e) {
      return Left(InventoryFailure('Erro ao limpar inventário: $e'));
    }
  }

  @override
  Future<Either<Failure, List<InventoryItemEntity>>> getItemsByCategory({
    required String userId,
    required String category,
  }) async {
    try {
      final items = await _datasource.getItemsByCategory(
        userId: userId,
        category: category,
      );
      return Right(items);
    } catch (e) {
      return Left(InventoryFailure('Erro ao buscar itens por categoria: $e'));
    }
  }
}
