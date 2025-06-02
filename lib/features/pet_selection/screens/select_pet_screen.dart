// lib/features/pet_selection/screens/select_pet_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/data/game_data.dart';
import 'package:petverse/shared/providers/global_providers.dart'
    show activePetProvider;
import 'package:petverse/shared/widgets/styled_app_bar.dart';

class SelectPetScreen extends ConsumerWidget {
  const SelectPetScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = GameData.availablePets;
    return Scaffold(
      appBar: const StyledAppBar(title: 'Escolha seu Pet'),
      body: Column(children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Adote um companheiro virtual!",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground),
                textAlign: TextAlign.center)),
        Expanded(
            child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12),
          padding: const EdgeInsets.all(16),
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final petDef = pets[index];
            return Card(
                    child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                await ref.read(activePetProvider.notifier).selectPet(petDef);
                if (context.mounted) context.go('/main');
              },
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(petDef.emoji, style: const TextStyle(fontSize: 64)),
                    const SizedBox(height: 12),
                    Text(petDef.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
                  ]),
            ))
                .animate()
                .fadeIn(duration: (300 + index * 100).ms)
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
          },
        )),
      ]),
    );
  }
}
