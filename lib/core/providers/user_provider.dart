// lib/shared/providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/model/user_model.dart';

import '../../core/services/user_service.dart';

// Provider para o usuário atual
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  return await UserService.getCurrentUser();
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

// Provider que escuta mudanças no refresh
final watchCurrentUserProvider = FutureProvider<UserModel?>((ref) async {
  ref.watch(userRefreshProvider); // Escuta mudanças no refresh
  return await UserService.getCurrentUser();
});

// Notifier para ações do usuário
class UserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  UserNotifier() : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      state = const AsyncValue.loading();
      final user = await UserService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadUser();
  }

  Future<void> assignPet(String petId) async {
    final currentUser = state.value;
    if (currentUser == null) return;

    try {
      await UserService.assignPetToUser(currentUser.id, petId);
      await refresh();
    } catch (error) {
      // Handle error appropriately
      rethrow;
    }
  }
}

final userNotifierProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<UserModel?>>((ref) {
  return UserNotifier();
});
