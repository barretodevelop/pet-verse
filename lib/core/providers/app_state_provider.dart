// lib/core/providers/app_state_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';

// Provider para o estado geral da aplicação
final appStateProvider = Provider<AppState>((ref) {
  final authState = ref.watch(authenticationNotifierProvider);

  // Se está carregando a autenticação
  if (authState.isLoading) {
    return AppState.loading;
  }

  // Se não está autenticado
  if (!authState.isAuthenticated) {
    return AppState.authenticated; // Usuário precisa fazer login
  }

  // Se está autenticado mas não tem userModel
  if (authState.userModel == null) {
    return AppState.loading; // Ainda carregando dados do usuário
  }

  // Se tem userModel, verifica se tem pet
  final user = authState.userModel!;
  if (user.hasPet) {
    return AppState.hasPet;
  } else {
    return AppState.needsAdoption;
  }
});

// Provider para controle de loading global
final globalLoadingProvider = StateProvider<bool>((ref) => false);

// Provider para mensagens de feedback
final feedbackMessageProvider = StateProvider<String?>((ref) => null);

// Provider para controle de conectividade
final connectivityProvider = StateProvider<bool>((ref) => true);

// Provider combinado para estado da UI
final uiStateProvider = Provider<
    ({
      AppState appState,
      bool isLoading,
      bool isAuthenticated,
      String? error,
      String? feedbackMessage,
    })>((ref) {
  final authState = ref.watch(authenticationNotifierProvider);
  final appState = ref.watch(appStateProvider);
  final globalLoading = ref.watch(globalLoadingProvider);
  final feedbackMessage = ref.watch(feedbackMessageProvider);

  return (
    appState: appState,
    isLoading: authState.isLoading || globalLoading,
    isAuthenticated: authState.isAuthenticated,
    error: authState.error,
    feedbackMessage: feedbackMessage,
  );
});

// Provider para verificar se deve mostrar tela de adoção
final shouldShowAdoptionProvider = Provider<bool>((ref) {
  final appState = ref.watch(appStateProvider);
  return appState == AppState.needsAdoption;
});

// Provider para verificar se tem pet
final hasActivePetProvider = Provider<bool>((ref) {
  final appState = ref.watch(appStateProvider);
  return appState == AppState.hasPet;
});

// Provider para ID do pet atual (se existir)
final activePetIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authenticationNotifierProvider);
  return authState.userModel?.currentPetId;
});

// Notifier para controle de loading global
class GlobalLoadingNotifier extends StateNotifier<bool> {
  GlobalLoadingNotifier() : super(false);

  void setLoading(bool loading) {
    state = loading;
  }

  void toggle() {
    state = !state;
  }
}

final globalLoadingNotifierProvider =
    StateNotifierProvider<GlobalLoadingNotifier, bool>((ref) {
  return GlobalLoadingNotifier();
});

// Notifier para mensagens de feedback
class FeedbackNotifier extends StateNotifier<String?> {
  FeedbackNotifier() : super(null);

  void showMessage(String message) {
    state = message;
  }

  void clearMessage() {
    state = null;
  }

  void showSuccess(String message) {
    state = "SUCCESS: $message";
  }

  void showError(String message) {
    state = "ERROR: $message";
  }

  void showInfo(String message) {
    state = "INFO: $message";
  }
}

final feedbackNotifierProvider =
    StateNotifierProvider<FeedbackNotifier, String?>((ref) {
  return FeedbackNotifier();
});

// Provider para verificar se está em modo offline
final isOfflineProvider = StateProvider<bool>((ref) => false);

// Provider combinado para status da rede
final networkStatusProvider = Provider<
    ({
      bool isConnected,
      bool isOffline,
      String status,
    })>((ref) {
  final isConnected = ref.watch(connectivityProvider);
  final isOffline = ref.watch(isOfflineProvider);

  String status;
  if (!isConnected && isOffline) {
    status = "Modo Offline";
  } else if (!isConnected) {
    status = "Sem Conexão";
  } else {
    status = "Conectado";
  }

  return (
    isConnected: isConnected,
    isOffline: isOffline,
    status: status,
  );
});
