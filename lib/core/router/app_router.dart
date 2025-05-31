// lib/core/router/app_router.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/erro/error_page.dart';
import 'package:petverse/core/providers/app_state_provider.dart';
import 'package:petverse/feature/adoption/presentation/pages/create_adoption_page.dart';
import 'package:petverse/feature/adoption/presentation/pages/list_adoption_page.dart';
import 'package:petverse/feature/auth/presentation/login_page.dart';
import 'package:petverse/feature/home/presentation/pages/home_page.dart';
import 'package:petverse/feature/pet/presentation/pages/pet_main_page.dart';
import 'package:petverse/feature/profile/presentation/profile_page.dart';
import 'package:petverse/feature/settings/presentation/settings_page.dart';
import 'package:petverse/feature/shop/presetation/shop.dart';
import 'package:petverse/feature/splash/presentation/splash_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final uiState = ref.watch(uiStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,

    // --- LÓGICA DE REDIRECIONAMENTO CORRIGIDA ---
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthenticated = uiState.isAuthenticated;
      final isLoading = uiState.isLoading;
      final appState = uiState.appState;

      // Lista de rotas públicas que não precisam de autenticação
      final publicRoutes = ['/splash', '/auth/login'];
      final isPublicRoute = publicRoutes.contains(location);

      // Se está carregando, manter na rota atual ou ir para splash
      if (isLoading) {
        return location == '/splash' ? null : '/splash';
      }

      // Se não está autenticado
      if (!isAuthenticated) {
        // Se já está em rota pública, continuar
        if (isPublicRoute) return null;
        // Senão, redirecionar para login
        return '/auth/login';
      }

      // Se está autenticado
      if (isAuthenticated) {
        // Se está em rota pública, redirecionar baseado no estado do app
        if (isPublicRoute) {
          switch (appState) {
            case AppState.needsAdoption:
              return '/need-adoption';
            case AppState.hasPet:
              return '/home';
            case AppState.loading:
              return '/splash';
            default:
              return '/home';
          }
        }

        // Se está tentando acessar rota que não deveria baseado no estado
        if (appState == AppState.needsAdoption &&
            location.startsWith('/pet-')) {
          return '/need-adoption';
        }
      }

      return null; // Manter na rota atual
    },

    errorBuilder: (context, state) => ErrorPage(
      error: state.error.toString(),
      onRetry: () => context.go('/home'),
    ),

    routes: [
      // Splash Route
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Auth Routes
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Home Route
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Profile Routes
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),

      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),

      // Adoption Routes
      GoRoute(
        path: '/need-adoption',
        name: 'need-adoption',
        builder: (context, state) => const HomePage(),
      ),

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

      // Pet Routes
      GoRoute(
        path: '/pet-main',
        name: 'pet-main',
        builder: (context, state) => const PetMainPage(),
      ),

      // shop
      GoRoute(
        path: '/shop',
        name: 'shop',
        builder: (context, state) => const ShopPage(),
      ),
    ],

    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
  );
});

// // Router simplificado para desenvolvimento/teste
// final simpleRouterProvider = Provider<GoRouter>((ref) {
//   return GoRouter(
//     initialLocation: '/home',
//     debugLogDiagnostics: false,
//     routes: [
//       // Home Route
//       GoRoute(
//         path: '/home',
//         name: 'home',
//         builder: (context, state) => const HomePage(),
//       ),

//       GoRoute(
//         path: '/profile',
//         name: 'profile',
//         builder: (context, state) => const ProfilePage(),
//       ),

//       GoRoute(
//         path: '/settings',
//         name: 'settings',
//         builder: (context, state) => const SettingsPage(),
//       ),

//       GoRoute(
//         path: '/list-adoption',
//         name: 'list-adoption',
//         builder: (context, state) => const AdoptionListPage(),
//       ),

//       GoRoute(
//         path: '/create-adoption',
//         name: 'create-adoption',
//         builder: (context, state) => const CreateAdoptionPage(),
//       ),

//       // GoRoute(
//       //   path: '/public-adoptions',
//       //   name: 'public-adoptions',
//       //   builder: (context, state) => const PublicAdoptionsPage(),
//       // ),

//       // GoRoute(
//       //   path: '/adoption-details/:requestId',
//       //   name: 'adoption-details',
//       //   builder: (context, state) {
//       //     final requestId = state.pathParameters['requestId']!;
//       //     return AdoptionDetailsPage(requestId: requestId);
//       //   },
//       // ),

//       // Pet Route
//       GoRoute(
//         path: '/pet-main',
//         name: 'pet-main',
//         builder: (context, state) => const PetMainPage(),
//       ),

//       // Share Link Route
//       // GoRoute(
//       //   path: '/adopt/:requestId',
//       //   name: 'adopt-share',
//       //   builder: (context, state) {
//       //     final requestId = state.pathParameters['requestId']!;
//       //     return AdoptionDetailsPage(
//       //       requestId: requestId,
//       //       isSharedLink: true,
//       //     );
//       //   },
//       // ),
//     ],
//     errorBuilder: (context, state) => Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.error_outline,
//               size: 64,
//               color: AppTheme.error,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Página não encontrada',
//               style: AppTheme.headingMedium,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'A página que você está procurando não existe.',
//               style: AppTheme.bodyMedium,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () => context.go('/home'),
//               child: const Text('Voltar ao Início'),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// });

// Provider para navegação com observação de estado
final smartRouterProvider = Provider<GoRouter>((ref) {
  // Observa mudanças no estado da aplicação
  ref.listen(uiStateProvider, (previous, next) {
    // Pode adicionar lógica de navegação automática aqui se necessário
    if (previous?.isAuthenticated != next.isAuthenticated) {
      // Usuário logou/deslogou - GoRouter já vai gerenciar via redirect
    }
  });

  return ref.watch(appRouterProvider);
});
