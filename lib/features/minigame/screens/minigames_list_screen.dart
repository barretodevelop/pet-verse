// lib/features/minigame/screens/minigames_list_screen.dart (NOVO - Placeholder)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/constants/app_colors.dart';
import 'package:petverse/shared/widgets/styled_app_bar.dart';

class MinigamesListScreen extends StatelessWidget {
  const MinigamesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StyledAppBar(title: "Minijogos"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_esports_outlined,
                size: 80, color: AppColors.accent),
            const SizedBox(height: 20),
            Text(
              "Minijogos Divertidos!",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => context.go(
                  '/main/minigame_click_emoji'), // Exemplo de navegação para um minijogo
              child: const Text("Clique no Emoji"),
            ),
            // Adicionar mais botões para outros minijogos aqui
          ],
        ),
      ),
    );
  }
}
