// lib/core/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:petverse/core/firebase/firebase_auth_service.dart';
import 'package:petverse/core/navigation/navigation_guards.dart';
import 'package:petverse/core/navigation/route_names.dart';
import 'package:petverse/presentation/screens/feed_screeen.dart';
import 'package:petverse/presentation/screens/game_screen.dart';
import 'package:petverse/presentation/screens/home_screen.dart';
import 'package:petverse/presentation/screens/login_screen.dart';
import 'package:petverse/presentation/screens/splash_screen.dart';

/// Configuração principal do roteamento da aplicação
class AppRouter {
  static final Logger _logger = Logger();
  static AppRouter? _instance;

  late final GoRouter _router;
  final Ref _ref;

  AppRouter._(this._ref) {
    _initializeRouter();
  }

  /// Singleton instance
  static AppRouter create(Ref ref) {
    return _instance = AppRouter._(ref);
  }

  static AppRouter get instance {
    if (_instance == null) {
      throw Exception('AppRouter must be created first');
    }
    return _instance!;
  }

  /// Getter para o GoRouter
  GoRouter get router => _router;

  /// Inicializa o roteador com todas as configurações
  void _initializeRouter() {
    _router = GoRouter(
      // Configurações básicas
      initialLocation: RouteNames.splash,
      debugLogDiagnostics: true,

      // Redirect global para controle de autenticação
      redirect: _globalRedirect,

      // Refresh listener para mudanças de autenticação
      refreshListenable: _AuthStateNotifier(),

      // Error handler
      errorBuilder: _errorBuilder,

      // Configuração das rotas
      routes: _buildRoutes(),

      // Observers para analytics e debug
      observers: [
        _NavigationObserver(),
      ],
    );

    _logger.i('AppRouter initialized');
  }

  /// Constrói todas as rotas da aplicação
  List<RouteBase> _buildRoutes() {
    return [
      // ========================================
      // ROTA PRINCIPAL (SPLASH)
      // ========================================
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => SplashScreen(
          onComplete: () => _handleSplashComplete(context),
        ),
      ),

      // ========================================
      // AUTENTICAÇÃO
      // ========================================
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) => LoginScreen(
          onLoginSuccess: () => _handleLoginSuccess(context),
          onLoginError: (error) => _handleLoginError(context, error),
          enabledMethods: const [LoginType.google, LoginType.apple],
          showSkipOption: true,
        ),
      ),

      // ========================================
      // NAVEGAÇÃO PRINCIPAL (COM BOTTOM BAR)
      // ========================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationWrapper(
            navigationShell: navigationShell,
          );
        },
        branches: [
          // Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.dashboard,
                name: RouteNames.dashboard,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Loja
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.store,
                name: RouteNames.store,
                builder: (context, state) => const StoreScreen(),
              ),
            ],
          ),

          // Games
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.games,
                name: RouteNames.games,
                builder: (context, state) => const GamesScreen(),
              ),
            ],
          ),

          // Feed
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.feed,
                name: RouteNames.feed,
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),
        ],
      ),

      // ========================================
      // ROTAS DE DETALHES E MODAIS
      // ========================================
      GoRoute(
        path: '${RouteNames.petDetails}/:petId',
        name: RouteNames.petDetails,
        builder: (context, state) {
          final petId = state.pathParameters['petId']!;
          final petData = state.extra as Map<String, dynamic>?;

          return PetDetailsScreen(
            petId: petId,
            petData: petData,
          );
        },
      ),

      GoRoute(
        path: RouteNames.petGeneration,
        name: RouteNames.petGeneration,
        builder: (context, state) => const PetGenerationScreen(),
      ),

      GoRoute(
        path: '${RouteNames.adoptionRequest}/:requestId?',
        name: RouteNames.adoptionRequest,
        builder: (context, state) {
          final requestId = state.pathParameters['requestId'];
          final mode = state.uri.queryParameters['mode'] ?? 'create';

          return AdoptionRequestScreen(
            requestId: requestId,
            mode: mode,
          );
        },
      ),

      // ========================================
      // CONFIGURAÇÕES E PERFIL
      // ========================================
      GoRoute(
        path: RouteNames.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          // Sub-rotas de configurações
          GoRoute(
            path: 'profile',
            name: 'settings-profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: 'notifications',
            name: 'settings-notifications',
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: 'privacy',
            name: 'settings-privacy',
            builder: (context, state) => const PrivacySettingsScreen(),
          ),
        ],
      ),

      GoRoute(
        path: RouteNames.profile,
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),

      // ========================================
      // ROTAS DE ERRO E FALLBACK
      // ========================================
      GoRoute(
        path: '/error',
        name: 'error',
        builder: (context, state) {
          final error = state.extra as String?;
          return ErrorScreen(errorMessage: error);
        },
      ),
    ];
  }

  /// Redirect global para controle de navegação
  String? _globalRedirect(BuildContext context, GoRouterState state) {
    try {
      final currentPath = state.uri.path;
      final authService = FirebaseAuthService.instance;
      final currentUser = authService.currentUser;

      _logger.d('Navigation redirect check: $currentPath');

      // Permitir splash sempre
      if (currentPath == RouteNames.splash) {
        return null;
      }

      // Se não está autenticado e não está na tela de login
      if (currentUser == null && currentPath != RouteNames.login) {
        _logger.d('Redirecting to login - user not authenticated');
        return RouteNames.login;
      }

      // Se está autenticado mas está na tela de login/splash
      if (currentUser != null &&
          (currentPath == RouteNames.login ||
              currentPath == RouteNames.splash)) {
        _logger.d('Redirecting to dashboard - user authenticated');
        return RouteNames.dashboard;
      }

      // Verificações de guards específicos
      final guards = NavigationGuards();
      final guardResult = guards.canNavigateTo(currentPath, currentUser);

      if (!guardResult.canNavigate && guardResult.redirectTo != null) {
        _logger.d('Guard redirect: ${guardResult.redirectTo}');
        return guardResult.redirectTo;
      }

      return null;
    } catch (e, stackTrace) {
      _logger.e('Navigation redirect error', error: e, stackTrace: stackTrace);
      return RouteNames.login;
    }
  }

  /// Builder para telas de erro
  Widget _errorBuilder(BuildContext context, GoRouterState state) {
    _logger.e('Navigation error: ${state.error}');

    return ErrorScreen(
      errorMessage: state.error?.toString() ?? 'Erro de navegação',
      onRetry: () => context.go(RouteNames.dashboard),
    );
  }

  /// Manipula conclusão do splash
  void _handleSplashComplete(BuildContext context) {
    // A navegação será controlada pelo redirect global
    context.go(RouteNames.dashboard);
  }

  /// Manipula sucesso no login
  void _handleLoginSuccess(BuildContext context) {
    context.go(RouteNames.dashboard);
  }

  /// Manipula erro no login
  void _handleLoginError(BuildContext context, String error) {
    _logger.w('Login error: $error');
    // Permanece na tela de login com erro
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro no login: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ========================================
  // MÉTODOS UTILITÁRIOS
  // ========================================

  /// Navega para uma rota específica
  static void go(String route, {Object? extra}) {
    instance._router.go(route, extra: extra);
  }

  /// Navega com nome da rota
  static void goNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    instance._router.goNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Push de uma nova rota
  static void push(String route, {Object? extra}) {
    instance._router.push(route, extra: extra);
  }

  /// Push com nome
  static void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    instance._router.pushNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Volta na navegação
  static void pop([Object? result]) {
    instance._router.pop(result);
  }

  /// Verifica se pode voltar
  static bool canPop() {
    return instance._router.canPop();
  }

  /// Obtém rota atual
  static String get currentRoute {
    return instance._router.routerDelegate.currentConfiguration.uri.path;
  }

  /// Obtém estado atual do router
  static RouteMatchList get currentState {
    return instance._router.routerDelegate.currentConfiguration;
  }
}

