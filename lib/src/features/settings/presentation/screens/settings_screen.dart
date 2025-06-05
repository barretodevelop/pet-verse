import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/core/theme/theme_provider.dart';
import 'package:petverse/src/features/auth/presentation/providers/auth_state_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Tema Escuro'),
            trailing: Switch(
              value: currentThemeMode == ThemeMode.dark,
              onChanged: (isDark) {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
          // TODO: Adicionar opção para tema do sistema
          // TODO: Adicionar opção para ciclo dia/noite
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await ref.read(authStateProvider.notifier).signOut();
              // A lógica de redirect do GoRouter deve levar para a tela de login.
              // Se a tela atual for mantida no stack após o logout e redirect,
              // pode ser necessário um context.go(AppRoutes.login) explícito aqui
              // ou garantir que o pop aconteça corretamente.
            },
          ),
        ],
      ),
    );
  }
}
