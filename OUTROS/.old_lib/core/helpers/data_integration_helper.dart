// File: lib/core/helpers/data_integration_helper.dart
// Helper para integração e conversão de dados entre diferentes providers

import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';
import 'package:petverse/domain/entities/pet_entity.dart';
import 'package:petverse/presentation/providers/collaboration_slots_provider.dart';

/// Helper para integração de dados entre diferentes partes do sistema
class DataIntegrationHelper {
  /// Converter pet colaborativo para formato compatível com enhanced pet provider
  static Map<String, dynamic> collaborativePetToEnhancedFormat(
      CollaborativePetEntity collaborativePet) {
    return {
      'id': collaborativePet.id,
      'name': collaborativePet.name,
      'avatar': collaborativePet.imageUrl, // CollaborativePetEntity usa imageUrl, não avatar
      'level': collaborativePet.level,
      'experience': collaborativePet.xp, // CollaborativePetEntity usa xp, não experience
      'hunger': collaborativePet.hunger, // Propriedades diretas da PetEntity
      'happiness': collaborativePet.happiness,
      'energy': collaborativePet.energy,
      'health': collaborativePet.health,
      'breed': collaborativePet.type, // CollaborativePetEntity usa type, não breed
      'type': 'collaborative',
      'collaborationStatus': collaborativePet.status.name,
      'isCollaborative': true,
      'partnerId':
          collaborativePet.caretakerIds.isNotEmpty ? collaborativePet.caretakerIds.first : null,
      'lastActivity':
          collaborativePet.matchedAt.toIso8601String(), // Usar matchedAt ao invés de lastActiveAt
      'createdAt': collaborativePet.matchedAt
          .toIso8601String(), // CollaborativePetEntity não tem createdAt separado
    };
  }

  /// Converter pet regular para formato compatível com collaborative provider
  static Map<String, dynamic> regularPetToCollaborativeFormat(PetEntity regularPet) {
    return {
      'id': regularPet.id,
      'name': regularPet.name,
      'avatar': regularPet.imageUrl, // PetEntity usa imageUrl
      'level': regularPet.level,
      'experience': regularPet.xp, // PetEntity usa xp
      'breed': regularPet.type,
      'isCollaborative': false,
      'type': 'individual',
      'stats': {
        'hunger': regularPet.hunger,
        'happiness': regularPet.happiness,
        'energy': regularPet.energy,
        'health': regularPet.health,
      },
      'createdAt': regularPet.lastFed.toIso8601String(), // Usar lastFed como fallback
      'lastActivity': DateTime.now().toIso8601String(),
    };
  }

  /// Converter lista de pets colaborativos em slots
  static List<CollaborationSlot> petsToSlots(List<CollaborativePetEntity> pets,
      {int maxSlots = 3}) {
    final slots = <CollaborationSlot>[];

    for (int i = 0; i < maxSlots; i++) {
      if (i < pets.length) {
        // Slot ocupado
        final pet = pets[i];
        slots.add(CollaborationSlot(
          index: i,
          petId: pet.id,
          pet: pet,
          // isPremium: i >= 1, // Primeiro slot gratuito
          isOccupied: true,
          status: pet.status, type: SlotType.regular,
        ));
      } else {
        // Slot vazio
        slots.add(CollaborationSlot(
          index: i,
          // isPremium: i >= 1,
          isOccupied: false, type: SlotType.premium,
        ));
      }
    }

    return slots;
  }

  /// Mesclar dados de pets de diferentes providers
  static List<Map<String, dynamic>> mergeAllPetsData(
    List<PetEntity> regularPets,
    List<CollaborativePetEntity> collaborativePets,
  ) {
    final mergedPets = <Map<String, dynamic>>[];

    // Adicionar pets regulares
    for (final pet in regularPets) {
      mergedPets.add(regularPetToCollaborativeFormat(pet));
    }

    // Adicionar pets colaborativos
    for (final pet in collaborativePets) {
      mergedPets.add(collaborativePetToEnhancedFormat(pet));
    }

    // Ordenar por nível (maior primeiro) e depois por nome
    mergedPets.sort((a, b) {
      final levelComparison = (b['level'] as int).compareTo(a['level'] as int);
      if (levelComparison != 0) return levelComparison;
      return (a['name'] as String).compareTo(b['name'] as String);
    });

    return mergedPets;
  }

