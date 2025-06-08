// File: lib/presentation/providers/enhanced_pet_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/types/either.dart';
import 'package:petverse/domain/entities/pet_entity.dart';
import 'package:petverse/domain/usecases/pet/adopt_pet.dart';
import 'package:petverse/domain/usecases/pet/feed_pet.dart';
import 'package:petverse/domain/usecases/pet/play_with_pet.dart';
import 'package:petverse/domain/usecases/pet/rest_pet.dart';
import 'package:petverse/presentation/providers/auth_provider.dart';
import 'package:petverse/presentation/providers/dependencies_provider.dart';
import 'package:petverse/services/pet_stats_service.dart';
import 'package:petverse/services/pet_timer_service.dart';

/// Enhanced pet game state with multiple pets support
class EnhancedPetGameState {
  final List<PetEntity> userPets;
  final PetEntity? selectedPet;
  final List<PetEntity> availablePets;
  final LoadingState status;
  final String? errorMessage;
  final bool isTimerActive;

  const EnhancedPetGameState({
    this.userPets = const [],
    this.selectedPet,
    this.availablePets = const [],
    this.status = LoadingState.initial,
    this.errorMessage,
    this.isTimerActive = false,
  });

  EnhancedPetGameState copyWith({
    List<PetEntity>? userPets,
    PetEntity? selectedPet,
    bool clearSelectedPet = false,
    List<PetEntity>? availablePets,
    LoadingState? status,
    String? errorMessage,
    bool clearError = false,
    bool? isTimerActive,
  }) {
    return EnhancedPetGameState(
      userPets: userPets ?? this.userPets,
      selectedPet: clearSelectedPet ? null : selectedPet ?? this.selectedPet,
      availablePets: availablePets ?? this.availablePets,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isTimerActive: isTimerActive ?? this.isTimerActive,
    );
  }

  bool get isLoading => status == LoadingState.loading;
  bool get hasError => status == LoadingState.error;
  bool get isSuccess => status == LoadingState.success;
  bool get hasSelectedPet => selectedPet != null;
  bool get hasUserPets => userPets.isNotEmpty;

  // Get pet by ID
  PetEntity? getPetById(String petId) {
    try {
      return userPets.firstWhere((pet) => pet.id == petId);
    } catch (e) {
      return null;
    }
  }

  // Get pets needing care
  List<PetEntity> get petsNeedingCare {
    return userPets.where((pet) => PetStatsService.needsUrgentCare(pet)).toList();
  }
}

/// Enhanced pet game notifier with multiple pets and timer support
class EnhancedPetGameNotifier extends StateNotifier<EnhancedPetGameState> {
  final AdoptPet _adoptPet;
  final FeedPet _feedPet;
  final PlayWithPet _playWithPet;
  final RestPet _restPet;
  final Ref _ref;

