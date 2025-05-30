// ============================================
// ARQUIVO: lib/core/models/mock_models.dart
// ============================================

import 'dart:math';

import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/economy/price.dart';
import 'package:petverse/core/model/economy/transaction.dart';
import 'package:petverse/core/model/user_inventory.dart';

class AnonymousAdoption {
  final String missionId;
  final String codename;
  final int colorTheme;
  final int level;
  final List<String> badges;
  final int successRate;
  final int completedAdoptions;
  final int currentStreak;
  final String region;
  final int views;
  final int interested;
  final int potentialMatches;
  final double timeLeftDays;
  final List<MockPet> pets;
  final String codedMessage;
  final List<String> personalityTags;
  final String status;
  final bool isNew;

  AnonymousAdoption({
    required this.missionId,
    required this.codename,
    required this.colorTheme,
    required this.level,
    required this.badges,
    required this.successRate,
    required this.completedAdoptions,
    required this.currentStreak,
    required this.region,
    required this.views,
    required this.interested,
    required this.potentialMatches,
    required this.timeLeftDays,
    required this.pets,
    required this.codedMessage,
    required this.personalityTags,
    required this.status,
    required this.isNew,
  });

  // Método para criar cópia com modificações
  AnonymousAdoption copyWith({
    String? missionId,
    String? codename,
    int? colorTheme,
    int? level,
    List<String>? badges,
    int? successRate,
    int? completedAdoptions,
    int? currentStreak,
    String? region,
    int? views,
    int? interested,
    int? potentialMatches,
    double? timeLeftDays,
    List<MockPet>? pets,
    String? codedMessage,
    List<String>? personalityTags,
    String? status,
    bool? isNew,
  }) {
    return AnonymousAdoption(
      missionId: missionId ?? this.missionId,
      codename: codename ?? this.codename,
      colorTheme: colorTheme ?? this.colorTheme,
      level: level ?? this.level,
      badges: badges ?? this.badges,
      successRate: successRate ?? this.successRate,
      completedAdoptions: completedAdoptions ?? this.completedAdoptions,
      currentStreak: currentStreak ?? this.currentStreak,
      region: region ?? this.region,
      views: views ?? this.views,
      interested: interested ?? this.interested,
      potentialMatches: potentialMatches ?? this.potentialMatches,
      timeLeftDays: timeLeftDays ?? this.timeLeftDays,
      pets: pets ?? this.pets,
      codedMessage: codedMessage ?? this.codedMessage,
      personalityTags: personalityTags ?? this.personalityTags,
      status: status ?? this.status,
      isNew: isNew ?? this.isNew,
    );
  }

  // Método para converter para JSON (útil para debug)
  Map<String, dynamic> toJson() {
    return {
      'missionId': missionId,
      'codename': codename,
      'colorTheme': colorTheme,
      'level': level,
      'badges': badges,
      'successRate': successRate,
      'completedAdoptions': completedAdoptions,
      'currentStreak': currentStreak,
      'region': region,
      'views': views,
      'interested': interested,
      'potentialMatches': potentialMatches,
      'timeLeftDays': timeLeftDays,
      'pets': pets.map((pet) => pet.toJson()).toList(),
      'codedMessage': codedMessage,
      'personalityTags': personalityTags,
      'status': status,
      'isNew': isNew,
    };
  }
}

class MockPet {
  final String name;
  final String type;
  final String age;
  final String photo;
  final List<String>? traits; // Adicional para características
  final String? description; // Adicional para descrição

  MockPet({
    required this.name,
    required this.type,
    required this.age,
    required this.photo,
    this.traits,
    this.description,
  });

  // Método copyWith
  MockPet copyWith({
    String? name,
    String? type,
    String? age,
    String? photo,
    List<String>? traits,
    String? description,
  }) {
    return MockPet(
      name: name ?? this.name,
      type: type ?? this.type,
      age: age ?? this.age,
      photo: photo ?? this.photo,
      traits: traits ?? this.traits,
      description: description ?? this.description,
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'age': age,
      'photo': photo,
      'traits': traits,
      'description': description,
    };
  }
}

class InterestedUser {
  final String codename;
  final int level;
  final int colorTheme;
  final List<String>? badges;
  final int? successRate;

  InterestedUser({
    required this.codename,
    required this.level,
    required this.colorTheme,
    this.badges,
    this.successRate,
  });

  // Método copyWith
  InterestedUser copyWith({
    String? codename,
    int? level,
    int? colorTheme,
    List<String>? badges,
    int? successRate,
  }) {
    return InterestedUser(
      codename: codename ?? this.codename,
      level: level ?? this.level,
      colorTheme: colorTheme ?? this.colorTheme,
      badges: badges ?? this.badges,
      successRate: successRate ?? this.successRate,
    );
  }

  // Método para converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'codename': codename,
      'level': level,
      'colorTheme': colorTheme,
      'badges': badges,
      'successRate': successRate,
    };
  }
}

// ============================================
// DADOS MOCK CENTRALIZADOS
// ============================================

