import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/constants/app_colors.dart';
import 'package:petverse/features/auth/providers/auth_providers.dart';
import 'package:petverse/features/settings/providers/day_night_cycle_provider.dart';
import 'package:petverse/features/settings/providers/theme_provider.dart';
import 'package:petverse/shared/widgets/styled_app_bar.dart';

// lib/features/settings/screens/settings_screen.dart (ALTERADO)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final dayNightCycleEnabled = ref.watch(dayNightCycleProvider); // NOVO
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const StyledAppBar(title: "Configurações"),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: Text("Modo Escuro",
                style: TextStyle(color: theme.colorScheme.onSurface)),
            value: currentThemeMode == ThemeMode.dark,
            onChanged: (bool value) {
              ref
                  .read(themeModeProvider.notifier)
                  .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
            secondary: Icon(
                currentThemeMode == ThemeMode.dark
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                color: theme.colorScheme.primary),
          ),
          const Divider(),
          // NOVO: Switch para Ciclo Dia/Noite
          SwitchListTile(
            title: Text("Ciclo Dia/Noite Dinâmico",
                style: TextStyle(color: theme.colorScheme.onSurface)),
            subtitle: Text("Muda o fundo da tela do pet com a hora.",
                style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7))),
            value: dayNightCycleEnabled,
            onChanged: (bool value) {
              ref
                  .read(dayNightCycleProvider.notifier)
                  .setDayNightCycleEnabled(value);
            },
            secondary: Icon(
                dayNightCycleEnabled
                    ? Icons.wb_sunny_outlined
                    : Icons.nights_stay_outlined,
                color: theme.colorScheme.primary),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.info_outline,
                color: theme.colorScheme.onSurface.withOpacity(0.7)),
            title: Text("Sobre o App",
                style: TextStyle(color: theme.colorScheme.onSurface)),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Meu Pet Virtual",
                applicationVersion: "1.0.0",
                applicationLegalese: "© 2024 Seu Nome/Empresa",
                children: [
                  const Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: Text("Cuide do seu pet virtual e divirta-se!")),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text("Sair da Conta",
                style: TextStyle(color: AppColors.error)),
            onTap: () async {
              final confirmLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext dialogContext) => AlertDialog(
                  title: const Text('Sair da Conta'),
                  content: const Text('Você tem certeza que deseja sair?'),
                  actions: <Widget>[
                    TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(false)),
                    TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.error),
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        child: const Text('Sair')),
                  ],
                ),
              );

              if (confirmLogout == true && context.mounted) {
                final authService = ref.read(authServiceProvider);
                // ... (lógica de limpar dados locais como na V12) ...
                await authService.signOut();
                if (context.mounted) context.go('/');
              }
            },
          ),
        ],
      ),
    );
  }
}
