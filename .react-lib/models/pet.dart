import 'package:flutter/material.dart'; // Para @immutable
import 'accessory.dart'; // Importa o modelo Accessory

// Enum para status do pet
enum PetStatus {
  adopted,
  returned,
  dead,
  waiting,
  matched;

  // Conversão para/de String para SharedPreferences
  String toShortString() => toString().split('.').last;
  static PetStatus fromString(String value) {
    return PetStatus.values.firstWhere(
      (e) => e.toShortString() == value,
      orElse: () => PetStatus.adopted, // Valor padrão ou tratamento de erro
    );
  }
}

@immutable
class Pet {
  final int id;
  final String name;
  final String emoji;
  final String rarity;
  final String category;
  final int level;
  final int xp;
  final int happiness;
  final int hunger;
  final int energy;
  final int health;
  final bool isCollab;
  final PetStatus status;
  final bool canInteract;
  final List<Accessory> accessories;
  final int lastCared;
  final int adoptedAt;
  final String? imageUrl;
  final bool isUnique;
  final String? generatedBy;
  final String? prompt;
  final String? partner;
  final String? partnerAvatar;
  final String? userAvatar;
  final int? revealLevel;
  final bool? identityRevealed;
  final int? diedAt;
  final String? deathReason;
  final int? returnedAt;
  final List<String> traits;
  final int? cost; // Adicionada a propriedade 'cost'

  Pet({
    required this.id,
    required this.name,
    required this.emoji,
    required this.rarity,
    required this.category,
    this.level = 1,
    this.xp = 0,
    this.happiness = 50,
    this.hunger = 50,
    this.energy = 50,
    this.health = 80,
    this.isCollab = false,
    this.status = PetStatus.adopted,
    this.canInteract = true,
    this.accessories = const [],
    required this.lastCared,
    required this.adoptedAt,
    this.imageUrl,
    this.isUnique = false,
    this.generatedBy,
    this.prompt,
    this.partner,
    this.partnerAvatar,
    this.userAvatar,
    this.revealLevel,
    this.identityRevealed,
    this.diedAt,
    this.deathReason,
    this.returnedAt,
    this.traits = const [],
    this.cost, // Inicializa 'cost'
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      rarity: json['rarity'],
      category: json['category'],
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      happiness: json['happiness'] ?? 50,
      hunger: json['hunger'] ?? 50,
      energy: json['energy'] ?? 50,
      health: json['health'] ?? 80,
      isCollab: json['isCollab'] ?? false,
      status: PetStatus.fromString(json['status'] ?? 'adopted'),
      canInteract: json['canInteract'] ?? true,
      accessories: (json['accessories'] as List<dynamic>?)
              ?.map((e) => Accessory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastCared: json['lastCared'],
      adoptedAt: json['adoptedAt'],
      imageUrl: json['imageUrl'],
      isUnique: json['isUnique'] ?? false,
      generatedBy: json['generatedBy'],
      prompt: json['prompt'],
      partner: json['partner'],
      partnerAvatar: json['partnerAvatar'],
      userAvatar: json['userAvatar'],
      revealLevel: json['revealLevel'],
      identityRevealed: json['identityRevealed'],
      diedAt: json['diedAt'],
      deathReason: json['deathReason'],
      returnedAt: json['returnedAt'],
      traits: (json['traits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      cost: json['cost'], // Desserializa 'cost'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'rarity': rarity,
      'category': category,
      'level': level,
      'xp': xp,
      'happiness': happiness,
      'hunger': hunger,
      'energy': energy,
      'health': health,
      'isCollab': isCollab,
      'status': status.toShortString(),
      'canInteract': canInteract,
      'accessories': accessories.map((e) => e.toJson()).toList(),
      'lastCared': lastCared,
      'adoptedAt': adoptedAt,
      'imageUrl': imageUrl,
      'isUnique': isUnique,
      'generatedBy': generatedBy,
      'prompt': prompt,
      'partner': partner,
      'partnerAvatar': partnerAvatar,
      'userAvatar': userAvatar,
      'revealLevel': revealLevel,
      'identityRevealed': identityRevealed,
      'diedAt': diedAt,
      'deathReason': deathReason,
      'returnedAt': returnedAt,
      'traits': traits,
      'cost': cost, // Serializa 'cost'
    };
  }

  Pet copyWith({
    int? id,
    String? name,
    String? emoji,
    String? rarity,
    String? category,
    int? level,
    int? xp,
    int? happiness,
    int? hunger,
    int? energy,
    int? health,
    bool? isCollab,
    PetStatus? status,
    bool? canInteract,
    List<Accessory>? accessories,
    int? lastCared,
    int? adoptedAt,
    String? imageUrl,
    bool? isUnique,
    String? generatedBy,
    String? prompt,
    String? partner,
    String? partnerAvatar,
    String? userAvatar,
    int? revealLevel,
    bool? identityRevealed,
    int? diedAt,
    String? deathReason,
    int? returnedAt,
    List<String>? traits,
    int? cost, // Adiciona 'cost' ao copyWith
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      rarity: rarity ?? this.rarity,
      category: category ?? this.category,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      happiness: happiness ?? this.happiness,
      hunger: hunger ?? this.hunger,
      energy: energy ?? this.energy,
      health: health ?? this.health,
      isCollab: isCollab ?? this.isCollab,
      status: status ?? this.status,
      canInteract: canInteract ?? this.canInteract,
      accessories: accessories ?? this.accessories,
      lastCared: lastCared ?? this.lastCared,
      adoptedAt: adoptedAt ?? this.adoptedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      isUnique: isUnique ?? this.isUnique,
      generatedBy: generatedBy ?? this.generatedBy,
      prompt: prompt ?? this.prompt,
      partner: partner ?? this.partner,
      partnerAvatar: partnerAvatar ?? this.partnerAvatar,
      userAvatar: userAvatar ?? this.userAvatar,
      revealLevel: revealLevel ?? this.revealLevel,
      identityRevealed: identityRevealed ?? this.identityRevealed,
      diedAt: diedAt ?? this.diedAt,
      deathReason: deathReason ?? this.deathReason,
      returnedAt: returnedAt ?? this.returnedAt,
      traits: traits ?? this.traits,
      cost: cost ?? this.cost, // Copia 'cost'
    );
  }
}
