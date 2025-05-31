import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/theme/app_theme.dart';
import 'package:petverse/core/utils/app_utils.dart';
import 'package:petverse/core/widgets/resource_chip.dart' hide AppTheme;
import 'package:petverse/feature/auth/providers/authentication_provider.dart';

class CustomHomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomHomeAppBar({super.key});

  @override
  Size get preferredSize => Size(double.infinity, 110.h);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authenticationNotifierProvider);
    final user = authState.userModel;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 45.h, 20.w, 8.h),
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
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.w),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primarySoft.withOpacity(0.2),
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
                                  return Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 20.sp,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: -1.h,
                    right: -1.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: Colors.white, width: 1.w),
                      ),
                      child: Text(
                        '${user?.level ?? 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10.w),
              // Saudação
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, ${user?.displayName ?? 'Jogador'}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Pronto para se divertir?',
                      style: TextStyle(
                        fontSize: 13.sp,
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
                  SizedBox(width: 8.w),
                  _HeaderActionButton(
                    icon: Icons.notifications_outlined,
                    color: AppTheme.primarySoft,
                    onTap: () => AppUtils.lightImpact(),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Segunda linha - Recursos do usuário
          Row(
            children: [
              ResourceChip(
                icon: '⭐',
                label: 'LEVEL',
                value: '${user?.level ?? 1}',
                color: const Color(0xFFEC4899),
              ),
              SizedBox(width: 6.w),
              ResourceChip(
                icon: '🪙',
                label: 'COINS',
                value: '${user?.coins ?? 0}',
                color: const Color(0xFFF59E0B),
              ),
              SizedBox(width: 6.w),
              ResourceChip(
                icon: '💎',
                label: 'GEMS',
                value: '${user?.gems ?? 0}',
                color: const Color(0xFF06B6D4),
              ),
              SizedBox(width: 6.w),
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
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 2.w,
          ),
        ),
        child: Icon(
          icon,
          color: color,
          size: 18.sp,
        ),
      ),
    );
  }
}
