// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:petverse/data/models/user_currency.dart';
// import 'package:petverse/presentation/providers/currency_provider.dart';
// import 'package:petverse/presentation/providers/pet_provider.dart';
// import 'package:petverse/presentation/providers/theme_provider.dart';

// /// Tela principal do dashboard com visão geral das atividades
// class DashboardScreen extends ConsumerStatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends ConsumerState<DashboardScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late List<Animation<double>> _cardAnimations;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _initializeAnimations() {
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );

//     // Criar animações escalonadas para os cards
//     _cardAnimations = List.generate(6, (index) {
//       return Tween<double>(
//         begin: 0.0,
//         end: 1.0,
//       ).animate(CurvedAnimation(
//         parent: _animationController,
//         curve: Interval(
//           index * 0.1,
//           0.6 + (index * 0.1),
//           curve: Curves.easeOutCubic,
//         ),
//       ));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isLightTheme = ref.watch(isLightThemeProvider);
//     final userCurrency = ref.watch(userCurrencyProvider);
//     final currentPet = ref.watch(currentAdoptedPetProvider);
//     final petsStats = ref.watch(petsStatsProvider);
//     final hasCriticalPets = ref.watch(hasCriticalPetsProvider);

//     return Scaffold(
//       backgroundColor: isLightTheme ? Colors.grey[50] : Colors.grey[900],
//       body: RefreshIndicator(
//         onRefresh: _refreshData,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Saudação e resumo
//               _buildWelcomeSection(isLightTheme, userCurrency),
//               const SizedBox(height: 24),

//               // Cards de estatísticas
//               petsStats.when(
//                 data: (data) {
//                   return _buildStatsGrid(isLightTheme, userCurrency, data);
//                 },
//                 loading: () => const CircularProgressIndicator(),
//                 error: (err, stack) => Text('Erro: $err'),
//               ),
//               // _buildStatsGrid(isLightTheme, userCurrency,
//               //     petsStats ),
//               const SizedBox(height: 24),

//               // Status do pet atual
//               if (currentPet != null) ...[
//                 _buildCurrentPetSection(
//                     isLightTheme, currentPet, hasCriticalPets),
//                 const SizedBox(height: 24),
//               ],

//               // Ações rápidas
//               _buildQuickActions(isLightTheme),
//               const SizedBox(height: 24),

//               // Atividades recentes
//               _buildRecentActivities(isLightTheme),
//               const SizedBox(height: 24),

