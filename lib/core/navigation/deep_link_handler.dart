// lib/core/navigation/deep_link_handler.dart - CORRIGIDO
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'route_names.dart';

/// Manipulador de deep links (SIMPLIFICADO PARA CORREÇÃO)
class DeepLinkHandler {
  static final Logger _logger = Logger();
  static DeepLinkHandler? _instance;

  DeepLinkHandler._();

  static DeepLinkHandler get instance {
    return _instance ??= DeepLinkHandler._();
  }

  /// Inicializa o handler de deep links
  Future<void> initialize() async {
    try {
      _logger.i('Deep link handler initialized');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize deep link handler',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Gera deep link para uma rota
  String generateDeepLink(String route, {Map<String, String>? parameters}) {
    const baseUrl = 'https://petadote.app';

    String path;
    switch (route) {
      case RouteNames.dashboard:
        path = '/home';
        break;
      default:
        path = route;
    }

    if (parameters != null && parameters.isNotEmpty) {
      final queryString = parameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      return '$baseUrl$path?$queryString';
    }

    return '$baseUrl$path';
  }

  /// Compartilha um deep link
  Future<void> shareDeepLink(String route,
      {Map<String, String>? parameters}) async {
    try {
      final link = generateDeepLink(route, parameters: parameters);

      // Copia para clipboard por simplicidade
      await Clipboard.setData(ClipboardData(text: link));

      _logger.d('Deep link copied to clipboard: $link');
    } catch (e, stackTrace) {
      _logger.e('Failed to share deep link', error: e, stackTrace: stackTrace);
    }
  }
}
