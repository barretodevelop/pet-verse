// SplashScreen
// lib/screens/splash_screen.dart - SplashScreen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_provider.dart'; // Importar o AppProvider

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.repeat(reverse: true);
    // A navegação será gerenciada pelo listener do appProvider
  }

  // void _navigateAfterDelay() async { // Removido - não mais necessário
  //   await Future.delayed(const Duration(seconds: 3));
  //   if (mounted) {
  //     final user = AuthService.currentUser;
  //     if (user != null) {
  //       context.go('/home');
  //     } else {
  //       context.go('/login');
  //     }
  //   }
  // }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos ref.listen para efeitos colaterais como navegação.
    ref.listen<AppState>(appProvider, (previousState, nextState) {
      final wasLoading = previousState?.isLoading ?? true;

      if (wasLoading && !nextState.isLoading) {
        if (nextState.user != null) {
          print(
              '[SplashScreen] Usuário carregado: ${nextState.user!.id}. Navegando para /home.');
          context.go('/home');
        } else {
          print(
              '[SplashScreen] Nenhum usuário ou erro. Navegando para /login. Erro: ${nextState.error}');
          context.go('/login');
        }
      }
    });

    // ref.watch é usado para reconstruir a UI da SplashScreen
    // e para garantir que o AppNotifier seja inicializado.
    final appState = ref.watch(appProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF9333EA), // purple-600
              Color(0xFF2563EB), // blue-600
              Color(0xFF0D9488), // teal-600
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _bounceAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _bounceAnimation.value,
                    child: const Text(
                      '🐾',
                      style: TextStyle(fontSize: 120),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              const Text(
                'PetCare',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Cuidado Colaborativo',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 64),
              if (appState.isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              if (appState.error != null && !appState.isLoading) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    'Ocorreu um erro: ${appState.error}',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Poderia tentar recarregar os dados ou simplesmente ir para o login
                    // ref.read(appProvider.notifier)._init(); // Para tentar recarregar
                    print(
                        '[SplashScreen] Botão "Tentar Novamente" pressionado. Navegando para /login.');
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple),
                  child: const Text('Tentar Novamente'),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
