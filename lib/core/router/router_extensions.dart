// lib/core/router/router_extensions.dart
// NOVO: Extensões para facilitar navegação no app
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extensões para facilitar a navegação entre telas
extension AppNavigation on BuildContext {
  // Navegação para autenticação
  void goToLogin() => go('/login');
  void goToSplash() => go('/');

  // Navegação para adoção
  void goToAdoptionChoice() => go('/adoption-choice');
  void goToCreateAdoption() => go('/adoption-choice/create');
  void goToAdoptionList() => go('/adoption-choice/list');
  void goToFriendCode() => go('/adoption-choice/friend-code');

  // Navegação para pet
  void goToSelectPet() => go('/select');
  void goToPetCare() => go('/main');

  // Navegação para outras telas
  void goToShop() => go('/shop');
  void goToMinigames() => go('/minigames');
  void goToEvents() => go('/events');

  // Navegação com parâmetros
  void goToPetDetails(String petId) => go('/main/pet/$petId');
  void goToAdoptionDetails(String adoptionId) =>
      go('/adoption-choice/list/$adoptionId');

  // Navegação com confirmação
  Future<bool> goWithConfirmation(
    String route, {
    String title = 'Confirmar navegação',
    String content = 'Tem certeza que deseja sair desta tela?',
  }) async {
    final shouldNavigate = await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (shouldNavigate == true) {
      go(route);
      return true;
    }

    return false;
  }

  // Navegação com animação personalizada
  void goWithCustomTransition(
    String route, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    // Para implementação futura com animações customizadas
    go(route);
  }
}

/// Validações de rota
class RouteValidator {
  /// Verifica se a rota requer autenticação
  static bool requiresAuth(String route) {
    final publicRoutes = ['/', '/login'];
    return !publicRoutes.contains(route);
  }

  /// Verifica se a rota requer pet ativo
  static bool requiresPet(String route) {
    final petRoutes = ['/main'];
    return petRoutes.any((petRoute) => route.startsWith(petRoute));
  }

  /// Verifica se a rota é de adoção
  static bool isAdoptionRoute(String route) {
    return route.startsWith('/adoption-choice') || route.startsWith('/select');
  }
}

/// Estados de navegação
enum NavigationState {
  splash,
  login,
  adoptionChoice,
  petCare,
  shop,
  minigames,
  events,
}

/// Helper para controlar estado de navegação
class NavigationHelper {
  static NavigationState getStateFromRoute(String route) {
    if (route == '/') return NavigationState.splash;
    if (route == '/login') return NavigationState.login;
    if (route.startsWith('/adoption-choice'))
      return NavigationState.adoptionChoice;
    if (route.startsWith('/main')) return NavigationState.petCare;
    if (route.startsWith('/shop')) return NavigationState.shop;
    if (route.startsWith('/minigames')) return NavigationState.minigames;
    if (route.startsWith('/events')) return NavigationState.events;

    return NavigationState.splash; // Default
  }

  static bool canNavigateBack(NavigationState currentState) {
    // Definir regras de quando permitir voltar
    switch (currentState) {
      case NavigationState.splash:
      case NavigationState.login:
        return false;
      default:
        return true;
    }
  }
}
