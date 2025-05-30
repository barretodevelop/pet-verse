// lib/shared/providers/navigation_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para o estado de navegação atual
final currentRouteProvider = StateProvider<String>((ref) => '/home');

// Provider para controle de navegação
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});

class NavigationState {
  final String currentRoute;
  final Map<String, dynamic> routeData;
  final bool canPop;

  const NavigationState({
    this.currentRoute = '/home',
    this.routeData = const {},
    this.canPop = false,
  });

  NavigationState copyWith({
    String? currentRoute,
    Map<String, dynamic>? routeData,
    bool? canPop,
  }) {
    return NavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      routeData: routeData ?? this.routeData,
      canPop: canPop ?? this.canPop,
    );
  }
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  void updateRoute(String route, {Map<String, dynamic>? data}) {
    state = state.copyWith(
      currentRoute: route,
      routeData: data ?? {},
    );
  }

  void setCanPop(bool canPop) {
    state = state.copyWith(canPop: canPop);
  }
}

// Provider para controle de tabs/bottom navigation
final bottomNavProvider = StateProvider<int>((ref) => 0);

// Provider para histórico de navegação
final navigationHistoryProvider =
    StateNotifierProvider<NavigationHistoryNotifier, List<String>>((ref) {
  return NavigationHistoryNotifier();
});

class NavigationHistoryNotifier extends StateNotifier<List<String>> {
  NavigationHistoryNotifier() : super(['/home']);

  void push(String route) {
    state = [...state, route];
  }

  void pop() {
    if (state.length > 1) {
      state = state.sublist(0, state.length - 1);
    }
  }

  void clear() {
    state = ['/home'];
  }

  String get current => state.last;
  String? get previous => state.length > 1 ? state[state.length - 2] : null;
  bool get canGoBack => state.length > 1;
}
