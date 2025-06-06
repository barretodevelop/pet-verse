// lib/core/navigation/navigation_providers.dart - CORRIGIDO
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';
import 'navigation_guards.dart';
import 'navigation_state.dart';

/// Provider para o usuário atual do Firebase (CORRIGIDO)
final firebaseCurrentUserProvider = Provider<User?>((ref) {
  // Implementação será conectada com FirebaseAuthService
  try {
    return FirebaseAuth.instance.currentUser;
  } catch (e) {
    return null;
  }
});

/// Provider principal para o GoRouter (CORRIGIDO)
final goRouterProvider = Provider<GoRouter>((ref) {
  // Cria o AppRouter passando a ref
  final appRouter = AppRouter.create(ref);

  // Adiciona listener para mudanças de estado que podem afetar a navegação
  ref.listen(
    firebaseCurrentUserProvider,
    (previous, next) {
      // Quando o usuário muda, o router já vai redirecionar automaticamente
      // devido ao refresh listener configurado no AppRouter
    },
    fireImmediately: false,
  );

  // Dispose quando não precisar mais
  ref.onDispose(() {
    // AppRouter cleanup se necessário
  });

  return appRouter.router;
});

/// Provider para navegação guards
final navigationGuardsProvider = Provider<NavigationGuards>((ref) {
  return NavigationGuards();
});

/// Provider para verificar permissões de navegação
final canNavigateToProvider = Provider.family<bool, String>((ref, route) {
  final guards = ref.watch(navigationGuardsProvider);
  final currentUser = ref.watch(firebaseCurrentUserProvider);

  final result = guards.canNavigateTo(route, currentUser);
  return result.canNavigate;
});

/// Provider para informações de debug da navegação
final navigationDebugInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final navState = ref.watch(navigationStateProvider);
  final currentUser = ref.watch(firebaseCurrentUserProvider);

  return {
    'currentRoute': navState.currentRoute,
    'canGoBack': navState.canGoBack,
    'isNavigating': navState.isNavigating,
    'historyLength': navState.navigationHistory.length,
    'userAuthenticated': currentUser != null,
    'routeData': navState.routeData,
  };
});
