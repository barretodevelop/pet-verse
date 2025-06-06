import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:petverse/core/security/security_monitor.dart';

import '../config/app_config.dart';
import '../network/rate_limiter.dart';
import '../network/secure_http_client.dart';
import '../validation/input_validator.dart';

// ========================================
// PROVIDERS DE CONFIGURAÇÃO
// ========================================

/// Provider para AppConfig
final appConfigProvider = Provider<AppConfig>((ref) {
  if (!AppConfig.instance.isInitialized) {
    throw Exception('AppConfig must be initialized before use');
  }
  return AppConfig.instance;
});

/// Provider para verificar se estamos em modo debug
final isDebugModeProvider = Provider<bool>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.debugMode;
});

/// Provider para verificar se estamos em produção
final isProductionProvider = Provider<bool>((ref) {
  final config = ref.watch(appConfigProvider);
  return config.isProduction;
});

/// Provider para configurações de API
final apiConfigProvider = Provider<ApiConfig>((ref) {
  final config = ref.watch(appConfigProvider);
  return ApiConfig(
    geminiApiKey: config.geminiApiKey,
    imagenApiKey: config.imagenApiKey,
    openaiApiKey: config.openaiApiKey,
    geminiBaseUrl: config.geminiBaseUrl,
    imagenBaseUrl: config.imagenBaseUrl,
    backendBaseUrl: config.backendBaseUrl,
  );
});

// ========================================
// PROVIDERS DE REDE E SEGURANÇA
// ========================================

/// Provider para SecureHttpClient
final secureHttpClientProvider = Provider<SecureHttpClient>((ref) {
  return SecureHttpClient.instance;
});

/// Provider para LocalRateLimiter
final rateLimiterProvider = Provider<LocalRateLimiter>((ref) {
  return LocalRateLimiter.instance;
});

/// Provider para verificar rate limit status
final rateLimitStatusProvider = StateProvider<RateLimitStatus>((ref) {
  return const RateLimitStatus.normal();
});

/// Provider para estatísticas de rate limiting
final rateLimiterStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final rateLimiter = ref.watch(rateLimiterProvider);
  return rateLimiter.getStats();
});

// ========================================
// PROVIDERS DE VALIDAÇÃO
// ========================================

/// Provider para validação de entrada
final inputValidatorProvider = Provider<InputValidator>((ref) {
  return InputValidator();
});

/// Provider para verificar status de validação
final validationStatusProvider = StateProvider<ValidationStatus>((ref) {
  return const ValidationStatus.idle();
});

/// Provider para cache de validações
final validationCacheProvider =
    StateProvider<Map<String, ValidationResult>>((ref) {
  return {};
});

// ========================================
// PROVIDERS DE MONITORAMENTO
// ========================================

/// Provider para monitoramento de segurança
final securityMonitorProvider =
    StateNotifierProvider<SecurityMonitorNotifier, SecurityMonitorState>((ref) {
  final config = ref.watch(appConfigProvider);
  final httpClient = ref.watch(secureHttpClientProvider);
  final rateLimiter = ref.watch(rateLimiterProvider);

  return SecurityMonitorNotifier(
    config: config,
    httpClient: httpClient,
    rateLimiter: rateLimiter,
  );
});

/// Provider para logs de segurança
final securityLogsProvider = StateProvider<List<SecurityLog>>((ref) {
  return [];
});

/// Provider para alertas de segurança
final securityAlertsProvider = StateProvider<List<SecurityAlert>>((ref) {
  return [];
});

// ========================================
// PROVIDERS DE API SERVICES
// ========================================

/// Provider para Gemini API Service
final geminiApiServiceProvider = Provider<GeminiApiService>((ref) {
  final httpClient = ref.watch(secureHttpClientProvider);
  final config = ref.watch(apiConfigProvider);

  return GeminiApiService(
    httpClient: httpClient,
    apiKey: config.geminiApiKey,
    baseUrl: config.geminiBaseUrl,
  );
});

