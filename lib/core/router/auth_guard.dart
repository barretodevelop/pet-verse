// lib/core/router/auth_guard.dart
// NOVO: Sistema inteligente de verificação pós-login
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/features/auth/providers/auth_providers.dart';
import 'package:petverse/shared/providers/global_providers.dart';

/// Serviço responsável por determinar a rota inicial baseada no estado do usuário
class AuthGuard {
  /// Determina a rota inicial após autenticação
  static Future<String> getInitialRoute(User user, WidgetRef ref) async {
    try {
      debugPrint('🔍 Verificando estado inicial para usuário: ${user.uid}');

      // Aguardar carregamento dos dados do usuário
      await ref.read(userProvider.notifier).loadDataAndCheckQuests(user.uid);

      // Aguardar carregamento do pet ativo
      await ref.read(activePetProvider.notifier).loadInitialPet(user.uid);

      // Verificar se tem pet ativo
      final activePet = ref.read(activePetProvider);

      if (activePet != null) {
        debugPrint('✅ Pet ativo encontrado: ${activePet.definition.name}');
        return '/main';
      } else {
        debugPrint('📋 Nenhum pet ativo - direcionando para escolha de adoção');
        return '/adoption-choice';
      }
    } catch (e) {
      debugPrint('❌ Erro na verificação inicial: $e');
      // Em caso de erro, direcionar para seleção de pet como fallback
      return '/select';
    }
  }

  /// Verifica se o usuário pode acessar rotas protegidas
  static Future<bool> canAccessProtectedRoute(
      String route, WidgetRef ref) async {
    final authState = ref.read(authStateChangesProvider);

    return authState.when(
      data: (user) => user != null,
      loading: () => false,
      error: (_, __) => false,
    );
  }

  /// Verifica se o usuário tem pet para acessar a tela principal
  static Future<bool> hasPetForMainScreen(WidgetRef ref) async {
    try {
      final activePet = ref.read(activePetProvider);
      return activePet != null;
    } catch (e) {
      debugPrint('❌ Erro ao verificar pet ativo: $e');
      return false;
    }
  }

  /// Rota de redirecionamento baseada no estado de autenticação
  static String getAuthRedirectRoute(User? user) {
    if (user == null) {
      return '/login';
    }

    // Para usuários autenticados, o splash determinará a rota correta
    return '/';
  }
}

/// Provider para estado de inicialização do app
final appInitializationProvider =
    FutureProvider<AppInitializationState>((ref) async {
  final authState = ref.watch(authStateChangesProvider);

  return authState.when(
    data: (user) async {
      if (user == null) {
        return const AppInitializationState(
          isAuthenticated: false,
          hasActivePet: false,
          initialRoute: '/login',
        );
      }

      try {
        // Carregar dados essenciais
        await ref.read(userProvider.notifier).loadDataAndCheckQuests(user.uid);
        await ref.read(activePetProvider.notifier).loadInitialPet(user.uid);

        final activePet = ref.read(activePetProvider);
        final hasActivePet = activePet != null;

        return AppInitializationState(
          isAuthenticated: true,
          hasActivePet: hasActivePet,
          initialRoute: hasActivePet ? '/main' : '/adoption-choice',
          user: user,
          activePet: activePet,
        );
      } catch (e) {
        debugPrint('❌ Erro na inicialização: $e');
        return AppInitializationState(
          isAuthenticated: true,
          hasActivePet: false,
          initialRoute: '/select',
          user: user,
          error: e.toString(),
        );
      }
    },
    loading: () => const AppInitializationState(
      isAuthenticated: false,
      hasActivePet: false,
      initialRoute: '/',
      isLoading: true,
    ),
    error: (error, _) => AppInitializationState(
      isAuthenticated: false,
      hasActivePet: false,
      initialRoute: '/login',
      error: error.toString(),
    ),
  );
});

/// Estado de inicialização do aplicativo
class AppInitializationState {
  final bool isAuthenticated;
  final bool hasActivePet;
  final String initialRoute;
  final User? user;
  final dynamic activePet;
  final String? error;
  final bool isLoading;

  const AppInitializationState({
    required this.isAuthenticated,
    required this.hasActivePet,
    required this.initialRoute,
    this.user,
    this.activePet,
    this.error,
    this.isLoading = false,
  });

  @override
  String toString() =>
      'AppInitializationState(auth: $isAuthenticated, pet: $hasActivePet, route: $initialRoute)';
}
