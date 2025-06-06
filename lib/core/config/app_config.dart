import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

/// Enum para ambientes de execução
enum AppEnvironment {
  development('development'),
  staging('staging'),
  production('production');

  const AppEnvironment(this.name);
  final String name;

  static AppEnvironment fromString(String env) {
    return AppEnvironment.values.firstWhere(
      (e) => e.name == env.toLowerCase(),
      orElse: () => AppEnvironment.development,
    );
  }
}

/// Gerenciador central de configurações da aplicação
class AppConfig {
  static AppConfig? _instance;
  static final Logger _logger = Logger();

  late final AppEnvironment _environment;
  late final Map<String, String> _config;
  late final bool _isInitialized;

  AppConfig._internal() : _isInitialized = false;

  /// Singleton instance
  static AppConfig get instance {
    _instance ??= AppConfig._internal();
    return _instance!;
  }

  /// Inicializa as configurações carregando o arquivo .env apropriado
  static Future<void> initialize({String? flavor}) async {
    final config = AppConfig.instance;

    try {
      // Determina qual arquivo .env carregar baseado no flavor/ambiente
      String envFile = '.env';

      if (flavor != null) {
        envFile = '.env.$flavor';
      } else if (kDebugMode) {
        envFile = '.env.dev';
      } else {
        envFile = '.env.prod';
      }

      // Tenta carregar o arquivo específico, senão carrega o padrão
      try {
        await dotenv.load(fileName: envFile);
        _logger.i('Configurações carregadas de: $envFile');
      } catch (e) {
        _logger.w('Não foi possível carregar $envFile, tentando .env padrão');
        await dotenv.load(fileName: '.env');
      }

      config._config = Map<String, String>.from(dotenv.env);
      config._environment = AppEnvironment.fromString(
        config._config['ENVIRONMENT'] ?? 'development',
      );

      config._isInitialized = true;
      _logger.i(
          'AppConfig inicializado para ambiente: ${config._environment.name}');

      // Valida configurações críticas
      config._validateCriticalConfig();
    } catch (e, stackTrace) {
      _logger.e('Erro ao inicializar AppConfig',
          error: e, stackTrace: stackTrace);

      // Configurações padrão em caso de erro
      config._config = _getDefaultConfig();
      config._environment = AppEnvironment.development;
      config._isInitialized = true;

      _logger.w('Usando configurações padrão devido ao erro');
    }
  }

  /// Valida se as configurações críticas estão presentes
  void _validateCriticalConfig() {
    final criticalKeys = [
      'GEMINI_API_KEY',
      'IMAGEN_API_KEY',
      'BACKEND_BASE_URL',
    ];

    final missingKeys = <String>[];

    for (final key in criticalKeys) {
      if (_config[key] == null || _config[key]!.isEmpty) {
        missingKeys.add(key);
      }
    }

    if (missingKeys.isNotEmpty && isProduction) {
      throw Exception(
          'Configurações críticas ausentes em produção: ${missingKeys.join(', ')}');
    }

    if (missingKeys.isNotEmpty) {
      _logger.w(
          'Configurações ausentes (não crítico em dev): ${missingKeys.join(', ')}');
    }
  }

  /// Configurações padrão para fallback
  static Map<String, String> _getDefaultConfig() {
    return {
      'ENVIRONMENT': 'development',
      'DEBUG_MODE': 'true',
      'BACKEND_BASE_URL': 'https://dev-api.petadote.com',
      'MAX_REQUESTS_PER_MINUTE': '120',
      'MAX_REQUESTS_PER_HOUR': '2000',
      'REQUEST_TIMEOUT': '30',
      'CONNECT_TIMEOUT': '10',
      'RECEIVE_TIMEOUT': '60',
      'CACHE_MAX_AGE': '1800',
      'CACHE_MAX_SIZE': '50',
      'ANALYTICS_ENABLED': 'false',
      'CRASH_REPORTING_ENABLED': 'false',
    };
  }

  /// Getters para ambiente
  AppEnvironment get environment => _environment;
  bool get isProduction => _environment == AppEnvironment.production;
  bool get isDevelopment => _environment == AppEnvironment.development;
  bool get isStaging => _environment == AppEnvironment.staging;
  bool get isInitialized => _isInitialized;

  /// Getter genérico para configurações
  String? getString(String key, [String? defaultValue]) {
    _ensureInitialized();
    final value = _config[key] ?? defaultValue;

    // Log apenas chaves não sensíveis
    if (!_isSensitiveKey(key)) {
      _logger.d('Config[$key]: $value');
    } else {
      _logger.d('Config[$key]: [REDACTED]');
    }

    return value;
  }

  /// Getter para boolean
  bool getBool(String key, [bool defaultValue = false]) {
    final value = getString(key, defaultValue.toString());
    return value?.toLowerCase() == 'true';
  }

