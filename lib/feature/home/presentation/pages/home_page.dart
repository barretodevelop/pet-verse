// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/model/pet_model.dart';
import 'package:petverse/core/providers/pet_provider.dart';
import 'package:petverse/core/providers/user_provider.dart';
import 'package:petverse/core/theme/app_theme.dart';
import 'package:petverse/core/utils/app_utils.dart';
import 'package:petverse/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:petverse/feature/dashoard/dashboard_page.dart';
import 'package:petverse/feature/minigames/mini_games_bottom_sheet.dart';
import 'package:petverse/feature/shop/presetation/shop.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
    AppUtils.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      appBar: _buildCustomAppBar(),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // Color.fromARGB(255, 186, 212, 245), // Azul muito claro
              Color(0xFFF0F8FF), // Alice blue
              Color(0xFFFFFFFF), // Branco puro
              Color(0xFFF0F8FF), // Alice blue
              Color(0xFFFAF8FF), // Lavanda muito suave
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _selectedIndex = index);
                },
                children: [
                  _buildPetsTabPage(),
                  const DashboardPage(),
                  const ShopPage(),
                  _buildMoreTabPage(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        items: [
          BottomNavItem(icon: Icons.pets, label: 'Pet'),
          BottomNavItem(icon: Icons.dashboard, label: 'Dashboard'),
          BottomNavItem(icon: Icons.store, label: 'Loja'),
          BottomNavItem(icon: Icons.more, label: 'Mais'),
        ],
        // onCenterButtonTap: () => print('Jogos!'),
        onItemTapped: _onItemTapped,
        onCenterButtonPressed: _showGamesBottomSheet,
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    final userAsync = ref.watch(currentUserProvider);

    return PreferredSize(
      preferredSize: Size(double.infinity, 110.h),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 45.h, 20.w, 8.h),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 186, 212, 245), // Azul muito claro
              // Color(0xFFFFFFFF), // Branco puro
              Color(0xFFF0F8FF), // Alice blue
              // Color(0xFFFAF8FF), // Lavanda muito suave
            ],
            stops: [0.0, 0.7],
          ),
        ),
        child: Column(
          children: [
            // Primeira linha - Avatar, Saudação e Ações
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
                        child: userAsync.when(
                          data: (user) => user?.avatarUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    user!.avatarUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                          loading: () => Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          error: (_, __) => Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -1.h,
                      right: -1.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: Colors.white, width: 1.w),
                        ),
                        child: Text(
                          '12',
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
                        userAsync.when(
                          data: (user) =>
                              'Olá, ${user?.displayName ?? 'Jogador'}!',
                          loading: () => 'Carregando...',
                          error: (_, __) => 'Olá, Jogador!',
                        ),
                        style: TextStyle(
                          fontSize: 17.sp,
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
                    _buildHeaderActionButton(
                      Icons.emoji_events_outlined,
                      AppTheme.warning,
                      () => AppUtils.lightImpact(),
                    ),
                    SizedBox(width: 8.w),
                    _buildHeaderActionButton(
                      Icons.notifications_outlined,
                      AppTheme.primarySoft,
                      () => AppUtils.lightImpact(),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Segunda linha - Recursos do usuário
            Row(
              children: [
                // Level
                _buildResourceChip(
                  icon: '⭐',
                  label: 'LEVEL',
                  value: '12',
                  color: const Color(0xFFEC4899),
                ),
                SizedBox(width: 6.w),
                // Coins
                _buildResourceChip(
                  icon: '🪙',
                  label: 'COINS',
                  value: '1,500',
                  color: const Color(0xFFF59E0B),
                ),
                SizedBox(width: 6.w),
                // Gems
                _buildResourceChip(
                  icon: '💎',
                  label: 'GEMS',
                  value: '45',
                  color: const Color(0xFF06B6D4),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
    );
  }

  Widget _buildResourceChip({
    required String icon,
    required String value,
    required Color color,
    String? label,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: 12.sp),
            ),
            SizedBox(width: 4.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label != null)
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderActionButton(
      IconData icon, Color color, VoidCallback onTap) {
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

  Widget _buildPetsTabPage() {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user?.hasPet == true) {
          return _buildPetStatusCard(user!.currentPetId!);
        } else {
          return _buildAdoptPetCard();
        }
      },
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState(),
    );
  }

  Widget _buildPetStatusCard(String petId) {
    final petAsync = ref.watch(petByIdProvider(petId));

    return petAsync.when(
      data: (pet) => pet != null ? _buildPetCard(pet) : _buildNoPetCard(),
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState(),
    );
  }

  Widget _buildPetCard(PetModel pet) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.primarySoft.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primarySoft.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pet Image
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatController.value * 8),
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primarySoft.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      pet.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.pets,
                            size: 60.sp,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 20.h),

          // Pet Name
          Text(
            pet.name,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),

          SizedBox(height: 8.h),

          // Pet Info
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppTheme.accentCoral.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '${pet.breed} • ${pet.type}',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.accentCoral,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Stats
          Column(
            children: [
              _buildStatBar(
                  'Felicidade', pet.happiness, AppTheme.accentCoral, '❤️'),
              SizedBox(height: 12.h),
              _buildStatBar('Saúde', pet.health, AppTheme.success, '🏥'),
              SizedBox(height: 12.h),
              _buildStatBar('Energia', pet.energy, AppTheme.warning, '⚡'),
            ],
          ),

          SizedBox(height: 24.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildPetActionButton(
                  'Alimentar',
                  Icons.restaurant,
                  AppTheme.accentCoral,
                  () => AppUtils.mediumImpact(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildPetActionButton(
                  'Brincar',
                  Icons.sports_tennis,
                  AppTheme.primarySoft,
                  () => AppUtils.mediumImpact(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildPetActionButton(
                  'Cuidar',
                  Icons.medical_services,
                  AppTheme.success,
                  () => AppUtils.mediumImpact(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int value, Color color, String emoji) {
    return Row(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 16.sp),
        ),
        SizedBox(width: 8.w),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            height: 8.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '$value%',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPetActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLojaTabPage() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Text(
            'Loja do Pet',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store,
                    size: 80.sp,
                    color: AppTheme.warning,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Loja de Itens',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Compre comida, brinquedos e\nacessórios para seu pet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      // color: AppTheme.textSecundary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreTabPage() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Text(
            'Mais Opções',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.more_horiz,
                    size: 80.sp,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Configurações e Mais',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Perfil, configurações, suporte\ne outras funcionalidades',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdoptPetCard() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Card informativo - altura controlada
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: 120.h,
                  maxHeight: 210.h,
                ),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF8FAFC), // Branco azulado
                      Color(0xFFF1F5F9), // Cinza azulado muito claro
                      Color(0xFFE2E8F0), // Cinza claro
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFFCBD5E1).withOpacity(0.3),
                    width: 1.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF64748B).withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFF94A3B8).withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícone do pet - centralizado
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF60A5FA), // Azul claro
                            Color(0xFF3B82F6), // Azul médio
                            Color(0xFF2563EB), // Azul escuro
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.pets_rounded,
                        size: 30.sp,
                        color: Colors.white,
                      ),
                    )
                        .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.08, 1.08),
                          duration: 2500.ms,
                        )
                        .shimmer(
                          delay: 1200.ms,
                          duration: 1800.ms,
                          color: Colors.white.withOpacity(0.4),
                        ),

                    SizedBox(height: 12.h),

                    // Título
                    Text(
                      'Adote um Pet',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    )
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 800.ms)
                        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),

                    SizedBox(height: 6.h),

                    // Descrição
                    Text(
                      'Encontre seu companheiro perfeito\ne transforme duas vidas para sempre',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                        .animate(delay: 500.ms)
                        .fadeIn(duration: 800.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 1000.ms)
                  .slideY(begin: -0.2, end: 0, curve: Curves.easeOutCubic),

              SizedBox(height: 16.h),

              // Botões - altura controlada
              ...List.generate(3, (index) {
                final buttons = [
                  {
                    'text': 'Ver Pets Disponíveis',
                    'subtitle': 'pets disponiveis para adoção compartilhada',
                    'icon': Icons.pets_outlined,
                    'gradient': const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                    ),
                    'onTap': () {
                      AppUtils.mediumImpact();
                      context.push('/list-adoption');
                    },
                  },
                  {
                    'text': 'Criar uma Adoção',
                    'subtitle':
                        'Após sua escolha, o pet aguardará a aprovação da segunda pessoa para a adoção.',
                    'icon': Icons.add_circle_outline,
                    'gradient': const LinearGradient(
                      colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                    ),
                    'onTap': () {
                      AppUtils.mediumImpact();
                      context.push('/create-adoption');
                    },
                  },
                  {
                    'text': 'Convidar Amigo',
                    'subtitle':
                        'Aqui você convida uma amigo pra fazer a adoção conjunta com voce.',
                    'icon': Icons.share_outlined,
                    'gradient': const LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    ),
                    'onTap': () {
                      AppUtils.mediumImpact();
                      _showShareBottomSheet();
                    },
                  },
                ];

                return Column(
                  children: [
                    _buildActionButton(
                      onTap: buttons[index]['onTap'] as VoidCallback,
                      text: buttons[index]['text'] as String,
                      subtitle: buttons[index]['subtitle'] as String,
                      icon: buttons[index]['icon'] as IconData,
                      gradient: buttons[index]['gradient'] as Gradient,
                      delay: 700 + (index * 150),
                    ),
                    if (index < 2) SizedBox(height: 10.h),
                  ],
                );
              }),

              // Espaço final para evitar overlap com bottom navigator
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required String text,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFFAFBFC),
              Color(0xFFF8FAFC),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: gradient.colors.first.withOpacity(0.15),
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone com gradiente
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24.sp,
              ),
            ),

            SizedBox(width: 16.w),

            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Seta com gradiente
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                gradient: gradient.colors.first.withOpacity(0.1) != null
                    ? LinearGradient(
                        colors: [
                          gradient.colors.first.withOpacity(0.1),
                          gradient.colors.first.withOpacity(0.05),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: gradient.colors.first.withOpacity(0.7),
                size: 16.sp,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 800.ms)
        .slideX(begin: 0.4, end: 0, curve: Curves.easeOutCubic)
        .then()
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .shimmer(
          delay: Duration(milliseconds: delay + 2500),
          duration: 2500.ms,
          color: gradient.colors.first.withOpacity(0.08),
        );
  }

  void _showShareBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFFAFBFC),
            ],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(top: 12.h, bottom: 24.h),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Título
            Text(
              'Convidar Amigo',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),

            SizedBox(height: 12.h),

            // Descrição
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                'Compartilhe a alegria de adotar um pet com seus amigos e façam uma adoção conjunta!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Botões de compartilhamento
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Row(
                children: [
                  Expanded(
                    child: _buildShareButton(
                      onTap: () {
                        Navigator.pop(context);
                        AppUtils.mediumImpact();
                        // Implementar compartilhamento WhatsApp
                      },
                      icon: Icons.chat_bubble_outline,
                      text: 'WhatsApp',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _buildShareButton(
                      onTap: () {
                        Navigator.pop(context);
                        AppUtils.mediumImpact();
                        // Implementar compartilhamento geral
                      },
                      icon: Icons.share_outlined,
                      text: 'Outros',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF64748B), Color(0xFF475569)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().slideY(
          begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildShareButton({
    required VoidCallback onTap,
    required IconData icon,
    required String text,
    required Gradient gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGamesBottomSheet() {
    MinigamesBottomSheet.show(context);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60.w,
            height: 60.w,
            child: CircularProgressIndicator(
              color: AppTheme.primarySoft,
              strokeWidth: 3.w,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Carregando...',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: AppTheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Algo deu errado',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              AppUtils.mediumImpact();
              ref.refresh(currentUserProvider);
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPetCard() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pets,
              size: 80.sp,
              color: AppTheme.textLight,
            ),
            SizedBox(height: 16.h),
            Text(
              'Pet não encontrado',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Não foi possível carregar\nas informações do seu pet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () {
                AppUtils.lightImpact();
                ref.refresh(currentUserProvider);
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
