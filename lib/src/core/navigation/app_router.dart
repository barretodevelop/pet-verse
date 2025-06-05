// lib/src/core/navigation/app_router.dart
// CORREÇÃO CRÍTICA - Navegação simplificada para evitar loops infinitos

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/screens/home_screen.dart';
import 'package:petverse/src/core/navigation/app_routes.dart';
import 'package:petverse/src/features/adoption/presentation/screens/adopt_new_pet_screen.dart';
import 'package:petverse/src/features/adoption/presentation/screens/adoption_initial_screen.dart';
import 'package:petverse/src/features/adoption/presentation/screens/enter_friend_code_screen.dart';
import 'package:petverse/src/features/adoption/presentation/screens/pending_adoptions_screen.dart';
import 'package:petverse/src/features/adoption/presentation/screens/pending_request_details_screen.dart';
import 'package:petverse/src/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:petverse/src/features/auth/presentation/providers/user_data_provider.dart';
import 'package:petverse/src/features/auth/presentation/screens/login_screen.dart';
import 'package:petverse/src/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart';
import 'package:petverse/src/features/pets/presentation/screens/pet_details_screen.dart';
import 'package:petverse/src/features/settings/presentation/screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userStatus = ref.watch(userStatusProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // LÓGICA DE REDIRECIONAMENTO SIMPLIFICADA
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final currentLocation = state.matchedLocation;

      debugPrint('🧭 [Router] Local: $currentLocation');
      debugPrint('🧭 [Router] Logado: $isLoggedIn');
      debugPrint('🧭 [Router] UserStatus: $userStatus');

      // 1. Se não estiver logado e não estiver em login/splash -> LOGIN
      if (!isLoggedIn &&
          currentLocation != AppRoutes.login &&
          currentLocation != AppRoutes.splash) {
        debugPrint('🧭 [Router] ➡️ Redirecionando para LOGIN');
        return AppRoutes.login;
      }

      // 2. Se estiver logado e em login/splash -> HOME
      if (isLoggedIn &&
          (currentLocation == AppRoutes.login ||
              currentLocation == AppRoutes.splash)) {
        // Só redirecionar se userStatus não estiver loading
        if (userStatus != UserStatus.loading) {
          debugPrint('🧭 [Router] ➡️ Redirecionando para HOME');
          return AppRoutes.home;
        }
      }

      // 3. Se tem pets e tenta acessar adoption initial -> HOME
      if (isLoggedIn &&
          userStatus == UserStatus.hasPets &&
          currentLocation == AppRoutes.adoptionInitial) {
        debugPrint('🧭 [Router] ➡️ Usuário tem pets, redirecionando para HOME');
        return AppRoutes.home;
      }

      // 4. Nenhum redirecionamento necessário
      debugPrint('🧭 [Router] ✅ Sem redirecionamento');
      return null;
    },

    // Listener para mudanças de auth
    refreshListenable:
        GoRouterRefreshStream(fb_auth.FirebaseAuth.instance.authStateChanges()),

    routes: <RouteBase>[
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Login Screen
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Home Screen
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Settings Screen
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Pet Details Screen
      GoRoute(
        name: 'petDetails',
        path: AppRoutes.petDetails,
        builder: (context, state) {
          final pet = state.extra as Pet;
          return PetDetailsScreen(pet: pet);
        },
      ),

      // Adoption Initial Screen
      GoRoute(
        path: AppRoutes.adoptionInitial,
        builder: (context, state) => const AdoptionInitialScreen(),
      ),

      // Adopt New Pet Screen
      GoRoute(
        path: AppRoutes.adoptNewPet,
        builder: (context, state) => const AdoptNewPetScreen(),
      ),

      // Enter Friend Code Screen
      GoRoute(
        path: AppRoutes.enterFriendCode,
        builder: (context, state) => const EnterFriendCodeScreen(),
      ),

      // Pending Adoptions Screen
      GoRoute(
        path: AppRoutes.pendingAdoptions,
        builder: (context, state) => const PendingAdoptionsScreen(),
      ),

      // Pending Request Details Screen
      GoRoute(
        path: AppRoutes.pendingRequestDetails,
        builder: (context, state) {
          final requestId = state.pathParameters['requestId']!;
          return PendingRequestDetailsScreen(requestId: requestId);
        },
      ),
    ],

    // Error handling
    errorBuilder: (context, state) {
      debugPrint('🧭 [Router] 💥 ERRO: ${state.error}');
      return Scaffold(
        appBar: AppBar(title: const Text('Erro')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro de Navegação: ${state.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Voltar ao Início'),
              ),
            ],
          ),
        ),
      );
    },
  );
});

// Helper class para refresh do GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) {
        debugPrint('🧭 [GoRouterRefresh] Auth state changed');
        notifyListeners();
      },
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
