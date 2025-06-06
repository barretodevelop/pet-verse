// lib/core/navigation/navigation_guards.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:petverse/core/navigation/route_names.dart';

import '../config/app_config.dart';

/// Resultado de verificação de guard
class GuardResult {
  final bool canNavigate;
  final String? redirectTo;
  final String? message;

  const GuardResult({
    required this.canNavigate,
    this.redirectTo,
    this.message,
  });

  factory GuardResult.allow() {
    return const GuardResult(canNavigate: true);
  }

  factory GuardResult.deny({String? redirectTo, String? message}) {
    return GuardResult(
      canNavigate: false,
      redirectTo: redirectTo,
      message: message,
    );
  }
}

/// Sistema de guards para controle de navegação
class NavigationGuards {
  static final Logger _logger = Logger();

  /// Verifica se pode navegar para uma rota específica
  GuardResult canNavigateTo(String route, User? currentUser) {
    try {
      // Guard de autenticação
      final authGuard = _checkAuthGuard(route, currentUser);
      if (!authGuard.canNavigate) return authGuard;

      // Guard de permissões
      final permissionGuard = _checkPermissionGuard(route, currentUser);
      if (!permissionGuard.canNavigate) return permissionGuard;

      // Guard de ambiente (algumas rotas apenas em dev)
      final environmentGuard = _checkEnvironmentGuard(route);
      if (!environmentGuard.canNavigate) return environmentGuard;

      // Guard de estado da aplicação
      final appStateGuard = _checkAppStateGuard(route);
      if (!appStateGuard.canNavigate) return appStateGuard;

      return GuardResult.allow();
    } catch (e, stackTrace) {
      _logger.e('Navigation guard error', error: e, stackTrace: stackTrace);
      return GuardResult.deny(
        redirectTo: RouteNames.login,
        message: 'Erro na verificação de acesso',
      );
    }
  }

  /// Guard de autenticação
  GuardResult _checkAuthGuard(String route, User? currentUser) {
    // Rotas que não requerem autenticação
    if (!RouteNames.requiresAuth(route)) {
      return GuardResult.allow();
    }

    // Verifica se o usuário está autenticado
    if (currentUser == null) {
      _logger.d('Auth guard: User not authenticated for $route');
      return GuardResult.deny(
        redirectTo: RouteNames.login,
        message: 'Acesso negado. Faça login para continuar.',
      );
    }

    // Verifica se o email está verificado (se necessário)
    if (_requiresEmailVerification(route) && !currentUser.emailVerified) {
      _logger.d('Auth guard: Email not verified for $route');
      return GuardResult.deny(
        redirectTo: RouteNames.profile,
        message: 'Verifique seu email para acessar esta área.',
      );
    }

    return GuardResult.allow();
  }

  /// Guard de permissões específicas
  GuardResult _checkPermissionGuard(String route, User? currentUser) {
    if (currentUser == null) return GuardResult.allow();

    // Verifica permissões específicas baseadas no tipo de usuário
    final userType = _getUserType(currentUser);

    switch (route) {
      case RouteNames.settings:
        // Qualquer usuário autenticado pode acessar settings
        return GuardResult.allow();

      case RouteNames.petGeneration:
        // Verifica se o usuário pode gerar pets
        if (!_canGeneratePets(currentUser, userType)) {
          return GuardResult.deny(
            redirectTo: RouteNames.store,
            message: 'Você precisa de gems para gerar pets únicos.',
          );
        }
        break;

      default:
        break;
    }

    return GuardResult.allow();
  }

  /// Guard de ambiente (desenvolvimento vs produção)
  GuardResult _checkEnvironmentGuard(String route) {
    final config = AppConfig.instance;

    // Rotas apenas para desenvolvimento
    const devOnlyRoutes = [
      '/debug',
      '/test',
    ];

    if (devOnlyRoutes.contains(route) && config.isProduction) {
      _logger.w('Environment guard: Dev route $route blocked in production');
      return GuardResult.deny(
        redirectTo: RouteNames.dashboard,
        message: 'Recurso não disponível nesta versão.',
      );
    }

    return GuardResult.allow();
  }

  /// Guard de estado da aplicação
  GuardResult _checkAppStateGuard(String route) {
    // Verifica se o Firebase está inicializado para rotas que precisam
    const firebaseRoutes = [
      RouteNames.dashboard,
      RouteNames.petGeneration,
      RouteNames.adoptionRequest,
      RouteNames.profile,
    ];

    if (firebaseRoutes.contains(route)) {
      // Aqui poderia verificar se o Firebase está funcionando
      // Por simplicidade, assumimos que está OK se chegou até aqui
    }

    return GuardResult.allow();
  }

  /// Verifica se a rota requer email verificado
  bool _requiresEmailVerification(String route) {
    const verificationRequiredRoutes = [
      RouteNames.petGeneration,
      RouteNames.adoptionRequest,
    ];

    return verificationRequiredRoutes.contains(route);
  }

  /// Obtém tipo do usuário baseado nas informações do Firebase
  String _getUserType(User user) {
    // Lógica simples baseada no provedor
    if (user.isAnonymous) return 'guest';
    if (user.emailVerified) return 'verified';
    return 'basic';
  }

  /// Verifica se o usuário pode gerar pets
  bool _canGeneratePets(User user, String userType) {
    // Usuários guest não podem gerar pets únicos
    if (userType == 'guest') return false;

    // Outros usuários podem (o custo será verificado na tela)
    return true;
  }
}
