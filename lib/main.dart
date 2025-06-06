// lib/main.dart - ATUALIZADO COM SISTEMA DE NAVEGAÇÃO
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:petverse/core/navigation/back_button_controller.dart';
import 'package:petverse/core/navigation/deep_link_handler.dart';
import 'package:petverse/core/navigation/navigation_providers.dart';

// Imports existentes mantidos
import 'core/auth/social_auth_service.dart';
import 'core/config/app_config.dart';
import 'core/firebase/firebase_analytics_service.dart';
import 'core/firebase/firebase_auth_service.dart';
import 'core/firebase/firebase_config.dart';
import 'core/network/rate_limiter.dart';
import 'core/network/secure_http_client.dart';
import 'core/validation/input_validator.dart';
import 'presentation/providers/theme_provider.dart';

/// Função principal da aplicação
void main() async {
  // Configuração de error handling global
  FlutterError.onError = (details) {
    Logger().e('Flutter Error',
        error: details.exception, stackTrace: details.stack);
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      try {
        // Inicialização segura incluindo Firebase e Navegação
        await _initializeApp();

        // Executa a aplicação com navegação
        runApp(
          const ProviderScope(
            child: PetAdoteAppWithNavigation(),
          ),
        );
      } catch (e, stackTrace) {
        Logger()
            .e('App initialization failed', error: e, stackTrace: stackTrace);
        runApp(const ErrorApp());
      }
    },
    (error, stack) {
      Logger().e('Uncaught error', error: error, stackTrace: stack);
    },
  );
}

/// Inicialização segura da aplicação incluindo Firebase e Navegação
Future<void> _initializeApp() async {
  final logger = Logger();
  logger.i('Starting app initialization with Firebase and Navigation...');

  try {
    // 1. Configurações do sistema
    await _configureSystemSettings();
    logger.d('System settings configured');

    // 2. Carrega configurações de ambiente
    await AppConfig.initialize();
    logger.d('App config initialized');

    // 3. Inicializa Firebase
    await FirebaseConfig.initialize();
    logger.d('Firebase core initialized');

    // 4. Inicializa serviços Firebase
    await _initializeFirebaseServices();
    logger.d('Firebase services initialized');

    // 5. Inicializa sistema de navegação
    await _initializeNavigationSystem();
    logger.d('Navigation system initialized');

    // 6. Inicializa rate limiting baseado no ambiente
    RateLimiterFactory.createForEnvironment(
      AppConfig.instance.environment.name,
    );
    logger.d('Rate limiter configured');

    // 7. Inicializa autenticação social
    await SocialAuthService.initialize();
    logger.d('Social auth service initialized');

    // // 8. Validações de segurança
    // await _performSecurityChecks();
    // logger.d('Security checks completed');

    logger.i('App initialization completed successfully');
  } catch (e, stackTrace) {
    logger.e('Failed to initialize app', error: e, stackTrace: stackTrace);
    rethrow;
  }
}

/// Inicializa serviços específicos do Firebase
Future<void> _initializeFirebaseServices() async {
  final logger = Logger();

  try {
    // Inicializa Firebase Auth Service
    await FirebaseAuthService.initialize();
    logger.d('Firebase Auth Service initialized');

    // Inicializa Firebase Analytics
    await FirebaseAnalyticsService.initialize();
    logger.d('Firebase Analytics Service initialized');

    logger.d('Firebase services ready');
  } catch (e, stackTrace) {
    logger.e('Firebase services initialization failed',
        error: e, stackTrace: stackTrace);
    rethrow;
  }
}

/// Inicializa sistema de navegação
Future<void> _initializeNavigationSystem() async {
  final logger = Logger();

  try {
    // Inicializa handler de deep links
    await DeepLinkHandler.instance.initialize();
    logger.d('Deep link handler initialized');

    // Configura controle de back button
    BackButtonController.instance.configure(
      doubleTapThreshold: const Duration(seconds: 2),
    );
    logger.d('Back button controller configured');

    logger.d('Navigation system ready');
  } catch (e, stackTrace) {
    logger.e('Navigation system initialization failed',
        error: e, stackTrace: stackTrace);
    rethrow;
  }
}

/// Configurações do sistema (mantido do original)
Future<void> _configureSystemSettings() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

