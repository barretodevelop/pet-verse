// // ========================================
// // CORREÇÕES CRÍTICAS - FLUXO DE AUTENTICAÇÃO GOOGLE
// // ========================================

// // 1. CONFIGURAÇÃO SEGURA DO FIREBASE
// // lib/core/firebase/firebase_config.dart (CORRIGIDO)

// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
// import 'package:logger/logger.dart';
// import 'package:petverse/core/config/app_config.dart';
// import 'package:petverse/core/firebase/firebase_analytics_service.dart';
// import 'package:petverse/core/network/rate_limiter.dart';
 

// class FirebaseConfig {
//   static final Logger _logger = Logger();
//   static bool _isInitialized = false;

//   static Future<void> initialize() async {
//     if (_isInitialized) {
//       _logger.w('Firebase already initialized');
//       return;
//     }

//     try {
//       _logger.i('Initializing Firebase...');

//       // CORREÇÃO: Usar firebase_options.dart gerado pelo FlutterFire CLI
//       // Em vez de hardcoded values
//       await Firebase.initializeApp(
//         // options: DefaultFirebaseOptions.currentPlatform, // Descomente após gerar
//       );

//       await _configureFirebaseSecurity();

//       _isInitialized = true;
//       _logger.i('Firebase initialized successfully');
//     } catch (e, stackTrace) {
//       _logger.e('Firebase initialization failed', error: e, stackTrace: stackTrace);
//       rethrow;
//     }
//   }

//   // CORREÇÃO: Remover método com valores hardcoded
//   // O _getFirebaseOptions() foi removido - usar DefaultFirebaseOptions

//   static Future<void> _configureFirebaseSecurity() async {
//     final config = AppConfig.instance;

//     if (config.isProduction) {
//       _logger.d('Production Firebase security configured');
//     }

//     if (config.analyticsEnabled) {
//       _logger.d('Firebase Analytics enabled');
//     }

//     if (config.crashReportingEnabled) {
//       _logger.d('Firebase Crashlytics enabled');
//     }
//   }

//   static bool get isInitialized => _isInitialized;

//   static Map<String, dynamic> getConfigInfo() {
//     return {
//       'initialized': _isInitialized,
//       'platform': _getPlatformName(),
//       'hasAnalytics': AppConfig.instance.analyticsEnabled,
//       'hasCrashlytics': AppConfig.instance.crashReportingEnabled,
//     };
//   }

//   static String _getPlatformName() {
//     if (kIsWeb) return 'web';
//     if (Platform.isAndroid) return 'android';
//     if (Platform.isIOS) return 'ios';
//     return 'unknown';
//   }
// }

// // ========================================
// // 2. SERVIÇO DE AUTENTICAÇÃO UNIFICADO
// // lib/core/auth/unified_auth_service.dart (NOVO)

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:logger/logger.dart';
// import 'firebase_auth_service.dart';
// import 'social_auth_service.dart';
// import 'auth_middleware.dart';
// import '../firebase/firestore_service.dart';

// class UnifiedAuthService {
//   static final Logger _logger = Logger();

//   final FirebaseAuthService _firebaseAuth;
//   final SocialAuthService _socialAuth;
//   final FirestoreService _firestore;

//   UnifiedAuthService({
//     required FirebaseAuthService firebaseAuth,
//     required SocialAuthService socialAuth,
//     required FirestoreService firestore,
//   })  : _firebaseAuth = firebaseAuth,
//         _socialAuth = socialAuth,
//         _firestore = firestore;

//   /// Fluxo unificado de autenticação com Google
//   Future<AuthResult> signInWithGoogle() async {
//     try {
//       _logger.d('Starting unified Google Sign-In...');

//       // 1. Usar diretamente o FirebaseAuthService (que já integra com Google Sign-In)
//       final firebaseResult = await _firebaseAuth.signInWithGoogle();
      
//       if (!firebaseResult.success) {
//         return AuthResult.failure(
//           firebaseResult.error ?? 'Falha na autenticação Firebase',
//           authType: AuthType.google,
//         );
//       }

//       final user = firebaseResult.user!;

//       // 2. Sincronizar com Firestore
//       final authUser = AuthUser(
//         id: user.uid,
//         email: user.email,
//         name: user.displayName,
//         avatarUrl: user.photoURL,
//         authType: AuthType.google,
//         createdAt: DateTime.now(),
//         lastLoginAt: DateTime.now(),
//       );

//       final firestoreResult = await _firestore.saveUser(authUser);
//       if (!firestoreResult.success) {
//         _logger.w('Failed to save user to Firestore: ${firestoreResult.error}');
//         // Não falha o login por causa disso
//       }

