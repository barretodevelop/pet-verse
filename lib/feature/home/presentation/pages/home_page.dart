// lib/feature/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/model/firebase_pet_model.dart';
import 'package:petverse/core/model/pet_model.dart';
import 'package:petverse/core/providers/active_request_provider.dart';
import 'package:petverse/core/providers/app_state_provider.dart';
import 'package:petverse/core/providers/firebase_adoption_provider.dart';
import 'package:petverse/core/providers/pet_provider.dart';
import 'package:petverse/core/theme/app_theme.dart';
import 'package:petverse/core/utils/app_utils.dart';
import 'package:petverse/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:petverse/core/widgets/resource_chip.dart' hide AppTheme;
import 'package:petverse/feature/auth/providers/authentication_provider.dart';
import 'package:petverse/feature/dashoard/dashboard_page.dart';
import 'package:petverse/feature/home/presentation/widgets/adoption_options_widget.dart';
import 'package:petverse/feature/minigames/mini_games_bottom_sheet.dart';
import 'package:petverse/feature/mission/anonymous_mission_list_page.dart';

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
    // Observa o estado da UI para determinar o que mostrar
    final uiState = ref.watch(uiStateProvider);

    // Se está carregando, mostra loading
    if (uiState.isLoading) {
      return _buildLoadingScreen();
    }

    // Se não está autenticado, não deveria estar aqui (GoRouter deve redirecionar)
    if (!uiState.isAuthenticated) {
      return _buildErrorScreen('Usuário não autenticado');
    }

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
                  const AnonymousAdoptionsListPage(),
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
          BottomNavItem(icon: Icons.model_training_sharp, label: 'Missoes'),
          BottomNavItem(icon: Icons.more, label: 'Mais'),
        ],
        onItemTapped: _onItemTapped,
        onCenterButtonPressed: _showGamesBottomSheet,
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: Center(
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
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: Center(
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
              'Erro',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                AppUtils.mediumImpact();
                context.go('/auth/login');
              },
              child: const Text('Fazer Login'),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    final authState = ref.watch(authenticationNotifierProvider);
    final user = authState.userModel;

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
              Color(0xFFF0F8FF), // Alice blue
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
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

            SizedBox(height: 8.h),

            // Segunda linha - Recursos do usuário
            Row(
              children: [
                // Level
                ResourceChip(
                  icon: '⭐',
                  label: 'LEVEL',
                  value: '${user?.level ?? 1}',
                  color: const Color(0xFFEC4899),
                ),
                SizedBox(width: 6.w),
                // Coins
                ResourceChip(
                  icon: '🪙',
                  label: 'COINS',
                  value: '${user?.coins ?? 0}',
                  color: const Color(0xFFF59E0B),
                ),
                SizedBox(width: 6.w),
                // Gems
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
      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
    );
  }

  // Widget _buildResourceChip({
  //   required String icon,
  //   required String value,
  //   required Color color,
  //   String? label,
  // }) {
  //   return Expanded(
  //     child: Container(
  //       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(10.r),
  //         border: Border.all(
  //           color: color.withOpacity(0.2),
  //           width: 1.w,
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: color.withOpacity(0.08),
  //             blurRadius: 4,
  //             offset: const Offset(0, 1),
  //           ),
  //         ],
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text(
  //             icon,
  //             style: TextStyle(fontSize: 12.sp),
  //           ),
  //           SizedBox(width: 4.w),
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               if (label != null)
  //                 Text(
  //                   label,
  //                   style: TextStyle(
  //                     color: color,
  //                     fontSize: 8.sp,
  //                     fontWeight: FontWeight.w600,
  //                     letterSpacing: 0.3,
  //                   ),
  //                 ),
  //               Text(
  //                 value,
  //                 style: TextStyle(
  //                   color: AppTheme.textPrimary,
  //                   fontSize: 11.sp,
  //                   fontWeight: FontWeight.w700,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
    final hasActivePet = ref.watch(hasActivePetProvider);
    final activePetId = ref.watch(activePetIdProvider);
    final authState = ref.watch(authenticationNotifierProvider);
    final user = authState.userModel;

    // NEW: Verificar se tem solicitação ativa
    final activeRequestAsync = ref.watch(watchUserActiveRequestProvider);

    return activeRequestAsync.when(
      data: (activeRequest) {
        // Se tem solicitação ativa, mostrar status
        if (activeRequest != null) {
          return _buildActiveRequestCard(activeRequest);
        }

        // Se tem pet ativo, mostrar pet
        if (hasActivePet && activePetId != null) {
          return _buildPetStatusCard(activePetId);
        }

        // Senão, mostrar opções de adoção
        if (user != null) {
          return AdoptionOptionsWidget(user: user);
        }

        return _buildLoadingState();
      },
      loading: () => _buildLoadingState(),
      error: (_, __) {
        // Em caso de erro, mostrar interface normal
        if (hasActivePet && activePetId != null) {
          return _buildPetStatusCard(activePetId);
        } else if (user != null) {
          return AdoptionOptionsWidget(user: user);
        } else {
          return _buildLoadingState();
        }
      },
    );
  }

// NEW: Widget para mostrar solicitação ativa
  Widget _buildActiveRequestCard(CollaborativeAdoptionRequest activeRequest) {
    final petsAsync = ref.watch(userActiveRequestPetsProvider);

    return Container(
      margin: EdgeInsets.all(20.w),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header da solicitação
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(activeRequest.requesterColorTheme).withOpacity(0.1),
                    Color(activeRequest.requesterColorTheme).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color:
                      Color(activeRequest.requesterColorTheme).withOpacity(0.3),
                  width: 2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(activeRequest.requesterColorTheme)
                        .withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Status icon
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(activeRequest.requesterColorTheme),
                          Color(activeRequest.requesterColorTheme)
                              .withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(activeRequest.requesterColorTheme)
                              .withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.schedule,
                      size: 40.sp,
                      color: Colors.white,
                    ),
                  )
                      .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.1, 1.1),
                        duration: 2000.ms,
                      ),

                  SizedBox(height: 20.h),

                  // Título
                  Text(
                    'Solicitação Ativa',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Tempo restante
                  Text(
                    'Expira em ${activeRequest.daysRemaining.toStringAsFixed(1)} dias',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: activeRequest.isUrgent
                          ? const Color(0xFFEF4444)
                          : Color(activeRequest.requesterColorTheme),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Stats da solicitação
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat(
                          '👁️', '${activeRequest.views}', 'Visualizações'),
                      _buildStat(
                          '❤️', '${activeRequest.interested}', 'Interessados'),
                      _buildStat('🎯', '${activeRequest.selectedPetIds.length}',
                          'Pets'),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Pets da solicitação
            petsAsync.when(
              data: (pets) => _buildRequestPetsList(pets, activeRequest),
              loading: () => _buildPetsLoading(),
              error: (_, __) => _buildPetsError(),
            ),

            SizedBox(height: 20.h),

            // Ações
            _buildRequestActions(activeRequest),
          ],
        ),
      ),
    );
  }

