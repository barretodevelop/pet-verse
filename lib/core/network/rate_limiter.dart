import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:logger/logger.dart';

/// Resultado de tentativa de requisição
class RequestAttemptResult {
  final bool allowed;
  final Duration? retryAfter;
  final String? reason;

  const RequestAttemptResult({
    required this.allowed,
    this.retryAfter,
    this.reason,
  });

  factory RequestAttemptResult.allowed() {
    return const RequestAttemptResult(allowed: true);
  }

  factory RequestAttemptResult.denied({
    Duration? retryAfter,
    String? reason,
  }) {
    return RequestAttemptResult(
      allowed: false,
      retryAfter: retryAfter,
      reason: reason,
    );
  }
}

/// Configuração do rate limiter
class RateLimiterConfig {
  final int maxRequestsPerMinute;
  final int maxRequestsPerHour;
  final int maxRequestsPerDay;
  final Duration cleanupInterval;
  final bool enabled;

  const RateLimiterConfig({
    this.maxRequestsPerMinute = 60,
    this.maxRequestsPerHour = 1000,
    this.maxRequestsPerDay = 10000,
    this.cleanupInterval = const Duration(minutes: 5),
    this.enabled = true,
  });

  factory RateLimiterConfig.development() {
    return const RateLimiterConfig(
      maxRequestsPerMinute: 120,
      // maxRequestsPerHour = 2000,
      maxRequestsPerDay: 20000,
      enabled: false, // Desabilitado em desenvolvimento
    );
  }

  factory RateLimiterConfig.production() {
    return const RateLimiterConfig(
      maxRequestsPerMinute: 60,
      maxRequestsPerHour: 1000,
      maxRequestsPerDay: 10000,
      enabled: true,
    );
  }
}

/// Rate limiter local thread-safe
class LocalRateLimiter {
  static final Logger _logger = Logger();
  static LocalRateLimiter? _instance;

  final RateLimiterConfig _config;
  final Map<String, Queue<DateTime>> _requestHistory = {};
  final Map<String, DateTime> _blockedUntil = {};
  Timer? _cleanupTimer;

  LocalRateLimiter._(this._config) {
    if (_config.enabled) {
      _startCleanupTimer();
    }
  }

  /// Singleton instance
  static LocalRateLimiter get instance {
    return _instance ??= LocalRateLimiter._(
      RateLimiterConfig.production(),
    );
  }

  /// Inicializa com configuração específica
  static void initialize(RateLimiterConfig config) {
    _instance?._cleanupTimer?.cancel();
    _instance = LocalRateLimiter._(config);
  }

  /// Verifica se uma requisição pode ser feita
  RequestAttemptResult canMakeRequest(String endpoint, {String? userId}) {
    if (!_config.enabled) {
      return RequestAttemptResult.allowed();
    }

    final key = _generateKey(endpoint, userId);
    final now = DateTime.now();

    // Verifica se está bloqueado
    final blockedUntil = _blockedUntil[key];
    if (blockedUntil != null && now.isBefore(blockedUntil)) {
      final retryAfter = blockedUntil.difference(now);
      return RequestAttemptResult.denied(
        retryAfter: retryAfter,
        reason: 'Rate limit exceeded. Retry after ${retryAfter.inSeconds}s',
      );
    }

    // Remove bloco se expirou
    if (blockedUntil != null && now.isAfter(blockedUntil)) {
      _blockedUntil.remove(key);
    }

    // Obtém histórico de requisições
    final history = _requestHistory[key] ??= Queue<DateTime>();

    // Remove requisições antigas
    _removeOldRequests(history, now);

    // Verifica limites
    final minuteCount =
        _countRequestsInPeriod(history, now, const Duration(minutes: 1));
    final hourCount =
        _countRequestsInPeriod(history, now, const Duration(hours: 1));
    final dayCount =
        _countRequestsInPeriod(history, now, const Duration(days: 1));

    // Verifica se excede algum limite
    if (minuteCount >= _config.maxRequestsPerMinute) {
      _blockEndpoint(key, const Duration(minutes: 1));
      return RequestAttemptResult.denied(
        retryAfter: const Duration(minutes: 1),
        reason: 'Rate limit per minute exceeded',
      );
    }

    if (hourCount >= _config.maxRequestsPerHour) {
      _blockEndpoint(key, const Duration(hours: 1));
      return RequestAttemptResult.denied(
        retryAfter: const Duration(hours: 1),
        reason: 'Rate limit per hour exceeded',
      );
    }

    if (dayCount >= _config.maxRequestsPerDay) {
      _blockEndpoint(key, const Duration(days: 1));
      return RequestAttemptResult.denied(
        retryAfter: const Duration(days: 1),
        reason: 'Rate limit per day exceeded',
      );
    }

    return RequestAttemptResult.allowed();
  }

