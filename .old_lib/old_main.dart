// // File: lib/main.dart

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:petverse/firebase_options.dart';
// import 'package:petverse/presentation/providers/theme_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'core/config/app_config.dart';
// // Core imports

// import 'core/config/theme_config.dart';
// // Presentation imports
// import 'presentation/providers/dependencies_provider.dart';
// import 'presentation/screens/auth/app_wrapper.dart';

// void main() async {
//   // Ensure Flutter bindings are initialized
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Firebase
//   await _initializeFirebase();

//   // ✅ DEBUG FIREBASE
//   await Firebase.initializeApp();
//   print('🔥 Firebase initialized: ${Firebase.apps.length} apps');

//   // ✅ DEBUG AUTH
//   final auth = FirebaseAuth.instance;
//   print('🔐 Auth instance: ${auth.app.name}');

//   // Initialize dependencies
//   final providerOverrides = await _initializeDependencies();

//   // Configure system UI
//   await _configureSystemUI();

//   // Run the application
//   runApp(
//     ProviderScope(
//       overrides: providerOverrides,
//       observers: [
//         if (kDebugMode) AppProviderObserver(),
//       ],
//       child: const PetGameApp(),
//     ),
//   );
// }

// /// Initialize Firebase with error handling
// Future<void> _initializeFirebase() async {
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );

//     // await AppCheckService.initialize();

//     debugPrint('✅ Firebase initialized successfully');
//   } catch (e) {
//     debugPrint('❌ Firebase initialization failed: $e');
//     // In a production app, you might want to show an error screen
//     // or use offline mode if Firebase fails to initialize
//   }
// }

// /// Initialize async dependencies like SharedPreferences
// Future<List<Override>> _initializeDependencies() async {
//   try {
//     final sharedPreferences = await SharedPreferences.getInstance();
//     debugPrint('✅ SharedPreferences initialized successfully');

//     return [
//       sharedPreferencesProvider.overrideWithValue(sharedPreferences),
//     ];
//   } catch (e) {
//     debugPrint('❌ Failed to initialize dependencies: $e');
//     return [];
//   }
// }

// /// Configure system UI overlay style
// Future<void> _configureSystemUI() async {
//   // Set preferred orientations
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   // Configure system UI overlay style
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//       statusBarBrightness: Brightness.dark,
//       systemNavigationBarColor: Colors.white,
//       systemNavigationBarIconBrightness: Brightness.dark,
//     ),
//   );

//   debugPrint('✅ System UI configured successfully');
// }

// /// Root application widget
// class PetGameApp extends ConsumerWidget {
//   const PetGameApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Watch theme state to rebuild when theme changes
//     final themeState = ref.watch(themeProvider);

//     return MaterialApp(
//       // App configuration
//       title: AppConfig.appName,
//       debugShowCheckedModeBanner: false,

//       // Theme configuration
//       theme: ThemeConfig.lightTheme,
//       darkTheme: ThemeConfig.darkTheme,
//       themeMode: themeState.themeMode,

//       // Route configuration
//       home: const AppWrapper(),

//       // App-wide configuration
//       builder: (context, child) {
//         return MediaQuery(
//           // Ensure text scaling doesn't break the UI
//           data: MediaQuery.of(context).copyWith(
//             textScaler: MediaQuery.of(context).textScaler.clamp(
//                   minScaleFactor: 0.8,
//                   maxScaleFactor: 1.2,
//                 ),
//           ),
//           child: _AppErrorBoundary(child: child),
//         );
//       },

//       // Localization (if needed in the future)
//       // supportedLocales: const [
//       //   Locale('en', 'US'),
//       //   Locale('pt', 'BR'),
//       // ],
//     );
//   }
// }

// /// Error boundary widget to catch and handle app-wide errors
// class _AppErrorBoundary extends StatelessWidget {
//   final Widget? child;

//   const _AppErrorBoundary({this.child});

//   @override
//   Widget build(BuildContext context) {
//     return child ?? const _AppErrorScreen();
//   }
// }

// /// Error screen shown when the app fails to initialize
// class _AppErrorScreen extends StatelessWidget {
//   const _AppErrorScreen();

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: ThemeConfig.primaryGradient,
//           ),
//           child: const Center(
//             child: Padding(
//               padding: EdgeInsets.all(24.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.error_outline,
//                     size: 64,
//                     color: Colors.white,
//                   ),
//                   SizedBox(height: 24),
//                   Text(
//                     'Oops! Something went wrong',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'Please restart the app to continue',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white70,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
