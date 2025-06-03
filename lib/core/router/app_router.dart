// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/adoption/presentation/pages/create_adoption_page.dart';
import '../../features/adoption/presentation/pages/list_adoption_page.dart';
import '../../features/adoption/screens/adoption_choice_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/events/screens/events_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/minigame/screens/minigames_list_screen.dart';
import '../../features/pet_care/screens/pet_care_screen.dart';
import '../../features/shop/screens/shop_screen.dart';
import '../../features/splash/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    debugLogDiagnostics: false,
    initialLocation: '/',
    redirect: (context, state) {
      final user = authState.asData?.value;
      final location = state.uri.path;

      // Rotas públicas
      if (['/login', '/'].contains(location)) return null;

      // Redirecionar para login se não autenticado
      if (user == null) return '/login';

      return null;
    },
    routes: [
      // Splash - verifica tudo e redireciona
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Login
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadeTransition(const LoginScreen()),
      ),

      // Escolha de Adoção (quando não tem pet)
      GoRoute(
        path: '/adoption-choice',
        pageBuilder: (context, state) =>
            _slideUpTransition(const AdoptionChoiceScreen()),
      ),

      // Criar Adoção
      GoRoute(
        path: '/create-adoption',
        pageBuilder: (context, state) =>
            _slideLeftTransition(const CreateAdoptionPage()),
      ),

      // Lista de Adoções
      GoRoute(
        path: '/adoption-list',
        pageBuilder: (context, state) =>
            _slideLeftTransition(const AdoptionListPage()),
      ),

      // Shell Principal (quando tem pet)
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeScreen(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/main',
                pageBuilder: (context, state) =>
                    _fadeTransition(const PetCareScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shop',
                pageBuilder: (context, state) =>
                    _fadeTransition(const ShopScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/minigames',
                pageBuilder: (context, state) =>
                    _fadeTransition(const MinigamesListScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/events',
                pageBuilder: (context, state) =>
                    _fadeTransition(const EventsScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => _buildErrorPage(context, state.uri.path),
  );
});

// Transições simples
Page _fadeTransition(Widget child) => CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );

Page _slideLeftTransition(Widget child) => CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, _, child) => SlideTransition(
        position: animation
            .drive(Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)),
        child: child,
      ),
    );

Page _slideUpTransition(Widget child) => CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, _, child) => SlideTransition(
        position: animation
            .drive(Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)),
        child: child,
      ),
    );

Widget _buildErrorPage(BuildContext context, String path) => Scaffold(
      appBar: AppBar(title: const Text('Erro')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Página não encontrada: $path'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );

// Extensões de navegação
extension AppNavigation on BuildContext {
  void goToAdoptionChoice() => go('/adoption-choice');
  void goToCreateAdoption() => go('/create-adoption');
  void goToAdoptionList() => go('/adoption-list');
  void goToPetCare() => go('/main');
  void goToLogin() => go('/login');
}
