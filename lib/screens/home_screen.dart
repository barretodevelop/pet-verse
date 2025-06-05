// lib/screens/home_screen.dart
// ALTERAÇÃO: Navegação melhorada, animações e feedback visual

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/src/core/navigation/app_routes.dart';
import 'package:petverse/src/features/adoption/presentation/screens/adoption_initial_screen.dart';
import 'package:petverse/src/features/auth/presentation/providers/user_data_provider.dart';
import 'package:petverse/src/features/pets/presentation/screens/feed_screen.dart';
import 'package:petverse/src/features/pets/presentation/screens/my_pets_screen.dart';
import 'package:petverse/src/features/profile/presentation/screens/profile_screen.dart';

// StateProvider para gerenciar o índice da aba selecionada na BottomNavigationBar
final homeScreenIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late AnimationController _appBarController;
  late Animation<double> _fabAnimation;
  late Animation<double> _appBarAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _appBarController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));

    _appBarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _appBarController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _appBarController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _fabController.forward();
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    _appBarController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    HapticFeedback.selectionClick();
    final currentIndex = ref.read(homeScreenIndexProvider);

    // If tapping the same tab, trigger a refresh or scroll to top
    if (currentIndex == index) {
      _triggerTabRefresh(index);
    } else {
      ref.read(homeScreenIndexProvider.notifier).state = index;
    }
  }

  void _triggerTabRefresh(int index) {
    // Add tab-specific refresh logic here
    switch (index) {
      case 0: // Feed
        // Could refresh feed data
        break;
      case 1: // My Pets
        // Could refresh pet data
        break;
      case 2: // Profile
        // Could refresh profile data
        break;
    }
  }

  String _getAppBarTitle(int currentIndex, bool hasPet) {
    switch (currentIndex) {
      case 0:
        return 'Feed de Pets';
      case 1:
        return hasPet ? 'Meus Pets' : 'Adotar Pet';
      case 2:
        return 'Meu Perfil';
      default:
        return 'PetVerse';
    }
  }

  IconData _getAppBarIcon(int currentIndex, bool hasPet) {
    switch (currentIndex) {
      case 0:
        return Icons.pets;
      case 1:
        return hasPet ? Icons.favorite : Icons.add_circle_outline;
      case 2:
        return Icons.person;
      default:
        return Icons.pets;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(homeScreenIndexProvider);
    final userHasPetAsyncValue = ref.watch(userHasPetProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return userHasPetAsyncValue.when(
      data: (hasPet) => _buildHomeContent(currentIndex, hasPet),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildHomeContent(int currentIndex, bool hasPet) {
    final colorScheme = Theme.of(context).colorScheme;

    // Build screen list dynamically
    final List<Widget> screens = [
      const FeedScreen(),
      hasPet ? const MyPetsScreen() : const AdoptionInitialScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(_appBarAnimation),
          child: AppBar(
            title: Row(
              children: [
                ScaleTransition(
                  scale: _appBarAnimation,
                  child: Icon(
                    _getAppBarIcon(currentIndex, hasPet),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(_getAppBarTitle(currentIndex, hasPet)),
              ],
            ),
            elevation: 0,
            backgroundColor: colorScheme.surface.withOpacity(0.95),
            foregroundColor: colorScheme.onSurface,
            actions: [
              ScaleTransition(
                scale: _appBarAnimation,
                child: IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: colorScheme.onSurface,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push(AppRoutes.settings);
                  },
                  tooltip: 'Configurações',
                ),
              ),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: IndexedStack(
          key: ValueKey(currentIndex),
          index: currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(currentIndex, hasPet),
      floatingActionButton: _buildFloatingActionButton(currentIndex, hasPet),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNavigationBar(int currentIndex, bool hasPet) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.pets, 0, currentIndex),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(
              hasPet ? Icons.favorite : Icons.add_circle_outline,
              1,
              currentIndex,
            ),
            label: hasPet ? 'Meus Pets' : 'Adotar',
          ),
          BottomNavigationBarItem(
            icon: _buildNavIcon(Icons.person, 2, currentIndex),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, int currentIndex) {
    final isSelected = currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: isSelected ? 26 : 24,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget? _buildFloatingActionButton(int currentIndex, bool hasPet) {
    // Only show FAB on certain tabs
    if (currentIndex != 0) return null;

    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.push(AppRoutes.pendingAdoptions);
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
        child: const Icon(Icons.search),
      ),
    );
  }

  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Carregando PetVerse...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(error) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.error.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Erro: $error',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(userHasPetProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
