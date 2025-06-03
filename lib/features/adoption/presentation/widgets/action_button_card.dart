// // lib/features/adoption/presentation/widgets/action_button_card.dart
// import 'package:flutter/material.dart';

// class ActionButtonCard extends StatefulWidget {
//   final String title;
//   final String description;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;
//   final bool isOutlined;

//   const ActionButtonCard({
//     super.key,
//     required this.title,
//     required this.description,
//     required this.icon,
//     required this.color,
//     required this.onTap,
//     this.isOutlined = false,
//   });

//   @override
//   State<ActionButtonCard> createState() => _ActionButtonCardState();
// }

// class _ActionButtonCardState extends State<ActionButtonCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _scaleController;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _scaleController = AnimationController(
//       duration: const Duration(milliseconds: 100),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.95,
//     ).animate(CurvedAnimation(
//       parent: _scaleController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   @override
//   void dispose() {
//     _scaleController.dispose();
//     super.dispose();
//   }

//   void _handleTapDown(TapDownDetails details) {
//     _scaleController.forward();
//   }

//   void _handleTapUp(TapUpDetails details) {
//     _scaleController.reverse();
//   }

//   void _handleTapCancel() {
//     _scaleController.reverse();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _scaleAnimation,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value,
//           child: GestureDetector(
//             onTapDown: _handleTapDown,
//             onTapUp: _handleTapUp,
//             onTapCancel: _handleTapCancel,
//             onTap: widget.onTap,
//             child: Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: widget.isOutlined ? Colors.white : widget.color,
//                 borderRadius: BorderRadius.circular(16),
//                 border: widget.isOutlined
//                     ? Border.all(color: widget.color, width: 2)
//                     : null,
//                 boxShadow: [
//                   BoxShadow(
//                     color: widget.color.withOpacity(0.2),
//                     blurRadius: 15,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   // Icon
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: widget.isOutlined
//                           ? widget.color.withOpacity(0.1)
//                           : Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Icon(
//                       widget.icon,
//                       color: widget.isOutlined ? widget.color : Colors.white,
//                       size: 24,
//                     ),
//                   ),

//                   const SizedBox(width: 16),

//                   // Text content
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.title,
//                           style: AppTheme.bodyLarge.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color:
//                                 widget.isOutlined ? widget.color : Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           widget.description,
//                           style: AppTheme.bodySmall.copyWith(
//                             color: widget.isOutlined
//                                 ? AppTheme.textSecondary
//                                 : Colors.white.withOpacity(0.8),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Arrow
//                   Icon(
//                     Icons.arrow_forward_ios,
//                     color: widget.isOutlined
//                         ? widget.color
//                         : Colors.white.withOpacity(0.7),
//                     size: 16,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
