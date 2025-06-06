import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';
import '../validation/input_validator.dart';
import 'rate_limiter.dart';

/// Cliente HTTP seguro com validação, rate limiting e retry
class SecureHttpClient {
  static final Logger _logger = Logger();
  static SecureHttpClient? _instance;

  late final Dio _dio;
  late final NetworkRequestExecutor _requestExecutor;
  late final LocalRateLimiter _rateLimiter;

  SecureHttpClient._() {
    _rateLimiter = LocalRateLimiter.instance;
    _requestExecutor = NetworkRequestExecutor(rateLimiter: _rateLimiter);
    _setupDio();
  }

  /// Singleton instance
  static SecureHttpClient get instance {
    return _instance ??= SecureHttpClient._();
  }

  /// Inicializa cliente com configurações específicas
  static void initialize({
    RetryPolicy? retryPolicy,
    LocalRateLimiter? rateLimiter,
  }) {
    _instance = SecureHttpClient._();
    if (retryPolicy != null || rateLimiter != null) {
      _instance!._requestExecutor = NetworkRequestExecutor(
        retryPolicy: retryPolicy ?? const RetryPolicy(),
        rateLimiter: rateLimiter ?? LocalRateLimiter.instance,
      );
    }
  }

  /// Configura o cliente Dio
  void _setupDio() {
    final config = AppConfig.instance;

    _dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: config.connectTimeoutSeconds),
      receiveTimeout: Duration(seconds: config.receiveTimeoutSeconds),
      sendTimeout: Duration(seconds: config.requestTimeoutSeconds),
      headers: config.commonHeaders,
      validateStatus: (status) => status != null && status < 500,
      followRedirects: true,
      maxRedirects: 3,
    ));

    // Interceptors de segurança
    _dio.interceptors.add(_SecurityInterceptor());
    _dio.interceptors.add(_LoggingInterceptor());

    if (config.debugMode) {
      _dio.interceptors.add(_DebugInterceptor());
    }
  }

  // ========================================
  // MÉTODOS PÚBLICOS
  // ========================================

  /// GET seguro com validação
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    String? userId,
    RetryPolicy? retryPolicy,
  }) async {
    // Valida parâmetros de query
    if (queryParameters != null) {
      final validatedParams = await _validateQueryParams(queryParameters);
      queryParameters = validatedParams;
    }

    return _requestExecutor.execute(
      path,
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
      userId: userId,
      customRetryPolicy: retryPolicy,
    );
  }

  /// POST seguro com validação
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    String? userId,
    RetryPolicy? retryPolicy,
  }) async {
    // Valida dados do body
    if (data != null) {
      data = await _validateAndSanitizeBody(data);
    }

    // Valida parâmetros de query
    if (queryParameters != null) {
      final validatedParams = await _validateQueryParams(queryParameters);
      queryParameters = validatedParams;
    }

    return _requestExecutor.execute(
      path,
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
      userId: userId,
      customRetryPolicy: retryPolicy,
    );
  }

  /// PUT seguro com validação
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    String? userId,
    RetryPolicy? retryPolicy,
  }) async {
    if (data != null) {
      data = await _validateAndSanitizeBody(data);
    }

    if (queryParameters != null) {
      final validatedParams = await _validateQueryParams(queryParameters);
      queryParameters = validatedParams;
    }

    return _requestExecutor.execute(
      path,
      () => _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
      userId: userId,
      customRetryPolicy: retryPolicy,
    );
  }

  /// DELETE seguro
  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    String? userId,
    RetryPolicy? retryPolicy,
  }) async {
    if (queryParameters != null) {
      final validatedParams = await _validateQueryParams(queryParameters);
      queryParameters = validatedParams;
    }

    return _requestExecutor.execute(
      path,
      () => _dio.delete<T>(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
      userId: userId,
      customRetryPolicy: retryPolicy,
    );
  }

  // ========================================
  // MÉTODOS ESPECÍFICOS PARA APIs
  // ========================================

  /// Requisição para API Gemini
  Future<Response<T>> geminiRequest<T>(
    String endpoint, {
    dynamic data,
    Map<String, String>? additionalHeaders,
    String? userId,
  }) async {
    final config = AppConfig.instance;

    if (!config.hasApiKey('gemini')) {
      throw const ApiKeyException('Gemini API key not configured');
    }

    final headers = {
      ...config.geminiHeaders,
      if (additionalHeaders != null) ...additionalHeaders,
    };

    final fullUrl = '${config.geminiBaseUrl}$endpoint';

    return data != null
        ? post<T>(fullUrl, data: data, headers: headers, userId: userId)
        : get<T>(fullUrl, headers: headers, userId: userId);
  }

  /// Requisição para API Imagen
  Future<Response<T>> imagenRequest<T>(
    String endpoint, {
    dynamic data,
    Map<String, String>? additionalHeaders,
    String? userId,
  }) async {
    final config = AppConfig.instance;

    if (!config.hasApiKey('imagen')) {
      throw const ApiKeyException('Imagen API key not configured');
    }

    final headers = {
      ...config.imagenHeaders,
      if (additionalHeaders != null) ...additionalHeaders,
    };

    final fullUrl = '${config.imagenBaseUrl}$endpoint';

    return data != null
        ? post<T>(fullUrl, data: data, headers: headers, userId: userId)
        : get<T>(fullUrl, headers: headers, userId: userId);
  }

  /// Requisição para backend próprio
  Future<Response<T>> backendRequest<T>(
    String endpoint, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? additionalHeaders,
    String? userId,
  }) async {
    final config = AppConfig.instance;
    final fullUrl = '${config.backendBaseUrl}$endpoint';

    final headers = {
      ...config.commonHeaders,
      if (additionalHeaders != null) ...additionalHeaders,
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return get<T>(fullUrl,
            queryParameters: queryParameters, headers: headers, userId: userId);
      case 'POST':
        return post<T>(fullUrl,
            data: data,
            queryParameters: queryParameters,
            headers: headers,
            userId: userId);
      case 'PUT':
        return put<T>(fullUrl,
            data: data,
            queryParameters: queryParameters,
            headers: headers,
            userId: userId);
      case 'DELETE':
        return delete<T>(fullUrl,
            queryParameters: queryParameters, headers: headers, userId: userId);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  // ========================================
  // MÉTODOS DE VALIDAÇÃO
  // ========================================

  /// Valida e sanitiza parâmetros de query
  Future<Map<String, dynamic>> _validateQueryParams(
    Map<String, dynamic> params,
  ) async {
    final validated = <String, dynamic>{};

    for (final entry in params.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value == null) continue;

      // Valida a chave
      final keyValidation = InputValidator.validate(
        key,
        ValidationType.generic,
        maxLength: 50,
      );

      if (!keyValidation.isValid) {
        _logger.w('Invalid query parameter key: $key');
        continue;
      }

      // Valida o valor
      String valueStr = value.toString();
      final valueValidation = InputValidator.validate(
        valueStr,
        ValidationType.generic,
        maxLength: 1000,
      );

      if (!valueValidation.isValid) {
        _logger.w('Invalid query parameter value for $key');
        continue;
      }

      validated[keyValidation.sanitizedValue] = valueValidation.sanitizedValue;
    }

    return validated;
  }

  /// Valida e sanitiza corpo da requisição
  Future<dynamic> _validateAndSanitizeBody(dynamic data) async {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      return _validateMapData(data);
    } else if (data is List) {
      return _validateListData(data);
    } else if (data is String) {
      final validation = InputValidator.validate(
        data,
        ValidationType.apiPrompt,
      );

      if (!validation.isValid) {
        throw ValidationException('Invalid request body: ${validation.error}');
      }

      return validation.sanitizedValue;
    }

    return data;
  }

  /// Valida dados em formato Map
  Future<Map<String, dynamic>> _validateMapData(
      Map<String, dynamic> data) async {
    final validated = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      // Valida chave
      final keyValidation = InputValidator.validate(
        key,
        ValidationType.generic,
        maxLength: 100,
      );

      if (!keyValidation.isValid) {
        _logger.w('Skipping invalid key in request body: $key');
        continue;
      }

      // Valida valor recursivamente
      if (value is Map<String, dynamic>) {
        validated[keyValidation.sanitizedValue] = await _validateMapData(value);
      } else if (value is List) {
        validated[keyValidation.sanitizedValue] =
            await _validateListData(value);
      } else if (value is String) {
        final valueValidation = _determineValidationTypeForField(key, value);
        if (valueValidation.isValid) {
          validated[keyValidation.sanitizedValue] =
              valueValidation.sanitizedValue;
        }
      } else {
        validated[keyValidation.sanitizedValue] = value;
      }
    }

    return validated;
  }

  /// Valida dados em formato List
  Future<List<dynamic>> _validateListData(List<dynamic> data) async {
    final validated = <dynamic>[];

    for (final item in data) {
      if (item is Map<String, dynamic>) {
        validated.add(await _validateMapData(item));
      } else if (item is List) {
        validated.add(await _validateListData(item));
      } else if (item is String) {
        final validation = InputValidator.validate(
          item,
          ValidationType.generic,
          maxLength: 1000,
        );

        if (validation.isValid) {
          validated.add(validation.sanitizedValue);
        }
      } else {
        validated.add(item);
      }
    }

    return validated;
  }

  /// Determina tipo de validação baseado no campo
  ValidationResult _determineValidationTypeForField(
      String fieldName, String value) {
    final lowerField = fieldName.toLowerCase();

    if (lowerField.contains('name')) {
      return InputValidator.validate(value, ValidationType.petName);
    } else if (lowerField.contains('description') ||
        lowerField.contains('prompt')) {
      return InputValidator.validate(value, ValidationType.petDescription);
    } else if (lowerField.contains('email')) {
      return InputValidator.validate(value, ValidationType.email);
    } else if (lowerField.contains('url') || lowerField.contains('link')) {
      return InputValidator.validate(value, ValidationType.url);
    } else {
      return InputValidator.validate(value, ValidationType.userInput);
    }
  }

  // ========================================
  // UTILITÁRIOS
  // ========================================

  /// Obtém estatísticas do cliente
  Map<String, dynamic> getStats() {
    return {
      'rateLimiter': _rateLimiter.getStats(),
      'baseUrl': _dio.options.baseUrl,
      'timeouts': {
        'connect': _dio.options.connectTimeout?.inSeconds,
        'receive': _dio.options.receiveTimeout?.inSeconds,
        'send': _dio.options.sendTimeout?.inSeconds,
      },
    };
  }

  /// Dispose do cliente
  void dispose() {
    _dio.close();
    _rateLimiter.dispose();
  }
}

