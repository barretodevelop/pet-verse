import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/providers/currency_provider.dart';
import '../../presentation/providers/theme_provider.dart';

/// Widget customizado para a AppBar do aplicativo
class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback onSettingsClick;
  final VoidCallback? onNotificationsClick;
  final String? userDisplayName;
  final String? userAvatarUrl;
  final bool showBackButton;
  final String? title;

  const CustomAppBar({
    super.key,
    required this.onSettingsClick,
    this.onNotificationsClick,
    this.userDisplayName,
    this.userAvatarUrl,
    this.showBackButton = false,
    this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(180);

  void _showNotifications(BuildContext context) {}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCurrency = ref.watch(userCurrencyProvider);
    final formattedCurrency = ref.watch(formattedCurrencyProvider);
    final isLightTheme = ref.watch(isLightThemeProvider);

    final displayName = userDisplayName ?? 'Usuário';
    final avatarUrl =
        userAvatarUrl ?? 'https://placehold.co/50x50/cccccc/ffffff?text=AV';

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
                    // Avatar e saudação do usuário
                    Expanded(
                      child: Row(
                        children: [
                          // Avatar do usuário
                          GestureDetector(
                            // onTap: () => _showUserProfile(context),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundImage: NetworkImage(avatarUrl),
                                backgroundColor: Colors.white.withOpacity(0.2),
                                onBackgroundImageError:
                                    (exception, stackTrace) {
                                  // Fallback se a imagem não carregar
                                },
                                child: userAvatarUrl == null
                                    ? Text(
                                        displayName.isNotEmpty
                                            ? displayName[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Saudação e informações do usuário
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (title != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    title!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
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
                              // Badge de notificação (simulado)
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
                          onPressed: onSettingsClick,
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
                    color: const Color(0xFFFFD700), // Dourado
                    // onTap: () => _showCurrencyDetails(context, 'coins', userCurrency.coins),
                  ),
                  _buildCurrencyDisplay(
                    icon: '💎',
                    value: formattedCurrency.gems,
                    color: const Color(0xFF40E0D0), // Turquesa
                    // onTap: () => _showCurrencyDetails(context, 'gems', userCurrency.gems),
                  ),
                  _buildCurrencyDisplay(
                    icon: '⭐',
                    value: formattedCurrency.xp,
                    color: const Color(0xFF32CD32), // Verde lima
                    // onTap: () => _showLevelDetails(context, userCurrency),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para exibir informações de moeda
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
            Text(
              icon,
              style: const TextStyle(fontSize: 16),
            ),
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

  /// Retorna uma saudação baseada no horário atual
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia,';
    } else if (hour < 18) {
      return 'Boa tarde,';
    } else {
      return 'Boa noite,';
    }
  }
}
