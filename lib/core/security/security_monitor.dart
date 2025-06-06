import 'dart:async';
// Imports necessários
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:petverse/core/providers/secure_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../network/rate_limiter.dart';
import '../network/secure_http_client.dart';

/// Níveis de severidade para eventos de segurança
enum SecurityEventSeverity {
  info,
  warning,
  error,
  critical,
}

/// Tipos de eventos de segurança
enum SecurityEventType {
  authFailure,
  rateLimitExceeded,
  inputValidationFailed,
  apiKeyMissing,
  networkError,
  configurationError,
  suspiciousActivity,
  dataIntegrityIssue,
}

/// Evento de segurança
class SecurityEvent {
  final String id;
  final SecurityEventType type;
  final SecurityEventSeverity severity;
  final String message;
  final DateTime timestamp;
  final String? userId;
  final String? endpoint;
  final Map<String, dynamic> metadata;
  final String? stackTrace;

  SecurityEvent({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    DateTime? timestamp,
    this.userId,
    this.endpoint,
    this.metadata = const {},
    this.stackTrace,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SecurityEvent.authFailure({
    required String message,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    return SecurityEvent(
      id: _generateEventId(),
      type: SecurityEventType.authFailure,
      severity: SecurityEventSeverity.warning,
      message: message,
      userId: userId,
      metadata: metadata ?? {},
    );
  }

  factory SecurityEvent.rateLimitExceeded({
    required String endpoint,
    String? userId,
    required Duration retryAfter,
  }) {
    return SecurityEvent(
      id: _generateEventId(),
      type: SecurityEventType.rateLimitExceeded,
      severity: SecurityEventSeverity.warning,
      message: 'Rate limit exceeded for $endpoint',
      userId: userId,
      endpoint: endpoint,
      metadata: {'retryAfter': retryAfter.inSeconds},
    );
  }

  factory SecurityEvent.validationFailed({
    required String field,
    required String error,
    String? userId,
  }) {
    return SecurityEvent(
      id: _generateEventId(),
      type: SecurityEventType.inputValidationFailed,
      severity: SecurityEventSeverity.error,
      message: 'Input validation failed for $field: $error',
      userId: userId,
      metadata: {'field': field, 'validationError': error},
    );
  }

  factory SecurityEvent.suspiciousActivity({
    required String activity,
    required String userId,
    Map<String, dynamic>? metadata,
  }) {
    return SecurityEvent(
      id: _generateEventId(),
      type: SecurityEventType.suspiciousActivity,
      severity: SecurityEventSeverity.critical,
      message: 'Suspicious activity detected: $activity',
      userId: userId,
      metadata: metadata ?? {},
    );
  }

  static String _generateEventId() {
    return 'sec_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'severity': severity.name,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'endpoint': endpoint,
      'metadata': metadata,
      'stackTrace': stackTrace,
    };
  }

  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      id: json['id'] as String,
      type: SecurityEventType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => SecurityEventType.suspiciousActivity,
      ),
      severity: SecurityEventSeverity.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => SecurityEventSeverity.info,
      ),
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String?,
      endpoint: json['endpoint'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      stackTrace: json['stackTrace'] as String?,
    );
  }
}

/// Monitor de segurança em tempo real
class SecurityMonitor {
  static final Logger _logger = Logger();
  static SecurityMonitor? _instance;

  final AppConfig _config;
  final SecureHttpClient _httpClient;
  final LocalRateLimiter _rateLimiter;

  final List<SecurityEvent> _events = [];
  final StreamController<SecurityEvent> _eventController =
      StreamController<SecurityEvent>.broadcast();

  Timer? _metricsTimer;
  Timer? _reportTimer;

  bool _isMonitoring = false;
  int _eventCount = 0;

  SecurityMonitor._({
    required AppConfig config,
    required SecureHttpClient httpClient,
    required LocalRateLimiter rateLimiter,
  })  : _config = config,
        _httpClient = httpClient,
        _rateLimiter = rateLimiter;

  /// Singleton instance
  static SecurityMonitor get instance {
    if (_instance == null) {
      throw Exception('SecurityMonitor must be initialized first');
    }
    return _instance!;
  }

