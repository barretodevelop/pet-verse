// lib/data/game_data.dart
import 'package:flutter/material.dart';
import 'package:petverse/shared/enums/enums.dart';
import 'package:petverse/shared/models/app_event.dart';
import 'package:petverse/shared/models/pet_definition.dart';
import 'package:petverse/shared/models/quest.dart';
import 'package:petverse/shared/models/shop_item.dart';

class GameData {
  static final List<PetDefinition> availablePets = [
    const PetDefinition(id: 'dog', name: 'Cachorro', emoji: '🐶'),
    const PetDefinition(id: 'cat', name: 'Gato', emoji: '🐱'),
    const PetDefinition(id: 'bunny', name: 'Coelho', emoji: '🐰'),
    const PetDefinition(id: 'hamster', name: 'Hamster', emoji: '🐹'),
    const PetDefinition(id: 'fox', name: 'Raposa', emoji: '🦊'),
  ];

  static final Map<String, ShopItem> _baseShopItems = {
    'hat': const ShopItem(
        id: 'hat',
        name: 'Chapéu Elegante',
        emoji: '🎩',
        coinPrice: 20,
        category: ItemCategory.accessory,
        isStackable: false),
    'glasses': const ShopItem(
        id: 'glasses',
        name: 'Óculos Descolados',
        emoji: '🕶️',
        coinPrice: 15,
        category: ItemCategory.accessory,
        isStackable: false),
    'apple': const ShopItem(
        id: 'apple',
        name: 'Maçã Suculenta',
        emoji: '🍎',
        coinPrice: 2,
        category: ItemCategory.food),
    'fish_food': const ShopItem(
        id: 'fish_food',
        name: 'Ração de Peixe',
        emoji: '🐟',
        coinPrice: 3,
        category: ItemCategory.food),
    'carrot': const ShopItem(
        id: 'carrot',
        name: 'Cenoura Crocante',
        emoji: '🥕',
        coinPrice: 2,
        category: ItemCategory.food),
    'ball': const ShopItem(
        id: 'ball',
        name: 'Bola Divertida',
        emoji: '⚽',
        coinPrice: 8,
        category: ItemCategory.toy),
    'yarn_ball': const ShopItem(
        id: 'yarn_ball',
        name: 'Novelo de Lã',
        emoji: '🧶',
        coinPrice: 7,
        category: ItemCategory.toy),
    'health_potion': const ShopItem(
        id: 'health_potion',
        name: 'Pílula de Saúde',
        emoji: '💊',
        coinPrice: 15,
        category: ItemCategory.medicine),
    'soap': const ShopItem(
        id: 'soap',
        name: 'Sabonete Perfumado',
        emoji: '🧼',
        coinPrice: 10,
        category: ItemCategory.bath),
    'scissors': const ShopItem(
        id: 'scissors',
        name: 'Tesoura de Tosa',
        emoji: '✂️',
        coinPrice: 12,
        category: ItemCategory.grooming),
    'wallpaper_forest': const ShopItem(
        id: 'wallpaper_forest',
        name: 'Papel de Parede Floresta',
        assetPath: 'assets/images/bg_forest.png',
        coinPrice: 50,
        category: ItemCategory.environment,
        isStackable: false,
        description: "Uma vista relaxante da floresta."),
    'wallpaper_stars': const ShopItem(
        id: 'wallpaper_stars',
        name: 'Papel de Parede Estrelado',
        assetPath: 'assets/images/bg_stars.png',
        coinPrice: 60,
        category: ItemCategory.environment,
        isStackable: false,
        description: "Para sonhar com as estrelas."),
    'floor_grass': const ShopItem(
        id: 'floor_grass',
        name: 'Piso de Grama',
        itemColor: Color(0xFF90EE90),
        coinPrice: 30,
        category: ItemCategory.environment,
        isStackable: false,
        description: "Como um piquenique em casa."), // Verde mais claro
    'floor_wood': const ShopItem(
        id: 'floor_wood',
        name: 'Piso de Madeira',
        itemColor: Color(0xFF8B4513),
        coinPrice: 40,
        category: ItemCategory.environment,
        isStackable: false,
        description: "Um toque rústico e elegante."),
  };

