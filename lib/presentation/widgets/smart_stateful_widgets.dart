// // lib/presentation/widgets/smart_stateful_widgets.dart
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:petverse/core/providers/firebase_providers.dart';

// import '../../core/providers/performance_providers.dart';
// import '../../core/providers/selector_extensions.dart';
// import '../../core/providers/unified_optimized_providers.dart';
// import '../providers/optimized_currency_provider.dart';
// import '../providers/optimized_pet_provider.dart';

// /// Widget que usa ConsumerStatefulWidget APENAS quando necessário
// /// (tem estado local complexo que interage com providers)
// class SmartPetInteractionWidget extends ConsumerStatefulWidget {
//   final String petId;

//   const SmartPetInteractionWidget({
//     super.key,
//     required this.petId,
//   });

//   @override
//   ConsumerState<SmartPetInteractionWidget> createState() =>
//       _SmartPetInteractionWidgetState();
// }

// class _SmartPetInteractionWidgetState
//     extends ConsumerState<SmartPetInteractionWidget>
//     with OptimizedConsumerStateMixin, TickerProviderStateMixin {
//   // Estado local que JUSTIFICA o uso de StatefulWidget
//   late AnimationController _actionAnimationController;
//   late AnimationController _progressAnimationController;
//   Timer? _actionTimer;
//   PetAction? _currentAction;
//   bool _isActionInProgress = false;
//   int _actionProgress = 0;

//   @override
//   void initState() {
//     super.initState();

//     // Inicializa animações
//     _actionAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _progressAnimationController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     );
//   }

//   @override
//   void dispose() {
//     _actionAnimationController.dispose();
//     _progressAnimationController.dispose();
//     _actionTimer?.cancel();
//     super.dispose();
//   }

//   // ========================================
//   // LISTENERS OTIMIZADOS
//   // ========================================

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();

//     // Listen otimizado que só dispara quando pet stats mudam
//     listenOptimized(
//       petStatsProvider(widget.petId),
//       (stats) => stats,
//       (previous, next) {
//         if (next != null && previous != null) {
//           _handleStatsChange(previous, next);
//         }
//       },
//       shouldNotify: (prev, next) => prev != next,
//     );
//   }

//   void _handleStatsChange(PetStats previous, PetStats current) {
//     // Só executa se houve mudança significativa
//     if ((current.hunger - previous.hunger).abs() > 5 ||
//         (current.happiness - previous.happiness).abs() > 5) {
//       // Anima mudança nas stats
//       _actionAnimationController.forward().then((_) {
//         _actionAnimationController.reverse();
//       });
//     }
//   }

//   // ========================================
//   // AÇÕES COM ESTADO LOCAL
//   // ========================================

//   Future<void> _performAction(PetAction action) async {
//     if (_isActionInProgress) return;

//     setState(() {
//       _isActionInProgress = true;
//       _currentAction = action;
//       _actionProgress = 0;
//     });

//     // Inicia animação de progresso
//     _progressAnimationController.reset();
//     _progressAnimationController.forward();

//     // Simula progresso da ação
//     _actionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
//       setState(() {
//         _actionProgress = (_actionProgress + 1).clamp(0, 100);
//       });

//       if (_actionProgress >= 100) {
//         timer.cancel();
//         _completeAction(action);
//       }
//     });
//   }

//   Future<void> _completeAction(PetAction action) async {
//     // Executa ação no provider
//     bool success = false;

//     switch (action) {
//       case PetAction.feed:
//         success = await ref.feedPet(widget.petId);
//         break;
//       case PetAction.play:
//         success = await ref.playWithPet(widget.petId);
//         break;
//       case PetAction.rest:
//         success = await ref.letPetRest(widget.petId);
//         break;
//     }

//     setState(() {
//       _isActionInProgress = false;
//       _currentAction = null;
//       _actionProgress = 0;
//     });

//     // Mostra feedback visual
//     if (success) {
//       _showSuccessFeedback(action);
//     } else {
//       _showErrorFeedback();
//     }
//   }