/// Verificações de segurança (mantido do original)
Future<void> _performSecurityChecks() async {
  final config = AppConfig.instance;
  final logger = Logger();

  if (config.isProduction && config.debugMode) {
    logger.w('WARNING: Debug mode enabled in production');
  }

  if (config.isProduction && !config.hasAllRequiredApiKeys) {
    throw Exception('Missing required API keys in production environment');
  }

  if (!FirebaseConfig.isInitialized) {
    throw Exception('Firebase not properly initialized');
  }

  // Testa conectividade básica se em produção
  if (config.isProduction) {
    try {
      final httpClient = SecureHttpClient.instance;
      final isConnected = await httpClient.ping().timeout(
            const Duration(seconds: 5),
          );

      if (!isConnected) {
        logger.w('Network connectivity check failed');
      }
    } catch (e) {
      logger.w('Network connectivity check error: $e');
    }
  }

  // Valida sistema de validação
  final testValidation = InputValidator.validate(
    'test input',
    ValidationType.generic,
  );

  if (!testValidation.isValid) {
    throw Exception('Input validation system not working correctly');
  }

  logger.i('Security checks passed');
}

/// Widget raiz da aplicação com navegação integrada
class PetAdoteAppWithNavigation extends ConsumerStatefulWidget {
  const PetAdoteAppWithNavigation({super.key});

  @override
  ConsumerState<PetAdoteAppWithNavigation> createState() =>
      _PetAdoteAppWithNavigationState();
}

class _PetAdoteAppWithNavigationState
    extends ConsumerState<PetAdoteAppWithNavigation>
    with WidgetsBindingObserver {
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cleanupResources();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      default:
        break;
    }
  }

  /// Manipula quando o app volta do background
  void _handleAppResumed() {
    _logger.d('App resumed');

    // Verifica se as configurações ainda são válidas
    if (!AppConfig.instance.isInitialized) {
      _logger.w('App config not initialized on resume');
      _restartApp();
    }

    if (!FirebaseConfig.isInitialized) {
      _logger.w('Firebase not initialized on resume');
      _restartApp();
    }
  }

  /// Manipula quando o app vai para o background
  void _handleAppPaused() {
    _logger.d('App paused');

    // Atualiza última atividade do usuário se autenticado
    final currentUser = FirebaseAuthService.instance.currentUser;
    if (currentUser != null) {
      _logger.d('Updating user last activity');
      // Aqui poderia fazer update no Firestore se necessário
    }
  }

  /// Manipula quando o app é finalizado
  void _handleAppDetached() {
    _logger.d('App detached');
    _cleanupResources();
  }

  /// Limpa recursos da aplicação
  void _cleanupResources() {
    SecureHttpClient.instance.dispose();
    FirebaseAuthService.instance.dispose();
    BackButtonController.instance.release();
  }

  /// Reinicia a aplicação
  void _restartApp() {
    // Implementar lógica de restart se necessário
    _logger.w('App restart requested');
  }

  @override
  Widget build(BuildContext context) {
    // Observa o provider do GoRouter
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      // Configurações básicas
      title: 'Pet Adote',
      debugShowCheckedModeBanner: false,

      // Configuração do router
      routerConfig: router,

      // Temas (usando providers existentes)
      themeMode: ref.watch(themeModeProvider),
      theme: ref.watch(lightThemeProvider),
      darkTheme: ref.watch(darkThemeProvider),

      // Configurações de localização
      locale: const Locale('pt', 'BR'),

      // Builder global para aplicar controles de navegação
      builder: (context, child) {
        return AppWrapper(child: child);
      },
    );
  }
}

/// Wrapper global para configurações que afetam toda a aplicação
class AppWrapper extends ConsumerWidget {
  final Widget? child;

  const AppWrapper({super.key, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MediaQuery(
      // Remove padding desnecessário em alguns dispositivos
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
        ),
      ),
      child: NavigationWrapper(
        // child: NavigationDebugOverlay(
        child: child ?? const SizedBox.shrink(),
        // ),
      ),
    );
  }
}

/// Wrapper que aplica controles globais de navegação
class NavigationWrapper extends ConsumerWidget {
  final Widget? child;