class MockDataProvider {
  static List<AnonymousAdoption> getAdoptions() {
    return [
      AnonymousAdoption(
        missionId: 'ADT_001',
        codename: 'Guardian Azul',
        colorTheme: 0xFF3B82F6,
        level: 12,
        badges: ['golden_angel', 'shadow_protector'],
        successRate: 94,
        completedAdoptions: 15,
        currentStreak: 5,
        region: 'Zona Sul - SP',
        views: 47,
        interested: 12,
        potentialMatches: 3,
        timeLeftDays: 2.6,
        pets: [
          MockPet(
            name: 'Luna',
            type: 'Gato',
            age: '2 anos',
            photo: '🐱',
            traits: ['carinhoso', 'brincalhão', 'calmo'],
            description: 'Luna é uma gatinha muito dócil e carinhosa',
          ),
          MockPet(
            name: 'Max',
            type: 'Cachorro',
            age: '3 anos',
            photo: '🐕',
            traits: ['leal', 'energético', 'protetor'],
            description: 'Max é um cachorro muito leal e protetor',
          ),
          MockPet(
            name: 'Bella',
            type: 'Coelho',
            age: '1 ano',
            photo: '🐰',
            traits: ['tímido', 'fofo', 'tranquilo'],
            description: 'Bella é uma coelhinha muito fofa e tranquila',
          ),
        ],
        codedMessage:
            'Colaborador experiente busca parceiro dedicado para missão especial',
        personalityTags: ['dedicado', 'organizado', 'carinhoso'],
        status: 'hot',
        isNew: false,
      ),
      AnonymousAdoption(
        missionId: 'ADT_002',
        codename: 'Protetor Rosa',
        colorTheme: 0xFFEC4899,
        level: 8,
        badges: ['first_timer', 'cat_lover'],
        successRate: 89,
        completedAdoptions: 7,
        currentStreak: 3,
        region: 'Centro - RJ',
        views: 23,
        interested: 8,
        potentialMatches: 2,
        timeLeftDays: 4.2,
        pets: [
          MockPet(
            name: 'Mimi',
            type: 'Gato',
            age: '1 ano',
            photo: '🐱',
            traits: ['brincalhão', 'curioso', 'ativo'],
          ),
          MockPet(
            name: 'Toby',
            type: 'Cachorro',
            age: '2 anos',
            photo: '🐕',
            traits: ['amigável', 'obediente', 'carinhoso'],
          ),
          MockPet(
            name: 'Snow',
            type: 'Hamster',
            age: '6 meses',
            photo: '🐹',
            traits: ['pequeno', 'ativo', 'fofo'],
          ),
        ],
        codedMessage: 'Primeira missão em grupo, procuro mentor experiente',
        personalityTags: ['iniciante', 'entusiasmado', 'responsável'],
        status: 'normal',
        isNew: true,
      ),
      AnonymousAdoption(
        missionId: 'ADT_003',
        codename: 'Anjo Verde',
        colorTheme: 0xFF10B981,
        level: 20,
        badges: ['veteran', 'dog_whisperer', 'golden_heart'],
        successRate: 98,
        completedAdoptions: 32,
        currentStreak: 12,
        region: 'Zona Norte - SP',
        views: 89,
        interested: 23,
        potentialMatches: 7,
        timeLeftDays: 0.8,
        pets: [
          MockPet(
            name: 'Rex',
            type: 'Cachorro',
            age: '4 anos',
            photo: '🐕',
            traits: ['forte', 'leal', 'protetor'],
          ),
          MockPet(
            name: 'Whiskers',
            type: 'Gato',
            age: '3 anos',
            photo: '🐱',
            traits: ['independente', 'elegante', 'carinhoso'],
          ),
          MockPet(
            name: 'Pipoca',
            type: 'Papagaio',
            age: '2 anos',
            photo: '🦜',
            traits: ['falante', 'inteligente', 'colorido'],
          ),
        ],
        codedMessage:
            'Veterano em missão urgente, preciso de parceiro confiável',
        personalityTags: ['experiente', 'paciente', 'líder'],
        status: 'urgent',
        isNew: false,
      ),
    ];
  }

  static List<InterestedUser> getInterestedUsers() {
    return [
      InterestedUser(
        codename: 'Protetor Dourado',
        level: 15,
        colorTheme: 0xFFF59E0B,
        badges: ['golden_heart'],
        successRate: 92,
      ),
      InterestedUser(
        codename: 'Guardian Prata',
        level: 11,
        colorTheme: 0xFF6B7280,
        badges: ['consistent'],
        successRate: 88,
      ),
      InterestedUser(
        codename: 'Anjo Roxo',
        level: 9,
        colorTheme: 0xFF8B5CF6,
        badges: ['newcomer'],
        successRate: 85,
      ),
    ];
  }

  static List<AnonymousAdoption> getExtendedAdoptions() {
    return [
      // Adoções existentes
      ...getAdoptions(),

      // Novas adoções para maior variedade
      AnonymousAdoption(
        missionId: 'ADT_004',
        codename: 'Sombra Violeta',
        colorTheme: 0xFF8B5CF6,
        level: 5,
        badges: ['newcomer'],
        successRate: 78,
        completedAdoptions: 3,
        currentStreak: 2,
        region: 'Zona Oeste - SP',
        views: 15,
        interested: 4,
        potentialMatches: 1,
        timeLeftDays: 3.8,
        pets: [
          MockPet(
            name: 'Hope',
            type: 'Coelho',
            age: '4 anos',
            photo: '🐰',
            traits: ['especial', 'forte', 'inspirador'],
            description: 'Coelho com três patas, muito inspirador',
          ),
        ],
        codedMessage:
            'MISSÃO ESPECIAL: Veterano experiente precisa de parceiro para pets com necessidades especiais',
        personalityTags: ['especialista', 'compassivo', 'experiente'],
        status: 'urgent',
        isNew: false,
      ),

      AnonymousAdoption(
        missionId: 'ADT_007',
        codename: 'Protetor Coral',
        colorTheme: 0xFFFF6B6B,
        level: 10,
        badges: ['dog_lover', 'active'],
        successRate: 87,
        completedAdoptions: 12,
        currentStreak: 4,
        region: 'Zona Norte - RJ',
        views: 32,
        interested: 9,
        potentialMatches: 2,
        timeLeftDays: 2.1,
        pets: [
          MockPet(
            name: 'Bolt',
            type: 'Cachorro',
            age: '1 ano',
            photo: '🐕',
            traits: ['energético', 'atlético', 'brincalhão'],
            description: 'Cachorro muito energético, precisa de exercícios',
          ),
          MockPet(
            name: 'Flash',
            type: 'Gato',
            age: '2 anos',
            photo: '🐱',
            traits: ['ativo', 'ágil', 'aventureiro'],
            description: 'Gato muito ativo e aventureiro',
          ),
          MockPet(
            name: 'Rocket',
            type: 'Furão',
            age: '1 ano',
            photo: '🦔',
            traits: ['rápido', 'curioso', 'travesso'],
            description: 'Furão muito rápido e travesso',
          ),
        ],
        codedMessage:
            'Busco parceiro ativo para pets de alta energia - aventura garantida!',
        personalityTags: ['ativo', 'aventureiro', 'energético'],
        status: 'normal',
        isNew: false,
      ),

      AnonymousAdoption(
        missionId: 'ADT_008',
        codename: 'Sábio Dourado',
        colorTheme: 0xFFEAB308,
        level: 30,
        badges: ['master', 'golden_heart', 'wise_mentor'],
        successRate: 100,
        completedAdoptions: 67,
        currentStreak: 25,
        region: 'Interior - SP',
        views: 89,
        interested: 12,
        potentialMatches: 4,
        timeLeftDays: 4.7,
        pets: [
          MockPet(
            name: 'Wisdom',
            type: 'Tartaruga',
            age: '15 anos',
            photo: '🐢',
            traits: ['sábio', 'tranquilo', 'longevo'],
            description: 'Tartaruga muito antiga e sábia',
          ),
          MockPet(
            name: 'Sage',
            type: 'Gato',
            age: '12 anos',
            photo: '🐱',
            traits: ['sênior', 'calmo', 'sábio'],
            description: 'Gato sênior muito sábio e calmo',
          ),
          MockPet(
            name: 'Elder',
            type: 'Cachorro',
            age: '10 anos',
            photo: '🐕',
            traits: ['sênior', 'gentil', 'experiente'],
            description: 'Cachorro idoso muito gentil',
          ),
        ],
        codedMessage:
            'Mestre experiente oferece sabedoria em troca de companhia para pets sêniores',
        personalityTags: ['mestre', 'sábio', 'mentor'],
        status: 'normal',
        isNew: false,
      ),
    ];
  }