// ========================================
// INTERCEPTORS
// ========================================

/// Interceptor de segurança
class _SecurityInterceptor extends Interceptor {
  static final Logger _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Remove headers sensíveis em logs
    final sanitizedHeaders = Map<String, dynamic>.from(options.headers);
    for (final key in sanitizedHeaders.keys.toList()) {
      if (key.toLowerCase().contains('authorization') ||
          key.toLowerCase().contains('api-key') ||
          key.toLowerCase().contains('token')) {
        sanitizedHeaders[key] = '[REDACTED]';
      }
    }

    // Adiciona cabeçalhos de segurança
    options.headers['X-Request-ID'] = _generateRequestId();
    options.headers['X-Timestamp'] =
        DateTime.now().millisecondsSinceEpoch.toString();

    // Força HTTPS em produção
    if (AppConfig.instance.isProduction &&
        !options.uri.scheme.startsWith('https')) {
      handler.reject(DioException(
        requestOptions: options,
        message: 'HTTPS required in production',
      ));
      return;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Remove informações sensíveis dos erros
    final sanitizedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      message: err.message,
      type: err.type,
    );

    // Log do erro (sem dados sensíveis)
    _logger.e('HTTP Error: ${err.type} - ${err.message}');

    handler.next(sanitizedError);
  }

  String _generateRequestId() {
    final bytes = utf8.encode('${DateTime.now().millisecondsSinceEpoch}');
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }
}

