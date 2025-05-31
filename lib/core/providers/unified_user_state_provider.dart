// lib/core/providers/unified_user_state_provider.dart
// NOVO: Provider unificado que centraliza todo o estado do usuário
// Resolve problemas de fragmentação, sincronização e race conditions

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/firebase_pet_model.dart';
import 'package:petverse/core/model/user_model.dart';
import 'package:petverse/core/services/firebase_adoption_service.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';
import 'package:petverse/feature/auth/state/authentication_state.dart';

// Estado unificado do usuário
class UnifiedUserState {
  // Dados principais
  final UserModel? user;
  final CollaborativeAdoptionRequest? activeRequest;
  final List<FirebasePetModel> userPets;
  final String? currentPetId;

  // Estados de controle
  final AppFlow flow;
  final TransitionState transitionState;
  final bool isLoading;
  final String? error;

  // Cache e metadata
  final DateTime? lastUpdate;
  final Map<String, dynamic> cache;

  const UnifiedUserState({
    this.user,
    this.activeRequest,
    this.userPets = const [],
    this.currentPetId,
    this.flow = AppFlow.loading,
    this.transitionState = TransitionState.none,
    this.isLoading = false,
    this.error,
    this.lastUpdate,
    this.cache = const {},
  });

  // Getters de conveniência
  bool get isAuthenticated => user != null;
  bool get hasActiveRequest => activeRequest != null;
  bool get hasPet => userPets.isNotEmpty || currentPetId != null;
  bool get needsAdoption => isAuthenticated && !hasActiveRequest && !hasPet;
  bool get isInTransition => transitionState != TransitionState.none;
  bool get hasError => error != null;

  // Pet ativo
  FirebasePetModel? get activePet {
    if (currentPetId != null) {
      return userPets.firstWhere(
        (pet) => pet.id == currentPetId,
        orElse: () => userPets.isNotEmpty
            ? userPets.first
            : throw StateError('No pet found'),
      );
    }
    return userPets.isNotEmpty ? userPets.first : null;
  }

  // Copy with para atualizações imutáveis
  UnifiedUserState copyWith({
    UserModel? user,
    CollaborativeAdoptionRequest? activeRequest,
    List<FirebasePetModel>? userPets,
    String? currentPetId,
    AppFlow? flow,
    TransitionState? transitionState,
    bool? isLoading,
    String? error,
    DateTime? lastUpdate,
    Map<String, dynamic>? cache,
    bool clearError = false,
    bool clearActiveRequest = false,
  }) {
    return UnifiedUserState(
      user: user ?? this.user,
      activeRequest:
          clearActiveRequest ? null : (activeRequest ?? this.activeRequest),
      userPets: userPets ?? this.userPets,
      currentPetId: currentPetId ?? this.currentPetId,
      flow: flow ?? this.flow,
      transitionState: transitionState ?? this.transitionState,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      lastUpdate: lastUpdate ?? this.lastUpdate,
      cache: cache ?? this.cache,
    );
  }

  @override
  String toString() {
    return 'UnifiedUserState('
        'flow: $flow, '
        'hasUser: ${user != null}, '
        'hasRequest: $hasActiveRequest, '
        'petsCount: ${userPets.length}, '
        'transition: $transitionState, '
        'isLoading: $isLoading, '
        'hasError: $hasError'
        ')';
  }
}

// Notifier principal que gerencia todo o estado
class UnifiedUserStateNotifier extends StateNotifier<UnifiedUserState> {
  UnifiedUserStateNotifier(this._ref) : super(const UnifiedUserState()) {
    _initialize();
  }

  final Ref _ref;
  StreamSubscription? _authSubscription;
  Timer? _refreshTimer;

