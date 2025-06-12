// File: lib/services/pet_timer_service.dart

import 'dart:async';

import 'package:petverse/core/config/app_config.dart';
import 'package:petverse/core/utils/helpers.dart';
import 'package:petverse/domain/entities/pet_entity.dart';

/// Service for managing pet decay timers and automatic stat updates
class PetTimerService {
  static PetTimerService? _instance;
  static PetTimerService get instance => _instance ??= PetTimerService._();
  PetTimerService._();

  Timer? _decayTimer;
  final Map<String, PetEntity> _activePets = {};
  Function(List<PetEntity>)? _onPetsUpdated;

  /// Start the pet decay system for multiple pets
  void startPetDecay({
    required List<PetEntity> pets,
    required Function(List<PetEntity>) onPetsUpdated,
  }) {
    print('🕐 Starting pet decay timer for ${pets.length} pets');

    _onPetsUpdated = onPetsUpdated;
    _activePets.clear();

    // Store pets by ID
    for (final pet in pets) {
      _activePets[pet.id] = pet;
    }

    // Cancel existing timer
    _decayTimer?.cancel();

    // Start new decay timer (every minute)
    _decayTimer = Timer.periodic(
      const Duration(milliseconds: AppConfig.petDecayTimerInterval),
      (_) => _performDecayCycle(),
    );

    print('✅ Pet decay timer started');
  }

  /// Stop the pet decay timer
  void stopPetDecay() {
    print('🛑 Stopping pet decay timer');
    _decayTimer?.cancel();
    _decayTimer = null;
    _activePets.clear();
    _onPetsUpdated = null;
  }

  /// Update a specific pet in the timer
  void updatePet(PetEntity pet) {
    if (_activePets.containsKey(pet.id)) {
      _activePets[pet.id] = pet;
      print('🔄 Updated pet ${pet.name} in timer');
    }
  }

  /// Perform decay cycle for all active pets
  void _performDecayCycle() {
    if (_activePets.isEmpty || _onPetsUpdated == null) return;

    print('⏰ Performing decay cycle for ${_activePets.length} pets');
    final updatedPets = <PetEntity>[];
    bool anyPetChanged = false;

    for (final pet in _activePets.values) {
      final updatedPet = _decayPetStats(pet);
      updatedPets.add(updatedPet);

      if (updatedPet != pet) {
        anyPetChanged = true;
        _activePets[updatedPet.id] = updatedPet;
      }
    }

    // Notify listeners if any pet changed
    if (anyPetChanged) {
      print('📢 Notifying pet updates');
      _onPetsUpdated!(updatedPets);
    }
  }

  /// Apply decay to individual pet stats
  PetEntity _decayPetStats(PetEntity pet) {
    final now = DateTime.now();

    // Calculate time since last updates (in minutes)
    final minutesSinceLastFed = now.difference(pet.lastFed).inMinutes;
    final minutesSinceLastPlayed = now.difference(pet.lastPlayed).inMinutes;
    final minutesSinceLastSlept = now.difference(pet.lastSlept).inMinutes;

    int newHunger = pet.hunger;
    int newHappiness = pet.happiness;
    int newEnergy = pet.energy;
    bool needsUpdate = false;

    // Hunger decay (every 2 minutes)
    if (minutesSinceLastFed >= 2) {
      newHunger = Helpers.clamp(
        pet.hunger - AppConfig.petHungerDecayRate,
        0,
        100,
      );
      needsUpdate = true;
    }

    // Happiness decay (every 3 minutes)
    if (minutesSinceLastPlayed >= 3) {
      newHappiness = Helpers.clamp(
        pet.happiness - AppConfig.petHappinessDecayRate,
        0,
        100,
      );
      needsUpdate = true;
    }

    // Energy decay (every 5 minutes)
    if (minutesSinceLastSlept >= 5) {
      newEnergy = Helpers.clamp(
        pet.energy - AppConfig.petEnergyDecayRate,
        0,
        100,
      );
      needsUpdate = true;
    }

    if (needsUpdate) {
      print('📉 Pet ${pet.name} stats decayed: H:$newHunger Ha:$newHappiness E:$newEnergy');

      return pet.copyWith(
        hunger: newHunger,
        happiness: newHappiness,
        energy: newEnergy,
      );
    }

    return pet;
  }

  /// Get current pets state
  List<PetEntity> get currentPets => _activePets.values.toList();

  /// Check if timer is running
  bool get isActive => _decayTimer?.isActive ?? false;
}
