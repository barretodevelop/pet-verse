// // ============================================================================
// ARQUIVO 1: lib/feature/dashoard/dashboard_page_updated.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/model/mocks.dart';
import 'package:petverse/core/providers/dashboard_provider.dart';
import 'package:petverse/core/providers/user_sync_provider.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';
import 'package:petverse/feature/pet/presentation/pages/my_pets.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  void _onQuickAction(String action, BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();

    switch (action) {
      case 'feed_all':
        // Atualizar stats do usuário
        ref.read(userSyncProvider).updateUserStats(
              coinsEarned: 10,
              xpEarned: 5,
            );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alimentando todos os pets... +10 coins, +5 XP'),
            backgroundColor: Color(0xFFF59E0B),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'new_adoption':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abrindo criação de adoção...'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'browse_adoptions':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buscando adoções disponíveis...'),
            backgroundColor: Color(0xFF3B82F6),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'my_pets':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyPetsPage()),
        );
        break;
    }
  }

  void _onPetTap(Map<String, dynamic> petData, BuildContext context) {
    final pet = petData['pet'] as MockPet;
    final adoption = AnonymousAdoption(
      missionId: 'ADT_001',
      codename: petData['coGuardian'],
      colorTheme: 0xFFEC4899,
      level: 8,
      badges: ['cat_lover'],
      successRate: 89,
      completedAdoptions: 7,
      currentStreak: 3,
      region: 'Centro - RJ',
      views: 23,
      interested: 8,
      potentialMatches: 2,
      timeLeftDays: 4.2,
      pets: [],
      codedMessage: 'Co-guardião experiente',
      personalityTags: ['dedicado', 'carinhoso'],
      status: 'normal',
      isNew: false,
    );

    // NavigationService.navigateToPetPage(context, pet, adoption);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo ${pet.name}...'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);
    final authState = ref.watch(authenticationNotifierProvider);

    // Se não há usuário autenticado, mostrar erro
    if (!authState.isAuthenticated || authState.userModel == null) {
      return _buildErrorState('Usuário não autenticado');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: dashboardState.isLoading
          ? _buildLoadingState()
          : _buildDashboard(context, ref, dashboardState),
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
              Icons.dashboard,
              color: const Color(0xFF3B82F6),
              size: 40.sp,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 2000.ms),
          SizedBox(height: 24.h),
          Text(
            'Carregando Dashboard...',
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
            'Erro',
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

  Widget _buildDashboard(
      BuildContext context, WidgetRef ref, DashboardState state) {
    final currentUserData = state.currentUserData;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(currentUserData, state.notifications),
            SizedBox(height: 20.h),
            _buildQuickActions(context, ref),
            SizedBox(height: 20.h),
            _buildMyPetsSection(context, state.myActivePets, currentUserData),
            SizedBox(height: 20.h),
            _buildNotificationsSection(state.notifications),
            SizedBox(height: 20.h),
            _buildStatsSection(currentUserData, state.myActivePets),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> currentUser,
      List<Map<String, dynamic>> notifications) {
    final xpProgress =
        (currentUser['xp'] as int) / (currentUser['xpToNext'] as int);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(currentUser['colorTheme'] as int).withOpacity(0.1),
            Color(currentUser['colorTheme'] as int).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Color(currentUser['colorTheme'] as int).withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color:
                      Color(currentUser['colorTheme'] as int).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(currentUser['colorTheme'] as int),
                    width: 2.w,
                  ),
                ),
                child: Center(
                  child: Text(
                    (currentUser['codename'] as String)
                        .split(' ')
                        .map((word) => word[0])
                        .join(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(currentUser['colorTheme'] as int),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 16.w),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            currentUser['codename'] as String,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Color(currentUser['colorTheme'] as int),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'Lv.${currentUser['level']}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${currentUser['successRate']}% sucesso • ${currentUser['totalAdoptions']} adoções',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // Notifications bell
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64748B).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.notifications_outlined,
                        color: const Color(0xFF64748B),
                        size: 18.sp,
                      ),
                    ),
                    if (notifications.any((n) => n['type'] == 'urgent'))
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        )
                            .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true))
                            .scale(
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.3, 1.3),
                              duration: 1000.ms,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // XP Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Experiência',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    '${currentUser['xp']} / ${currentUser['xpToNext']} XP',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(currentUser['colorTheme'] as int),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: xpProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(currentUser['colorTheme'] as int),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Currency Display (Novo)
          Row(
            children: [
              Expanded(
                child: _buildCurrencyChip(
                  '🪙',
                  'Coins',
                  '${currentUser['coins']}',
                  const Color(0xFFF59E0B),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildCurrencyChip(
                  '💎',
                  'Gems',
                  '${currentUser['gems']}',
                  const Color(0xFF06B6D4),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildCurrencyChip(
                  '⚡',
                  'Total XP',
                  '${currentUser['totalXP']}',
                  const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildCurrencyChip(
      String emoji, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(8.w),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: TextStyle(fontSize: 14.sp)),
              SizedBox(width: 4.w),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 12.h),

        // Row de ações compactas
        Row(
          children: [
            Expanded(
                child: _buildCompactAction('Alimentar', Icons.restaurant,
                    const Color(0xFFF59E0B), 'feed_all', context, ref)),
            SizedBox(width: 8.w),
            Expanded(
                child: _buildCompactAction('Nova', Icons.add_circle,
                    const Color(0xFF10B981), 'new_adoption', context, ref)),
            SizedBox(width: 8.w),
            Expanded(
                child: _buildCompactAction('Buscar', Icons.search,
                    const Color(0xFF3B82F6), 'browse_adoptions', context, ref)),
            SizedBox(width: 8.w),
            Expanded(
                child: _buildCompactAction('Meus', Icons.pets,
                    const Color(0xFF8B5CF6), 'my_pets', context, ref)),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactAction(String title, IconData icon, Color color,
      String action, BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _onQuickAction(action, context, ref),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 16.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }

  // Manter os outros métodos do dashboard original...
  Widget _buildMyPetsSection(
      BuildContext context,
      List<Map<String, dynamic>> myActivePets,
      Map<String, dynamic> currentUser) {
    // Implementação igual ao original
    return Container(); // Placeholder
  }

  Widget _buildNotificationsSection(List<Map<String, dynamic>> notifications) {
    // Implementação igual ao original
    return Container(); // Placeholder
  }

  Widget _buildStatsSection(Map<String, dynamic> currentUser,
      List<Map<String, dynamic>> myActivePets) {
    // Implementação igual ao original
    return Container(); // Placeholder
  }
}