//   void _showSuccessFeedback(PetAction action) {
//     final actionName = _getActionName(action);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$actionName realizada com sucesso!'),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   void _showErrorFeedback() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Não foi possível realizar a ação'),
//         backgroundColor: Colors.red,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   String _getActionName(PetAction action) {
//     switch (action) {
//       case PetAction.feed:
//         return 'Alimentação';
//       case PetAction.play:
//         return 'Brincadeira';
//       case PetAction.rest:
//         return 'Descanso';
//     }
//   }

//   // ========================================
//   // BUILD OTIMIZADO
//   // ========================================

//   @override
//   Widget build(BuildContext context) {
//     // Select apenas as informações necessárias
//     final petStats = select(
//       petStatsProvider(widget.petId),
//       (stats) => stats,
//     );

//     final canAffordFeed = select(
//       canAffordSelector({
//         'userId': ref.watch(firebaseCurrentUserProvider)?.uid ?? '',
//         'coins': 10,
//         'gems': 0,
//       }),
//       (canAfford) => canAfford,
//     );

//     final canAffordPlay = select(
//       canAffordSelector({
//         'userId': ref.watch(firebaseCurrentUserProvider)?.uid ?? '',
//         'coins': 5,
//         'gems': 0,
//       }),
//       (canAfford) => canAfford,
//     );

//     if (petStats == null) {
//       return const Card(
//         child: Padding(
//           padding: EdgeInsets.all(16),
//           child: Text('Pet não encontrado'),
//         ),
//       );
//     }

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Interações com o Pet',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),

//             const SizedBox(height: 16),

//             // Stats animadas
//             AnimatedBuilder(
//               animation: _actionAnimationController,
//               builder: (context, child) {
//                 final scale = 1.0 + (_actionAnimationController.value * 0.1);

//                 return Transform.scale(
//                   scale: scale,
//                   child: _StatsDisplay(stats: petStats),
//                 );
//               },
//             ),

//             const SizedBox(height: 16),

//             // Barra de progresso da ação
//             if (_isActionInProgress) ...[
//               _ActionProgressBar(
//                 action: _currentAction!,
//                 progress: _actionProgress / 100.0,
//                 animation: _progressAnimationController,
//               ),
//               const SizedBox(height: 16),
//             ],

//             // Botões de ação
//             _ActionButtons(
//               canAffordFeed: canAffordFeed,
//               canAffordPlay: canAffordPlay && petStats.energy > 10,
//               canRest: petStats.energy < 80,
//               isActionInProgress: _isActionInProgress,
//               onFeed: () => _performAction(PetAction.feed),
//               onPlay: () => _performAction(PetAction.play),
//               onRest: () => _performAction(PetAction.rest),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Widget de exibição de stats (StatelessWidget puro para performance)
// class _StatsDisplay extends StatelessWidget {
//   final PetStats stats;

//   const _StatsDisplay({required this.stats});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _StatBar(
//           label: 'Fome',
//           value: stats.hunger,
//           color: Colors.orange,
//           icon: Icons.restaurant,
//         ),
//         const SizedBox(height: 8),
//         _StatBar(
//           label: 'Felicidade',
//           value: stats.happiness,
//           color: Colors.pink,
//           icon: Icons.favorite,
//         ),
//         const SizedBox(height: 8),
//         _StatBar(
//           label: 'Energia',
//           value: stats.energy,
//           color: Colors.blue,
//           icon: Icons.battery_full,
//         ),
//       ],
//     );
//   }
// }

// /// Barra de stat individual
// class _StatBar extends StatelessWidget {
//   final String label;
//   final int value;
//   final Color color;
//   final IconData icon;

//   const _StatBar({
//     required this.label,
//     required this.value,
//     required this.color,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final percentage = value / 100.0;

