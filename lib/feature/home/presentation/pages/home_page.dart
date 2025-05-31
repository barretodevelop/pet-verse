// lib/feature/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/providers/app_state_provider.dart';
import 'package:petverse/core/providers/firebase_adoption_provider.dart';
import 'package:petverse/core/theme/app_theme.dart';
import 'package:petverse/core/utils/app_utils.dart';
import 'package:petverse/core/widgets/custom_bottom_navigation_bar.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';
import 'package:petverse/feature/dashoard/dashboard_page.dart';
import 'package:petverse/feature/home/presentation/widgets/custom_app_bar.dart';
import 'package:petverse/feature/home/presentation/widgets/loading_error_screens.dart';
import 'package:petverse/feature/home/presentation/widgets/more_ptions_tab_page.dart';
import 'package:petverse/feature/home/presentation/widgets/pets_tab_page_content.dart';
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

  void _showGamesBottomSheet() {
    MinigamesBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userPetsProvider, (previous, next) {
      next.whenData((pets) {
        if (pets.isNotEmpty && (previous?.value?.isEmpty ?? true)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bem-vindo ao cuidado do seu novo pet! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    });

    final uiState = ref.watch(uiStateProvider);

    if (uiState.isLoading) {
      return const LoadingScreen();
    }

    if (!uiState.isAuthenticated) {
      return const ErrorScreen(
        message: 'Usuario não Authenticado',
      );
    }

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
                  PetsTabPageContent(floatController: _floatController),
                  const DashboardPage(),
                  const AnonymousAdoptionsListPage(),
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
          BottomNavItem(icon: Icons.model_training_sharp, label: 'Missoes'),
          BottomNavItem(icon: Icons.more, label: 'Mais'),
        ],
        onItemTapped: _onItemTapped,
        onCenterButtonPressed: _showGamesBottomSheet,
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
}