//       // 3. Criar resultado de sucesso
//       return AuthResult.success(
//         token: firebaseResult.idToken ?? '',
//         userData: authUser.toJson(),
//         authType: AuthType.google,
//       );

//     } catch (e, stackTrace) {
//       _logger.e('Unified Google Sign-In failed', error: e, stackTrace: stackTrace);
//       return AuthResult.failure('Erro interno na autenticação: $e');
//     }
//   }

//   /// Logout unificado
//   Future<void> signOut() async {
//     try {
//       await Future.wait([
//         _firebaseAuth.signOut(),
//         _socialAuth.signOutAll(),
//       ]);
//       _logger.i('Unified sign out completed');
//     } catch (e, stackTrace) {
//       _logger.e('Unified sign out failed', error: e, stackTrace: stackTrace);
//     }
//   }

//   /// Verifica se está autenticado
//   bool get isAuthenticated => _firebaseAuth.currentUser != null;

//   /// Usuário atual
//   User? get currentUser => _firebaseAuth.currentUser;

//   /// Stream de mudanças de autenticação
//   Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges;
// }

// // ========================================
// // 3. PROVIDER UNIFICADO PARA RIVERPOD
// // lib/core/providers/auth_providers.dart (NOVO)

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../auth/unified_auth_service.dart';
// import '../auth/firebase_auth_service.dart';
// import '../auth/social_auth_service.dart';
// import '../firebase/firestore_service.dart';

// /// Provider para UnifiedAuthService
// final unifiedAuthServiceProvider = Provider<UnifiedAuthService>((ref) {
//   return UnifiedAuthService(
//     firebaseAuth: FirebaseAuthService.instance,
//     socialAuth: SocialAuthService.instance,
//     firestore: FirestoreService.instance,
//   );
// });

// /// Provider para estado de autenticação
// final authStateProvider = StreamProvider<User?>((ref) {
//   final authService = ref.watch(unifiedAuthServiceProvider);
//   return authService.authStateChanges;
// });

// /// Provider para usuário atual
// final currentUserProvider = Provider<User?>((ref) {
//   final authService = ref.watch(unifiedAuthServiceProvider);
//   return authService.currentUser;
// });

// /// Provider para verificar se está autenticado
// final isAuthenticatedProvider = Provider<bool>((ref) {
//   final authService = ref.watch(unifiedAuthServiceProvider);
//   return authService.isAuthenticated;
// });

// // ========================================
// // 4. WIDGET DE LOGIN SIMPLIFICADO
// // lib/presentation/widgets/google_sign_in_button.dart (NOVO)

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../core/providers/auth_providers.dart';

// class GoogleSignInButton extends ConsumerStatefulWidget {
//   final VoidCallback? onSuccess;
//   final Function(String)? onError;

//   const GoogleSignInButton({
//     super.key,
//     this.onSuccess,
//     this.onError,
//   });

//   @override
//   ConsumerState<GoogleSignInButton> createState() => _GoogleSignInButtonState();
// }

// class _GoogleSignInButtonState extends ConsumerState<GoogleSignInButton> {
//   bool _isLoading = false;

//   Future<void> _handleGoogleSignIn() async {
//     if (_isLoading) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final authService = ref.read(unifiedAuthServiceProvider);
//       final result = await authService.signInWithGoogle();

//       if (result.success) {
//         widget.onSuccess?.call();
//       } else {
//         widget.onError?.call(result.error ?? 'Erro desconhecido');
//       }
//     } catch (e) {
//       widget.onError?.call('Erro interno: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton.icon(
//       onPressed: _isLoading ? null : _handleGoogleSignIn,
//       icon: _isLoading
//           ? const SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             )
//           : Image.asset(
//               'assets/images/google_logo.png',
//               width: 20,
//               height: 20,
//             ),
//       label: Text(_isLoading ? 'Entrando...' : 'Entrar com Google'),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 2,
//         side: BorderSide(color: Colors.grey[300]!),
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }
// }

// // ========================================
// // 5. CONFIGURAÇÃO CORRETA DO GOOGLE SIGN-IN
// // lib/core/auth/firebase_auth_service.dart (CORREÇÃO)

// // Remover a configuração duplicada do GoogleSignIn em _setupAuthSettings()
// // O GoogleSignIn deve ser configurado apenas uma vez

// class FirebaseAuthService {
//   // ... código existente ...

//   static Future<void> initialize() async {
//     if (_instance != null) return;

//     try {
//       final config = AppConfig.instance;

//       // CORREÇÃO: Configuração simplificada e unificada
//       final googleSignIn = GoogleSignIn(
//         scopes: ['email', 'profile'],
//         // clientId será determinado automaticamente pelo Firebase
//         forceCodeForRefreshToken: true,
//       );

