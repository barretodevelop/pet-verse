// lib/core/router/app_router.dart
// NOVO: Sistema completo de roteamento com autenticação
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/album_conquistas/screens/album_achievements_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/decoration/screens/decorate_environment_screen.dart';
import '../../features/events/screens/events_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/inventory/screens/inventory_screen.dart';
import '../../features/minigame/screens/click_emoji_minigame_screen.dart';
import '../../features/minigame/screens/minigames_list_screen.dart';
import '../../features/pet_care/screens/pet_care_screen.dart';
import '../../features/pet_customization/screens/pet_customization_screen.dart';
import '../../features/pet_selection/screens/select_pet_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/quests/screens/quests_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/shop/screens/shop_screen.dart';
import '../../features/splash/splash_screen.dart';

// Chaves para navegadores
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// Provider para o roteador
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: '/',
    redirect: (context, state) {
      // Aguardar carregamento do estado de auth
      final isLoading = authState is AsyncLoading;
      final isLoggedIn = authState.asData?.value != null;

      final isGoingToLogin = state.uri.toString() == '/login';
      final isGoingToSplash = state.uri.toString() == '/';

      // Se ainda está carregando, manter na splash
      if (isLoading) {
        return isGoingToSplash ? null : '/';
      }

      // Se não está logado e não está indo para login, redirecionar para login
      if (!isLoggedIn && !isGoingToLogin && !isGoingToSplash) {
        return '/login';
      }

      // Se está logado e está na tela de login, redirecionar para home
      if (isLoggedIn && isGoingToLogin) {
        return '/main';
      }

      return null; // Não redirecionar
    },
    routes: [
      // Rota da Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Rota de Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Rota de Seleção de Pet
      GoRoute(
        path: '/select',
        name: 'select_pet',
        builder: (context, state) => const SelectPetScreen(),
      ),

      // Rotas principais com bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Pet Care
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/main',
                name: 'pet_care',
                builder: (context, state) => const PetCareScreen(),
                routes: [
                  // Sub-rotas do Pet Care (sem barra inicial)
                  GoRoute(
                    path: 'inventory',
                    name: 'inventory',
                    builder: (context, state) => const InventoryScreen(),
                  ),
                  GoRoute(
                    path: 'customization',
                    name: 'pet_customization',
                    builder: (context, state) => const PetCustomizationScreen(),
                  ),
                  GoRoute(
                    path: 'decoration',
                    name: 'decoration',
                    builder: (context, state) =>
                        const DecorateEnvironmentScreen(),
                  ),
                  GoRoute(
                    path: 'profile',
                    name: 'profile',
                    builder: (context, state) => const ProfileScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    name: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'achievements',
                    name: 'achievements',
                    builder: (context, state) =>
                        const AlbumAchievementsScreen(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: Loja
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shop',
                name: 'shop',
                builder: (context, state) => const ShopScreen(),
                routes: [
                  GoRoute(
                    path: 'quests',
                    name: 'quests',
                    builder: (context, state) => const QuestsScreen(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 3: Mini-jogos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/minigames',
                name: 'minigames',
                builder: (context, state) => const MinigamesListScreen(),
                routes: [
                  GoRoute(
                    path: 'click_emoji',
                    name: 'click_emoji_game',
                    builder: (context, state) =>
                        const ClickEmojiMinigameScreen(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 4: Eventos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/events',
                name: 'events',
                builder: (context, state) => const EventsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],

    // Tratamento de erros de navegação
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Página não encontrada'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Ops! Página não encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'A página "${state.uri.toString()}" não existe.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/main'),
              child: const Text('Voltar ao Início'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Extensões úteis para navegação
extension GoRouterExtension on GoRouter {
  /// Limpar stack de navegação e ir para rota
  void goAndClearStack(String location) {
    while (canPop()) {
      pop();
    }
    go(location);
  }
}

// Helper class para navegação global
class AppRouter {
  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

  // Métodos de navegação úteis
  static void showErrorDialog(String message) {
    final context = _rootNavigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  static void showSuccessSnackBar(String message) {
    final context = _rootNavigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static void showErrorSnackBar(String message) {
    final context = _rootNavigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
