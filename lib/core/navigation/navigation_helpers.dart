// lib/core/navigation/navigation_helpers.dart - CORRIGIDO
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';
import 'navigation_state.dart';

/// Helpers e extensões para navegação
extension NavigationExtensions on BuildContext {
  /// Navega para uma rota
  void goTo(String route, {Object? extra}) {
    AppRouter.go(route, extra: extra);
  }

  /// Navega usando nome
  void goToNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    AppRouter.goNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Push de uma nova rota
  void pushTo(String route, {Object? extra}) {
    AppRouter.push(route, extra: extra);
  }

  /// Push usando nome
  void pushToNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    AppRouter.pushNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Volta na navegação
  void goBack([Object? result]) {
    if (AppRouter.canPop()) {
      AppRouter.pop(result);
    }
  }

  /// Verifica se pode voltar
  bool get canGoBack => AppRouter.canPop();

  /// Rota atual
  String get currentRoute => AppRouter.currentRoute;
}

/// Extensões para WidgetRef (CORRIGIDA)
extension NavigationRefExtensions on WidgetRef {
  /// Navega com controle de estado
  void navigateTo(String route, {Object? extra}) {
    final navNotifier = read(navigationStateProvider.notifier);

    if (!navNotifier.canNavigateTo(route)) {
      return;
    }

    navNotifier.setNavigating(true, pendingRoute: route);

    try {
      AppRouter.go(route, extra: extra);
      navNotifier.updateCurrentRoute(route,
          data: extra as Map<String, dynamic>?);
    } finally {
      navNotifier.setNavigating(false);
    }
  }

  /// Volta com controle de estado
  void navigateBack() {
    final navNotifier = read(navigationStateProvider.notifier);
    final previousRoute = navNotifier.goBack();

    if (previousRoute != null) {
      AppRouter.go(previousRoute);
    } else if (AppRouter.canPop()) {
      AppRouter.pop();
    }
  }

  /// Atualiza dados da rota atual
  void updateRouteData(Map<String, dynamic> data) {
    read(navigationStateProvider.notifier).updateRouteData(data);
  }

  /// MÉTODO PRINCIPAL: safeNavigateTo (ADICIONADO)
  void safeNavigateTo(String route, {Object? extra}) {
    navigateTo(route, extra: extra);
  }
}

/// Widget para navegação com estado controlado
class ControlledNavigation extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onWillPop;
  final bool preventBack;

  const ControlledNavigation({
    super.key,
    required this.child,
    this.onWillPop,
    this.preventBack = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canGoBack = ref.watch(canGoBackProvider);
    final isNavigating = ref.watch(isNavigatingProvider);

    return WillPopScope(
      onWillPop: () async {
        if (preventBack) return false;

        if (onWillPop != null) {
          onWillPop!();
          return false;
        }

        if (isNavigating) return false;

        if (canGoBack) {
          ref.navigateBack();
          return false;
        }

        return true;
      },
      child: AbsorbPointer(
        absorbing: isNavigating,
        child: child,
      ),
    );
  }
}

/// Widget de loading durante navegação
class NavigationLoadingOverlay extends ConsumerWidget {
  final Widget child;

  const NavigationLoadingOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNavigating = ref.watch(isNavigatingProvider);

    return Stack(
      children: [
        child,
        if (isNavigating)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}

/// Mixin para controle de navegação em telas (CORRIGIDO)
mixin NavigationControlMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  bool _isNavigating = false;

  /// Navega de forma segura
  void safeNavigateTo(String route, {Object? extra}) {
    if (_isNavigating) return;

    setState(() => _isNavigating = true);

    try {
      ref.navigateTo(route, extra: extra);
    } finally {
      // Delay para evitar setState durante build
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() => _isNavigating = false);
        }
      });
    }
  }

  /// Volta de forma segura
  void safeNavigateBack() {
    if (_isNavigating) return;

    setState(() => _isNavigating = true);

    try {
      ref.navigateBack();
    } finally {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() => _isNavigating = false);
        }
      });
    }
  }

  bool get isNavigating => _isNavigating;
}
