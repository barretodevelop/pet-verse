import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/theme/bck-app_theme.dart';
import 'package:petverse/core/utils/app_utils.dart';
import 'package:petverse/core/widgets/resource_chip.dart' hide AppTheme;
import 'package:petverse/feature/auth/providers/authentication_provider.dart';

class CustomHomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomHomeAppBar({super.key});

  @override
  Size get preferredSize => const Size(double.infinity, 110);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authenticationNotifierProvider);
    final user = authState.userModel;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 45, 20, 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 186, 212, 245), // Azul muito claro
            Color(0xFFF0F8FF), // Alice blue
          ],
          stops: [0.0, 0.7],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar com nível
              Stack(
                children: [
                  InkWell(
                    onTap: () {
                      context.push('/profile');
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: user?.photoURL != null
                          ? ClipOval(
                              child: Image.network(
                                user!.photoURL!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: -1,
                    right: -1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3, vertical: 1),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Text(
                        '${user?.level ?? 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              // Saudação
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, ${user?.displayName ?? 'Jogador'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Text(
                      'Pronto para se divertir?',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Ações
              Row(
                children: [
                  _HeaderActionButton(
                    icon: Icons.emoji_events_outlined,
                    color: AppTheme.warning,
                    onTap: () => AppUtils.lightImpact(),
                  ),
                  const SizedBox(width: 8),
                  _HeaderActionButton(
                    icon: Icons.notifications_outlined,
                    color: AppTheme.primary,
                    onTap: () => AppUtils.lightImpact(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Segunda linha - Recursos do usuário
          Row(
            children: [
              ResourceChip(
                icon: '⭐',
                label: 'LEVEL',
                value: '${user?.level ?? 1}',
                color: const Color(0xFFEC4899),
              ),
              const SizedBox(width: 6),
              ResourceChip(
                icon: '🪙',
                label: 'COINS',
                value: '${user?.coins ?? 0}',
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 6),
              ResourceChip(
                icon: '💎',
                label: 'GEMS',
                value: '${user?.gems ?? 0}',
                color: const Color(0xFF06B6D4),
              ),
              const SizedBox(width: 6),
              ResourceChip(
                icon: '🏪',
                label: 'Loja',
                value: '',
                color: const Color.fromARGB(255, 6, 120, 52),
                onTap: () {
                  context.push('/shop');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget privado para os botões de ação do cabeçalho
class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 18,
        ),
      ),
    );
  }
}
