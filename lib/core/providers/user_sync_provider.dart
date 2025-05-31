// Provider para sincronizar dados entre authentication e outras telas
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/providers/dashboard_provider.dart';
import 'package:petverse/core/providers/profile_provider.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';

final userSyncProvider = Provider<UserSyncService>((ref) {
  return UserSyncService(ref);
});

class UserSyncService {
  final Ref _ref;

  UserSyncService(this._ref);

  // Escutar mudanças no usuário e atualizar providers dependentes
  void startListening() {
    _ref.listen(authenticationNotifierProvider, (previous, next) {
      final user = next.userModel;

      // Atualizar dashboard
      _ref.read(dashboardProvider.notifier).updateUser(user);

      // Atualizar profile
      _ref.read(profileProvider.notifier).updateUser(user);
    });
  }

  // Método para atualizar estatísticas do usuário
  Future<void> updateUserStats({
    int? coinsEarned,
    int? xpEarned,
    int? missionsCompleted,
    bool? incrementLoginStreak,
  }) async {
    final authNotifier = _ref.read(authenticationNotifierProvider.notifier);
    final currentUser = _ref.read(authenticationNotifierProvider).userModel;

    if (currentUser == null) return;

    // Atualizar estatísticas
    final updatedStats = currentUser.stats.copyWith(
      totalCoinsEarned: coinsEarned != null
          ? currentUser.stats.totalCoinsEarned + coinsEarned
          : currentUser.stats.totalCoinsEarned,
      totalXPEarned: xpEarned != null
          ? currentUser.stats.totalXPEarned + xpEarned
          : currentUser.stats.totalXPEarned,
      totalMissionsCompleted: missionsCompleted != null
          ? currentUser.stats.totalMissionsCompleted + missionsCompleted
          : currentUser.stats.totalMissionsCompleted,
      loginStreak: incrementLoginStreak == true
          ? currentUser.stats.loginStreak + 1
          : currentUser.stats.loginStreak,
    );

    // Calcular novo nível baseado no XP
    final newTotalXP = currentUser.totalXP + (xpEarned ?? 0);
    final newLevel = (newTotalXP / 100).floor() + 1;
    final newXP = newTotalXP % 100;

    // Atualizar modelo do usuário
    final updatedUser = currentUser.copyWith(
      coins: currentUser.coins + (coinsEarned ?? 0),
      totalXP: newTotalXP,
      level: newLevel,
      xp: newXP,
      stats: updatedStats,
    );

    // Aqui você salvaria no Firebase usando UserService
    // await UserService.updateUser(updatedUser);

    // E atualizaria o estado local
    authNotifier.refreshUserModel();
  }

  // Método para adicionar conquista
  Future<void> unlockAchievement(String achievementId) async {
    final currentUser = _ref.read(authenticationNotifierProvider).userModel;

    if (currentUser == null ||
        currentUser.achievements.contains(achievementId)) {
      return;
    }

    final updatedUser = currentUser.copyWith(
      achievements: [...currentUser.achievements, achievementId],
    );

    // Salvar no Firebase
    // await UserService.updateUser(updatedUser);

    // Atualizar estado local
    _ref.read(authenticationNotifierProvider.notifier).refreshUserModel();
  }
}
