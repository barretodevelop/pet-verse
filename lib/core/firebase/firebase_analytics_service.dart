// lib/core/firebase/firebase_analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';

/// Eventos de analytics customizados
enum AnalyticsEvent {
  petGenerated('pet_generated'),
  petAdopted('pet_adopted'),
  petFed('pet_fed'),
  petPlayed('pet_played'),
  purchaseCoins('purchase_coins'),
  purchaseGems('purchase_gems'),
  levelUp('level_up'),
  adoptionRequestCreated('adoption_request_created'),
  adoptionRequestJoined('adoption_request_joined'),
  userRegistered('user_registered'),
  userLogin('user_login');

  const AnalyticsEvent(this.name);
  final String name;
}

/// Serviço para Firebase Analytics e Crashlytics
class FirebaseAnalyticsService {
  static final Logger _logger = Logger();
  static FirebaseAnalyticsService? _instance;

  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;
  final bool _analyticsEnabled;
  final bool _crashlyticsEnabled;

  FirebaseAnalyticsService._({
    required FirebaseAnalytics analytics,
    required FirebaseCrashlytics crashlytics,
    required bool analyticsEnabled,
    required bool crashlyticsEnabled,
  })  : _analytics = analytics,
        _crashlytics = crashlytics,
        _analyticsEnabled = analyticsEnabled,
        _crashlyticsEnabled = crashlyticsEnabled;

  /// Singleton instance
  static FirebaseAnalyticsService get instance {
    if (_instance == null) {
      throw Exception('FirebaseAnalyticsService must be initialized first');
    }
    return _instance!;
  }

  /// Inicializa o serviço
  static Future<void> initialize() async {
    if (_instance != null) return;

    try {
      final config = AppConfig.instance;

      final analytics = FirebaseAnalytics.instance;
      final crashlytics = FirebaseCrashlytics.instance;

      _instance = FirebaseAnalyticsService._(
        analytics: analytics,
        crashlytics: crashlytics,
        analyticsEnabled: config.analyticsEnabled,
        crashlyticsEnabled: config.crashReportingEnabled,
      );

      await _instance!._configure();

      _logger.i('FirebaseAnalyticsService initialized');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize FirebaseAnalyticsService',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Configurações iniciais
  Future<void> _configure() async {
    try {
      // Configuração do Analytics
      if (_analyticsEnabled) {
        await _analytics.setAnalyticsCollectionEnabled(true);
        _logger.d('Firebase Analytics enabled');
      } else {
        await _analytics.setAnalyticsCollectionEnabled(false);
        _logger.d('Firebase Analytics disabled');
      }

      // Configuração do Crashlytics
      if (_crashlyticsEnabled) {
        await _crashlytics.setCrashlyticsCollectionEnabled(true);

        // Captura erros não tratados do Flutter
        FlutterError.onError = (errorDetails) {
          _crashlytics.recordFlutterFatalError(errorDetails);
        };

        // Captura erros assíncronos
        PlatformDispatcher.instance.onError = (error, stack) {
          _crashlytics.recordError(error, stack, fatal: true);
          return true;
        };

        _logger.d('Firebase Crashlytics enabled');
      } else {
        await _crashlytics.setCrashlyticsCollectionEnabled(false);
        _logger.d('Firebase Crashlytics disabled');
      }

      // Configurações básicas
      await _analytics.setDefaultEventParameters({
        'app_version': '1.0.0',
        'platform': 'mobile',
        'environment': AppConfig.instance.environment.name,
      });
    } catch (e, stackTrace) {
      _logger.e('Failed to configure analytics',
          error: e, stackTrace: stackTrace);
    }
  }

  // ========================================
  // ANALYTICS METHODS
  // ========================================

  /// Log de evento personalizado
  Future<void> logEvent(
    AnalyticsEvent event, {
    Map<String, Object>? parameters,
  }) async {
    if (!_analyticsEnabled) return;

    try {
      final params = <String, Object>{
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?parameters,
      };

      await _analytics.logEvent(
        name: event.name,
        parameters: params,
      );

      _logger.d('Analytics event logged: ${event.name}');
    } catch (e) {
      _logger.w('Failed to log analytics event: $e');
    }
  }

  /// Log de tela visualizada
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, Object>? parameters,
  }) async {
    if (!_analyticsEnabled) return;

    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
        parameters: parameters,
      );

