// lib/features/quests/screens/quests_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/constants/app_colors.dart';
import 'package:petverse/data/game_data.dart';
import 'package:petverse/shared/providers/app_providers.dart';
import 'package:petverse/shared/providers/global_providers.dart';
import 'package:petverse/shared/widgets/styled_app_bar.dart';

class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final quests = user.dailyQuests.entries.toList();
    final activeEvent = ref.watch(eventManagerProvider).getActiveEvent();

    return Scaffold(
      appBar: StyledAppBar(title: activeEvent?.name ?? 'Missões Diárias'),
      body: quests.isEmpty
          ? Center(
              child: Text("Nenhuma missão disponível. Volte amanhã!",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground)))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: quests.length,
              itemBuilder: (context, index) {
                final questProgress = quests[index].value;
                final questDef = GameData.getQuestById(questProgress.questId);
                if (questDef == null) return const SizedBox.shrink();

                final isComplete =
                    questProgress.currentCount >= questDef.targetCount;
                final isClaimed = questProgress.isClaimed;

                return Card(
                  color: isClaimed
                      ? AppColors.success.withOpacity(0.1)
                      : Theme.of(context).cardTheme.color,
                  child: ListTile(
                    leading: Icon(Icons.star,
                        color: isComplete
                            ? AppColors.goldCoin
                            : AppColors.questColor,
                        size: 40),
                    title: Text(questDef.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface)),
                    subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(questDef.description,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.8))),
                          const SizedBox(height: 5),
                          LinearProgressIndicator(
                              value: questDef.targetCount > 0
                                  ? questProgress.currentCount /
                                      questDef.targetCount
                                  : 1.0,
                              borderRadius: BorderRadius.circular(5)),
                          Text(
                              "${questProgress.currentCount} / ${questDef.targetCount}",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7))),
                        ]),
                    trailing: isClaimed
                        ? const Icon(Icons.check_circle,
                            color: AppColors.success, size: 30)
                        : ElevatedButton(
                            onPressed: isComplete
                                ? () {
                                    if (ref
                                            .read(userProvider.notifier)
                                            .claimQuestReward(questDef.id) &&
                                        context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  "Recompensa coletada! +${questDef.rewardCoins} moedas, +${questDef.rewardGems} gemas."),
                                              backgroundColor:
                                                  AppColors.success));
                                    }
                                  }
                                : null,
                            child: const Text("Coletar"),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
