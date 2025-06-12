// File: lib/core/compatibility/entity_compatibility_reference.dart
// Referência de compatibilidade entre PetEntity e CollaborativePetEntity

import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';
import 'package:petverse/domain/entities/pet_entity.dart';

/// Classe de referência para compatibilidade entre entidades
class EntityCompatibilityReference {
  /// Mapeamento de propriedades comuns entre PetEntity e CollaborativePetEntity
  static const Map<String, Map<String, String>> propertyMapping = {
    'id': {'PetEntity': 'id', 'CollaborativePetEntity': 'id'},
    'name': {'PetEntity': 'name', 'CollaborativePetEntity': 'name'},
    'avatar/image': {'PetEntity': 'imageUrl', 'CollaborativePetEntity': 'imageUrl'},
    'level': {'PetEntity': 'level', 'CollaborativePetEntity': 'level'},
    'experience': {'PetEntity': 'xp', 'CollaborativePetEntity': 'xp'},
    'hunger': {'PetEntity': 'hunger', 'CollaborativePetEntity': 'hunger'},
    'happiness': {'PetEntity': 'happiness', 'CollaborativePetEntity': 'happiness'},
    'energy': {'PetEntity': 'energy', 'CollaborativePetEntity': 'energy'},
    'health': {'PetEntity': 'health', 'CollaborativePetEntity': 'health'},
    'type/breed': {'PetEntity': 'type', 'CollaborativePetEntity': 'type'},
  };

  /// Propriedades específicas de cada entidade
  static const Map<String, List<String>> specificProperties = {
    'PetEntity': [
      'description',
      'isAdopted',
      'xpToNextLevel',
      'lastFed',
      'lastPlayed',
      'lastSlept',
      'evolutionStage',
      'skills',
      'generatedByUserId',
    ],
    'CollaborativePetEntity': [
      'collaborationId',
      'caretakerIds',
      'status',
      'difficulty',
      'revealLevel',
      'revealRequested',
      'revealAccepted',
      'matchedAt',
      'contributionStats',
      'recentActions',
      'revealRequestedAt',
      'createdByUserId',
      'collaborationRewards',
    ],
  };

  /// Helpers seguros para acessar propriedades
  static String getName(dynamic pet) {
    if (pet is PetEntity) return pet.name;
    if (pet is CollaborativePetEntity) return pet.name;
    if (pet is Map<String, dynamic>) return pet['name'] ?? 'Pet';
    return 'Pet';
  }

  static String getImageUrl(dynamic pet) {
    if (pet is PetEntity) return pet.imageUrl;
    if (pet is CollaborativePetEntity) return pet.imageUrl;
    if (pet is Map<String, dynamic>) return pet['imageUrl'] ?? pet['avatar'] ?? '';
    return '';
  }

  static int getLevel(dynamic pet) {
    if (pet is PetEntity) return pet.level;
    if (pet is CollaborativePetEntity) return pet.level;
    if (pet is Map<String, dynamic>) return pet['level'] ?? 1;
    return 1;
  }

  static int getExperience(dynamic pet) {
    if (pet is PetEntity) return pet.xp;
    if (pet is CollaborativePetEntity) return pet.xp;
    if (pet is Map<String, dynamic>) return pet['xp'] ?? pet['experience'] ?? 0;
    return 0;
  }

  static int getHunger(dynamic pet) {
    if (pet is PetEntity) return pet.hunger;
    if (pet is CollaborativePetEntity) return pet.hunger;
    if (pet is Map<String, dynamic>) {
      return pet['hunger'] ?? pet['stats']?['hunger'] ?? 100;
    }
    return 100;
  }

  static int getHappiness(dynamic pet) {
    if (pet is PetEntity) return pet.happiness;
    if (pet is CollaborativePetEntity) return pet.happiness;
    if (pet is Map<String, dynamic>) {
      return pet['happiness'] ?? pet['stats']?['happiness'] ?? 100;
    }
    return 100;
  }

  static int getEnergy(dynamic pet) {
    if (pet is PetEntity) return pet.energy;
    if (pet is CollaborativePetEntity) return pet.energy;
    if (pet is Map<String, dynamic>) {
      return pet['energy'] ?? pet['stats']?['energy'] ?? 100;
    }
    return 100;
  }

  static int getHealth(dynamic pet) {
    if (pet is PetEntity) return pet.health;
    if (pet is CollaborativePetEntity) return pet.health;
    if (pet is Map<String, dynamic>) {
      return pet['health'] ?? pet['stats']?['health'] ?? 100;
    }
    return 100;
  }

