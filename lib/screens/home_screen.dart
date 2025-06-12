// HomeScreen

// lib/screens/home_screen.dart - HomeScreen
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/providers/theme_provider.dart';
import 'package:petverse/providers/user_provider.dart';
import 'package:petverse/screens/dashboard_screen.dart';
import 'package:petverse/screens/feed_screen.dart';
import 'package:petverse/screens/missions_screen.dart';
import 'package:petverse/screens/pet_screen.dart';
import 'package:petverse/screens/shop_screen.dart';
import 'package:petverse/screens/user_profile_screen.dart';
import 'package:petverse/services/auth_service.dart';
import 'package:petverse/widgets/adoption_flow.dart';
import 'package:petverse/widgets/pet_slots.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 2;

  final List<Widget> _screens = [
    const FeedScreen(),
    const MissionsScreen(),
    const PetScreen(),
    const ShopScreen(),
    const DashboardScreen(),
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   // Ouvir mudanças na lista de pets
  //   // Usamos WidgetsBinding.instance.addPostFrameCallback para garantir que o ref está disponível
  //   // ESTE LISTENER FOI MOVIDO PARA DENTRO DO AppNotifier PARA UMA LÓGICA MAIS CENTRALIZADA
  //   // WidgetsBinding.instance.addPostFrameCallback((_) {
  //   //   ref.listen<List<PetModel>>(petProvider, (previousPets, newPets) {
  //   //     final appNotifier = ref.read(appProvider.notifier);
  //   //     final currentActiveIndex = ref.read(appProvider).activePetIndex;

  //   //     // Se um pet foi removido (lista diminuiu)
  //   //     if (previousPets != null && newPets.length < previousPets.length) {
  //   //       print(
  //   //           'HomeScreen: Pet removido detectado. Reavaliando activePetIndex.');
  //   //       appNotifier.setActivePetIndex(currentActiveIndex);
  //   //     }
  //   //   });
  //   // });
  // }

  // Método para abrir o AdoptionFlow como um modal
  void _openAdoptionFlow() {
    final isDark = ref.read(themeProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bContext) {
        return Container(
          height: MediaQuery.of(bContext).size.height * 0.9,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: const AdoptionFlow(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        elevation: 2,
        title: GestureDetector(
          onTap: () => _showUserProfile(context),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2), // espessura da borda
                decoration: const BoxDecoration(
                  color: Colors.white, // cor da borda
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF8B5CF6),
                  backgroundImage:
                      user?.avatar != null && user!.avatar.isNotEmpty
                          ? CachedNetworkImageProvider(user!.avatar)
                          : null,
                  child: user?.avatar == null || user!.avatar.isEmpty
                      ? const Text('👨', style: TextStyle(fontSize: 20))
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.username ?? 'Usuário',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Color(0xFFFBBF24)),
                        const SizedBox(width: 4),
                        Text(
                          'Nível ${user?.level ?? 1} • ${(user?.xp ?? 0) % 100}/100 XP',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on,
                    size: 16, color: Color(0xFFF59E0B)),
                const SizedBox(width: 4),
                Text('${user?.coins ?? 0}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA16207))),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E8FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond, size: 16, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 4),
                Text('${user?.gems ?? 0}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C3AED))),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Stack não é mais necessário se AdoptionFlow é um modal
          Column(
            // Conteúdo principal da HomeScreen
            children: [
              PetSlots(
                  onSlotClick:
                      _openAdoptionFlow), // Passa o método para abrir o modal
              Expanded(child: _screens[_currentIndex]),
            ],
          ),
          // AdoptionFlow não é mais renderizado condicionalmente aqui
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2))
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.rss_feed, 'Feed'),
                _buildNavItem(1, Icons.flag, 'Missões'),
                _buildCenterNavItem(2),
                _buildNavItem(3, Icons.shopping_bag, 'Loja'),
                _buildNavItem(4, Icons.dashboard, 'Dashboard'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ CORREÇÃO: Modal de perfil com altura fixa para evitar overflow
  void _showUserProfile(BuildContext context) {
    final user = ref.read(userProvider);
    final isDark = ref.read(themeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85, // ✅ Altura fixa
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: SafeArea(
          child: UserProfileScreen(),
          // ✅ SafeArea para evitar sobreposição
          // child: Column(
          //   children: [
          //     // Handle bar
          //     Container(
          //       margin: const EdgeInsets.only(top: 12, bottom: 8),
          //       width: 40,
          //       height: 4,
          //       decoration: BoxDecoration(
          //         color: isDark
          //             ? const Color(0xFF4B5563)
          //             : const Color(0xFFD1D5DB),
          //         borderRadius: BorderRadius.circular(2),
          //       ),
          //     ),

          //     // Header compacto
          //     Padding(
          //       padding: const EdgeInsets.symmetric(
          //           horizontal: 24, vertical: 12), // ✅ Padding reduzido
          //       child: Row(
          //         children: [
          //           Text('Perfil',
          //               style: TextStyle(
          //                   fontSize: 20,
          //                   fontWeight: FontWeight.bold,
          //                   color: isDark
          //                       ? Colors.white
          //                       : const Color(0xFF1F2937))),
          //           const Spacer(),
          //           GestureDetector(
          //             onTap: () => Navigator.of(context).pop(),
          //             child: Container(
          //               width: 32,
          //               height: 32,
          //               decoration: BoxDecoration(
          //                   color: isDark
          //                       ? const Color(0xFF374151)
          //                       : const Color(0xFFF3F4F6),
          //                   shape: BoxShape.circle),
          //               child: Icon(Icons.close,
          //                   size: 18,
          //                   color: isDark
          //                       ? Colors.white
          //                       : const Color(0xFF1F2937)),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),

          //     // ✅ CONTEÚDO COM SCROLL para evitar overflow
          //     Expanded(
          //       child: SingleChildScrollView(
          //         padding: const EdgeInsets.symmetric(horizontal: 24),
          //         child: Column(
          //           children: [
          //             // ✅ Profile card compacto
          //             Container(
          //               width: double.infinity,
          //               padding: const EdgeInsets.all(16), // ✅ Padding reduzido
          //               decoration: BoxDecoration(
          //                 color: isDark
          //                     ? const Color(0xFF374151)
          //                     : const Color(0xFFF8FAFC),
          //                 borderRadius: BorderRadius.circular(16),
          //               ),
          //               child: Column(
          //                 children: [
          //                   Container(
          //                     width: 60, height: 60, // ✅ Avatar menor
          //                     decoration: const BoxDecoration(
          //                         gradient: LinearGradient(colors: [
          //                           Color(0xFF8B5CF6),
          //                           Color(0xFF3B82F6)
          //                         ]),
          //                         shape: BoxShape.circle),
          //                     child: Center(
          //                         child: Text(user?.avatar ?? '👨',
          //                             style: const TextStyle(fontSize: 30))),
          //                   ),
          //                   const SizedBox(height: 12),
          //                   Text(user?.username ?? 'Usuário',
          //                       style: TextStyle(
          //                           fontSize: 18,
          //                           fontWeight: FontWeight.bold,
          //                           color: isDark
          //                               ? Colors.white
          //                               : const Color(0xFF1F2937))),
          //                   const SizedBox(height: 6),
          //                   Row(
          //                     mainAxisAlignment: MainAxisAlignment.center,
          //                     children: [
          //                       const Icon(Icons.star,
          //                           size: 16, color: Color(0xFFFBBF24)),
          //                       const SizedBox(width: 4),
          //                       Text('Nível ${user?.level ?? 1}',
          //                           style: TextStyle(
          //                               color: isDark
          //                                   ? const Color(0xFF9CA3AF)
          //                                   : const Color(0xFF6B7280))),
          //                     ],
          //                   ),
          //                   const SizedBox(height: 8),
          //                   Container(
          //                     width: double.infinity,
          //                     height: 6,
          //                     decoration: BoxDecoration(
          //                         color: isDark
          //                             ? const Color(0xFF4B5563)
          //                             : const Color(0xFFE5E7EB),
          //                         borderRadius: BorderRadius.circular(3)),
          //                     child: FractionallySizedBox(
          //                       alignment: Alignment.centerLeft,
          //                       widthFactor: ((user?.xp ?? 0) % 100) / 100,
          //                       child: Container(
          //                           decoration: BoxDecoration(
          //                               gradient: const LinearGradient(colors: [
          //                                 Color(0xFF8B5CF6),
          //                                 Color(0xFF3B82F6)
          //                               ]),
          //                               borderRadius:
          //                                   BorderRadius.circular(3))),
          //                     ),
          //                   ),
          //                   const SizedBox(height: 6),
          //                   Text(
          //                       '${(user?.xp ?? 0) % 100}/100 XP • Total: ${user?.xp ?? 0}',
          //                       style: TextStyle(
          //                           fontSize: 11,
          //                           color: isDark
          //                               ? const Color(0xFF9CA3AF)
          //                               : const Color(0xFF6B7280))),
          //                 ],
          //               ),
          //             ),

          //             const SizedBox(height: 20),

          //             // Toggle tema
          //             Container(
          //               padding: const EdgeInsets.all(14), // ✅ Padding reduzido
          //               decoration: BoxDecoration(
          //                   color: isDark
          //                       ? const Color(0xFF374151)
          //                       : const Color(0xFFF3F4F6),
          //                   borderRadius: BorderRadius.circular(12)),
          //               child: Row(
          //                 children: [
          //                   Icon(isDark ? Icons.dark_mode : Icons.light_mode,
          //                       color: isDark
          //                           ? Colors.white
          //                           : const Color(0xFF1F2937)),
          //                   const SizedBox(width: 12),
          //                   Expanded(
          //                     child: Column(
          //                       crossAxisAlignment: CrossAxisAlignment.start,
          //                       children: [
          //                         Text('Tema Escuro',
          //                             style: TextStyle(
          //                                 fontSize: 14,
          //                                 fontWeight: FontWeight.w600,
          //                                 color: isDark
          //                                     ? Colors.white
          //                                     : const Color(0xFF1F2937))),
          //                         Text('Alternar tema',
          //                             style: TextStyle(
          //                                 fontSize: 11,
          //                                 color: isDark
          //                                     ? const Color(0xFF9CA3AF)
          //                                     : const Color(0xFF6B7280))),
          //                       ],
          //                     ),
          //                   ),
          //                   Switch(
          //                       value: isDark,
          //                       onChanged: (_) => ref
          //                           .read(themeProvider.notifier)
          //                           .toggleTheme(),
          //                       activeColor: const Color(0xFF8B5CF6)),
          //                 ],
          //               ),
          //             ),

          //             const SizedBox(height: 16),

          //             // ✅ CORREÇÃO: Botão logout FUNCIONAL
          //             SizedBox(
          //               width: double.infinity, height: 48, // ✅ Altura reduzida
          //               child: ElevatedButton.icon(
          //                 onPressed: () => _performLogout(context),
          //                 icon: const Icon(Icons.logout),
          //                 label: const Text('Sair da Conta'),
          //                 style: ElevatedButton.styleFrom(
          //                   backgroundColor: const Color(0xFFEF4444),
          //                   foregroundColor: Colors.white,
          //                   shape: RoundedRectangleBorder(
          //                       borderRadius: BorderRadius.circular(12)),
          //                 ),
          //               ),
          //             ),

          //             const SizedBox(height: 40), // ✅ Espaço inferior
          //           ],
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }

  // ✅ CORREÇÃO: Método de logout FUNCIONAL
  Future<void> _performLogout(BuildContext context) async {
    final isDark = ref.read(themeProvider);

    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Confirmar Logout',
                style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1F2937))),
            content: Text('Deseja realmente sair da conta?',
                style: TextStyle(
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280))),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar',
                    style: TextStyle(
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280))),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white),
                child: const Text('Sair'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldLogout && mounted) {
      try {
        // ✅ CORREÇÃO: Logout real com navegação
        await AuthService.signOut();
        ref.read(userProvider.notifier).setUser(null);

        Navigator.of(context).pop(); // Fechar modal

        if (mounted) {
          context.go('/login'); // ✅ Navegar para login
          print('✅ Logout realizado com sucesso');
        }
      } catch (e) {
        print('❌ Erro no logout: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erro no logout: $e'),
                backgroundColor: const Color(0xFFEF4444)),
          );
        }
      }
    }
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isDark = ref.watch(themeProvider);
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 24,
              color: isSelected
                  ? const Color(0xFF8B5CF6)
                  : isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? const Color(0xFF8B5CF6)
                      : isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildCenterNavItem(int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Transform.translate(
        offset: const Offset(0, -8),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)])
                : const LinearGradient(
                    colors: [Color(0xFF6B7280), Color(0xFF9CA3AF)]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: isSelected
                      ? const Color(0xFF8B5CF6).withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            ],
          ),
          child:
              const Center(child: Text('🐾', style: TextStyle(fontSize: 24))),
        ),
      ),
    );
  }
}