//               // Dicas e conquistas
//               _buildTipsAndAchievements(isLightTheme, userCurrency),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// Constrói a seção de boas-vindas
//   Widget _buildWelcomeSection(bool isLightTheme, UserCurrency userCurrency) {
//     return AnimatedBuilder(
//       animation: _cardAnimations[0],
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, 30 * (1 - _cardAnimations[0].value)),
//           child: Opacity(
//             opacity: _cardAnimations[0].value,
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: isLightTheme
//                       ? [Colors.purple[500]!, Colors.purple[700]!]
//                       : [Colors.purple[800]!, Colors.purple[900]!],
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.purple.withOpacity(0.3),
//                     blurRadius: 15,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           _getGreeting(),
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Você está no nível ${userCurrency.level}',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.white.withOpacity(0.9),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         LinearProgressIndicator(
//                           value: userCurrency.levelProgress,
//                           backgroundColor: Colors.white.withOpacity(0.3),
//                           valueColor:
//                               const AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Faltam ${userCurrency.xpToNextLevel} XP para o próximo nível',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.white.withOpacity(0.8),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: const Icon(
//                       Icons.emoji_events,
//                       color: Colors.white,
//                       size: 32,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   /// Constrói o grid de estatísticas
//   Widget _buildStatsGrid(bool isLightTheme, UserCurrency userCurrency,
//       Map<String, dynamic> petsStats) {
//     final stats = [
//       {
//         'title': 'Coins',
//         'value': userCurrency.coinsFormatted,
//         'icon': Icons.monetization_on,
//         'color': Colors.amber,
//         'subtitle': 'Total de moedas',
//       },
//       {
//         'title': 'Gems',
//         'value': userCurrency.gemsFormatted,
//         'icon': Icons.diamond,
//         'color': Colors.cyan,
//         'subtitle': 'Gemas coletadas',
//       },
//       {
//         'title': 'Pets',
//         'value': petsStats['totalPets'].toString(),
//         'icon': Icons.pets,
//         'color': Colors.purple,
//         'subtitle': 'Pets disponíveis',
//       },
//       {
//         'title': 'Adoções',
//         'value': petsStats['adoptedPets'].toString(),
//         'icon': Icons.favorite,
//         'color': Colors.red,
//         'subtitle': 'Pets adotados',
//       },
//     ];

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: 1.3,
//       ),
//       itemCount: stats.length,
//       itemBuilder: (context, index) {
//         final stat = stats[index];
//         return AnimatedBuilder(
//           animation: _cardAnimations[index + 1],
//           builder: (context, child) {
//             return Transform.scale(
//               scale: _cardAnimations[index + 1].value,
//               child: Opacity(
//                 opacity: _cardAnimations[index + 1].value,
//                 child: _buildStatCard(
//                   stat['title'] as String,
//                   stat['value'] as String,
//                   stat['subtitle'] as String,
//                   stat['icon'] as IconData,
//                   stat['color'] as Color,
//                   isLightTheme,
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   /// Constrói um card de estatística
//   Widget _buildStatCard(
//     String title,
//     String value,
//     String subtitle,
//     IconData icon,
//     Color color,
//     bool isLightTheme,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: isLightTheme ? Colors.white : Colors.grey[800],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: color.withOpacity(0.2),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Icon(
//                 icon,
//                 color: color,
//                 size: 24,
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: color,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const Spacer(),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.w700,
//               color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
//             ),
//           ),
//           Text(
//             subtitle,
//             style: TextStyle(
//               fontSize: 12,
//               color: isLightTheme ? Colors.grey[600] : Colors.grey[400],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Constrói a seção do pet atual
//   Widget _buildCurrentPetSection(bool isLightTheme, pet, bool hasCriticalPets) {
//     return AnimatedBuilder(
//       animation: _cardAnimations[5],
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, 30 * (1 - _cardAnimations[5].value)),
//           child: Opacity(
//             opacity: _cardAnimations[5].value,
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: isLightTheme ? Colors.white : Colors.grey[800],
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: hasCriticalPets
//                       ? Colors.orange[400]!
//                       : (isLightTheme
//                           ? Colors.green[300]!
//                           : Colors.green[600]!),
//                   width: 2,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 12,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         hasCriticalPets ? Icons.warning : Icons.pets,
//                         color: hasCriticalPets
//                             ? Colors.orange[600]
//                             : Colors.green[600],
//                         size: 24,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         hasCriticalPets
//                             ? 'Pet Precisa de Cuidados!'
//                             : 'Meu Pet',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: isLightTheme
//                               ? Colors.grey[800]
//                               : Colors.grey[100],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Container(
//                         width: 60,
//                         height: 60,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[200],
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: Colors.purple[300]!,
//                             width: 2,
//                           ),
//                         ),
//                         child: const Icon(
//                           Icons.pets,
//                           color: Colors.purple,
//                           size: 30,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               pet.name,
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w700,
//                                 color: isLightTheme
//                                     ? Colors.grey[800]
//                                     : Colors.grey[100],
//                               ),
//                             ),
//                             Text(
//                               '${pet.type} • Nível ${pet.level}',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: isLightTheme
//                                     ? Colors.grey[600]
//                                     : Colors.grey[400],
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             _buildPetStatusBars(pet, isLightTheme),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   /// Constrói as barras de status do pet
//   Widget _buildPetStatusBars(pet, bool isLightTheme) {
//     return Column(
//       children: [
//         _buildMiniStatusBar('Fome', pet.hunger, Colors.orange),
//         const SizedBox(height: 4),
//         _buildMiniStatusBar('Felicidade', pet.happiness, Colors.pink),
//         const SizedBox(height: 4),
//         _buildMiniStatusBar('Energia', pet.energy, Colors.green),
//       ],
//     );
//   }

