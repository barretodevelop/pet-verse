// lib/features/album_conquistas/screens/album_achievements_screen.dart (NOVO)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/constants/app_colors.dart';
import 'package:petverse/data/achievement_data.dart';
import 'package:petverse/data/game_data.dart';
import 'package:petverse/shared/models/achievement_progress.dart';
import 'package:petverse/shared/providers/global_providers.dart';

class AlbumAchievementsScreen extends ConsumerWidget {
  const AlbumAchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final allShopItemsMap = {
      for (var item in GameData.getShopItems(null)) item.id: item
    };
    final allPetsMap = {for (var pet in GameData.availablePets) pet.id: pet};
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3, // Abas: Itens, Pets, Conquistas
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Coleções & Conquistas"),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.inventory_2_outlined), text: "Itens"),
              Tab(icon: Icon(Icons.pets_outlined), text: "Pets"),
              Tab(icon: Icon(Icons.emoji_events_outlined), text: "Conquistas"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Aba de Itens Colecionados
            ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: user.collectedItemIds.length,
              itemBuilder: (context, index) {
                final itemId = user.collectedItemIds.elementAt(index);
                final item = allShopItemsMap[itemId];
                if (item == null) return const SizedBox.shrink();
                return Card(
                  child: ListTile(
                    leading: item.assetPath != null
                        ? Image.asset(item.assetPath!,
                            width: 36,
                            height: 36,
                            fit: BoxFit.contain,
                            errorBuilder: (c, o, s) => Text(item.emoji,
                                style: const TextStyle(fontSize: 24)))
                        : (item.itemColor != null
                            ? CircleAvatar(
                                backgroundColor: item.itemColor, radius: 18)
                            : Text(item.emoji,
                                style: const TextStyle(fontSize: 24))),
                    title: Text(item.name,
                        style: TextStyle(color: theme.colorScheme.onSurface)),
                    subtitle: Text(item.description,
                        style: TextStyle(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.7))),
                    // Poderia adicionar um ícone de "check" se o item for importante para alguma conquista
                  ),
                );
              },
            ),

            // Aba de Pets Colecionados
            ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: user.collectedPetIds.length,
              itemBuilder: (context, index) {
                final petId = user.collectedPetIds.elementAt(index);
                final petDef = allPetsMap[petId];
                if (petDef == null) return const SizedBox.shrink();
                return Card(
                  child: ListTile(
                    leading: Text(petDef.emoji,
                        style: const TextStyle(fontSize: 30)),
                    title: Text(petDef.name,
                        style: TextStyle(color: theme.colorScheme.onSurface)),
                    // Poderia mostrar o nível mais alto alcançado com este pet
                  ),
                );
              },
            ),

            // Aba de Conquistas
            ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: AchievementData.allAchievements.length,
              itemBuilder: (context, index) {
                final achDef = AchievementData.allAchievements[index];
                final progress = user.achievementProgress[achDef.id] ??
                    AchievementProgress(achievementId: achDef.id);

                final bool canClaim =
                    progress.isCompleted && !progress.isClaimed;

                return Card(
                  color: progress.isClaimed
                      ? AppColors.achievementClaimedColor.withOpacity(0.2)
                      : (progress.isCompleted
                          ? AppColors.achievementUnlockedColor.withOpacity(0.2)
                          : theme.cardTheme.color),
                  child: ListTile(
                    leading: Text(achDef.iconEmoji,
                        style: TextStyle(
                            fontSize: 30,
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
                                ? progress.currentProgress / achDef.targetValue
                                : 1.0,
                            backgroundColor: AppColors.achievementLockedColor
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
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.success)),
                        if (progress.isClaimed)
                          Text("Recompensa Coletada!",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success.withOpacity(0.8))),
                      ],
                    ),
                    trailing: canClaim
                        ? ElevatedButton(
                            onPressed: () {
                              final success = ref
                                  .read(userProvider.notifier)
                                  .claimAchievementReward(achDef.id);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Conquista '${achDef.title}' resgatada!"),
                                    backgroundColor: AppColors.success));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success),
                            child: const Text("Coletar"),
                          )
                        : (progress.isClaimed
                            ? Icon(Icons.check_circle,
                                color: AppColors.achievementClaimedColor)
                            : (progress.isCompleted
                                ? Icon(Icons.lock_open,
                                    color: AppColors.achievementUnlockedColor)
                                : Icon(Icons.lock_outline,
                                    color: AppColors.achievementLockedColor))),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