  static final Map<String, ShopItem> _eventShopItems = {
    'sunglasses': const ShopItem(
        id: 'sunglasses',
        name: 'Óculos de Sol Veranis',
        emoji: '😎',
        coinPrice: 25,
        category: ItemCategory.accessory,
        isStackable: false),
    'ice_cream': const ShopItem(
        id: 'ice_cream',
        name: 'Sorvete Refrescante',
        emoji: '🍦',
        coinPrice: 5,
        category: ItemCategory.food),
  };

  static final Map<String, Quest> _baseQuests = {
    'feed_3': const Quest(
        id: 'feed_3',
        title: 'Hora do Lanche',
        description: 'Alimente seu pet 3 vezes',
        type: QuestType.feed,
        targetCount: 3,
        rewardCoins: 10,
        detail: ''),
    'play_5': const Quest(
        id: 'play_5',
        title: 'Brincalhão',
        description: 'Brinque com seu pet 5 vezes',
        type: QuestType.play,
        targetCount: 5,
        rewardCoins: 15,
        detail: ''),
    'buy_1': const Quest(
        id: 'buy_1',
        title: 'Comprador',
        description: 'Compre 1 item na loja',
        type: QuestType.buyItem,
        targetCount: 1,
        rewardGems: 1,
        detail: ''),
    'earn_20': const Quest(
        id: 'earn_20',
        title: 'Pé-quente',
        description: 'Ganhe 20 moedas',
        type: QuestType.earnCoins,
        targetCount: 20,
        rewardCoins: 5,
        detail: ''),
    'use_toy_2': const Quest(
        id: 'use_toy_2',
        title: 'Mestre dos Brinquedos',
        description: 'Use um brinquedo 2 vezes',
        type: QuestType.useToy,
        targetCount: 2,
        rewardCoins: 12,
        detail: ''),
    'give_bath_1': const Quest(
        id: 'give_bath_1',
        title: 'Hora do Banho',
        description: 'Dê um banho no seu pet',
        type: QuestType.giveBath,
        targetCount: 1,
        rewardCoins: 10,
        rewardGems: 1,
        detail: ''),
    'use_medicine_1': const Quest(
        id: 'use_medicine_1',
        title: 'Check-up',
        description: 'Use um remédio no seu pet',
        type: QuestType.useMedicine,
        targetCount: 1,
        rewardCoins: 15,
        detail: ''),
    'groom_pet_1': const Quest(
        id: 'groom_pet_1',
        title: 'Dia de Beleza',
        description: 'Tose seu pet',
        type: QuestType.groomPet,
        targetCount: 1,
        rewardCoins: 8,
        detail: ''),
    'play_minigame_1': const Quest(
        id: 'play_minigame_1',
        title: 'Diversão Rápida',
        description: 'Jogue um minijogo',
        type: QuestType.playMinigame,
        targetCount: 1,
        rewardCoins: 15,
        rewardGems: 1,
        detail: ''),
  };

  static final Map<String, Quest> _eventQuests = {
    'summer_play': const Quest(
        id: 'summer_play',
        title: 'Diversão de Verão',
        description: 'Brinque 10 vezes durante o evento',
        type: QuestType.play,
        targetCount: 10,
        rewardGems: 5,
        detail: ''),
  };

  static List<ShopItem> getShopItems(AppEvent? activeEvent) {
    final items = List<ShopItem>.from(_baseShopItems.values);
    if (activeEvent != null) {
      for (var id in activeEvent.eventItemIds) {
        if (_eventShopItems.containsKey(id)) {
          items.add(_eventShopItems[id]!);
        }
      }
    }
    return items;
  }

  static Quest? getQuestById(String id) => _baseQuests[id] ?? _eventQuests[id];

  static List<Quest> getAvailableQuests(AppEvent? activeEvent) {
    final quests = List<Quest>.from(_baseQuests.values);
    if (activeEvent != null) {
      for (var id in activeEvent.eventQuestIds) {
        if (_eventQuests.containsKey(id)) {
          quests.add(_eventQuests[id]!);
        }
      }
    }
    return quests;
  }

  static PetDefinition? getPetDefinitionById(String? id) {
    if (id == null) return null;
    try {
      return availablePets.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }
}
