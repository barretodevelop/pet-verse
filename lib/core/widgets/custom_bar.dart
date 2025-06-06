// ========================================
// CUSTOM APP BAR ATUALIZADA (SIMPLIFICADA)
// lib/core/widgets/custom_bar.dart (VERSÃO FINAL)
// ========================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/providers/currency_provider.dart';
import '../../presentation/providers/theme_provider.dart';
import '../../presentation/widgets/user_profile_widget.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onSettingsClick;
  final VoidCallback? onNotificationsClick;
  final bool showBackButton;
  final String? title;

  const CustomAppBar({
    super.key,
    this.onSettingsClick,
    this.onNotificationsClick,
    this.showBackButton = false,
    this.title,
    required String userDisplayName,
  });

  @override
  Size get preferredSize => const Size.fromHeight(180);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCurrency = ref.watch(userCurrencyProvider);
    final formattedCurrency = ref.watch(formattedCurrencyProvider);
    final isLightTheme = ref.watch(isLightThemeProvider);

    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLightTheme
              ? [const Color(0xFF8A05BE), const Color(0xFF4B0082)]
              : [const Color(0xFF1A1A1A), const Color(0xFF000000)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Seção principal da AppBar
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Widget de perfil do usuário (simplificado)
                    const Expanded(
                      child: UserProfileWidget(
                        showEmail: true,
                        avatarRadius: 22,
                      ),
                    ),

                    // Botões de ação
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botão de notificações
                        IconButton(
                          icon: Stack(
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                              // Badge de notificação
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red[500],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 12,
                                    minHeight: 12,
                                  ),
                                  child: const Text(
                                    '2',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onPressed: onNotificationsClick ??
                              () => _showNotifications(context),
                          tooltip: 'Notificações',
                        ),

                        // Botão de configurações
                        IconButton(
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed:
                              onSettingsClick ?? () => _showSettings(context),
                          tooltip: 'Configurações',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Barra de status da moeda
            Container(
              height: 40,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCurrencyDisplay(
                    icon: '💰',
                    value: formattedCurrency.coins,
                    color: const Color(0xFFFFD700),
                  ),
                  _buildCurrencyDisplay(
                    icon: '💎',
                    value: formattedCurrency.gems,
                    color: const Color(0xFF40E0D0),
                  ),
                  _buildCurrencyDisplay(
                    icon: '⭐',
                    value: formattedCurrency.xp,
                    color: const Color(0xFF32CD32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDisplay({
    required String icon,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notificações'),
        content: const Text('Nenhuma notificação nova'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Configurações',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Tema'),
              onTap: () {
                Navigator.pop(context);
                // Implementar mudança de tema
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificações'),
              onTap: () {
                Navigator.pop(context);
                // Implementar configurações de notificação
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ========================================
// PROVIDER PARA DETECTAR MUDANÇAS NO PERFIL
// lib/core/providers/auth_providers.dart (ADICIONAR)
// ========================================

/// Provider que observa mudanças no perfil do usuário
final userProfileChangesProvider = StreamProvider<Map<String, String?>>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((user) {
    if (user == null) {
      return {
        'name': null,
        'email': null,
        'photoUrl': null,
      };
    }

    return {
      'name': user.displayName ?? user.email?.split('@').first ?? 'Usuário',
      'email': user.email,
      'photoUrl': user.photoURL,
    };
  });
});