  static List<AnonymousAdoption> getAdoptionsByFilter(String filter) {
    final allAdoptions = getExtendedAdoptions();

    switch (filter) {
      case 'Urgentes':
        return allAdoptions
            .where((a) => a.status == 'urgent' || a.timeLeftDays < 1.0)
            .toList();
      case 'Novas':
        return allAdoptions.where((a) => a.isNew).toList();
      case 'Experientes':
        return allAdoptions.where((a) => a.level >= 15).toList();
      case 'Filhotes':
        return allAdoptions
            .where((a) =>
                a.pets.any((pet) => pet.traits?.contains('filhote') ?? false))
            .toList();
      case 'Especiais':
        return allAdoptions
            .where((a) =>
                a.pets.any((pet) => pet.traits?.contains('especial') ?? false))
            .toList();
      case 'Sênior':
        return allAdoptions
            .where((a) =>
                a.pets.any((pet) => pet.traits?.contains('sênior') ?? false))
            .toList();
      default:
        return allAdoptions;
    }
  }

  // Método para simular mudanças de status em tempo real
  static AnonymousAdoption updateAdoptionStatus(AnonymousAdoption adoption) {
    // Simular aumento de visualizações e interesse
    final random = DateTime.now().millisecond;
    return adoption.copyWith(
      views: adoption.views + (random % 5),
      interested: adoption.interested + (random % 3),
      timeLeftDays: adoption.timeLeftDays - 0.1,
    );
  }

  // Método para ordenar adoções por diferentes critérios
  static List<AnonymousAdoption> sortAdoptions(
      List<AnonymousAdoption> adoptions, String sortBy) {
    switch (sortBy) {
      case 'Mais Urgentes':
        adoptions.sort((a, b) => a.timeLeftDays.compareTo(b.timeLeftDays));
        break;
      case 'Mais Populares':
        adoptions.sort((a, b) => b.interested.compareTo(a.interested));
        break;
      case 'Nível Alto':
        adoptions.sort((a, b) => b.level.compareTo(a.level));
        break;
      case 'Recentes':
        adoptions.sort((a, b) => b.isNew ? 1 : -1);
        break;
      default:
        // Ordenação padrão por tempo restante e popularidade
        adoptions.sort((a, b) {
          if (a.status == 'urgent' && b.status != 'urgent') return -1;
          if (b.status == 'urgent' && a.status != 'urgent') return 1;
          if (a.status == 'hot' && b.status != 'hot') return -1;
          if (b.status == 'hot' && a.status != 'hot') return 1;
          return b.interested.compareTo(a.interested);
        });
    }
    return adoptions;
  }

  // ============================================
  // NOVOS DADOS DE LOJA E INVENTÁRIO
  // ============================================

  static UserInventory getUserInventory() {
    return UserInventory(
      coins: 1250,
      gems: 25,
      lastDailyReward: DateTime.now().subtract(const Duration(days: 1)),
      items: {
        'food_basic': 5,
        'food_premium': 2,
        'toy_ball': 3,
        'care_soap': 4,
        'special_energy': 1,
      },
    );
  }

  // static List<GameItem> getShopItems() {
  //   return [
  //     // ============================================
  //     // CATEGORIA: ALIMENTOS
  //     // ============================================
  //     GameItem(
  //       id: 'food_basic',
  //       name: 'Ração Básica',
  //       emoji: '🥫',
  //       category: ItemCategory.food,
  //       rarity: ItemRarity.common,
  //       effects: {'nutrition': 15, 'happiness': 5},
  //       price: Price(coins: 50),
  //       description:
  //           'Alimento nutritivo que se adapta perfeitamente ao seu pet',
  //       visualsByPet: {
  //         PetType.cachorro: ItemVisual(
  //             emoji: '🥩', actionDescription: 'Oferece carne nutritiva'),
  //         PetType.gato: ItemVisual(
  //             emoji: '🐟', actionDescription: 'Oferece peixe fresco'),
  //         PetType.coelho: ItemVisual(
  //             emoji: '🥕', actionDescription: 'Oferece cenouras crocantes'),
  //         PetType.hamster: ItemVisual(
  //             emoji: '🌾', actionDescription: 'Oferece sementes variadas'),
  //         PetType.passaro: ItemVisual(
  //             emoji: '🌾', actionDescription: 'Oferece mix de sementes'),
  //         PetType.tartaruga: ItemVisual(
  //             emoji: '🥬', actionDescription: 'Oferece vegetais frescos'),
  //         PetType.furao:
  //             ItemVisual(emoji: '🥩', actionDescription: 'Oferece carne magra'),
  //       },
  //     ),

  //     GameItem(
  //       id: 'food_premium',
  //       name: 'Refeição Premium',
  //       emoji: '🍖',
  //       category: ItemCategory.food,
  //       rarity: ItemRarity.rare,
  //       effects: {'nutrition': 50, 'happiness': 15},
  //       price: Price(coins: 200),
  //       description: 'Alimento de alta qualidade com nutrientes especiais',
  //       visualsByPet: {
  //         PetType.cachorro: ItemVisual(
  //             emoji: '🥩', actionDescription: 'Bife suculento premium'),
  //         PetType.gato: ItemVisual(
  //             emoji: '🐟', actionDescription: 'Salmão grelhado premium'),
  //         PetType.coelho: ItemVisual(
  //             emoji: '🥕', actionDescription: 'Cenouras orgânicas premium'),
  //         PetType.hamster: ItemVisual(
  //             emoji: '🌰', actionDescription: 'Nozes e sementes premium'),
  //         PetType.passaro: ItemVisual(
  //             emoji: '🍇', actionDescription: 'Frutas e sementes premium'),
  //         PetType.tartaruga: ItemVisual(
  //             emoji: '🥬', actionDescription: 'Verduras orgânicas premium'),
  //         PetType.furao: ItemVisual(
  //             emoji: '🍗', actionDescription: 'Frango premium assado'),
  //       },
  //     ),