/// Wrapper para navegação principal com bottom bar
class MainNavigationWrapper extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationWrapper({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Loja',
          ),
          NavigationDestination(
            icon: Icon(Icons.games_outlined),
            selectedIcon: Icon(Icons.games),
            label: 'Games',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: 'Feed',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppRouter.goNamed(RouteNames.petGeneration),
        child: const Icon(Icons.pets),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

/// Notifier para mudanças de estado de autenticação
class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier() {
    FirebaseAuthService.instance.authStateChanges.listen((user) {
      notifyListeners();
    });
  }
}

/// Observer de navegação para analytics e debug
class _NavigationObserver extends NavigatorObserver {
  static final Logger _logger = Logger();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logger.d('Navigation: Pushed ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logger.d('Navigation: Popped ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _logger.d(
        'Navigation: Replaced ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
  }
}

/// Tela de erro
class ErrorScreen extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erro'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Algo deu errado',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'Erro desconhecido',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar Novamente'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder screens para desenvolvimento
class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Loja Screen'),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: const Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: const Center(
        child: Text('Setting Screen'),
      ),
    );
  }
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: const Center(
        child: Text('Notification Settings Screen'),
      ),
    );
  }
}

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidade')),
      body: const Center(
        child: Text('Privacy Settings Screen'),
      ),
    );
  }
}

class PetDetailsScreen extends StatelessWidget {
  final String petId;
  final Map<String, dynamic>? petData;

  const PetDetailsScreen({
    super.key,
    required this.petId,
    this.petData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Pet')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Pet ID: $petId'),
            if (petData != null) Text('Data: ${petData.toString()}'),
          ],
        ),
      ),
    );
  }
}

class PetGenerationScreen extends StatelessWidget {
  const PetGenerationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerar Pet')),
      body: const Center(
        child: Text('Pet Generation Screen'),
      ),
    );
  }
}

class AdoptionRequestScreen extends StatelessWidget {
  final String? requestId;
  final String mode;

  const AdoptionRequestScreen({
    super.key,
    this.requestId,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitação de Adoção')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Mode: $mode'),
            if (requestId != null) Text('Request ID: $requestId'),
          ],
        ),
      ),
    );
  }
}
