// File: lib/presentation/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/domain/entities/daily_reward_result.dart';
import 'package:petverse/presentation/providers/dependencies_provider.dart';
import 'package:petverse/presentation/providers/user_provider.dart';
import 'package:petverse/presentation/screens/home/pet/new_pet_screen.dart';
import 'package:petverse/presentation/screens/settings/settings_screen.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';
import 'package:petverse/presentation/widgets/common/custom_app_bar.dart';

import 'dashboard/dashboard_screen.dart';
import 'feed/feed_screen.dart';
import 'games/games_screen.dart';
import 'shop/shop_screen.dart';

/// Main home screen with bottom navigation
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  bool _showSettings = false;
  late AnimationController _screenTransitionController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _screenTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

  @override
  void dispose() {
    _screenTransitionController.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    final currentIndex = ref.read(bottomNavIndexProvider);
    if (currentIndex != index) {
      ref.read(bottomNavIndexProvider.notifier).state = index;
      _screenTransitionController.reset();
      _screenTransitionController.forward();
    }
  }

  void _handleSettingsClick() {
    setState(() {
      _showSettings = true;
      _screenTransitionController.reset();
      _screenTransitionController.forward();
    });
  }

  void _handleNotificationsClick() {
    _showNotificationsDialog();
  }

  void _handleBackFromSettings() {
    setState(() {
      _showSettings = false;
      _screenTransitionController.reset();
      _screenTransitionController.forward();
    });
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.notifications,
              color: ThemeConfig.primaryColor,
            ),
            SizedBox(width: ThemeConfig.spacing8),
            Text('Notifications'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationItem(
              '🎉',
              'Daily Reward Available!',
              'Claim your daily bonus now',
              DateTime.now().subtract(const Duration(minutes: 5)),
            ),
            const SizedBox(height: ThemeConfig.spacing12),
            _buildNotificationItem(
              '🐾',
              'Pet needs attention',
              'Fluffy is feeling hungry',
              DateTime.now().subtract(const Duration(hours: 1)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to notifications settings
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  Widget _renderCurrentScreen() {
    if (_showSettings) {
      return SettingsScreen(onBack: _handleBackFromSettings);
    }

    final currentIndex = ref.watch(bottomNavIndexProvider);
    final petGameState = ref.watch(enhancedPetGameProvider);

    switch (currentIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const ShopScreen();
      case 2:
        return const NewPetScreen();
      //petGameState.hasUserPets ? const EnhancedPetScreen() : const PetAdoptionScreen();
      case 3:
        return const GamesScreen();
      case 4:
        return const FeedScreen();
      default:
        return const DashboardScreen();
    }
  }

  Widget _buildNotificationItem(
    String emoji,
    String title,
    String subtitle,
    DateTime time,
  ) {
    return Container(
      padding: const EdgeInsets.all(ThemeConfig.spacing12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: ThemeConfig.fontSize24),
          ),
          const SizedBox(width: ThemeConfig.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: ThemeConfig.fontSize14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: ThemeConfig.fontSize12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimeAgo(time),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: ThemeConfig.fontSize10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userGameDataState = ref.watch(userGameDataProvider);

    return Scaffold(
      appBar: !_showSettings
          ? CustomAppBar(
              onSettingsClick: _handleSettingsClick,
              onNotificationsClick: _handleNotificationsClick,
            )
          : null,
      body: AnimatedBuilder(
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
      bottomNavigationBar: !_showSettings ? _buildBottomNavigationBar() : null,
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBottomNavigationBar() {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final theme = Theme.of(context);

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
    );
  }

  Widget? _buildFloatingActionButton() {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final userGameDataState = ref.watch(userGameDataProvider);

    // Show daily reward FAB only on dashboard
    if (currentIndex == 0 &&
        !_showSettings &&
        userGameDataState.canClaimDailyReward &&
        userGameDataState.hasUser) {
      return SlideFadeAnimation(
        duration: const Duration(milliseconds: 500),
        child: FloatingActionButton.extended(
          onPressed: _claimDailyReward,
          backgroundColor: ThemeConfig.accentColor,
          foregroundColor: Colors.black87,
          elevation: 4,
          icon: const Icon(Icons.card_giftcard),
          label: const Text(
            'Daily Reward!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return null;
  }

  Future<void> _claimDailyReward() async {
    try {
      // Versão simples que sempre funciona
      await ref.read(userGameDataProvider.notifier).addCoins(100);
      await ref.read(userGameDataProvider.notifier).addGems(2);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎁 Recompensa recebida: 100 coins + 2 gems!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRewardSuccessDialog(DailyRewardResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated gift icon
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 600),
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ThemeConfig.accentColor, Colors.orange],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  size: ThemeConfig.iconSize48,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: ThemeConfig.spacing20),

            const Text(
              'Daily Reward Claimed!',
              style: TextStyle(
                fontSize: ThemeConfig.fontSize20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: ThemeConfig.spacing12),

            Text(
              result.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: ThemeConfig.spacing20),

            // Reward items
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // if (result.coins > 0) _buildRewardItem('💰', '+${result.coins}'),
                // if (result.gems > 0) _buildRewardItem('💎', '+${result.gems}'),
                // if (result.xp > 0) _buildRewardItem('⭐', '+${result.xp}'),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String emoji, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConfig.spacing12,
        vertical: ThemeConfig.spacing8,
      ),
      decoration: BoxDecoration(
        color: ThemeConfig.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: ThemeConfig.fontSize20),
          ),
          const SizedBox(height: 2),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ThemeConfig.fontSize12,
            ),
          ),
        ],
      ),
    );
  }
}
