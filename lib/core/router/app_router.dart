// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/features/album_conquistas/screens/album_achievements_screen.dart';
import 'package:petverse/features/auth/providers/auth_providers.dart';
import 'package:petverse/features/auth/screens/login_screen.dart';
import 'package:petverse/features/decoration/screens/decorate_environment_screen.dart';
import 'package:petverse/features/events/screens/events_screen.dart';
import 'package:petverse/features/home/screens/home_screen.dart';
import 'package:petverse/features/minigame/screens/click_emoji_minigame_screen.dart';
import 'package:petverse/features/minigame/screens/minigames_list_screen.dart';
import 'package:petverse/features/pet_care/screens/pet_care_screen.dart';
import 'package:petverse/features/pet_selection/screens/select_pet_screen.dart';
import 'package:petverse/features/profile/screens/profile_screen.dart';
import 'package:petverse/features/quests/screens/quests_screen.dart';
import 'package:petverse/features/settings/screens/settings_screen.dart';
import 'package:petverse/features/shop/screens/shop_screen.dart';
import 'package:petverse/features/splash/splash_screen.dart';

// Chave global para o Navigator do ShellRoute
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/', // Sempre começa pela Splash
  routes: [
    // Rotas de nível superior (fora do ShellRoute com BottomNavigationBar)
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
        path: '/select',
        builder: (_, __) =>
            const SelectPetScreen()), // Mantido fora se o fluxo for Splash -> Login -> Select -> Home(Main)

    // StatefulShellRoute para a navegação com BottomNavigationBar
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
          StatefulNavigationShell navigationShell) {
        // O widget que contém o Scaffold com a BottomNavigationBar e o corpo da aba
        return HomeScreen(navigationShell: navigationShell);
      },
      branches: <StatefulShellBranch>[
        // Branch para a aba "Pet" (Principal)
        StatefulShellBranch(
          // navigatorKey: _shellNavigatorKey, // Opcional: chave para este branch se precisar de navegação interna complexa
          routes: <RouteBase>[
            GoRoute(
              path: '/main', // Rota raiz desta aba
              builder: (BuildContext context, GoRouterState state) =>
                  const PetCareScreen(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'settings', // Acessível como /main/profile/settings
                  builder: (BuildContext context, GoRouterState state) =>
                      const SettingsScreen(),
                ),
                GoRoute(
                  path: 'profile', // Acessível como /main/profile
                  builder: (BuildContext context, GoRouterState state) =>
                      const ProfileScreen(),
                ),
                // Outras sub-rotas da PetCareScreen, se houver (ex: um detalhe específico do pet)
                GoRoute(
                    path: 'minigame_click_emoji',
                    builder: (_, __) =>
                        const ClickEmojiMinigameScreen()), // Movido para ser sub-rota de /main
                GoRoute(
                    path: 'decorate_environment',
                    builder: (_, __) => const DecorateEnvironmentScreen()),
                GoRoute(
                    path: 'quests',
                    builder: (_, __) =>
                        const QuestsScreen()), // Missões acessadas da PetCareScreen
                GoRoute(
                    path: 'album_achievements',
                    builder: (_, __) =>
                        const AlbumAchievementsScreen()), // Álbum acessado da PetCareScreen ou Perfil
              ],
            ),
          ],
        ),

        // Branch para a aba "Loja"
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/shop',
              builder: (BuildContext context, GoRouterState state) =>
                  const ShopScreen(),
              // Se a loja tiver sub-rotas (ex: detalhes do item), adicione-as aqui
            ),
          ],
        ),

        // Branch para a aba "Jogos"
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/games', // Nova rota para a lista de minijogos
              builder: (BuildContext context, GoRouterState state) =>
                  const MinigamesListScreen(),
              // A rota para o minijogo específico agora é sub-rota de /main para ser acessada de lá
            ),
          ],
        ),

        // Branch para a aba "Eventos"
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/events', // Nova rota para a tela de eventos
              builder: (BuildContext context, GoRouterState state) =>
                  const EventsScreen(),
            ),
          ],
        ),
      ],
    ),
    // Rotas que não fazem parte do Shell (ex: tela de customização de pet se for modal ou tela cheia separada)
    // GoRoute(path: '/customize_pet_full', builder: (_, __) => const PetCustomizationScreen()),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authStateChangesProvider);
    final firebaseUser = authState.asData?.value;

    final loggingIn = state.matchedLocation == '/login';
    final isSplash = state.matchedLocation == '/';
    final selectingPet = state.matchedLocation == '/select';

    if (isSplash) return null; // Permite a SplashScreen carregar

    if (firebaseUser == null) {
      // Não autenticado
      return loggingIn ? null : '/login';
    }

    // Autenticado
    if (loggingIn)
      return '/'; // Se autenticado e na tela de login, vai para splash

    // Se autenticado e não tem pet ativo, mas está tentando acessar /main ou suas sub-rotas
    // A SplashScreen agora deve lidar com o gameDataLoadingProvider e o redirecionamento para /select ou /main
    // Este redirect aqui é mais para proteger as rotas que exigem autenticação.

    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text("Página não encontrada")),
    body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("Erro: ${state.error?.message ?? 'Rota não encontrada'}"),
      ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text("Voltar para o Início"))
    ])),
  ),
);
