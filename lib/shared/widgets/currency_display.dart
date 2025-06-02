// lib/shared/widgets/currency_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/constants/app_colors.dart';
import 'package:petverse/shared/providers/global_providers.dart';

class CurrencyDisplay extends ConsumerWidget {
  const CurrencyDisplay({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 20),
            const SizedBox(width: 4),
            Text('${user.coins}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground)),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.diamond, color: AppColors.gemStone, size: 20),
            const SizedBox(width: 4),
            Text('${user.gems}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground)),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.star_rounded, color: AppColors.userXpColor, size: 22),
            const SizedBox(width: 4),
            Text('UXP: ${user.uxp}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground)),
          ]),
        ],
      ),
    );
  }
}
