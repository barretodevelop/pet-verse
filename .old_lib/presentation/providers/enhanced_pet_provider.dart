// File: lib/presentation/providers/enhanced_pet_provider.dart
// Enhanced Pet Provider - Implementação completa com métodos em falta

import 'dart:async';

import 'package:flutter/foundation.dart';
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
import 'package:petverse/presentation/providers/dependencies_provider.dart' hide kDebugMode;
import 'package:petverse/services/pet_stats_service.dart';

/// Enhanced pet game state with multiple pets support
class EnhancedPetGameState {
  final List<PetEntity> userPets;
  final PetEntity? selectedPet;
  final List<PetEntity> availablePets;
  final LoadingState status;
  final String? errorMessage;
  final String? successMessage;
  final bool isTimerActive;
  final bool isPerformingAction;

  const EnhancedPetGameState({
    this.userPets = const [],
    this.selectedPet,
    this.availablePets = const [],
    this.status = LoadingState.initial,
    this.errorMessage,
    this.successMessage,
    this.isTimerActive = false,
    this.isPerformingAction = false,
  });

  EnhancedPetGameState copyWith({
    List<PetEntity>? userPets,
    PetEntity? selectedPet,
    bool clearSelectedPet = false,
    List<PetEntity>? availablePets,
    LoadingState? status,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool? isTimerActive,
    bool? isPerformingAction,
  }) {
    return EnhancedPetGameState(
      userPets: userPets ?? this.userPets,
      selectedPet: clearSelectedPet ? null : (selectedPet ?? this.selectedPet),
      availablePets: availablePets ?? this.availablePets,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      isTimerActive: isTimerActive ?? this.isTimerActive,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
    );
  }

  bool get isLoading => status == LoadingState.loading;
  bool get hasError => status == LoadingState.error && errorMessage != null;
  bool get hasSuccess => successMessage != null;
  bool get isSuccess => status == LoadingState.success;
  bool get hasSelectedPet => selectedPet != null;
  bool get hasUserPets => userPets.isNotEmpty;

  /// Get pet by ID
  PetEntity? getPetById(String petId) {
    try {
      return userPets.firstWhere((pet) => pet.id == petId);
    } catch (e) {
      return null;
    }
  }

  /// Get pets needing care
  List<PetEntity> get petsNeedingCare {
    return userPets.where((pet) => PetStatsService.needsUrgentCare(pet)).toList();
  }

  /// Get pets by mood
  List<PetEntity> getPetsByMood(PetMood mood) {
    return userPets.where((pet) => PetStatsService.calculateMood(pet) == mood).toList();
  }
}

