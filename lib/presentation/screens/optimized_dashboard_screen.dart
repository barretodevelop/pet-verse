// // lib/presentation/screens/optimized_dashboard_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:petverse/core/providers/secure_provider.dart';
// import 'package:petverse/core/providers/selector_extensions.dart';

// import '../../core/performance/rebuild_manager.dart';
// import '../../core/providers/unified_optimized_providers.dart';
// import '../../data/models/pet.dart';
// import '../providers/optimized_currency_provider.dart';
// import '../providers/optimized_pet_provider.dart';

// /// Tela dashboard otimizada que demonstra todas as implementações da FASE 3
// class OptimizedDashboardScreen extends UnifiedConsumerWidget {
//   const OptimizedDashboardScreen({super.key});

//   @override
//   Widget buildContent(
//       BuildContext context, WidgetRef ref, UnifiedAppState state) {
//     return Scaffold(
//       appBar: _buildOptimizedAppBar(context, ref),
//       body: _buildOptimizedBody(context, ref, state),
//       floatingActionButton: _buildFloatingActionButton(context, ref),
//     );
//   }

//   PreferredSizeWidget _buildOptimizedAppBar(
//       BuildContext context, WidgetRef ref) {
//     return AppBar(
//       title: const Text('Pet Dashboard'),
//       elevation: 0,
//       backgroundColor: Theme.of(context).primaryColor,
//       foregroundColor: Colors.white,
//       actions: [
//         // Monitor de rebuilds (apenas em debug)
//         if (ref.watch(isDebugModeProvider))
//           IconButton(
//             icon: const Icon(Icons.analytics),
//             onPressed: () => _showRebuildStats(context),
//           ),
//         // Botão de refresh
//         IconButton(
//           icon: const Icon(Icons.refresh),
//           onPressed: () => ref.refreshAllData(),
//         ),
//       ],
//     );
//   }

//   Widget _buildOptimizedBody(
//       BuildContext context, WidgetRef ref, UnifiedAppState state) {
//     return RefreshIndicator(
//       onRefresh: () => ref.refreshAllData(),
//       child: CustomScrollView(
//         slivers: [
//           // Header com informações do usuário
//           SliverToBoxAdapter(
//             child: _OptimizedUserHeader(),
//           ),

//           // Estatísticas rápidas
//           SliverToBoxAdapter(
//             child: _OptimizedQuickStats(),
//           ),

//           // Pets críticos (se houver)
//           SliverToBoxAdapter(
//             child: _CriticalPetsSection(),
//           ),

//           // Lista de pets otimizada
//           SliverToBoxAdapter(
//             child: _OptimizedPetsSection(),
//           ),

//           // Seção de ações rápidas
//           SliverToBoxAdapter(
//             child: _QuickActionsSection(),
//           ),

//           // Debug info (apenas em desenvolvimento)
//           if (ref.watch(isDebugModeProvider))
//             const SliverToBoxAdapter(
//                 // child: _DebugSection(),
//                 ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFloatingActionButton(BuildContext context, WidgetRef ref) {
//     return FloatingActionButton.extended(
//       onPressed: () => _showGeneratePetDialog(context, ref),
//       icon: const Icon(Icons.add),
//       label: const Text('Gerar Pet'),
//     );
//   }

//   void _showRebuildStats(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Rebuild Statistics'),
//         content: const SizedBox(
//           width: double.maxFinite,
//           child: RebuildStatsWidget(showDetails: true),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showGeneratePetDialog(BuildContext context, WidgetRef ref) {
//     // Implementar diálogo de geração de pet
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Gerar Novo Pet'),
//         content: const Text('Funcionalidade de geração será implementada'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancelar'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Gerar'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Header do usuário otimizado
// class _OptimizedUserHeader extends OptimizedConsumerWidget {
//   @override
//   Widget buildContent(
//       BuildContext context, WidgetRef ref, UnifiedAppState state) {
//     final userContext = ref.userContext;

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Theme.of(context).primaryColor,
//             Theme.of(context).primaryColor.withOpacity(0.8),
//           ],
//         ),
//       ),
//       child: Column(
//         children: [
//           // Saudação e avatar
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 30,
//                 backgroundColor: Colors.white.withOpacity(0.2),
//                 child: const Icon(
//                   Icons.person,
//                   size: 35,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       _getGreeting(),
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.9),
//                         fontSize: 14,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       userContext?.userId.substring(0, 8) ?? 'Usuário',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           // Moeda e nível otimizados
//           Row(
//             children: [
//               const Expanded(
//                 child: OptimizedCurrencyDisplayWidget(
//                   showBackground: false,
//                   showLevel: false,
//                   padding: EdgeInsets.zero,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               SizedBox(
//                 width: 120,
//                 child: OptimizedLevelProgressWidget(
//                   showLabel: true,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   String _getGreeting() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) return 'Bom dia!';
//     if (hour < 18) return 'Boa tarde!';
//     return 'Boa noite!';
//   }

