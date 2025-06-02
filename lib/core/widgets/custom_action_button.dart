import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BuildActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final int delay;

  const BuildActionButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFFAFBFC),
              Color(0xFFF8FAFC),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: gradient.colors.first.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone com gradiente
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Seta com gradiente
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: gradient.colors.first.withOpacity(0.1) != null
                    ? LinearGradient(
                        colors: [
                          gradient.colors.first.withOpacity(0.1),
                          gradient.colors.first.withOpacity(0.05),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: gradient.colors.first.withOpacity(0.7),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(
          delay: Duration(milliseconds: delay),
        )
        .fadeIn(duration: 800.ms)
        .slideX(
          begin: 0.4,
          end: 0,
          curve: Curves.easeOutCubic,
        )
        .then()
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .shimmer(
          delay: Duration(milliseconds: delay + 2500),
          duration: 2500.ms,
          color: gradient.colors.first.withOpacity(0.08),
        );
  }
}
