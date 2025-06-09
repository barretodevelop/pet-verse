// File: lib/presentation/providers/collaborative_pet_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_action_entity.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';
import 'package:petverse/domain/entities/collaboration/user_collaboration_data_entity.dart';
import 'package:petverse/domain/repositories/collaborative_pet_repository.dart';
import 'package:petverse/domain/usecases/collaboration/check_collaboration_match.dart';
import 'package:petverse/domain/usecases/collaboration/get_available_collaborative_pets.dart';
import 'package:petverse/domain/usecases/collaboration/process_reveal_request.dart';
import 'package:petverse/domain/usecases/collaboration/request_collaborative_adoption.dart';
import 'package:petverse/domain/usecases/collaboration/sync_collaborative_action.dart';
import 'package:petverse/domain/usecases/usecase.dart';
import 'package:petverse/presentation/providers/dependencies_provider.dart';

/// Estado da colaboração
class CollaborativePetState {
  final List<CollaborativePetEntity> availablePets;
  final List<CollaborativePetEntity> userPets;
  final CollaborativePetEntity? selectedPet;
  final UserCollaborationDataEntity? userCollaborationData;
  final List<CollaborativeActionEntity> recentActions;
  final bool isLoading;
  final String? errorMessage;
  final bool isPerformingAction;
  final String? successMessage;

  const CollaborativePetState({
    this.availablePets = const [],
    this.userPets = const [],
    this.selectedPet,
    this.userCollaborationData,
    this.recentActions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isPerformingAction = false,
    this.successMessage,
  });

  bool get hasError => errorMessage != null;
  bool get hasSuccess => successMessage != null;
  bool get hasSelectedPet => selectedPet != null;
  bool get hasAvailableSlots => userCollaborationData?.hasAvailableSlots ?? false;
  int get availableSlots => userCollaborationData?.availableSlots ?? 0;
  int get maxSlots => userCollaborationData?.maxCollaborativeSlots ?? 3;

