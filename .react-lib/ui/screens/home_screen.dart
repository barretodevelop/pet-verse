import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Para ícones
import '../../core/app_notifier.dart'; // Para acessar o appServiceProvider
import '../components/pet_slot.dart';
// Importa as abas
import '../tabs/dashboard_tab.dart';
import '../tabs/feed_tab.dart';
import '../tabs/missions_tab.dart';
import '../tabs/pet_tab.dart';
import '../tabs/shop_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 2; // Começa na aba 'Pet' (índice 2)
  late PageController _pageController; // Controla a transição entre as abas

  bool _showSettingsSheet = false;
  bool _showAdoptionFlow = false;
  bool _showProfileSheet = false;
  bool _showAIGenerationSheet = false;

  // Estado local para o modal de confirmação de desbloqueio
  final ValueNotifier<bool> _showUnlockConfirm = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _showUnlockConfirm.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index); // Sem animação para trocas rápidas
    });
  }

  // Função para lidar com o desbloqueio (passada para PetSlots)
  void _handleUnlockSlotRequest() {
    _showUnlockConfirm.value = true;
  }

  // Função para lidar com o desbloqueio real
  void _handleUnlockSlotConfirm() {
    final appService = ref.read(appServiceProvider.notifier);
    if (appService.unlockSlot()) {
      // Chama o método do serviço
      _showUnlockConfirm.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appServiceProvider);
    final appService = ref.read(appServiceProvider.notifier);

    final user = appState.user;
    final coins = appState.coins;
    final gems = appState.gems;
    final isDark = appState.isDark;

    final tabs = [
      {'id': 'feed', 'label': 'Feed', 'icon': LucideIcons.rss, 'component': const FeedTab()},
      {
        'id': 'missions',
        'label': 'Missões',
        'icon': LucideIcons.target,
        'component': const MissionsTab()
      },
      {'id': 'pet', 'label': 'Pet', 'icon': '🐾', 'component': const PetTab(), 'isCenter': true},
      {
        'id': 'shop',
        'label': 'Loja',
        'icon': LucideIcons.shoppingBag,
        'component': const ShopTab()
      },
      {
        'id': 'dashboard',
        'label': 'Dashboard',
        'icon': LucideIcons.home,
        'component': const DashboardTab()
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A202C) : Colors.white, // bg-gray-900 ou bg-white

      // App Bar
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF2D3748) : Colors.white, // bg-gray-800 ou bg-white
        elevation: 4.0, // shadow-lg
        toolbarHeight: 80.0, // Aumenta a altura para acomodar o conteúdo
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24), // Cantos arredondados na parte inferior
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Perfil do Usuário
            GestureDetector(
              onTap: () => setState(() => _showProfileSheet = true),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24, // w-12 h-12
                    backgroundColor: Colors.purple.shade500, // Cor de fundo do avatar
                    child: Text(
                      user?.avatar ?? '?',
                      style: const TextStyle(fontSize: 24), // text-3xl
                    ),
                  ),
                  const SizedBox(width: 12), // space-x-3
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.username ?? 'Convidado',
                        style: TextStyle(
                          fontSize: 18, // text-lg
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.grey.shade800, // Corrected
                        ),
                      ),
                      Row(
                        children: [
                          Icon(LucideIcons.star,
                              size: 16, color: Colors.yellow.shade500), // Corrected
                          const SizedBox(width: 4),
                          Text(
                            'Nível ${user?.level ?? 1} • ${(user?.xp ?? 0) % 100}/100 XP', // Corrected
                            style: TextStyle(
                              fontSize: 12, // text-sm
                              color:
                                  isDark ? Colors.grey.shade300 : Colors.grey.shade600, // Corrected
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botões de Ação e Recursos
            Row(
              children: [
                // Botão de Gerar Pet Único (IA)
                IconButton(
                  onPressed: () => setState(() => _showAIGenerationSheet = true),
                  icon: Icon(LucideIcons.wand2,
                      size: 24,
                      color: isDark ? Colors.pink.shade300 : Colors.pink.shade600), // Corrected
                  tooltip: 'Gerar Pet Único com IA',
                  style: IconButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.grey.shade700 : Colors.grey.shade100, // Corrected
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(width: 16), // space-x-4

                // Moedas
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100, // bg-yellow-100
                    borderRadius: BorderRadius.circular(99), // rounded-full
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.coins, size: 16, color: Colors.yellow.shade600), // Corrected
                      const SizedBox(width: 4),
                      Text(
                        '$coins',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow.shade800, // Corrected
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Gemas
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100, // bg-purple-100
                    borderRadius: BorderRadius.circular(99), // rounded-full
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.gem, size: 16, color: Colors.purple.shade600), // Corrected
                      const SizedBox(width: 4),
                      Text(
                        '$gems',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade800, // Corrected
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Botão de Configurações
                IconButton(
                  onPressed: () => setState(() => _showSettingsSheet = true),
                  icon: Icon(LucideIcons.settings,
                      size: 24,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade600), // Corrected
                  tooltip: 'Configurações',
                  style: IconButton.styleFrom(
                    backgroundColor:
                        isDark ? Colors.grey.shade700 : Colors.grey.shade100, // Corrected
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // Pet Slots (agora faz parte do body do Scaffold)
      body: Column(
        children: [
          PetSlots(onSlotClick: _handleUnlockSlotRequest), // Passa o callback para PetSlots
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: tabs.map((tab) => tab['component'] as Widget).toList(),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2D3748) : Colors.white, // bg-gray-800 ou bg-white
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent, // Transparente para usar a cor do Container
          elevation: 0, // Sem sombra padrão
          type: BottomNavigationBarType.fixed, // Itens fixos
          selectedItemColor: Colors.purple.shade600,
          unselectedItemColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600, // Corrected
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: tabs.map((tab) {
            bool isCenterButton = tab['isCenter'] == true;
            return BottomNavigationBarItem(
              icon: isCenterButton
                  ? Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _selectedIndex == tabs.indexOf(tab)
                            ? Colors.purple.shade600 // bg-gradient-to-r from-purple-600 to-blue-600
                            : isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade200, // Corrected
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _selectedIndex == tabs.indexOf(tab)
                                ? Colors.purple.shade300.withOpacity(0.6) // Corrected
                                : Colors.transparent,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          tab['icon'].toString(),
                          style: const TextStyle(fontSize: 28, color: Colors.white),
                        ),
                      ),
                    )
                  : Icon(tab['icon'] is IconData ? tab['icon'] as IconData : null, size: 24),
              label: tab['label'] as String,
            );
          }).toList(),
        ),
      ),

      // // Modals e Sheets (serão renderizados acima do Scaffold)
      // // Settings Sheet
      //   (_showSettingsSheet)
      //   AppBottomSheet(
      //     show: _showSettingsSheet,
      //     onClose: () => setState(() => _showSettingsSheet = false),
      //     title: 'Configurações',
      //     children: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         SwitchListTile(
      //           title: Text('Modo Escuro', style: TextStyle(color: isDark ? Colors.white : Colors.grey.shade800)), // Corrected
      //           subtitle: Text('Alternar tema do aplicativo', style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade600)), // Corrected
      //           value: isDark,
      //           onChanged: (value) {
      //             appService.setIsDark(value);
      //           },
      //           activeColor: Colors.purple.shade600,
      //         ),
      //         const SizedBox(height: 16),
      //         ElevatedButton.icon(
      //           onPressed: () {
      //             appService.logout();
      //             setState(() => _showSettingsSheet = false);
      //             // A navegação para o LoginScreen será tratada em main.dart
      //           },
      //           icon: const Icon(LucideIcons.logOut),
      //           label: const Text('Sair da Conta'),
      //           style: ElevatedButton.styleFrom(
      //             backgroundColor: Colors.red.shade400,
      //             foregroundColor: Colors.white,
      //             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),

      // // Adoption Flow Sheet
      //   (_showAdoptionFlow)
      //   AdoptionFlowSheet(
      //     show: _showAdoptionFlow,
      //     onClose: () => setState(() => _showAdoptionFlow = false),
      //     onAIGenerationRequest: () {
      //       // Fecha o AdoptionFlow e abre o AIPetGenerationSheet
      //       setState(() {
      //         _showAdoptionFlow = false;
      //         _showAIGenerationSheet = true;
      //       });
      //     },
      //   ),

      // // AI Pet Generation Sheet
      //   (_showAIGenerationSheet)
      //   AIPetGenerationSheet(
      //     show: _showAIGenerationSheet,
      //     onClose: () => setState(() => _showAIGenerationSheet = false),
      //   ),

      // // User Profile Sheet
      //   (_showProfileSheet)
      //   UserProfileSheet(
      //     show: _showProfileSheet,
      //     onClose: () => setState(() => _showProfileSheet = false),
      //   ),

      // // Confirmation Modal (para desbloquear slot, gerenciado aqui)
      // ValueListenableBuilder<bool>(
      //   valueListenable: _showUnlockConfirm,
      //   builder: (context, show, child) {
      //     return ConfirmationModal(
      //       show: show,
      //       title: 'Desbloquear Slot',
      //       message: 'Deseja desbloquear um novo slot para pets?',
      //       cost: 5,
      //       onConfirm:
      //           _handleUnlockSlotConfirm, // Chama a função que usa o serviço
      //       onCancel: () => _showUnlockConfirm.value = false,
      //     );
      //   },
      // ),
    );
  }
}