  static String getType(dynamic pet) {
    if (pet is PetEntity) return pet.type;
    if (pet is CollaborativePetEntity) return pet.type;
    if (pet is Map<String, dynamic>) return pet['type'] ?? pet['breed'] ?? 'Mixed';
    return 'Mixed';
  }

  /// Verificar se pet é colaborativo
  static bool isCollaborativePet(dynamic pet) {
    if (pet is CollaborativePetEntity) return true;
    if (pet is Map<String, dynamic>) return pet['isCollaborative'] == true;
    return false;
  }

  /// Verificar se pet precisa de cuidado
  static bool needsAttention(dynamic pet) {
    final hunger = getHunger(pet);
    final happiness = getHappiness(pet);
    final energy = getEnergy(pet);
    final health = getHealth(pet);

    return hunger < 30 || happiness < 30 || energy < 20 || health < 40;
  }

  /// Obter emoji do pet baseado no tipo ou imageUrl
  static String getEmoji(dynamic pet) {
    final imageUrl = getImageUrl(pet);
    final type = getType(pet).toLowerCase();

    // Verificar imageUrl primeiro
    if (imageUrl.contains('🐱') || type.contains('cat')) return '🐱';
    if (imageUrl.contains('🐶') || type.contains('dog')) return '🐶';
    if (imageUrl.contains('🐹') || type.contains('hamster')) return '🐹';
    if (imageUrl.contains('🐰') || type.contains('rabbit')) return '🐰';
    if (imageUrl.contains('🦊') || type.contains('fox')) return '🦊';
    if (imageUrl.contains('🐦') || type.contains('bird')) return '🐦';

    // Padrão baseado no tipo
    switch (type) {
      case 'cat':
        return '🐱';
      case 'dog':
        return '🐶';
      case 'hamster':
        return '🐹';
      case 'rabbit':
        return '🐰';
      case 'fox':
        return '🦊';
      case 'bird':
        return '🐦';
      default:
        return '🐾';
    }
  }

  /// Converter qualquer tipo de pet para Map
  static Map<String, dynamic> toMap(dynamic pet) {
    if (pet is PetEntity) {
      return {
        'id': pet.id,
        'name': pet.name,
        'imageUrl': pet.imageUrl,
        'type': pet.type,
        'level': pet.level,
        'xp': pet.xp,
        'hunger': pet.hunger,
        'happiness': pet.happiness,
        'energy': pet.energy,
        'health': pet.health,
        'isCollaborative': false,
      };
    } else if (pet is CollaborativePetEntity) {
      return {
        'id': pet.id,
        'name': pet.name,
        'imageUrl': pet.imageUrl,
        'type': pet.type,
        'level': pet.level,
        'xp': pet.xp,
        'hunger': pet.hunger,
        'happiness': pet.happiness,
        'energy': pet.energy,
        'health': pet.health,
        'isCollaborative': true,
        'status': pet.status.name,
        'caretakerIds': pet.caretakerIds,
      };
    } else if (pet is Map<String, dynamic>) {
      return Map<String, dynamic>.from(pet);
    }

    return {};
  }

  /// Verificar compatibilidade entre pets
  static bool areCompatible(dynamic pet1, dynamic pet2) {
    final level1 = getLevel(pet1);
    final level2 = getLevel(pet2);
    final health1 = (getHealth(pet1) + getHappiness(pet1)) / 2;
    final health2 = (getHealth(pet2) + getHappiness(pet2)) / 2;

    // Diferença de nível máxima de 5
    if ((level1 - level2).abs() > 5) return false;

    // Ambos devem estar saudáveis
    if (health1 < 40 || health2 < 40) return false;

    return true;
  }
}

/// Extension para facilitar uso com qualquer tipo de pet
extension UniversalPetExtension on dynamic {
  String get safeName => EntityCompatibilityReference.getName(this);
  String get safeImageUrl => EntityCompatibilityReference.getImageUrl(this);
  int get safeLevel => EntityCompatibilityReference.getLevel(this);
  int get safeExperience => EntityCompatibilityReference.getExperience(this);
  int get safeHunger => EntityCompatibilityReference.getHunger(this);
  int get safeHappiness => EntityCompatibilityReference.getHappiness(this);
  int get safeEnergy => EntityCompatibilityReference.getEnergy(this);
  int get safeHealth => EntityCompatibilityReference.getHealth(this);
  String get safeType => EntityCompatibilityReference.getType(this);
  String get safeEmoji => EntityCompatibilityReference.getEmoji(this);
  bool get safeNeedsAttention => EntityCompatibilityReference.needsAttention(this);
  bool get safeIsCollaborative => EntityCompatibilityReference.isCollaborativePet(this);
  Map<String, dynamic> get safeMap => EntityCompatibilityReference.toMap(this);
}