  const NavigationWrapper({super.key, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackButtonHandler(
      enableDoubleTapToExit: true,
      exitMessage: 'Pressione novamente para sair',
      // child: NavigationLoadingOverlay(
      child: child ?? const SizedBox.shrink(),
      // ),
    );
  }
}

/// Aplicação de erro para casos críticos (mantida do original)
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Adote - Error',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 24),
              const Text(
                'Falha crítica na inicialização',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Por favor, reinstale o aplicativo.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================
// CONFIGURAÇÕES ATUALIZADAS
// ========================================

/// Classe para configurações globais da aplicação (atualizada com navegação)
class AppConstants {
  // URLs da API (mantidas)
  static String get baseUrl => AppConfig.instance.backendBaseUrl;
  static String get geminiUrl => AppConfig.instance.geminiBaseUrl;
  static String get imagenUrl => AppConfig.instance.imagenBaseUrl;

  // Configurações Firebase (mantidas)
  static Map<String, dynamic> get firebaseConfig =>
      FirebaseConfig.getConfigInfo();
  static bool get isFirebaseInitialized => FirebaseConfig.isInitialized;

  // Configurações de navegação (NOVAS)
  static const Duration navigationTransitionDuration =
      Duration(milliseconds: 300);
  static const Duration navigationDebounce = Duration(milliseconds: 500);
  static const int maxNavigationHistory = 10;
  static const Duration deepLinkTimeout = Duration(seconds: 5);

  // Configurações de tempo (mantidas)
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Demais configurações mantidas...
  static const int maxPetsInRequest = 3;
  static const int adoptionRequestDuration = 5;
  static const int initialCoins = 1000;
  static const int initialGems = 50;
  static const int initialXP = 0;

  // Configurações de interface (mantidas)
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const Curve defaultCurve = Curves.easeInOut;
  static const Duration defaultTransition = Duration(milliseconds: 200);

  // Configurações de debug (mantidas)
  static bool get enableDebugLogging => AppConfig.instance.debugMode;
  static bool get enablePerformanceOverlay => AppConfig.instance.debugMode;
  static bool get enableNavigationDebug => AppConfig.instance.debugMode;
}

/// Utilitários globais da aplicação (atualizados com navegação)
class AppUtils {
  static final Logger _logger = Logger();

  // Métodos existentes mantidos...
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  // NOVOS métodos relacionados à navegação

  /// Gera deep link para compartilhamento
  static Future<String> generateShareLink(String route,
      {Map<String, String>? params}) async {
    try {
      return DeepLinkHandler.instance
          .generateDeepLink(route, parameters: params);
    } catch (e) {
      _logger.w('Failed to generate share link: $e');
      return 'https://petadote.app';
    }
  }

  /// Compartilha deep link
  static Future<void> shareRoute(String route,
      {Map<String, String>? params}) async {
    try {
      await DeepLinkHandler.instance.shareDeepLink(route, parameters: params);
    } catch (e) {
      _logger.w('Failed to share route: $e');
    }
  }

  /// Verifica se uma rota é válida
  static bool isValidRoute(String route) {
    // Lista de rotas válidas conhecidas
    const validRoutes = [
      '/dashboard',
      '/store',
      '/games',
      '/feed',
      '/pet',
      '/adoption',
      '/generate-pet',
      '/settings',
      '/profile',
    ];

    return validRoutes.any((validRoute) => route.startsWith(validRoute));
  }

  /// Log de debug seguro para navegação
  static void navigationLog(String message, {Object? data}) {
    if (AppConstants.enableNavigationDebug) {
      _logger.d('[Navigation] $message');
      if (data != null) {
        _logger.d('Navigation Data: $data');
      }
    }
  }

  // Métodos existentes mantidos...
  static Color getBorderColorByLevel(int level) {
    if (level >= 10) return const Color(0xFFFFD700);
    if (level >= 5) return const Color(0xFFC0C0C0);
    return const Color(0xFFCD7F32);
  }

  static bool isValidEmail(String email) {
    final validation = InputValidator.validate(email, ValidationType.email);
    return validation.isValid;
  }

  static String? validateUserInput(String input, ValidationType type) {
    final validation = InputValidator.validate(input, type);
    return validation.isValid ? null : validation.error;
  }

  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static void debugLog(String message, {Object? data}) {
    if (AppConstants.enableDebugLogging) {
      _logger.d('[PetAdote] $message');
      if (data != null) {
        _logger.d('Data: $data');
      }
    }
  }

  static void errorLog(String message,
      {Object? error, StackTrace? stackTrace}) {
    _logger.e('[PetAdote] $message', error: error, stackTrace: stackTrace);
  }

  static Future<bool> checkFirebaseConnectivity() async {
    try {
      if (!FirebaseConfig.isInitialized) {
        return false;
      }

      final authService = FirebaseAuthService.instance;
      final currentUser = authService.currentUser;

      if (currentUser != null) {
        await currentUser.getIdToken(true);
      }

      return true;
    } catch (e) {
      _logger.w('Firebase connectivity check failed: $e');
      return false;
    }
  }
}
