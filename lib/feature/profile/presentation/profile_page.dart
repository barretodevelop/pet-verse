import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/model/mocks.dart';

// Providers
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

final selectedTabProvider = StateProvider<int>((ref) => 0);

// Models
class UserProfile {
  final String codename;
  final int level;
  final int currentXP;
  final int xpToNextLevel;
  final int colorTheme;
  final int totalPetsAdopted;
  final int activePets;
  final int successRate;
  final int currentStreak;
  final int longestStreak;
  final int daysActive;
  final int totalXPEarned;
  final List<Achievement> achievements;
  final List<AdoptionHistoryItem> adoptionHistory;
  final int rankingPosition;
  final DateTime joinedDate;

  UserProfile({
    required this.codename,
    required this.level,
    required this.currentXP,
    required this.xpToNextLevel,
    required this.colorTheme,
    required this.totalPetsAdopted,
    required this.activePets,
    required this.successRate,
    required this.currentStreak,
    required this.longestStreak,
    required this.daysActive,
    required this.totalXPEarned,
    required this.achievements,
    required this.adoptionHistory,
    required this.rankingPosition,
    required this.joinedDate,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int rarity; // 1=comum, 2=raro, 3=épico, 4=lendário
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int xpReward;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.rarity,
    required this.isUnlocked,
    this.unlockedAt,
    required this.xpReward,
  });
}

class AdoptionHistoryItem {
  final MockPet pet;
  final String coGuardianName;
  final DateTime adoptedAt;
  final int daysActive;
  final bool isCurrentlyActive;
  final int xpEarned;

  AdoptionHistoryItem({
    required this.pet,
    required this.coGuardianName,
    required this.adoptedAt,
    required this.daysActive,
    required this.isCurrentlyActive,
    required this.xpEarned,
  });
}

class RankingUser {
  final String codename;
  final int level;
  final int totalXP;
  final int colorTheme;
  final int position;

  RankingUser({
    required this.codename,
    required this.level,
    required this.totalXP,
    required this.colorTheme,
    required this.position,
  });
}

// State
class ProfileState {
  final bool isLoading;
  final UserProfile? userProfile;
  final List<RankingUser> ranking;
  final String errorMessage;

