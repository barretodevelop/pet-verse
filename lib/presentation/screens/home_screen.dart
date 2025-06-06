import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/widgets/custom_bar.dart';
import 'package:petverse/core/widgets/custom_bottom_navigation.dart';
import 'package:petverse/presentation/providers/theme_provider.dart';
import 'package:petverse/presentation/screens/dashboard_screen.dart';
import 'package:petverse/presentation/screens/feed_screeen.dart';
import 'package:petverse/presentation/screens/game_screen.dart';
import 'package:petverse/presentation/screens/pet_screen.dart';
import 'package:petverse/presentation/screens/settings_screen.dart';
import 'package:petverse/presentation/screens/store_screen.dart';

// import '../../core/providers/auth_provider.dart';
// import '../widgets/logout_button.dart';

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   int _selectedIndex = 0;
//   final PageController _pageController = PageController();

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final currentUser = ref.watch(currentUserProvider);
//     final isAuthenticated = ref.watch(isAuthenticatedProvider);

//     return Scaffold(
//       // AppBar customizado com dados reais do usuário
//       appBar: CustomAppBar(
//         onSettingsClick: () => _openSettings(context),
//         onNotificationsClick: () => _openNotifications(context),
//         title: _getPageTitle(),
//       ),

//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         children: [
//           _buildDashboardPage(),
//           _buildStorePage(),
//           _buildPetPage(),
//           _buildGamesPage(),
//           _buildFeedPage(),
//         ],
//       ),

//       // Navegação inferior com botão central
//       bottomNavigationBar: NavigationWithCenterButton(
//         selectedIndex: _selectedIndex,
//         onItemTapped: _onNavItemTapped,
//         onCenterButtonPressed: () => _onNavItemTapped(2), // Pet page
//       ),

//       // FAB para ações rápidas (se necessário)
//       floatingActionButton: _selectedIndex == 2 // Na página do Pet
//           ? FloatingActionButton(
//               onPressed: () => _showQuickActions(context),
//               tooltip: 'Ações Rápidas',
//               child: const Icon(Icons.add),
//             )
//           : null,
//     );
//   }

//   /// Navegação entre páginas
//   void _onNavItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     _pageController.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   /// Título da página atual
//   String _getPageTitle() {
//     switch (_selectedIndex) {
//       case 0:
//         return 'Dashboard';
//       case 1:
//         return 'Loja';
//       case 2:
//         return 'Meu Pet';
//       case 3:
//         return 'Jogos';
//       case 4:
//         return 'Feed';
//       default:
//         return 'PetVerse';
//     }
//   }

//   /// Página Dashboard
//   Widget _buildDashboardPage() {
//     final currentUser = ref.watch(currentUserProvider);

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Boas-vindas personalizadas
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Bem-vindo${currentUser?.displayName != null ? ', ${currentUser!.displayName}' : ''}!',
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Que tal cuidar do seu pet hoje?',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(height: 16),

//                   // Status de autenticação
//                   Row(
//                     children: [
//                       Icon(
//                         currentUser != null
//                             ? Icons.verified_user
//                             : Icons.person_outline,
//                         color:
//                             currentUser != null ? Colors.green : Colors.orange,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         currentUser != null ? 'Conectado' : 'Visitante',
//                         style: TextStyle(
//                           color: currentUser != null
//                               ? Colors.green
//                               : Colors.orange,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Estatísticas rápidas
//           GridView.count(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             crossAxisCount: 2,
//             crossAxisSpacing: 16,
//             mainAxisSpacing: 16,
//             children: [
//               _buildStatCard('Pets Criados', '0', Icons.pets, Colors.purple),
//               _buildStatCard('Nível', '1', Icons.star, Colors.amber),
//               _buildStatCard(
//                   'Dias Ativo', '1', Icons.calendar_today, Colors.blue),
//               _buildStatCard(
//                   'Conquistas', '0', Icons.emoji_events, Colors.green),
//             ],
//           ),

//           const SizedBox(height: 24),