//     return Row(
//       children: [
//         Icon(icon, size: 16, color: color),
//         const SizedBox(width: 8),
//         SizedBox(
//           width: 60,
//           child: Text(
//             label,
//             style: const TextStyle(fontSize: 12),
//           ),
//         ),
//         Expanded(
//           child: Container(
//             height: 8,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: FractionallySizedBox(
//               alignment: Alignment.centerLeft,
//               widthFactor: percentage,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: _getStatusColor(percentage, color),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         SizedBox(
//           width: 30,
//           child: Text(
//             '$value',
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//             textAlign: TextAlign.right,
//           ),
//         ),
//       ],
//     );
//   }

//   Color _getStatusColor(double percentage, Color baseColor) {
//     if (percentage > 0.7) return baseColor;
//     if (percentage > 0.3) return Colors.orange;
//     return Colors.red;
//   }
// }

// /// Barra de progresso da ação
// class _ActionProgressBar extends StatelessWidget {
//   final PetAction action;
//   final double progress;
//   final Animation<double> animation;

//   const _ActionProgressBar({
//     required this.action,
//     required this.progress,
//     required this.animation,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: animation,
//       builder: (context, child) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   _getActionIcon(action),
//                   size: 16,
//                   color: _getActionColor(action),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Executando ${_getActionName(action)}...',
//                   style: const TextStyle(fontSize: 14),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Container(
//               height: 6,
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(3),
//               ),
//               child: FractionallySizedBox(
//                 alignment: Alignment.centerLeft,
//                 widthFactor: animation.value,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: _getActionColor(action),
//                     borderRadius: BorderRadius.circular(3),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               '${(progress * 100).toInt()}%',
//               style: TextStyle(
//                 fontSize: 10,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   IconData _getActionIcon(PetAction action) {
//     switch (action) {
//       case PetAction.feed:
//         return Icons.restaurant;
//       case PetAction.play:
//         return Icons.sports_esports;
//       case PetAction.rest:
//         return Icons.hotel;
//     }
//   }

//   Color _getActionColor(PetAction action) {
//     switch (action) {
//       case PetAction.feed:
//         return Colors.orange;
//       case PetAction.play:
//         return Colors.green;
//       case PetAction.rest:
//         return Colors.blue;
//     }
//   }

//   String _getActionName(PetAction action) {
//     switch (action) {
//       case PetAction.feed:
//         return 'alimentação';
//       case PetAction.play:
//         return 'brincadeira';
//       case PetAction.rest:
//         return 'descanso';
//     }
//   }
// }

// /// Botões de ação (StatelessWidget puro)
// class _ActionButtons extends StatelessWidget {
//   final bool canAffordFeed;
//   final bool canAffordPlay;
//   final bool canRest;
//   final bool isActionInProgress;
//   final VoidCallback onFeed;
//   final VoidCallback onPlay;
//   final VoidCallback onRest;

//   const _ActionButtons({
//     required this.canAffordFeed,
//     required this.canAffordPlay,
//     required this.canRest,
//     required this.isActionInProgress,
//     required this.onFeed,
//     required this.onPlay,
//     required this.onRest,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Expanded(
//           child: _ActionButton(
//             icon: Icons.restaurant,
//             label: 'Alimentar',
//             subtitle: '10💰',
//             color: Colors.orange,
//             enabled: canAffordFeed && !isActionInProgress,
//             onPressed: onFeed,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: _ActionButton(
//             icon: Icons.sports_esports,
//             label: 'Brincar',
//             subtitle: '5💰',
//             color: Colors.green,
//             enabled: canAffordPlay && !isActionInProgress,
//             onPressed: onPlay,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: _ActionButton(
//             icon: Icons.hotel,
//             label: 'Descansar',
//             subtitle: 'Grátis',
//             color: Colors.blue,
//             enabled: canRest && !isActionInProgress,
//             onPressed: onRest,
//           ),
//         ),
//       ],
//     );
//   }
// }

// /// Botão de ação individual
// class _ActionButton extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String subtitle;
//   final Color color;
//   final bool enabled;
//   final VoidCallback? onPressed;

