import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/router/app_router.dart';
import 'package:petverse/core/theme/app_theme.dart';
import 'package:petverse/features/settings/providers/theme_provider.dart';

class MeuPetVirtualApp extends ConsumerWidget {
  const MeuPetVirtualApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Meu Pet Virtual',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: currentThemeMode,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
