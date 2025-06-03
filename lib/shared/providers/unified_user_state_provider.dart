// lib/core/providers/unified_user_state_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../shared/models/active_pet.dart';
import '../../shared/models/user_state.dart';
import '../../shared/providers/global_providers.dart';

// Estado unificado do usuário
class UnifiedUserState {
  final bool isAuthenticated;
  final User? user;
  final UserProfile? userProfile;
  final ActivePet? activePet;
  final bool isLoading;

  const UnifiedUserState({
    this.isAuthenticated = false,
    this.user,
    this.userProfile,
    this.activePet,
    this.isLoading = true,
  });

  // Getters úteis
  bool get hasPet => activePet != null;
  bool get hasUserProfile => userProfile != null;
  bool get isReady => !isLoading && isAuthenticated;
  String? get userId => user?.uid;
  String? get displayName => user?.displayName;
  String? get email => user?.email;
  String? get photoURL => user?.photoURL;

  // Estado da adoção
  bool get canCreateRequest => isAuthenticated && !hasPet;
  bool get canAdoptPet => isAuthenticated && !hasPet;
  bool get hasActiveRequest =>
      false; // TODO: implementar verificação de request ativo
  bool get isInTransition =>
      false; // TODO: implementar verificação de transição

  UnifiedUserState copyWith({
    bool? isAuthenticated,
    User? user,
    UserProfile? userProfile,
    ActivePet? activePet,
    bool? isLoading,
  }) {
    return UnifiedUserState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      userProfile: userProfile ?? this.userProfile,
      activePet: activePet ?? this.activePet,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  String toString() {
    return 'UnifiedUserState(auth: $isAuthenticated, pet: $hasPet, loading: $isLoading)';
  }
}

// Provider principal que combina todos os estados
final unifiedUserStateProvider = Provider<UnifiedUserState>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final userProfile = ref.watch(userProvider);
  final activePet = ref.watch(activePetProvider);

  return authState.when(
    data: (user) => UnifiedUserState(
      isAuthenticated: user != null,
      user: user,
      userProfile: userProfile,
      activePet: activePet,
      isLoading: false,
    ),
    loading: () => const UnifiedUserState(isLoading: true),
    error: (_, __) => const UnifiedUserState(isLoading: false),
  );
});

// Providers derivados para facilitar o uso
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(unifiedUserStateProvider).isAuthenticated;
});

final hasPetProvider = Provider<bool>((ref) {
  return ref.watch(unifiedUserStateProvider).hasPet;
});

final canCreateRequestProvider = Provider<bool>((ref) {
  return ref.watch(unifiedUserStateProvider).canCreateRequest;
});

final canAdoptPetProvider = Provider<bool>((ref) {
  return ref.watch(unifiedUserStateProvider).canAdoptPet;
});

final isInTransitionProvider = Provider<bool>((ref) {
  return ref.watch(unifiedUserStateProvider).isInTransition;
});

final currentUserDisplayNameProvider = Provider<String?>((ref) {
  return ref.watch(unifiedUserStateProvider).displayName;
});

// Provider para status de carregamento inicial
final appInitializationProvider = Provider<AppInitializationStatus>((ref) {
  final unifiedState = ref.watch(unifiedUserStateProvider);

  if (unifiedState.isLoading) {
    return AppInitializationStatus.loading;
  }

  if (!unifiedState.isAuthenticated) {
    return AppInitializationStatus.needsLogin;
  }

  if (!unifiedState.hasPet) {
    return AppInitializationStatus.needsPet;
  }

  return AppInitializationStatus.ready;
});

enum AppInitializationStatus {
  loading,
  needsLogin,
  needsPet,
  ready,
}

// Extensão para facilitar verificações
extension AppInitializationStatusExtension on AppInitializationStatus {
  bool get isLoading => this == AppInitializationStatus.loading;
  bool get needsLogin => this == AppInitializationStatus.needsLogin;
  bool get needsPet => this == AppInitializationStatus.needsPet;
  bool get isReady => this == AppInitializationStatus.ready;

  String get routePath {
    switch (this) {
      case AppInitializationStatus.loading:
        return '/';
      case AppInitializationStatus.needsLogin:
        return '/login';
      case AppInitializationStatus.needsPet:
        return '/adoption-choice';
      case AppInitializationStatus.ready:
        return '/main';
    }
  }
}

// Provider para navegação automática baseada no estado
final navigationTargetProvider = Provider<String>((ref) {
  return ref.watch(appInitializationProvider).routePath;
});