//   const _ActionButton({
//     required this.icon,
//     required this.label,
//     required this.subtitle,
//     required this.color,
//     required this.enabled,
//     this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: enabled ? onPressed : null,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: enabled ? color.withOpacity(0.1) : null,
//         foregroundColor: enabled ? color : null,
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//           side: BorderSide(
//             color: enabled ? color : Colors.grey,
//             width: 1,
//           ),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 20),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             subtitle,
//             style: const TextStyle(fontSize: 10),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Widget que demonstra quando NÃO usar ConsumerStatefulWidget
// /// (apenas exibe dados, sem estado local complexo)
// class SimpleInfoDisplayWidget extends ConsumerWidget
//     with PerformanceMonitorMixin {
//   const SimpleInfoDisplayWidget({super.key});

//   @override
//   Widget buildMonitored(BuildContext context, WidgetRef ref) {
//     // Usa selectors específicos para evitar rebuilds
//     final totalPets =
//         ref.watch(optimizedPetsProvider.select((state) => state.pets.length));

//     final availablePets = ref.watch(
//         optimizedPetsProvider.select((state) => state.availablePets.length));

//     final userCoins = ref.currentUserCoins;
//     final userGems = ref.currentUserGems;

//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Informações Gerais',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 12),
//             _InfoRow(
//               icon: Icons.pets,
//               label: 'Total de Pets',
//               value: totalPets.toString(),
//               color: Colors.blue,
//             ),
//             _InfoRow(
//               icon: Icons.favorite,
//               label: 'Pets Disponíveis',
//               value: availablePets.toString(),
//               color: Colors.green,
//             ),
//             const Divider(),
//             _InfoRow(
//               icon: Icons.monetization_on,
//               label: 'Suas Moedas',
//               value: userCoins.toString(),
//               color: Colors.amber,
//             ),
//             _InfoRow(
//               icon: Icons.diamond,
//               label: 'Suas Gemas',
//               value: userGems.toString(),
//               color: Colors.cyan,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Row de informação (widget puro)
// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color color;

//   const _InfoRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               label,
//               style: const TextStyle(fontSize: 14),
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Widget complexo que justifica o uso de ConsumerStatefulWidget
// /// (tem multiple timers, animações e estado local que interage com providers)
// class SmartNotificationWidget extends ConsumerStatefulWidget {
//   const SmartNotificationWidget({super.key});

//   @override
//   ConsumerState<SmartNotificationWidget> createState() =>
//       _SmartNotificationWidgetState();
// }

// class _SmartNotificationWidgetState
//     extends ConsumerState<SmartNotificationWidget>
//     with TickerProviderStateMixin {
//   // Estado local complexo que justifica StatefulWidget
//   late AnimationController _slideController;
//   late AnimationController _fadeController;
//   Timer? _autoHideTimer;
//   Timer? _updateTimer;

//   final List<NotificationItem> _notifications = [];
//   bool _isVisible = false;

//   @override
//   void initState() {
//     super.initState();

//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 200),
//       vsync: this,
//     );

//     // Timer para verificar notificações periodicamente
//     _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) {
//       _checkForNotifications();
//     });
//   }

//   @override
//   void dispose() {
//     _slideController.dispose();
//     _fadeController.dispose();
//     _autoHideTimer?.cancel();
//     _updateTimer?.cancel();
//     super.dispose();
//   }

//   void _checkForNotifications() {
//     final criticalPets = ref.read(criticalPetsSelector);
//     final hasLocalChanges = ref.read(hasLocalChangesSelector(
//         ref.read(firebaseCurrentUserProvider)?.uid ?? ''));

//     // Adiciona notificações baseadas no estado dos providers
//     if (criticalPets.isNotEmpty) {
//       _addNotification(NotificationItem(
//         id: 'critical_pets',
//         message: '${criticalPets.length} pets precisam de atenção!',
//         type: NotificationType.warning,
//         action: () => _handleCriticalPets(criticalPets.length),
//       ));
//     }

//     if (hasLocalChanges) {
//       _addNotification(NotificationItem(
//         id: 'sync_pending',
//         message: 'Dados pendentes para sincronização',
//         type: NotificationType.info,
//         action: () => ref.syncPendingData(),
//       ));
//     }
//   }