  EnhancedPetGameNotifier(
    this._adoptPet,
    this._feedPet,
    this._playWithPet,
    this._restPet,
    this._ref,
  ) : super(const EnhancedPetGameState()) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && next.firebaseUser != null) {
        _loadUserPets(next.firebaseUser!.uid);
      } else {
        _resetState();
      }
    });

    // Initialize if already authenticated
    final authState = _ref.read(authProvider);
    if (authState.isAuthenticated && authState.firebaseUser != null) {
      _loadUserPets(authState.firebaseUser!.uid);
    }
  }

  Future<void> _loadUserPets(String userId) async {
    state = state.copyWith(status: LoadingState.loading, clearError: true);

    final petRepository = _ref.read(petRepositoryProvider);
    final result = await petRepository.getUserPets(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: LoadingState.error,
          errorMessage: _getErrorMessage(failure),
        );
      },
      (pets) {
        final selectedPet = pets.isNotEmpty ? pets.first : null;

        state = state.copyWith(
          userPets: pets,
          selectedPet: selectedPet,
          status: LoadingState.success,
          clearError: true,
        );

        // Start pet timer if we have pets
        if (pets.isNotEmpty) {
          _startPetTimer();
        }
      },
    );
  }

  /// Start the pet decay timer
  void _startPetTimer() {
    if (state.userPets.isEmpty) return;

    print('🕐 Starting pet timer for ${state.userPets.length} pets');

    PetTimerService.instance.startPetDecay(
      pets: state.userPets,
      onPetsUpdated: _onPetsUpdatedByTimer,
    );

    state = state.copyWith(isTimerActive: true);
  }

  /// Handle pets updated by timer
  void _onPetsUpdatedByTimer(List<PetEntity> updatedPets) {
    print('⏰ Pets updated by timer');

    // Update selected pet if it was updated
    PetEntity? updatedSelectedPet = state.selectedPet;
    if (updatedSelectedPet != null) {
      try {
        updatedSelectedPet = updatedPets.firstWhere(
          (pet) => pet.id == updatedSelectedPet!.id,
        );
      } catch (e) {
        // Pet not found, keep current
      }
    }

    state = state.copyWith(
      userPets: updatedPets,
      selectedPet: updatedSelectedPet,
    );

    // Update pets in database
    _updatePetsInDatabase(updatedPets);
  }

  /// Update pets in database (batch)
  Future<void> _updatePetsInDatabase(List<PetEntity> pets) async {
    final authState = _ref.read(authProvider);
    if (!authState.isAuthenticated || authState.firebaseUser == null) return;

    final petRepository = _ref.read(petRepositoryProvider);
    final userId = authState.firebaseUser!.uid;

    // Update each pet (in real app, would batch this)
    for (final pet in pets) {
      await petRepository.updatePet(userId: userId, pet: pet);
    }
  }

  void _resetState() {
    PetTimerService.instance.stopPetDecay();
    state = const EnhancedPetGameState();
  }

  /// Select a pet from the user's pets
  void selectPet(PetEntity pet) {
    if (state.userPets.any((p) => p.id == pet.id)) {
      state = state.copyWith(selectedPet: pet);
      PetTimerService.instance.updatePet(pet);
      print('🎯 Selected pet: ${pet.name}');
    }
  }

  /// Load available pets for adoption
  Future<void> loadAvailablePets() async {
    final petRepository = _ref.read(petRepositoryProvider);
    final result = await petRepository.getAvailablePets();

    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: _getErrorMessage(failure),
        );
      },
      (pets) {
        state = state.copyWith(
          availablePets: pets,
          clearError: true,
        );
      },
    );
  }

  /// Adopt a new pet
  Future<PetInteractionResult> adoptPet(PetEntity petData) async {
    final authState = _ref.read(authProvider);
    if (!authState.isAuthenticated || authState.firebaseUser == null) {
      return PetInteractionResult(
        success: false,
        message: 'User not authenticated',
      );
    }

    final params = AdoptPetParams(
      userId: authState.firebaseUser!.uid,
      petData: petData,
    );

    final result = await _adoptPet(params);

    return result.fold(
      (failure) {
        return PetInteractionResult(
          success: false,
          message: _getErrorMessage(failure),
        );
      },
      (adoptedPet) {
        // Update local state
        final updatedUserPets = [...state.userPets, adoptedPet];
        final selectedPet = state.selectedPet ?? adoptedPet;

        state = state.copyWith(
          userPets: updatedUserPets,
          selectedPet: selectedPet,
        );

        // Remove from available pets
        final updatedAvailablePets = state.availablePets.where((p) => p.id != petData.id).toList();

        state = state.copyWith(availablePets: updatedAvailablePets);

        // Restart timer with new pets
        _startPetTimer();

        return PetInteractionResult(
          success: true,
          message: '${adoptedPet.name} adopted successfully!',
        );
      },
    );
  }

  /// Perform pet care action
  Future<PetInteractionResult> performPetAction(String petId, PetAction action) async {
    final authState = _ref.read(authProvider);
    if (!authState.isAuthenticated || authState.firebaseUser == null) {
      return PetInteractionResult(
        success: false,
        message: 'User not authenticated',
      );
    }

    final pet = state.getPetById(petId);
    if (pet == null) {
      return PetInteractionResult(
        success: false,
        message: 'Pet not found',
      );
    }

    late Future<Either<Failure, PetEntity>> actionFuture;
    late String successMessage;

    switch (action) {
      case PetAction.feeding:
        actionFuture = _feedPet(FeedPetParams(
          userId: authState.firebaseUser!.uid,
          petId: petId,
        ));
        successMessage = '${pet.name} enjoyed the meal! 🍖';
        break;
      case PetAction.playing:
        actionFuture = _playWithPet(PlayWithPetParams(
          userId: authState.firebaseUser!.uid,
          petId: petId,
        ));
        successMessage = '${pet.name} had fun playing! 🎾';
        break;
      case PetAction.sleeping:
        actionFuture = _restPet(RestPetParams(
          userId: authState.firebaseUser!.uid,
          petId: petId,
        ));
        successMessage = '${pet.name} feels well rested! 😴';
        break;
      case PetAction.idle:
        return PetInteractionResult(
          success: false,
          message: 'No action specified',
        );
    }

    final result = await actionFuture;

    return result.fold(
      (failure) {
        return PetInteractionResult(
          success: false,
          message: _getErrorMessage(failure),
        );
      },
      (updatedPet) {
        // Update local state
        final updatedUserPets =
            state.userPets.map((p) => p.id == updatedPet.id ? updatedPet : p).toList();

        // Update selected pet if it's the one we acted on
        final updatedSelectedPet =
            state.selectedPet?.id == updatedPet.id ? updatedPet : state.selectedPet;

        state = state.copyWith(
          userPets: updatedUserPets,
          selectedPet: updatedSelectedPet,
        );

        // Update timer
        PetTimerService.instance.updatePet(updatedPet);

        return PetInteractionResult(
          success: true,
          message: successMessage,
        );
      },
    );
  }

  /// Get pet mood
  PetMood getPetMood(String petId) {
    final pet = state.getPetById(petId);
    if (pet == null) return PetMood.sad;
    return PetStatsService.calculateMood(pet);
  }

  /// Get pet care priority
  String getPetCarePriority(String petId) {
    final pet = state.getPetById(petId);
    if (pet == null) return 'Unknown';
    return PetStatsService.getCarePriority(pet);
  }

  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case PetGameFailure:
      case DatabaseFailure:
        return failure.message;
      case NetworkFailure:
        return 'Please check your internet connection';
      default:
        return 'An unexpected error occurred';
    }
  }

  @override
  void dispose() {
    PetTimerService.instance.stopPetDecay();
    super.dispose();
  }
}

// /// Enhanced pet game provider
// final enhancedPetGameProvider =
//     StateNotifierProvider<EnhancedPetGameNotifier, EnhancedPetGameState>((ref) {
//   return EnhancedPetGameNotifier(
//     ref.read(adoptPetProvider),
//     ref.read(feedPetProvider),
//     ref.read(playWithPetProvider),
//     ref.read(restPetProvider),
//     ref,
//   );
// });

/// Pet interaction result class
class PetInteractionResult {
  final bool success;
  final String message;
  final PetEntity? updatedPet;

  PetInteractionResult({
    required this.success,
    required this.message,
    this.updatedPet,
  });
}