      _logger.d('Screen view logged: $screenName');
    } catch (e) {
      _logger.w('Failed to log screen view: $e');
    }
  }

  /// Log de login de usuário
  Future<void> logUserLogin({
    required String loginMethod,
    String? userId,
  }) async {
    if (!_analyticsEnabled) return;

    try {
      await logEvent(
        AnalyticsEvent.userLogin,
        parameters: {
          'login_method': loginMethod,
          if (userId != null) 'user_id': userId,
        },
      );

      // Define propriedades do usuário
      if (userId != null) {
        await _analytics.setUserId(id: userId);
        await _analytics.setUserProperty(
          name: 'login_method',
          value: loginMethod,
        );
      }
    } catch (e) {
      _logger.w('Failed to log user login: $e');
    }
  }

  /// Log de registro de usuário
  Future<void> logUserRegistration({
    required String registrationMethod,
    String? userId,
  }) async {
    if (!_analyticsEnabled) return;

    try {
      await logEvent(
        AnalyticsEvent.userRegistered,
        parameters: {
          'method': registrationMethod,
          if (userId != null) 'user_id': userId,
        },
      );
    } catch (e) {
      _logger.w('Failed to log user registration: $e');
    }
  }

  /// Log de geração de pet
  Future<void> logPetGenerated({
    required String petId,
    required String petType,
    String? userId,
    bool isUnique = false,
  }) async {
    if (!_analyticsEnabled) return;

    try {
      await logEvent(
        AnalyticsEvent.petGenerated,
        parameters: {
          'pet_id': petId,
          'pet_type': petType,
          'is_unique': isUnique,
          if (userId != null) 'user_id': userId,
        },
      );
    } catch (e) {
      _logger.w('Failed to log pet generation: $e');
    }
  }

  /// Log de adoção de pet
  Future<void> logPetAdopted({
    required String petId,
    required String petType,
    required String adoptionType, // 'individual', 'joint'
    String? userId,
  }) async {
    if (!_analyticsEnabled) return;

    try {
      await logEvent(
        AnalyticsEvent.petAdopted,
        parameters: {
          'pet_id': petId,
          'pet_type': petType,
          'adoption_type': adoptionType,
          if (userId != null) 'user_id': userId,
        },
      );
    } catch (e) {
      _logger.w('Failed to log pet adoption: $e');
    }
  }

  /// Log de ações com pet
  Future<void> logPetAction({
    required String action, // 'fed', 'played', 'rested'
    required String petId,
    String? userId,
    int? cost,
  }) async {
    if (!_analyticsEnabled) return;

    try {
      final event =
          action == 'fed' ? AnalyticsEvent.petFed : AnalyticsEvent.petPlayed;

      await logEvent(
        event,
        parameters: {
          'pet_id': petId,
          'action': action,
          if (cost != null) 'cost': cost,
          if (userId != null) 'user_id': userId,
        },
      );
    } catch (e) {
      _logger.w('Failed to log pet action: $e');
    }
  }

  /// Log de compra/transação
  Future<void> logPurchase({
    required String itemId,
    required String currency, // 'coins', 'gems', 'real_money'
    required double value,
    String? userId,
  }) async {
    if (!_analyticsEnabled) return;

    try {
      final event = currency == 'coins'
          ? AnalyticsEvent.purchaseCoins
          : AnalyticsEvent.purchaseGems;

      await logEvent(
        event,
        parameters: {
          'item_id': itemId,
          'currency': currency,
          'value': value,
          if (userId != null) 'user_id': userId,
        },
      );
    } catch (e) {
      _logger.w('Failed to log purchase: $e');
    }
  }

  /// Log de level up
  Future<void> logLevelUp({
    required int level,
    String? userId,
    String? character, // pet ou user
  }) async {
    if (!_analyticsEnabled) return;

    try {
      await logEvent(
        AnalyticsEvent.levelUp,
        parameters: {
          'level': level,
          'character': character ?? 'user',
          if (userId != null) 'user_id': userId,
        },
      );
    } catch (e) {
      _logger.w('Failed to log level up: $e');
    }
  }

  /// Log de solicitação de adoção
  Future<void> logAdoptionRequest({
    required String requestId,
    required String action, // 'created', 'joined', 'completed', 'expired'
    String? userId,
    int? petsCount,
  }) async {
    if (!_analyticsEnabled) return;

    try {
      final event = action == 'created'
          ? AnalyticsEvent.adoptionRequestCreated
          : AnalyticsEvent.adoptionRequestJoined;

      await logEvent(
        event,
        parameters: {
          'request_id': requestId,
          'action': action,
          if (petsCount != null) 'pets_count': petsCount,
          if (userId != null) 'user_id': userId,
        },
      );
    } catch (e) {
      _logger.w('Failed to log adoption request: $e');
    }
  }

  /// Define propriedades do usuário
  Future<void> setUserProperties({
    String? userId,
    String? userType,
    int? userLevel,
    String? preferredPetType,
  }) async {
    if (!_analyticsEnabled) return;

    try {
      if (userId != null) {
        await _analytics.setUserId(id: userId);
      }

      final properties = <String, String>{};

      if (userType != null) properties['user_type'] = userType;
      if (userLevel != null) properties['user_level'] = userLevel.toString();
      if (preferredPetType != null)
        properties['preferred_pet_type'] = preferredPetType;

      for (final entry in properties.entries) {
        await _analytics.setUserProperty(
          name: entry.key,
          value: entry.value,
        );
      }

      _logger.d('User properties set');
    } catch (e) {
      _logger.w('Failed to set user properties: $e');
    }
  }

  // ========================================
  // CRASHLYTICS METHODS
  // ========================================

  /// Log de erro não fatal
  Future<void> logError({
    required Object error,
    StackTrace? stackTrace,
    String? reason,
    Map<String, dynamic>? additionalData,
    bool fatal = false,
  }) async {
    if (!_crashlyticsEnabled) {
      // Fallback para log normal se Crashlytics desabilitado
      _logger.e('Error logged: $reason', error: error, stackTrace: stackTrace);
      return;
    }

    try {
      // Adiciona dados customizados
      if (additionalData != null) {
        for (final entry in additionalData.entries) {
          await _crashlytics.setCustomKey(entry.key, entry.value);
        }
      }

      // Registra o erro
      await _crashlytics.recordError(
        error,
        stackTrace,
        fatal: fatal,
        // information: reason != null ? [reason] : null,
        information: [],
      );

      _logger.d('Error logged to Crashlytics: $reason');
    } catch (e) {
      _logger.w('Failed to log error to Crashlytics: $e');
    }
  }

  /// Log de mensagem customizada
  Future<void> logMessage(String message) async {
    if (!_crashlyticsEnabled) return;

    try {
      await _crashlytics.log(message);
      _logger.d('Message logged to Crashlytics: $message');
    } catch (e) {
      _logger.w('Failed to log message: $e');
    }
  }

  /// Define ID do usuário para Crashlytics
  Future<void> setCrashlyticsUserId(String userId) async {
    if (!_crashlyticsEnabled) return;

    try {
      await _crashlytics.setUserIdentifier(userId);
      _logger.d('Crashlytics user ID set: $userId');
    } catch (e) {
      _logger.w('Failed to set Crashlytics user ID: $e');
    }
  }

  /// Define dados customizados para Crashlytics
  Future<void> setCrashlyticsCustomData(Map<String, dynamic> data) async {
    if (!_crashlyticsEnabled) return;

    try {
      for (final entry in data.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }
      _logger.d('Crashlytics custom data set');
    } catch (e) {
      _logger.w('Failed to set Crashlytics custom data: $e');
    }
  }

  /// Simula crash para teste (apenas debug)
  Future<void> testCrash() async {
    if (!_crashlyticsEnabled || AppConfig.instance.isProduction) return;

    try {
      _logger.w('Testing crash (debug only)');
      _crashlytics.crash();
    } catch (e) {
      _logger.w('Test crash failed: $e');
    }
  }

  // ========================================
  // MÉTODOS UTILITÁRIOS
  // ========================================

  /// Obtém informações de configuração
  Map<String, dynamic> getConfigInfo() {
    return {
      'analyticsEnabled': _analyticsEnabled,
      'crashlyticsEnabled': _crashlyticsEnabled,
      'environment': AppConfig.instance.environment.name,
    };
  }

  /// Habilita/desabilita analytics
  Future<void> setAnalyticsEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      _logger.d('Analytics ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      _logger.w('Failed to toggle analytics: $e');
    }
  }

  /// Habilita/desabilita crashlytics
  Future<void> setCrashlyticsEnabled(bool enabled) async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
      _logger.d('Crashlytics ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      _logger.w('Failed to toggle crashlytics: $e');
    }
  }

  /// Observer para Analytics (para uso com Navigator)
  FirebaseAnalyticsObserver get analyticsObserver {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  /// Limpa dados do usuário
  Future<void> clearUserData() async {
    try {
      if (_analyticsEnabled) {
        await _analytics.setUserId(id: null);
        await _analytics.resetAnalyticsData();
      }

      if (_crashlyticsEnabled) {
        await _crashlytics.setUserIdentifier('');
      }

      _logger.d('User data cleared from analytics');
    } catch (e) {
      _logger.w('Failed to clear user data: $e');
    }
  }
}

