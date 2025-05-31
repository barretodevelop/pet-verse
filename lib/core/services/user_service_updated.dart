// Métodos adicionais para UserService para suportar as novas funcionalidades

import 'package:petverse/core/model/user_model.dart';
import 'package:petverse/core/services/firebase_service.dart';
import 'package:petverse/core/services/user_service.dart';

extension UserServiceExtensions on UserService {
  static Future<void> updateUserStats(
    String userId, {
    int? coinsToAdd,
    int? xpToAdd,
    int? missionsCompleted,
    bool? incrementLoginStreak,
  }) async {
    try {
      await FirebaseService.runTransaction((transaction) async {
        final userDoc =
            await transaction.get(FirebaseService.users.doc(userId));
        if (!userDoc.exists) throw Exception('Usuário não encontrado');

        final user = UserModel.fromFirestore(userDoc);

        // Atualizar coins
        final newCoins = user.coins + (coinsToAdd ?? 0);

        // Atualizar XP e calcular novo nível
        final newTotalXP = user.totalXP + (xpToAdd ?? 0);
        final newLevel = (newTotalXP / 100).floor() + 1;
        final newXP = newTotalXP % 100;

        // Atualizar estatísticas
        final updatedStats = user.stats.copyWith(
          totalCoinsEarned: user.stats.totalCoinsEarned + (coinsToAdd ?? 0),
          totalXPEarned: user.stats.totalXPEarned + (xpToAdd ?? 0),
          totalMissionsCompleted:
              user.stats.totalMissionsCompleted + (missionsCompleted ?? 0),
          loginStreak: incrementLoginStreak == true
              ? user.stats.loginStreak + 1
              : user.stats.loginStreak,
        );

        // Criar usuário atualizado
        final updatedUser = user.copyWith(
          coins: newCoins,
          level: newLevel,
          xp: newXP,
          totalXP: newTotalXP,
          stats: updatedStats,
          updatedAt: DateTime.now(),
        );

        // Salvar no Firestore
        transaction.update(
          FirebaseService.users.doc(userId),
          updatedUser.toFirestore(),
        );
      });
    } catch (e) {
      throw Exception('Erro ao atualizar estatísticas do usuário: $e');
    }
  }

  static Future<void> addAchievement(
      String userId, String achievementId) async {
    try {
      await FirebaseService.runTransaction((transaction) async {
        final userDoc =
            await transaction.get(FirebaseService.users.doc(userId));
        if (!userDoc.exists) throw Exception('Usuário não encontrado');

        final user = UserModel.fromFirestore(userDoc);

        if (!user.achievements.contains(achievementId)) {
          final updatedAchievements = [...user.achievements, achievementId];
          final updatedStats = user.stats.copyWith(
            totalAchievementsUnlocked: user.stats.totalAchievementsUnlocked + 1,
          );

          final updatedUser = user.copyWith(
            achievements: updatedAchievements,
            stats: updatedStats,
            updatedAt: DateTime.now(),
          );

          transaction.update(
            FirebaseService.users.doc(userId),
            updatedUser.toFirestore(),
          );
        }
      });
    } catch (e) {
      throw Exception('Erro ao adicionar conquista: $e');
    }
  }
}
