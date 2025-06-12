import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Para LucideIcons
import '../../core/app_notifier.dart';
import 'bottom_sheet.dart'; // Para acessar o appServiceProvider

class UserProfileSheet extends ConsumerWidget {
  final bool show;
  final VoidCallback onClose;

  const UserProfileSheet({super.key, required this.show, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(appServiceProvider.select((state) => state.user));
    final isDark = ref.watch(appServiceProvider.select((state) => state.isDark));
    final appService = ref.read(appServiceProvider.notifier);

    return AppBottomSheet(
      show: show,
      onClose: onClose,
      title: 'Perfil do Usuário',
      children: Column(
        mainAxisSize: MainAxisSize.min, // Ocupa o mínimo de espaço
        children: [
          // Avatar do Usuário
          Text(
            user?.avatar ?? '❓',
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 16),

          // Nome de Usuário
          Text(
            user?.username ?? 'Convidado',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade800, // Corrected
            ),
          ),
          const SizedBox(height: 8),

          // Nível do Usuário
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.star, color: Colors.yellow.shade700, size: 20), // Corrected
              const SizedBox(width: 4),
              Text(
                'Nível ${user?.level ?? 1}',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, // Corrected
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cartão de Experiência
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade100, // Corrected
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              children: [
                Text(
                  'Experiência: ${(user?.xp ?? 0) % 100}/100',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, // Corrected
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: ((user?.xp ?? 0) % 100) / 100, // Progresso do XP no nível atual
                  backgroundColor:
                      isDark ? Colors.grey.shade600 : Colors.grey.shade300, // Corrected
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 4),
                Text(
                  'XP Total: ${user?.xp ?? 0}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, // Corrected
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Botão Sair da Conta
          ElevatedButton.icon(
            onPressed: () {
              appService.logout();
              onClose(); // Fecha a folha
            },
            icon: const Icon(LucideIcons.logOut, size: 20),
            label: const Text('Sair da Conta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}
