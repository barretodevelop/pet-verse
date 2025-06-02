// lib/features/pet_customization/screens/pet_customization_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/shared/providers/global_providers.dart';
import 'package:petverse/shared/widgets/styled_app_bar.dart';

class PetCustomizationScreen extends ConsumerWidget {
  const PetCustomizationScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePet = ref.watch(activePetProvider);
    return Scaffold(
      appBar: const StyledAppBar(title: 'Customizar Pet'),
      body: Center(
          child: activePet == null
              ? Text('Nenhum pet selecionado.',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground))
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(activePet.definition.emoji,
                      style: const TextStyle(fontSize: 100)),
                  const SizedBox(height: 20),
                  Text('Customizando ${activePet.definition.name}',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onBackground)),
                  const SizedBox(height: 20),
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Funcionalidade em desenvolvimento...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.7)))),
                ])),
    );
  }
}
