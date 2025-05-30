import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HapticButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool useHaptic;

  const HapticButton({
    super.key,
    required this.child,
    this.onPressed,
    this.useHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed == null
          ? null
          : () {
              if (useHaptic) {
                HapticFeedback.lightImpact();
              }
              onPressed!();
            },
      child: child,
    );
  }
}
