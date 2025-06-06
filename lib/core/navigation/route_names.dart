// lib/core/navigation/route_names.dart
/// Constantes para nomes e caminhos das rotas
class RouteNames {
  // ========================================
  // ROTAS PRINCIPAIS
  // ========================================
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  // ========================================
  // NAVEGAÇÃO PRINCIPAL
  // ========================================
  static const String store = '/store';
  static const String games = '/games';
  static const String feed = '/feed';

  // ========================================
  // PETS E ADOÇÃO
  // ========================================
  static const String petDetails = '/pet';
  static const String petGeneration = '/generate-pet';
  static const String adoptionRequest = '/adoption';
  static const String myPets = '/my-pets';

  // ========================================
  // USUÁRIO E CONFIGURAÇÕES
  // ========================================
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  // ========================================
  // OUTROS
  // ========================================
  static const String search = '/search';
  static const String help = '/help';
  static const String about = '/about';

  /// Verifica se uma rota requer autenticação
  static bool requiresAuth(String route) {
    return !_publicRoutes.contains(route);
  }

  /// Rotas que não requerem autenticação
  static const List<String> _publicRoutes = [
    splash,
    login,
  ];

  /// Rotas principais da navegação (bottom bar)
  static const List<String> mainNavigationRoutes = [
    dashboard,
    store,
    games,
    feed,
  ];

  /// Rotas que permitem voltar
  static bool canGoBack(String route) {
    return !_noBackRoutes.contains(route);
  }

  /// Rotas que não permitem voltar (ex: splash, login após sucesso)
  static const List<String> _noBackRoutes = [
    splash,
  ];
}