  /// Inicializa o monitor de segurança
  static Future<void> initialize({
    required AppConfig config,
    required SecureHttpClient httpClient,
    required LocalRateLimiter rateLimiter,
  }) async {
    _instance = SecurityMonitor._(
      config: config,
      httpClient: httpClient,
      rateLimiter: rateLimiter,
    );

    await _instance!._startMonitoring();
  }

  /// Stream de eventos de segurança
  Stream<SecurityEvent> get eventStream => _eventController.stream;

  /// Lista de eventos recentes
  List<SecurityEvent> get recentEvents => List.unmodifiable(_events);

  /// Estatísticas de segurança
  SecurityMetrics get metrics => _calculateMetrics();

  // ========================================
  // MÉTODOS PÚBLICOS
  // ========================================

  /// Registra um evento de segurança
  void logEvent(SecurityEvent event) {
    _events.add(event);
    _eventCount++;

    // Limita o número de eventos na memória
    if (_events.length > 1000) {
      _events.removeRange(0, _events.length - 1000);
    }

    // Emite evento no stream
    _eventController.add(event);

    // Log baseado na severidade
    switch (event.severity) {
      case SecurityEventSeverity.info:
        _logger.i('Security Event: ${event.message}');
        break;
      case SecurityEventSeverity.warning:
        _logger.w('Security Warning: ${event.message}');
        break;
      case SecurityEventSeverity.error:
        _logger.e('Security Error: ${event.message}');
        break;
      case SecurityEventSeverity.critical:
        _logger.e('CRITICAL Security Event: ${event.message}');
        _handleCriticalEvent(event);
        break;
    }

    // Salva evento se necessário
    if (event.severity.index >= SecurityEventSeverity.error.index) {
      _persistEvent(event);
    }
  }

  /// Conveniência para registrar falha de autenticação
  void logAuthFailure(String message, {String? userId}) {
    logEvent(SecurityEvent.authFailure(
      message: message,
      userId: userId,
    ));
  }

  /// Conveniência para registrar rate limit excedido
  void logRateLimitExceeded(String endpoint,
      {String? userId, Duration? retryAfter}) {
    logEvent(SecurityEvent.rateLimitExceeded(
      endpoint: endpoint,
      userId: userId,
      retryAfter: retryAfter ?? const Duration(minutes: 1),
    ));
  }

  /// Conveniência para registrar falha de validação
  void logValidationFailure(String field, String error, {String? userId}) {
    logEvent(SecurityEvent.validationFailed(
      field: field,
      error: error,
      userId: userId,
    ));
  }

  /// Conveniência para registrar atividade suspeita
  void logSuspiciousActivity(String activity, String userId,
      {Map<String, dynamic>? metadata}) {
    logEvent(SecurityEvent.suspiciousActivity(
      activity: activity,
      userId: userId,
      metadata: metadata,
    ));
  }

  /// Verifica integridade do sistema
  Future<SecurityHealthCheck> performHealthCheck() async {
    final issues = <SecurityIssue>[];

    try {
      // Verifica configuração
      if (!_config.isInitialized) {
        issues.add(SecurityIssue.critical('AppConfig not initialized'));
      }

      if (_config.isProduction && !_config.hasAllRequiredApiKeys) {
        issues.add(SecurityIssue.critical('Missing API keys in production'));
      }

      // Verifica rate limiting
      final rateLimiterStats = _rateLimiter.getStats();
      final blockedEndpoints = rateLimiterStats['blockedEndpoints'] as int;

      if (blockedEndpoints > 10) {
        issues.add(SecurityIssue.warning(
            'High number of blocked endpoints: $blockedEndpoints'));
      }

      // Verifica conectividade
      try {
        final networkTest = await _httpClient.ping();
        if (!networkTest) {
          issues.add(SecurityIssue.error('Network connectivity issues'));
        }
      } catch (e) {
        issues.add(SecurityIssue.error('Network check failed: $e'));
      }

      // Verifica eventos críticos recentes
      final criticalEvents = _events
          .where((e) => e.severity == SecurityEventSeverity.critical)
          .where((e) => DateTime.now().difference(e.timestamp).inHours < 1)
          .length;

      if (criticalEvents > 5) {
        issues.add(SecurityIssue.critical(
            'Multiple critical events in last hour: $criticalEvents'));
      }

      // Verifica uso de memória (simplificado)
      if (_events.length > 800) {
        issues.add(
            SecurityIssue.warning('High memory usage for security events'));
      }

      final severity = _calculateOverallSeverity(issues);

      return SecurityHealthCheck(
        isHealthy: issues.isEmpty,
        overallSeverity: severity,
        issues: issues,
        timestamp: DateTime.now(),
        checkDuration: const Duration(seconds: 1), // placeholder
      );
    } catch (e, stackTrace) {
      _logger.e('Health check failed', error: e, stackTrace: stackTrace);

      return SecurityHealthCheck(
        isHealthy: false,
        overallSeverity: SecurityEventSeverity.error,
        issues: [SecurityIssue.error('Health check failed: $e')],
        timestamp: DateTime.now(),
        checkDuration: const Duration(seconds: 1),
      );
    }
  }

