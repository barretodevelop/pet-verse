// import 'package:flutter/material.dart';
//

// class ResourceChip extends StatefulWidget {
//   final String icon;
//   final String value;
//   final Color color;
//   final String? label;
//   final VoidCallback? onTap;
//   final bool isSelected;
//   final EdgeInsetsGeometry? padding;
//   final double? elevation;
//   final bool showGradient;
//   final bool animate;
//   final String? tooltip;
//   final TextStyle? valueStyle;
//   final TextStyle? labelStyle;
//   final TextStyle? iconStyle;

//   const ResourceChip({
//     super.key,
//     required this.icon,
//     required this.value,
//     required this.color,
//     this.label,
//     this.onTap,
//     this.isSelected = false,
//     this.padding,
//     this.elevation,
//     this.showGradient = false,
//     this.animate = true,
//     this.tooltip,
//     this.valueStyle,
//     this.labelStyle,
//     this.iconStyle,
//   });

//   @override
//   State<ResourceChip> createState() => _ResourceChipState();
// }

// class _ResourceChipState extends State<ResourceChip>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _elevationAnimation;
//   bool _isPressed = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.95,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));

//     _elevationAnimation = Tween<double>(
//       begin: widget.elevation ?? 2.0,
//       end: (widget.elevation ?? 2.0) * 1.5,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _handleTapDown(TapDownDetails details) {
//     if (widget.animate) {
//       setState(() => _isPressed = true);
//       _animationController.forward();
//     }
//   }

//   void _handleTapUp(TapUpDetails details) {
//     if (widget.animate) {
//       setState(() => _isPressed = false);
//       _animationController.reverse();
//     }
//   }

//   void _handleTapCancel() {
//     if (widget.animate) {
//       setState(() => _isPressed = false);
//       _animationController.reverse();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final defaultPadding = EdgeInsets.symmetric(
//       horizontal: 12,
//       vertical: 8,
//     );

//     Widget child = AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: widget.animate ? _scaleAnimation.value : 1.0,
//           child: Container(
//             padding: widget.padding ?? defaultPadding,
//             decoration: BoxDecoration(
//               gradient: widget.showGradient
//                   ? LinearGradient(
//                       colors: [
//                         Colors.white,
//                         widget.color.withOpacity(0.02),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     )
//                   : null,
//               color: widget.showGradient ? null : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: widget.isSelected
//                     ? widget.color
//                     : widget.color.withOpacity(0.15),
//                 width: widget.isSelected ? 2 : 1,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: widget.color.withOpacity(
//                     widget.isSelected ? 0.15 : 0.08,
//                   ),
//                   blurRadius: widget.animate
//                       ? _elevationAnimation.value * 2
//                       : (widget.elevation ?? 2.0) * 2,
//                   offset: Offset(
//                       0,
//                       widget.animate
//                           ? _elevationAnimation.value / 2
//                           : (widget.elevation ?? 2.0) / 2),
//                   spreadRadius: widget.isSelected ? 0.5 : 0,
//                 ),
//               ],
//             ),
//             child: _buildContent(),
//           ),
//         );
//       },
//     );

//     if (widget.onTap != null) {
//       child = GestureDetector(
//         onTap: widget.onTap,
//         onTapDown: _handleTapDown,
//         onTapUp: _handleTapUp,
//         onTapCancel: _handleTapCancel,
//         child: child,
//       );
//     }

//     if (widget.tooltip != null) {
//       child = Tooltip(
//         message: widget.tooltip!,
//         child: child,
//       );
//     }

//     return Expanded(
//       child: Semantics(
//         label: widget.tooltip ?? '${widget.label ?? ''} ${widget.value}'.trim(),
//         value: widget.value,
//         button: widget.onTap != null,
//         selected: widget.isSelected,
//         child: child,
//       ),
//     );
//   }

//   Widget _buildContent() {
//     return IntrinsicHeight(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Icon
//           Flexible(
//             flex: 0,
//             child: Text(
//               widget.icon,
//               style: widget.iconStyle ??
//                   TextStyle(
//                     fontSize: 14,
//                     color: widget.color,
//                   ),
//             ),
//           ),

//           SizedBox(width: 6),

//           // Content
//           Flexible(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Label (opcional)
//                 if (widget.label != null) ...[
//                   Text(
//                     widget.label!,
//                     style: widget.labelStyle ??
//                         TextStyle(
//                           color: widget.color.withOpacity(0.7),
//                           fontSize: 9,
//                           fontWeight: FontWeight.w500,
//                           letterSpacing: 0.2,
//                           height: 1.1,
//                         ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   SizedBox(height: 1),
//                 ],

