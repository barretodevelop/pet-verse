// File: lib/services/pet_stats_service.dart

import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/domain/entities/pet_entity.dart';

/// Service for calculating pet stats, moods, and health
class PetStatsService {
  /// Calculate pet's current mood based on all stats
  static PetMood calculateMood(PetEntity pet) {
    final avgStats = (pet.hunger + pet.happiness + pet.energy) / 3;

    if (pet.hunger < 20) return PetMood.hungry;
    if (pet.energy < 20) return PetMood.tired;
    if (avgStats >= 80) return PetMood.happy;
    if (avgStats >= 60) return PetMood.playful;
    if (avgStats >= 40) return PetMood.sad;
    return PetMood.sleepy;
  }

  /// Get mood emoji for display
  static String getMoodEmoji(PetMood mood) {
    switch (mood) {
      case PetMood.happy:
        return '😊';
      case PetMood.sad:
        return '😢';
      case PetMood.excited:
        return '🤩';
      case PetMood.tired:
        return '😴';
      case PetMood.hungry:
        return '😋';
      case PetMood.playful:
        return '😄';
      case PetMood.sleepy:
        return '😪';
    }
  }

  /// Get mood description
  static String getMoodDescription(PetMood mood) {
    switch (mood) {
      case PetMood.happy:
        return 'Very Happy';
      case PetMood.sad:
        return 'Sad';
      case PetMood.excited:
        return 'Excited';
      case PetMood.tired:
        return 'Tired';
      case PetMood.hungry:
        return 'Hungry';
      case PetMood.playful:
        return 'Playful';
      case PetMood.sleepy:
        return 'Sleepy';
    }
  }

  /// Calculate overall health percentage
  static double calculateOverallHealth(PetEntity pet) {
    return (pet.hunger + pet.happiness + pet.energy) / 3;
  }

  /// Check if pet needs urgent care
  static bool needsUrgentCare(PetEntity pet) {
    return pet.hunger < 20 || pet.happiness < 20 || pet.energy < 10;
  }

  /// Get care priority (what pet needs most)
  static String getCarePriority(PetEntity pet) {
    if (pet.hunger < 30) return 'Feed';
    if (pet.energy < 30) return 'Rest';
    if (pet.happiness < 30) return 'Play';
    return 'Good';
  }

  /// Calculate XP gain based on action and pet state
  static int calculateXpGain(PetEntity pet, PetAction action) {
    int baseXp = 0;

    switch (action) {
      case PetAction.feeding:
        baseXp = 10;
        // Bonus XP if pet was very hungry
        if (pet.hunger < 30) baseXp += 5;
        break;
      case PetAction.playing:
        baseXp = 15;
        // Bonus XP if pet was sad
        if (pet.happiness < 30) baseXp += 5;
        break;
      case PetAction.sleeping:
        baseXp = 5;
        // Bonus XP if pet was very tired
        if (pet.energy < 30) baseXp += 3;
        break;
      case PetAction.idle:
        baseXp = 0;
        break;
    }

    // Level multiplier
    baseXp = (baseXp * (1 + pet.level * 0.1)).round();

    return baseXp;
  }

  /// Check if pet should evolve
  static bool shouldEvolve(PetEntity pet) {
    // Evolution criteria: level 5, 10, 20, etc.
    final evolutionLevels = [5, 10, 20, 35, 50];
    return evolutionLevels.contains(pet.level) &&
        pet.evolutionStage < evolutionLevels.indexOf(pet.level) + 2;
  }

  /// Calculate next evolution stage
  static EvolutionStage getNextEvolutionStage(PetEntity pet) {
    if (pet.level >= 50) return EvolutionStage.elder;
    if (pet.level >= 35) return EvolutionStage.adult;
    if (pet.level >= 20) return EvolutionStage.teenager;
    if (pet.level >= 10) return EvolutionStage.child;
    return EvolutionStage.baby;
  }

  /// Get evolution stage name
  static String getEvolutionStageName(EvolutionStage stage) {
    switch (stage) {
      case EvolutionStage.baby:
        return 'Baby';
      case EvolutionStage.child:
        return 'Child';
      case EvolutionStage.teenager:
        return 'Teen';
      case EvolutionStage.adult:
        return 'Adult';
      case EvolutionStage.elder:
        return 'Elder';
    }
  }
}