// Helper para stats
  Widget _buildStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 20.sp)),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

// Lista de pets da solicitação
  Widget _buildRequestPetsList(
      List<FirebasePetModel> pets, CollaborativeAdoptionRequest request) {
    if (pets.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          'Erro ao carregar pets da solicitação',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Text(
              'Seus Pets Selecionados',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          ...pets.asMap().entries.map((entry) {
            final index = entry.key;
            final pet = entry.value;

            return Container(
              margin: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                bottom: index == pets.length - 1 ? 20.w : 12.w,
              ),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Color(request.requesterColorTheme).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Color(request.requesterColorTheme).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  // Pet emoji
                  Text(
                    pet.photo,
                    style: TextStyle(fontSize: 32.sp),
                  ),

                  SizedBox(width: 16.w),

                  // Pet info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          '${pet.breed} • ${pet.age}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'ATIVO',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

// Loading para pets
  Widget _buildPetsLoading() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

// Erro para pets
  Widget _buildPetsError() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        'Erro ao carregar pets',
        style: TextStyle(
          fontSize: 14.sp,
          color: const Color(0xFFEF4444),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

// Ações da solicitação
  Widget _buildRequestActions(CollaborativeAdoptionRequest request) {
    return Column(
      children: [
        // Botão para ver na lista
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              AppUtils.lightImpact();
              context.push('/list-adoption');
            },
            icon: const Icon(Icons.list),
            label: const Text('Ver na Lista Pública'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(request.requesterColorTheme),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),

        SizedBox(height: 12.h),

        // Botão para cancelar
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showCancelRequestDialog(request),
            icon: const Icon(Icons.close),
            label: const Text('Cancelar Solicitação'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              side: const BorderSide(color: Color(0xFFEF4444)),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

// Dialog para cancelar solicitação
  void _showCancelRequestDialog(CollaborativeAdoptionRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Solicitação'),
        content: const Text(
          'Tem certeza que deseja cancelar sua solicitação de adoção? '
          'Esta ação não pode ser desfeita e você precisará criar uma nova solicitação.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelRequest(request.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Sim, Cancelar'),
          ),
        ],
      ),
    );
  }

// Cancelar solicitação
  Future<void> _cancelRequest(String requestId) async {
    try {
      await ref
          .read(firebaseAdoptionNotifierProvider.notifier)
          .cancelAdoptionRequest(requestId);

      // Invalidar providers para atualizar UI
      ref.invalidate(userActiveRequestProvider);
      ref.invalidate(publicAdoptionRequestsFirebaseProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitação cancelada com sucesso'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cancelar: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
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
              ref
                  .read(authenticationNotifierProvider.notifier)
                  .refreshUserModel();
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
                ref
                    .read(authenticationNotifierProvider.notifier)
                    .refreshUserModel();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
