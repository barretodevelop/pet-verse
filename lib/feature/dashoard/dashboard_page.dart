import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/model/mocks.dart';
import 'package:petverse/feature/pet/presentation/pages/my_pets.dart';
// import 'package:petverse/pages/my_pets_page.dart'; // Adicionar quando implementar

// Navigation Service
class NavigationService {
  static void navigateToPetPage(
      BuildContext context, MockPet pet, AnonymousAdoption adoption,
      {bool isNewlyAdopted = false}) {
    HapticFeedback.lightImpact();
    // TODO: Implementar navegação para PetPage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo ${pet.name}...'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }
}

// Providers
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

// State
class DashboardState {
  final bool isLoading;
  final Map<String, dynamic> currentUser;
  final List<Map<String, dynamic>> myActivePets;
  final List<Map<String, dynamic>> notifications;

  DashboardState({
    required this.isLoading,
    required this.currentUser,
    required this.myActivePets,
    required this.notifications,
  });

  DashboardState copyWith({
    bool? isLoading,
    Map<String, dynamic>? currentUser,
    List<Map<String, dynamic>>? myActivePets,
    List<Map<String, dynamic>>? notifications,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      myActivePets: myActivePets ?? this.myActivePets,
      notifications: notifications ?? this.notifications,
    );
  }
}

// Notifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier()
      : super(DashboardState(
          isLoading: true,
          currentUser: {},
          myActivePets: [],
          notifications: [],
        )) {
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await Future.delayed(const Duration(seconds: 1));

    state = state.copyWith(
      isLoading: false,
      currentUser: _getCurrentUser(),
      myActivePets: _generateMyPets(),
      notifications: _generateNotifications(),
    );
  }

  Map<String, dynamic> _getCurrentUser() {
    return {
      'codename': 'Guardian Azul',
      'level': 12,
      'xp': 2450,
      'xpToNext': 3000,
      'colorTheme': 0xFF3B82F6,
      'successRate': 94,
      'totalAdoptions': 15,
      'currentStreak': 5,
      'badges': ['golden_angel', 'shadow_protector', 'pet_whisperer'],
    };
  }

  List<Map<String, dynamic>> _generateMyPets() {
    return [
      {
        'pet': MockPet(
          name: 'Luna',
          type: 'Gato',
          age: '2 anos',
          photo: '🐱',
          traits: ['carinhoso', 'brincalhão'],
        ),
        'coGuardian': 'Protetor Rosa',
        'happiness': 85,
        'health': 92,
        'energy': 78,
        'hunger': 65,
        'needsAttention': false,
        'lastActivity': '2h atrás',
      },
      {
        'pet': MockPet(
          name: 'Max',
          type: 'Cachorro',
          age: '3 anos',
          photo: '🐕',
          traits: ['leal', 'energético'],
        ),
        'coGuardian': 'Anjo Verde',
        'happiness': 72,
        'health': 88,
        'energy': 45,
        'hunger': 85,
        'needsAttention': true,
        'lastActivity': '30min atrás',
      },
      {
        'pet': MockPet(
          name: 'Bella',
          type: 'Coelho',
          age: '1 ano',
          photo: '🐰',
          traits: ['fofo', 'tranquilo'],
        ),
        'coGuardian': 'Sábio Dourado',
        'happiness': 95,
        'health': 98,
        'energy': 90,
        'hunger': 30,
        'needsAttention': false,
        'lastActivity': '1h atrás',
      },
    ];
  }

  List<Map<String, dynamic>> _generateNotifications() {
    return [
      {
        'type': 'urgent',
        'title': 'Max precisa de comida!',
        'message': 'Nível de fome crítico',
        'time': '5min atrás',
        'icon': Icons.restaurant,
        'color': 0xFFEF4444,
      },
      {
        'type': 'achievement',
        'title': 'Nova conquista!',
        'message': 'Badge "Cuidador Dedicado"',
        'time': '1h atrás',
        'icon': Icons.emoji_events,
        'color': 0xFFF59E0B,
      },
      {
        'type': 'social',
        'title': 'Anjo Verde alimentou Max',
        'message': 'Co-guardião cuidou do pet',
        'time': '2h atrás',
        'icon': Icons.people,
        'color': 0xFF10B981,
      },
    ];
  }

