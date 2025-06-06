// import 'dart:async';

// import 'package:flutter/material.dart';

// class SplashScreen extends StatefulWidget {
//   final VoidCallback onComplete;
//   final String? message;
//   final Duration duration;

//   const SplashScreen({
//     super.key,
//     required this.onComplete,
//     this.message,
//     this.duration = const Duration(seconds: 2),
//   });

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _logoController;
//   late AnimationController _textController;
//   late Animation<double> _logoScale;
//   late Animation<double> _textOpacity;

//   @override
//   void initState() {
//     super.initState();

//     _logoController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _textController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _logoScale = Tween<double>(
//       begin: 0.5,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _logoController,
//       curve: Curves.elasticOut,
//     ));

//     _textOpacity = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _textController,
//       curve: Curves.easeIn,
//     ));

//     _startAnimation();
//   }

//   void _startAnimation() async {
//     await _logoController.forward();
//     await _textController.forward();

//     // Aguarda duração configurada
//     await Future.delayed(widget.duration);

//     widget.onComplete();
//   }

//   @override
//   void dispose() {
//     _logoController.dispose();
//     _textController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF8A05BE),
//               Color(0xFF4B0082),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Logo animado
//               AnimatedBuilder(
//                 animation: _logoScale,
//                 builder: (context, child) {
//                   return Transform.scale(
//                     scale: _logoScale.value,
//                     child: Container(
//                       width: 120,
//                       height: 120,
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.pets,
//                         size: 60,
//                         color: Color(0xFF8A05BE),
//                       ),
//                     ),
//                   );
//                 },
//               ),

//               const SizedBox(height: 32),

//               // Texto animado
//               AnimatedBuilder(
//                 animation: _textOpacity,
//                 builder: (context, child) {
//                   return Opacity(
//                     opacity: _textOpacity.value,
//                     child: Column(
//                       children: [
//                         const Text(
//                           'PetVerse',
//                           style: TextStyle(
//                             fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           widget.message ?? 'Carregando...',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.white.withOpacity(0.8),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),

//               const SizedBox(height: 48),

//               // Loading indicator
//               const CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 strokeWidth: 2,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // class SimpleSplashScreen extends StatelessWidget {
// //   final VoidCallback? onComplete;

// //   const SimpleSplashScreen({
// //     super.key,
// //     this.onComplete,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return SplashScreen(
// //       onComplete: onComplete,
// //       duration: const Duration(seconds: 2),
// //     );
// //   }
// // }

// /// Extensão para facilitar o uso
// // extension SplashScreenExtensions on Widget {
// //   /// Envolve o widget com uma tela de splash
// //   Widget withSplash({
// //     Duration duration = const Duration(seconds: 3),
// //     VoidCallback? onComplete,
// //   }) {
// //     return SplashScreen(
// //       duration: duration,
// //       onComplete: onComplete,
// //     );
// //   }
// // }

// lib/presentation/screens/splash_screen.dart - ATUALIZADO
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_auth_service.dart';
import '../../core/navigation/app_router.dart';
import '../../core/navigation/route_names.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const SplashScreen({
    super.key,
    this.onComplete,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkInitialRoute();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _scaleController.forward();
  }

  Future<void> _checkInitialRoute() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // Verifica autenticação
      final authService = FirebaseAuthService.instance;
      final currentUser = authService.currentUser;

      String targetRoute;

      if (currentUser != null) {
        // Usuário autenticado, vai para dashboard
        targetRoute = RouteNames.dashboard;
      } else {
        // Usuário não autenticado, vai para login
        targetRoute = RouteNames.login;
      }

      // Callback se fornecido
      widget.onComplete?.call();

      // Navega usando o sistema de roteamento
      if (mounted) {
        AppRouter.go(targetRoute);
      }
    } catch (e) {
      // Em caso de erro, vai para login
      if (mounted) {
        AppRouter.go(RouteNames.login);
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo animado
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.pets,
                        size: 60,
                        color: Color(0xFF8A05BE),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Nome do app
                    const Text(
                      'Pet Adote',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtítulo
                    Text(
                      'Encontre seu companheiro perfeito',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Loading indicator
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
