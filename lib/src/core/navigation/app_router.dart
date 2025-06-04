import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/src/core/navigation/app_routes.dart';
import 'package:petverse/src/features/adoption/presentation/screens/adopt_new_pet_screen.dart';
import 'package:petverse/src/features/adoption/presentation/screens/adoption_initial_screen.dart';
import 'package:petverse/src/features/adoption/presentation/screens/enter_friend_code_screen.dart';
import 'package:petverse/src/features/adoption/presentation/screens/pending_adoptions_screen.dart';
import 'package:petverse/src/features/adoption/presentation/screens/pending_request_details_screen.dart'; // Importe a nova tela
import 'package:petverse/src/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:petverse/src/features/auth/presentation/screens/login_screen.dart';
import 'package:petverse/src/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:petverse/src/features/pets/presentation/screens/home_screen.dart';
import 'package:petverse/src/features/settings/presentation/screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
// final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell'); // Para ShellRoute se necessário

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  // TODO: Criar um provider ou serviço para verificar se o usuário logado tem um pet
  // Por enquanto, vamos simular que o usuário não tem pet para testar o redirecionamento
  const bool userHasPet =
      false; // <-- SIMULAÇÃO: Mude para true quando tiver a lógica real

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true, // Útil para depuração
    // TODO: Refinar a lógica de redirecionamento para considerar o estado do pet
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authState.status == AuthStatus.authenticated;
      final bool loggingIn = state.matchedLocation == AppRoutes.login;
      final bool splashing = state.matchedLocation == AppRoutes.splash;

      // Se não estiver logado e não estiver na tela de login ou splash, vá para login.
      if (!loggedIn && !loggingIn && !splashing) {
        return AppRoutes.login;
      }

      // Se estiver logado...
      if (loggedIn && loggingIn) {
        // ...e tentando acessar a tela de login, redirecione com base se tem pet ou não.
        return userHasPet ? AppRoutes.home : AppRoutes.adoptionInitial;
      }

      // Se estiver logado e não tiver pet...
      if (loggedIn && !userHasPet) {
        // Lista de rotas permitidas dentro do fluxo de adoção inicial
        // O usuário pode navegar entre estas telas mesmo sem ter um pet ainda.
        final allowedAdoptionFlowRoutes = [
          AppRoutes.adoptionInitial,
          AppRoutes.pendingAdoptions,
          AppRoutes.adoptNewPet,
          AppRoutes.enterFriendCode,
          AppRoutes.pendingRequestDetails, // Adicione a nova rota permitida
          // Adicione aqui outras sub-rotas do fluxo de adoção, se houver.
        ];

        // ...e não estiver em uma das telas do fluxo de adoção, vá para a tela inicial de adoção.
        if (!allowedAdoptionFlowRoutes.contains(state.matchedLocation)) {
          return AppRoutes.adoptionInitial;
        }
      }

      // Nenhum redirecionamento necessário.
      return null;
    },
    refreshListenable: GoRouterRefreshStream(fb_auth.FirebaseAuth.instance
        .authStateChanges()), // Para reavaliar redirects
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home, // '/'
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      GoRoute(
        path: AppRoutes.adoptionInitial, // Nova rota adicionada
        builder: (context, state) => const AdoptionInitialScreen(),
      ),
      GoRoute(
        path: AppRoutes.adoptNewPet, // <-- Rota para Adotar Novo Pet adicionada
        builder: (context, state) => const AdoptNewPetScreen(),
      ),
      GoRoute(
        path: AppRoutes
            .enterFriendCode, // <-- Rota para Inserir Código adicionada
        builder: (context, state) => const EnterFriendCodeScreen(),
      ),
      GoRoute(
        path: AppRoutes.pendingAdoptions, // Nova rota adicionada
        builder: (context, state) => const PendingAdoptionsScreen(),
      ),
      GoRoute(
        path: AppRoutes
            .pendingRequestDetails, // Nova rota adicionada com parâmetro
        builder: (context, state) {
          final requestId =
              state.pathParameters['requestId']!; // Obtém o parâmetro da rota
          return PendingRequestDetailsScreen(
              requestId: requestId); // Passa o parâmetro para a tela
        },
      ),
      // TODO: Adicionar rotas para Login, Onboarding, Profile, etc.
    ],
  );
});

// Classe auxiliar para fazer o GoRouter ouvir a um Stream (como authStateChanges)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
