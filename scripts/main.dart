// // Entry point da aplicação com configurações de segurança
// // Função auxiliar para tratamento de erros não capturados
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:logger/logger.dart';
// import 'package:petverse/core/network/rate_limiter.dart';
// import 'package:petverse/core/network/secure_http_client.dart';
// import 'package:petverse/core/validation/input_validator.dart';
// import 'package:petverse/main.dart';
// import 'package:petverse/presentation/providers/theme_provider.dart';
// import 'package:petverse/presentation/screens/home_screen.dart';
// import 'package:petverse/presentation/screens/login_screen.dart';
// import 'package:petverse/presentation/screens/splash_screen.dart';
// // runZonedGuarded<Future<void>>(Future<void> Function() body, void Function(Object error, StackTrace stack) onError) {}

// /// Enum para controlar o estado da aplicação
// enum AppState {
//   loading,
//   configuring,
//   login,
//   home,
//   error,
// }

// /// Função principal da aplicação
// void main() async {
//   // Configuração de error handling global
//   FlutterError.onError = (details) {
//     Logger().e('Flutter Error',
//         error: details.exception, stackTrace: details.stack);
//   };

//   runZonedGuarded(
//     () async {
//       WidgetsFlutterBinding.ensureInitialized();

//       try {
//         // Inicialização segura
//         await _initializeApp();

//         // Executa a aplicação
//         runApp(
//           const ProviderScope(
//             child: PetAdoteApp(),
//           ),
//         );
//       } catch (e, stackTrace) {
//         Logger()
//             .e('App initialization failed', error: e, stackTrace: stackTrace);
//         runApp(const ErrorApp());
//       }
//     },
//     (error, stack) {
//       Logger().e('Uncaught error', error: error, stackTrace: stack);
//     },
//   );
// }

// /// Inicialização segura da aplicação
// Future<void> _initializeApp() async {
//   final logger = Logger();
//   logger.i('Starting app initialization...');

//   try {
//     // 1. Configurações do sistema
//     await _configureSystemSettings();
//     logger.d('System settings configured');

//     // 2. Carrega configurações de ambiente
//     await AppConfig.initialize();
//     logger.d('App config initialized');

//     // 3. Inicializa rate limiting baseado no ambiente
//     RateLimiterFactory.createForEnvironment(
//       AppConfig.instance.environment.name,
//     );
//     logger.d('Rate limiter configured');

//     // 4. Inicializa cliente HTTP seguro
//     SecureHttpClient.initialize(
//       retryPolicy: AppConfig.instance.isProduction
//           ? const RetryPolicy.conservative()
//           : const RetryPolicy(),
//     );
//     logger.d('Secure HTTP client initialized');

//     // 5. Validações de segurança
//     await _performSecurityChecks();
//     logger.d('Security checks completed');

//     logger.i('App initialization completed successfully');
//   } catch (e, stackTrace) {
//     logger.e('Failed to initialize app', error: e, stackTrace: stackTrace);
//     rethrow;
//   }
// }

// /// Configurações do sistema
// Future<void> _configureSystemSettings() async {
//   // Configuração da orientação (apenas portrait)
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   // Configuração da barra de status
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//       systemNavigationBarColor: Colors.transparent,
//       systemNavigationBarIconBrightness: Brightness.dark,
//     ),
//   );
// }

// /// Verificações de segurança na inicialização
// Future<void> _performSecurityChecks() async {
//   final config = AppConfig.instance;
//   final logger = Logger();

//   // Verifica se estamos em debug mode em produção
//   if (config.isProduction && config.debugMode) {
//     logger.w('WARNING: Debug mode enabled in production');
//   }

//   // Verifica se as API keys estão configuradas
//   if (config.isProduction && !config.hasAllRequiredApiKeys) {
//     throw Exception('Missing required API keys in production environment');
//   }

//   // Testa conectividade básica se em produção
//   if (config.isProduction) {
//     try {
//       final httpClient = SecureHttpClient.instance;
//       final isConnected = await httpClient.ping().timeout(
//             const Duration(seconds: 5),
//           );

//       if (!isConnected) {
//         logger.w('Network connectivity check failed');
//       }
//     } catch (e) {
//       logger.w('Network connectivity check error: $e');
//     }
//   }

//   // Valida sistema de validação
//   final testValidation = InputValidator.validate(
//     'test input',
//     ValidationType.generic,
//   );

//   if (!testValidation.isValid) {
//     throw Exception('Input validation system not working correctly');
//   }

//   logger.i('Security checks passed');
// }

// /// Widget raiz da aplicação
// class PetAdoteApp extends ConsumerStatefulWidget {
//   const PetAdoteApp({super.key});

//   @override
//   ConsumerState<PetAdoteApp> createState() => _PetAdoteAppState();
// }

// class _PetAdoteAppState extends ConsumerState<PetAdoteApp>
//     with WidgetsBindingObserver {
//   AppState _appState = AppState.loading;
//   String? _errorMessage;
//   final Logger _logger = Logger();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _startApp();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     // Cleanup dos recursos de segurança
//     SecureHttpClient.instance.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);

