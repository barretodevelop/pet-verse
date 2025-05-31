// lib/core/providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/model/user_model.dart';
import 'package:petverse/core/services/user_service.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';

// Provider principal para o usuário atual - usa autenticação como base
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authenticationNotifierProvider);

  if (!authState.isAuthenticated || authState.user == null) {
    return null;
  }

  try {
    return await UserService.getCurrentUser();
  } catch (e) {
    return null;
  }
});

// Provider para verificar se o usuário tem pet
final userHasPetProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user?.hasPet ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});

// Provider para refresh do usuário
final userRefreshProvider = StateProvider<int>((ref) => 0);

// Provider que escuta mudanças no refresh e autenticação
final watchCurrentUserProvider = FutureProvider<UserModel?>((ref) async {
  // Escuta mudanças no refresh e na autenticação
  ref.watch(userRefreshProvider);
  final authState = ref.watch(authenticationNotifierProvider);

  if (!authState.isAuthenticated || authState.user == null) {
    return null;
  }

  try {
    return await UserService.getCurrentUser();
  } catch (e) {
    return null;
  }
});

// Notifier para ações do usuário
class UserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref _ref;

  UserNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      state = const AsyncValue.loading();
      final authState = _ref.read(authenticationNotifierProvider);

      if (!authState.isAuthenticated) {
        state = const AsyncValue.data(null);
        return;
      }

      final user = await UserService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadUser();
    // Também atualiza o provider de refresh
    _ref.read(userRefreshProvider.notifier).state++;
  }

  Future<void> assignPet(String petId) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      state = const AsyncValue.loading();
      await UserService.assignPetToUser(currentUser.id, petId);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateUserData(UserModel updatedUser) async {
    try {
      state = const AsyncValue.loading();
      final user = await UserService.updateUser(updatedUser);
      state = AsyncValue.data(user);
      await refresh();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

final userNotifierProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<UserModel?>>((ref) {
  return UserNotifier(ref);
});

// Provider de conveniência para o estado da app baseado no usuário
final appUserStateProvider = Provider<AppUserState>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final authState = ref.watch(authenticationNotifierProvider);

  if (authState.isLoading) return AppUserState.loading;
  if (!authState.isAuthenticated) return AppUserState.unauthenticated;

  return userAsync.when(
    data: (user) {
      if (user == null) return AppUserState.error;
      if (user.hasPet) return AppUserState.hasPet;
      return AppUserState.needsAdoption;
    },
    loading: () => AppUserState.loading,
    error: (_, __) => AppUserState.error,
  );
});

enum AppUserState {
  loading,
  unauthenticated,
  needsAdoption,
  hasPet,
  error,
}