//                 // Value
//                 Text(
//                   widget.value,
//                   style: widget.valueStyle ??
//                       TextStyle(
//                         color: widget.isSelected
//                             ? widget.color
//                             : AppTheme.textPrimary,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                         height: 1.2,
//                       ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Widget builder method melhorado (para manter compatibilidade)
// Widget buildResourceChip({
//   required String icon,
//   required String value,
//   required Color color,
//   String? label,
//   VoidCallback? onTap,
//   bool isSelected = false,
//   bool showGradient = false,
//   String? tooltip,
// }) {
//   return ResourceChip(
//     icon: icon,
//     value: value,
//     color: color,
//     label: label,
//     onTap: onTap,
//     isSelected: isSelected,
//     showGradient: showGradient,
//     tooltip: tooltip,
//   );
// }

// // Classe para temas (se não existir)
// class AppTheme {
//   static const Color textPrimary = Color(0xFF2D3748);
//   static const Color textSecondary = Color(0xFF718096);
// }

import 'package:flutter/material.dart';

class ResourceChip extends StatefulWidget {
  final String icon;
  final String value;
  final Color color;
  final String? label;
  final VoidCallback? onTap;
  final bool isSelected;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final bool showGradient;
  final bool animate;
  final String? tooltip;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final TextStyle? iconStyle;

  const ResourceChip({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
    this.label,
    this.onTap,
    this.isSelected = false,
    this.padding,
    this.elevation,
    this.showGradient = false,
    this.animate = true,
    this.tooltip,
    this.valueStyle,
    this.labelStyle,
    this.iconStyle,
  });

  @override
  State<ResourceChip> createState() => _ResourceChipState();
}

class _ResourceChipState extends State<ResourceChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 2.0,
      end: (widget.elevation ?? 2.0) * 1.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.animate) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.animate) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.animate) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    const defaultPadding = EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    );

    Widget child = AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animate ? _scaleAnimation.value : 1.0,
          child: Container(
            padding: widget.padding ?? defaultPadding,
            decoration: BoxDecoration(
              gradient: widget.showGradient
                  ? LinearGradient(
                      colors: [
                        Colors.white,
                        widget.color.withOpacity(0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.showGradient ? null : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? widget.color
                    : widget.color.withOpacity(0.15),
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(
                    widget.isSelected ? 0.15 : 0.08,
                  ),
                  blurRadius: widget.animate
                      ? _elevationAnimation.value * 2
                      : (widget.elevation ?? 2.0) * 2,
                  offset: Offset(
                      0,
                      widget.animate
                          ? _elevationAnimation.value / 2
                          : (widget.elevation ?? 2.0) / 2),
                  spreadRadius: widget.isSelected ? 0.5 : 0,
                ),
              ],
            ),
            child: _buildContent(),
          ),
        );
      },
    );

    if (widget.onTap != null) {
      child = GestureDetector(
        onTap: widget.onTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: child,
      );
    }

    if (widget.tooltip != null) {
      child = Tooltip(
        message: widget.tooltip!,
        child: child,
      );
    }

    return Expanded(
      child: Semantics(
        label: widget.tooltip ?? '${widget.label ?? ''} ${widget.value}'.trim(),
        value: widget.value,
        button: widget.onTap != null,
        selected: widget.isSelected,
        child: child,
      ),
    );
  }

  Widget _buildContent() {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Flexible(
            flex: 0,
            child: Text(
              widget.icon,
              style: widget.iconStyle ??
                  const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
            ),
          ),

          const SizedBox(width: 6),

          // Content
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Label (opcional)
                if (widget.label != null) ...[
                  Text(
                    widget.label!,
                    style: widget.labelStyle ??
                        const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                          height: 1.1,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                ],

                // Value
                Text(
                  widget.value,
                  style: widget.valueStyle ??
                      TextStyle(
                        color: widget.isSelected
                            ? widget.color
                            : AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget builder method melhorado (para manter compatibilidade)
Widget buildResourceChip({
  required String icon,
  required String value,
  required Color color,
  String? label,
  VoidCallback? onTap,
  bool isSelected = false,
  bool showGradient = false,
  String? tooltip,
}) {
  return ResourceChip(
    icon: icon,
    value: value,
    color: color,
    label: label,
    onTap: onTap,
    isSelected: isSelected,
    showGradient: showGradient,
    tooltip: tooltip,
  );
}

// Classe para temas
class AppTheme {
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
}