//   void _addNotification(NotificationItem notification) {
//     // Evita duplicatas
//     final exists = _notifications.any((n) => n.id == notification.id);
//     if (exists) return;

//     setState(() {
//       _notifications.add(notification);
//     });

//     _showNotifications();
//   }

//   void _showNotifications() {
//     if (_notifications.isEmpty || _isVisible) return;

//     setState(() {
//       _isVisible = true;
//     });

//     _slideController.forward();
//     _fadeController.forward();

//     // Auto-hide após 5 segundos
//     _autoHideTimer?.cancel();
//     _autoHideTimer = Timer(const Duration(seconds: 5), () {
//       _hideNotifications();
//     });
//   }

//   void _hideNotifications() {
//     if (!_isVisible) return;

//     _slideController.reverse().then((_) {
//       setState(() {
//         _isVisible = false;
//         _notifications.clear();
//       });
//     });

//     _fadeController.reverse();
//   }

//   void _handleCriticalPets(int count) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$count pets críticos detectados!'),
//         action: SnackBarAction(
//           label: 'Ver',
//           onPressed: () {
//             // Navegar para tela de pets críticos
//           },
//         ),
//       ),
//     );

//     _hideNotifications();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isVisible || _notifications.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Positioned(
//       top: MediaQuery.of(context).padding.top + 10,
//       left: 16,
//       right: 16,
//       child: SlideTransition(
//         position: Tween<Offset>(
//           begin: const Offset(0, -1),
//           end: Offset.zero,
//         ).animate(_slideController),
//         child: FadeTransition(
//           opacity: _fadeController,
//           child: Material(
//             elevation: 8,
//             borderRadius: BorderRadius.circular(12),
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey[300]!),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(Icons.notifications, size: 20),
//                       const SizedBox(width: 8),
//                       const Expanded(
//                         child: Text(
//                           'Notificações',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: _hideNotifications,
//                         icon: const Icon(Icons.close, size: 20),
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(
//                           minWidth: 24,
//                           minHeight: 24,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Divider(height: 16),
//                   ..._notifications.map(
//                     (notification) => _NotificationTile(
//                       notification: notification,
//                       onDismiss: () {
//                         setState(() {
//                           _notifications.remove(notification);
//                         });
//                         if (_notifications.isEmpty) {
//                           _hideNotifications();
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Item de notificação
// class NotificationItem {
//   final String id;
//   final String message;
//   final NotificationType type;
//   final VoidCallback? action;

//   const NotificationItem({
//     required this.id,
//     required this.message,
//     required this.type,
//     this.action,
//   });
// }

// enum NotificationType { info, warning, error, success }

// /// Tile de notificação
// class _NotificationTile extends StatelessWidget {
//   final NotificationItem notification;
//   final VoidCallback onDismiss;

//   const _NotificationTile({
//     required this.notification,
//     required this.onDismiss,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final color = _getTypeColor(notification.type);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(_getTypeIcon(notification.type), color: color, size: 16),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               notification.message,
//               style: const TextStyle(fontSize: 12),
//             ),
//           ),
//           if (notification.action != null) ...[
//             const SizedBox(width: 8),
//             TextButton(
//               onPressed: () {
//                 notification.action!();
//                 onDismiss();
//               },
//               style: TextButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 minimumSize: Size.zero,
//               ),
//               child: const Text('Ação', style: TextStyle(fontSize: 10)),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Color _getTypeColor(NotificationType type) {
//     switch (type) {
//       case NotificationType.info:
//         return Colors.blue;
//       case NotificationType.warning:
//         return Colors.orange;
//       case NotificationType.error:
//         return Colors.red;
//       case NotificationType.success:
//         return Colors.green;
//     }
//   }

//   IconData _getTypeIcon(NotificationType type) {
//     switch (type) {
//       case NotificationType.info:
//         return Icons.info;
//       case NotificationType.warning:
//         return Icons.warning;
//       case NotificationType.error:
//         return Icons.error;
//       case NotificationType.success:
//         return Icons.check_circle;
//     }
//   }
// }