  //     GameItem(
  //       id: 'food_deluxe',
  //       name: 'Banquete Deluxe',
  //       emoji: '🍗',
  //       category: ItemCategory.food,
  //       rarity: ItemRarity.epic,
  //       effects: {'nutrition': 100, 'happiness': 25},
  //       price: Price(gems: 5),
  //       description:
  //           'Banquete especial que satisfaz completamente qualquer pet',
  //       visualsByPet: {
  //         PetType.cachorro: ItemVisual(
  //             emoji: '🍖', actionDescription: 'Banquete canino real'),
  //         PetType.gato: ItemVisual(
  //             emoji: '🍤', actionDescription: 'Banquete felino gourmet'),
  //         PetType.coelho: ItemVisual(
  //             emoji: '🥗', actionDescription: 'Banquete vegetal deluxe'),
  //         PetType.hamster: ItemVisual(
  //             emoji: '🥜', actionDescription: 'Banquete de nozes especiais'),
  //         PetType.passaro: ItemVisual(
  //             emoji: '🍯', actionDescription: 'Banquete com frutas e mel'),
  //         PetType.tartaruga: ItemVisual(
  //             emoji: '🌿', actionDescription: 'Banquete de plantas aquáticas'),
  //         PetType.furao: ItemVisual(
  //             emoji: '🦐', actionDescription: 'Banquete de proteínas premium'),
  //       },
  //     ),

  //     GameItem(
  //       id: 'food_birthday',
  //       name: 'Bolo de Aniversário',
  //       emoji: '🎂',
  //       category: ItemCategory.food,
  //       rarity: ItemRarity.legendary,
  //       effects: {'nutrition': 120, 'happiness': 50, 'energy': 30},
  //       price: Price(gems: 15),
  //       description: 'Bolo mágico especial que traz alegria e energia extras',
  //       visualsByPet: {
  //         PetType.cachorro:
  //             ItemVisual(emoji: '🧁', actionDescription: 'Cupcake sabor carne'),
  //         PetType.gato:
  //             ItemVisual(emoji: '🍰', actionDescription: 'Bolo sabor peixe'),
  //         PetType.coelho: ItemVisual(
  //             emoji: '🥕', actionDescription: 'Bolo de cenoura especial'),
  //         PetType.hamster: ItemVisual(
  //             emoji: '🧁', actionDescription: 'Mini bolo de sementes'),
  //         PetType.passaro: ItemVisual(
  //             emoji: '🍯', actionDescription: 'Bolo de frutas com mel'),
  //         PetType.tartaruga: ItemVisual(
  //             emoji: '🌱', actionDescription: 'Bolo de algas nutritivas'),
  //         PetType.furao: ItemVisual(
  //             emoji: '🥓', actionDescription: 'Bolo proteico especial'),
  //       },
  //     ),

  //     // ============================================
  //     // CATEGORIA: BRINQUEDOS
  //     // ============================================
  //     GameItem(
  //       id: 'toy_ball',
  //       name: 'Brinquedo Divertido',
  //       emoji: '🎾',
  //       category: ItemCategory.toys,
  //       rarity: ItemRarity.common,
  //       effects: {'energy': -20, 'happiness': 15},
  //       price: Price(coins: 75),
  //       description: 'Brinquedo versátil que se adapta ao tipo do seu pet',
  //       visualsByPet: {
  //         PetType.cachorro:
  //             ItemVisual(emoji: '🎾', actionDescription: 'Bolinha para buscar'),
  //         PetType.gato:
  //             ItemVisual(emoji: '🪀', actionDescription: 'Barbante mágico'),
  //         PetType.coelho: ItemVisual(
  //             emoji: '🥕', actionDescription: 'Cenoura de brinquedo'),
  //         PetType.hamster:
  //             ItemVisual(emoji: '🎡', actionDescription: 'Rodinha especial'),
  //         PetType.passaro:
  //             ItemVisual(emoji: '🔔', actionDescription: 'Sininho musical'),
  //         PetType.tartaruga:
  //             ItemVisual(emoji: '🏊', actionDescription: 'Brinquedo aquático'),
  //         PetType.furao:
  //             ItemVisual(emoji: '🧸', actionDescription: 'Bonequinho fofo'),
  //       },
  //     ),

  //     GameItem(
  //       id: 'toy_interactive',
  //       name: 'Brinquedo Interativo',
  //       emoji: '🎮',
  //       category: ItemCategory.toys,
  //       rarity: ItemRarity.rare,
  //       effects: {'energy': -30, 'happiness': 25, 'intelligence': 10},
  //       price: Price(coins: 150),
  //       description: 'Brinquedo inteligente que estimula a mente do pet',
  //       visualsByPet: {
  //         PetType.cachorro:
  //             ItemVisual(emoji: '🦴', actionDescription: 'Osso inteligente'),
  //         PetType.gato:
  //             ItemVisual(emoji: '🐭', actionDescription: 'Ratinho robótico'),
  //         PetType.coelho:
  //             ItemVisual(emoji: '🌽', actionDescription: 'Labirinto de milho'),
  //         PetType.hamster:
  //             ItemVisual(emoji: '🏠', actionDescription: 'Casa labirinto'),
  //         PetType.passaro:
  //             ItemVisual(emoji: '🪶', actionDescription: 'Brinquedo de penas'),
  //         PetType.tartaruga:
  //             ItemVisual(emoji: '🪨', actionDescription: 'Pedras empilháveis'),
  //         PetType.furao:
  //             ItemVisual(emoji: '🕳️', actionDescription: 'Túnel interativo'),
  //       },
  //     ),

  //     GameItem(
  //       id: 'toy_luxury',
  //       name: 'Brinquedo de Luxo',
  //       emoji: '💎',
  //       category: ItemCategory.toys,
  //       rarity: ItemRarity.epic,
  //       effects: {'energy': -15, 'happiness': 40, 'intelligence': 20},
  //       price: Price(gems: 8),
  //       description: 'Brinquedo premium feito com materiais especiais',
  //       visualsByPet: {
  //         PetType.cachorro:
  //             ItemVisual(emoji: '👑', actionDescription: 'Coroa real canina'),
  //         PetType.gato: ItemVisual(
  //             emoji: '🎭', actionDescription: 'Brinquedo aristocrático'),
  //         PetType.coelho:
  //             ItemVisual(emoji: '💍', actionDescription: 'Anel mágico'),
  //         PetType.hamster:
  //             ItemVisual(emoji: '🎪', actionDescription: 'Parque de diversões'),
  //         PetType.passaro:
  //             ItemVisual(emoji: '🎨', actionDescription: 'Kit de pintura'),
  //         PetType.tartaruga:
  //             ItemVisual(emoji: '🏰', actionDescription: 'Castelo aquático'),
  //         PetType.furao:
  //             ItemVisual(emoji: '🎠', actionDescription: 'Carrossel miniatura'),
  //       },
  //     ),

