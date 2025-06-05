import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/widgets/custom_bar.dart';
import 'package:petverse/core/widgets/custom_bottom_navigation.dart';
import 'package:petverse/presentation/providers/theme_provider.dart';
import 'package:petverse/presentation/screens/dashboard_screen.dart';
import 'package:petverse/presentation/screens/feed_screeen.dart';
import 'package:petverse/presentation/screens/game_screen.dart' hide Colors;
import 'package:petverse/presentation/screens/pet_screen.dart';
import 'package:petverse/presentation/screens/settings_screen.dart';
import 'package:petverse/presentation/screens/store_screen.dart';

/// Tela principal do aplicativo com navegação entre seções
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _navigationController;
  late AnimationController _pageTransitionController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedIndex = 0;
  bool _showSettings = false;
  PageController? _pageController;

  // Cache das páginas para melhor performance
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializePages();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _navigationController.dispose();
    _pageTransitionController.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _navigationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pageTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeOutCubic,
    ));

    _pageTransitionController.forward();
  }

  void _initializePages() {
    _pages = [
      const DashboardScreen(),
      const StoreScreen(),
      const PetScreen(),
      const GamesScreen(),
      const FeedScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(isLightThemeProvider);

    return Scaffold(
      backgroundColor: isLightTheme ? Colors.grey[50] : Colors.grey[900],
      appBar: _showSettings ? null : _buildAppBar(),
      extendBody:
          true, // Permite que o corpo se estenda atrás da navigation bar
      body: AnimatedBuilder(
        animation: _pageTransitionController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                // Adiciona padding bottom para evitar que o conteúdo fique atrás da navigation
                padding: _showSettings
                    ? EdgeInsets.zero
                    : const EdgeInsets.only(bottom: 90),
                child: _buildBody(isLightTheme),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _showSettings
          ? null
          : NavigationWithCenterButton(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              onCenterButtonPressed: () => _onItemTapped(2), // Pet = index 2
            ),
    );
  }

  /// Constrói a AppBar
  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      onSettingsClick: _handleSettingsClick,
      onNotificationsClick: _handleNotificationsClick,
      userDisplayName: 'Pet Lover',
    );
  }

  /// Constrói o corpo principal
  Widget _buildBody(bool isLightTheme) {
    if (_showSettings) {
      return SettingsScreen(onBack: _handleBackFromSettings);
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: _pages.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation:
              _pageController?.position ?? const AlwaysStoppedAnimation(0),
          builder: (context, child) {
            double value = 1.0;
            if (_pageController?.position.haveDimensions == true) {
              value = (_pageController!.page! - index).abs();
              value = (1 - (value * 0.3)).clamp(0.7, 1.0);
            }

            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: _pages[index],
              ),
            );
          },
        );
      },
    );
  }

  /// Manipula mudança de página
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Anima a transição
    _pageTransitionController.reset();
    _pageTransitionController.forward();
  }

  /// Manipula toque nos itens da navegação
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    // Anima para a nova página
    _pageController?.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Feedback tátil
    _provideFeedback();
  }

  /// Manipula clique nas configurações
  void _handleSettingsClick() {
    setState(() {
      _showSettings = true;
    });

    // Anima a entrada das configurações
    _navigationController.forward();
  }

  /// Manipula volta das configurações
  void _handleBackFromSettings() {
    _navigationController.reverse().then((_) {
      setState(() {
        _showSettings = false;
      });
    });
  }

  /// Manipula clique nas notificações
  void _handleNotificationsClick() {
    _showNotificationsDialog();
  }

  /// Mostra dialog de notificações
  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications, color: Colors.purple[600]),
            const SizedBox(width: 8),
            const Text('Notificações'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNotificationItem(
                'Novo pet disponível!',
                'Um adorável gatinho está esperando por uma família.',
                '2h',
                Icons.pets,
                Colors.purple,
              ),
              const Divider(),
              _buildNotificationItem(
                'Seu pet está com fome!',
                'Max precisa de cuidados. Que tal alimentá-lo?',
                '4h',
                Icons.restaurant,
                Colors.orange,
              ),
              const Divider(),
              _buildNotificationItem(
                'Nova conquista desbloqueada!',
                'Você alcançou o nível 5! Parabéns!',
                '1d',
                Icons.emoji_events,
                Colors.amber,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  /// Constrói um item de notificação
  Widget _buildNotificationItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        time,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[500],
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  /// Mostra snackbar de sucesso
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Fornece feedback tátil
  void _provideFeedback() {
    // Implementar vibração se necessário
    // HapticFeedback.lightImpact();
  }
}
