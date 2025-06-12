// File: lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/domain/entities/daily_reward_result.dart';
import 'package:petverse/presentation/providers/dependencies_provider.dart';
import 'package:petverse/presentation/providers/feedback_notification_provider.dart';
import 'package:petverse/presentation/screens/home/custom_app_bar.dart';
import 'package:petverse/presentation/screens/home/pet/optimized_pet_screen.dart';
import 'package:petverse/presentation/screens/settings/settings_screen.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';

import 'dashboard/dashboard_screen.dart';
import 'feed/feed_screen.dart';
import 'games/games_screen.dart';
import 'shop/shop_screen.dart';

/// Main home screen with bottom navigation - INTEGRAÇÃO FASE 1
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  bool _showSettings = false;
  late AnimationController _screenTransitionController;
  late AnimationController _feedbackController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupFeedbackSystem();
  }

  void _initAnimations() {
    _screenTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _screenTransitionController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _screenTransitionController,
      curve: Curves.easeOutBack,
    ));

    _screenTransitionController.forward();
  }

  void _setupFeedbackSystem() {
    // Listen to feedback provider for visual feedback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<FeedbackState>(feedbackProvider, (previous, next) {
        if (next.hasActiveFeedbacks &&
            (previous?.activeFeedbackCount ?? 0) < next.activeFeedbackCount) {
          _feedbackController.forward().then((_) => _feedbackController.reverse());
        }
      });
    });
  }

  @override
  void dispose() {
    _screenTransitionController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    final currentIndex = ref.read(bottomNavIndexProvider);
    if (currentIndex != index) {
      ref.read(bottomNavIndexProvider.notifier).state = index;

      // Trigger screen transition animation
      _screenTransitionController.reset();
      _screenTransitionController.forward();

      // Provide haptic feedback
      _provideTapFeedback();
    }
  }

  void _provideTapFeedback() {
    final shouldUseHaptic = ref.read(shouldUseHapticProvider);
    if (shouldUseHaptic) {
      // TODO: Add haptic feedback
      // HapticFeedback.lightImpact();
    }
  }

  Widget _renderCurrentScreen() {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    if (_showSettings) {
      return SettingsScreen(
        onBack: () {
          setState(() {
            _showSettings = false;
          });
        },
      );
    }

    switch (currentIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const ShopScreen();
      case 2:
        // ⭐ INTEGRAÇÃO FASE 1: Nova OptimizedPetScreen
        return const OptimizedPetScreen();
      case 3:
        return const GamesScreen();
      case 4:
        return const FeedScreen();
      default:
        return const DashboardScreen();
    }
  }

  void _handleSettingsClick() {
    setState(() {
      _showSettings = true;
    });

    _screenTransitionController.reset();
    _screenTransitionController.forward();
  }

  void _handleNotificationsClick() {
    // TODO: Implement notifications screen
    // ref.read(feedbackProvider.notifier).showInfo('Notificações em desenvolvimento!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !_showSettings
          ? CustomAppBar(
              onSettingsClick: _handleSettingsClick,
              onNotificationsClick: _handleNotificationsClick,
            )
          : null,
      body: Stack(
        children: [
          // Main content with transition animation
          AnimatedBuilder(
            animation: _screenTransitionController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: _renderCurrentScreen(),
                ),
              );
            },
          ),

          // ⭐ INTEGRAÇÃO: Sistema de feedback visual
          const FeedbackOverlay(),
        ],
      ),
      bottomNavigationBar: !_showSettings ? _buildBottomNavigationBar() : null,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBottomNavigationBar() {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _feedbackController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_feedbackController.value * 0.02),
          child: Container(
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
              onTap: _onBottomNavTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: theme.bottomAppBarTheme.color ?? theme.cardColor,
              selectedItemColor: ThemeConfig.primaryColor,
              unselectedItemColor: Colors.grey[600],
              selectedFontSize: ThemeConfig.fontSize12,
              unselectedFontSize: ThemeConfig.fontSize12,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store_outlined),
                  activeIcon: Icon(Icons.store),
                  label: 'Shop',
                ),
                BottomNavigationBarItem(
                  // ⭐ Tab Pet agora usa OptimizedPetScreen
                  icon: Icon(Icons.pets_outlined),
                  activeIcon: Icon(Icons.pets),
                  label: 'Pet',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sports_esports_outlined),
                  activeIcon: Icon(Icons.sports_esports),
                  label: 'Games',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.feed_outlined),
                  activeIcon: Icon(Icons.feed),
                  label: 'Feed',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget? _buildFloatingActionButton() {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    // Show FAB only on Pet screen
    if (currentIndex != 2 || _showSettings) return null;

    return SlideFadeAnimation(
      duration: const Duration(milliseconds: 600),
      child: FloatingActionButton.extended(
        onPressed: _handleQuickPetAction,
        backgroundColor: ThemeConfig.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.favorite),
        label: const Text('Amar Pets'),
        elevation: 8,
        highlightElevation: 12,
      ),
    );
  }

  void _handleQuickPetAction() {
    // Quick love action for all pets
    ref.read(feedbackProvider.notifier).showSuccess(
          '💖 Você demonstrou amor por todos os seus pets!',
          duration: const Duration(seconds: 3),
        );

    _provideTapFeedback();
  }

  void _showDailyRewardDialog(DailyRewardResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeConfig.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.card_giftcard,
              color: ThemeConfig.primaryColor,
              size: 28,
            ),
            const SizedBox(width: ThemeConfig.spacing8),
            const Text(
              'Daily Reward!',
              style: TextStyle(
                fontSize: ThemeConfig.fontSize20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Congratulations! You received:',
              style: TextStyle(
                fontSize: ThemeConfig.fontSize16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            Container(
              padding: const EdgeInsets.all(ThemeConfig.spacing16),
              decoration: BoxDecoration(
                color: ThemeConfig.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
                border: Border.all(
                  color: ThemeConfig.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '🪙 ${result.coinsRewarded} Coins',
                    style: const TextStyle(
                      fontSize: ThemeConfig.fontSize18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (result.gemsRewarded > 0) ...[
                    const SizedBox(height: ThemeConfig.spacing8),
                    Text(
                      '💎 ${result.gemsRewarded} Gems',
                      style: const TextStyle(
                        fontSize: ThemeConfig.fontSize18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (result.xpRewarded > 0) ...[
                    const SizedBox(height: ThemeConfig.spacing8),
                    Text(
                      '⭐ ${result.xpRewarded} XP',
                      style: const TextStyle(
                        fontSize: ThemeConfig.fontSize18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: ThemeConfig.spacing12),
            Text(
              'Day ${result.streakDay} of your streak!',
              style: TextStyle(
                fontSize: ThemeConfig.fontSize14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();

              // Show success feedback
              ref.read(feedbackProvider.notifier).showSuccess(
                    'Recompensa diária coletada! 🎉',
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
              ),
            ),
            child: const Text('Collect!'),
          ),
        ],
      ),
    );
  }
}

/// Provider para controlar o overlay de feedback visual
final feedbackOverlayProvider = Provider<Widget>((ref) {
  return const FeedbackOverlay();
});

/// Provider para verificar se deve mostrar FAB
final shouldShowFABProvider = Provider<bool>((ref) {
  final currentIndex = ref.watch(bottomNavIndexProvider);
  return currentIndex == 2; // Pet screen
});
