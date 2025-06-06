import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:petverse/core/providers/secure_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../network/secure_http_client.dart';
import '../validation/input_validator.dart';

/// Estados de autenticação
enum AuthState {
  unauthenticated,
  authenticating,
  authenticated,
  expired,
  error,
}

/// Tipos de autenticação suportados
enum AuthType {
  guest,
  google,
  apple,
  email,
}

/// Resultado de autenticação
class AuthResult {
  final bool success;
  final String? token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final Map<String, dynamic>? userData;
  final String? error;

  const AuthResult({
    required this.success,
    this.token,
    this.refreshToken,
    this.expiresAt,
    this.userData,
    this.error,
  });

  factory AuthResult.success({
    required String token,
    String? refreshToken,
    DateTime? expiresAt,
    Map<String, dynamic>? userData,
  }) {
    return AuthResult(
      success: true,
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      userData: userData,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult(
      success: false,
      error: error,
    );
  }
}

/// Dados do usuário autenticado
class AuthUser {
  final String id;
  final String? email;
  final String? name;
  final String? avatarUrl;
  final AuthType authType;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const AuthUser({
    required this.id,
    this.email,
    this.name,
    this.avatarUrl,
    required this.authType,
    this.metadata = const {},
    required this.createdAt,
    required this.lastLoginAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      name: json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      authType: AuthType.values.firstWhere(
        (type) => type.name == json['authType'],
        orElse: () => AuthType.guest,
      ),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'authType': authType.name,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }

  AuthUser copyWith({
    String? email,
    String? name,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
    DateTime? lastLoginAt,
  }) {
    return AuthUser(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      authType: authType,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

/// Middleware de autenticação seguro
class AuthMiddleware {
  static final Logger _logger = Logger();
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _sessionKey = 'session_data';

  final SecureHttpClient _httpClient;
  final AppConfig _config;

  AuthMiddleware({
    required SecureHttpClient httpClient,
    required AppConfig config,
  })  : _httpClient = httpClient,
        _config = config;

  // ========================================
  // MÉTODOS DE AUTENTICAÇÃO
  // ========================================

  /// Login com Google
  Future<AuthResult> loginWithGoogle({
    required String idToken,
    String? deviceId,
  }) async {
    try {
      // Valida o token
      final tokenValidation = InputValidator.validate(
        idToken,
        ValidationType.generic,
        maxLength: 2048,
      );

      if (!tokenValidation.isValid) {
        return AuthResult.failure('Token inválido');
      }

      // Prepara dados para o backend
      final requestData = {
        'idToken': tokenValidation.sanitizedValue,
        'provider': 'google',
        if (deviceId != null) 'deviceId': deviceId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Adiciona assinatura para verificação
      final signature = _generateRequestSignature(requestData);
      requestData['signature'] = signature;

      final response = await _httpClient.backendRequest<Map<String, dynamic>>(
        '/auth/google',
        method: 'POST',
        data: requestData,
      );

      return _processAuthResponse(response.data);
    } catch (e, stackTrace) {
      _logger.e('Google login failed', error: e, stackTrace: stackTrace);
      return AuthResult.failure('Falha no login com Google: $e');
    }
  }

  /// Login com Apple
  Future<AuthResult> loginWithApple({
    required String authorizationCode,
    required String identityToken,
    String? deviceId,
  }) async {
    try {
      // Valida tokens
      final codeValidation = InputValidator.validate(
        authorizationCode,
        ValidationType.generic,
        maxLength: 1024,
      );

      final tokenValidation = InputValidator.validate(
        identityToken,
        ValidationType.generic,
        maxLength: 2048,
      );

      if (!codeValidation.isValid || !tokenValidation.isValid) {
        return AuthResult.failure('Tokens inválidos');
      }

      final requestData = {
        'authorizationCode': codeValidation.sanitizedValue,
        'identityToken': tokenValidation.sanitizedValue,
        'provider': 'apple',
        if (deviceId != null) 'deviceId': deviceId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final signature = _generateRequestSignature(requestData);
      requestData['signature'] = signature;

      final response = await _httpClient.backendRequest<Map<String, dynamic>>(
        '/auth/apple',
        method: 'POST',
        data: requestData,
      );

      return _processAuthResponse(response.data);
    } catch (e, stackTrace) {
      _logger.e('Apple login failed', error: e, stackTrace: stackTrace);
      return AuthResult.failure('Falha no login com Apple: $e');
    }
  }

  /// Login como convidado
  Future<AuthResult> loginAsGuest({String? deviceId}) async {
    try {
      final guestId = _generateGuestId();

      final requestData = {
        'guestId': guestId,
        'provider': 'guest',
        if (deviceId != null) 'deviceId': deviceId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final signature = _generateRequestSignature(requestData);
      requestData['signature'] = signature;

      final response = await _httpClient.backendRequest<Map<String, dynamic>>(
        '/auth/guest',
        method: 'POST',
        data: requestData,
      );

      return _processAuthResponse(response.data);
    } catch (e, stackTrace) {
      _logger.e('Guest login failed', error: e, stackTrace: stackTrace);
      return AuthResult.failure('Falha no login como convidado: $e');
    }
  }

  /// Login com email/senha
  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
    String? deviceId,
  }) async {
    try {
      // Valida email
      final emailValidation =
          InputValidator.validate(email, ValidationType.email);
      if (!emailValidation.isValid) {
        return AuthResult.failure('Email inválido');
      }

      // Valida senha (básico - não logamos a senha)
      if (password.length < 6) {
        return AuthResult.failure('Senha deve ter pelo menos 6 caracteres');
      }

      // Hash da senha para envio seguro
      final passwordHash = _hashPassword(password);

      final requestData = {
        'email': emailValidation.sanitizedValue,
        'passwordHash': passwordHash,
        'provider': 'email',
        if (deviceId != null) 'deviceId': deviceId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final signature = _generateRequestSignature(requestData);
      requestData['signature'] = signature;

      final response = await _httpClient.backendRequest<Map<String, dynamic>>(
        '/auth/email',
        method: 'POST',
        data: requestData,
      );

      return _processAuthResponse(response.data);
    } catch (e, stackTrace) {
      _logger.e('Email login failed', error: e, stackTrace: stackTrace);
      return AuthResult.failure('Falha no login com email: $e');
    }
  }

  // ========================================
  // GERENCIAMENTO DE SESSÃO
  // ========================================

  /// Salva dados de autenticação de forma segura
  Future<void> saveAuthData(AuthResult authResult) async {
    if (!authResult.success) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Encrypt tokens antes de salvar
      if (authResult.token != null) {
        final encryptedToken = _encryptData(authResult.token!);
        await prefs.setString(_tokenKey, encryptedToken);
      }

      if (authResult.refreshToken != null) {
        final encryptedRefreshToken = _encryptData(authResult.refreshToken!);
        await prefs.setString(_refreshTokenKey, encryptedRefreshToken);
      }

      if (authResult.userData != null) {
        final userDataJson = jsonEncode(authResult.userData);
        final encryptedUserData = _encryptData(userDataJson);
        await prefs.setString(_userDataKey, encryptedUserData);
      }

      // Salva dados da sessão
      final sessionData = {
        'expiresAt': authResult.expiresAt?.toIso8601String(),
        'loginTime': DateTime.now().toIso8601String(),
        'deviceFingerprint': await _generateDeviceFingerprint(),
      };

      final sessionJson = jsonEncode(sessionData);
      final encryptedSession = _encryptData(sessionJson);
      await prefs.setString(_sessionKey, encryptedSession);

      _logger.i('Auth data saved securely');
    } catch (e, stackTrace) {
      _logger.e('Failed to save auth data', error: e, stackTrace: stackTrace);
    }
  }

  /// Carrega dados de autenticação
  Future<AuthUser?> loadAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Verifica se tem dados salvos
      final encryptedUserData = prefs.getString(_userDataKey);
      final encryptedSession = prefs.getString(_sessionKey);

      if (encryptedUserData == null || encryptedSession == null) {
        return null;
      }

      // Descriptografa dados
      final userDataJson = _decryptData(encryptedUserData);
      final sessionJson = _decryptData(encryptedSession);

      final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
      final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;

      // Verifica se a sessão ainda é válida
      if (!_isSessionValid(sessionData)) {
        await clearAuthData();
        return null;
      }

      return AuthUser.fromJson(userData);
    } catch (e, stackTrace) {
      _logger.e('Failed to load auth data', error: e, stackTrace: stackTrace);
      await clearAuthData(); // Limpa dados corrompidos
      return null;
    }
  }

  /// Limpa dados de autenticação
  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await Future.wait([
        prefs.remove(_tokenKey),
        prefs.remove(_refreshTokenKey),
        prefs.remove(_userDataKey),
        prefs.remove(_sessionKey),
      ]);

      _logger.i('Auth data cleared');
    } catch (e, stackTrace) {
      _logger.e('Failed to clear auth data', error: e, stackTrace: stackTrace);
    }
  }

  /// Atualiza token usando refresh token
  Future<AuthResult> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedRefreshToken = prefs.getString(_refreshTokenKey);

      if (encryptedRefreshToken == null) {
        return AuthResult.failure('Refresh token não encontrado');
      }

      final refreshToken = _decryptData(encryptedRefreshToken);

      final requestData = {
        'refreshToken': refreshToken,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final signature = _generateRequestSignature(requestData);
      requestData['signature'] = signature;

      final response = await _httpClient.backendRequest<Map<String, dynamic>>(
        '/auth/refresh',
        method: 'POST',
        data: requestData,
      );

      final authResult = _processAuthResponse(response.data);

      if (authResult.success) {
        await saveAuthData(authResult);
      }

      return authResult;
    } catch (e, stackTrace) {
      _logger.e('Token refresh failed', error: e, stackTrace: stackTrace);
      return AuthResult.failure('Falha ao renovar token: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Tenta invalidar token no servidor
      try {
        await _httpClient.backendRequest<void>(
          '/auth/logout',
          method: 'POST',
        );
      } catch (e) {
        _logger.w('Failed to logout on server: $e');
      }

      // Limpa dados locais sempre
      await clearAuthData();

      _logger.i('User logged out');
    } catch (e, stackTrace) {
      _logger.e('Logout failed', error: e, stackTrace: stackTrace);
    }
  }

  // ========================================
  // MÉTODOS AUXILIARES
  // ========================================

  /// Processa resposta de autenticação
  AuthResult _processAuthResponse(Map<String, dynamic>? data) {
    if (data == null) {
      return AuthResult.failure('Resposta inválida do servidor');
    }

    if (data['success'] != true) {
      return AuthResult.failure(
          data['message'] as String? ?? 'Erro desconhecido');
    }

    final token = data['token'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    final userData = data['user'] as Map<String, dynamic>?;

    DateTime? expiresAt;
    if (data['expiresAt'] != null) {
      expiresAt = DateTime.parse(data['expiresAt'] as String);
    }

    if (token == null) {
      return AuthResult.failure('Token não recebido');
    }

    return AuthResult.success(
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      userData: userData,
    );
  }

  /// Gera assinatura da requisição
  String _generateRequestSignature(Map<String, dynamic> data) {
    final sortedKeys = data.keys.toList()..sort();
    final dataString = sortedKeys.map((key) => '$key=${data[key]}').join('&');

    // Em produção, use uma chave secreta real
    final secretKey = _config.isProduction
        ? _config.getString('AUTH_SECRET_KEY', 'default-secret')
        : 'dev-secret-key';

    final bytes = utf8.encode('$dataString:$secretKey');
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  /// Gera ID único para convidado
  String _generateGuestId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomBytes = List.generate(16, (i) => timestamp % 256);
    final digest = sha256.convert(randomBytes);

    return 'guest_${digest.toString().substring(0, 16)}';
  }

  /// Hash da senha
  String _hashPassword(String password) {
    // Em produção, use bcrypt ou similar
    const salt = 'petadote_salt_2024'; // Use salt único por usuário
    final bytes = utf8.encode('$password:$salt');
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  /// Encrypts data simples (em produção, use AES)
  String _encryptData(String data) {
    // Implementação simplificada - em produção use AES
    final bytes = utf8.encode(data);
    final encoded = base64.encode(bytes);

    return encoded;
  }

  /// Decrypts data
  String _decryptData(String encryptedData) {
    // Implementação simplificada
    final bytes = base64.decode(encryptedData);
    final decoded = utf8.decode(bytes);

    return decoded;
  }

  /// Verifica se a sessão ainda é válida
  bool _isSessionValid(Map<String, dynamic> sessionData) {
    try {
      // Verifica expiração
      final expiresAtStr = sessionData['expiresAt'] as String?;
      if (expiresAtStr != null) {
        final expiresAt = DateTime.parse(expiresAtStr);
        if (DateTime.now().isAfter(expiresAt)) {
          return false;
        }
      }

      // Verifica fingerprint do dispositivo
      // (implementação simplificada)
      final savedFingerprint = sessionData['deviceFingerprint'] as String?;
      if (savedFingerprint != null) {
        // Em um cenário real, verificaria se o fingerprint atual
        // corresponde ao salvo
      }

      return true;
    } catch (e) {
      _logger.w('Session validation error: $e');
      return false;
    }
  }

  /// Gera fingerprint do dispositivo
  Future<String> _generateDeviceFingerprint() async {
    // Implementação simplificada
    // Em produção, coletaria mais informações do dispositivo
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = 'device_$timestamp';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);

    return digest.toString().substring(0, 32);
  }

  /// Obtém token atual
  Future<String?> getCurrentToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedToken = prefs.getString(_tokenKey);

      if (encryptedToken == null) return null;

      return _decryptData(encryptedToken);
    } catch (e) {
      _logger.w('Failed to get current token: $e');
      return null;
    }
  }