// ========================================
// EXTENSIONS
// ========================================

extension FirebaseAnalyticsExtensions on FirebaseAnalyticsService {
  /// Log combinado de erro para Analytics e Crashlytics
  Future<void> logCombinedError({
    required Object error,
    StackTrace? stackTrace,
    String? screen,
    String? action,
    Map<String, dynamic>? additionalData,
  }) async {
    // Log para Crashlytics
    await logError(
      error: error,
      stackTrace: stackTrace,
      reason: 'Error on $screen during $action',
      additionalData: additionalData,
    );

    // Log para Analytics se não for muito sensível
    if (screen != null) {
      await logEvent(
        AnalyticsEvent.userLogin, // Usando como placeholder
        parameters: {
          'error_type': error.runtimeType.toString(),
          'screen': screen,
          if (action != null) 'action': action,
        },
      );
    }
  }

  /// Log de performance de tela
  Future<void> logScreenPerformance({
    required String screenName,
    required Duration loadTime,
    String? userId,
  }) async {
    await logEvent(
      AnalyticsEvent.userLogin, // Placeholder
      parameters: {
        'event_type': 'screen_performance',
        'screen_name': screenName,
        'load_time_ms': loadTime.inMilliseconds,
        if (userId != null) 'user_id': userId,
      },
    );
  }
}
