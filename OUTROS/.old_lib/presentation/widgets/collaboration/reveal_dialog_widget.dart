// File: lib/presentation/widgets/collaboration/reveal_dialog_widget.dart

import 'package:flutter/material.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';
import 'package:petverse/presentation/widgets/animations/bounce_animation.dart';

class RevealDialogWidget extends StatelessWidget {
  final CollaborativePetEntity pet;
  final VoidCallback onRevealRequested;

  const RevealDialogWidget({
    super.key,
    required this.pet,
    required this.onRevealRequested,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            BounceAnimation(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.visibility,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: ThemeConfig.spacing20),

            Text(
              '🎉 PARABÉNS!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
            ),

            const SizedBox(height: ThemeConfig.spacing16),

            Text(
              '${pet.name} atingiu nível ${pet.level}!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: ThemeConfig.spacing12),

            Text(
              'Vocês cuidaram tão bem dele que ele quer apresentar vocês dois! 💕',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: ThemeConfig.spacing16),

            Container(
              padding: const EdgeInsets.all(ThemeConfig.spacing16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(height: ThemeConfig.spacing8),
                  Text(
                    'Seu parceiro anônimo também será perguntado se quer conhecer você.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue[800],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: ThemeConfig.spacing24),

            Text(
              'Aceitar Reveal?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(height: ThemeConfig.spacing20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing12),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: Column(
                      children: [
                        const Text('❌'),
                        const SizedBox(height: ThemeConfig.spacing4),
                        Text(
                          'Prefiro manter\nanônimo',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: ThemeConfig.spacing12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onRevealRequested();
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing12),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Column(
                      children: [
                        const Text('✅'),
                        const SizedBox(height: ThemeConfig.spacing4),
                        Text(
                          'SIM, quero\nconhecer!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
