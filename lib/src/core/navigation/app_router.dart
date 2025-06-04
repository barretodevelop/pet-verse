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
import 'package:petverse/src/features/adoption/presentation/screens/pending_request_details_screen.dart'; // Importe a nova tela
import 'package:petverse/src/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:petverse/src/features/auth/presentation/providers/user_data_provider.dart'; // Import the new provider
import 'package:petverse/src/features/auth/presentation/screens/login_screen.dart';
import 'package:petverse/src/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart'; // Import Pet model
import 'package:petverse/src/features/pets/presentation/screens/pet_details_screen.dart'; // Import PetDetailsScreen
import 'package:petverse/src/features/settings/presentation/screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
// final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell'); // Para ShellRoute se necessário

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  // Watch the userHasPetProvider. This will be an AsyncValue<bool>.
  final userHasPetAsyncValue = ref.watch(userHasPetProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true, // Útil para depuração
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = authState.status;
      final userHasPetAV =
          userHasPetAsyncValue; // Alias para facilitar a leitura

      final bool loggedIn = authStatus == AuthStatus.authenticated;
      final String currentLocation = state.matchedLocation;

      final bool onLogin = currentLocation == AppRoutes.login;
      final bool onSplash = currentLocation == AppRoutes.splash;

      debugPrint(
          '[GoRouter Redirect] Current: $currentLocation, LoggedIn: $loggedIn, UserHasPet Loading: ${userHasPetAV.isLoading}, UserHasPet Error: ${userHasPetAV.hasError}, UserHasPet Value: ${userHasPetAV.valueOrNull}');

      // 1. Se userHasPetProvider está carregando e o usuário está logado,
      //    e não estamos já na SplashScreen, redirecione para a SplashScreen.
      //    Isso força o app a esperar que o status do pet seja carregado.
      if (loggedIn && userHasPetAV.isLoading && !onSplash) {
        debugPrint(
            '[GoRouter Redirect] Usuário logado e userHasPet carregando. Redirecionando para Splash. Vindo de: $currentLocation');
        return AppRoutes.splash;
      }

      // 2. Se userHasPetProvider teve um erro e o usuário está logado,
      //    e não estamos na SplashScreen ou LoginScreen, redirecione para Login.
      //    Isso pode ajudar a re-autenticar ou limpar um estado problemático.
      //    Considere uma tela de erro dedicada para uma melhor UX.
      if (loggedIn && userHasPetAV.hasError && !onSplash && !onLogin) {
        debugPrint(
            '[GoRouter Redirect] userHasPet teve erro. Redirecionando para Login. Vindo de: $currentLocation');
        // Opcional: Deslogar o usuário aqui antes de redirecionar
        // ref.read(authRepositoryProvider).signOut();
        return AppRoutes.login;
      }

      // A partir daqui, userHasPetAV não está mais carregando (ou o carregamento não impede a decisão)
      final bool hasPet = userHasPetAV.asData?.value ?? false;

      // Se não estiver logado e não estiver na tela de login ou splash, vá para login.
      if (!loggedIn && !onLogin && !onSplash) {
        debugPrint(
            '[GoRouter Redirect] Não logado. Redirecionando para Login. Vindo de: $currentLocation');
        return AppRoutes.login;
      }

      // Se estiver logado:
      if (loggedIn) {
        // E tentando acessar Login, OU Splash (e userHasPet já carregou)
        if (onLogin || (onSplash && !userHasPetAV.isLoading)) {
          debugPrint(
              '[GoRouter Redirect] Logado. Em Login/Splash (e userHasPet carregado). Redirecionando para Home.');
          return AppRoutes.home; // Sempre redireciona para a Home aqui.
        }

        // Se logado, TEM pet, e está tentando acessar a tela inicial de adoção,
        // redirecione para a home.
        if (hasPet &&
            !userHasPetAV.isLoading &&
            currentLocation == AppRoutes.adoptionInitial) {
          debugPrint(
              '[GoRouter Redirect] Logado, com pet, tentando acessar AdoptionInitial. Redirecionando para Home.');
          return AppRoutes.home;
        }

        // Se o usuário está logado, NÃO tem pet, e está na HomeScreen (currentLocation == AppRoutes.home),
        // a HomeScreen (definida em lib/screens/home_screen.dart) internamente já mostrará
        // AdoptionInitialScreen na aba correta. Não precisamos de um redirecionamento explícito
        // do GoRouter para AppRoutes.adoptionInitial aqui, pois isso tiraria o usuário da
        // HomeScreen (com BottomNavigationBar).
      }
      // Nenhum redirecionamento necessário.
      debugPrint(
          '[GoRouter Redirect] Nenhuma condição de redirecionamento atendida para $currentLocation.');
      return null;
    },
    refreshListenable: GoRouterRefreshStream(fb_auth.FirebaseAuth.instance
        .authStateChanges()), // Simplificado: GoRouter irá reavaliar o redirect quando os providers observados mudarem.
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
        name: AppRoutes.petDetails, // Nomear a rota para facilitar a navegação
        path: AppRoutes.petDetails, // '/pet-details'
        builder: (context, state) {
          final pet = state.extra as Pet; // Receber o objeto Pet como extra
          return PetDetailsScreen(pet: pet);
        },
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
