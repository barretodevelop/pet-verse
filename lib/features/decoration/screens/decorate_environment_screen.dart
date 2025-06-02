// lib/features/decoration/screens/decorate_environment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/constants/app_colors.dart';
import 'package:petverse/data/game_data.dart';
import 'package:petverse/shared/enums/enums.dart';
import 'package:petverse/shared/models/shop_item.dart';
import 'package:petverse/shared/providers/app_providers.dart';
import 'package:petverse/shared/providers/global_providers.dart';
import 'package:petverse/shared/widgets/styled_app_bar.dart';

class DecorateEnvironmentScreen extends ConsumerWidget {
  const DecorateEnvironmentScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final allShopItems =
        GameData.getShopItems(ref.watch(eventManagerProvider).getActiveEvent());
    final ownedEnvironmentItems = allShopItems
        .where((item) =>
            item.category == ItemCategory.environment && user.hasItem(item.id))
        .toList();
    final activeWallpaperId = user.activeWallpaperId;
    final activeFloorId = user.activeFloorId;
    ShopItem? getEnvItemById(String? id) {
      if (id == null) return null;
      try {
        return allShopItems.firstWhere((item) => item.id == id);
      } catch (e) {
        return null;
      }
    }

    final activeWallpaper = getEnvItemById(activeWallpaperId);
    final activeFloor = getEnvItemById(activeFloorId);

    return Scaffold(
      appBar: const StyledAppBar(title: "Decorar Ambiente"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Ambiente Atual:",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child: Text(
                    "Papel de Parede: ${activeWallpaper?.name ?? 'Padrão'}",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground))),
            if (activeWallpaperId != null)
              TextButton(
                  onPressed: () =>
                      ref.read(userProvider.notifier).clearActiveWallpaper(),
                  child: const Text("Remover"))
          ]),
          Row(children: [
            Expanded(
                child: Text("Piso: ${activeFloor?.name ?? 'Padrão'}",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground))),
            if (activeFloorId != null)
              TextButton(
                  onPressed: () =>
                      ref.read(userProvider.notifier).clearActiveFloor(),
                  child: const Text("Remover"))
          ]),
          const Divider(height: 30),
          Text("Itens de Decoração Adquiridos:",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground)),
          const SizedBox(height: 10),
          Expanded(
            child: ownedEnvironmentItems.isEmpty
                ? Center(
                    child: Text(
                        "Você não possui itens de decoração. Visite a loja!",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground)))
                : ListView.builder(
                    itemCount: ownedEnvironmentItems.length,
                    itemBuilder: (context, index) {
                      final item = ownedEnvironmentItems[index];
                      final bool isApplied = item.id == activeWallpaperId ||
                          item.id == activeFloorId;
                      return Card(
                          child: ListTile(
                        leading: item.assetPath != null
                            ? Image.asset(item.assetPath!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) =>
                                    const Icon(Icons.image_not_supported))
                            : (item.itemColor != null
                                ? CircleAvatar(
                                    backgroundColor: item.itemColor, radius: 20)
                                : Text(item.emoji,
                                    style: const TextStyle(fontSize: 24))),
                        title: Text(item.name,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                        subtitle: Text(item.description,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7))),
                        trailing: ElevatedButton(
                          onPressed: isApplied
                              ? null
                              : () {
                                  ref
                                      .read(userProvider.notifier)
                                      .setActiveEnvironmentItem(item);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("${item.name} aplicado!"),
                                          backgroundColor: AppColors.success));
                                },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: isApplied
                                  ? AppColors.success
                                  : AppColors.accent),
                          child: Text(isApplied ? "Aplicado" : "Aplicar"),
                        ),
                      ));
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}
