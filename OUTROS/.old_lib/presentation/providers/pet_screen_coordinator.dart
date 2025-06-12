// File: lib/presentation/providers/pet_screen_coordinator.dart
// Provider coordenador para sincronizar todos os providers da pet screen

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/presentation/providers/auth_provider.dart';
import 'package:petverse/presentation/providers/collaboration_slots_provider.dart';
import 'package:petverse/presentation/providers/collaborative_pet_provider.dart';
import 'package:petverse/presentation/providers/enhanced_pet_provider.dart';

/// Estado coordenado da pet screen
class PetScreenCoordinatedState {
  final bool isInitialized;
  final bool isLoading;
  final String? errorMessage;
  final bool hasAnyPets;
  final int totalPets;
  final int availableSlots;
  final bool needsAttention;

  const PetScreenCoordinatedState({
    this.isInitialized = false,
    this.isLoading = false,
    this.errorMessage,
    this.hasAnyPets = false,
    this.totalPets = 0,
    this.availableSlots = 0,
    this.needsAttention = false,
  });

  PetScreenCoordinatedState copyWith({
    bool? isInitialized,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? hasAnyPets,
    int? totalPets,
    int? availableSlots,
    bool? needsAttention,
  }) {
    return PetScreenCoordinatedState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      hasAnyPets: hasAnyPets ?? this.hasAnyPets,
      totalPets: totalPets ?? this.totalPets,
      availableSlots: availableSlots ?? this.availableSlots,
      needsAttention: needsAttention ?? this.needsAttention,
    );
  }
}

/// Coordenador que sincroniza todos os providers da pet screen
class PetScreenCoordinator extends StateNotifier<PetScreenCoordinatedState> {
  final StateNotifierProviderRef<PetScreenCoordinator, PetScreenCoordinatedState> _ref;

  PetScreenCoordinator(this._ref) : super(const PetScreenCoordinatedState());

  /// Inicializa todos os providers necessários
  Future<void> initializeScreen() async {
    if (state.isInitialized) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Verificar se usuário está autenticado
      final authState = _ref.read(authProvider);
      final userId = authState.firebaseUser?.uid;

      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Usuário não autenticado',
        );
        return;
      }

      // Inicializar providers em paralelo
      await Future.wait([
        _initializeEnhancedPetProvider(userId),
        _initializeCollaborativePetProvider(userId),
      ]);

      // Sincronizar slots após carregar pets
      _syncSlotsWithPets();

      // Atualizar estado final
      _updateCoordinatedState();

      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao inicializar: $e',
      );
    }
  }

  /// Recarrega todos os dados
  Future<void> refreshAllData() async {
    final authState = _ref.read(authProvider);
    final userId = authState.firebaseUser?.uid;

    if (userId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await Future.wait([
        _ref.read(enhancedPetGameProvider.notifier).loadUserPets(userId),
        _ref.read(collaborativePetProvider.notifier).initialize(userId),
      ]);

      _syncSlotsWithPets();
      _updateCoordinatedState();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao recarregar: $e',
      );
    }
  }

  /// Sincroniza os slots com os pets carregados
  void _syncSlotsWithPets() {
    final collaborativeState = _ref.read(collaborativePetProvider);
    _ref.read(collaborationSlotsProvider.notifier).syncWithUserPets(collaborativeState.userPets);
  }

  /// Atualiza o estado coordenado baseado nos outros providers
  void _updateCoordinatedState() {
    final enhancedState = _ref.read(enhancedPetGameProvider);
    final collaborativeState = _ref.read(collaborativePetProvider);
    final slotsState = _ref.read(collaborationSlotsProvider);

    final totalPets = enhancedState.userPets.length + collaborativeState.userPets.length;
    final hasAnyPets = totalPets > 0;

    // Verificar se algum pet precisa de atenção
    final needsAttention = _checkIfAnyPetNeedsAttention(
      enhancedState.userPets,
      collaborativeState.userPets,
    );

    state = state.copyWith(
      hasAnyPets: hasAnyPets,
      totalPets: totalPets,
      availableSlots: slotsState.availableSlots,
      needsAttention: needsAttention,
    );
  }

  /// Verifica se algum pet precisa de atenção
  bool _checkIfAnyPetNeedsAttention(List<dynamic> regularPets, List<dynamic> collaborativePets) {
    // TODO: Implementar lógica de verificação de stats dos pets
    // Para pets regulares: verificar hunger, happiness, energy, health
    // Para pets colaborativos: verificar status da colaboração
    return false; // Placeholder
  }

  /// Inicializa o provider de pets regulares
  Future<void> _initializeEnhancedPetProvider(String userId) async {
    await _ref.read(enhancedPetGameProvider.notifier).loadUserPets(userId);
  }

  /// Inicializa o provider de pets colaborativos
  Future<void> _initializeCollaborativePetProvider(String userId) async {
    await _ref.read(collaborativePetProvider.notifier).initialize(userId);
  }

  /// Cleanup quando não precisar mais do coordinator
  @override
  void dispose() {
    // Cleanup se necessário
  }
}

/// Provider do coordenador da pet screen
final petScreenCoordinatorProvider =
    StateNotifierProvider<PetScreenCoordinator, PetScreenCoordinatedState>((ref) {
  return PetScreenCoordinator(ref);
});

/// Provider que escuta mudanças nos providers filhos e atualiza o coordenador
final petScreenAutoSyncProvider = Provider<void>((ref) {
  // Escutar mudanças nos providers filhos
  ref.listen(enhancedPetGameProvider, (previous, next) {
    if (previous != next) {
      ref.read(petScreenCoordinatorProvider.notifier)._updateCoordinatedState();
    }
  });

  ref.listen(collaborativePetProvider, (previous, next) {
    if (previous != next) {
      ref.read(petScreenCoordinatorProvider.notifier)._syncSlotsWithPets();
      ref.read(petScreenCoordinatorProvider.notifier)._updateCoordinatedState();
    }
  });

  return;
});

// COMO USAR O COORDINATOR:
// ========================
//
// 1. No initState() da OptimizedPetScreen:
//    ref.read(petScreenCoordinatorProvider.notifier).initializeScreen();
//    ref.read(petScreenAutoSyncProvider); // Ativa sincronização automática
//
// 2. No build() para acessar estado coordenado:
//    final coordState = ref.watch(petScreenCoordinatorProvider);
//    if (coordState.isLoading) return CircularProgressIndicator();
//    if (coordState.errorMessage != null) return ErrorWidget();
//
// 3. Para refresh:
//    ref.read(petScreenCoordinatorProvider.notifier).refreshAllData();
//
// VANTAGENS:
// ✅ Sincronização automática entre providers
// ✅ Estado centralizado da tela
// ✅ Facilita debug e monitoramento
// ✅ Reduz complexidade de gerenciamento manual
// ✅ Melhora performance com carregamento paralelo
// ✅ Tratamento de erros centralizado