  ProfileState({
    required this.isLoading,
    this.userProfile,
    required this.ranking,
    required this.errorMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    UserProfile? userProfile,
    List<RankingUser>? ranking,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      userProfile: userProfile ?? this.userProfile,
      ranking: ranking ?? this.ranking,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier()
      : super(ProfileState(
          isLoading: true,
          ranking: [],
          errorMessage: '',
        )) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await Future.delayed(const Duration(seconds: 1));

    state = state.copyWith(
      isLoading: false,
      userProfile: _generateUserProfile(),
      ranking: _generateRanking(),
    );
  }

  UserProfile _generateUserProfile() {
    return UserProfile(
      codename: 'Guardian Azul',
      level: 12,
      currentXP: 2450,
      xpToNextLevel: 3000,
      colorTheme: 0xFF3B82F6,
      totalPetsAdopted: 15,
      activePets: 5,
      successRate: 94,
      currentStreak: 12,
      longestStreak: 25,
      daysActive: 89,
      totalXPEarned: 18450,
      joinedDate: DateTime.now().subtract(const Duration(days: 89)),
      rankingPosition: 24,
      achievements: _generateAchievements(),
      adoptionHistory: _generateAdoptionHistory(),
    );
  }

  List<Achievement> _generateAchievements() {
    return [
      Achievement(
        id: 'first_adoption',
        title: 'Primeiro Pet',
        description: 'Adotou seu primeiro pet',
        emoji: '🐾',
        rarity: 1,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 80)),
        xpReward: 100,
      ),
      Achievement(
        id: 'golden_angel',
        title: 'Anjo Dourado',
        description: 'Manteve 10 pets felizes por 30 dias',
        emoji: '👼',
        rarity: 3,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 20)),
        xpReward: 500,
      ),
      Achievement(
        id: 'streak_master',
        title: 'Mestre da Sequência',
        description: 'Cuidou de pets por 7 dias consecutivos',
        emoji: '🔥',
        rarity: 2,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
        xpReward: 250,
      ),
      Achievement(
        id: 'social_guardian',
        title: 'Guardião Social',
        description: 'Trabalhou com 5 co-guardiões diferentes',
        emoji: '🤝',
        rarity: 2,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 15)),
        xpReward: 300,
      ),
      Achievement(
        id: 'pet_whisperer',
        title: 'Sussurrador de Pets',
        description: 'Alcançou 95% de felicidade em todos os pets',
        emoji: '🎯',
        rarity: 3,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 10)),
        xpReward: 400,
      ),
      Achievement(
        id: 'legendary_guardian',
        title: 'Guardião Lendário',
        description: 'Cuidou de 50 pets com sucesso',
        emoji: '👑',
        rarity: 4,
        isUnlocked: false,
        xpReward: 1000,
      ),
      Achievement(
        id: 'speed_adopter',
        title: 'Adoção Relâmpago',
        description: 'Adotou um pet em menos de 30 segundos',
        emoji: '⚡',
        rarity: 2,
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 30)),
        xpReward: 200,
      ),
      Achievement(
        id: 'caring_heart',
        title: 'Coração Cuidadoso',
        description: 'Nunca deixou um pet triste por mais de 1 dia',
        emoji: '💖',
        rarity: 3,
        isUnlocked: false,
        xpReward: 600,
      ),
    ];
  }

  List<AdoptionHistoryItem> _generateAdoptionHistory() {
    return [
      AdoptionHistoryItem(
        pet: MockPet(
            name: 'Luna',
            type: 'Gato',
            age: '2 anos',
            photo: '🐱',
            traits: ['carinhoso']),
        coGuardianName: 'Protetor Rosa',
        adoptedAt: DateTime.now().subtract(const Duration(days: 3)),
        daysActive: 3,
        isCurrentlyActive: true,
        xpEarned: 150,
      ),
      AdoptionHistoryItem(
        pet: MockPet(
            name: 'Max',
            type: 'Cachorro',
            age: '3 anos',
            photo: '🐕',
            traits: ['leal']),
        coGuardianName: 'Anjo Verde',
        adoptedAt: DateTime.now().subtract(const Duration(days: 8)),
        daysActive: 8,
        isCurrentlyActive: true,
        xpEarned: 400,
      ),
      AdoptionHistoryItem(
        pet: MockPet(
            name: 'Buddy',
            type: 'Cachorro',
            age: '4 anos',
            photo: '🐕',
            traits: ['amigável']),
        coGuardianName: 'Sábio Dourado',
        adoptedAt: DateTime.now().subtract(const Duration(days: 45)),
        daysActive: 30,
        isCurrentlyActive: false,
        xpEarned: 1200,
      ),
      AdoptionHistoryItem(
        pet: MockPet(
            name: 'Mimi',
            type: 'Gato',
            age: '1 ano',
            photo: '🐱',
            traits: ['brincalhão']),
        coGuardianName: 'Guardião Coral',
        adoptedAt: DateTime.now().subtract(const Duration(days: 60)),
        daysActive: 25,
        isCurrentlyActive: false,
        xpEarned: 950,
      ),
    ];
  }

  List<RankingUser> _generateRanking() {
    return [
      RankingUser(
          codename: 'Mestre Supremo',
          level: 50,
          totalXP: 125000,
          colorTheme: 0xFFFFD700,
          position: 1),
      RankingUser(
          codename: 'Anjo Celestial',
          level: 42,
          totalXP: 98500,
          colorTheme: 0xFFC0C0C0,
          position: 2),
      RankingUser(
          codename: 'Guardião Eterno',
          level: 38,
          totalXP: 87200,
          colorTheme: 0xFFCD7F32,
          position: 3),
      RankingUser(
          codename: 'Protetor Lendário',
          level: 35,
          totalXP: 76500,
          colorTheme: 0xFF8B5CF6,
          position: 4),
      RankingUser(
          codename: 'Sábio Ancião',
          level: 32,
          totalXP: 68900,
          colorTheme: 0xFF10B981,
          position: 5),
      // ... mais usuários até chegar ao usuário atual na posição 24
      RankingUser(
          codename: 'Guardian Azul',
          level: 12,
          totalXP: 18450,
          colorTheme: 0xFF3B82F6,
          position: 24),
    ];
  }

  void refreshProfile() {
    state = state.copyWith(isLoading: true);
    _loadProfile();
  }
}

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, ref),
      body: profileState.isLoading
          ? _buildLoadingState()
          : _buildContent(context, ref, profileState.userProfile!, selectedTab),
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
          onPressed: () => ref.read(profileProvider.notifier).refreshProfile(),
          icon: Icon(
            Icons.refresh,
            color: const Color(0xFF64748B),
            size: 24.sp,
          ),
        ),
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push('/settings');
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(
            //     content: Text('Configurações em breve...'),
            //     backgroundColor: Color(0xFF3B82F6),
            //   ),
            // );
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
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Color(profile.colorTheme),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white, width: 2.w),
                      ),
                      child: Text(
                        'Lv.${profile.level}',
                        style: TextStyle(
                          fontSize: 10.sp,
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

  Widget _buildTabSelector(WidgetRef ref, int selectedTab) {
    final tabs = [
      {'title': 'Conquistas', 'icon': Icons.emoji_events},
      {'title': 'Histórico', 'icon': Icons.history},
      {'title': 'Ranking', 'icon': Icons.leaderboard},
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
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
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = selectedTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(selectedTabProvider.notifier).state = index;
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                      size: 20.sp,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      tab['title'] as String,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(
      BuildContext context, UserProfile profile, int selectedTab) {
    switch (selectedTab) {
      case 0:
        return _buildAchievementsTab(profile.achievements);
      case 1:
        return _buildHistoryTab(profile.adoptionHistory);
      case 2:
        return _buildRankingTab(context, profile);
      default:
        return const SizedBox();
    }
  }

  Widget _buildAchievementsTab(List<Achievement> achievements) {
    final unlockedAchievements =
        achievements.where((a) => a.isUnlocked).toList();
    final lockedAchievements =
        achievements.where((a) => !a.isUnlocked).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Conquistas Desbloqueadas',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${unlockedAchievements.length}/${achievements.length}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Lista de conquistas desbloqueadas
          ...unlockedAchievements.asMap().entries.map((entry) {
            final index = entry.key;
            final achievement = entry.value;
            return _buildAchievementListItem(achievement, index, true);
          }),

          SizedBox(height: 24.h),
          Text(
            'Conquistas Bloqueadas',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 12.h),

          // Lista de conquistas bloqueadas
          ...lockedAchievements.asMap().entries.map((entry) {
            final index = entry.key;
            final achievement = entry.value;
            return _buildAchievementListItem(
                achievement, index + unlockedAchievements.length, false);
          }),
        ],
      ),
    );
  }

  Widget _buildAchievementListItem(
      Achievement achievement, int index, bool isUnlocked) {
    final rarityColors = {
      1: const Color(0xFF64748B), // Comum
      2: const Color(0xFF3B82F6), // Raro
      3: const Color(0xFF8B5CF6), // Épico
      4: const Color(0xFFF59E0B), // Lendário
    };

    final rarityLabels = {
      1: 'Comum',
      2: 'Raro',
      3: 'Épico',
      4: 'Lendário',
    };

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // TODO: Mostrar detalhes da conquista
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isUnlocked
                ? rarityColors[achievement.rarity]!.withOpacity(0.3)
                : const Color(0xFFE2E8F0),
            width: isUnlocked ? 2.w : 1.w,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: rarityColors[achievement.rarity]!.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Emoji e Status
            Stack(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? rarityColors[achievement.rarity]!.withOpacity(0.1)
                        : const Color(0xFFE2E8F0).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      achievement.emoji,
                      style: TextStyle(
                        fontSize: 28.sp,
                        color: isUnlocked ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (!isUnlocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(width: 16.w),

            // Info da conquista
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          achievement.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: isUnlocked
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF94A3B8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w), // Espaçamento

                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isUnlocked
                                ? rarityColors[achievement.rarity]!
                                : const Color(0xFF94A3B8),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            rarityLabels[achievement.rarity]!,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isUnlocked
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      if (isUnlocked) ...[
                        Icon(
                          Icons.star,
                          color: const Color(0xFF10B981),
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '+${achievement.xpReward} XP',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                      if (isUnlocked && achievement.unlockedAt != null) ...[
                        Icon(
                          Icons.schedule,
                          color: const Color(0xFF64748B),
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Desbloqueado ${_formatDate(achievement.unlockedAt!)}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                      if (!isUnlocked) ...[
                        Icon(
                          Icons.lock_outline,
                          color: const Color(0xFF94A3B8),
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Recompensa: ${achievement.xpReward} XP',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildHistoryTab(List<AdoptionHistoryItem> history) {
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: history.length,
      itemBuilder: (context, index) {
        return _buildHistoryCard(history[index], index);
      },
    );
  }

  Widget _buildHistoryCard(AdoptionHistoryItem item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: item.isCurrentlyActive
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFFE2E8F0),
          width: item.isCurrentlyActive ? 2.w : 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: item.isCurrentlyActive
                ? const Color(0xFF10B981).withOpacity(0.1)
                : const Color(0xFF64748B).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pet Photo
          Stack(
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    item.pet.photo,
                    style: TextStyle(fontSize: 20.sp),
                  ),
                ),
              ),
              if (item.isCurrentlyActive)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.w),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(width: 12.w),

          // Pet Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.pet.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    if (item.isCurrentlyActive)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          'ATIVO',
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  '${item.pet.type} • ${item.pet.age}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Co-guardião: ${item.coGuardianName}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.daysActive} dias',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                '+${item.xpEarned} XP',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _formatDate(item.adoptedAt),
                style: TextStyle(
                  fontSize: 9.sp,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildRankingTab(BuildContext context, UserProfile profile) {
    return Consumer(
      builder: (context, ref, child) {
        final profileState = ref.watch(profileProvider);
        final ranking = profileState.ranking;

        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Minha Posição
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(profile.colorTheme).withOpacity(0.1),
                      Color(profile.colorTheme).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Color(profile.colorTheme).withOpacity(0.3),
                    width: 2.w,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: Color(profile.colorTheme),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.w),
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
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Minha Posição',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            profile.codename,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Lv.${profile.level} • ${profile.totalXPEarned} XP',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Color(profile.colorTheme),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '#${profile.rankingPosition}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              Text(
                'Top Guardiões',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),

              SizedBox(height: 12.h),

              // Top 3 Podium
              _buildPodium(ranking.take(3).toList()),

              SizedBox(height: 24.h),

              // Lista do ranking
              ...ranking
                  .skip(3)
                  .take(10)
                  .map((user) => _buildRankingCard(user)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPodium(List<RankingUser> topThree) {
    if (topThree.length < 3) return const SizedBox();

    return SizedBox(
      height: 160.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2º Lugar
          Expanded(child: _buildPodiumPlace(topThree[1], 2, 100.h)),
          SizedBox(width: 8.w),
          // 1º Lugar
          Expanded(child: _buildPodiumPlace(topThree[0], 1, 130.h)),
          SizedBox(width: 8.w),
          // 3º Lugar
          Expanded(child: _buildPodiumPlace(topThree[2], 3, 80.h)),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(RankingUser user, int position, double height) {
    final colors = {
      1: const Color(0xFFFFD700), // Ouro
      2: const Color(0xFFC0C0C0), // Prata
      3: const Color(0xFFCD7F32), // Bronze
    };

    final crowns = {
      1: '👑',
      2: '🥈',
      3: '🥉',
    };

    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Avatar e Crown
          Stack(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Color(user.colorTheme),
                  shape: BoxShape.circle,
                  border: Border.all(color: colors[position]!, width: 2.w),
                ),
                child: Center(
                  child: Text(
                    user.codename.split(' ').map((word) => word[0]).join(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -6.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    crowns[position]!,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Nome (usando Flexible para evitar overflow)
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text(
                user.codename,
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          Text(
            'Lv.${user.level}',
            style: TextStyle(
              fontSize: 7.sp,
              color: const Color(0xFF64748B),
            ),
          ),

          SizedBox(height: 4.h),

          // Podium Base
          Container(
            height: height - 65.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors[position]!.withOpacity(0.8),
                  colors[position]!.withOpacity(0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.r),
                topRight: Radius.circular(8.r),
              ),
            ),
            child: Center(
              child: Text(
                '#$position',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard(RankingUser user) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.w),
      ),
      child: Row(
        children: [
          // Position
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: Color(user.colorTheme).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#${user.position}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Color(user.colorTheme),
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Avatar
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: Color(user.colorTheme),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.codename.split(' ').map((word) => word[0]).join(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.codename,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Lv.${user.level} • ${user.totalXP} XP',
                  style: TextStyle(
                    fontSize: 11.sp,
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
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Hoje';
    if (difference == 1) return 'Ontem';
    if (difference < 7) return '${difference}d atrás';
    if (difference < 30) return '${(difference / 7).floor()}sem atrás';
    return '${(difference / 30).floor()}mês atrás';
  }
}