//   /// Constrói uma barra de status mini
//   Widget _buildMiniStatusBar(String label, int value, Color color) {
//     return Row(
//       children: [
//         SizedBox(
//           width: 60,
//           child: Text(
//             label,
//             style: const TextStyle(fontSize: 12),
//           ),
//         ),
//         Expanded(
//           child: LinearProgressIndicator(
//             value: value / 100,
//             backgroundColor: Colors.grey[300],
//             valueColor: AlwaysStoppedAnimation<Color>(color),
//             minHeight: 4,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           '$value%',
//           style: const TextStyle(fontSize: 10),
//         ),
//       ],
//     );
//   }

//   /// Constrói as ações rápidas
//   Widget _buildQuickActions(bool isLightTheme) {
//     final actions = [
//       {
//         'title': 'Adotar Pet',
//         'icon': Icons.favorite_border,
//         'color': Colors.red,
//         'onTap': () => _navigateToAdoption(),
//       },
//       {
//         'title': 'Jogar',
//         'icon': Icons.games,
//         'color': Colors.blue,
//         'onTap': () => _navigateToGames(),
//       },
//       {
//         'title': 'Loja',
//         'icon': Icons.store,
//         'color': Colors.green,
//         'onTap': () => _navigateToStore(),
//       },
//       {
//         'title': 'Feed',
//         'icon': Icons.article,
//         'color': Colors.orange,
//         'onTap': () => _navigateToFeed(),
//       },
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Ações Rápidas',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
//           ),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: actions.map((action) {
//             return Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: _buildQuickActionCard(
//                   action['title'] as String,
//                   action['icon'] as IconData,
//                   action['color'] as Color,
//                   action['onTap'] as VoidCallback,
//                   isLightTheme,
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   /// Constrói um card de ação rápida
//   Widget _buildQuickActionCard(
//     String title,
//     IconData icon,
//     Color color,
//     VoidCallback onTap,
//     bool isLightTheme,
//   ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: isLightTheme ? Colors.white : Colors.grey[800],
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: color.withOpacity(0.2),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(
//                 icon,
//                 color: color,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//                 color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Constrói as atividades recentes
//   Widget _buildRecentActivities(bool isLightTheme) {
//     final activities = [
//       {
//         'title': 'Pet Max foi alimentado',
//         'time': 'Há 2 horas',
//         'icon': Icons.restaurant,
//         'color': Colors.orange,
//       },
//       {
//         'title': 'Novo pet disponível para adoção',
//         'time': 'Há 1 dia',
//         'icon': Icons.pets,
//         'color': Colors.purple,
//       },
//       {
//         'title': 'Coin coletado no jogo',
//         'time': 'Há 2 dias',
//         'icon': Icons.monetization_on,
//         'color': Colors.amber,
//       },
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Atividades Recentes',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
//           ),
//         ),
//         const SizedBox(height: 16),
//         Container(
//           decoration: BoxDecoration(
//             color: isLightTheme ? Colors.white : Colors.grey[800],
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             children: activities.asMap().entries.map((entry) {
//               final index = entry.key;
//               final activity = entry.value;
//               return Column(
//                 children: [
//                   ListTile(
//                     leading: Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: (activity['color'] as Color).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Icon(
//                         activity['icon'] as IconData,
//                         color: activity['color'] as Color,
//                         size: 20,
//                       ),
//                     ),
//                     title: Text(
//                       activity['title'] as String,
//                       style: TextStyle(
//                         fontWeight: FontWeight.w500,
//                         color:
//                             isLightTheme ? Colors.grey[800] : Colors.grey[100],
//                       ),
//                     ),
//                     subtitle: Text(
//                       activity['time'] as String,
//                       style: TextStyle(
//                         color:
//                             isLightTheme ? Colors.grey[600] : Colors.grey[400],
//                       ),
//                     ),
//                   ),
//                   if (index < activities.length - 1)
//                     Divider(
//                       color: isLightTheme ? Colors.grey[200] : Colors.grey[700],
//                       height: 1,
//                     ),
//                 ],
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }

//   /// Constrói dicas e conquistas
//   Widget _buildTipsAndAchievements(
//       bool isLightTheme, UserCurrency userCurrency) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Dicas & Conquistas',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//             color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
//           ),
//         ),
//         const SizedBox(height: 16),
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 Colors.blue[400]!,
//                 Colors.blue[600]!,
//               ],
//             ),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               const Icon(
//                 Icons.lightbulb,
//                 color: Colors.white,
//                 size: 32,
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Dica do Dia',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Alimente seu pet regularmente para mantê-lo feliz e saudável!',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.white.withOpacity(0.9),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   /// Retorna uma saudação baseada no horário
//   String _getGreeting() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) {
//       return 'Bom dia!';
//     } else if (hour < 18) {
//       return 'Boa tarde!';
//     } else {
//       return 'Boa noite!';
//     }
//   }

//   /// Refresh dos dados
//   Future<void> _refreshData() async {
//     await Future.delayed(const Duration(seconds: 1));
//     // Implementar refresh real aqui
//   }

//   // Métodos de navegação
//   void _navigateToAdoption() {
//     // Implementar navegação para adoção
//   }

//   void _navigateToGames() {
//     // Implementar navegação para jogos
//   }

//   void _navigateToStore() {
//     // Implementar navegação para loja
//   }

//   void _navigateToFeed() {
//     // Implementar navegação para feed
//   }
// }

// lib/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/service/dashboard_service.dart';
import 'package:petverse/presentation/providers/currency_provider.dart';
import 'package:petverse/presentation/providers/dashboard_provider.dart';
import 'package:petverse/presentation/providers/pet_provider.dart';
import 'package:petverse/presentation/providers/theme_provider.dart';
import 'package:petverse/presentation/widgets/dashboard_widgets.dart';

/// Tela principal do dashboard com funcionalidades reais
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Inicia sessão de tempo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionTimerProvider.notifier).startSession();
      _checkAchievements();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();

    // Finaliza sessão de tempo
    ref.read(sessionTimerProvider.notifier).endSession();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(sessionTimerProvider.notifier).endSession();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(sessionTimerProvider.notifier).startSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(isLightThemeProvider);

    return Scaffold(
      backgroundColor: isLightTheme ? Colors.grey[50] : Colors.grey[900],
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // App Bar customizada
            _buildSliverAppBar(isLightTheme),

            // Conteúdo principal
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Seção de boas-vindas
                  _buildWelcomeSection(isLightTheme),
                  const SizedBox(height: 24),

                  // Grid de estatísticas
                  _buildStatsGrid(isLightTheme),
                  const SizedBox(height: 24),

                  // Status do pet (se tiver)
                  _buildPetStatusSection(isLightTheme),

                  // Ações rápidas sugeridas
                  _buildQuickActionsSection(isLightTheme),
                  const SizedBox(height: 24),

                  // Dica do dia
                  _buildDailyTipSection(isLightTheme),
                  const SizedBox(height: 24),

                  // Atividades recentes
                  _buildRecentActivitiesSection(isLightTheme),
                  const SizedBox(height: 80), // Espaço para navigation bar
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói a app bar customizada
  Widget _buildSliverAppBar(bool isLightTheme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLightTheme
                ? [Colors.purple[500]!, Colors.purple[700]!]
                : [Colors.purple[800]!, Colors.purple[900]!],
          ),
        ),
        child: FlexibleSpaceBar(
          title: const Text(
            'Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          background: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isLightTheme
                    ? [Colors.purple[400]!, Colors.purple[600]!]
                    : [Colors.purple[700]!, Colors.purple[900]!],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói a seção de boas-vindas
  Widget _buildWelcomeSection(bool isLightTheme) {
    final welcomeMessage = ref.watch(welcomeMessageProvider);
    final userCurrency = ref.watch(userCurrencyProvider);
    final sessionMinutes = ref.watch(sessionTimerProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLightTheme
              ? [Colors.purple[500]!, Colors.purple[700]!]
              : [Colors.purple[800]!, Colors.purple[900]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      welcomeMessage,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nível ${userCurrency.level} • ${userCurrency.xpFormatted} XP',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.timer,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${sessionMinutes}m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de progresso do nível
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progresso do Nível',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '${userCurrency.xp}/${userCurrency.xpToNextLevel + userCurrency.xp} XP',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: userCurrency.levelProgress,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói o grid de estatísticas
  Widget _buildStatsGrid(bool isLightTheme) {
    final userCurrency = ref.watch(userCurrencyProvider);
    final dashboardStats = ref.watch(dashboardStatsProvider);
    final petStats = ref.watch(petStatsStreamProvider);

    return dashboardStats.when(
      data: (stats) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            AnimatedStatCard(
              title: 'Coins',
              value: userCurrency.coinsFormatted,
              subtitle: 'Total de moedas',
              icon: Icons.monetization_on,
              color: Colors.amber,
              onTap: () => _navigateToStore(),
            ),
            AnimatedStatCard(
              title: 'Gems',
              value: userCurrency.gemsFormatted,
              subtitle: 'Gemas coletadas',
              icon: Icons.diamond,
              color: Colors.cyan,
              onTap: () => _navigateToStore(),
            ),
            petStats.when(
              data: (petData) => AnimatedStatCard(
                title: 'Pets',
                value: petData['total'].toString(),
                subtitle: '${petData['adopted']} adotados',
                icon: Icons.pets,
                color: Colors.purple,
                showTrend: true,
                trendValue: petData['adopted']! > 0 ? 5.2 : 0,
                onTap: () => _navigateToPets(),
              ),
              loading: () => const AnimatedStatCard(
                title: 'Pets',
                value: '0',
                subtitle: 'Carregando...',
                icon: Icons.pets,
                color: Colors.purple,
              ),
              error: (_, __) => const AnimatedStatCard(
                title: 'Pets',
                value: '0',
                subtitle: 'Erro ao carregar',
                icon: Icons.pets,
                color: Colors.purple,
              ),
            ),
            AnimatedStatCard(
              title: 'Sequência',
              value: stats.dailyStreak.toString(),
              subtitle: 'Dias consecutivos',
              icon: Icons.local_fire_department,
              color: Colors.orange,
              showTrend: true,
              trendValue: stats.dailyStreak > 0 ? 10.0 : -100.0,
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => Center(
        child: Text('Erro ao carregar estatísticas: $error'),
      ),
    );
  }

  /// Constrói a seção de status do pet
  Widget _buildPetStatusSection(bool isLightTheme) {
    final currentPet = ref.watch(currentAdoptedPetProvider);

    if (currentPet == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.white : Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: currentPet.isCriticalStatus
              ? Colors.orange[400]!
              : (isLightTheme ? Colors.green[300]! : Colors.green[600]!),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                currentPet.isCriticalStatus ? Icons.warning : Icons.pets,
                color: currentPet.isCriticalStatus
                    ? Colors.orange[600]
                    : Colors.green[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                currentPet.isCriticalStatus
                    ? '${currentPet.name} precisa de cuidados!'
                    : 'Status do ${currentPet.name}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _navigateToPets(),
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Ver Pet'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.purple[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPetStatBar(
                  '🍔 Fome',
                  currentPet.hunger,
                  Colors.orange,
                  isLightTheme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPetStatBar(
                  '😊 Felicidade',
                  currentPet.happiness,
                  Colors.pink,
                  isLightTheme,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPetStatBar(
                  '⚡ Energia',
                  currentPet.energy,
                  Colors.green,
                  isLightTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói uma barra de stat do pet
  Widget _buildPetStatBar(
      String label, int value, Color color, bool isLightTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isLightTheme ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: isLightTheme ? Colors.grey[200] : Colors.grey[700],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
        const SizedBox(height: 2),
        Text(
          '$value%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Constrói a seção de ações rápidas
  Widget _buildQuickActionsSection(bool isLightTheme) {
    final suggestions = ref.watch(quickActionSuggestionsProvider);

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Sugeridas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return SizedBox(
                width: 120,
                child: QuickActionCard(
                  suggestion: suggestion,
                  onTap: () => _handleQuickAction(suggestion.action),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Constrói a seção de dica do dia
  Widget _buildDailyTipSection(bool isLightTheme) {
    final dailyTip = ref.watch(dailyTipProvider);

    return dailyTip.when(
      data: (tip) {
        if (tip == null) return const SizedBox.shrink();

        return DailyTipCard(
          tip: tip,
          onDismiss: () {
            // Implementar dismiss da dica
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Constrói a seção de atividades recentes
  Widget _buildRecentActivitiesSection(bool isLightTheme) {
    final activities = ref.watch(recentActivitiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Atividades Recentes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
              ),
            ),
            TextButton(
              onPressed: () => _showAllActivities(),
              child: const Text('Ver Todas'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        activities.when(
          data: (activityList) {
            if (activityList.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isLightTheme ? Colors.white : Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color:
                            isLightTheme ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhuma atividade recente',
                        style: TextStyle(
                          color: isLightTheme
                              ? Colors.grey[600]
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: isLightTheme ? Colors.white : Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activityList.length > 5 ? 5 : activityList.length,
                separatorBuilder: (_, __) => Divider(
                  color: isLightTheme ? Colors.grey[200] : Colors.grey[700],
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  return RecentActivityTile(
                    activity: activityList[index],
                    onTap: () => _showActivityDetails(activityList[index]),
                  );
                },
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => Center(
            child: Text('Erro ao carregar atividades: $error'),
          ),
        ),
      ],
    );
  }

  // Métodos auxiliares

  /// Atualiza dados do dashboard
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);

    try {
      // Força atualização dos providers
      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(dailyTipProvider);

      await Future.delayed(const Duration(seconds: 1));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Verifica e desbloqueia conquistas
  void _checkAchievements() async {
    final achievements = ref.read(availableAchievementsProvider);
    final actions = ref.read(dashboardActionsProvider.notifier);

    for (final achievement in achievements) {
      if (achievement.isCompleted) {
        await actions.completeAchievement(
          achievement.id,
          achievement.rewardCoins,
          achievement.rewardGems,
          achievement.rewardXp,
        );

        if (mounted) {
          _showAchievementUnlocked(achievement);
        }
      }
    }
  }

  /// Mostra conquista desbloqueada
  void _showAchievementUnlocked(AchievementCheck achievement) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Conquista Desbloqueada!',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    achievement.name,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.amber[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Manipula ação rápida selecionada
  void _handleQuickAction(QuickActionType action) {
    switch (action) {
      case QuickActionType.adoptPet:
        _navigateToPets();
        break;
      case QuickActionType.carePet:
        _navigateToPets();
        break;
      case QuickActionType.playGame:
        _navigateToGames();
        break;
      case QuickActionType.visitStore:
        _navigateToStore();
        break;
      case QuickActionType.checkFeed:
        _navigateToFeed();
        break;
    }
  }

  /// Mostra todas as atividades
  void _showAllActivities() {
    // Implementar navegação para lista completa de atividades
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lista completa de atividades em desenvolvimento'),
      ),
    );
  }

  /// Mostra detalhes de uma atividade
  void _showActivityDetails(RecentActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(activity.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.description),
            const SizedBox(height: 8),
            Text(
              'Tipo: ${activity.type}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Data: ${_formatDateTime(activity.timestamp)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} às ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Métodos de navegação (para integrar com o sistema de navegação existente)
  void _navigateToPets() {
    // Implementar navegação
    debugPrint('Navegar para Pets');
  }

  void _navigateToStore() {
    // Implementar navegação
    debugPrint('Navegar para Loja');
  }

  void _navigateToGames() {
    // Implementar navegação
    debugPrint('Navegar para Jogos');
  }

  void _navigateToFeed() {
    // Implementar navegação
    debugPrint('Navegar para Feed');
  }
}