  /// Registra uma requisição feita
  void recordRequest(String endpoint, {String? userId}) {
    if (!_config.enabled) return;

    final key = _generateKey(endpoint, userId);
    final history = _requestHistory[key] ??= Queue<DateTime>();

    history.add(DateTime.now());

    // Limita o tamanho do histórico
    while (history.length > _config.maxRequestsPerDay) {
      history.removeFirst();
    }

    _logger.d('Request recorded for $endpoint (user: $userId)');
  }

  /// Gera chave única para endpoint/usuário
  String _generateKey(String endpoint, String? userId) {
    return userId != null ? '${endpoint}_$userId' : endpoint;
  }

  /// Remove requisições antigas do histórico
  void _removeOldRequests(Queue<DateTime> history, DateTime now) {
    final dayAgo = now.subtract(const Duration(days: 1));

    while (history.isNotEmpty && history.first.isBefore(dayAgo)) {
      history.removeFirst();
    }
  }

  /// Conta requisições em um período específico
  int _countRequestsInPeriod(
      Queue<DateTime> history, DateTime now, Duration period) {
    final cutoff = now.subtract(period);
    return history.where((request) => request.isAfter(cutoff)).length;
  }

  /// Bloqueia um endpoint por um período
  void _blockEndpoint(String key, Duration duration) {
    final blockedUntil = DateTime.now().add(duration);
    _blockedUntil[key] = blockedUntil;

    _logger.w('Endpoint blocked: $key until $blockedUntil');
  }

  /// Inicia timer de limpeza periódica
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(_config.cleanupInterval, (_) {
      _cleanup();
    });
  }

  /// Limpa dados antigos
  void _cleanup() {
    final now = DateTime.now();
    final dayAgo = now.subtract(const Duration(days: 1));

    // Remove históricos antigos
    for (final key in _requestHistory.keys.toList()) {
      final history = _requestHistory[key]!;
      _removeOldRequests(history, now);

      if (history.isEmpty) {
        _requestHistory.remove(key);
      }
    }

    // Remove bloqueios expirados
    for (final key in _blockedUntil.keys.toList()) {
      if (now.isAfter(_blockedUntil[key]!)) {
        _blockedUntil.remove(key);
      }
    }

    _logger.d('Rate limiter cleanup completed');
  }

  /// Obtém estatísticas do rate limiter
  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    final stats = <String, dynamic>{
      'config': {
        'maxRequestsPerMinute': _config.maxRequestsPerMinute,
        'maxRequestsPerHour': _config.maxRequestsPerHour,
        'maxRequestsPerDay': _config.maxRequestsPerDay,
        'enabled': _config.enabled,
      },
      'activeEndpoints': _requestHistory.length,
      'blockedEndpoints': _blockedUntil.length,
      'requestCounts': <String, Map<String, int>>{},
    };

    // Estatísticas por endpoint
    for (final entry in _requestHistory.entries) {
      final key = entry.key;
      final history = entry.value;

      stats['requestCounts'][key] = {
        'lastMinute':
            _countRequestsInPeriod(history, now, const Duration(minutes: 1)),
        'lastHour':
            _countRequestsInPeriod(history, now, const Duration(hours: 1)),
        'lastDay':
            _countRequestsInPeriod(history, now, const Duration(days: 1)),
        'total': history.length,
      };
    }

    return stats;
  }

  /// Reseta o rate limiter
  void reset() {
    _requestHistory.clear();
    _blockedUntil.clear();
    _logger.i('Rate limiter reset');
  }

  /// Desabilita rate limiting temporariamente
  void disable() {
    // Não podemos modificar _config, mas podemos limpar os dados
    reset();
    _logger.w('Rate limiter temporarily disabled');
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _requestHistory.clear();
    _blockedUntil.clear();
  }
}

/// Sistema de retry com backoff exponencial
class RetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final bool enableJitter;
  final List<int> retryableStatusCodes;

  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.enableJitter = true,
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
  });

  factory RetryPolicy.conservative() {
    return const RetryPolicy(
      maxAttempts: 2,
      initialDelay: Duration(seconds: 1),
      maxDelay: Duration(seconds: 10),
      backoffMultiplier: 1.5,
    );
  }

  factory RetryPolicy.aggressive() {
    return const RetryPolicy(
      maxAttempts: 5,
      initialDelay: Duration(milliseconds: 100),
      maxDelay: Duration(minutes: 2),
      backoffMultiplier: 2.5,
    );
  }

  /// Calcula o delay para uma tentativa específica
  Duration calculateDelay(int attempt) {
    if (attempt <= 0) return Duration.zero;

    var delay =
        initialDelay.inMilliseconds * pow(backoffMultiplier, attempt - 1);
    delay = min(delay, maxDelay.inMilliseconds.toDouble());

    if (enableJitter) {
      // Adiciona jitter de ±25%
      final jitter = Random().nextDouble() * 0.5 - 0.25;
      delay = delay * (1 + jitter);
    }

    return Duration(milliseconds: delay.round());
  }

  /// Verifica se deve tentar novamente baseado no status code
  bool shouldRetry(int? statusCode, int attempt) {
    if (attempt >= maxAttempts) return false;
    if (statusCode == null) return true; // Erro de rede
    return retryableStatusCodes.contains(statusCode);
  }
}