//           // Ações rápidas
//           Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Ações Rápidas',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildQuickAction(
//                         'Adotar Pet',
//                         Icons.favorite,
//                         Colors.red,
//                         () => _onNavItemTapped(2),
//                       ),
//                       _buildQuickAction(
//                         'Jogar',
//                         Icons.games,
//                         Colors.blue,
//                         () => _onNavItemTapped(3),
//                       ),
//                       _buildQuickAction(
//                         'Loja',
//                         Icons.shopping_cart,
//                         Colors.green,
//                         () => _onNavItemTapped(1),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Página da Loja
//   Widget _buildStorePage() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.store, size: 64, color: Colors.grey),
//           SizedBox(height: 16),
//           Text(
//             'Loja',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           Text('Em breve...'),
//         ],
//       ),
//     );
//   }

//   /// Página do Pet
//   Widget _buildPetPage() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.pets, size: 64, color: Colors.purple),
//           SizedBox(height: 16),
//           Text(
//             'Meu Pet',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           Text('Adote seu primeiro pet!'),
//         ],
//       ),
//     );
//   }

//   /// Página de Jogos
//   Widget _buildGamesPage() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.games, size: 64, color: Colors.blue),
//           SizedBox(height: 16),
//           Text(
//             'Jogos',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           Text('Mini-jogos em breve...'),
//         ],
//       ),
//     );
//   }

//   /// Página do Feed
//   Widget _buildFeedPage() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.article, size: 64, color: Colors.orange),
//           SizedBox(height: 16),
//           Text(
//             'Feed',
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           Text('Novidades da comunidade...'),
//         ],
//       ),
//     );
//   }

//   /// Card de estatística
//   Widget _buildStatCard(
//       String title, String value, IconData icon, Color color) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 32, color: color),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               title,
//               style: const TextStyle(fontSize: 12),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Ação rápida
//   Widget _buildQuickAction(
//       String title, IconData icon, Color color, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: Icon(icon, color: color, size: 30),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             title,
//             style: const TextStyle(fontSize: 12),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   /// Abrir configurações
//   void _openSettings(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 24),

//             const Text(
//               'Configurações',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Opções de configuração
//             ListTile(
//               leading: const Icon(Icons.palette),
//               title: const Text('Tema'),
//               subtitle: const Text('Claro / Escuro'),
//               onTap: () {
//                 // Toggle tema
//                 final currentTheme = ref.read(themeModeProvider);
//                 final newTheme = currentTheme == ThemeMode.light
//                     ? ThemeMode.dark
//                     : ThemeMode.light;
//                 ref.read(themeModeProvider.notifier).setTheme(newTheme);
//                 Navigator.pop(context);
//               },
//             ),

//             ListTile(
//               leading: const Icon(Icons.notifications),
//               title: const Text('Notificações'),
//               subtitle: const Text('Gerenciar alertas'),
//               onTap: () => Navigator.pop(context),
//             ),

//             ListTile(
//               leading: const Icon(Icons.help),
//               title: const Text('Ajuda'),
//               subtitle: const Text('FAQ e suporte'),
//               onTap: () => Navigator.pop(context),
//             ),

//             const Divider(),

//             // Botão de logout (se autenticado)
//             LogoutButton(
//               onLogoutSuccess: () {
//                 Navigator.pop(context);
//               },
//             ),

//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Abrir notificações
//   void _openNotifications(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Notificações'),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: Icon(Icons.pets, color: Colors.purple),
//               title: Text('Seu pet está com fome!'),
//               subtitle: Text('Há 2 horas'),
//             ),
//             ListTile(
//               leading: Icon(Icons.star, color: Colors.amber),
//               title: Text('Parabéns! Nível 2 alcançado'),
//               subtitle: Text('Há 1 dia'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Fechar'),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Mostrar ações rápidas
//   void _showQuickActions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Ações Rápidas',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ListTile(
//               leading: const Icon(Icons.restaurant, color: Colors.orange),
//               title: const Text('Alimentar Pet'),
//               subtitle: const Text('10 coins'),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(Icons.sports_esports, color: Colors.blue),
//               title: const Text('Brincar'),
//               subtitle: const Text('5 coins'),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(Icons.hotel, color: Colors.green),
//               title: const Text('Descansar'),
//               subtitle: const Text('8 coins'),
//               onTap: () => Navigator.pop(context),
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }

// ========================================
// 3. SPLASH SCREEN ATUALIZADA
// lib/presentation/screens/splash_screen.dart (ATUALIZADO)

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