  /// Getter para int
  int getInt(String key, [int defaultValue = 0]) {
    final value = getString(key, defaultValue.toString());
    return int.tryParse(value ?? '') ?? defaultValue;
  }

  /// Getter para double
  double getDouble(String key, [double defaultValue = 0.0]) {
    final value = getString(key, defaultValue.toString());
    return double.tryParse(value ?? '') ?? defaultValue;
  }

  /// Verifica se uma chave é sensível (não deve ser logada)
  bool _isSensitiveKey(String key) {
    final sensitivePatterns = [
      'api_key',
      'secret',
      'token',
      'password',
      'credential',
    ];

    final lowerKey = key.toLowerCase();
    return sensitivePatterns.any((pattern) => lowerKey.contains(pattern));
  }

  /// Garante que as configurações foram inicializadas
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
          'AppConfig não foi inicializado. Chame AppConfig.initialize() antes de usar.');
    }
  }

  // ========================================
  // CONFIGURAÇÕES ESPECÍFICAS DA APLICAÇÃO
  // ========================================

  /// Configurações de API
  String? get geminiApiKey => getString('GEMINI_API_KEY');
  String? get imagenApiKey => getString('IMAGEN_API_KEY');
  String? get openaiApiKey => getString('OPENAI_API_KEY');

  String get geminiBaseUrl => getString(
      'GEMINI_BASE_URL', 'https://generativelanguage.googleapis.com')!;
  String get imagenBaseUrl =>
      getString('IMAGEN_BASE_URL', 'https://cloud.google.com/vertex-ai')!;
  String get backendBaseUrl =>
      getString('BACKEND_BASE_URL', 'https://api.petadote.com')!;

  /// Configurações de rate limiting
  int get maxRequestsPerMinute => getInt('MAX_REQUESTS_PER_MINUTE', 60);
  int get maxRequestsPerHour => getInt('MAX_REQUESTS_PER_HOUR', 1000);

  /// Configurações de timeout
  int get requestTimeoutSeconds => getInt('REQUEST_TIMEOUT', 30);
  int get connectTimeoutSeconds => getInt('CONNECT_TIMEOUT', 10);
  int get receiveTimeoutSeconds => getInt('RECEIVE_TIMEOUT', 60);

  /// Configurações de cache
  int get cacheMaxAge => getInt('CACHE_MAX_AGE', 3600);
  int get cacheMaxSize => getInt('CACHE_MAX_SIZE', 100);

  /// Configurações de analytics
  bool get analyticsEnabled => getBool('ANALYTICS_ENABLED', false);
  bool get crashReportingEnabled => getBool('CRASH_REPORTING_ENABLED', false);
  bool get debugMode => getBool('DEBUG_MODE', kDebugMode);

  /// Headers de API comuns
  Map<String, String> get commonHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'PetAdote/${_getAppVersion()}',
        'X-App-Environment': environment.name,
        if (debugMode) 'X-Debug-Mode': 'true',
      };

  /// Headers específicos para Gemini
  Map<String, String> get geminiHeaders => {
        ...commonHeaders,
        if (geminiApiKey != null) 'Authorization': 'Bearer $geminiApiKey',
      };

  /// Headers específicos para Imagen
  Map<String, String> get imagenHeaders => {
        ...commonHeaders,
        if (imagenApiKey != null) 'Authorization': 'Bearer $imagenApiKey',
      };

  /// Versão da aplicação (placeholder)
  String _getAppVersion() {
    return '1.0.0'; // Em uma implementação real, pegaria do pubspec.yaml
  }

  /// Dump de configurações (para debug - sem informações sensíveis)
  Map<String, dynamic> toDebugMap() {
    final debugConfig = <String, dynamic>{};

    for (final entry in _config.entries) {
      if (_isSensitiveKey(entry.key)) {
        debugConfig[entry.key] = '[REDACTED]';
      } else {
        debugConfig[entry.key] = entry.value;
      }
    }

    return {
      'environment': environment.name,
      'isInitialized': isInitialized,
      'config': debugConfig,
    };
  }

  @override
  String toString() {
    return 'AppConfig(environment: ${environment.name}, initialized: $isInitialized)';
  }
}

/// Extension para facilitar o uso
extension AppConfigExtensions on AppConfig {
  /// Verifica se uma API key está configurada
  bool hasApiKey(String service) {
    switch (service.toLowerCase()) {
      case 'gemini':
        return geminiApiKey != null && geminiApiKey!.isNotEmpty;
      case 'imagen':
        return imagenApiKey != null && imagenApiKey!.isNotEmpty;
      case 'openai':
        return openaiApiKey != null && openaiApiKey!.isNotEmpty;
      default:
        return false;
    }
  }

  /// Valida se todas as APIs necessárias estão configuradas
  bool get hasAllRequiredApiKeys {
    return hasApiKey('gemini') && hasApiKey('imagen');
  }

  /// Configurações para desenvolvimento
  bool get isDev => isDevelopment || debugMode;
}