/// Provider para Imagen API Service
final imagenApiServiceProvider = Provider<ImagenApiService>((ref) {
  final httpClient = ref.watch(secureHttpClientProvider);
  final config = ref.watch(apiConfigProvider);

  return ImagenApiService(
    httpClient: httpClient,
    apiKey: config.imagenApiKey,
    baseUrl: config.imagenBaseUrl,
  );
});

/// Provider para Backend API Service
final backendApiServiceProvider = Provider<BackendApiService>((ref) {
  final httpClient = ref.watch(secureHttpClientProvider);
  final config = ref.watch(apiConfigProvider);

  return BackendApiService(
    httpClient: httpClient,
    baseUrl: config.backendBaseUrl,
  );
});

// ========================================
// MODELS E CLASSES DE APOIO
// ========================================

/// Configuração de APIs
class ApiConfig {
  final String? geminiApiKey;
  final String? imagenApiKey;
  final String? openaiApiKey;
  final String geminiBaseUrl;
  final String imagenBaseUrl;
  final String backendBaseUrl;

  const ApiConfig({
    this.geminiApiKey,
    this.imagenApiKey,
    this.openaiApiKey,
    required this.geminiBaseUrl,
    required this.imagenBaseUrl,
    required this.backendBaseUrl,
  });

  bool get hasGeminiKey => geminiApiKey != null && geminiApiKey!.isNotEmpty;
  bool get hasImagenKey => imagenApiKey != null && imagenApiKey!.isNotEmpty;
  bool get hasOpenaiKey => openaiApiKey != null && openaiApiKey!.isNotEmpty;
  bool get hasAllKeys => hasGeminiKey && hasImagenKey;
}

/// Status do rate limiting
class RateLimitStatus {
  final bool isLimited;
  final String? endpoint;
  final Duration? retryAfter;
  final String? reason;

  const RateLimitStatus({
    required this.isLimited,
    this.endpoint,
    this.retryAfter,
    this.reason,
  });

  const RateLimitStatus.normal() : this(isLimited: false);

  const RateLimitStatus.limited({
    required String endpoint,
    Duration? retryAfter,
    String? reason,
  }) : this(
          isLimited: true,
          endpoint: endpoint,
          retryAfter: retryAfter,
          reason: reason,
        );
}

/// Status de validação
class ValidationStatus {
  final bool isValidating;
  final String? field;
  final String? error;

  const ValidationStatus({
    required this.isValidating,
    this.field,
    this.error,
  });

  const ValidationStatus.idle() : this(isValidating: false);

  const ValidationStatus.validating(String field)
      : this(
          isValidating: true,
          field: field,
        );

  const ValidationStatus.error(String field, String error)
      : this(
          isValidating: false,
          field: field,
          error: error,
        );
}

/// Estado do monitor de segurança
class SecurityMonitorState {
  final bool isMonitoring;
  final DateTime? lastCheck;
  final List<SecurityIssue> issues;
  final int threatLevel; // 0-5, onde 5 é crítico

  const SecurityMonitorState({
    required this.isMonitoring,
    this.lastCheck,
    this.issues = const [],
    this.threatLevel = 0,
  });

  SecurityMonitorState copyWith({
    bool? isMonitoring,
    DateTime? lastCheck,
    List<SecurityIssue>? issues,
    int? threatLevel,
  }) {
    return SecurityMonitorState(
      isMonitoring: isMonitoring ?? this.isMonitoring,
      lastCheck: lastCheck ?? this.lastCheck,
      issues: issues ?? this.issues,
      threatLevel: threatLevel ?? this.threatLevel,
    );
  }
}

/// Monitor de segurança
class SecurityMonitorNotifier extends StateNotifier<SecurityMonitorState> {
  static final Logger _logger = Logger();

  final AppConfig config;
  final SecureHttpClient httpClient;
  final LocalRateLimiter rateLimiter;

