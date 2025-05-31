import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petverse/core/constants/app_constants.dart';
import 'package:petverse/core/router/app_router.dart';
import 'package:petverse/core/services/notification_service.dart';
import 'package:petverse/core/theme/app_theme.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ CORRIGIDO: Configurar orientação
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ✅ CORRIGIDO: Inicializar Firebase
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );

  // ✅ CORRIGIDO: Inicializar NotificationService
  await NotificationService().initialize();

  runApp(
    const ProviderScope(
      child: PetVerseApp(),
    ),
  );
}

class DefaultFirebaseOptions {}

class PetVerseApp extends ConsumerWidget {
  const PetVerseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ CORRIGIDO: Usar GoRouter do provider
    final router = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,

          // ✅ CORRIGIDO: Configuração do router
          routerConfig: router,

          // Theme
          theme: ThemeData(
            useMaterial3: true,
            // colorScheme: AppTheme.lightTheme(),
            textTheme: GoogleFonts.interTextTheme(
              Theme.of(context).textTheme,
            ),
            appBarTheme: AppBarTheme(
              elevation: 0,
              centerTitle: true,
              backgroundColor: Colors.transparent,
              foregroundColor: AppTheme.textPrimary,
              titleTextStyle: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primarySoft,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Builder para interceptar e customizar
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler:
                    const TextScaler.linear(1.0), // Evita zoom automático
              ),
              child: child ?? const SizedBox(),
            );
          },
        );
      },
    );
  }
}