  void refreshData() {
    state = state.copyWith(isLoading: true);
    _loadDashboardData();
  }
}

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  void _onQuickAction(String action, BuildContext context) {
    HapticFeedback.lightImpact();

    switch (action) {
      case 'feed_all':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alimentando todos os pets...'),
            backgroundColor: Color(0xFFF59E0B),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'new_adoption':
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateAdoptionPage()));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Abrindo criação de adoção...'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'browse_adoptions':
        // Navigator.push(context, MaterialPageRoute(builder: (context) => const AdoptionListPage()));
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

    NavigationService.navigateToPetPage(context, pet, adoption);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: dashboardState.isLoading
          ? _buildLoadingState(dashboardState.currentUser)
          : _buildDashboard(context, ref, dashboardState),
    );
  }

  Widget _buildLoadingState(Map<String, dynamic> currentUser) {
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

  Widget _buildDashboard(
      BuildContext context, WidgetRef ref, DashboardState state) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(state.currentUser, state.notifications),
            SizedBox(height: 20.h),
            _buildQuickActions(context),
            SizedBox(height: 20.h),
            _buildMyPetsSection(context, state.myActivePets, state.currentUser),
            SizedBox(height: 20.h),
            _buildNotificationsSection(state.notifications),
            SizedBox(height: 20.h),
            _buildStatsSection(state.currentUser, state.myActivePets),
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
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildQuickActions(BuildContext context) {
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
                    const Color(0xFFF59E0B), 'feed_all', context)),
            SizedBox(width: 8.w),
            Expanded(
                child: _buildCompactAction('Nova', Icons.add_circle,
                    const Color(0xFF10B981), 'new_adoption', context)),
            SizedBox(width: 8.w),
            Expanded(
                child: _buildCompactAction('Buscar', Icons.search,
                    const Color(0xFF3B82F6), 'browse_adoptions', context)),
            SizedBox(width: 8.w),
            Expanded(
                child: _buildCompactAction('Meus', Icons.pets,
                    const Color(0xFF8B5CF6), 'my_pets', context)),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactAction(String title, IconData icon, Color color,
      String action, BuildContext context) {
    return GestureDetector(
      onTap: () => _onQuickAction(action, context),
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

  Widget _buildMyPetsSection(
      BuildContext context,
      List<Map<String, dynamic>> myActivePets,
      Map<String, dynamic> currentUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Meus Pets',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyPetsPage()),
                );
              },
              child: Text(
                'Ver todos',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(currentUser['colorTheme'] as int),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 110.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: myActivePets.length,
            itemBuilder: (context, index) {
              return _buildPetCard(myActivePets[index], index, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPetCard(
      Map<String, dynamic> petData, int index, BuildContext context) {
    final pet = petData['pet'] as MockPet;
    final needsAttention = petData['needsAttention'] as bool;

    return GestureDetector(
      onTap: () => _onPetTap(petData, context),
      child: Container(
        width: 90.w,
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: needsAttention
                ? const Color(0xFFEF4444).withOpacity(0.3)
                : const Color(0xFFE2E8F0),
            width: needsAttention ? 2.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: needsAttention
                  ? const Color(0xFFEF4444).withOpacity(0.1)
                  : const Color(0xFF64748B).withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Text(
                  pet.photo,
                  style: TextStyle(fontSize: 22.sp),
                ),
                if (needsAttention)
                  Positioned(
                    top: -2.h,
                    right: -2.w,
                    child: Container(
                      width: 10.w,
                      height: 10.w,
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
            SizedBox(height: 6.h),
            Text(
              pet.name,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              petData['lastActivity'],
              style: TextStyle(
                fontSize: 9.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMiniStatBar(
                    petData['happiness'], const Color(0xFFF59E0B)),
                SizedBox(width: 2.w),
                _buildMiniStatBar(petData['health'], const Color(0xFF10B981)),
                SizedBox(width: 2.w),
                _buildMiniStatBar(petData['energy'], const Color(0xFF3B82F6)),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildMiniStatBar(int value, Color color) {
    return Container(
      width: 16.w,
      height: 3.h,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value / 100,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(List<Map<String, dynamic>> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Notificações',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${notifications.length}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...notifications
            .take(3)
            .map((notification) => _buildNotificationCard(notification)),
      ],
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: notification['type'] == 'urgent'
              ? const Color(0xFFEF4444).withOpacity(0.3)
              : const Color(0xFFE2E8F0),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: Color(notification['color']).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              notification['icon'],
              color: Color(notification['color']),
              size: 16.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  notification['message'],
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            notification['time'],
            style: TextStyle(
              fontSize: 9.sp,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> currentUser,
      List<Map<String, dynamic>> myActivePets) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estatísticas',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Pets Ativos', '${myActivePets.length}',
                    const Color(0xFF3B82F6)),
              ),
              Expanded(
                child: _buildStatItem(
                    'Sequência',
                    '${currentUser['currentStreak']} dias',
                    const Color(0xFF10B981)),
              ),
              Expanded(
                child: _buildStatItem('Taxa Sucesso',
                    '${currentUser['successRate']}%', const Color(0xFFF59E0B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
