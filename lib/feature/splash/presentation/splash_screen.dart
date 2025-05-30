// lib/feature/splash/presentation/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petverse/core/constants/app_constants.dart';
import 'package:petverse/core/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // _initializeApp();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  // Future<void> _initializeApp() async {
  //   try {
  //      final authState = ref.watch(authenticationNotifierProvider);
  //      final isAuthenticated = authState.isAuthenticated;

  //     // Simulate initialization time (minimum splash duration)
  //     await Future.delayed(const Duration(milliseconds: 2000));

  //     if (mounted) {
  //       context.go('/');
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       _showErrorDialog(e.toString());
  //     }
  //   }
  // }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Erro de Inicialização',
          style: AppTheme.textTheme.headlineSmall,
        ),
        content: Text(
          'Ocorreu um erro ao inicializar o app:\n$error',
          style: AppTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // _initializeApp(); // Retry
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Animation
                      AnimatedBuilder(
                        animation: _logoScale,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: AppTheme.elevatedShadow,
                              ),
                              child: const Icon(
                                Icons.pets,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // App Name Animation
                      AnimatedBuilder(
                        animation: _textOpacity,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _textOpacity.value,
                            child: Column(
                              children: [
                                Text(
                                  AppConstants.appName,
                                  style: GoogleFonts.nunito(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppConstants.appTagline,
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 60),

                      // Loading Animation
                      const PulsingDots(),
                    ],
                  ),
                ),
              ),

              // Version Info
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Versão 1.0',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Loading Animation
class PulsingDots extends StatefulWidget {
  const PulsingDots({super.key});

  @override
  State<PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<PulsingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Start animations with delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(
                  0.3 + (_animations[index].value * 0.7),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            );
          },
        );
      }),
    );
  }
}

// Alternative Splash with Lottie Animation (if using Lottie)
class AnimatedSplashScreen extends ConsumerStatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  ConsumerState<AnimatedSplashScreen> createState() =>
      _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends ConsumerState<AnimatedSplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 3000));

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation (uncomment if using)
              // Lottie.asset(
              //   'assets/lottie/pet_animation.json',
              //   width: 200,
              //   height: 200,
              //   fit: BoxFit.contain,
              // ),

              // Fallback Icon Animation
              const Icon(
                Icons.pets,
                size: 100,
                color: AppTheme.primaryColor,
              )
                  .animate()
                  .scale(
                    duration: 1000.ms,
                    curve: Curves.elasticOut,
                  )
                  .then()
                  .shimmer(
                    duration: 2000.ms,
                    color: AppTheme.secondaryColor,
                  ),

              const SizedBox(height: 32),

              Text(
                AppConstants.appName,
                style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 800.ms)
                  .slideY(begin: 0.5, end: 0),

              const SizedBox(height: 16),

              Text(
                AppConstants.appTagline,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