/// Enhanced pet game notifier with complete implementation
class EnhancedPetGameNotifier extends StateNotifier<EnhancedPetGameState> {
  final AdoptPet _adoptPet;
  final FeedPet _feedPet;
  final PlayWithPet _playWithPet;
  final RestPet _restPet;
  final Ref _ref;
  Timer? _petDecayTimer;

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
        loadUserPets(next.firebaseUser!.uid);
      } else {
        _resetState();
      }
    });

    // Initialize if already authenticated
    final authState = _ref.read(authProvider);
    if (authState.isAuthenticated && authState.firebaseUser != null) {
      loadUserPets(authState.firebaseUser!.uid);
    }
  }

  /// Load user pets from repository
  Future<void> loadUserPets(String userId) async {
    if (state.isLoading) return;

    state = state.copyWith(status: LoadingState.loading, clearError: true, clearSuccess: true);

    try {
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
          final selectedPet =
              pets.isNotEmpty && state.selectedPet == null ? pets.first : state.selectedPet;

          state = state.copyWith(
            userPets: pets,
            selectedPet: selectedPet,
            status: LoadingState.success,
            clearError: true,
          );

          _startPetTimer();

          if (kDebugMode) {
            print('🐾 Loaded ${pets.length} pets for user: $userId');
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: LoadingState.error,
        errorMessage: 'Failed to load pets: $e',
      );
    }
  }

  /// Start pet decay timer
  void _startPetTimer() {
    _stopPetTimer();

    _petDecayTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _handlePetDecay();
    });

    state = state.copyWith(isTimerActive: true);
  }

  /// Stop pet decay timer
  void _stopPetTimer() {
    _petDecayTimer?.cancel();
    _petDecayTimer = null;
    state = state.copyWith(isTimerActive: false);
  }

  /// Handle pet stats decay over time
  void _handlePetDecay() {
    if (state.userPets.isEmpty) return;

    final updatedPets = state.userPets.map((pet) {
      return PetStatsService.applyTimeDecay(pet);
    }).toList();

    // Update selected pet if it's in the list
    // PetEntity? updatedSelectedPet = state.selectedPet;
    // if (updatedSelectedPet != null) {
    //   try {
    //     updatedSelectedPet = updatedPets.firstWhere(
    //       (pet) => pet.id == updatedSelectedPet!.id,
    //     ) as PetEntity?;
    //   } catch (e) {
    //     // Pet not found, keep current
    //   }
    // }

    // state = state.copyWith(
    //   userPets: updatedPets,
    //   selectedPet: updatedSelectedPet,
    // );

    // // Update pets in database
    // _updatePetsInDatabase(updatedPets);
  }

  /// Update pets in database (batch operation)
  Future<void> _updatePetsInDatabase(List<PetEntity> pets) async {
    final authState = _ref.read(authProvider);
    if (!authState.isAuthenticated || authState.firebaseUser == null) return;

    try {
      final petRepository = _ref.read(petRepositoryProvider);
      final userId = authState.firebaseUser!.uid;

      // In production, this would be a batch operation
      for (final pet in pets) {
        await petRepository.updatePet(userId: userId, pet: pet);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to update pets in database: $e');
      }
    }
  }

  /// Reset state and cleanup
  void _resetState() {
    _stopPetTimer();
    state = const EnhancedPetGameState();
  }

  /// Select a pet from the user's pets
  void selectPet(PetEntity pet) {
    if (state.userPets.any((p) => p.id == pet.id)) {
      state = state.copyWith(selectedPet: pet, clearSuccess: true);

      if (kDebugMode) {
        print('🎯 Selected pet: ${pet.name}');
      }
    }
  }

  /// Clear selected pet
  void clearSelectedPet() {
    state = state.copyWith(clearSelectedPet: true);
  }

  /// Load available pets for adoption
  Future<void> loadAvailablePets() async {
    try {
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
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load available pets: $e',
      );
    }
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

    state = state.copyWith(isPerformingAction: true, clearError: true);

    try {
      final params = AdoptPetParams(
        userId: authState.firebaseUser!.uid,
        petData: petData,
      );

      final result = await _adoptPet(params);

      return result.fold(
        (failure) {
          state = state.copyWith(
            isPerformingAction: false,
            errorMessage: _getErrorMessage(failure),
          );
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
            isPerformingAction: false,
            successMessage: '${adoptedPet.name} adopted successfully! 🎉',
          );

          // Remove from available pets
          final updatedAvailablePets =
              state.availablePets.where((p) => p.id != petData.id).toList();

          state = state.copyWith(availablePets: updatedAvailablePets);

          // Restart timer with new pets
          _startPetTimer();

          return PetInteractionResult(
            success: true,
            message: '${adoptedPet.name} adopted successfully! 🎉',
            updatedPet: adoptedPet,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isPerformingAction: false,
        errorMessage: 'Failed to adopt pet: $e',
      );
      return PetInteractionResult(
        success: false,
        message: 'Failed to adopt pet: $e',
      );
    }
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

    state = state.copyWith(isPerformingAction: true, clearError: true);

    try {
      late Future<Either<Failure, PetEntity>> actionFuture;
      late String successMessage;

      switch (action) {
        case PetAction.feeding:
          actionFuture = _feedPet(FeedPetParams(
            userId: authState.firebaseUser!.uid,
            petId: petId,
          ));
          successMessage = '🍖 ${pet.name} enjoyed the meal!';
          break;
        case PetAction.playing:
          actionFuture = _playWithPet(PlayWithPetParams(
            userId: authState.firebaseUser!.uid,
            petId: petId,
          ));
          successMessage = '🎾 ${pet.name} had fun playing!';
          break;
        case PetAction.sleeping:
          actionFuture = _restPet(RestPetParams(
            userId: authState.firebaseUser!.uid,
            petId: petId,
          ));
          successMessage = '😴 ${pet.name} feels well rested!';
          break;
        case PetAction.idle:
          state = state.copyWith(isPerformingAction: false);
          return PetInteractionResult(
            success: false,
            message: 'No action specified',
          );
      }

      final result = await actionFuture;

      return result.fold(
        (failure) {
          state = state.copyWith(
            isPerformingAction: false,
            errorMessage: _getErrorMessage(failure),
          );
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
            isPerformingAction: false,
            successMessage: successMessage,
          );

          return PetInteractionResult(
            success: true,
            message: successMessage,
            updatedPet: updatedPet,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isPerformingAction: false,
        errorMessage: 'Failed to perform action: $e',
      );
      return PetInteractionResult(
        success: false,
        message: 'Failed to perform action: $e',
      );
    }
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

  /// Clear messages
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  /// Force refresh pets
  Future<void> refreshPets() async {
    final authState = _ref.read(authProvider);
    if (authState.isAuthenticated && authState.firebaseUser != null) {
      await loadUserPets(authState.firebaseUser!.uid);
    }
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
    _stopPetTimer();
    super.dispose();
  }
}

/// Enhanced pet game provider
final enhancedPetGameProvider =
    StateNotifierProvider<EnhancedPetGameNotifier, EnhancedPetGameState>((ref) {
  return EnhancedPetGameNotifier(
    ref.read(adoptPetProvider),
    ref.read(feedPetProvider),
    ref.read(playWithPetProvider),
    ref.read(restPetProvider),
    ref,
  );
});

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