  //     // ============================================
  //     // CATEGORIA: CUIDADOS
  //     // ============================================
  //     GameItem(
  //       id: 'care_soap',
  //       name: 'Kit de Higiene',
  //       emoji: '🧼',
  //       category: ItemCategory.care,
  //       rarity: ItemRarity.common,
  //       effects: {'hygiene': 30, 'happiness': 10},
  //       price: Price(coins: 60),
  //       description: 'Kit básico de limpeza que mantém seu pet sempre limpo',
  //       visualsByPet: {
  //         PetType.cachorro:
  //             ItemVisual(emoji: '🛁', actionDescription: 'Banho relaxante'),
  //         PetType.gato:
  //             ItemVisual(emoji: '🪥', actionDescription: 'Escovação especial'),
  //         PetType.coelho:
  //             ItemVisual(emoji: '✨', actionDescription: 'Limpeza delicada'),
  //         PetType.hamster:
  //             ItemVisual(emoji: '🧽', actionDescription: 'Banho de areia'),
  //         PetType.passaro: ItemVisual(
  //             emoji: '💧', actionDescription: 'Banho de água fresca'),
  //         PetType.tartaruga:
  //             ItemVisual(emoji: '🌊', actionDescription: 'Limpeza aquática'),
  //         PetType.furao:
  //             ItemVisual(emoji: '🧴', actionDescription: 'Shampoo especial'),
  //       },
  //     ),

  //     GameItem(
  //       id: 'care_spa',
  //       name: 'Kit Spa Premium',
  //       emoji: '🛁',
  //       category: ItemCategory.care,
  //       rarity: ItemRarity.rare,
  //       effects: {'hygiene': 80, 'happiness': 25, 'health': 15},
  //       price: Price(coins: 180),
  //       description: 'Tratamento spa completo para relaxamento total',
  //       visualsByPet: {
  //         PetType.cachorro:
  //             ItemVisual(emoji: '🧖', actionDescription: 'Spa canino completo'),
  //         PetType.gato:
  //             ItemVisual(emoji: '💆', actionDescription: 'Massagem felina'),
  //         PetType.coelho:
  //             ItemVisual(emoji: '🌸', actionDescription: 'Tratamento floral'),
  //         PetType.hamster:
  //             ItemVisual(emoji: '🏖️', actionDescription: 'Spa de areia fina'),
  //         PetType.passaro:
  //             ItemVisual(emoji: '🌈', actionDescription: 'Banho de cores'),
  //         PetType.tartaruga:
  //             ItemVisual(emoji: '🏝️', actionDescription: 'Resort aquático'),
  //         PetType.furao:
  //             ItemVisual(emoji: '💅', actionDescription: 'Manicure e pedicure'),
  //       },
  //     ),

  //     GameItem(
  //       id: 'care_medicine',
  //       name: 'Poção de Cura',
  //       emoji: '💊',
  //       category: ItemCategory.care,
  //       rarity: ItemRarity.epic,
  //       effects: {'health': 60, 'hygiene': 40},
  //       price: Price(gems: 6),
  //       description: 'Remédio mágico que cura doenças e restaura a saúde',
  //       visualsByPet: {
  //         PetType.cachorro:
  //             ItemVisual(emoji: '💉', actionDescription: 'Vacina protetora'),
  //         PetType.gato:
  //             ItemVisual(emoji: '🍯', actionDescription: 'Mel medicinal'),
  //         PetType.coelho:
  //             ItemVisual(emoji: '🌿', actionDescription: 'Ervas curativas'),
  //         PetType.hamster:
  //             ItemVisual(emoji: '💊', actionDescription: 'Vitamina especial'),
  //         PetType.passaro:
  //             ItemVisual(emoji: '🧪', actionDescription: 'Poção voadora'),
  //         PetType.tartaruga:
  //             ItemVisual(emoji: '🌊', actionDescription: 'Água medicinal'),
  //         PetType.furao: ItemVisual(
  //             emoji: '⚗️', actionDescription: 'Elixir da vitalidade'),
  //       },
  //     ),

  //     // ============================================
  //     // CATEGORIA: ESPECIAIS
  //     // ============================================
  //     GameItem(
  //       id: 'special_energy',
  //       name: 'Poção de Energia',
  //       emoji: '⚡',
  //       category: ItemCategory.special,
  //       rarity: ItemRarity.epic,
  //       effects: {'energy': 100},
  //       price: Price(gems: 12),
  //       description:
  //           'Restaura completamente a energia do seu pet instantaneamente',
  //       visualsByPet: {
  //         PetType.cachorro:
  //             ItemVisual(emoji: '⚡', actionDescription: 'Raio energizante'),
  //         PetType.gato:
  //             ItemVisual(emoji: '✨', actionDescription: 'Faísca mágica'),
  //         PetType.coelho:
  //             ItemVisual(emoji: '🌟', actionDescription: 'Estrela energética'),
  //         PetType.hamster:
  //             ItemVisual(emoji: '💫', actionDescription: 'Cometa energético'),
  //         PetType.passaro: ItemVisual(
  //             emoji: '🌪️', actionDescription: 'Ventania revigorante'),
  //         PetType.tartaruga:
  //             ItemVisual(emoji: '🌊', actionDescription: 'Onda de energia'),
  //         PetType.furao:
  //             ItemVisual(emoji: '⚡', actionDescription: 'Descarga elétrica'),
  //       },
  //     ),

  //     GameItem(
  //       id: 'special_luck',
  //       name: 'Elixir da Sorte',
  //       emoji: '🍀',
  //       category: ItemCategory.special,
  //       rarity: ItemRarity.legendary,
  //       effects: {'xp_multiplier': 2.0, 'duration_hours': 1},
  //       price: Price(gems: 20),
  //       description: 'Dobra o XP ganho por 1 hora - muito raro!',
  //       visualsByPet: {
  //         PetType.cachorro:
  //             ItemVisual(emoji: '🍀', actionDescription: 'Trevo da sorte'),
  //         PetType.gato:
  //             ItemVisual(emoji: '🔮', actionDescription: 'Bola de cristal'),
  //         PetType.coelho:
  //             ItemVisual(emoji: '🌈', actionDescription: 'Arco-íris da sorte'),
  //         PetType.hamster:
  //             ItemVisual(emoji: '🎰', actionDescription: 'Jackpot dourado'),
  //         PetType.passaro:
  //             ItemVisual(emoji: '🪙', actionDescription: 'Moeda dourada'),
  //         PetType.tartaruga:
  //             ItemVisual(emoji: '💎', actionDescription: 'Diamante da sorte'),
  //         PetType.furao:
  //             ItemVisual(emoji: '🎯', actionDescription: 'Alvo certeiro'),
  //       },
  //     ),