//   Widget OptimizedLevelProgressWidget({required bool showLabel}) {
//     return const Placeholder();
//   }
// }

// class OptimizedCurrencyDisplayWidget extends OptimizedConsumerWidget {
//   const OptimizedCurrencyDisplayWidget({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return const Placeholder();
//   }
// }

// /// Estatísticas rápidas otimizadas
// class _OptimizedQuickStats extends OptimizedConsumerWidget {
//   @override
//   Widget buildContent(
//       BuildContext context, WidgetRef ref, UnifiedAppState state) {
//     // Usa selectors específicos para evitar rebuilds
//     final totalPets = ref.petsCount;
//     final availablePets = ref.availablePets.length;
//     final criticalPets = ref.criticalPets.length;
//     final globalStats = ref.globalStats;

//     return Container(
//       margin: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           Expanded(
//             child: _StatCard(
//               title: 'Total Pets',
//               value: totalPets.toString(),
//               icon: Icons.pets,
//               color: Colors.blue,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: _StatCard(
//               title: 'Disponíveis',
//               value: availablePets.toString(),
//               icon: Icons.favorite,
//               color: Colors.green,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: _StatCard(
//               title: 'Críticos',
//               value: criticalPets.toString(),
//               icon: Icons.warning,
//               color: Colors.red,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: _StatCard(
//               title: 'Taxa Adoção',
//               value: '${globalStats.adoptionRate.toStringAsFixed(1)}%',
//               icon: Icons.trending_up,
//               color: Colors.purple,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Card de estatística individual
// class _StatCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color color;

//   const _StatCard({
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 24),
//             const SizedBox(height: 8),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             Text(
//               title,
//               style: Theme.of(context).textTheme.bodySmall,
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Seção de pets críticos
// class _CriticalPetsSection extends OptimizedConsumerWidget {
//   @override
//   Widget buildContent(
//       BuildContext context, WidgetRef ref, UnifiedAppState state) {
//     final criticalPets = ref.criticalPets;

//     if (criticalPets.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.warning, color: Colors.red[600]),
//               const SizedBox(width: 8),
//               Text(
//                 'Pets Precisando de Atenção',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red[600],
//                     ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             height: 120,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: criticalPets.length,
//               itemBuilder: (context, index) {
//                 final pet = criticalPets[index];
//                 return Container(
//                   width: 200,
//                   margin: const EdgeInsets.only(right: 12),
//                   child: Card(
//                     color: Colors.red[50],
//                     child: Padding(
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             pet.name,
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 8),
//                           Expanded(
//                             child: OptimizedPetStatsWidget(
//                               petId: pet.id,
//                               // showProgress: false,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Widget OptimizedPetStatsWidget() {
//   return const Placeholder();
// }

// /// Seção principal de pets
// class _OptimizedPetsSection extends OptimizedConsumerWidget {
//   @override
//   Widget buildContent(
//       BuildContext context, WidgetRef ref, UnifiedAppState state) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Seus Pets',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   // Navegar para lista completa
//                 },
//                 child: const Text('Ver Todos'),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             height: 280,
//             child: OptimizedPetListWidget(
//               onPetTap: (pet) => _showPetDetails(context, ref, pet),
//               itemBuilder: (pet) => Container(
//                 width: 200,
//                 margin: const EdgeInsets.only(right: 12),
//                 child: OptimizedPetCardWidget(
//                   petId: pet.id,
//                   showStats: true,
//                   showActions: true,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showPetDetails(BuildContext context, WidgetRef ref, Pet pet) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => DraggableScrollableSheet(
//         initialChildSize: 0.7,
//         maxChildSize: 0.9,
//         minChildSize: 0.5,
//         expand: false,
//         builder: (context, scrollController) => Container(
//           decoration: const BoxDecoration(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             color: Colors.white,
//           ),
//           child: Column(
//             children: [
//               // Handle
//               Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       OptimizedPetCardWidget(
//                         petId: pet.id,
//                         showStats: true,
//                       ),
//                       const SizedBox(height: 16),
//                       // SmartPetInteractionWidget(petId: pet.id),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // TODO: implement build
//     throw UnimplementedError();
//   }
// }

