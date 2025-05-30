import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PetPreviewCard extends StatelessWidget {
  final Map<String, dynamic> pet;
  final bool isSelected;

  const PetPreviewCard({
    super.key,
    required this.pet,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: pet['color'].withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pet Visual
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: pet['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  pet['icon'],
                  style: const TextStyle(fontSize: 100),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shake(duration: 3.seconds, delay: 2.seconds)
                    .then()
                    .shimmer(duration: 2.seconds),
              ),
            )
                .animate(target: isSelected ? 1 : 0)
                .scale(
                    begin: const Offset(0.9, 0),
                    end: const Offset(1.0, 0),
                    duration: 300.ms)
                .shake(hz: 2, duration: 300.ms),

            const SizedBox(height: 24),

            // Pet Info com animação de batimento
            if (isSelected) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: pet['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: pet['color'],
                      size: 20,
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(
                          begin: const Offset(1.0, 0),
                          end: const Offset(1.2, 0),
                          duration: 800.ms,
                          curve: Curves.easeInOut,
                        )
                        .then()
                        .scale(
                          begin: const Offset(1.2, 0),
                          end: const Offset(1.0, 0),
                          duration: 800.ms,
                          curve: Curves.easeInOut,
                        ),
                    const SizedBox(width: 8),
                    Text(
                      'Me escolha!',
                      style: TextStyle(
                        color: pet['color'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(),
            ],
          ],
        ),
      ),
    );
  }
}
