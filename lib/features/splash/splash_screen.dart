// lib/features/splash/splash_screen.dart
// ALTERADO: Fluxo de carregamento otimizado e tratamento de erros
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../shared/providers/global_providers.dart';
import '../../shared/providers/initial_loading_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _loadingMessage = 'Iniciando PetVerse...';
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Iniciar verificação após um pequeno delay para mostrar o splash
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _checkAuthAndInitialize();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndInitialize() async {
    if (_hasNavigated) return;

    try {
      setState(() => _loadingMessage = 'Verificando autenticação...');

      // Aguardar o estado de autenticação
      final authState = await ref.read(authStateChangesProvider.future);

      if (!mounted) return;

      if (authState == null) {
        // Usuário não autenticado - ir para login
        _navigateTo('/login');
        return;
      }

      // Usuário autenticado - carregar dados do jogo
      setState(() => _loadingMessage = 'Carregando dados do jogo...');

      try {
        // Carregar configurações e dados iniciais
        await ref.read(initialLoadingProvider.future);

        if (!mounted) return;

        setState(() => _loadingMessage = 'Verificando pet ativo...');

        // Verificar se há pet ativo
        final activePet = ref.read(activePetProvider);

        if (!mounted) return;

        if (activePet == null) {
          // Não há pet ativo - ir para seleção de pet
          _navigateTo('/select');
        } else {
          // Há pet ativo - ir para tela principal
          _navigateTo('/main');
        }
      } catch (gameDataError) {
        debugPrint('❌ Erro ao carregar dados do jogo: $gameDataError');
        if (!mounted) return;

        // Erro no carregamento - mostrar opção de retry ou ir para seleção de pet
        _showErrorDialog(
          'Erro ao carregar dados do jogo',
          gameDataError.toString(),
          () => _navigateTo('/select'),
        );
      }
    } catch (authError) {
      debugPrint('❌ Erro na verificação de autenticação: $authError');
      if (!mounted) return;

      // Erro na autenticação - ir para login
      _showErrorDialog(
        'Erro de autenticação',
        'Houve um problema na verificação. Tente fazer login novamente.',
        () => _navigateTo('/login'),
      );
    }
  }

  void _navigateTo(String route) {
    if (_hasNavigated || !mounted) return;

    _hasNavigated = true;
    setState(() => _loadingMessage = 'Redirecionando...');

    // Pequeno delay para mostrar mensagem de redirecionamento
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.go(route);
      }
    });
  }

  void _showErrorDialog(String title, String message, VoidCallback onRetry) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _hasNavigated = false;
              setState(() => _loadingMessage = 'Tentando novamente...');
              Future.delayed(
                  const Duration(milliseconds: 500), _checkAuthAndInitialize);
            },
            child: const Text('Tentar Novamente'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
              AppColors.accent,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo principal animado
              _buildAnimatedLogo(),

              const SizedBox(height: 48),

              // Título
              Text(
                'PetVerse',
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 800.ms)
                  .slideY(begin: -0.3, end: 0)
                  .then()
                  .shimmer(
                      duration: 2000.ms, color: Colors.white.withOpacity(0.3)),

              const SizedBox(height: 12),

              // Subtítulo
              Text(
                'Cuidado Virtual de Pets Colaborativo',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 80),

              // Indicador de carregamento
              _buildLoadingIndicator(),

              const SizedBox(height: 24),

              // Mensagem de carregamento
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _loadingMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ).animate().fadeIn(delay: 1200.ms, duration: 600.ms),

              const Spacer(),

              // Versão do app
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'Versão 1.0.0',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ).animate().fadeIn(delay: 1500.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animationController.value * 0.2,
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
                    spreadRadius: 2,
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
    ).animate().fadeIn(duration: 1000.ms).scale(
          begin: const Offset(0.3, 0.3),
          end: const Offset(1.0, 1.0),
          curve: Curves.elasticOut,
        );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          // Indicador de progresso personalizado
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.white.withOpacity(0.2),
            ),
            child: const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),

          const SizedBox(height: 16),

          // Pontos de carregamento animados
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
                  .fadeIn(
                    delay: Duration(milliseconds: index * 200),
                    duration: 600.ms,
                  )
                  .then()
                  .fadeOut(duration: 600.ms);
            }),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1000.ms, duration: 600.ms);
  }
}
