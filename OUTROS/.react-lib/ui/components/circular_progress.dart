import 'dart:math';

import 'package:flutter/material.dart';

// CustomPainter para desenhar o círculo de progresso com gradiente e fundo.
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final bool glowing;
  final Color baseColor;
  final List<Color> gradientColors;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.glowing,
    required this.baseColor,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Pintar o círculo de fundo (base)
    final Paint backgroundPaint = Paint()
      ..color =
          baseColor.withOpacity(0.3) // Cor base com opacidade para o "trilho"
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Pontas arredondadas

    canvas.drawCircle(center, radius, backgroundPaint);

    // Pintar o arco de progresso
    final Paint progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round // Pontas arredondadas
      ..shader = SweepGradient(
        startAngle: -pi / 2, // Começa do topo
        endAngle:
            -pi / 2 + 2 * pi * (progress / 100), // Termina no progresso atual
        colors: gradientColors,
        tileMode: TileMode.mirror,
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Ângulo inicial (topo)
      2 * pi * (progress / 100), // Ângulo do arco (progresso)
      false, // Não é um pie chart
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowing != glowing ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.gradientColors != gradientColors;
  }
}

// Widget CircularProgress
class CircularProgress extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final bool glowing;

  const CircularProgress({
    super.key,
    required this.progress,
    this.size = 200,
    this.strokeWidth = 8,
    this.glowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Adiciona um BoxShadow para simular o efeito de brilho se 'glowing' for true
        boxShadow: glowing
            ? [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        painter: _CircularProgressPainter(
          progress: progress,
          strokeWidth: strokeWidth,
          glowing: glowing,
          baseColor: Colors.grey, // Cor base do trilho
          gradientColors: [
            const Color(0xFF8B5CF6), // purple-600
            const Color(0xFFA855F7), // purple-500
            const Color(0xFFC084FC), // purple-400
          ],
        ),
      ),
    );
  }
}
