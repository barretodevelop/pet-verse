// File: lib/presentation/providers/pet_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/app_config.dart';
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

/// Pet game state
class PetGameState {
  final List<PetEntity> userPets;
  final PetEntity? currentPet;
  final List<PetEntity> availablePets;
  final LoadingState status;
  final String? errorMessage;

  const PetGameState({
    this.userPets = const [],
    this.currentPet,
    this.availablePets = const [],
    this.status = LoadingState.initial,
    this.errorMessage,
  });

  PetGameState copyWith({
    List<PetEntity>? userPets,
    PetEntity? currentPet,
    bool clearCurrentPet = false,
    List<PetEntity>? availablePets,
    LoadingState? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PetGameState(
      userPets: userPets ?? this.userPets,
      currentPet: clearCurrentPet ? null : currentPet ?? this.currentPet,
      availablePets: availablePets ?? this.availablePets,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  bool get isLoading => status == LoadingState.loading;
  bool get hasError => status == LoadingState.error;
  bool get isSuccess => status == LoadingState.success;
  bool get hasCurrentPet => currentPet != null;
  bool get hasUserPets => userPets.isNotEmpty;
}

/// Pet game notifier
class PetGameNotifier extends StateNotifier<PetGameState> {
  final AdoptPet _adoptPet;
  final FeedPet _feedPet;
  final PlayWithPet _playWithPet;
  final RestPet _restPet;
  final Ref _ref;

  Timer? _petDecayTimer;

  PetGameNotifier(
    this._adoptPet,
    this._feedPet,
    this._playWithPet,
    this._restPet,
    this._ref,
  ) : super(const PetGameState()) {
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
        final currentPet = pets.isNotEmpty ? pets.first : null;

        state = state.copyWith(
          userPets: pets,
          currentPet: currentPet,
          status: LoadingState.success,
          clearError: true,
        );

        if (currentPet != null) {
          _startPetDecayTimer();
        }
      },
    );
  }

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

  void _startPetDecayTimer() {
    _petDecayTimer?.cancel();
    _petDecayTimer = Timer.periodic(
      const Duration(milliseconds: AppConfig.petDecayTimerInterval),
      (_) => _updatePetDecay(),
    );
  }

  Future<void> _updatePetDecay() async {
    if (state.currentPet == null) return;

    final authState = _ref.read(authProvider);
    if (!authState.isAuthenticated || authState.firebaseUser == null) return;

    final userId = authState.firebaseUser!.uid;
    final pet = state.currentPet!;
    final now = DateTime.now();

    bool needsUpdate = false;
    PetEntity updatedPet = pet;

    // Decay hunger
    if (now.difference(pet.lastFed).inMinutes >= 2) {
      updatedPet = updatedPet.copyWith(
        hunger: (pet.hunger - AppConfig.petHungerDecayRate).clamp(0, 100),
        lastFed: now,
      );
      needsUpdate = true;
    }

    // Decay happiness
    if (now.difference(pet.lastPlayed).inMinutes >= 3) {
      updatedPet = updatedPet.copyWith(
        happiness: (pet.happiness - AppConfig.petHappinessDecayRate).clamp(0, 100),
        lastPlayed: now,
      );
      needsUpdate = true;
    }

    // Decay energy
    if (now.difference(pet.lastSlept).inMinutes >= 5 && pet.energy > 0) {
      updatedPet = updatedPet.copyWith(
        energy: (pet.energy - AppConfig.petEnergyDecayRate).clamp(0, 100),
      );
      needsUpdate = true;
    }

    if (needsUpdate) {
      final petRepository = _ref.read(petRepositoryProvider);
      await petRepository.updatePet(userId: userId, pet: updatedPet);

      // Update local state
      final updatedUserPets =
          state.userPets.map((p) => p.id == updatedPet.id ? updatedPet : p).toList();

      state = state.copyWith(
        userPets: updatedUserPets,
        currentPet: updatedPet,
      );
    }
  }

  void _resetState() {
    _petDecayTimer?.cancel();
    state = const PetGameState();
  }

  void setCurrentPet(PetEntity? pet) {
    state = state.copyWith(
      currentPet: pet,
      clearCurrentPet: pet == null,
    );
  }

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
        final currentPet = state.currentPet ?? adoptedPet;

        state = state.copyWith(
          userPets: updatedUserPets,
          currentPet: currentPet,
        );

        // Remove from available pets
        final updatedAvailablePets = state.availablePets.where((p) => p.id != petData.id).toList();

        state = state.copyWith(availablePets: updatedAvailablePets);

        if (state.currentPet != null) {
          _startPetDecayTimer();
        }

        return PetInteractionResult(
          success: true,
          message: '${adoptedPet.name} adopted successfully!',
        );
      },
    );
  }

  Future<PetInteractionResult> feedCurrentPet() async {
    return _performPetAction(
      (userId, petId) => _feedPet(FeedPetParams(userId: userId, petId: petId)),
      'Pet fed successfully!',
    );
  }

  Future<PetInteractionResult> playWithCurrentPet() async {
    return _performPetAction(
      (userId, petId) => _playWithPet(PlayWithPetParams(userId: userId, petId: petId)),
      'Pet enjoyed playing!',
    );
  }

  Future<PetInteractionResult> restCurrentPet() async {
    return _performPetAction(
      (userId, petId) => _restPet(RestPetParams(userId: userId, petId: petId)),
      'Pet is well rested!',
    );
  }

  Future<PetInteractionResult> _performPetAction(
    Future<Either<Failure, PetEntity>> Function(String, String) action,
    String successMessage,
  ) async {
    final authState = _ref.read(authProvider);
    if (!authState.isAuthenticated || authState.firebaseUser == null) {
      return PetInteractionResult(
        success: false,
        message: 'User not authenticated',
      );
    }

    if (state.currentPet == null) {
      return PetInteractionResult(
        success: false,
        message: 'No pet selected',
      );
    }

    final result = await action(authState.firebaseUser!.uid, state.currentPet!.id);

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

        state = state.copyWith(
          userPets: updatedUserPets,
          currentPet: updatedPet,
        );

        return PetInteractionResult(
          success: true,
          message: successMessage,
        );
      },
    );
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
    _petDecayTimer?.cancel();
    super.dispose();
  }
}

/// Pet game provider
final petGameProvider = StateNotifierProvider<PetGameNotifier, PetGameState>((ref) {
  return PetGameNotifier(
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

  PetInteractionResult({
    required this.success,
    required this.message,
  });
}
