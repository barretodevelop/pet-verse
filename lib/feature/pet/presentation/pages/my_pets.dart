import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/model/mocks.dart';
import 'package:petverse/feature/pet/presentation/pages/pet_page.dart';

// Providers
final myPetsProvider =
    StateNotifierProvider<MyPetsNotifier, MyPetsState>((ref) {
  return MyPetsNotifier();
});

final petsFilterProvider = StateProvider<String>((ref) => 'Todos');

// Navigation Service
class NavigationService {
  static void navigateToPetPage(
      BuildContext context, MockPet pet, AnonymousAdoption adoption,
      {bool isNewlyAdopted = false}) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetPage(
          pet: pet,
          adoption: adoption,
          isNewlyAdopted: isNewlyAdopted,
        ),
      ),
    );
  }
}

// State
class MyPetsState {
  final bool isLoading;
  final List<Map<String, dynamic>> allPets;
  final Map<String, dynamic> currentUser;
  final String errorMessage;

  MyPetsState({
    required this.isLoading,
    required this.allPets,
    required this.currentUser,
    required this.errorMessage,
  });

  MyPetsState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? allPets,
    Map<String, dynamic>? currentUser,
    String? errorMessage,
  }) {
    return MyPetsState(
      isLoading: isLoading ?? this.isLoading,
      allPets: allPets ?? this.allPets,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  List<Map<String, dynamic>> getFilteredPets(String filter) {
    switch (filter) {
      case 'Atenção':
        return allPets.where((pet) => pet['needsAttention'] == true).toList();
      case 'Felizes':
        return allPets.where((pet) => pet['happiness'] >= 80).toList();
      case 'Energia Baixa':
        return allPets.where((pet) => pet['energy'] <= 50).toList();
      case 'Com Fome':
        return allPets.where((pet) => pet['hunger'] >= 70).toList();
      case 'Saudáveis':
        return allPets.where((pet) => pet['health'] >= 90).toList();
      default:
        return allPets;
    }
  }
}

// Notifier
class MyPetsNotifier extends StateNotifier<MyPetsState> {
  MyPetsNotifier()
      : super(MyPetsState(
          isLoading: true,
          allPets: [],
          currentUser: {},
          errorMessage: '',
        )) {
    _loadMyPets();
  }

  Future<void> _loadMyPets() async {
    await Future.delayed(const Duration(seconds: 1));

    state = state.copyWith(
      isLoading: false,
      allPets: _generateAllMyPets(),
      currentUser: _getCurrentUser(),
    );
  }

  Map<String, dynamic> _getCurrentUser() {
    return {
      'codename': 'Guardian Azul',
      'level': 12,
      'colorTheme': 0xFF3B82F6,
      'successRate': 94,
      'totalAdoptions': 15,
    };
  }

  List<Map<String, dynamic>> _generateAllMyPets() {
    return [
      {
        'pet': MockPet(
          name: 'Luna',
          type: 'Gato',
          age: '2 anos',
          photo: '🐱',
          traits: ['carinhoso', 'brincalhão', 'independente'],
          description:
              'Luna é uma gatinha muito carinhosa que adora brincar com bolinhas',
        ),
        'adoption': AnonymousAdoption(
          missionId: 'ADT_001',
          codename: 'Protetor Rosa',
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
        ),
        'happiness': 85,
        'health': 92,
        'energy': 78,
        'hunger': 35,
        'needsAttention': false,
        'lastActivity': '2h atrás',
        'adoptedAt': '15 dias atrás',
        'dailyStreak': 12,
      },
      {
        'pet': MockPet(
          name: 'Max',
          type: 'Cachorro',
          age: '3 anos',
          photo: '🐕',
          traits: ['leal', 'energético', 'protetor'],
          description:
              'Max é um cachorro muito leal e cheio de energia, adora correr no parque',
        ),
        'adoption': AnonymousAdoption(
          missionId: 'ADT_002',
          codename: 'Anjo Verde',
          colorTheme: 0xFF10B981,
          level: 20,
          badges: ['veteran', 'dog_whisperer'],
          successRate: 98,
          completedAdoptions: 32,
          currentStreak: 12,
          region: 'Zona Norte - SP',
          views: 89,
          interested: 23,
          potentialMatches: 7,
          timeLeftDays: 0.8,
          pets: [],
          codedMessage: 'Veterano experiente',
          personalityTags: ['experiente', 'paciente'],
          status: 'normal',
          isNew: false,
        ),
        'happiness': 72,
        'health': 88,
        'energy': 45,
        'hunger': 85,
        'needsAttention': true,
        'lastActivity': '30min atrás',
        'adoptedAt': '8 dias atrás',
        'dailyStreak': 7,
      },
      {
        'pet': MockPet(
          name: 'Bella',
          type: 'Coelho',
          age: '1 ano',
          photo: '🐰',
          traits: ['fofo', 'tranquilo', 'tímido'],
          description:
              'Bella é uma coelhinha muito fofa e tranquila, adora cenouras',
        ),
        'adoption': AnonymousAdoption(
          missionId: 'ADT_003',
          codename: 'Sábio Dourado',
          colorTheme: 0xFFEAB308,
          level: 30,
          badges: ['master', 'golden_heart'],
          successRate: 100,
          completedAdoptions: 67,
          currentStreak: 25,
          region: 'Interior - SP',
          views: 89,
          interested: 12,
          potentialMatches: 4,
          timeLeftDays: 4.7,
          pets: [],
          codedMessage: 'Mestre experiente',
          personalityTags: ['mestre', 'sábio'],
          status: 'normal',
          isNew: false,
        ),
        'happiness': 95,
        'health': 98,
        'energy': 90,
        'hunger': 25,
        'needsAttention': false,
        'lastActivity': '1h atrás',
        'adoptedAt': '22 dias atrás',
        'dailyStreak': 20,
      },
      {
        'pet': MockPet(
          name: 'Charlie',
          type: 'Cachorro',
          age: '4 anos',
          photo: '🐕',
          traits: ['amigável', 'obediente', 'calmo'],
          description:
              'Charlie é um cachorro muito amigável e obediente, perfeito para famílias',
        ),
        'adoption': AnonymousAdoption(
          missionId: 'ADT_004',
          codename: 'Protetor Coral',
          colorTheme: 0xFFFF6B6B,
          level: 10,
          badges: ['dog_lover'],
          successRate: 87,
          completedAdoptions: 12,
          currentStreak: 4,
          region: 'Zona Norte - RJ',
          views: 32,
          interested: 9,
          potentialMatches: 2,
          timeLeftDays: 2.1,
          pets: [],
          codedMessage: 'Guardian dedicado',
          personalityTags: ['ativo', 'dedicado'],
          status: 'normal',
          isNew: false,
        ),
        'happiness': 88,
        'health': 85,
        'energy': 92,
        'hunger': 40,
        'needsAttention': false,
        'lastActivity': '45min atrás',
        'adoptedAt': '5 dias atrás',
        'dailyStreak': 5,
      },
      {
        'pet': MockPet(
          name: 'Mimi',
          type: 'Gato',
          age: '6 meses',
          photo: '🐱',
          traits: ['filhote', 'curioso', 'brincalhão'],
          description: 'Mimi é uma gatinha filhote muito curiosa e brincalhona',
        ),
        'adoption': AnonymousAdoption(
          missionId: 'ADT_005',
          codename: 'Guardião Laranja',
          colorTheme: 0xFFF97316,
          level: 16,
          badges: ['pet_whisperer'],
          successRate: 96,
          completedAdoptions: 24,
          currentStreak: 8,
          region: 'Centro - SP',
          views: 67,
          interested: 18,
          potentialMatches: 5,
          timeLeftDays: 1.2,
          pets: [],
          codedMessage: 'Especialista em filhotes',
          personalityTags: ['especialista', 'paciente'],
          status: 'normal',
          isNew: false,
        ),
        'happiness': 68,
        'health': 95,
        'energy': 35,
        'hunger': 75,
        'needsAttention': true,
        'lastActivity': '15min atrás',
        'adoptedAt': '3 dias atrás',
        'dailyStreak': 3,
      },
    ];
  }

  void refreshPets() {
    state = state.copyWith(isLoading: true);
    _loadMyPets();
  }

  void updatePetStats(String petName, Map<String, int> newStats) {
    final updatedPets = state.allPets.map((petData) {
      if ((petData['pet'] as MockPet).name == petName) {
        final updatedPetData = Map<String, dynamic>.from(petData);
        newStats.forEach((key, value) {
          updatedPetData[key] = value;
        });
        updatedPetData['lastActivity'] = 'Agora';
        updatedPetData['needsAttention'] = _needsAttention(updatedPetData);
        return updatedPetData;
      }
      return petData;
    }).toList();

    state = state.copyWith(allPets: updatedPets);
  }

  bool _needsAttention(Map<String, dynamic> petData) {
    return petData['hunger'] >= 80 ||
        petData['energy'] <= 30 ||
        petData['health'] <= 60 ||
        petData['happiness'] <= 50;
  }
}

class MyPetsPage extends ConsumerWidget {
  const MyPetsPage({super.key});

  void _onPetTap(BuildContext context, Map<String, dynamic> petData) {
    final pet = petData['pet'] as MockPet;
    final adoption = petData['adoption'] as AnonymousAdoption;
    NavigationService.navigateToPetPage(context, pet, adoption);
  }

  void _onQuickCare(BuildContext context, WidgetRef ref, String action) {
    HapticFeedback.lightImpact();

    final myPetsNotifier = ref.read(myPetsProvider.notifier);
    final petsState = ref.read(myPetsProvider);

    String message = '';
    int petsCared = 0;

    for (final petData in petsState.allPets) {
      final pet = petData['pet'] as MockPet;
      Map<String, int> updates = {};

      switch (action) {
        case 'feed_all':
          if (petData['hunger'] > 20) {
            updates['hunger'] = (petData['hunger'] - 30).clamp(0, 100);
            updates['happiness'] = (petData['happiness'] + 5).clamp(0, 100);
            petsCared++;
          }
          break;
        case 'play_all':
          if (petData['energy'] > 20) {
            updates['energy'] = (petData['energy'] - 20).clamp(0, 100);
            updates['happiness'] = (petData['happiness'] + 10).clamp(0, 100);
            petsCared++;
          }
          break;
        case 'rest_all':
          if (petData['energy'] < 80) {
            updates['energy'] = (petData['energy'] + 25).clamp(0, 100);
            petsCared++;
          }
          break;
      }

      if (updates.isNotEmpty) {
        myPetsNotifier.updatePetStats(pet.name, updates);
      }
    }

    switch (action) {
      case 'feed_all':
        message = 'Alimentou $petsCared pets! 🍖';
        break;
      case 'play_all':
        message = 'Brincou com $petsCared pets! 🎾';
        break;
      case 'rest_all':
        message = '$petsCared pets estão descansando! 😴';
        break;
    }

    if (petsCared > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPetsState = ref.watch(myPetsProvider);
    final currentFilter = ref.watch(petsFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, ref),
      body: myPetsState.isLoading
          ? _buildLoadingState()
          : _buildContent(context, ref, myPetsState, currentFilter),
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
        'Meus Pets',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => ref.read(myPetsProvider.notifier).refreshPets(),
          icon: Icon(
            Icons.refresh,
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
              Icons.pets,
              color: const Color(0xFF3B82F6),
              size: 40.sp,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 2000.ms),
          SizedBox(height: 24.h),
          Text(
            'Carregando seus pets...',
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

  Widget _buildContent(BuildContext context, WidgetRef ref, MyPetsState state,
      String currentFilter) {
    final filteredPets = state.getFilteredPets(currentFilter);

    return Column(
      children: [
        _buildQuickActions(context, ref, state),
        _buildFilters(ref, currentFilter, state),
        _buildStats(state, filteredPets),
        Expanded(
          child: filteredPets.isEmpty
              ? _buildEmptyState(currentFilter)
              : _buildPetsList(context, filteredPets),
        ),
      ],
    );
  }

  Widget _buildQuickActions(
      BuildContext context, WidgetRef ref, MyPetsState state) {
    final needsAttentionCount =
        state.allPets.where((pet) => pet['needsAttention'] == true).length;

    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(16.w),
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
          Row(
            children: [
              Text(
                'Cuidados Rápidos',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              if (needsAttentionCount > 0) ...[
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '$needsAttentionCount precisam de atenção',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(context, ref, 'Alimentar Todos',
                    Icons.restaurant, const Color(0xFFF59E0B), 'feed_all'),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildQuickActionButton(context, ref, 'Brincar',
                    Icons.sports_tennis, const Color(0xFF3B82F6), 'play_all'),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildQuickActionButton(context, ref, 'Descansar',
                    Icons.bedtime, const Color(0xFF8B5CF6), 'rest_all'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, WidgetRef ref,
      String title, IconData icon, Color color, String action) {
    return GestureDetector(
      onTap: () => _onQuickCare(context, ref, action),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.w,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20.sp),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(WidgetRef ref, String currentFilter, MyPetsState state) {
    final filters = [
      'Todos',
      'Atenção',
      'Felizes',
      'Energia Baixa',
      'Com Fome',
      'Saudáveis'
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = currentFilter == filter;
          final count = state.getFilteredPets(filter).length;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(petsFilterProvider.notifier).state = filter;
            },
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFE2E8F0),
                  width: 1.w,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                  if (count > 0) ...[
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : const Color(0xFF3B82F6).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats(
      MyPetsState state, List<Map<String, dynamic>> filteredPets) {
    final totalPets = state.allPets.length;
    final happyPets =
        state.allPets.where((pet) => pet['happiness'] >= 80).length;
    final needsAttention =
        state.allPets.where((pet) => pet['needsAttention'] == true).length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
              child: _buildStatCard(
                  'Total', '$totalPets', const Color(0xFF3B82F6))),
          SizedBox(width: 8.w),
          Expanded(
              child: _buildStatCard(
                  'Felizes', '$happyPets', const Color(0xFF10B981))),
          SizedBox(width: 8.w),
          Expanded(
              child: _buildStatCard(
                  'Atenção', '$needsAttention', const Color(0xFFEF4444))),
          SizedBox(width: 8.w),
          Expanded(
              child: _buildStatCard('Filtrados', '${filteredPets.length}',
                  const Color(0xFFF59E0B))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
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
              fontSize: 16.sp,
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
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: const Color(0xFF64748B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets_outlined,
              color: const Color(0xFF64748B),
              size: 40.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            filter == 'Todos'
                ? 'Nenhum pet encontrado'
                : 'Nenhum pet em "$filter"',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            filter == 'Todos'
                ? 'Adote seu primeiro pet!'
                : 'Tente alterar o filtro',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList(BuildContext context, List<Map<String, dynamic>> pets) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        return _buildPetCard(context, pets[index], index);
      },
    );
  }

  Widget _buildPetCard(
      BuildContext context, Map<String, dynamic> petData, int index) {
    final pet = petData['pet'] as MockPet;
    final adoption = petData['adoption'] as AnonymousAdoption;
    final needsAttention = petData['needsAttention'] as bool;

    return GestureDetector(
      onTap: () => _onPetTap(context, petData),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
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
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Pet Photo
                Stack(
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        color: Color(adoption.colorTheme).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(adoption.colorTheme).withOpacity(0.3),
                          width: 2.w,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          pet.photo,
                          style: TextStyle(fontSize: 28.sp),
                        ),
                      ),
                    ),
                    if (needsAttention)
                      Positioned(
                        top: -2.h,
                        right: -2.w,
                        child: Container(
                          width: 16.w,
                          height: 16.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.priority_high,
                            color: Colors.white,
                            size: 10.sp,
                          ),
                        )
                            .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true))
                            .scale(
                              begin: const Offset(1.0, 1.0),
                              end: const Offset(1.2, 1.2),
                              duration: 1000.ms,
                            ),
                      ),
                  ],
                ),

                SizedBox(width: 16.w),

                // Pet Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pet.name,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color:
                                  Color(adoption.colorTheme).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              pet.type,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(adoption.colorTheme),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${pet.age} • ${petData['lastActivity']}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            'Co-guardião: ',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            adoption.codename,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(adoption.colorTheme),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Indicator
                Column(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: _getPetMoodColor(petData),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${petData['dailyStreak']}d',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Stats Bars
            Row(
              children: [
                Expanded(
                    child: _buildStatBar(
                        '😊', petData['happiness'], const Color(0xFFF59E0B))),
                SizedBox(width: 8.w),
                Expanded(
                    child: _buildStatBar(
                        '❤️', petData['health'], const Color(0xFF10B981))),
                SizedBox(width: 8.w),
                Expanded(
                    child: _buildStatBar(
                        '⚡', petData['energy'], const Color(0xFF3B82F6))),
                SizedBox(width: 8.w),
                Expanded(
                    child: _buildStatBar(
                        '🍖',
                        (100 - petData['hunger']).toInt(),
                        const Color(0xFF8B5CF6))),
              ],
            ),

            if (needsAttention) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: const Color(0xFFEF4444),
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _getAttentionMessage(petData),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildStatBar(String emoji, int value, Color color) {
    return Column(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 12.sp),
        ),
        SizedBox(height: 2.h),
        Container(
          height: 4.h,
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
        ),
        SizedBox(height: 2.h),
        Text(
          '$value%',
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getPetMoodColor(Map<String, dynamic> petData) {
    final avgMood = (petData['happiness'] +
            petData['health'] +
            petData['energy'] -
            petData['hunger']) /
        3;
    if (avgMood >= 80) return const Color(0xFF10B981);
    if (avgMood >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _getAttentionMessage(Map<String, dynamic> petData) {
    if (petData['hunger'] >= 80) return 'Está com muita fome!';
    if (petData['energy'] <= 30) return 'Precisa descansar';
    if (petData['health'] <= 60) return 'Precisa de cuidados médicos';
    if (petData['happiness'] <= 50) return 'Está triste, precisa de carinho';
    return 'Precisa de atenção';
  }
}