  SecurityMonitorNotifier({
    required this.config,
    required this.httpClient,
    required this.rateLimiter,
  }) : super(const SecurityMonitorState(isMonitoring: false)) {
    _startMonitoring();
  }

  void _startMonitoring() {
    if (config.isProduction) {
      state = state.copyWith(isMonitoring: true);
      _performSecurityCheck();
    }
  }

  Future<void> _performSecurityCheck() async {
    try {
      final issues = <SecurityIssue>[];

      // Verifica configurações críticas
      if (!config.hasAllRequiredApiKeys) {
        issues.add(SecurityIssue(
          type: SecurityIssueType.missingApiKeys,
          severity: SecurityEventSeverity.critical,
          message: 'API keys missing',
          description: '',
        ));
      }

      // Verifica rate limiting
      final rateLimiterStats = rateLimiter.getStats();
      final blockedEndpoints = rateLimiterStats['blockedEndpoints'] as int;

      if (blockedEndpoints > 5) {
        issues.add(SecurityIssue(
          type: SecurityIssueType.rateLimitExceeded,
          severity: SecurityEventSeverity.critical,
          message: '$blockedEndpoints endpoints blocked',
          description: '',
        ));
      }

      // Verifica conectividade
      try {
        final isConnected = await httpClient.ping();
        if (!isConnected) {
          issues.add(SecurityIssue(
            type: SecurityIssueType.connectivityIssue,
            severity: SecurityEventSeverity.error,
            message: 'Network connectivity issues detected',
            description: '',
          ));
        }
      } catch (e) {
        _logger.w('Security check network error: $e');
      }

      // Calcula nível de ameaça
      final threatLevel = _calculateThreatLevel(issues);

      state = state.copyWith(
        lastCheck: DateTime.now(),
        issues: issues,
        threatLevel: threatLevel,
      );

      _logger.d('Security check completed. Threat level: $threatLevel');
    } catch (e, stackTrace) {
      _logger.e('Security check failed', error: e, stackTrace: stackTrace);
    }
  }

  int _calculateThreatLevel(List<SecurityIssue> issues) {
    if (issues.isEmpty) return 0;

    int level = 0;
    for (final issue in issues) {
      switch (issue.severity) {
        case SecuritySeverity.low:
          level += 1;
          break;
        case SecuritySeverity.medium:
          level += 2;
          break;
        case SecuritySeverity.high:
          level += 3;
          break;
        case SecuritySeverity.critical:
          level += 5;
          break;
        case SecurityEventSeverity.info:
          // TODO: Handle this case.
          throw UnimplementedError();
        case SecurityEventSeverity.warning:
          // TODO: Handle this case.
          throw UnimplementedError();
        case SecurityEventSeverity.error:
          // TODO: Handle this case.
          throw UnimplementedError();
        case SecurityEventSeverity.critical:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    }

    return (level / 2).ceil().clamp(0, 5);
  }

  void forceSecurityCheck() {
    _performSecurityCheck();
  }

  void stopMonitoring() {
    state = state.copyWith(isMonitoring: false);
  }
}

/// Tipos de problemas de segurança
enum SecurityIssueType {
  missingApiKeys,
  rateLimitExceeded,
  connectivityIssue,
  validationFailure,
  unauthorizedAccess,
  dataIntegrityIssue,
}

/// Severidade de problemas de segurança
enum SecuritySeverity {
  low,
  medium,
  high,
  critical,
}

/// Problema de segurança
class SecurityIssueAlternative {
  final SecurityIssueType type;
  final SecuritySeverity severity;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const SecurityIssueAlternative._({
    required this.type,
    required this.severity,
    required this.message,
    required this.timestamp,
    this.metadata,
  });