  //     GameItem(
  //       id: 'special_love',
  //       name: 'Kit de Amor',
  //       emoji: '💖',
  //       category: ItemCategory.special,
  //       rarity: ItemRarity.legendary,
  //       effects: {'happiness': 50, 'health': 30, 'energy': 50, 'nutrition': 50},
  //       price: Price(gems: 25),
  //       description: 'Kit especial que melhora todos os atributos do pet',
  //       visualsByPet: {
  //         PetType.cachorro:
  //             ItemVisual(emoji: '💝', actionDescription: 'Presente especial'),
  //         PetType.gato:
  //             ItemVisual(emoji: '💕', actionDescription: 'Carinho infinito'),
  //         PetType.coelho:
  //             ItemVisual(emoji: '💘', actionDescription: 'Cupido fofo'),
  //         PetType.hamster:
  //             ItemVisual(emoji: '💗', actionDescription: 'Coração pulsante'),
  //         PetType.passaro:
  //             ItemVisual(emoji: '💖', actionDescription: 'Amor voador'),
  //         PetType.tartaruga:
  //             ItemVisual(emoji: '💙', actionDescription: 'Amor aquático'),
  //         PetType.furao:
  //             ItemVisual(emoji: '💜', actionDescription: 'Amor travesso'),
  //       },
  //     ),
  //   ];
  // }

  // static List<GameItem> getItemsByCategory(ItemCategory category) {
  //   return getShopItems().where((item) => item.category == category).toList();
  // }

  // static GameItem? getItemById(String id) {
  //   try {
  //     return getShopItems().firstWhere((item) => item.id == id);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  static List<Transaction> getTransactionHistory() {
    return [
      Transaction(
        id: 'tx_001',
        itemId: 'food_premium',
        quantity: 1,
        originalPrice: Price(coins: 200),
        currencyUsed: CurrencyType.coins,
        actualCoinsSpent: 200,
        actualGemsSpent: 0,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: TransactionType.purchase,
        notes: 'Compra de ração premium',
      ),
      Transaction(
        id: 'tx_002',
        itemId: 'toy_ball',
        quantity: 2,
        originalPrice: Price(coins: 75), // Preço unitário
        currencyUsed: CurrencyType.coins,
        actualCoinsSpent: 150, // 75 * 2 unidades
        actualGemsSpent: 0,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        type: TransactionType.purchase,
        notes: 'Compra de 2 brinquedos',
      ),
      Transaction(
        id: 'tx_003',
        itemId: 'special_energy',
        quantity: 1,
        originalPrice: Price(gems: 12),
        currencyUsed: CurrencyType.gems,
        actualCoinsSpent: 0,
        actualGemsSpent: 12,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.purchase,
        notes: 'Poção de energia para recuperação',
      ),
      // Exemplos adicionais para demonstrar diferentes cenários
      Transaction(
        id: 'tx_004',
        itemId: 'food_basic',
        quantity: 1,
        originalPrice: Price(coins: 0, gems: 0),
        currencyUsed: CurrencyType.free,
        actualCoinsSpent: 0,
        actualGemsSpent: 0,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.daily,
        notes: 'Recompensa diária coletada',
      ),
      Transaction(
        id: 'tx_005',
        itemId: 'care_spa',
        quantity: 1,
        originalPrice: Price(coins: 180),
        currencyUsed: CurrencyType.coins,
        actualCoinsSpent: 180,
        actualGemsSpent: 0,
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        type: TransactionType.purchase,
        notes: 'Spa premium para o pet',
      ),
      Transaction(
        id: 'tx_006',
        itemId: 'special_love',
        quantity: 1,
        originalPrice: Price(gems: 25),
        currencyUsed: CurrencyType.gems,
        actualCoinsSpent: 0,
        actualGemsSpent: 25,
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        type: TransactionType.purchase,
        notes: 'Kit especial de amor - item lendário',
      ),
      Transaction(
        id: 'tx_007',
        itemId: 'food_deluxe',
        quantity: 1,
        originalPrice: Price(coins: 300, gems: 5, bothRequired: true),
        currencyUsed: CurrencyType.both,
        actualCoinsSpent: 300,
        actualGemsSpent: 5,
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
        type: TransactionType.purchase,
        notes: 'Banquete deluxe - pagamento misto',
      ),
    ];
  }

  static Map<String, int> getDailyRewards() {
    return {
      'coins': 100,
      'gems': 2,
      'food_basic': 1,
    };
  }

  // Métodos utilitários
  static String formatPrice(Price price) {
    if (price.bothRequired) {
      return '${price.coins} 🪙 + ${price.gems} 💎';
    } else if (price.hasCoins && price.hasGems) {
      return '${price.coins} 🪙 ou ${price.gems} 💎';
    } else if (price.hasCoins) {
      return '${price.coins} 🪙';
    } else if (price.hasGems) {
      return '${price.gems} 💎';
    } else {
      return 'Grátis';
    }
  }

  static String getRarityName(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return 'Comum';
      case ItemRarity.rare:
        return 'Raro';
      case ItemRarity.epic:
        return 'Épico';
      case ItemRarity.legendary:
        return 'Lendário';
    }
  }

  static int getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return 0xFF64748B; // Cinza
      case ItemRarity.rare:
        return 0xFF3B82F6; // Azul
      case ItemRarity.epic:
        return 0xFF8B5CF6; // Roxo
      case ItemRarity.legendary:
        return 0xFFF59E0B; // Dourado
    }
  }
}

// =============================================================================
// MOCK DATA SERVICE - CENTRALIZADO
// =============================================================================

class MockDataService {
  static final Random _random = Random();

  // =============================================================================
  // SHOP ITEMS DATA
  // =============================================================================

