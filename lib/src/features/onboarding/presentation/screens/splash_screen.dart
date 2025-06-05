// lib/src/features/onboarding/presentation/screens/splash_screen.dart
// CORREÇÃO CRÍTICA - Splash com timeout para evitar travamento infinito

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/src/core/navigation/app_routes.dart';
import 'package:petverse/src/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:petverse/src/features/auth/presentation/providers/user_data_provider.dart';
import 'package:petverse/src/utils/test_data_initializer.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();

    // TIMEOUT DE SEGURANÇA - se após 8 segundos não navegou, força navegação
    _setupSafetyTimeout();
  }

  void _setupSafetyTimeout() {
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && !_hasNavigated) {
        debugPrint('🚨 [Splash] TIMEOUT de segurança - forçando navegação');
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    if (_hasNavigated || !mounted) return;

    _hasNavigated = true;
    debugPrint('🧭 [Splash] Navegando para próxima tela...');

    final authState = ref.read(authStateProvider);
    final isLoggedIn = authState.status == AuthStatus.authenticated;

    if (isLoggedIn) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Observar dados de teste e auth
    final testDataAsync = ref.watch(testDataInitializerProvider);
    final authState = ref.watch(authStateProvider);
    final userStatus = ref.watch(userStatusProvider);

    // LÓGICA DE NAVEGAÇÃO SIMPLIFICADA
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (!mounted || _hasNavigated) return;

      // Aguardar um pouco para animação
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && !_hasNavigated) {
          _navigateToNextScreen();
        }
      });
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo animado
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween<double>(begin: 0.5, end: 1.0),
                      builder: (context, double scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.pets_rounded,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Título
                    Text(
                      'PetVerse',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Cuidado colaborativo de pets',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                    ),

                    const SizedBox(height: 48),

                    // Loading indicator
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Status text
                    Text(
                      _getStatusText(testDataAsync, authState, userStatus),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getStatusText(
    AsyncValue<void> testDataAsync,
    AuthState authState,
    UserStatus userStatus,
  ) {
    if (testDataAsync.isLoading) {
      return 'Inicializando dados...';
    }

    if (testDataAsync.hasError) {
      return 'Erro ao carregar dados';
    }

    switch (authState.status) {
      case AuthStatus.unknown:
        return 'Verificando autenticação...';
      case AuthStatus.authenticated:
        switch (userStatus) {
          case UserStatus.loading:
            return 'Carregando perfil...';
          case UserStatus.hasPets:
            return 'Bem-vindo de volta!';
          case UserStatus.noPets:
            return 'Preparando para adoção...';
          case UserStatus.notLoggedIn:
            return 'Redirecionando...';
        }
      case AuthStatus.unauthenticated:
        return 'Redirecionando para login...';
    }
  }
}
