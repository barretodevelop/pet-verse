import 'package:petverse/core/enums/enums/app_enums.dart';

import '../../../core/errors/failures.dart';
import '../../../core/types/either.dart';
import '../../repositories/inventory_repository.dart';
import '../../repositories/pet_repository.dart';
import '../../repositories/shop_repository.dart';

class UseItemParams {
  final String userId;
  final String inventoryItemId;
  final String petId;
  final int quantity;

  UseItemParams({
    required this.userId,
    required this.inventoryItemId,
    required this.petId,
    this.quantity = 1,
  });
}

class UseItem {
  final InventoryRepository _inventoryRepository;
  final ShopRepository _shopRepository;
  final PetRepository _petRepository;

  UseItem(
    this._inventoryRepository,
    this._shopRepository,
    this._petRepository,
  );

  Future<Either<Failure, void>> call(UseItemParams params) async {
    // Get inventory item
    final inventoryResult = await _inventoryRepository.getInventoryItem(
      params.userId,
      params.inventoryItemId,
    );

    return inventoryResult.fold(
      (failure) => Left(failure),
      (inventoryItem) async {
        if (inventoryItem == null) {
          return const Left(DatabaseFailure('Inventory item not found'));
        }

        if (inventoryItem.quantity < params.quantity) {
          return const Left(DatabaseFailure('Not enough items in inventory'));
        }

        // Get shop item for effects
        final shopItemResult = await _shopRepository.getItemById(
          inventoryItem.shopItemId,
        );

        return shopItemResult.fold(
          (failure) => Left(failure),
          (shopItem) async {
            if (shopItem == null) {
              return const Left(DatabaseFailure('Shop item not found'));
            }

            // Get pet to apply effects
            final petResult = await _petRepository.getPetById(
              userId: params.userId,
              petId: params.petId,
            );

            return petResult.fold(
              (failure) => Left(failure),
              (pet) async {
                if (pet == null) {
                  return const Left(PetGameFailure('Pet not found'));
                }

                // Apply item effects to pet
                var updatedPet = pet;

                for (final effect in shopItem.effects.entries) {
                  switch (effect.key) {
                    case ItemEffectType.hunger:
                      updatedPet = updatedPet.copyWith(
                        hunger: (pet.hunger + effect.value).clamp(0, 100),
                      );
                      break;
                    case ItemEffectType.happiness:
                      updatedPet = updatedPet.copyWith(
                        happiness: (pet.happiness + effect.value).clamp(0, 100),
                      );
                      break;
                    case ItemEffectType.energy:
                      updatedPet = updatedPet.copyWith(
                        energy: (pet.energy + effect.value).clamp(0, 100),
                      );
                      break;
                    case ItemEffectType.xp:
                      updatedPet = updatedPet.copyWith(
                        xp: pet.xp + effect.value,
                      );
                      break;
                    default:
                      break;
                  }
                }

                // Update pet in database
                final updatePetResult = await _petRepository.updatePet(
                  userId: params.userId,
                  pet: updatedPet,
                );

                return updatePetResult.fold(
                  (failure) => Left(failure),
                  (_) async {
                    // Remove item from inventory
                    final removeResult = await _inventoryRepository.removeItem(
                      userId: params.userId,
                      inventoryItemId: params.inventoryItemId,
                      quantity: params.quantity,
                    );

                    return removeResult.fold(
                      (failure) => Left(failure),
                      (_) => const Right(null),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
