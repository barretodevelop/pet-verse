// File: lib/presentation/providers/user_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/app_config.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/core/errors/failures.dart';
import 'package:petverse/core/utils/helpers.dart';
import 'package:petverse/domain/entities/user_entity.dart';
import 'package:petverse/domain/usecases/auth/domain/usecases/user/get_user_data.dart';
import 'package:petverse/domain/usecases/user/claim_daily_reward.dart';
import 'package:petverse/domain/usecases/user/update_user_data.dart';
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

/// User game data notifier
class UserGameDataNotifier extends StateNotifier<UserGameDataState> {
  final GetUserData _getUserData;
  final UpdateUserData _updateUserData;
  final ClaimDailyReward _claimDailyReward;
  final Ref _ref;

  Timer? _dailyRewardTimer;

  UserGameDataNotifier(
    this._getUserData,
    this._updateUserData,
    this._claimDailyReward,
    this._ref,
  ) : super(const UserGameDataState()) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && next.firebaseUser != null) {
        _loadUserData(next.firebaseUser!.uid);
      } else {
        _resetState();
      }
    });

    // Initialize if already authenticated
    final authState = _ref.read(authProvider);
    if (authState.isAuthenticated && authState.firebaseUser != null) {
      _loadUserData(authState.firebaseUser!.uid);
    }
  }

  Future<void> _loadUserData(String userId) async {
    state = state.copyWith(status: LoadingState.loading, clearError: true);

    final result = await _getUserData(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: LoadingState.error,
          errorMessage: _getErrorMessage(failure),
        );
      },
      (user) {
        final canClaim = user != null ? Helpers.canClaimDailyReward(user.lastDailyReward) : false;

        state = state.copyWith(
          user: user,
          status: LoadingState.success,
          canClaimDailyReward: canClaim,
          clearError: true,
        );

        if (user != null) {
          _startDailyRewardTimer();
        }
      },
    );
  }

  void _startDailyRewardTimer() {
    _dailyRewardTimer?.cancel();
    _dailyRewardTimer = Timer.periodic(
      const Duration(milliseconds: AppConfig.dailyRewardCheckInterval),
      (_) => _checkDailyReward(),
    );
  }

  void _checkDailyReward() {
    if (state.user != null) {
      final canClaim = Helpers.canClaimDailyReward(state.user!.lastDailyReward);
      if (canClaim != state.canClaimDailyReward) {
        state = state.copyWith(canClaimDailyReward: canClaim);
      }
    }
  }

  void _resetState() {
    _dailyRewardTimer?.cancel();
    state = const UserGameDataState();
  }

  Future<bool> updateUserData(Map<String, dynamic> data) async {
    if (state.user == null) return false;

    final params = UpdateUserDataParams(
      userId: state.user!.id,
      data: data,
    );

    final result = await _updateUserData(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: LoadingState.error,
          errorMessage: _getErrorMessage(failure),
        );
        return false;
      },
      (_) {
        // Reload user data to get updated values
        _loadUserData(state.user!.id);
        return true;
      },
    );
  }

  Future<DailyRewardResult> claimDailyReward() async {
    if (state.user == null) {
      return DailyRewardResult(
        success: false,
        message: 'User not authenticated',
      );
    }

    if (!state.canClaimDailyReward) {
      return DailyRewardResult(
        success: false,
        message: 'Daily reward already claimed today',
      );
    }

    final result = await _claimDailyReward(state.user!.id);

    return result.fold(
      (failure) {
        return DailyRewardResult(
          success: false,
          message: _getErrorMessage(failure),
        );
      },
      (reward) {
        // Update local state
        state = state.copyWith(canClaimDailyReward: false);

        // Reload user data to get updated currency
        _loadUserData(state.user!.id);

        return DailyRewardResult(
          success: true,
          message: 'Daily reward claimed! Day ${reward.day}',
          coins: reward.type == RewardType.coins ? reward.amount : 0,
          gems: reward.type == RewardType.gems ? reward.amount : 0,
          xp: reward.type == RewardType.xp ? reward.amount : 0,
        );
      },
    );
  }

  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case UserDataFailure:
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
    _dailyRewardTimer?.cancel();
    super.dispose();
  }
}

/// User game data provider
final userGameDataProvider = StateNotifierProvider<UserGameDataNotifier, UserGameDataState>((ref) {
  return UserGameDataNotifier(
    ref.read(getUserDataProvider),
    ref.read(updateUserDataProvider),
    ref.read(claimDailyRewardProvider),
    ref,
  );
});

/// Daily reward result class
class DailyRewardResult {
  final bool success;
  final String message;
  final int coins;
  final int gems;
  final int xp;

  DailyRewardResult({
    required this.success,
    required this.message,
    this.coins = 0,
    this.gems = 0,
    this.xp = 0,
  });
}
