// lib/shared/providers/app_state_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/providers/user_provider.dart';

// Provider para o estado geral da aplicação
final appStateProvider = Provider<AppState>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return AppState.error;
      if (user.hasPet) return AppState.hasPet;
      return AppState.needsAdoption;
    },
    loading: () => AppState.loading,
    error: (_, __) => AppState.error,
  );
});

// Provider para controle de loading global
final globalLoadingProvider = StateProvider<bool>((ref) => false);

// Provider para mensagens de feedback
final feedbackMessageProvider = StateProvider<String?>((ref) => null);

// Provider para controle de conectividade
final connectivityProvider = StateProvider<bool>((ref) => true);
