// File: lib/services/shop_service.dart

import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/domain/entities/shop_item_entity.dart';

class ShopService {
  static List<ShopItemEntity> getAllItems() {
    return [
      // FOOD ITEMS
      const ShopItemEntity(
        id: 'food_basic_meat',
        name: 'Basic Meat',
        description: 'Simple meat that restores hunger',
        imageUrl: '🍖',
        price: 10,
        currency: CurrencyType.coins,
        category: ItemCategory.food,
        rarity: ItemRarity.common,
        effects: {ItemEffectType.hunger: 25},
      ),
      const ShopItemEntity(
        id: 'food_premium_steak',
        name: 'Premium Steak',
        description: 'Delicious steak that greatly restores hunger',
        imageUrl: '🥩',
        price: 25,
        currency: CurrencyType.coins,
        category: ItemCategory.food,
        rarity: ItemRarity.uncommon,
        effects: {ItemEffectType.hunger: 45, ItemEffectType.happiness: 10},
      ),
      const ShopItemEntity(
        id: 'food_superfood',
        name: 'Superfood',
        description: 'Magical food that boosts all stats',
        imageUrl: '⭐',
        price: 2,
        currency: CurrencyType.gems,
        category: ItemCategory.food,
        rarity: ItemRarity.epic,
        effects: {
          ItemEffectType.hunger: 50,
          ItemEffectType.happiness: 30,
          ItemEffectType.energy: 20
        },
      ),

      // TOY ITEMS
      const ShopItemEntity(
        id: 'toy_ball',
        name: 'Ball',
        description: 'Simple ball that makes pets happy',
        imageUrl: '⚽',
        price: 15,
        currency: CurrencyType.coins,
        category: ItemCategory.toys,
        rarity: ItemRarity.common,
        effects: {ItemEffectType.happiness: 30},
      ),
      const ShopItemEntity(
        id: 'toy_premium_rope',
        name: 'Premium Rope',
        description: 'High-quality rope toy',
        imageUrl: '🪢',
        price: 35,
        currency: CurrencyType.coins,
        category: ItemCategory.toys,
        rarity: ItemRarity.rare,
        effects: {ItemEffectType.happiness: 50, ItemEffectType.energy: -5},
      ),

      // MEDICINE ITEMS
      const ShopItemEntity(
        id: 'medicine_energy_drink',
        name: 'Energy Drink',
        description: 'Restores pet energy instantly',
        imageUrl: '⚡',
        price: 20,
        currency: CurrencyType.coins,
        category: ItemCategory.medicine,
        rarity: ItemRarity.uncommon,
        effects: {ItemEffectType.energy: 40},
      ),
      const ShopItemEntity(
        id: 'medicine_health_potion',
        name: 'Health Potion',
        description: 'Magical potion that restores all stats',
        imageUrl: '🧪',
        price: 1,
        currency: CurrencyType.gems,
        category: ItemCategory.medicine,
        rarity: ItemRarity.rare,
        effects: {
          ItemEffectType.hunger: 100,
          ItemEffectType.happiness: 100,
          ItemEffectType.energy: 100
        },
      ),
    ];
  }

  static List<ShopItemEntity> getItemsByCategory(ItemCategory category) {
    return getAllItems().where((item) => item.category == category).toList();
  }

  static ShopItemEntity? getItemById(String itemId) {
    try {
      return getAllItems().firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }
}
