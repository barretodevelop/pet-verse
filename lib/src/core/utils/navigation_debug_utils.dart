// lib/src/core/utils/navigation_debug_utils.dart
// NOVO - Utilitários para debug e monitoramento de navegação

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:petverse/src/features/auth/presentation/providers/user_data_provider.dart';

class NavigationDebugger {
  static void logNavigationState(WidgetRef ref, String context) {
    if (!kDebugMode) return;

    final authState = ref.read(authStateProvider);
    final userStatus = ref.read(userStatusProvider);

    debugPrint('🧭 === NAVIGATION DEBUG: $context ===');
    debugPrint('🧭 Auth Status: ${authState.status}');
    debugPrint('🧭 User Status: $userStatus');
    debugPrint('🧭 Firebase User: ${authState.firebaseUser?.uid ?? "null"}');
    debugPrint('🧭 App User: ${authState.user?.username ?? "null"}');
    debugPrint('🧭 === END DEBUG ===');
  }

  static void logProviderState(String providerName, AsyncValue<dynamic> value) {
    if (!kDebugMode) return;

    debugPrint('📊 [$providerName] Estado: ${value.runtimeType}');

    value.when(
      data: (data) => debugPrint('📊 [$providerName] ✅ Data: $data'),
      loading: () => debugPrint('📊 [$providerName] ⏳ Loading...'),
      error: (error, stack) => debugPrint('📊 [$providerName] ❌ Error: $error'),
    );
  }

  static void logUserPetProviderState(AsyncValue<bool> userHasPetState) {
    logProviderState('userHasPetProvider', userHasPetState);
  }

  static void logAuthProviderState(AuthState authState) {
    if (!kDebugMode) return;

    debugPrint('🔐 [AuthProvider] Status: ${authState.status}');
    debugPrint('🔐 [AuthProvider] User ID: ${authState.user?.id ?? "null"}');
    debugPrint(
        '🔐 [AuthProvider] Username: ${authState.user?.username ?? "null"}');
  }
}

// Provider para monitorar mudanças e fazer debug automático
final navigationDebugProvider = Provider<NavigationDebugger>((ref) {
  // Auto-log quando auth state muda
  ref.listen(authStateProvider, (previous, next) {
    NavigationDebugger.logAuthProviderState(next);
  });

  // Auto-log quando user status muda
  ref.listen(userStatusProvider, (previous, next) {
    debugPrint('👤 [UserStatus] Mudança: $previous → $next');
  });

  return NavigationDebugger();
});

// Enum para facilitar debug de rotas
enum AppScreens {
  splash('Splash'),
  login('Login'),
  home('Home'),
  adoptionInitial('Adoption Initial'),
  pendingAdoptions('Pending Adoptions'),
  settings('Settings');

  const AppScreens(this.displayName);
  final String displayName;
}

extension AppScreensExtension on AppScreens {
  void logEntry() {
    debugPrint('📱 [Screen] Entering: $displayName');
  }

  void logExit() {
    debugPrint('📱 [Screen] Exiting: $displayName');
  }
}