  /// Calcular estatísticas agregadas de todos os pets
  static Map<String, dynamic> calculateAggregatedStats(
    List<PetEntity> regularPets,
    List<CollaborativePetEntity> collaborativePets,
  ) {
    final allPets = mergeAllPetsData(regularPets, collaborativePets);

    if (allPets.isEmpty) {
      return {
        'totalPets': 0,
        'averageLevel': 0.0,
        'totalExperience': 0,
        'highestLevel': 0,
        'petsNeedingCare': 0,
        'activeCollaborations': 0,
        'completedCollaborations': 0,
      };
    }

    final totalPets = allPets.length;
    final regularPetsCount = regularPets.length;
    final collaborativePetsCount = collaborativePets.length;

    final totalLevel = allPets.fold<int>(0, (sum, pet) => sum + (pet['level'] as int));
    final averageLevel = totalLevel / totalPets;

    final totalExperience =
        allPets.fold<int>(0, (sum, pet) => sum + (pet['experience'] as int? ?? 0));
    final highestLevel = allPets.fold<int>(
        0, (max, pet) => (pet['level'] as int) > max ? (pet['level'] as int) : max);

    // Contar pets que precisam de cuidado
    int petsNeedingCare = 0;
    for (final pet in allPets) {
      final hunger = pet['hunger'] as int? ?? 100;
      final happiness = pet['happiness'] as int? ?? 100;
      final energy = pet['energy'] as int? ?? 100;
      final health = pet['health'] as int? ?? 100;

      if (hunger < 30 || happiness < 30 || energy < 20 || health < 40) {
        petsNeedingCare++;
      }
    }

    // Contar colaborações ativas
    final activeCollaborations = collaborativePets
        .where((pet) => pet.status == CollaborationStatus.activeCollaboration)
        .length;

    return {
      'totalPets': totalPets,
      'regularPets': regularPetsCount,
      'collaborativePets': collaborativePetsCount,
      'averageLevel': averageLevel.toStringAsFixed(1),
      'totalExperience': totalExperience,
      'highestLevel': highestLevel,
      'petsNeedingCare': petsNeedingCare,
      'activeCollaborations': activeCollaborations,
      'completedCollaborations':
          collaborativePets.where((pet) => pet.status == CollaborationStatus.completed).length,
      'healthyPetsPercentage': ((totalPets - petsNeedingCare) / totalPets * 100).round(),
    };
  }

  /// Converter status de colaboração para display amigável
  static String getCollaborationStatusDisplay(CollaborationStatus status) {
    switch (status) {
      case CollaborationStatus.waitingForPartner:
        return 'Aguardando Parceiro';
      case CollaborationStatus.activeCollaboration:
        return 'Colaboração Ativa';
      case CollaborationStatus.revealAvailable:
        return 'Reveal Disponível';
      case CollaborationStatus.revealed:
        return 'Parceiros Revelados';
      case CollaborationStatus.completed:
        return 'Concluída';
      case CollaborationStatus.abandoned:
        return 'Abandonada';
    }
  }

  /// Obter cor para status de colaboração
  static String getCollaborationStatusColor(CollaborationStatus status) {
    switch (status) {
      case CollaborationStatus.waitingForPartner:
        return '#FFA726'; // Orange
      case CollaborationStatus.activeCollaboration:
        return '#66BB6A'; // Green
      case CollaborationStatus.revealAvailable:
        return '#AB47BC'; // Purple
      case CollaborationStatus.revealed:
        return '#42A5F5'; // Blue
      case CollaborationStatus.completed:
        return '#26A69A'; // Teal
      case CollaborationStatus.abandoned:
        return '#EF5350'; // Red
    }
  }

  /// Priorizar ações recomendadas baseado no estado dos pets
  static List<Map<String, dynamic>> getRecommendedActions(
    List<PetEntity> regularPets,
    List<CollaborativePetEntity> collaborativePets,
  ) {
    final recommendations = <Map<String, dynamic>>[];

    // Verificar pets que precisam de cuidado urgente
    for (final pet in regularPets) {
      if (pet.hunger < 20) {
        recommendations.add({
          'type': 'urgent',
          'action': 'feed',
          'petId': pet.id,
          'petName': pet.name,
          'message': '${pet.name} está com muita fome!',
          'priority': 1,
        });
      }

      if (pet.health < 30) {
        recommendations.add({
          'type': 'urgent',
          'action': 'heal',
          'petId': pet.id,
          'petName': pet.name,
          'message': '${pet.name} precisa de cuidados médicos!',
          'priority': 1,
        });
      }

      if (pet.happiness < 25) {
        recommendations.add({
          'type': 'important',
          'action': 'play',
          'petId': pet.id,
          'petName': pet.name,
          'message': '${pet.name} está triste, que tal brincar?',
          'priority': 2,
        });
      }
    }

    // Verificar colaborações que precisam de atenção
    for (final pet in collaborativePets) {
      if (pet.status == CollaborationStatus.revealAvailable) {
        recommendations.add({
          'type': 'special',
          'action': 'reveal',
          'petId': pet.id,
          'petName': pet.name,
          'message': '${pet.name} pode revelar o parceiro!',
          'priority': 2,
        });
      }

      if (pet.status == CollaborationStatus.waitingForPartner) {
        recommendations.add({
          'type': 'info',
          'action': 'wait',
          'petId': pet.id,
          'petName': pet.name,
          'message': '${pet.name} aguarda um parceiro...',
          'priority': 3,
        });
      }
    }

    // Ordenar por prioridade
    recommendations.sort((a, b) => (a['priority'] as int).compareTo(b['priority'] as int));

    return recommendations.take(5).toList(); // Máximo 5 recomendações
  }