/// Interceptor de logging
class _LoggingInterceptor extends Interceptor {
  static final Logger _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.w(
        '✗ ${err.requestOptions.method} ${err.requestOptions.uri} - ${err.message}');
    handler.next(err);
  }
}

/// Interceptor de debug (apenas desenvolvimento)
class _DebugInterceptor extends Interceptor {
  static final Logger _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('Request Data: ${options.data}');
    _logger.d('Request Headers: ${_sanitizeHeaders(options.headers)}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('Response Data: ${response.data}');
    handler.next(response);
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    for (final key in sanitized.keys.toList()) {
      if (key.toLowerCase().contains('authorization') ||
          key.toLowerCase().contains('api-key') ||
          key.toLowerCase().contains('token')) {
        sanitized[key] = '[REDACTED]';
      }
    }
    return sanitized;
  }
}

// ========================================
// EXCEÇÕES CUSTOMIZADAS
// ========================================

class ApiKeyException implements Exception {
  final String message;
  const ApiKeyException(this.message);

  @override
  String toString() => 'ApiKeyException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

// ========================================
// EXTENSIONS
// ========================================

extension SecureHttpClientExtensions on SecureHttpClient {
  /// Ping para verificar conectividade
  Future<bool> ping({String endpoint = '/health'}) async {
    try {
      final response = await get(endpoint);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Upload seguro de arquivo
  Future<Response<T>> uploadFile<T>(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, String>? additionalFields,
    String? userId,
  }) async {
    // Valida o arquivo
    final fileName = file.path.split('/').last;
    final fileValidation =
        InputValidator.validate(fileName, ValidationType.fileName);

    if (!fileValidation.isValid) {
      throw ValidationException('Invalid file: ${fileValidation.error}');
    }

    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(file.path, filename: fileName),
      if (additionalFields != null) ...additionalFields,
    });

    return post<T>(path, data: formData, userId: userId);
  }
}