  /// Gera relatório de segurança
  Future<SecurityReport> generateReport({
    Duration? period,
  }) async {
    final reportPeriod = period ?? const Duration(days: 1);
    final cutoff = DateTime.now().subtract(reportPeriod);

    final relevantEvents =
        _events.where((e) => e.timestamp.isAfter(cutoff)).toList();

    final eventsByType = <SecurityEventType, int>{};
    final eventsBySeverity = <SecurityEventSeverity, int>{};
    final userActivity = <String, int>{};

    for (final event in relevantEvents) {
      eventsByType[event.type] = (eventsByType[event.type] ?? 0) + 1;
      eventsBySeverity[event.severity] =
          (eventsBySeverity[event.severity] ?? 0) + 1;

      if (event.userId != null) {
        userActivity[event.userId!] = (userActivity[event.userId!] ?? 0) + 1;
      }
    }

    return SecurityReport(
      period: reportPeriod,
      totalEvents: relevantEvents.length,
      eventsByType: eventsByType,
      eventsBySeverity: eventsBySeverity,
      topUserActivity: userActivity.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
      criticalEvents: relevantEvents
          .where((e) => e.severity == SecurityEventSeverity.critical)
          .toList(),
      generatedAt: DateTime.now(),
    );
  }

  /// Para o monitoramento
  void stop() {
    _isMonitoring = false;
    _metricsTimer?.cancel();
    _reportTimer?.cancel();
    _eventController.close();
  }

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  /// Inicia o monitoramento
  Future<void> _startMonitoring() async {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _logger.i('Security monitoring started');

    // Timer para coletar métricas periodicamente
    _metricsTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _collectMetrics();
    });

    // Timer para relatórios periódicos (apenas em produção)
    if (_config.isProduction) {
      _reportTimer = Timer.periodic(const Duration(hours: 6), (_) {
        _generatePeriodicReport();
      });
    }

    // Carrega eventos persistidos
    await _loadPersistedEvents();
  }

  /// Coleta métricas do sistema
  void _collectMetrics() {
    try {
      final rateLimiterStats = _rateLimiter.getStats();
      final httpStats = _httpClient.getStats();

      logEvent(SecurityEvent(
        id: SecurityEvent._generateEventId(),
        type: SecurityEventType.networkError, // usando como placeholder
        severity: SecurityEventSeverity.info,
        message: 'System metrics collected',
        metadata: {
          'rateLimiterStats': rateLimiterStats,
          'httpStats': httpStats,
          'eventCount': _eventCount,
          'memoryUsage': _events.length,
        },
      ));
    } catch (e) {
      _logger.w('Failed to collect metrics: $e');
    }
  }

  /// Gera relatório periódico
  Future<void> _generatePeriodicReport() async {
    try {
      final report = await generateReport(period: const Duration(hours: 6));

      _logger.i('Periodic security report: ${report.totalEvents} events, '
          '${report.criticalEvents.length} critical');

      // Em produção, enviaria para servidor de monitoramento
      if (_config.isProduction) {
        await _sendReportToServer(report);
      }
    } catch (e) {
      _logger.e('Failed to generate periodic report: $e');
    }
  }

  /// Manipula eventos críticos
  void _handleCriticalEvent(SecurityEvent event) {
    // Em produção, poderia enviar alerta imediato
    if (_config.isProduction) {
      _sendCriticalAlert(event);
    }

    // Pode implementar medidas automáticas como bloqueio temporário
    if (event.type == SecurityEventType.suspiciousActivity &&
        event.userId != null) {
      _handleSuspiciousUser(event.userId!);
    }
  }

  /// Manipula usuário suspeito
  void _handleSuspiciousUser(String userId) {
    _logger.w('Handling suspicious user: $userId');

    // Implementar medidas como:
    // - Rate limiting mais agressivo
    // - Logout forçado
    // - Bloqueio temporário
    // - Notificação para moderadores
  }

  /// Persiste evento importante
  Future<void> _persistEvent(SecurityEvent event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const key = 'security_events';

      final existingEvents = prefs.getStringList(key) ?? [];
      existingEvents.add(jsonEncode(event.toJson()));

      // Limita a 100 eventos persistidos
      if (existingEvents.length > 100) {
        existingEvents.removeRange(0, existingEvents.length - 100);
      }

      await prefs.setStringList(key, existingEvents);
    } catch (e) {
      _logger.w('Failed to persist security event: $e');
    }
  }

  /// Carrega eventos persistidos
  Future<void> _loadPersistedEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventStrings = prefs.getStringList('security_events') ?? [];

      for (final eventString in eventStrings) {
        try {
          final eventJson = jsonDecode(eventString) as Map<String, dynamic>;
          final event = SecurityEvent.fromJson(eventJson);
          _events.add(event);
        } catch (e) {
          _logger.w('Failed to parse persisted event: $e');
        }
      }

      _logger.d('Loaded ${_events.length} persisted security events');
    } catch (e) {
      _logger.w('Failed to load persisted events: $e');
    }
  }

  /// Envia relatório para servidor
  Future<void> _sendReportToServer(SecurityReport report) async {
    try {
      await _httpClient.backendRequest<void>(
        '/api/v1/security/reports',
        method: 'POST',
        data: report.toJson(),
      );
    } catch (e) {
      _logger.w('Failed to send security report to server: $e');
    }
  }

  /// Envia alerta crítico
  Future<void> _sendCriticalAlert(SecurityEvent event) async {
    try {
      await _httpClient.backendRequest<void>(
        '/api/v1/security/alerts',
        method: 'POST',
        data: {
          'event': event.toJson(),
          'priority': 'critical',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      _logger.w('Failed to send critical alert: $e');
    }
  }

  /// Calcula métricas de segurança
  SecurityMetrics _calculateMetrics() {
    final now = DateTime.now();
    final last24h = now.subtract(const Duration(days: 1));
    final lastHour = now.subtract(const Duration(hours: 1));

    final eventsLast24h =
        _events.where((e) => e.timestamp.isAfter(last24h)).length;
    final eventsLastHour =
        _events.where((e) => e.timestamp.isAfter(lastHour)).length;

    final criticalEventsLast24h = _events
        .where((e) => e.timestamp.isAfter(last24h))
        .where((e) => e.severity == SecurityEventSeverity.critical)
        .length;

    return SecurityMetrics(
      totalEvents: _events.length,
      eventsLast24Hours: eventsLast24h,
      eventsLastHour: eventsLastHour,
      criticalEventsLast24Hours: criticalEventsLast24h,
      averageEventsPerHour: eventsLast24h / 24,
      threatLevel: _calculateThreatLevel(),
    );
  }

  /// Calcula nível de ameaça atual
  int _calculateThreatLevel() {
    final lastHour = DateTime.now().subtract(const Duration(hours: 1));
    final recentEvents = _events.where((e) => e.timestamp.isAfter(lastHour));

    int threatScore = 0;

    for (final event in recentEvents) {
      switch (event.severity) {
        case SecurityEventSeverity.info:
          threatScore += 1;
          break;
        case SecurityEventSeverity.warning:
          threatScore += 3;
          break;
        case SecurityEventSeverity.error:
          threatScore += 5;
          break;
        case SecurityEventSeverity.critical:
          threatScore += 10;
          break;
      }
    }

    // Normaliza para escala 0-5
    return (threatScore / 10).ceil().clamp(0, 5);
  }

  /// Calcula severidade geral
  SecurityEventSeverity _calculateOverallSeverity(List<SecurityIssue> issues) {
    if (issues.isEmpty) return SecurityEventSeverity.info;

    final severities = issues.map((i) => i.severity);

    if (severities.contains(SecurityEventSeverity.critical)) {
      return SecurityEventSeverity.critical;
    } else if (severities.contains(SecurityEventSeverity.error)) {
      return SecurityEventSeverity.error;
    } else if (severities.contains(SecurityEventSeverity.warning)) {
      return SecurityEventSeverity.warning;
    } else {
      return SecurityEventSeverity.info;
    }
  }
}

// ========================================
// CLASSES DE APOIO
// ========================================

/// Métricas de segurança
class SecurityMetrics {
  final int totalEvents;
  final int eventsLast24Hours;
  final int eventsLastHour;
  final int criticalEventsLast24Hours;
  final double averageEventsPerHour;
  final int threatLevel; // 0-5

  const SecurityMetrics({
    required this.totalEvents,
    required this.eventsLast24Hours,
    required this.eventsLastHour,
    required this.criticalEventsLast24Hours,
    required this.averageEventsPerHour,
    required this.threatLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalEvents': totalEvents,
      'eventsLast24Hours': eventsLast24Hours,
      'eventsLastHour': eventsLastHour,
      'criticalEventsLast24Hours': criticalEventsLast24Hours,
      'averageEventsPerHour': averageEventsPerHour,
      'threatLevel': threatLevel,
    };
  }
}

/// Issue de segurança
class SecurityIssue {
  final SecurityEventSeverity severity;
  final String description;
  final DateTime timestamp;

  SecurityIssue({
    required this.severity,
    required this.description,
    DateTime? timestamp,
    required String message,
    required SecurityIssueType type,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SecurityIssue.info(String description) {
    return SecurityIssue(
        severity: SecurityEventSeverity.info,
        description: description,
        message: '',
        type: SecurityIssueType.connectivityIssue);
  }

  factory SecurityIssue.warning(String description) {
    return SecurityIssue(
        severity: SecurityEventSeverity.warning,
        description: description,
        message: '',
        type: SecurityIssueType.connectivityIssue);
  }

  factory SecurityIssue.error(String description) {
    return SecurityIssue(
        severity: SecurityEventSeverity.error,
        description: description,
        message: '',
        type: SecurityIssueType.connectivityIssue);
  }

  factory SecurityIssue.critical(String description) {
    return SecurityIssue(
        severity: SecurityEventSeverity.critical,
        description: description,
        message: '',
        type: SecurityIssueType.connectivityIssue);
  }
}

/// Verificação de saúde de segurança
class SecurityHealthCheck {
  final bool isHealthy;
  final SecurityEventSeverity overallSeverity;
  final List<SecurityIssue> issues;
  final DateTime timestamp;
  final Duration checkDuration;

  const SecurityHealthCheck({
    required this.isHealthy,
    required this.overallSeverity,
    required this.issues,
    required this.timestamp,
    required this.checkDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'isHealthy': isHealthy,
      'overallSeverity': overallSeverity.name,
      'issueCount': issues.length,
      'timestamp': timestamp.toIso8601String(),
      'checkDurationMs': checkDuration.inMilliseconds,
    };
  }
}

/// Relatório de segurança
class SecurityReport {
  final Duration period;
  final int totalEvents;
  final Map<SecurityEventType, int> eventsByType;
  final Map<SecurityEventSeverity, int> eventsBySeverity;
  final List<MapEntry<String, int>> topUserActivity;
  final List<SecurityEvent> criticalEvents;
  final DateTime generatedAt;

  const SecurityReport({
    required this.period,
    required this.totalEvents,
    required this.eventsByType,
    required this.eventsBySeverity,
    required this.topUserActivity,
    required this.criticalEvents,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'period': period.inHours,
      'totalEvents': totalEvents,
      'eventsByType': eventsByType.map((k, v) => MapEntry(k.name, v)),
      'eventsBySeverity': eventsBySeverity.map((k, v) => MapEntry(k.name, v)),
      'topUserActivity': Map.fromEntries(topUserActivity),
      'criticalEventCount': criticalEvents.length,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}