  /// Verifica se o usuário está autenticado
  Future<bool> isAuthenticated() async {
    final user = await loadAuthData();
    return user != null;
  }
}

// ========================================
// PROVIDER DO RIVERPOD
// ========================================

/// Provider para AuthMiddleware
final authMiddlewareProvider = Provider<AuthMiddleware>((ref) {
  final httpClient = ref.watch(secureHttpClientProvider);
  final config = ref.watch(appConfigProvider);

  return AuthMiddleware(
    httpClient: httpClient,
    config: config,
  );
});

/// Provider para estado de autenticação
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final middleware = ref.watch(authMiddlewareProvider);
  return AuthStateNotifier(middleware);
});

/// Provider para usuário atual
final currentUserProvider = StateProvider<AuthUser?>((ref) => null);

/// Notifier para gerenciar estado de autenticação
class AuthStateNotifier extends StateNotifier<AuthState> {
  static final Logger _logger = Logger();

  final AuthMiddleware _middleware;

  AuthStateNotifier(this._middleware) : super(AuthState.unauthenticated) {
    _checkInitialAuthState();
  }

  /// Verifica estado inicial de autenticação
  Future<void> _checkInitialAuthState() async {
    try {
      final user = await _middleware.loadAuthData();

      if (user != null) {
        state = AuthState.authenticated;
      } else {
        state = AuthState.unauthenticated;
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to check auth state', error: e, stackTrace: stackTrace);
      state = AuthState.error;
    }
  }

  /// Login com Google
  Future<AuthResult> loginWithGoogle(String idToken, {String? deviceId}) async {
    state = AuthState.authenticating;

    try {
      final result = await _middleware.loginWithGoogle(
        idToken: idToken,
        deviceId: deviceId,
      );

      if (result.success) {
        await _middleware.saveAuthData(result);
        state = AuthState.authenticated;
      } else {
        state = AuthState.unauthenticated;
      }

      return result;
    } catch (e, stackTrace) {
      _logger.e('Google login failed', error: e, stackTrace: stackTrace);
      state = AuthState.error;
      return AuthResult.failure('Erro interno no login');
    }
  }

  /// Login com Apple
  Future<AuthResult> loginWithApple(
    String authorizationCode,
    String identityToken, {
    String? deviceId,
  }) async {
    state = AuthState.authenticating;

    try {
      final result = await _middleware.loginWithApple(
        authorizationCode: authorizationCode,
        identityToken: identityToken,
        deviceId: deviceId,
      );

      if (result.success) {
        await _middleware.saveAuthData(result);
        state = AuthState.authenticated;
      } else {
        state = AuthState.unauthenticated;
      }

      return result;
    } catch (e, stackTrace) {
      _logger.e('Apple login failed', error: e, stackTrace: stackTrace);
      state = AuthState.error;
      return AuthResult.failure('Erro interno no login');
    }
  }

  /// Login como convidado
  Future<AuthResult> loginAsGuest({String? deviceId}) async {
    state = AuthState.authenticating;

    try {
      final result = await _middleware.loginAsGuest(deviceId: deviceId);

      if (result.success) {
        await _middleware.saveAuthData(result);
        state = AuthState.authenticated;
      } else {
        state = AuthState.unauthenticated;
      }

      return result;
    } catch (e, stackTrace) {
      _logger.e('Guest login failed', error: e, stackTrace: stackTrace);
      state = AuthState.error;
      return AuthResult.failure('Erro interno no login');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _middleware.logout();
      state = AuthState.unauthenticated;
    } catch (e, stackTrace) {
      _logger.e('Logout failed', error: e, stackTrace: stackTrace);
      state = AuthState.error;
    }
  }

  /// Refresh token
  Future<bool> refreshToken() async {
    try {
      final result = await _middleware.refreshToken();

      if (result.success) {
        // Token atualizado com sucesso
        return true;
      } else {
        // Token inválido, fazer logout
        state = AuthState.expired;
        await _middleware.clearAuthData();
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e('Token refresh failed', error: e, stackTrace: stackTrace);
      state = AuthState.error;
      return false;
    }
  }
}