  factory SecurityIssueAlternative({
    required SecurityIssueType type,
    required SecuritySeverity severity,
    required String message,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return SecurityIssueAlternative._(
      type: type,
      severity: severity,
      message: message,
      timestamp: timestamp ?? DateTime.now(),
      metadata: metadata,
    );
  }

  factory SecurityIssueAlternative.info(String description) {
    return SecurityIssueAlternative._(
      type: SecurityIssueType.connectivityIssue,
      severity: SecuritySeverity.low,
      message: description,
      timestamp: DateTime.now(),
    );
  }

  factory SecurityIssueAlternative.warning(String description) {
    return SecurityIssueAlternative._(
      type: SecurityIssueType.rateLimitExceeded,
      severity: SecuritySeverity.medium,
      message: description,
      timestamp: DateTime.now(),
    );
  }

  factory SecurityIssueAlternative.error(String description) {
    return SecurityIssueAlternative._(
      type: SecurityIssueType.validationFailure,
      severity: SecuritySeverity.high,
      message: description,
      timestamp: DateTime.now(),
    );
  }

  factory SecurityIssueAlternative.critical(String description) {
    return SecurityIssueAlternative._(
      type: SecurityIssueType.unauthorizedAccess,
      severity: SecuritySeverity.critical,
      message: description,
      timestamp: DateTime.now(),
    );
  }

  SecurityIssueAlternative copyWith({
    SecurityIssueType? type,
    SecuritySeverity? severity,
    String? message,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return SecurityIssueAlternative(
      type: type ?? this.type,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Log de segurança
class SecurityLog {
  final String event;
  final String level; // INFO, WARN, ERROR
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  const SecurityLog({
    required this.event,
    required this.level,
    required this.timestamp,
    this.context,
  });
}

/// Alerta de segurança
class SecurityAlert {
  final String title;
  final String message;
  final SecuritySeverity severity;
  final DateTime timestamp;
  final bool isRead;

  const SecurityAlert({
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isRead = false,
  });

  SecurityAlert copyWith({
    bool? isRead,
  }) {
    return SecurityAlert(
      title: title,
      message: message,
      severity: severity,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

// ========================================
// API SERVICES
// ========================================

/// Serviço para Gemini API
class GeminiApiService {
  final SecureHttpClient _httpClient;
  final String? _apiKey;
  final String _baseUrl;

  GeminiApiService({
    required SecureHttpClient httpClient,
    required String? apiKey,
    required String baseUrl,
  })  : _httpClient = httpClient,
        _apiKey = apiKey,
        _baseUrl = baseUrl;

  Future<Map<String, dynamic>> generatePet({
    required String prompt,
    String? userId,
  }) async {
    if (_apiKey == null) {
      throw const ApiKeyException('Gemini API key not configured');
    }

    // Valida o prompt
    final validation =
        InputValidator.validate(prompt, ValidationType.apiPrompt);
    if (!validation.isValid) {
      throw ValidationException('Invalid prompt: ${validation.error}');
    }

    final response = await _httpClient.geminiRequest<Map<String, dynamic>>(
      '/v1/models/gemini-pro:generateContent',
      data: {
        'contents': [
          {
            'parts': [
              {
                'text': validation.sanitizedValue,
              }
            ],
          }
        ],
        'generationConfig': {
          'temperature': 0.8,
          'maxOutputTokens': 1000,
        },
      },
      userId: userId,
    );

    return response.data ?? {};
  }
}

/// Serviço para Imagen API
class ImagenApiService {
  final SecureHttpClient _httpClient;
  final String? _apiKey;
  final String _baseUrl;

  ImagenApiService({
    required SecureHttpClient httpClient,
    required String? apiKey,
    required String baseUrl,
  })  : _httpClient = httpClient,
        _apiKey = apiKey,
        _baseUrl = baseUrl;

  Future<Map<String, dynamic>> generateImage({
    required String prompt,
    String? userId,
  }) async {
    if (_apiKey == null) {
      throw const ApiKeyException('Imagen API key not configured');
    }

    // Valida o prompt
    final validation =
        InputValidator.validate(prompt, ValidationType.apiPrompt);
    if (!validation.isValid) {
      throw ValidationException('Invalid prompt: ${validation.error}');
    }

    final response = await _httpClient.imagenRequest<Map<String, dynamic>>(
      '/v1/projects/your-project/locations/us-central1/publishers/google/models/imagegeneration:predict',
      data: {
        'instances': [
          {
            'prompt': validation.sanitizedValue,
          }
        ],
        'parameters': {
          'sampleCount': 1,
        },
      },
      userId: userId,
    );

    return response.data ?? {};
  }
}

/// Serviço para Backend próprio
class BackendApiService {
  final SecureHttpClient _httpClient;
  final String _baseUrl;

  BackendApiService({
    required SecureHttpClient httpClient,
    required String baseUrl,
  })  : _httpClient = httpClient,
        _baseUrl = baseUrl;

  Future<Map<String, dynamic>> uploadPetData({
    required Map<String, dynamic> petData,
    String? userId,
  }) async {
    final response = await _httpClient.backendRequest<Map<String, dynamic>>(
      '/api/v1/pets',
      method: 'POST',
      data: petData,
      userId: userId,
    );

    return response.data ?? {};
  }

  Future<List<Map<String, dynamic>>> fetchAdoptionRequests({
    String? userId,
  }) async {
    final response = await _httpClient.backendRequest<List<dynamic>>(
      '/api/v1/adoptions',
      method: 'GET',
      userId: userId,
    );

    return (response.data ?? []).cast<Map<String, dynamic>>();
  }
}

// ========================================
// EXTENSIONS PARA FACILITAR O USO
// ========================================

extension SecurityProviderExtensions on WidgetRef {
  /// Verifica se a configuração está segura
  bool get isSecurelyConfigured {
    final config = read(appConfigProvider);
    return config.isInitialized &&
        (config.isProduction ? config.hasAllRequiredApiKeys : true);
  }

  /// Obtém o cliente HTTP seguro
  SecureHttpClient get secureClient => read(secureHttpClientProvider);

  /// Verifica rate limit para um endpoint
  Future<bool> canMakeRequest(String endpoint, {String? userId}) async {
    final rateLimiter = read(rateLimiterProvider);
    final result = rateLimiter.canMakeRequest(endpoint, userId: userId);

    if (!result.allowed) {
      read(rateLimitStatusProvider.notifier).state = RateLimitStatus.limited(
        endpoint: endpoint,
        retryAfter: result.retryAfter,
        reason: result.reason,
      );
      return false;
    }

    return true;
  }

  /// Valida entrada de forma assíncrona
  Future<ValidationResult> validateInput(
      String input, ValidationType type) async {
    read(validationStatusProvider.notifier).state =
        ValidationStatus.validating(type.name);

    final result = InputValidator.validate(input, type);

    if (result.isValid) {
      read(validationStatusProvider.notifier).state =
          const ValidationStatus.idle();
    } else {
      read(validationStatusProvider.notifier).state = ValidationStatus.error(
        type.name,
        result.error ?? 'Validation failed',
      );
    }

    // Cache do resultado
    final cache = read(validationCacheProvider.notifier);
    final key = '${type.name}_${input.hashCode}';
    cache.state = {...cache.state, key: result};

    return result;
  }

  /// Força verificação de segurança
  void forceSecurityCheck() {
    read(securityMonitorProvider.notifier).forceSecurityCheck();
  }

  /// Adiciona log de segurança
  void addSecurityLog(String event, String level,
      {Map<String, dynamic>? context}) {
    final logs = read(securityLogsProvider.notifier);
    logs.state = [
      ...logs.state,
      SecurityLog(
        event: event,
        level: level,
        timestamp: DateTime.now(),
        context: context,
      ),
    ];

    // Limita o tamanho dos logs
    if (logs.state.length > 100) {
      logs.state = logs.state.skip(logs.state.length - 100).toList();
    }
  }
}
