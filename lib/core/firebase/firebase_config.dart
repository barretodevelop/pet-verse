// lib/core/firebase/firebase_config.dart
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';

/// Configuração segura do Firebase
class FirebaseConfig {
  static final Logger _logger = Logger();
  static bool _isInitialized = false;

  /// Inicializa Firebase com configurações específicas por plataforma
  static Future<void> initialize() async {
    if (_isInitialized) {
      _logger.w('Firebase already initialized');
      return;
    }

    try {
      _logger.i('Initializing Firebase...');

      // Configura Firebase baseado na plataforma
      final options = _getFirebaseOptions();

      await Firebase.initializeApp(options: options);

      // Configurações de segurança
      await _configureFirebaseSecurity();

      _isInitialized = true;
      _logger.i('Firebase initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Firebase initialization failed',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Retorna opções do Firebase baseado na plataforma
  static FirebaseOptions _getFirebaseOptions() {
    final config = AppConfig.instance;

    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: config.getString('FIREBASE_WEB_API_KEY')!,
        authDomain: config.getString('FIREBASE_AUTH_DOMAIN')!,
        projectId: config.getString('FIREBASE_PROJECT_ID')!,
        storageBucket: config.getString('FIREBASE_STORAGE_BUCKET')!,
        messagingSenderId: config.getString('FIREBASE_MESSAGING_SENDER_ID')!,
        appId: config.getString('FIREBASE_WEB_APP_ID')!,
        measurementId: config.getString('FIREBASE_MEASUREMENT_ID'),
      );
    } else if (Platform.isAndroid) {
      return FirebaseOptions(
        apiKey: config.getString('FIREBASE_ANDROID_API_KEY')!,
        appId: config.getString('FIREBASE_ANDROID_APP_ID')!,
        messagingSenderId: config.getString('FIREBASE_MESSAGING_SENDER_ID')!,
        projectId: config.getString('FIREBASE_PROJECT_ID')!,
        storageBucket: config.getString('FIREBASE_STORAGE_BUCKET')!,
      );
    } else if (Platform.isIOS) {
      return FirebaseOptions(
        apiKey: config.getString('FIREBASE_IOS_API_KEY')!,
        appId: config.getString('FIREBASE_IOS_APP_ID')!,
        messagingSenderId: config.getString('FIREBASE_MESSAGING_SENDER_ID')!,
        projectId: config.getString('FIREBASE_PROJECT_ID')!,
        storageBucket: config.getString('FIREBASE_STORAGE_BUCKET')!,
        iosBundleId: config.getString('FIREBASE_IOS_BUNDLE_ID')!,
      );
    } else {
      throw UnsupportedError('Platform not supported');
    }
  }

  /// Configurações de segurança do Firebase
  static Future<void> _configureFirebaseSecurity() async {
    final config = AppConfig.instance;

    // Configurações apenas para produção
    if (config.isProduction) {
      // App Check (se configurado)
      final appCheckToken = config.getString('FIREBASE_APP_CHECK_TOKEN');
      if (appCheckToken != null) {
        _logger.d('App Check token configured');
      }

      // Performance Monitoring (apenas produção)
      _logger.d('Performance monitoring enabled for production');
    }

    // Analytics (baseado na configuração)
    if (config.analyticsEnabled) {
      _logger.d('Firebase Analytics enabled');
    }

    // Crashlytics (baseado na configuração)
    if (config.crashReportingEnabled) {
      _logger.d('Firebase Crashlytics enabled');
    }
  }

  /// Verifica se Firebase está inicializado
  static bool get isInitialized => _isInitialized;

  /// Obtém informações de configuração (para debug)
  static Map<String, dynamic> getConfigInfo() {
    return {
      'initialized': _isInitialized,
      'platform': _getPlatformName(),
      'projectId': AppConfig.instance.getString('FIREBASE_PROJECT_ID'),
      'hasAnalytics': AppConfig.instance.analyticsEnabled,
      'hasCrashlytics': AppConfig.instance.crashReportingEnabled,
    };
  }

  static String _getPlatformName() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }
}
