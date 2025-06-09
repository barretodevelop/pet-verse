// File: lib/core/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/presentation/screens/auth/app_wrapper.dart';
import 'package:petverse/presentation/screens/auth/login_screen.dart';
import 'package:petverse/presentation/screens/home/home_screen.dart';
import 'package:petverse/presentation/screens/home/pet/new_pet_screen.dart';
import 'package:petverse/presentation/screens/settings/settings_screen.dart';
import 'package:petverse/presentation/screens/splash/splash_screen.dart';

/// Application routes configuration using GoRouter
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
          GoRoute(path: 'pet', name: 'pet', builder: (context, state) => NewPetScreen()),
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
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),

    // Route redirect logic
    redirect: (context, state) {
      // Add authentication-based redirects here if needed
      return null;
    },
  );
}

/// Pet detail screen placeholder
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
        title: Text('Pet Details: $petId'),
      ),
      body: Center(
        child: Text('Pet ID: $petId'),
      ),
    );
  }
}
