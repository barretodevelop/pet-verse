import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadingAnimation extends StatelessWidget {
  final String? message;

  const LoadingAnimation({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pets,
              size: 50,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shake(
                hz: 3,
                offset: const Offset(0, 10), // <-- Correção aqui!
                duration: 1.seconds,
              )
              .then(delay: 1.seconds)
              .scale(begin: const Offset(1.0, 0), end: const Offset(0, 1.1))
              .then()
              .scale(begin: const Offset(0, 1.1), end: const Offset(1.0, 0)),
          if (message != null) ...[
            const SizedBox(height: 24),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }
}
