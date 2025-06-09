// File: lib/presentation/providers/user_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/domain/entities/user_entity.dart';
import 'package:petverse/presentation/providers/auth_provider.dart';
import 'package:petverse/presentation/providers/dependencies_provider.dart';

/// User game data state
class UserGameDataState {
  final UserEntity? user;
  final LoadingState status;
  final String? errorMessage;
  final bool canClaimDailyReward;

  const UserGameDataState({
    this.user,
    this.status = LoadingState.initial,
    this.errorMessage,
    this.canClaimDailyReward = false,
  });

  UserGameDataState copyWith({
    UserEntity? user,
    LoadingState? status,
    String? errorMessage,
    bool clearError = false,
    bool? canClaimDailyReward,
  }) {
    return UserGameDataState(
      user: user ?? this.user,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      canClaimDailyReward: canClaimDailyReward ?? this.canClaimDailyReward,
    );
  }

  bool get isLoading => status == LoadingState.loading;
  bool get hasError => status == LoadingState.error;
  bool get isSuccess => status == LoadingState.success;
  bool get hasUser => user != null;
}

/// User game data notifier (versão simplificada)
class UserGameDataNotifier extends StateNotifier<UserGameDataState> {
  final Ref _ref;
  Timer? _refreshTimer;

  UserGameDataNotifier(this._ref) : super(const UserGameDataState()) {
    loadUserData();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Carrega os dados do usuário
  Future<void> loadUserData() async {
    final authState = _ref.read(authProvider);

    if (authState.firebaseUser == null) {
      state = state.copyWith(
        user: null,
        status: LoadingState.error,
        errorMessage: 'Usuário não autenticado',
      );
      return;
    }

    state = state.copyWith(status: LoadingState.loading, clearError: true);

    try {
      final getUserData = _ref.read(getUserDataProvider);
      final result = await getUserData(authState.firebaseUser!.uid);

      result.fold(
        (failure) {
          state = state.copyWith(
            status: LoadingState.error,
            errorMessage: failure.message,
          );
        },
        (user) {
          state = state.copyWith(
            user: user,
            status: LoadingState.success,
            canClaimDailyReward: true,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: LoadingState.error,
        errorMessage: 'Erro ao carregar dados do usuário: $e',
      );
    }
  }

  /// Força recarregamento dos dados do usuário
  Future<void> refreshUserData() async {
    await loadUserData();
  }

  /// Atualiza moedas do usuário (versão simplificada)
  Future<void> updateUserCoins(int newCoins, int newGems) async {
    if (state.user == null) return;

    try {
      final userRepository = _ref.read(userRepositoryProvider);

      final result = await userRepository.updateUserCurrency(
        userId: state.user!.id,
        coins: newCoins,
        gems: newGems,
        xp: state.user!.totalXp,
        level: state.user!.level,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            status: LoadingState.error,
            errorMessage: failure.message,
          );
        },
        (_) {
          // Recarregar dados do usuário após atualização
          loadUserData();
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: LoadingState.error,
        errorMessage: 'Erro ao atualizar moedas: $e',
      );
    }
  }

  /// Adiciona coins ao usuário
  Future<void> addCoins(int amount) async {
    if (state.user == null || amount <= 0) return;

    final newCoins = (state.user!.coins + amount).clamp(0, 999999999);
    await updateUserCoins(newCoins, state.user!.gems);
  }

  /// Remove coins do usuário
  Future<void> removeCoins(int amount) async {
    if (state.user == null || amount <= 0) return;

    final newCoins = (state.user!.coins - amount).clamp(0, 999999999);
    await updateUserCoins(newCoins, state.user!.gems);
  }

  /// Adiciona gems ao usuário
  Future<void> addGems(int amount) async {
    if (state.user == null || amount <= 0) return;

    final newGems = (state.user!.gems + amount).clamp(0, 999999);
    await updateUserCoins(state.user!.coins, newGems);
  }

  /// Remove gems do usuário
  Future<void> removeGems(int amount) async {
    if (state.user == null || amount <= 0) return;

    final newGems = (state.user!.gems - amount).clamp(0, 999999);
    await updateUserCoins(state.user!.coins, newGems);
  }

  /// Processa uma compra (remove moedas)
  Future<bool> processPurchase({
    required int coinsToRemove,
    required int gemsToRemove,
  }) async {
    if (state.user == null) return false;

    // Verificar se tem saldo suficiente
    if (state.user!.coins < coinsToRemove || state.user!.gems < gemsToRemove) {
      state = state.copyWith(
        status: LoadingState.error,
        errorMessage: 'Saldo insuficiente',
      );
      return false;
    }

    // Remover moedas
    final newCoins = state.user!.coins - coinsToRemove;
    final newGems = state.user!.gems - gemsToRemove;

    await updateUserCoins(newCoins, newGems);
    return !state.hasError;
  }

  /// Inicia refresh periódico para manter dados atualizados
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) {
        if (state.hasUser && !state.isLoading) {
          loadUserData();
        }
      },
    );
  }

  /// Simula daily reward (versão simplificada)
  Future<bool> claimDailyReward() async {
    if (state.user == null) return false;

    // Recompensas básicas
    final bonusCoins = 100 + (state.user!.level * 10);
    final bonusGems = 2 + (state.user!.level ~/ 5);

    await addCoins(bonusCoins);
    await addGems(bonusGems);

    state = state.copyWith(canClaimDailyReward: false);

    // Reabilitar depois de 24 horas (simulado)
    Timer(const Duration(seconds: 10), () {
      if (mounted) {
        state = state.copyWith(canClaimDailyReward: true);
      }
    });

    return true;
  }
}

/// Provider do estado de dados do usuário
final userGameDataProvider = StateNotifierProvider<UserGameDataNotifier, UserGameDataState>((ref) {
  return UserGameDataNotifier(ref);
});
