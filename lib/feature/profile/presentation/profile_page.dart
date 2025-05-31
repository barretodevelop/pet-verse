import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/providers/profile_provider.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final authState = ref.watch(authenticationNotifierProvider);
    // final selectedTab = ref.watch(selectedTabProvider);

    // Se não há usuário autenticado, mostrar erro
    if (!authState.isAuthenticated || authState.userModel == null) {
      return Scaffold(
        appBar: _buildAppBar(context, ref),
        body: _buildErrorState('Usuário não autenticado'),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, ref),
      body: profileState.isLoading
          ? _buildLoadingState()
          : profileState.userProfile != null
              ? _buildContent(context, ref, profileState.userProfile!, 1)
              : _buildErrorState(profileState.errorMessage),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back,
          color: const Color(0xFF0F172A),
          size: 24.sp,
        ),
      ),
      title: Text(
        'Meu Perfil',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Atualizar dados do usuário
            ref
                .read(authenticationNotifierProvider.notifier)
                .refreshUserModel();
            ref.read(profileProvider.notifier).refreshProfile();
          },
          icon: Icon(
            Icons.refresh,
            color: const Color(0xFF64748B),
            size: 24.sp,
          ),
        ),
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // Navegar para configurações
          },
          icon: Icon(
            Icons.settings,
            color: const Color(0xFF64748B),
            size: 24.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              color: const Color(0xFF3B82F6),
              size: 40.sp,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 2000.ms),
          SizedBox(height: 24.h),
          Text(
            'Carregando perfil...',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: const Color(0xFFEF4444),
          ),
          SizedBox(height: 16.h),
          Text(
            'Erro ao carregar perfil',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, UserProfile profile,
      int selectedTab) {
    return Column(
      children: [
        _buildProfileHeader(profile),
        _buildTabSelector(ref, selectedTab),
        Expanded(
          child: _buildTabContent(context, profile, selectedTab),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    final xpProgress = profile.currentXP / profile.xpToNextLevel;

    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(profile.colorTheme).withOpacity(0.1),
            Color(profile.colorTheme).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Color(profile.colorTheme).withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          // Avatar e Info Principal
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(profile.colorTheme),
                          Color(profile.colorTheme).withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.w),
                      boxShadow: [
                        BoxShadow(
                          color: Color(profile.colorTheme).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        profile.codename
                            .split(' ')
                            .map((word) => word[0])
                            .join(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -1.h,
                    right: -1.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF59E0B),
                            const Color(0xFFF59E0B).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: Colors.white, width: 1.w),
                      ),
                      child: Text(
                        'Lv.${profile.level}',
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.codename,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: const Color(0xFFF59E0B),
                          size: 16.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Ranking #${profile.rankingPosition}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${profile.daysActive} dias ativo • ${profile.totalPetsAdopted} pets salvos',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Barra de XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Experiência',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '${profile.currentXP} / ${profile.xpToNextLevel} XP',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(profile.colorTheme),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Container(
                height: 8.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: xpProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(profile.colorTheme),
                          Color(profile.colorTheme).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${(profile.xpToNextLevel - profile.currentXP)} XP para o próximo nível',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Stats Rápidas
          Row(
            children: [
              Expanded(
                  child: _buildQuickStat('Pets Ativos', '${profile.activePets}',
                      const Color(0xFF3B82F6))),
              SizedBox(width: 12.w),
              Expanded(
                  child: _buildQuickStat('Taxa Sucesso',
                      '${profile.successRate}%', const Color(0xFF10B981))),
              SizedBox(width: 12.w),
              Expanded(
                  child: _buildQuickStat('Sequência',
                      '${profile.currentStreak}d', const Color(0xFFF59E0B))),
            ],
          ),

          SizedBox(height: 16.h),

          // Total XP e Data de Cadastro (Novo)
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Total XP',
                  '${profile.totalXPEarned}',
                  Icons.star,
                  const Color(0xFF8B5CF6),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildInfoItem(
                  'Membro desde',
                  _formatDate(profile.joinedDate),
                  Icons.calendar_today,
                  const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Manter os outros métodos do profile original...
  Widget _buildTabSelector(WidgetRef ref, int selectedTab) {
    // Implementação igual ao original
    return Container(); // Placeholder
  }

  Widget _buildTabContent(
      BuildContext context, UserProfile profile, int selectedTab) {
    // Implementação igual ao original
    return Container(); // Placeholder
  }
}
