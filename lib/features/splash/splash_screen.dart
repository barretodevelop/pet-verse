// lib/features/splash/splash_screen.dart
// ALTERADO: Fluxo de carregamento otimizado e tratamento de erros
// lib/features/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petverse/shared/providers/unified_user_state_provider.dart';

import '../../core/constants/app_colors.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../shared/providers/global_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _message = 'Iniciando PetVerse...';
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Iniciar verificação após animação inicial
    Future.delayed(const Duration(seconds: 2), _checkAndNavigate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAndNavigate() async {
    if (_navigated) return;

    try {
      _updateMessage('Verificando login...');

      // Aguardar carregamento inicial do estado
      final authState = await ref.read(authStateChangesProvider.future);

      if (authState == null) {
        _navigateTo('/login');
        return;
      }

      _updateMessage('Carregando dados...');

      // Carregar dados do usuário
      await ref
          .read(userProvider.notifier)
          .loadDataAndCheckQuests(authState.uid);

      _updateMessage('Verificando pet...');

      // Carregar pet ativo
      await ref.read(activePetProvider.notifier).loadInitialPet(authState.uid);

      // Usar o provider unificado para determinar navegação
      final targetRoute = ref.read(navigationTargetProvider);
      _navigateTo(targetRoute);
    } catch (error) {
      debugPrint('Erro na splash: $error');
      _showError('Erro ao carregar dados', () => _navigateTo('/login'));
    }
  }

  void _updateMessage(String message) {
    if (mounted) setState(() => _message = message);
  }

  void _navigateTo(String route) {
    if (_navigated || !mounted) return;

    _navigated = true;
    _updateMessage('Redirecionando...');

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) context.go(route);
    });
  }

  void _showError(String error, VoidCallback onRetry) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error),
            SizedBox(width: 8),
            Text('Erro'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigated = false;
              _checkAndNavigate();
            },
            child: const Text('Tentar Novamente'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.secondary, AppColors.accent],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animado
              _buildLogo(),

              const SizedBox(height: 48),

              // Título
              Text(
                'PetVerse',
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: -0.3, end: 0),

              const SizedBox(height: 12),

              // Subtítulo
              Text(
                'Cuidado Virtual de Pets Colaborativo',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0),

              const SizedBox(height: 80),

              // Loading
              _buildLoading(),

              const SizedBox(height: 24),

              // Mensagem
              Text(
                _message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ).animate().fadeIn(delay: 1200.ms),

              const Spacer(),

              // Versão
              Text(
                'Versão 1.0.0',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ).animate().fadeIn(delay: 1500.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 0.2,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Icon(
                Icons.pets,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
        );
      },
    ).animate().fadeIn().scale(curve: Curves.elasticOut);
  }

  Widget _buildLoading() {
    return Column(
      children: [
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(delay: Duration(milliseconds: index * 200))
                .then()
                .fadeOut();
          }),
        ),
      ],
    ).animate().fadeIn(delay: 1000.ms);
  }
}