//     switch (state) {
//       case AppLifecycleState.resumed:
//         _handleAppResumed();
//         break;
//       case AppLifecycleState.paused:
//         _handleAppPaused();
//         break;
//       case AppLifecycleState.detached:
//         _handleAppDetached();
//         break;
//       default:
//         break;
//     }
//   }

//   /// Inicia a aplicação
//   Future<void> _startApp() async {
//     try {
//       setState(() {
//         _appState = AppState.configuring;
//       });

//       // Aguarda configurações finalizarem
//       await Future.delayed(const Duration(seconds: 2));

//       // Verifica se o usuário já está logado
//       final isLoggedIn = await _checkUserLoginStatus();

//       setState(() {
//         _appState = isLoggedIn ? AppState.home : AppState.login;
//       });
//     } catch (error, stackTrace) {
//       _logger.e('App startup failed', error: error, stackTrace: stackTrace);

//       setState(() {
//         _appState = AppState.error;
//         _errorMessage = 'Falha ao inicializar aplicação: $error';
//       });
//     }
//   }

//   /// Verifica status de login do usuário
//   Future<bool> _checkUserLoginStatus() async {
//     try {
//       // Implementar verificação real de login
//       // Por enquanto, sempre retorna true para demonstração
//       return true;
//     } catch (e) {
//       _logger.w('Login status check failed: $e');
//       return false;
//     }
//   }

//   /// Manipula sucesso no login
//   void _handleLoginSuccess() {
//     setState(() {
//       _appState = AppState.home;
//     });
//   }

//   /// Manipula erro no login
//   void _handleLoginError(String error) {
//     _showErrorSnackBar('Erro no login: $error');
//   }

//   /// Manipula quando o app volta do background
//   void _handleAppResumed() {
//     _logger.d('App resumed');

//     // Verifica se as configurações ainda são válidas
//     if (!AppConfig.instance.isInitialized) {
//       _logger.w('App config not initialized on resume');
//       _restartApp();
//     }
//   }

//   /// Manipula quando o app vai para o background
//   void _handleAppPaused() {
//     _logger.d('App paused');

//     // Limpa dados sensíveis da memória se necessário
//     // (implementar conforme necessário)
//   }

//   /// Manipula quando o app é finalizado
//   void _handleAppDetached() {
//     _logger.d('App detached');

//     // Cleanup final
//     SecureHttpClient.instance.dispose();
//   }

//   /// Reinicia a aplicação
//   void _restartApp() {
//     setState(() {
//       _appState = AppState.loading;
//       _errorMessage = null;
//     });

//     _startApp();
//   }

//   /// Mostra snackbar de erro
//   void _showErrorSnackBar(String message) {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     scaffoldMessenger.showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red[600],
//         behavior: SnackBarBehavior.floating,
//         action: SnackBarAction(
//           label: 'Tentar Novamente',
//           textColor: Colors.white,
//           onPressed: _restartApp,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Observa o tema atual
//     final themeMode = ref.watch(themeModeProvider);
//     final lightTheme = ref.watch(lightThemeProvider);
//     final darkTheme = ref.watch(darkThemeProvider);

//     return MaterialApp(
//       // Configurações básicas
//       title: 'Pet Adote',
//       debugShowCheckedModeBanner: false,

//       // Temas
//       themeMode: themeMode,
//       theme: lightTheme,
//       darkTheme: darkTheme,

//       // Configurações de localização
//       locale: const Locale('pt', 'BR'),

//       // Roteamento baseado no estado
//       home: _buildCurrentScreen(),

//       // Builder para configurações globais
//       builder: (context, child) {
//         return _AppWrapper(child: child);
//       },
//     );
//   }

//   /// Constrói a tela atual baseada no estado
//   Widget _buildCurrentScreen() {
//     switch (_appState) {
//       case AppState.loading:
//       case AppState.configuring:
//         return SplashScreen(
//           onComplete: () {
//             // O estado já é gerenciado pelo _startApp
//           },
//         );

//       case AppState.login:
//         return LoginScreen(
//           onLoginSuccess: _handleLoginSuccess,
//           onLoginError: _handleLoginError,
//           enabledMethods: const [
//             LoginType.google,
//             LoginType.apple,
//           ],
//           showSkipOption: !AppConfig.instance.isProduction,
//         );

//       case AppState.home:
//         return const HomeScreen();

//       case AppState.error:
//         return _buildErrorScreen();
//     }
//   }

//   /// Constrói tela de erro
//   Widget _buildErrorScreen() {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.error_outline,
//                 size: 64,
//                 color: Colors.red[400],
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 'Ops! Algo deu errado',
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 _errorMessage ?? 'Erro desconhecido',
//                 style: Theme.of(context).textTheme.bodyMedium,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               ElevatedButton.icon(
//                 onPressed: _restartApp,
//                 icon: const Icon(Icons.refresh),
//                 label: const Text('Tentar Novamente'),
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Aplicação de erro para casos críticos
// class ErrorApp extends StatelessWidget {
//   const ErrorApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Pet Adote - Error',
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.error_outline,
//                 size: 64,
//                 color: Colors.red[400],
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Falha crítica na inicialização',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Por favor, reinstale o aplicativo.',
//                 style: TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Wrapper global para configurações que afetam toda a aplicação
// class _AppWrapper extends ConsumerWidget {
//   final Widget? child;

