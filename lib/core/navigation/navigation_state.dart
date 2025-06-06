// lib/core/navigation/navigation_state.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:petverse/core/navigation/route_names.dart';

/// Estado centralizado da navegação
class NavigationState {
  final String currentRoute;
  final Map<String, dynamic> routeData;
  final List<String> navigationHistory;
  final bool canGoBack;
  final bool isNavigating;
  final String? pendingRoute;

  const NavigationState({
    required this.currentRoute,
    this.routeData = const {},
    this.navigationHistory = const [],
    this.canGoBack = true,
    this.isNavigating = false,
    this.pendingRoute,
  });

  NavigationState copyWith({
    String? currentRoute,
    Map<String, dynamic>? routeData,
    List<String>? navigationHistory,
    bool? canGoBack,
    bool? isNavigating,
    String? pendingRoute,
  }) {
    return NavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      routeData: routeData ?? this.routeData,
      navigationHistory: navigationHistory ?? this.navigationHistory,
      canGoBack: canGoBack ?? this.canGoBack,
      isNavigating: isNavigating ?? this.isNavigating,
      pendingRoute: pendingRoute ?? this.pendingRoute,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationState &&
        other.currentRoute == currentRoute &&
        mapEquals(other.routeData, routeData) &&
        listEquals(other.navigationHistory, navigationHistory) &&
        other.canGoBack == canGoBack &&
        other.isNavigating == isNavigating &&
        other.pendingRoute == pendingRoute;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentRoute,
      routeData,
      navigationHistory,
      canGoBack,
      isNavigating,
      pendingRoute,
    );
  }
}

/// Notifier para gerenciar estado de navegação
class NavigationStateNotifier extends StateNotifier<NavigationState> {
  static final Logger _logger = Logger();

  NavigationStateNotifier()
      : super(const NavigationState(currentRoute: RouteNames.splash));

  /// Atualiza rota atual
  void updateCurrentRoute(String route, {Map<String, dynamic>? data}) {
    final newHistory = List<String>.from(state.navigationHistory);

    // Adiciona à história se não for a mesma rota
    if (route != state.currentRoute) {
      newHistory.add(state.currentRoute);

      // Limita o tamanho da história
      if (newHistory.length > 10) {
        newHistory.removeAt(0);
      }
    }

    state = state.copyWith(
      currentRoute: route,
      routeData: data ?? {},
      navigationHistory: newHistory,
      canGoBack: RouteNames.canGoBack(route) && newHistory.isNotEmpty,
    );

    _logger.d('Navigation updated to: $route');
  }

  /// Marca navegação como em progresso
  void setNavigating(bool isNavigating, {String? pendingRoute}) {
    state = state.copyWith(
      isNavigating: isNavigating,
      pendingRoute: pendingRoute,
    );
  }

  /// Volta para rota anterior
  String? goBack() {
    if (!state.canGoBack || state.navigationHistory.isEmpty) {
      return null;
    }

    final previousRoute = state.navigationHistory.last;
    final newHistory = List<String>.from(state.navigationHistory)..removeLast();

    state = state.copyWith(
      currentRoute: previousRoute,
      navigationHistory: newHistory,
      canGoBack: newHistory.isNotEmpty,
    );

    _logger.d('Navigation back to: $previousRoute');
    return previousRoute;
  }

  /// Limpa histórico de navegação
  void clearHistory() {
    state = state.copyWith(
      navigationHistory: [],
      canGoBack: false,
    );
  }

  /// Verifica se pode navegar para uma rota
  bool canNavigateTo(String route) {
    // Não pode navegar se já está navegando
    if (state.isNavigating) {
      _logger.w('Navigation blocked: already navigating');
      return false;
    }

    // Não pode navegar para a mesma rota
    if (route == state.currentRoute) {
      _logger.d('Navigation blocked: same route');
      return false;
    }

    return true;
  }

  /// Adiciona dados à rota atual
  void updateRouteData(Map<String, dynamic> data) {
    final newData = Map<String, dynamic>.from(state.routeData);
    newData.addAll(data);

    state = state.copyWith(routeData: newData);
  }

  /// Remove dados da rota atual
  void removeRouteData(String key) {
    final newData = Map<String, dynamic>.from(state.routeData);
    newData.remove(key);

    state = state.copyWith(routeData: newData);
  }
}

/// Providers para navegação
final navigationStateProvider =
    StateNotifierProvider<NavigationStateNotifier, NavigationState>((ref) {
  return NavigationStateNotifier();
});

/// Provider para verificar se pode voltar
final canGoBackProvider = Provider<bool>((ref) {
  final navState = ref.watch(navigationStateProvider);
  return navState.canGoBack;
});

/// Provider para rota atual
final currentRouteProvider = Provider<String>((ref) {
  final navState = ref.watch(navigationStateProvider);
  return navState.currentRoute;
});

/// Provider para dados da rota atual
final currentRouteDataProvider = Provider<Map<String, dynamic>>((ref) {
  final navState = ref.watch(navigationStateProvider);
  return navState.routeData;
});

/// Provider para histórico de navegação
final navigationHistoryProvider = Provider<List<String>>((ref) {
  final navState = ref.watch(navigationStateProvider);
  return navState.navigationHistory;
});

/// Provider para status de navegação
final isNavigatingProvider = Provider<bool>((ref) {
  final navState = ref.watch(navigationStateProvider);
  return navState.isNavigating;
});