  CollaborativePetState copyWith({
    List<CollaborativePetEntity>? availablePets,
    List<CollaborativePetEntity>? userPets,
    CollaborativePetEntity? selectedPet,
    UserCollaborationDataEntity? userCollaborationData,
    List<CollaborativeActionEntity>? recentActions,
    bool? isLoading,
    String? errorMessage,
    bool? isPerformingAction,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelectedPet = false,
  }) {
    return CollaborativePetState(
      availablePets: availablePets ?? this.availablePets,
      userPets: userPets ?? this.userPets,
      selectedPet: clearSelectedPet ? null : (selectedPet ?? this.selectedPet),
      userCollaborationData: userCollaborationData ?? this.userCollaborationData,
      recentActions: recentActions ?? this.recentActions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// Provider do estado colaborativo
class CollaborativePetNotifier extends StateNotifier<CollaborativePetState> {
  final CollaborativePetRepository _repository;
  final RequestCollaborativeAdoption _requestAdoption;
  final SyncCollaborativeAction _syncAction;
  final ProcessRevealRequest _processReveal;
  final GetAvailableCollaborativePets _getAvailablePets;
  final CheckCollaborationMatch _checkMatch;

  CollaborativePetNotifier(
    this._repository,
    this._requestAdoption,
    this._syncAction,
    this._processReveal,
    this._getAvailablePets,
    this._checkMatch,
  ) : super(const CollaborativePetState());

  /// Carregar dados iniciais
  Future<void> initialize(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Carregar dados do usuário
      await loadUserCollaborationData(userId);

      // Carregar pets disponíveis
      await loadAvailableCollaborativePets();

      // Carregar pets do usuário
      await loadUserCollaborativePets(userId);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar dados de colaboração: $e',
      );
    }
  }

  /// Carregar pets disponíveis para adoção colaborativa
  Future<void> loadAvailableCollaborativePets() async {
    final result = await _getAvailablePets(NoParams());

    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
      ),
      (pets) => state = state.copyWith(
        availablePets: pets,
      ),
    );
  }

  /// Carregar pets colaborativos do usuário
  Future<void> loadUserCollaborativePets(String userId) async {
    final result = await _repository.getUserCollaborativePets(userId);

    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
      ),
      (pets) => state = state.copyWith(
        userPets: pets,
      ),
    );
  }

  /// Carregar dados de colaboração do usuário
  Future<void> loadUserCollaborationData(String userId) async {
    final result = await _repository.getUserCollaborationData(userId);

    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
      ),
      (data) => state = state.copyWith(
        userCollaborationData: data,
      ),
    );
  }

  /// Solicitar adoção colaborativa
  Future<void> requestCollaborativeAdoption(String userId, String petId) async {
    if (!state.hasAvailableSlots) {
      state = state.copyWith(
        errorMessage: 'Você não tem slots disponíveis para adoção colaborativa',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _requestAdoption(
      RequestCollaborativeAdoptionParams(userId: userId, petId: petId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (result) async {
        state = state.copyWith(
          isLoading: false,
          successMessage: result.message,
        );

        // Recarregar dados
        await loadUserCollaborativePets(userId);
        await loadAvailableCollaborativePets();

        // Verificar se houve match
        await checkMatch(petId, userId);
      },
    );
  }

  /// Verificar match de colaboração
  Future<void> checkMatch(String petId, String userId) async {
    final result = await _checkMatch(
      CheckMatchParams(petId: petId, userId: userId),
    );

    result.fold(
      (failure) => {}, // Ignorar erro de match
      (matchResult) {
        if (matchResult.hasMatch) {
          state = state.copyWith(
            successMessage: matchResult.message,
          );
        }
      },
    );
  }

  /// Realizar ação colaborativa
  Future<void> performCollaborativeAction(
    String userId,
    String petId,
    CollaborativeActionType actionType,
  ) async {
    state = state.copyWith(isPerformingAction: true, clearError: true);

    final result = await _syncAction(
      SyncActionParams(
        userId: userId,
        petId: petId,
        actionType: actionType,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isPerformingAction: false,
        errorMessage: failure.message,
      ),
      (actionResult) async {
        state = state.copyWith(
          isPerformingAction: false,
          successMessage: actionResult.message,
        );

        // Recarregar pet selecionado
        if (state.selectedPet?.id == petId) {
          await selectPet(petId);
        }

        // Recarregar ações recentes
        await loadPetActions(petId);

        // Verificar se pode fazer reveal
        if (actionResult.canRevealNow) {
          state = state.copyWith(
            successMessage: '🎉 Pet atingiu o nível para reveal! Você pode conhecer seu parceiro!',
          );
        }
      },
    );
  }

  /// Selecionar pet colaborativo
  Future<void> selectPet(String petId) async {
    final result = await _repository.getCollaborativePet(petId);

    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
      ),
      (pet) {
        if (pet != null) {
          state = state.copyWith(selectedPet: pet);
          loadPetActions(petId);
        }
      },
    );
  }

  /// Carregar ações do pet
  Future<void> loadPetActions(String petId) async {
    final result = await _repository.getPetActions(petId, limit: 10);

    result.fold(
      (failure) => {}, // Ignorar erro de ações
      (actions) => state = state.copyWith(recentActions: actions),
    );
  }

  /// Solicitar reveal
  Future<void> requestReveal(String userId, String petId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _processReveal(
      ProcessRevealParams(userId: userId, petId: petId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (revealResult) => state = state.copyWith(
        isLoading: false,
        successMessage: revealResult.message,
      ),
    );
  }

  /// Limpar mensagens
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  /// Limpar pet selecionado
  void clearSelectedPet() {
    state = state.copyWith(clearSelectedPet: true);
  }

  /// Assistir atualizações em tempo real do pet
  void watchPetUpdates(String petId) {
    _repository.watchPetUpdates(petId).listen(
      (updatedPet) {
        if (state.selectedPet?.id == petId) {
          state = state.copyWith(selectedPet: updatedPet);
        }

        // Atualizar na lista de pets do usuário
        final updatedUserPets = state.userPets.map((pet) {
          return pet.id == petId ? updatedPet : pet;
        }).toList();

        state = state.copyWith(userPets: updatedUserPets);
      },
      onError: (error) {
        // Log error but don't show to user
      },
    );
  }

  /// Assistir ações em tempo real
  void watchPetActions(String petId) {
    _repository.watchPetActions(petId).listen(
      (newAction) {
        final updatedActions = [newAction, ...state.recentActions];
        state = state.copyWith(
          recentActions: updatedActions.take(10).toList(),
        );
      },
      onError: (error) {
        // Log error but don't show to user
      },
    );
  }
}

/// Provider principal do sistema colaborativo
final collaborativePetProvider =
    StateNotifierProvider<CollaborativePetNotifier, CollaborativePetState>((ref) {
  final repository = ref.watch(collaborativePetRepositoryProvider);

  return CollaborativePetNotifier(
    repository,
    RequestCollaborativeAdoption(repository),
    SyncCollaborativeAction(repository),
    ProcessRevealRequest(repository),
    GetAvailableCollaborativePets(repository),
    CheckCollaborationMatch(repository),
  );
});
