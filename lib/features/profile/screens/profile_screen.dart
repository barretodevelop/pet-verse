// lib/features/profile/screens/profile_screen.dart (NOVO)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/constants/app_colors.dart';
import 'package:petverse/data/achievement_data.dart';
import 'package:petverse/data/game_data.dart';
import 'package:petverse/features/auth/providers/auth_providers.dart';
import 'package:petverse/shared/models/achievement_progress.dart';
import 'package:petverse/shared/providers/global_providers.dart';
import 'package:petverse/shared/widgets/styled_app_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseUser = ref.watch(authStateChangesProvider).asData?.value;
    final userProfile = ref.watch(userProvider); // Nosso UserProfile do jogo
    final theme = Theme.of(context);

    if (firebaseUser == null) {
      // Não deveria acontecer se a rota for protegida, mas como fallback
      return Scaffold(
          appBar: AppBar(title: const Text("Perfil")),
          body: const Center(child: Text("Usuário não encontrado.")));
    }

    final allGameItemsMap = {
      for (var item in GameData.getShopItems(null)) item.id: item
    };
    final allPetsMap = {for (var pet in GameData.availablePets) pet.id: pet};

    return Scaffold(
      appBar: StyledAppBar(
        title: "Meu Perfil",
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: "Configurações",
            onPressed: () => context.go('main/settings'),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: firebaseUser.photoURL != null
                      ? NetworkImage(firebaseUser.photoURL!)
                      : null,
                  child: firebaseUser.photoURL == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  firebaseUser.displayName ?? "Jogador Anônimo",
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: theme.colorScheme.onSurface),
                ),
                Text(
                  firebaseUser.email ?? "",
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          const Divider(height: 30),
          _buildSectionTitle(context, "Progresso do Jogo"),
          ListTile(
            leading:
                const Icon(Icons.star_rounded, color: AppColors.userXpColor),
            title: Text("UXP (Experiência de Usuário)",
                style: TextStyle(color: theme.colorScheme.onSurface)),
            trailing: Text("${userProfile.uxp}",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface)),
          ),
          ListTile(
            leading:
                const Icon(Icons.monetization_on, color: AppColors.goldCoin),
            title: Text("Moedas",
                style: TextStyle(color: theme.colorScheme.onSurface)),
            trailing: Text("${userProfile.coins}",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface)),
          ),
          ListTile(
            leading:
                const Icon(Icons.diamond_outlined, color: AppColors.gemStone),
            title: Text("Gemas",
                style: TextStyle(color: theme.colorScheme.onSurface)),
            trailing: Text("${userProfile.gems}",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface)),
          ),
          const Divider(height: 30),
          _buildSectionTitle(context, "Álbum de Pets"),
          userProfile.collectedPetIds.isEmpty
              ? const Center(child: Text("Nenhum pet colecionado ainda."))
              : SizedBox(
                  height: 100, // Altura fixa para a lista horizontal de pets
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: userProfile.collectedPetIds.length,
                    itemBuilder: (context, index) {
                      final petId =
                          userProfile.collectedPetIds.elementAt(index);
                      final petDef = allPetsMap[petId];
                      if (petDef == null) return const SizedBox.shrink();
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(petDef.emoji,
                                  style: const TextStyle(fontSize: 30)),
                              const SizedBox(height: 4),
                              Text(petDef.name,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          const Divider(height: 30),
          _buildSectionTitle(context, "Conquistas"),
          AchievementData.allAchievements.isEmpty
              ? const Center(child: Text("Nenhuma conquista definida no jogo."))
              : Column(
                  // Usando Column para evitar ListView dentro de ListView diretamente
                  children: AchievementData.allAchievements.map((achDef) {
                    final progress =
                        userProfile.achievementProgress[achDef.id] ??
                            AchievementProgress(achievementId: achDef.id);
                    final bool canClaim =
                        progress.isCompleted && !progress.isClaimed;
                    return Card(
                      color: progress.isClaimed
                          ? AppColors.achievementClaimedColor.withOpacity(0.2)
                          : (progress.isCompleted
                              ? AppColors.achievementUnlockedColor
                                  .withOpacity(0.2)
                              : theme.cardTheme.color),
                      child: ListTile(
                        leading: Text(achDef.iconEmoji,
                            style: TextStyle(
                                fontSize: 28,
                                color: progress.isCompleted
                                    ? AppColors.achievementUnlockedColor
                                    : AppColors.achievementLockedColor)),
                        title: Text(achDef.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(achDef.description,
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.8))),
                            if (!progress.isCompleted) ...[
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: achDef.targetValue > 0
                                    ? progress.currentProgress /
                                        achDef.targetValue
                                    : 1.0,
                                backgroundColor: AppColors
                                    .achievementLockedColor
                                    .withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.achievementUnlockedColor),
                              ),
                              Text(
                                  "${progress.currentProgress} / ${achDef.targetValue}",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7))),
                            ],
                            if (progress.isCompleted && !progress.isClaimed)
                              Text(
                                  "Recompensa: ${achDef.rewardCoins} Moedas, ${achDef.rewardGems} Gemas, ${achDef.rewardUxp} UXP",
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.success)),
                            if (progress.isClaimed)
                              Text("Recompensa Coletada!",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          AppColors.success.withOpacity(0.8))),
                          ],
                        ),
                        trailing: canClaim
                            ? ElevatedButton(
                                onPressed: () {
                                  final success = ref
                                      .read(userProvider.notifier)
                                      .claimAchievementReward(achDef.id);
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Conquista '${achDef.title}' resgatada!"),
                                            backgroundColor:
                                                AppColors.success));
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success),
                                child: const Text("Coletar"),
                              )
                            : (progress.isClaimed
                                ? const Icon(Icons.check_circle,
                                    color: AppColors.achievementClaimedColor)
                                : (progress.isCompleted
                                    ? const Icon(Icons.lock_open,
                                        color:
                                            AppColors.achievementUnlockedColor)
                                    : const Icon(Icons.lock_outline,
                                        color:
                                            AppColors.achievementLockedColor))),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