  /// Verificar compatibilidade entre pets para colaboração
  static bool arePetsCompatible(PetEntity pet1, dynamic pet2) {
    // Verificar diferença de nível (máximo 5 níveis)
    int pet2Level = 1;
    if (pet2 is PetEntity) {
      pet2Level = pet2.level;
    } else if (pet2 is CollaborativePetEntity) {
      pet2Level = pet2.level;
    } else if (pet2 is Map<String, dynamic>) {
      pet2Level = pet2['level'] ?? 1;
    }

    final levelDifference = (pet1.level - pet2Level).abs();
    if (levelDifference > 5) return false;

    // Verificar se ambos estão saudáveis o suficiente
    final pet1Health = (pet1.health + pet1.happiness) / 2;

    double pet2Health = 50.0;
    if (pet2 is PetEntity) {
      pet2Health = (pet2.health + pet2.happiness) / 2;
    } else if (pet2 is CollaborativePetEntity) {
      pet2Health = (pet2.health + pet2.happiness) / 2;
    } else if (pet2 is Map<String, dynamic>) {
      final health = pet2['health'] ?? 50;
      final happiness = pet2['happiness'] ?? 50;
      pet2Health = (health + happiness) / 2;
    }

    if (pet1Health < 40 || pet2Health < 40) return false;

    return true;
  }

  /// Gerar ID único para operações
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Converter timestamp para formato amigável
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'agora';
    }
  }

  /// Validar dados de pet antes de salvar
  static Map<String, dynamic> validatePetData(Map<String, dynamic> petData) {
    final validatedData = Map<String, dynamic>.from(petData);

    // Garantir que stats estão dentro dos limites
    if (validatedData['hunger'] != null) {
      validatedData['hunger'] = (validatedData['hunger'] as int).clamp(0, 100);
    }
    if (validatedData['happiness'] != null) {
      validatedData['happiness'] = (validatedData['happiness'] as int).clamp(0, 100);
    }
    if (validatedData['energy'] != null) {
      validatedData['energy'] = (validatedData['energy'] as int).clamp(0, 100);
    }
    if (validatedData['health'] != null) {
      validatedData['health'] = (validatedData['health'] as int).clamp(0, 100);
    }

    // Garantir que level é positivo
    if (validatedData['level'] != null) {
      validatedData['level'] = (validatedData['level'] as int).clamp(1, 50);
    }

    // Garantir que experience é não-negativo
    if (validatedData['experience'] != null) {
      validatedData['experience'] = (validatedData['experience'] as int).clamp(0, 999999);
    }

    return validatedData;
  }
}

/// Extension para facilitar conversões de PetEntity
extension PetEntityIntegration on PetEntity {
  Map<String, dynamic> toIntegratedFormat() {
    return DataIntegrationHelper.regularPetToCollaborativeFormat(this);
  }

  bool isCompatibleWith(dynamic otherPet) {
    return DataIntegrationHelper.arePetsCompatible(this, otherPet);
  }

  bool get needsUrgentCare {
    return hunger < 20 || health < 30 || happiness < 25 || energy < 15;
  }

  String get careStatus {
    if (needsUrgentCare) return 'urgent';
    if (hunger < 40 || happiness < 40 || energy < 30) return 'attention';
    return 'good';
  }
}

/// Extension para facilitar conversões de CollaborativePetEntity
extension CollaborativePetEntityIntegration on CollaborativePetEntity {
  Map<String, dynamic> toIntegratedFormat() {
    return DataIntegrationHelper.collaborativePetToEnhancedFormat(this);
  }

  String get statusDisplay {
    return DataIntegrationHelper.getCollaborationStatusDisplay(status);
  }

  String get statusColor {
    return DataIntegrationHelper.getCollaborationStatusColor(status);
  }

  String get timeAgo {
    return DataIntegrationHelper.formatTimeAgo(matchedAt); // Usar matchedAt
  }

  bool get canReveal {
    return status == CollaborationStatus.revealAvailable;
  }

  bool get isActive {
    return status == CollaborationStatus.activeCollaboration;
  }
}