  // Inicialização do provider
  Future<void> _initialize() async {
    // Escutar mudanças na autenticação
    _authSubscription = _ref
        .read(authenticationNotifierProvider.notifier)
        .stream
        .listen((authState) {
      _handleAuthChange(authState);
    });

    // Configurar refresh automático a cada 30 segundos para dados críticos
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (state.isAuthenticated && !state.isInTransition) {
        _refreshUserData(silent: true);
      }
    });

    // Carregar estado inicial
    await _loadInitialState();
  }

  // Carregar estado inicial baseado na autenticação
  Future<void> _loadInitialState() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final authState = _ref.read(authenticationNotifierProvider);

      if (!authState.isAuthenticated || authState.userModel == null) {
        state = state.copyWith(
          flow: AppFlow.unauthenticated,
          isLoading: false,
        );
        return;
      }

      await _loadUserCompleteState(authState.userModel!);
    } catch (e) {
      state = state.copyWith(
        flow: AppFlow.error,
        error: 'Erro ao carregar estado inicial: $e',
        isLoading: false,
      );
    }
  }

  // Manipular mudanças na autenticação
  void _handleAuthChange(AuthenticationState authState) {
    if (!authState.isAuthenticated) {
      state = const UnifiedUserState(flow: AppFlow.unauthenticated);
    } else if (authState.userModel != null) {
      _loadUserCompleteState(authState.userModel!);
    }
  }

  // Carregar estado completo do usuário (dados + pets + solicitações)
  Future<void> _loadUserCompleteState(UserModel user) async {
    try {
      state = state.copyWith(
        user: user,
        isLoading: true,
        clearError: true,
        lastUpdate: DateTime.now(),
      );

      // Carregar dados em paralelo para melhor performance
      final results = await Future.wait([
        _loadActiveRequest(user.id),
        _loadUserPets(user.id),
      ]);

      final activeRequest = results[0] as CollaborativeAdoptionRequest?;
      final userPets = results[1] as List<FirebasePetModel>;

      // Determinar fluxo baseado nos dados carregados
      final flow = _determineFlow(
        user: user,
        activeRequest: activeRequest,
        userPets: userPets,
      );

      state = state.copyWith(
        activeRequest: activeRequest,
        userPets: userPets,
        currentPetId: user.currentPetId,
        flow: flow,
        isLoading: false,
        lastUpdate: DateTime.now(),
      );

      print('✅ Estado unificado carregado: $state');
    } catch (e) {
      state = state.copyWith(
        flow: AppFlow.error,
        error: 'Erro ao carregar dados do usuário: $e',
        isLoading: false,
      );
      print('❌ Erro ao carregar estado: $e');
    }
  }

  // Carregar solicitação ativa do usuário
  Future<CollaborativeAdoptionRequest?> _loadActiveRequest(
      String userId) async {
    try {
      return await FirebaseAdoptionService.getUserActiveRequest(userId);
    } catch (e) {
      print('⚠️ Erro ao carregar solicitação ativa: $e');
      return null;
    }
  }

  // Carregar pets do usuário
  Future<List<FirebasePetModel>> _loadUserPets(String userId) async {
    try {
      return await FirebaseAdoptionService.getUserPets(userId);
    } catch (e) {
      print('⚠️ Erro ao carregar pets: $e');
      return [];
    }
  }

  // Determinar fluxo atual baseado nos dados
  AppFlow _determineFlow({
    required UserModel user,
    CollaborativeAdoptionRequest? activeRequest,
    required List<FirebasePetModel> userPets,
  }) {
    // Verificar se tem pet
    if (userPets.isNotEmpty || user.currentPetId != null) {
      return AppFlow.hasPet;
    }

    // Verificar se tem solicitação ativa
    if (activeRequest != null && !activeRequest.isExpired) {
      return AppFlow.hasActiveRequest;
    }

    // Usuário autenticado mas sem pet e sem solicitação
    return AppFlow.needsAdoption;
  }

  // =====================================================
  // MÉTODOS PÚBLICOS PARA AÇÕES DO USUÁRIO
  // =====================================================

  // Refresh completo dos dados
  Future<void> refreshUserData({bool silent = false}) async {
    if (!state.isAuthenticated) return;

    await _refreshUserData(silent: silent);
  }

  Future<void> _refreshUserData({bool silent = false}) async {
    try {
      if (!silent) {
        state = state.copyWith(
          transitionState: TransitionState.refreshingData,
          clearError: true,
        );
      }

      // Refresh do usuário no authentication provider
      await _ref
          .read(authenticationNotifierProvider.notifier)
          .refreshUserModel();

      // Recarregar estado completo
      final authState = _ref.read(authenticationNotifierProvider);
      if (authState.userModel != null) {
        await _loadUserCompleteState(authState.userModel!);
      }

      if (!silent) {
        state = state.copyWith(transitionState: TransitionState.none);
      }
    } catch (e) {
      state = state.copyWith(
        transitionState: TransitionState.none,
        error: 'Erro ao atualizar dados: $e',
      );
    }
  }

  // Adotar pet com fluxo robusto e verificação de integridade
  Future<bool> adoptPet({
    required String requestId,
    required String petId,
    required String coParentDisplayName,
    required String coParentCodename,
  }) async {
    if (!state.isAuthenticated) {
      throw Exception('Usuário não autenticado');
    }

    try {
      // Estado transitório
      state = state.copyWith(
        transitionState: TransitionState.adoptingPet,
        clearError: true,
      );

      print('🔄 Iniciando adoção: requestId=$requestId, petId=$petId');

      // 1. Executar adoção no Firebase
      await FirebaseAdoptionService.acceptAdoptionRequest(
        requestId: requestId,
        petId: petId,
        coParentId: state.user!.id,
        coParentDisplayName: coParentDisplayName,
        coParentCodename: coParentCodename,
      );

      print('✅ Adoção realizada no Firebase');

      // 2. Aguardar propagação (importante para consistência)
      await Future.delayed(const Duration(milliseconds: 1500));

      // 3. Invalidar providers dependentes
      _invalidateRelatedProviders();

      // 4. Verificar integridade com retry
      final adoptionSuccess =
          await _verifyAdoptionIntegrity(petId, maxRetries: 3);

      if (adoptionSuccess) {
        print('✅ Verificação de integridade passou');

        // 5. Atualizar estado com sucesso
        state = state.copyWith(
          transitionState: TransitionState.none,
          clearActiveRequest: true, // Limpar solicitação ativa
        );

        // 6. Refresh completo para garantir consistência
        await _refreshUserData(silent: true);

        return true;
      } else {
        throw Exception('Falha na verificação de integridade pós-adoção');
      }
    } catch (e) {
      print('❌ Erro na adoção: $e');
      state = state.copyWith(
        transitionState: TransitionState.none,
        error: 'Erro na adoção: $e',
      );
      return false;
    }
  }

  // Verificar integridade da adoção com retry
  Future<bool> _verifyAdoptionIntegrity(String petId,
      {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Verificar se o pet apareceu nos pets do usuário
        final userPets =
            await FirebaseAdoptionService.getUserPets(state.user!.id);
        final adoptedPet = userPets.firstWhere(
          (pet) => pet.id == petId,
          orElse: () => throw StateError('Pet não encontrado'),
        );

        if (userPets.contains(adoptedPet)) {
          print('✅ Integridade verificada na tentativa $attempt');
          return true;
        }
      } catch (e) {
        print('⚠️ Tentativa $attempt de verificação falhou: $e');
        if (attempt < maxRetries) {
          await Future.delayed(
              Duration(seconds: attempt * 2)); // Backoff exponencial
        }
      }
    }

    print('❌ Verificação de integridade falhou após $maxRetries tentativas');
    return false;
  }

  // Criar solicitação de adoção
  Future<String?> createAdoptionRequest({
    required List<String> selectedPetIds,
    required String codename,
    required int colorTheme,
    required String codedMessage,
    required List<String> personalityTags,
    required String region,
  }) async {
    if (!state.isAuthenticated || state.hasActiveRequest) {
      throw Exception('Não é possível criar solicitação no estado atual');
    }

    try {
      state = state.copyWith(
        transitionState: TransitionState.creatingRequest,
        clearError: true,
      );

      final requestId =
          await FirebaseAdoptionService.createCollaborativeAdoptionRequest(
        requesterId: state.user!.id,
        requesterDisplayName: state.user!.displayName ?? 'Usuário',
        requesterCodename: codename,
        requesterColorTheme: colorTheme,
        requesterLevel: state.user!.level,
        selectedPetIds: selectedPetIds,
        codedMessage: codedMessage,
        personalityTags: personalityTags,
        region: region,
      );

      // Aguardar propagação
      await Future.delayed(const Duration(milliseconds: 1000));

      // Refresh para carregar nova solicitação
      await _refreshUserData(silent: true);

      state = state.copyWith(transitionState: TransitionState.none);

      return requestId;
    } catch (e) {
      state = state.copyWith(
        transitionState: TransitionState.none,
        error: 'Erro ao criar solicitação: $e',
      );
      return null;
    }
  }

  // Cancelar solicitação ativa
  Future<bool> cancelActiveRequest() async {
    if (!state.hasActiveRequest) {
      throw Exception('Nenhuma solicitação ativa para cancelar');
    }

    try {
      state = state.copyWith(
        transitionState: TransitionState.cancelingRequest,
        clearError: true,
      );

      await FirebaseAdoptionService.cancelAdoptionRequest(
          state.activeRequest!.id);

      // Aguardar propagação
      await Future.delayed(const Duration(milliseconds: 1000));

      // Refresh para remover solicitação cancelada
      await _refreshUserData(silent: true);

      state = state.copyWith(transitionState: TransitionState.none);

      return true;
    } catch (e) {
      state = state.copyWith(
        transitionState: TransitionState.none,
        error: 'Erro ao cancelar solicitação: $e',
      );
      return false;
    }
  }

  // Limpar erro atual
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // Invalidar providers relacionados para forçar refresh
  void _invalidateRelatedProviders() {
    try {
      // Lista de providers que devem ser invalidados após operações críticas
      final providersToInvalidate = [
        'authenticationNotifierProvider',
        'publicAdoptionRequestsFirebaseProvider',
        'userActiveRequestProvider',
        'userPetsProvider',
        'availableCollaborativePetsProvider',
      ];

      print('🔄 Invalidando providers relacionados: $providersToInvalidate');

      // Invalidar authentication para refresh do userModel
      _ref.invalidate(authenticationNotifierProvider);

      // Note: Outros providers serão invalidados quando disponível no escopo
    } catch (e) {
      print('⚠️ Erro ao invalidar providers: $e');
    }
  }

  // Cleanup
  @override
  void dispose() {
    _authSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }
}

