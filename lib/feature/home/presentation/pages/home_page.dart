// lib/feature/home/presentation/pages/home_page.dart
// ATUALIZADO: HomePage refatorada para usar UnifiedUserStateProvider
// Remove lógica espalhada e centraliza decisão do que exibir

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/firebase_pet_model.dart';
import 'package:petverse/core/model/user_model.dart';
import 'package:petverse/core/providers/unified_user_state_provider.dart';
import 'package:petverse/core/services/adoption_flow_service.dart';
import 'package:petverse/core/theme/app_theme.dart';
import 'package:petverse/core/utils/app_utils.dart';
import 'package:petverse/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:petverse/feature/dashoard/dashboard_page.dart';
import 'package:petverse/feature/home/presentation/widgets/custom_app_bar.dart';
import 'package:petverse/feature/home/presentation/widgets/loading_error_screens.dart';
import 'package:petverse/feature/home/presentation/widgets/more_ptions_tab_page.dart';
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

    // Verificar e reparar estado na inicialização
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdoptionFlowService.verifyAndRepairState(ref: ref);
    });
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

  void _showGamesBottomSheet() {
    MinigamesBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    // NOVO: Usar provider unificado para determinar o que exibir
    final unifiedState = ref.watch(unifiedUserStateProvider);

    // Debug info em desenvolvimento
    debugPrint(
        '🏠 HomePage render: ${unifiedState.flow}, transition: ${unifiedState.transitionState}');

    // Mostrar diferentes telas baseado no fluxo unificado
    return _buildScaffoldForFlow(unifiedState);
  }

  Widget _buildScaffoldForFlow(UnifiedUserState state) {
    switch (state.flow) {
      case AppFlow.loading:
        return _buildLoadingScaffold();

      case AppFlow.unauthenticated:
        return _buildUnauthenticatedScaffold();

      case AppFlow.error:
        return _buildErrorScaffold(state.error ?? 'Erro desconhecido');

      case AppFlow.needsAdoption:
      case AppFlow.hasActiveRequest:
      case AppFlow.hasPet:
        return _buildMainScaffold(state);
    }
  }

  Widget _buildLoadingScaffold() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8FF),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: const LoadingScreen(),
      ),
    );
  }

  Widget _buildUnauthenticatedScaffold() {
    return const ErrorScreen(
      message: 'Usuário não autenticado',
      showLoginButton: true,
    );
  }

  Widget _buildErrorScaffold(String error) {
    return ErrorScreen(
      message: error,
      onRetry: () async {
        await AdoptionFlowService.verifyAndRepairState(
          ref: ref,
          forceRefresh: true,
        );
      },
    );
  }

  Widget _buildMainScaffold(UnifiedUserState state) {
    return Scaffold(
      extendBody: false,
      appBar: const CustomHomeAppBar(),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8FF),
              Color(0xFFFFFFFF),
              Color(0xFFF0F8FF),
              Color(0xFFFAF8FF),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            // NOVO: Mostrar indicador de transição se necessário
            if (state.isInTransition) _buildTransitionIndicator(state),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _selectedIndex = index);
                },
                children: [
                  // Tab 1: Pet (conteúdo dinâmico baseado no estado)
                  _PetTabContent(
                    state: state,
                    floatController: _floatController,
                  ),
                  // Tab 2: Dashboard
                  const DashboardPage(),
                  // Tab 3: Missões
                  const AnonymousAdoptionsListPage(),
                  // Tab 4: Mais opções
                  const MoreOptionsTabPage(),
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
          BottomNavItem(icon: Icons.model_training_sharp, label: 'Missões'),
          BottomNavItem(icon: Icons.more, label: 'Mais'),
        ],
        onItemTapped: _onItemTapped,
        onCenterButtonPressed: _showGamesBottomSheet,
      ),
    );
  }

  Widget _buildTransitionIndicator(UnifiedUserState state) {
    String message;
    Color color;

    switch (state.transitionState) {
      case TransitionState.adoptingPet:
        message = 'Processando adoção...';
        color = Colors.green;
        break;
      case TransitionState.creatingRequest:
        message = 'Criando solicitação...';
        color = Colors.blue;
        break;
      case TransitionState.cancelingRequest:
        message = 'Cancelando solicitação...';
        color = Colors.orange;
        break;
      case TransitionState.refreshingData:
        message = 'Atualizando dados...';
        color = Colors.purple;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: color.withOpacity(0.1),
      child: Row(
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              color: color,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget que renderiza o conteúdo da tab Pet baseado no estado unificado
class _PetTabContent extends ConsumerWidget {
  final UnifiedUserState state;
  final AnimationController floatController;

  const _PetTabContent({
    required this.state,
    required this.floatController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // NOVO: Lógica centralizada e clara para decidir o que exibir
    switch (state.flow) {
      case AppFlow.hasPet:
        return _buildPetStatusContent();

      case AppFlow.hasActiveRequest:
        return _buildActiveRequestContent();

      case AppFlow.needsAdoption:
        return _buildAdoptionOptionsContent();

      default:
        return _buildFallbackContent();
    }
  }

  Widget _buildPetStatusContent() {
    final activePet = state.activePet;

    if (activePet == null) {
      // Estado inconsistente - pet deveria existir
      return _buildInconsistentStateContent('Pet não encontrado');
    }

    return _PetStatusCard(
      pet: activePet,
      floatController: floatController,
    );
  }

  Widget _buildActiveRequestContent() {
    final activeRequest = state.activeRequest;

    if (activeRequest == null) {
      // Estado inconsistente - solicitação deveria existir
      return _buildInconsistentStateContent('Solicitação não encontrada');
    }

    return _ActiveRequestCard(activeRequest: activeRequest);
  }

  Widget _buildAdoptionOptionsContent() {
    final user = state.user;

    if (user == null) {
      return _buildInconsistentStateContent('Usuário não encontrado');
    }

    return _AdoptionOptionsWidget(user: user);
  }

  Widget _buildFallbackContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets_outlined,
            size: 80.sp,
            color: AppTheme.textLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'Estado Indefinido',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'O estado da aplicação não pôde ser determinado.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInconsistentStateContent(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_outlined,
            size: 80.sp,
            color: Colors.orange,
          ),
          SizedBox(height: 16.h),
          Text(
            'Estado Inconsistente',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 20.h),
          Consumer(
            builder: (context, ref, child) {
              return ElevatedButton(
                onPressed: () async {
                  await AdoptionFlowService.verifyAndRepairState(
                    ref: ref,
                    forceRefresh: true,
                  );
                },
                child: const Text('Reparar Estado'),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Widgets específicos para cada tipo de conteúdo
class _PetStatusCard extends StatelessWidget {
  final FirebasePetModel pet;
  final AnimationController floatController;

  const _PetStatusCard({
    required this.pet,
    required this.floatController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar do pet com animação
          AnimatedBuilder(
            animation: floatController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, floatController.value * 8),
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      pet.photo,
                      style: TextStyle(fontSize: 80.sp),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20.h),

          // Nome do pet
          Text(
            pet.name,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),

          SizedBox(height: 8.h),

          // Tipo e raça
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

          // Status do pet
          Text(
            'Seu pet está bem cuidado! 🐾',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActiveRequestCard extends StatelessWidget {
  final CollaborativeAdoptionRequest activeRequest;

  const _ActiveRequestCard({required this.activeRequest});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.w),
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
            ),
            child: Column(
              children: [
                Icon(
                  Icons.schedule,
                  size: 60.sp,
                  color: Color(activeRequest.requesterColorTheme),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Solicitação Ativa',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Expira em ${activeRequest.daysRemaining.toStringAsFixed(1)} dias',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: activeRequest.isUrgent
                        ? Colors.red
                        : Color(activeRequest.requesterColorTheme),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Ações da solicitação
          Consumer(
            builder: (context, ref, child) {
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await AdoptionFlowService.executeCancelRequestFlow(
                          context: context,
                          ref: ref,
                        );
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Cancelar Solicitação'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AdoptionOptionsWidget extends StatelessWidget {
  final UserModel user;

  const _AdoptionOptionsWidget({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.pets_rounded,
                  size: 80.sp,
                  color: AppTheme.primary,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Adote um Pet',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Encontre seu companheiro perfeito\ne transforme duas vidas para sempre',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),
          const Spacer(),
          // Botões de ação
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppUtils.mediumImpact();
                    context.push('/list-adoption');
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('Ver Pets Disponíveis'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    AppUtils.mediumImpact();
                    context.push('/create-adoption');
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Criar uma Adoção'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