// class OptimizedPetListWidget extends OptimizedConsumerWidget {
//   const OptimizedPetListWidget({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return const Placeholder();
//   }
// }

// /// Seção de ações rápidas
// class _QuickActionsSection extends OptimizedConsumerWidget {
//   @override
//   Widget buildContent(
//       BuildContext context, WidgetRef ref, UnifiedAppState state) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Ações Rápidas',
//             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _QuickActionCard(
//                   title: 'Recompensa Diária',
//                   subtitle: 'Claim your daily reward',
//                   icon: Icons.card_giftcard,
//                   color: Colors.orange,
//                   onTap: () => _claimDailyReward(ref),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: _QuickActionCard(
//                   title: 'Converter Gems',
//                   subtitle: 'Exchange gems for coins',
//                   icon: Icons.swap_horiz,
//                   color: Colors.blue,
//                   onTap: () => _showConversionDialog(context, ref),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _claimDailyReward(WidgetRef ref) {
//     final success = ref.claimDailyReward();
//     if (success) {
//       // Mostrar feedback de sucesso
//     }
//   }

//   void _showConversionDialog(BuildContext context, WidgetRef ref) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Converter Gems'),
//         content: const Text('Funcionalidade de conversão será implementada'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancelar'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // TODO: implement build
//     throw UnimplementedError();
//   }
// }

// /// Card de ação rápida
// class _QuickActionCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;

//   const _QuickActionCard({
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(8),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               Icon(icon, color: color, size: 32),
//               const SizedBox(height: 8),
//               Text(
//                 title,
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 subtitle,
//                 style: Theme.of(context).textTheme.bodySmall,
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // /// Seção de debug (apenas desenvolvimento)
// // class _DebugSection extends OptimizedConsumerWidget {
// //   @override
// //   Widget buildContent(
// //       BuildContext context, WidgetRef ref, UnifiedAppState state) {
// //     return Container(
// //       margin: const EdgeInsets.all(16),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'Debug Info',
// //             style: Theme.of(context).textTheme.titleMedium?.copyWith(
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //           ),
// //           const SizedBox(height: 8),

// //           // Rebuild stats
// //           const RebuildStatsWidget(showDetails: true),

// //           const SizedBox(height: 8),

// //           // App state debug
// //           const AppStateDebugWidget(),

// //           const SizedBox(height: 8),

// //           // Performance metrics
// //           _PerformanceMetricsCard(),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // /// Card de métricas de performance
// // class _PerformanceMetricsCard extends OptimizedConsumerWidget {
// //   @override
// //   Widget buildContent(
// //       BuildContext context, WidgetRef ref, UnifiedAppState state) {
// //     final metrics = ref.performanceMetrics;

// //     return Card(
// //       child: Padding(
// //         padding: const EdgeInsets.all(12),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               'Performance Metrics',
// //               style: Theme.of(context).textTheme.titleSmall?.copyWith(
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //             ),
// //             const SizedBox(height: 8),
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: Text(
// //                       'Cache Hit Rate: ${(metrics.cacheStats.hitRate * 100).toStringAsFixed(1)}%'),
// //                 ),
// //                 Expanded(
// //                   child: Text(
// //                       'Score: ${metrics.performanceScore.toStringAsFixed(0)}'),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 4),
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: Text('Memory Usage: ${metrics.memoryUsage}'),
// //                 ),
// //                 Expanded(
// //                   child: Text('Grade: ${metrics.performanceGrade}'),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // /// Provider para verificar modo debug
// // final isDebugModeProvider = Provider<bool>((ref) {
// //   return ref.watch(appConfigProvider).debugMode;
// // });

// /// Extensions para facilitar o uso na tela
// extension DashboardExtensions on WidgetRef {
//   /// Shortcuts para ações comuns
//   void showPetInteraction(String petId) {
//     // Implementar
//   }

//   void showCurrencyConversion() {
//     // Implementar
//   }

//   void navigateToPetDetails(String petId) {
//     // Implementar
//   }
// }