/// Executor de requisições com retry e rate limiting
class NetworkRequestExecutor {
  static final Logger _logger = Logger();

  final LocalRateLimiter _rateLimiter;
  final RetryPolicy _retryPolicy;

  NetworkRequestExecutor({
    LocalRateLimiter? rateLimiter,
    RetryPolicy retryPolicy = const RetryPolicy(),
  })  : _rateLimiter = rateLimiter ?? LocalRateLimiter.instance,
        _retryPolicy = retryPolicy;

  /// Executa uma requisição com rate limiting e retry
  Future<T> execute<T>(
    String endpoint,
    Future<T> Function() requestFunction, {
    String? userId,
    RetryPolicy? customRetryPolicy,
  }) async {
    final policy = customRetryPolicy ?? _retryPolicy;
    int attempt = 0;
    Exception? lastException;

    while (attempt < policy.maxAttempts) {
      attempt++;

      // Verifica rate limiting
      final rateLimitResult =
          _rateLimiter.canMakeRequest(endpoint, userId: userId);
      if (!rateLimitResult.allowed) {
        if (rateLimitResult.retryAfter != null) {
          _logger.w(
              'Rate limited for $endpoint. Retry after: ${rateLimitResult.retryAfter}');

          if (attempt < policy.maxAttempts) {
            await Future.delayed(rateLimitResult.retryAfter!);
            continue;
          }
        }

        throw RateLimitException(
          rateLimitResult.reason ?? 'Rate limit exceeded',
          rateLimitResult.retryAfter,
        );
      }

      try {
        // Executa a requisição
        _logger.d('Executing request to $endpoint (attempt $attempt)');
        final result = await requestFunction();

        // Registra a requisição bem-sucedida
        _rateLimiter.recordRequest(endpoint, userId: userId);

        _logger.d('Request to $endpoint completed successfully');
        return result;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        _logger.w('Request to $endpoint failed (attempt $attempt): $e');

        // Verifica se deve tentar novamente
        int? statusCode;
        if (e is NetworkException) {
          statusCode = e.statusCode;
        }

        if (!policy.shouldRetry(statusCode, attempt)) {
          _logger
              .e('Max attempts reached or non-retryable error for $endpoint');
          break;
        }

        // Calcula delay antes da próxima tentativa
        if (attempt < policy.maxAttempts) {
          final delay = policy.calculateDelay(attempt);
          _logger.d('Retrying $endpoint in ${delay.inMilliseconds}ms');
          await Future.delayed(delay);
        }
      }
    }

    throw lastException ??
        Exception('Request failed after ${policy.maxAttempts} attempts');
  }
}

/// Exceções customizadas
class RateLimitException implements Exception {
  final String message;
  final Duration? retryAfter;

  const RateLimitException(this.message, [this.retryAfter]);

  @override
  String toString() => 'RateLimitException: $message';
}

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final Exception? originalException;

  const NetworkException(this.message,
      {this.statusCode, this.originalException});

  @override
  String toString() => 'NetworkException: $message (status: $statusCode)';
}

/// Extensions para facilitar o uso
extension RateLimiterExtensions on LocalRateLimiter {
  /// Wrapper simples para fazer uma requisição
  Future<bool> tryMakeRequest(String endpoint, {String? userId}) async {
    final result = canMakeRequest(endpoint, userId: userId);
    if (result.allowed) {
      recordRequest(endpoint, userId: userId);
      return true;
    }
    return false;
  }
}

/// Factory para criar configurações baseadas no ambiente
class RateLimiterFactory {
  static LocalRateLimiter createForEnvironment(String environment) {
    late RateLimiterConfig config;

    switch (environment.toLowerCase()) {
      case 'development':
        config = RateLimiterConfig.development();
        break;
      case 'production':
        config = RateLimiterConfig.production();
        break;
      default:
        config = const RateLimiterConfig();
    }

    LocalRateLimiter.initialize(config);
    return LocalRateLimiter.instance;
  }
}