  static List<Map<String, dynamic>> getShopItemsData() {
    return [
      // === FOOD ITEMS ===
      {
        'id': 'food_basic',
        'name': 'Ração Básica',
        'emoji': '🥫',
        'category': 'food',
        'rarity': 'common',
        'effects': {'nutrition': 15.0, 'happiness': 5.0},
        'coins': 50,
        'gems': null,
        'description': 'Alimento nutritivo que se adapta a qualquer pet',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'food_premium',
        'name': 'Carne Premium',
        'emoji': '🥩',
        'category': 'food',
        'rarity': 'rare',
        'effects': {'nutrition': 50.0, 'happiness': 15.0},
        'coins': 200,
        'gems': null,
        'description':
            'Deliciosa refeição que vira o prato favorito do seu pet',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'food_deluxe',
        'name': 'Banquete Deluxe',
        'emoji': '🍗',
        'category': 'food',
        'rarity': 'epic',
        'effects': {'nutrition': 100.0, 'happiness': 25.0},
        'coins': null,
        'gems': 5,
        'description': 'Banquete completo que satisfaz totalmente seu pet',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'food_special',
        'name': 'Bolo Especial',
        'emoji': '🎂',
        'category': 'food',
        'rarity': 'legendary',
        'effects': {'nutrition': 120.0, 'happiness': 40.0, 'energy': 20.0},
        'coins': null,
        'gems': 10,
        'description': 'Bolo mágico de aniversário que aumenta todos os stats',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'food_snack',
        'name': 'Petisco Saudável',
        'emoji': '🦴',
        'category': 'food',
        'rarity': 'common',
        'effects': {'nutrition': 25.0, 'happiness': 10.0},
        'coins': 80,
        'gems': null,
        'description': 'Snack nutritivo para momentos especiais',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'food_fish',
        'name': 'Peixe Fresco',
        'emoji': '🐟',
        'category': 'food',
        'rarity': 'rare',
        'effects': {'nutrition': 45.0, 'health': 10.0},
        'coins': 150,
        'gems': null,
        'description': 'Peixe fresco rico em nutrientes',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
        'isActive': true,
      },

      // === TOY ITEMS ===
      {
        'id': 'toy_ball',
        'name': 'Bolinha Simples',
        'emoji': '🎾',
        'category': 'toys',
        'rarity': 'common',
        'effects': {'energy': -15.0, 'happiness': 20.0},
        'coins': 30,
        'gems': null,
        'description': 'Brinquedo clássico que se adapta a qualquer pet',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 28)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'toy_magic',
        'name': 'Brinquedo Mágico',
        'emoji': '🪀',
        'category': 'toys',
        'rarity': 'rare',
        'effects': {'energy': -25.0, 'happiness': 35.0},
        'coins': 120,
        'gems': null,
        'description': 'Brinquedo interativo que muda de forma',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 22)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'toy_console',
        'name': 'Console Pet',
        'emoji': '🎮',
        'category': 'toys',
        'rarity': 'epic',
        'effects': {'energy': -40.0, 'happiness': 50.0, 'intelligence': 10.0},
        'coins': null,
        'gems': 8,
        'description': 'Console de jogos adaptado para pets',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 18)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'toy_plush',
        'name': 'Pelúcia Fofa',
        'emoji': '🧸',
        'category': 'toys',
        'rarity': 'common',
        'effects': {'happiness': 25.0, 'comfort': 15.0},
        'coins': 60,
        'gems': null,
        'description': 'Pelúcia macia que acalma qualquer pet',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'toy_robot',
        'name': 'Robô Interativo',
        'emoji': '🤖',
        'category': 'toys',
        'rarity': 'epic',
        'effects': {'intelligence': 25.0, 'happiness': 30.0},
        'coins': null,
        'gems': 12,
        'description': 'Robô que ensina truques novos ao seu pet',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 6)).toIso8601String(),
        'isActive': true,
      },

      // === CARE ITEMS ===
      {
        'id': 'care_soap',
        'name': 'Sabonete Básico',
        'emoji': '🧼',
        'category': 'care',
        'rarity': 'common',
        'effects': {'hygiene': 30.0, 'happiness': 5.0},
        'coins': 40,
        'gems': null,
        'description': 'Sabonete suave para higiene diária',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 26)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'care_spa',
        'name': 'Kit Spa Premium',
        'emoji': '🛁',
        'category': 'care',
        'rarity': 'rare',
        'effects': {'hygiene': 80.0, 'happiness': 20.0, 'health': 10.0},
        'coins': 180,
        'gems': null,
        'description': 'Tratamento completo de spa para seu pet',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 21)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'care_medicine',
        'name': 'Poção de Cura',
        'emoji': '💊',
        'category': 'care',
        'rarity': 'epic',
        'effects': {'health': 60.0, 'happiness': 10.0},
        'coins': null,
        'gems': 4,
        'description': 'Remédio mágico que cura rapidamente',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 16)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'care_brush',
        'name': 'Escova Mágica',
        'emoji': '🪥',
        'category': 'care',
        'rarity': 'common',
        'effects': {'hygiene': 20.0, 'happiness': 15.0},
        'coins': 35,
        'gems': null,
        'description': 'Escova que deixa seu pet brilhando',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'care_shampoo',
        'name': 'Shampoo Aromático',
        'emoji': '🧴',
        'category': 'care',
        'rarity': 'rare',
        'effects': {'hygiene': 50.0, 'happiness': 25.0},
        'coins': 120,
        'gems': null,
        'description': 'Shampoo com fragrância relaxante',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
        'isActive': true,
      },

      // === SPECIAL ITEMS ===
      {
        'id': 'special_energy',
        'name': 'Poção de Energia',
        'emoji': '⚡',
        'category': 'special',
        'rarity': 'epic',
        'effects': {'energy': 100.0},
        'coins': null,
        'gems': 15,
        'description': 'Restaura completamente a energia do pet',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'special_luck',
        'name': 'Elixir da Sorte',
        'emoji': '🌟',
        'category': 'special',
        'rarity': 'legendary',
        'effects': {'xp_multiplier': 2.0},
        'coins': null,
        'gems': 20,
        'description': 'Dobra XP ganho por 1 hora',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 11)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'special_love',
        'name': 'Kit de Amor',
        'emoji': '💝',
        'category': 'special',
        'rarity': 'legendary',
        'effects': {'happiness': 50.0, 'health': 30.0, 'energy': 30.0},
        'coins': null,
        'gems': 25,
        'description': 'Aumenta todos os stats do pet',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'special_rainbow',
        'name': 'Arco-íris Mágico',
        'emoji': '🌈',
        'category': 'special',
        'rarity': 'legendary',
        'effects': {'all_stats': 20.0, 'rare_drop': 1.0},
        'coins': null,
        'gems': 50,
        'description': 'Item lendário que melhora tudo por 24h',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'isActive': true,
      },
      {
        'id': 'special_crystal',
        'name': 'Cristal de Poder',
        'emoji': '💎',
        'category': 'special',
        'rarity': 'legendary',
        'effects': {'all_stats': 35.0, 'xp_multiplier': 1.5},
        'coins': null,
        'gems': 75,
        'description': 'Cristal ancestral com poderes únicos',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'isActive': true,
      },
    ];
  }

  // =============================================================================
  // USER WALLET DATA
  // =============================================================================

  static Map<String, dynamic> getInitialWalletData() {
    return {
      'coins': 1250,
      'gems': 25,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  // =============================================================================
  // MOCK INVENTORY DATA (for testing)
  // =============================================================================

  static List<Map<String, dynamic>> getInitialInventoryData() {
    final shopItems = getShopItemsData();
    final List<Map<String, dynamic>> inventory = [];

    // Add some random items to inventory for testing
    final selectedItems = [
      'food_basic',
      'toy_ball',
      'care_soap',
      'food_snack',
      'toy_plush'
    ];

    for (String itemId in selectedItems) {
      final item = shopItems.firstWhere((item) => item['id'] == itemId);
      inventory.add({
        'id': '${itemId}_${DateTime.now().millisecondsSinceEpoch}',
        'itemId': itemId,
        'item': item,
        'quantity': _random.nextInt(3) + 1, // 1-3 items
        'purchasedAt': DateTime.now()
            .subtract(Duration(days: _random.nextInt(7)))
            .toIso8601String(),
        'usedAt': null,
      });
    }

    return inventory;
  }

  // =============================================================================
  // CATEGORY HELPERS
  // =============================================================================

  static List<Map<String, dynamic>> getCategoriesData() {
    return [
      {
        'category': 'food',
        'name': 'Alimentos',
        'emoji': '🍖',
        'description': 'Itens nutritivos para manter seu pet saudável',
      },
      {
        'category': 'toys',
        'name': 'Brinquedos',
        'emoji': '🎾',
        'description': 'Diversão garantida para seu companheiro',
      },
      {
        'category': 'care',
        'name': 'Cuidados',
        'emoji': '🧼',
        'description': 'Produtos de higiene e saúde',
      },
      {
        'category': 'special',
        'name': 'Especiais',
        'emoji': '⭐',
        'description': 'Itens mágicos com efeitos únicos',
      },
    ];
  }

  // =============================================================================
  // RARITY HELPERS
  // =============================================================================

  static Map<String, dynamic> getRarityData(String rarity) {
    final rarities = {
      'common': {
        'name': 'Comum',
        'color': 0xFF64748B,
        'dropRate': 60.0,
      },
      'rare': {
        'name': 'Raro',
        'color': 0xFF3B82F6,
        'dropRate': 25.0,
      },
      'epic': {
        'name': 'Épico',
        'color': 0xFF8B5CF6,
        'dropRate': 12.0,
      },
      'legendary': {
        'name': 'Lendário',
        'color': 0xFFF59E0B,
        'dropRate': 3.0,
      },
    };

    return rarities[rarity] ?? rarities['common']!;
  }

  // =============================================================================
  // EFFECTS HELPERS
  // =============================================================================

  static Map<String, dynamic> getEffectData(String effect) {
    final effects = {
      'nutrition': {
        'name': 'Nutrição',
        'emoji': '🍖',
        'description': 'Melhora a alimentação do pet',
        'positiveEffect': true,
      },
      'happiness': {
        'name': 'Felicidade',
        'emoji': '😊',
        'description': 'Aumenta o humor do pet',
        'positiveEffect': true,
      },
      'energy': {
        'name': 'Energia',
        'emoji': '⚡',
        'description': 'Afeta o nível de energia',
        'positiveEffect': true, // Can be negative for toys
      },
      'health': {
        'name': 'Saúde',
        'emoji': '❤️',
        'description': 'Melhora a saúde geral',
        'positiveEffect': true,
      },
      'hygiene': {
        'name': 'Higiene',
        'emoji': '🧼',
        'description': 'Mantém o pet limpo',
        'positiveEffect': true,
      },
      'intelligence': {
        'name': 'Inteligência',
        'emoji': '🧠',
        'description': 'Desenvolve habilidades cognitivas',
        'positiveEffect': true,
      },
      'comfort': {
        'name': 'Conforto',
        'emoji': '🛏️',
        'description': 'Proporciona bem-estar',
        'positiveEffect': true,
      },
      'xp_multiplier': {
        'name': 'Multiplicador XP',
        'emoji': '✨',
        'description': 'Multiplica ganho de experiência',
        'positiveEffect': true,
      },
      'all_stats': {
        'name': 'Todos os Stats',
        'emoji': '🌟',
        'description': 'Melhora todos os atributos',
        'positiveEffect': true,
      },
      'rare_drop': {
        'name': 'Drop Raro',
        'emoji': '🎁',
        'description': 'Aumenta chance de itens raros',
        'positiveEffect': true,
      },
    };

    return effects[effect] ??
        {
          'name': effect,
          'emoji': '📈',
          'description': 'Efeito especial',
          'positiveEffect': true,
        };
  }

  // =============================================================================
  // FILTER HELPERS
  // =============================================================================

  static List<Map<String, dynamic>> filterItemsByCategory(String category) {
    return getShopItemsData()
        .where(
            (item) => item['category'] == category && item['isActive'] == true)
        .toList();
  }

  static List<Map<String, dynamic>> filterItemsByRarity(String rarity) {
    return getShopItemsData()
        .where((item) => item['rarity'] == rarity && item['isActive'] == true)
        .toList();
  }

  static List<Map<String, dynamic>> filterItemsByPrice(
      {int? maxCoins, int? maxGems}) {
    return getShopItemsData().where((item) {
      if (!item['isActive']) return false;

      bool affordable = true;

      if (maxCoins != null && item['coins'] != null) {
        affordable = affordable && (item['coins'] as int) <= maxCoins;
      }

      if (maxGems != null && item['gems'] != null) {
        affordable = affordable && (item['gems'] as int) <= maxGems;
      }

      return affordable;
    }).toList();
  }

  // =============================================================================
  // SEARCH HELPERS
  // =============================================================================

  static List<Map<String, dynamic>> searchItems(String query) {
    if (query.isEmpty) return getShopItemsData();

    final lowerQuery = query.toLowerCase();

    return getShopItemsData().where((item) {
      if (!item['isActive']) return false;

      final name = (item['name'] as String).toLowerCase();
      final description = (item['description'] as String).toLowerCase();

      return name.contains(lowerQuery) || description.contains(lowerQuery);
    }).toList();
  }

  // =============================================================================
  // RANDOM GENERATORS (for events/daily rewards)
  // =============================================================================

  static Map<String, dynamic> generateRandomItem(
      {String? category, String? rarity}) {
    List<Map<String, dynamic>> items = getShopItemsData();

    if (category != null) {
      items = items.where((item) => item['category'] == category).toList();
    }

    if (rarity != null) {
      items = items.where((item) => item['rarity'] == rarity).toList();
    }

    if (items.isEmpty) return getShopItemsData().first;

    return items[_random.nextInt(items.length)];
  }

  static Map<String, int> generateDailyReward() {
    final rewards = [
      {'coins': 50, 'gems': 0},
      {'coins': 75, 'gems': 1},
      {'coins': 100, 'gems': 0},
      {'coins': 25, 'gems': 2},
      {'coins': 150, 'gems': 0},
      {'coins': 0, 'gems': 5},
    ];

    final reward = rewards[_random.nextInt(rewards.length)];
    return {
      'coins': reward['coins']!,
      'gems': reward['gems']!,
    };
  }
}