//   const _AppWrapper({this.child});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return MediaQuery(
//       // Remove padding desnecessário em alguns dispositivos
//       data: MediaQuery.of(context).copyWith(
//         textScaler: TextScaler.linear(
//           MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
//         ),
//       ),
//       child: child ?? const SizedBox.shrink(),
//     );
//   }
// }

// // ========================================
// // CONFIGURAÇÕES ATUALIZADAS
// // ========================================

// /// Classe para configurações globais da aplicação (atualizada)
// class AppConstants {
//   // URLs da API (agora gerenciadas pelo AppConfig)
//   static String get baseUrl => AppConfig.instance.backendBaseUrl;
//   static String get geminiUrl => AppConfig.instance.geminiBaseUrl;
//   static String get imagenUrl => AppConfig.instance.imagenBaseUrl;

//   // Configurações de tempo
//   static const Duration splashDuration = Duration(seconds: 3);
//   static const Duration animationDuration = Duration(milliseconds: 300);

//   // Configurações de cache
//   static int get maxCacheSize => AppConfig.instance.cacheMaxSize;
//   static Duration get cacheTimeout =>
//       Duration(seconds: AppConfig.instance.cacheMaxAge);

//   // Configurações de pet
//   static const int maxPetsInRequest = 3;
//   static const int adoptionRequestDuration = 5; // dias

//   // Configurações de moeda
//   static const int initialCoins = 1000;
//   static const int initialGems = 50;
//   static const int initialXP = 0;

//   // Configurações de custos
//   static const int petGenerationCost = 20; // gems
//   static const int feedPetCost = 10; // coins
//   static const int playPetCost = 5; // coins
//   static const int restPetCost = 8; // coins

//   // Configurações de recompensas
//   static const int adoptionReward = 100; // coins
//   static const int playXPReward = 10; // xp
//   static const int dailyRewardCoins = 100;
//   static const int dailyRewardGems = 5;
//   static const int dailyRewardXP = 50;

//   // Configurações de interface
//   static const double borderRadius = 12.0;
//   static const double cardElevation = 4.0;
//   static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);

//   // Configurações de animação
//   static const Curve defaultCurve = Curves.easeInOut;
//   static const Duration defaultTransition = Duration(milliseconds: 200);

//   // Configurações de debug (agora baseadas no AppConfig)
//   static bool get enableDebugLogging => AppConfig.instance.debugMode;
//   static bool get enablePerformanceOverlay => AppConfig.instance.debugMode;
// }

// /// Utilitários globais da aplicação (atualizados)
// class AppUtils {
//   static final Logger _logger = Logger();

//   /// Formata números para exibição amigável
//   static String formatNumber(int number) {
//     if (number >= 1000000) {
//       return '${(number / 1000000).toStringAsFixed(1)}M';
//     } else if (number >= 1000) {
//       return '${(number / 1000).toStringAsFixed(1)}K';
//     }
//     return number.toString();
//   }

//   /// Retorna saudação baseada no horário
//   static String getGreeting() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) return 'Bom dia';
//     if (hour < 18) return 'Boa tarde';
//     return 'Boa noite';
//   }

//   /// Calcula a cor da borda baseada no nível
//   static Color getBorderColorByLevel(int level) {
//     if (level >= 10) return const Color(0xFFFFD700); // Dourado
//     if (level >= 5) return const Color(0xFFC0C0C0); // Prata
//     return const Color(0xFFCD7F32); // Bronze
//   }

//   /// Verifica se uma string é um email válido (usando validação segura)
//   static bool isValidEmail(String email) {
//     final validation = InputValidator.validate(email, ValidationType.email);
//     return validation.isValid;
//   }

//   /// Valida entrada de usuário de forma segura
//   static String? validateUserInput(String input, ValidationType type) {
//     final validation = InputValidator.validate(input, type);
//     return validation.isValid ? null : validation.error;
//   }

//   /// Gera ID único
//   static String generateUniqueId() {
//     return DateTime.now().millisecondsSinceEpoch.toString();
//   }

//   /// Log de debug seguro (sem informações sensíveis)
//   static void debugLog(String message, {Object? data}) {
//     if (AppConstants.enableDebugLogging) {
//       _logger.d('[PetAdote] $message');
//       if (data != null) {
//         _logger.d('Data: $data');
//       }
//     }
//   }

//   /// Log de erro seguro
//   static void errorLog(String message,
//       {Object? error, StackTrace? stackTrace}) {
//     _logger.e('[PetAdote] $message', error: error, stackTrace: stackTrace);
//   }
// }
