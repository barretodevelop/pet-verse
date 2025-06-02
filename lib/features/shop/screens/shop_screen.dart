// lib/features/shop/screens/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/constants/app_colors.dart';
import 'package:petverse/data/game_data.dart';
import 'package:petverse/shared/models/shop_item.dart';
import 'package:petverse/shared/models/user_state.dart';
import 'package:petverse/shared/providers/app_providers.dart';
import 'package:petverse/shared/providers/global_providers.dart';
import 'package:petverse/shared/widgets/currency_display.dart';
import 'package:petverse/shared/widgets/styled_app_bar.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});
  void _showPurchaseFeedback(BuildContext context, ShopItem item, bool success,
      UserProfile userState) {
    if (!context.mounted) return;
    String message;
    Color backgroundColor;
    if (success) {
      message = '${item.name} comprado!';
      backgroundColor = AppColors.success;
    } else if (!item.isStackable && userState.hasItem(item.id)) {
      message = 'Você já possui este item único.';
      backgroundColor = AppColors.accent;
    } else if (!userState.canAfford(item)) {
      message = 'Moedas/Gemas insuficientes.';
      backgroundColor = AppColors.error;
    } else {
      message = 'Falha ao comprar ${item.name}.';
      backgroundColor = AppColors.error;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final activeEvent = ref.watch(eventManagerProvider).getActiveEvent();
    final items = GameData.getShopItems(activeEvent);

    return Scaffold(
      appBar: const StyledAppBar(title: 'Loja de Itens'),
      body: Column(children: [
        if (activeEvent != null)
          Container(
              width: double.infinity,
              color: activeEvent.themeColor,
              padding: const EdgeInsets.all(8),
              child: Text(activeEvent.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center)),
        const CurrencyDisplay(),
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Adquira itens para seu pet!",
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.center)),
        Expanded(
            child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          itemCount: items.length,
          itemBuilder: (_, index) {
            final item = items[index];
            final bool canAfford = userState.canAfford(item);
            final bool canBuyMore =
                item.isStackable || !userState.hasItem(item.id);

            return Card(
                child: ListTile(
              leading: item.assetPath != null
                  ? Image.asset(item.assetPath!,
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                      errorBuilder: (c, o, s) => Text(item.emoji,
                          style: const TextStyle(fontSize: 28)))
                  : (item.itemColor != null
                      ? CircleAvatar(
                          backgroundColor: item.itemColor, radius: 18)
                      : Text(item.emoji, style: const TextStyle(fontSize: 28))),
              title: Text(item.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface)),
              subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.description,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.8))),
                    const SizedBox(height: 4),
                    Row(children: [
                      if (item.coinPrice > 0) ...[
                        const Icon(Icons.monetization_on,
                            color: AppColors.goldCoin, size: 18),
                        const SizedBox(width: 2),
                        Text('${item.coinPrice}',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.9)))
                      ],
                      if (item.gemPrice > 0) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.diamond,
                            color: AppColors.gemStone, size: 18),
                        const SizedBox(width: 2),
                        Text('${item.gemPrice}',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.9)))
                      ],
                    ]),
                  ]),
              trailing: ElevatedButton(
                onPressed: canAfford && canBuyMore
                    ? () => _showPurchaseFeedback(
                        context,
                        item,
                        ref.read(userProvider.notifier).buyItem(item),
                        userState)
                    : null,
                style: ElevatedButton.styleFrom(
                    backgroundColor: (canAfford && canBuyMore)
                        ? AppColors.accent
                        : Colors.grey,
                    foregroundColor: Colors.white),
                child: Text(canBuyMore
                    ? 'Comprar'
                    : (item.isStackable ? 'Comprar Mais' : 'Adquirido')),
              ),
            ));
          },
        )),
      ]),
    );
  }
}
