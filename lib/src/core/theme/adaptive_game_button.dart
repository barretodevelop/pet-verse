// // 🔧 REFACTOR: Todos os botões game-like
// import 'package:flutter/material.dart';
// import 'package:petverse/src/core/theme/adaptive_game_colors.dart';
// import 'package:petverse/src/core/theme/adaptive_game_text_styles.dart';

// class AdaptiveGameButton extends StatefulWidget {
//   final String text;
//   final VoidCallback? onPressed;
//   final IconData? icon;
//   final bool isEnabled;

//   const AdaptiveGameButton({
//     super.key,
//     required this.text,
//     this.onPressed,
//     this.icon,
//     this.isEnabled = true,
//   });

//   @override
//   State<AdaptiveGameButton> createState() => _AdaptiveGameButtonState();
// }

// class _AdaptiveGameButtonState extends State<AdaptiveGameButton> {
//   bool _isPressed = false;
//   bool _isHovered = false; // Embora hover seja mais para web/desktop, é bom ter

//   void _onTapDown(TapDownDetails details) {
//     if (!widget.isEnabled) return;
//     setState(() => _isPressed = true);
//   }

//   void _onTapUp(TapUpDetails details) {
//     if (!widget.isEnabled) return;
//     setState(() => _isPressed = false);
//     widget.onPressed?.call();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       transform: Matrix4.identity()
//         ..translate(0.0, _isPressed ? 2.0 : 0.0)
//         ..scale(_isHovered ? 1.05 : 1.0),
//       decoration: BoxDecoration(
//         gradient: widget.isEnabled
//             ? AdaptiveGameColors.primaryGradient(context)
//             : LinearGradient(
//                 colors: [
//                   Theme.of(context).disabledColor,
//                   Theme.of(context).disabledColor.withOpacity(0.8),
//                 ],
//               ),
//         borderRadius: BorderRadius.circular(
//             16), // Ajustado para consistência com outros cards
//         boxShadow: widget.isEnabled && (_isHovered || _isPressed)
//             ? AdaptiveGameColors.glowShadow(
//                 context,
//                 AdaptiveGameColors.primaryGradient(context).colors.first,
//               )
//             : AdaptiveGameColors.cardShadow(context),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(16), // Ajustado
//           onTapDown: _onTapDown,
//           onTapUp: _onTapUp,
//           onTapCancel: () {
//             // Reset _isPressed if tap is cancelled
//             if (!widget.isEnabled) return;
//             setState(() => _isPressed = false);
//           },
//           onHover: (hovering) {
//             // Para web/desktop
//             if (!widget.isEnabled) return;
//             setState(() => _isHovered = hovering);
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(
//                 vertical: 12, horizontal: 24), // Padding ajustado
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment:
//                   MainAxisAlignment.center, // Centralizar conteúdo
//               children: [
//                 if (widget.icon != null) ...[
//                   Icon(widget.icon,
//                       color: Colors.white,
//                       size: 20), // Tamanho do ícone ajustado
//                   const SizedBox(width: 8),
//                 ],
//                 Text(widget.text,
//                     style: AdaptiveGameTextStyles.buttonText(context)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
