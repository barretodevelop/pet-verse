// File: lib/core/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/presentation/screens/auth/app_wrapper.dart';
import 'package:petverse/presentation/screens/auth/login_screen.dart';
import 'package:petverse/presentation/screens/home/home_screen.dart';
import 'package:petverse/presentation/screens/home/pet/optimized_pet_screen.dart';
import 'package:petverse/presentation/screens/settings/settings_screen.dart';
import 'package:petverse/presentation/screens/splash/splash_screen.dart';

/// Application routes configuration using GoRouter - INTEGRAÇÃO FASE 1
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String petDetail = '/pet/:petId';
  static const String shop = '/shop';
  static const String games = '/games';
  static const String feed = '/feed';
  static const String pet = '/pet';

  // ⭐ NOVAS ROTAS FASE 1
  static const String optimizedPet = '/optimized-pet';
  static const String petAdoption = '/pet-adoption';
  static const String collaborativeAdoption = '/collaborative-adoption';

  /// Router configuration
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash route
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main app wrapper
      GoRoute(
        path: '/',
        name: 'app',
        builder: (context, state) => const AppWrapper(),
      ),

      // Home routes
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Settings as sub-route
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => SettingsScreen(
              onBack: () => context.pop(),
            ),
          ),

          // ⭐ FASE 1: Pet routes atualizadas
          GoRoute(
            path: 'pet',
            name: 'pet',
            builder: (context, state) => const OptimizedPetScreen(),
          ),

          GoRoute(
            path: 'optimized-pet',
            name: 'optimized-pet',
            builder: (context, state) => const OptimizedPetScreen(),
          ),
        ],
      ),

      // Pet detail route
      GoRoute(
        path: petDetail,
        name: 'petDetail',
        builder: (context, state) {
          final petId = state.pathParameters['petId']!;
          return PetDetailScreen(petId: petId);
        },
      ),

      // ⭐ NOVAS ROTAS DIRETAS FASE 1
      GoRoute(
        path: optimizedPet,
        name: 'optimizedPetDirect',
        builder: (context, state) => const OptimizedPetScreen(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Página não encontrada'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Oops! Página não encontrada.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                'Verifique a URL ou volte para a tela inicial.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    },
  );

  /// Navigation helpers para facilitar navegação
  static void goToPetScreen(BuildContext context) {
    context.go('$home/pet');
  }

  static void goToOptimizedPetScreen(BuildContext context) {
    context.go(optimizedPet);
  }

  static void goToSettings(BuildContext context) {
    context.go('$home/settings');
  }

  static void goToHome(BuildContext context) {
    context.go(home);
  }

  static void goToPetDetail(BuildContext context, String petId) {
    context.go('/pet/$petId');
  }
}

/// Placeholder para PetDetailScreen (será implementado na Fase 2)
class PetDetailScreen extends StatelessWidget {
  final String petId;

  const PetDetailScreen({
    super.key,
    required this.petId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Pet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pets,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Pet ID: $petId',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tela de detalhes será implementada na Fase 2',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension para facilitar navegação
extension AppRoutesExtension on BuildContext {
  void goToPets() => AppRoutes.goToPetScreen(this);
  void goToOptimizedPets() => AppRoutes.goToOptimizedPetScreen(this);
  void goToAppSettings() => AppRoutes.goToSettings(this);
  void goToAppHome() => AppRoutes.goToHome(this);
  void goToPetDetails(String petId) => AppRoutes.goToPetDetail(this, petId);
}
