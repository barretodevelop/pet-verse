import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  // Simula um carregamento de dados e então chama onFinish
  void _startSplashTimer() {
    Future.delayed(const Duration(seconds: 2), () {
      widget.onFinish();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Equivalente a bg-gradient-to-br from-purple-600 via-blue-600 to-teal-500
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF8B5CF6), // purple-600
            Color(0xFF2563EB), // blue-600
            Color(0xFF14B8A6), // teal-500
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji do Pet (equivalente ao text-8xl)
            Text(
              '🐾',
              style: TextStyle(fontSize: 80),
            ),
            SizedBox(height: 16), // mb-4

            // Título do aplicativo (equivalente ao text-4xl font-bold)
            Text(
              'PetCare',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8), // mb-2

            // Subtítulo (equivalente ao text-white/80)
            Text(
              'Cuidado Colaborativo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 32), // mt-8

            // Indicador de carregamento (equivalente ao w-12 h-12 border-4 animate-spin)
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 4,
                backgroundColor: Colors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
