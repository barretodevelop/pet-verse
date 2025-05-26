// lib/features/shop/models/shop_item.dart
import 'package:equatable/equatable.dart';

enum ItemCategory { food, toys, accessories, backgrounds }

class ShopItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int price;
  final ItemCategory category;
  final Map<String, dynamic>? effects;
  final bool isPremium;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.price,
    required this.category,
    this.effects,
    this.isPremium = false,
  });

  @override
  List<Object?> get props => [id, name, price, category, isPremium];
}

// Itens disponíveis na loja
class ShopItems {
  static const List<ShopItem> allItems = [
    // Comidas
    ShopItem(
      id: 'food_premium',
      name: 'Ração Premium',
      description: 'Aumenta fome em 50 pontos',
      emoji: '🥩',
      price: 100,
      category: ItemCategory.food,
      effects: {'hunger': 50},
    ),
    ShopItem(
      id: 'food_treat',
      name: 'Petisco Especial',
      description: 'Aumenta fome em 30 e felicidade em 20',
      emoji: '🍖',
      price: 75,
      category: ItemCategory.food,
      effects: {'hunger': 30, 'happiness': 20},
    ),
    ShopItem(
      id: 'food_cookie',
      name: 'Biscoito de Pet',
      description: 'Aumenta fome em 20',
      emoji: '🍪',
      price: 30,
      category: ItemCategory.food,
      effects: {'hunger': 20},
    ),
    
    // Brinquedos
    ShopItem(
      id: 'toy_ball',
      name: 'Bola Colorida',
      description: 'Aumenta felicidade em 40',
      emoji: '⚽',
      price: 80,
      category: ItemCategory.toys,
      effects: {'happiness': 40},
    ),
    ShopItem(
      id: 'toy_rope',
      name: 'Corda de Brincar',
      description: 'Aumenta felicidade em 30',
      emoji: '🪢',
      price: 50,
      category: ItemCategory.toys,
      effects: {'happiness': 30},
    ),
    
    // Acessórios
    ShopItem(
      id: 'acc_hat',
      name: 'Chapéu Estiloso',
      description: 'Deixa seu pet mais charmoso',
      emoji: '🎩',
      price: 200,
      category: ItemCategory.accessories,
      isPremium: true,
    ),
    ShopItem(
      id: 'acc_glasses',
      name: 'Óculos Escuros',
      description: 'Para um pet descolado',
      emoji: '🕶️',
      price: 150,
      category: ItemCategory.accessories,
    ),
    ShopItem(
      id: 'acc_bow',
      name: 'Laço Fofo',
      description: 'Perfeito para pets elegantes',
      emoji: '🎀',
      price: 100,
      category: ItemCategory.accessories,
    ),
    
    // Backgrounds
    ShopItem(
      id: 'bg_beach',
      name: 'Praia Paradisíaca',
      description: 'Leve seu pet para a praia',
      emoji: '🏖️',
      price: 300,
      category: ItemCategory.backgrounds,
      isPremium: true,
    ),
    ShopItem(
      id: 'bg_garden',
      name: 'Jardim Florido',
      description: 'Um ambiente natural',
      emoji: '🌻',
      price: 250,
      category: ItemCategory.backgrounds,
    ),
  ];
}


