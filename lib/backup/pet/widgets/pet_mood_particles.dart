import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PetMoodParticles extends StatelessWidget {
  final String mood;
  final Widget child;

  const PetMoodParticles({
    super.key,
    required this.mood,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        if (mood == 'happy') ..._buildHappyParticles(),
        if (mood == 'sleepy') ..._buildSleepyParticles(),
        if (mood == 'energetic') ..._buildEnergeticParticles(),
      ],
    );
  }

  List<Widget> _buildHappyParticles() {
    return List.generate(5, (index) {
      final random = math.Random();
      final angle = (index * 72) * math.pi / 180;
      final distance = 80.0 + random.nextDouble() * 40;

      return Positioned(
        left: 125 + math.cos(angle) * distance,
        top: 125 + math.sin(angle) * distance,
        child: const Text('❤️', style: TextStyle(fontSize: 20))
            .animate(
              onPlay: (controller) => controller.repeat(),
              delay: Duration(milliseconds: index * 200),
            )
            .fade(begin: 0, end: 1, duration: 500.ms)
            .scale(
                begin: const Offset(0, 0),
                end: const Offset(1.0, 0),
                duration: 500.ms)
            .moveY(begin: 0, end: -20, duration: 2.seconds)
            .fade(begin: 1, end: 0, delay: 1.5.seconds),
      );
    });
  }

  List<Widget> _buildSleepyParticles() {
    return [
      Positioned(
        right: 60,
        top: 50,
        child: const Text('💤', style: TextStyle(fontSize: 30))
            .animate(onPlay: (controller) => controller.repeat())
            .fade(begin: 0.5, end: 1, duration: 2.seconds)
            .moveY(begin: 0, end: -20, duration: 3.seconds)
            .moveX(begin: 0, end: 10, duration: 3.seconds),
      ),
    ];
  }

  List<Widget> _buildEnergeticParticles() {
    return List.generate(8, (index) {
      final angle = (index * 45) * math.pi / 180;

      return Positioned(
          left: 125 + math.cos(angle) * 100,
          top: 125 + math.sin(angle) * 100,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.yellow,
              shape: BoxShape.circle,
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(),
                delay: Duration(milliseconds: index * 100),
              )
              .fade(begin: 0, end: 1, duration: 300.ms)
              .scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1.0, 0),
                  duration: 500.ms)
              .then()
              .fade(begin: 1, end: 0, duration: 300.ms)
              .scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1.0, 0),
                  duration: 500.ms));
    });
  }
}
