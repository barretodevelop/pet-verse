// ========================================
// 4. WIDGET DE LOGOUT PARA CONFIGURAÇÕES
// lib/presentation/widgets/logout_button.dart (NOVO)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';

class LogoutButton extends ConsumerWidget {
  final VoidCallback? onLogoutSuccess;

  const LogoutButton({
    super.key,
    this.onLogoutSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isAuthenticated = authState.isAuthenticated;
    final currentUser = authState.user;

    if (!isAuthenticated || currentUser == null) {
      return const SizedBox.shrink();
    }

    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text(
        'Sair',
        style: TextStyle(color: Colors.red),
      ),
      subtitle: Text('Sair de ${currentUser.email ?? 'sua conta'}'),
      onTap: () => _showLogoutDialog(context, ref),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).signOut();
              onLogoutSuccess?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
