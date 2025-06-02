// lib/features/inventory/screens/inventory_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/constants/app_colors.dart';
import 'package:petverse/data/game_data.dart';
import 'package:petverse/shared/enums/enums.dart';
import 'package:petverse/shared/providers/app_providers.dart';
import 'package:petverse/shared/providers/global_providers.dart';
import 'package:petverse/shared/widgets/currency_display.dart';
import 'package:petverse/shared/widgets/styled_app_bar.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final activeEvent = ref.watch(eventManagerProvider).getActiveEvent();
    final allGameItemsMap = {
      for (var item in GameData.getShopItems(activeEvent)) item.id: item
    };

    final List<Widget> inventoryWidgets = [];
    user.itemQuantities.forEach((itemId, quantity) {
      final item = allGameItemsMap[itemId];
      if (item != null && quantity > 0) {
        final bool isEquipped = user.equippedItemId == item.id;
        inventoryWidgets.add(Card(
            child: ListTile(
          leading: item.assetPath != null
              ? Image.asset(item.assetPath!,
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                  errorBuilder: (c, o, s) =>
                      Text(item.emoji, style: const TextStyle(fontSize: 28)))
              : (item.itemColor != null
                  ? CircleAvatar(backgroundColor: item.itemColor, radius: 18)
                  : Text(item.emoji, style: const TextStyle(fontSize: 28))),
          title: Text("${item.name} (x$quantity)",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface)),
          subtitle: Text(item.description,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.8))),
          trailing: item.category == ItemCategory.accessory
              ? (isEquipped
                  ? ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Equipado'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white),
                      onPressed: () =>
                          ref.read(userProvider.notifier).unequipItem())
                  : ElevatedButton(
                      onPressed: () =>
                          ref.read(userProvider.notifier).equipItem(item.id),
                      child: const Text('Equipar')))
              : Chip(
                  label: Text(item.category.name.toUpperCase(),
                      style: const TextStyle(fontSize: 10)),
                  avatar: Icon(
                    item.category == ItemCategory.toy
                        ? Icons.gamepad_outlined
                        : item.category == ItemCategory.food
                            ? Icons.restaurant_menu
                            : item.category == ItemCategory.medicine
                                ? Icons.medical_services_outlined
                                : item.category == ItemCategory.bath
                                    ? Icons.bathtub_outlined
                                    : item.category == ItemCategory.grooming
                                        ? Icons.content_cut_outlined
                                        : item.category ==
                                                ItemCategory.environment
                                            ? Icons.wallpaper_outlined
                                            : Icons.category_outlined,
                    size: 16,
                    color: item.category == ItemCategory.toy
                        ? AppColors.toyColor
                        : item.category == ItemCategory.food
                            ? AppColors.hungerColor
                            : item.category == ItemCategory.medicine
                                ? AppColors.medicineColor
                                : item.category == ItemCategory.bath
                                    ? AppColors.bathColor
                                    : item.category == ItemCategory.grooming
                                        ? AppColors.groomingColor
                                        : item.category ==
                                                ItemCategory.environment
                                            ? AppColors.environmentItemColor
                                            : AppColors.accent,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
        )));
      }
    });

    return Scaffold(
      appBar: const StyledAppBar(title: 'Meu Inventário'),
      body: Column(children: [
        const CurrencyDisplay(),
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Seus tesouros!",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground),
                textAlign: TextAlign.center)),
        if (inventoryWidgets.isEmpty)
          Expanded(
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                const Icon(Icons.sentiment_dissatisfied,
                    size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text('Seu inventário está vazio.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onBackground)),
                const SizedBox(height: 24),
                ElevatedButton(
                    onPressed: () => context.go('/shop'),
                    child: const Text('Ir para a Loja')),
              ])))
        else
          Expanded(
              child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            children: inventoryWidgets,
          )),
      ]),
    );
  }
}