//       _instance = FirebaseAuthService._(
//         auth: FirebaseAuth.instance,
//         googleSignIn: googleSignIn,
//       );

//       await _instance!._setupAuthSettings();
//       _instance!._startAuthStateListener();

//       _logger.i('FirebaseAuthService initialized');
//     } catch (e, stackTrace) {
//       _logger.e('Failed to initialize FirebaseAuthService',
//           error: e, stackTrace: stackTrace);
//       rethrow;
//     }
//   }

//   Future<void> _setupAuthSettings() async {
//     try {
//       await _auth.setSettings(
//         appVerificationDisabledForTesting: !AppConfig.instance.isProduction,
//       );

//       await _auth.setLanguageCode('pt');

//       _logger.d('Firebase Auth settings configured');
//     } catch (e) {
//       _logger.w('Failed to configure auth settings: $e');
//     }
//   }

//   // ... resto do código permanece igual ...
// }

// // ========================================
// // 6. ARQUIVO .ENV CORRIGIDO
// // .env.example (NOVO)

// # Ambiente
// ENVIRONMENT=development
// DEBUG_MODE=true

// # APIs (NÃO INCLUIR VALORES REAIS NO CÓDIGO)
// GEMINI_API_KEY=your_gemini_key_here
// IMAGEN_API_KEY=your_imagen_key_here

// # Firebase (usar firebase_options.dart gerado)
// # Estas chaves não devem estar no .env, mas no firebase_options.dart

// # URLs
// BACKEND_BASE_URL=https://dev-api.petadote.com
// GEMINI_BASE_URL=https://generativelanguage.googleapis.com
// IMAGEN_BASE_URL=https://cloud.google.com/vertex-ai

// # Rate Limiting
// MAX_REQUESTS_PER_MINUTE=120
// MAX_REQUESTS_PER_HOUR=2000

// # Timeouts
// REQUEST_TIMEOUT=30
// CONNECT_TIMEOUT=10
// RECEIVE_TIMEOUT=60

// # Analytics
// ANALYTICS_ENABLED=false
// CRASH_REPORTING_ENABLED=false

// // ========================================
// // 7. MAIN.dart SIMPLIFICADO (CORREÇÃO)

// Future<void> _initializeApp() async {
//   final logger = Logger();
//   logger.i('Starting app initialization...');

//   try {
//     // 1. Configurações do sistema
//     await _configureSystemSettings();

//     // 2. Carrega configurações
//     await AppConfig.initialize();

//     // 3. Inicializa Firebase (CORRIGIDO - ordem importante)
//     await FirebaseConfig.initialize();

//     // 4. Inicializa serviços Firebase
//     await FirebaseAuthService.initialize();
//     await FirebaseAnalyticsService.initialize();

//     // 5. Inicializa outros serviços
//     RateLimiterFactory.createForEnvironment(
//       AppConfig.instance.environment.name,
//     );

//     // REMOVIDO: SocialAuthService.initialize() - já incluído no FirebaseAuthService

//     logger.i('App initialization completed successfully');
//   } catch (e, stackTrace) {
//     logger.e('Failed to initialize app', error: e, stackTrace: stackTrace);
//     rethrow;
//   }
// }

// // ========================================
// // 8. INSTRUÇÕES DE CONFIGURAÇÃO

// /*
// INSTRUÇÕES PARA CONFIGURAÇÃO CORRETA:

// 1. FIREBASE SETUP:
//    - Execute: flutter pub global activate flutterfire_cli
//    - Execute: flutterfire configure
//    - Isso gerará firebase_options.dart automaticamente

// 2. GOOGLE SIGN-IN SETUP:
//    - No Firebase Console, vá em Authentication > Sign-in method
//    - Ative Google como provider
//    - Configure o support email

// 3. ANDROID SETUP:
//    - Obtenha SHA-1: cd android && ./gradlew signingReport
//    - Adicione SHA-1 no Firebase Console (Project Settings)

// 4. iOS SETUP:
//    - Baixe GoogleService-Info.plist do Firebase Console
//    - Adicione em ios/Runner/

// 5. DEPENDENCIES:
//    - firebase_core: ^2.24.2
//    - firebase_auth: ^4.15.3
//    - google_sign_in: ^6.1.6
//    - cloud_firestore: ^4.13.6

// 6. REMOVER:
//    - Valores hardcoded de firebase_config.dart
//    - Configuração duplicada de GoogleSignIn
//    - API keys expostas no código

// 7. TESTAR:
//    - Debug build primeiro
//    - Release build depois
//    - Diferentes dispositivos/emuladores
// */