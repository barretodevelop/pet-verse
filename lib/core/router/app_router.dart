// app_router.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/erro/error_page.dart';
import 'package:petverse/core/theme/app_theme.dart';
import 'package:petverse/feature/adoption/presentation/pages/adoption_list_page.dart';
import 'package:petverse/feature/adoption/presentation/pages/create_adoption_page.dart';
import 'package:petverse/feature/adoption/presentation/pages/create_request_page.dart';
import 'package:petverse/feature/adoption/presentation/pages/need_adoption_page.dart';
import 'package:petverse/feature/adoption/presentation/pages/public_adoptions_page.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';
import 'package:petverse/feature/home/presentation/pages/home_page.dart';
import 'package:petverse/feature/pet/presentation/pages/pet_main_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authenticationNotifierProvider);

  return GoRouter(
    initialLocation: '/splash', // Começa sempre no splash
    debugLogDiagnostics: true, // Útil para ver os logs do GoRouter

    // --- LÓGICA DE REDIRECIONAMENTO ---
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoadingAuth =
          authState.isLoading; // Verifica se a autenticação está carregando
      final isGoingToLogin = state.matchedLocation == '/auth/login';
      final isGoingToSplash = state.matchedLocation == '/splash';

      if (isLoadingAuth) {
        return isGoingToSplash ? null : '/splash';
      }

      if (!isAuthenticated) {
        return isGoingToLogin ? null : '/auth/login';
      }

      if (isAuthenticated) {
        return (isGoingToLogin || isGoingToSplash) ? '/home' : null;
      }

      return null;
    },
    // --- FIM DA LÓGICA DE REDIRECIONAMENTO ---

    errorBuilder: (context, state) => ErrorPage(
      error: state.error.toString(),
      onRetry: () => context.go('/home'),
    ),
    routes: [
      // Home Route
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Adoption Routes
      GoRoute(
        path: '/need-adoption',
        name: 'need-adoption',
        builder: (context, state) => const NeedAdoptionPage(),
      ),

      GoRoute(
        path: '/create-request',
        name: 'create-request',
        builder: (context, state) => const CreateRequestPage(),
      ),

      GoRoute(
        path: '/public-adoptions',
        name: 'public-adoptions',
        builder: (context, state) => const PublicAdoptionsPage(),
      ),

      GoRoute(
        path: '/adoption-details/:requestId',
        name: 'adoption-details',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return AdoptionDetailsPage(requestId: requestId);
        },
      ),

      // Pet Route
      GoRoute(
        path: '/pet-main',
        name: 'pet-main',
        builder: (context, state) => const PetMainPage(),
      ),

      // Share Link Route
      GoRoute(
        path: '/adopt/:requestId',
        name: 'adopt-share',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return AdoptionDetailsPage(
            requestId: requestId,
            isSharedLink: true,
          );
        },
      ),
    ],
    // routes: [
    //   GoRoute(
    //     path: '/auth/login',
    //     pageBuilder: (context, state) => CustomTransitionPage(
    //       key: state.pageKey,
    //       child: const LoginPage(),
    //       transitionsBuilder: _fadeTransition,
    //     ),
    //   ),
    //   GoRoute(
    //     path: '/splash',
    //     pageBuilder: (context, state) => CustomTransitionPage(
    //       key: state.pageKey,
    //       child: const SplashScreen(), // O splash screen simples e limpo
    //       transitionsBuilder: _fadeTransition,
    //     ),
    //   ),
    //   GoRoute(
    //     path: '/',
    //     builder: (context, state) => const HomePage(),
    //     routes: [
    //       // Suas rotas filhas aqui
    //       GoRoute(
    //         path: 'rooms/chat/:roomId',
    //         pageBuilder: (context, state) {
    //           final roomId = state.pathParameters['roomId']!;
    //           return CustomTransitionPage(
    //             key: state.pageKey,
    //             child: RoomChatPage(roomId: roomId),
    //             transitionsBuilder: _fadeTransition,
    //           );
    //         },
    //       ),
    //       // GoRoute(
    //       //   path: 'pet/adopt/:roomId',
    //       //   pageBuilder: (context, state) {
    //       //     final roomId = state.pathParameters['roomId']!;
    //       //     return CustomTransitionPage(
    //       //       key: state.pageKey,
    //       //       child: PetAdoptionPage(roomId: roomId),
    //       //       transitionsBuilder: _fadeTransition,
    //       //     );
    //       //   },
    //       // ),
    //       // GoRoute(
    //       //   path: 'shop',
    //       //   pageBuilder: (context, state) => CustomTransitionPage(
    //       //     key: state.pageKey,
    //       //     child: const ShopPage(),
    //       //     transitionsBuilder: _fadeTransition,
    //       //   ),
    //       // ),
    //       // GoRoute(
    //       //   path: 'missions',
    //       //   pageBuilder: (context, state) => CustomTransitionPage(
    //       //     key: state.pageKey,
    //       //     child: const MissionsPage(),
    //       //     transitionsBuilder: _fadeTransition,
    //       //   ),
    //       // ),
    //       // GoRoute(
    //       //   path: 'games/catch-food',
    //       //   pageBuilder: (context, state) => CustomTransitionPage(
    //       //     key: state.pageKey,
    //       //     child: const CatchFoodGame(),
    //       //     transitionsBuilder: _fadeTransition,
    //       //   ),
    //       // ),
    //       // GoRoute(
    //       //   path: 'games/pet-jump',
    //       //   pageBuilder: (context, state) => CustomTransitionPage(
    //       //     key: state.pageKey,
    //       //     child: const PetJumpGame(),
    //       //     transitionsBuilder: _fadeTransition,
    //       //   ),
    //       // ),
    //     ],
    //   ),
    // ],

    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
  );
});

// Custom Transitions (mantenha essas funções no final do arquivo)
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: animation,
    child: child,
  );
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: false,
    routes: [
      // Home Route
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Adoption Routes
      GoRoute(
        path: '/list-adoption',
        name: 'list-adoption',
        builder: (context, state) => const AdoptionListPage(),
      ),

      GoRoute(
        path: '/create-adoption',
        name: 'create-adoption',
        builder: (context, state) => const CreateAdoptionPage(),
      ),

      GoRoute(
        path: '/public-adoptions',
        name: 'public-adoptions',
        builder: (context, state) => const PublicAdoptionsPage(),
      ),

      GoRoute(
        path: '/adoption-details/:requestId',
        name: 'adoption-details',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return AdoptionDetailsPage(requestId: requestId);
        },
      ),

      // Pet Route
      GoRoute(
        path: '/pet-main',
        name: 'pet-main',
        builder: (context, state) => const PetMainPage(),
      ),

      // Share Link Route
      GoRoute(
        path: '/adopt/:requestId',
        name: 'adopt-share',
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return AdoptionDetailsPage(
            requestId: requestId,
            isSharedLink: true,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Página não encontrada',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'A página que você está procurando não existe.',
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Voltar ao Início'),
            ),
          ],
        ),
      ),
    ),
  );
});