// Provider principal que outros widgets devem usar
final unifiedUserStateProvider =
    StateNotifierProvider<UnifiedUserStateNotifier, UnifiedUserState>((ref) {
  return UnifiedUserStateNotifier(ref);
});

// Providers de conveniência derivados do estado unificado
final userFlowProvider = Provider<AppFlow>((ref) {
  return ref.watch(unifiedUserStateProvider).flow;
});

final isAuthenticatedUnifiedProvider = Provider<bool>((ref) {
  return ref.watch(unifiedUserStateProvider).isAuthenticated;
});

final hasActivePetUnifiedProvider = Provider<bool>((ref) {
  return ref.watch(unifiedUserStateProvider).hasPet;
});

final activeRequestUnifiedProvider =
    Provider<CollaborativeAdoptionRequest?>((ref) {
  return ref.watch(unifiedUserStateProvider).activeRequest;
});

final activePetUnifiedProvider = Provider<FirebasePetModel?>((ref) {
  return ref.watch(unifiedUserStateProvider).activePet;
});

final isInTransitionProvider = Provider<bool>((ref) {
  return ref.watch(unifiedUserStateProvider).isInTransition;
});

final transitionStateProvider = Provider<TransitionState>((ref) {
  return ref.watch(unifiedUserStateProvider).transitionState;
});

// Provider para verificar se pode criar nova solicitação
final canCreateRequestProvider = Provider<bool>((ref) {
  final state = ref.watch(unifiedUserStateProvider);
  return state.isAuthenticated &&
      !state.hasActiveRequest &&
      !state.hasPet &&
      !state.isInTransition;
});

// Provider para verificar se pode adotar pet
final canAdoptPetProvider = Provider<bool>((ref) {
  final state = ref.watch(unifiedUserStateProvider);
  return state.isAuthenticated && !state.hasPet && !state.isInTransition;
});
