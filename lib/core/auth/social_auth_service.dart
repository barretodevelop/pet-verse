import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../config/app_config.dart';
import '../validation/input_validator.dart';

/// Resultado da autenticação social
class SocialAuthResult {
  final bool success;
  final String? idToken;
  final String? accessToken;
  final String? authorizationCode;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? userId;
  final SocialAuthProvider provider;
  final String? error;
  final Map<String, dynamic>? rawData;

  const SocialAuthResult({
    required this.success,
    required this.provider,
    this.idToken,
    this.accessToken,
    this.authorizationCode,
    this.email,
    this.displayName,
    this.photoUrl,
    this.userId,
    this.error,
    this.rawData,
  });

  factory SocialAuthResult.success({
    required SocialAuthProvider provider,
    String? idToken,
    String? accessToken,
    String? authorizationCode,
    String? email,
    String? displayName,
    String? photoUrl,
    String? userId,
    Map<String, dynamic>? rawData,
  }) {
    return SocialAuthResult(
      success: true,
      provider: provider,
      idToken: idToken,
      accessToken: accessToken,
      authorizationCode: authorizationCode,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      userId: userId,
      rawData: rawData,
    );
  }

  factory SocialAuthResult.failure({
    required SocialAuthProvider provider,
    required String error,
  }) {
    return SocialAuthResult(
      success: false,
      provider: provider,
      error: error,
    );
  }

  factory SocialAuthResult.cancelled(SocialAuthProvider provider) {
    return SocialAuthResult(
      success: false,
      provider: provider,
      error: 'Autenticação cancelada pelo usuário',
    );
  }
}

/// Providers de autenticação social suportados
enum SocialAuthProvider {
  google('Google'),
  apple('Apple'),
  facebook('Facebook'),
  twitter('Twitter');

  const SocialAuthProvider(this.displayName);
  final String displayName;
}

/// Configuração do Google Sign-In
class GoogleSignInConfig {
  final String? clientIdAndroid;
  final String? clientIdIOS;
  final String? clientIdWeb;
  final List<String> scopes;
  final bool forceCodeForRefreshToken;

  const GoogleSignInConfig({
    this.clientIdAndroid,
    this.clientIdIOS,
    this.clientIdWeb,
    this.scopes = const ['email', 'profile'],
    this.forceCodeForRefreshToken = true,
  });

  factory GoogleSignInConfig.fromAppConfig(AppConfig config) {
    return GoogleSignInConfig(
      clientIdAndroid: config.getString('GOOGLE_CLIENT_ID_ANDROID'),
      clientIdIOS: config.getString('GOOGLE_CLIENT_ID_IOS'),
      clientIdWeb: config.getString('GOOGLE_CLIENT_ID_WEB'),
      scopes: const ['email', 'profile', 'openid'],
      forceCodeForRefreshToken: true,
    );
  }

  String? get clientId {
    if (kIsWeb && clientIdWeb != null) return clientIdWeb;
    if (Platform.isAndroid && clientIdAndroid != null) return clientIdAndroid;
    if (Platform.isIOS && clientIdIOS != null) return clientIdIOS;
    return clientIdWeb; // Fallback
  }
}

/// Configuração do Apple Sign-In
class AppleSignInConfig {
  final String? serviceId;
  final String? teamId;
  final String? keyId;
  final String? privateKeyPath;
  final List<AppleIDAuthorizationScopes> scopes;

  const AppleSignInConfig({
    this.serviceId,
    this.teamId,
    this.keyId,
    this.privateKeyPath,
    this.scopes = const [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
  });

  factory AppleSignInConfig.fromAppConfig(AppConfig config) {
    return AppleSignInConfig(
      serviceId: config.getString('APPLE_SERVICE_ID'),
      teamId: config.getString('APPLE_TEAM_ID'),
      keyId: config.getString('APPLE_KEY_ID'),
      privateKeyPath: config.getString('APPLE_PRIVATE_KEY_PATH'),
    );
  }
}

/// Serviço principal de autenticação social
class SocialAuthService {
  static final Logger _logger = Logger();
  static SocialAuthService? _instance;

  late final GoogleSignInConfig _googleConfig;
  late final AppleSignInConfig _appleConfig;
  late final GoogleSignIn _googleSignIn;

  bool _isInitialized = false;

  SocialAuthService._({
    required GoogleSignInConfig googleConfig,
    required AppleSignInConfig appleConfig,
  })  : _googleConfig = googleConfig,
        _appleConfig = appleConfig {
    _initializeGoogleSignIn();
  }

  /// Singleton instance
  static SocialAuthService get instance {
    if (_instance == null) {
      throw Exception('SocialAuthService must be initialized first');
    }
    return _instance!;
  }

  /// Inicializa o serviço com configurações
  static Future<void> initialize({
    GoogleSignInConfig? googleConfig,
    AppleSignInConfig? appleConfig,
  }) async {
    final config = AppConfig.instance;

    _instance = SocialAuthService._(
      googleConfig: googleConfig ?? GoogleSignInConfig.fromAppConfig(config),
      appleConfig: appleConfig ?? AppleSignInConfig.fromAppConfig(config),
    );

    await _instance!._initialize();
  }

  /// Inicialização interna
  Future<void> _initialize() async {
    try {
      _logger.i('Initializing SocialAuthService...');

      // Verifica disponibilidade dos serviços
      await _checkServicesAvailability();

      _isInitialized = true;
      _logger.i('SocialAuthService initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize SocialAuthService',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Inicializa Google Sign-In
  void _initializeGoogleSignIn() {
    _googleSignIn = GoogleSignIn(
      clientId: _googleConfig.clientId,
      scopes: _googleConfig.scopes,
      forceCodeForRefreshToken: _googleConfig.forceCodeForRefreshToken,
    );
  }

  /// Verifica disponibilidade dos serviços
  Future<void> _checkServicesAvailability() async {
    // Verifica Google Play Services (Android)
    if (Platform.isAndroid) {
      try {
        final isAvailable = await _googleSignIn.isSignedIn();
        _logger.d('Google Play Services available: $isAvailable');
      } catch (e) {
        _logger.w('Google Play Services check failed: $e');
      }
    }

    // Verifica Apple Sign-In (iOS)
    if (Platform.isIOS) {
      try {
        final isAvailable = await SignInWithApple.isAvailable();
        _logger.d('Apple Sign-In available: $isAvailable');
      } catch (e) {
        _logger.w('Apple Sign-In check failed: $e');
      }
    }
  }

  // ==========================================
  // GOOGLE SIGN-IN
  // ==========================================

  /// Autentica com Google
  Future<SocialAuthResult> signInWithGoogle({
    bool silentSignIn = false,
  }) async {
    if (!_isInitialized) {
      throw Exception('SocialAuthService not initialized');
    }

    try {
      _logger.d('Starting Google Sign-In (silent: $silentSignIn)...');

      GoogleSignInAccount? account;

      if (silentSignIn) {
        // Tenta login silencioso primeiro
        account = await _googleSignIn.signInSilently();
        _logger.d('Silent sign-in result: ${account?.email}');
      }

      // Se login silencioso falhou, tenta login interativo
      if (account == null && !silentSignIn) {
        account = await _googleSignIn.signIn();
      }

      if (account == null) {
        return SocialAuthResult.cancelled(SocialAuthProvider.google);
      }

      // Valida dados básicos
      final emailValidation = _validateGoogleUserData(account);
      if (!emailValidation.isValid) {
        await _googleSignIn.signOut();
        return SocialAuthResult.failure(
          provider: SocialAuthProvider.google,
          error: emailValidation.error ?? 'Dados do usuário inválidos',
        );
      }

      // Obtém tokens de autenticação
      final googleAuth = await account.authentication;

      // Valida tokens
      if (googleAuth.idToken == null) {
        await _googleSignIn.signOut();
        return SocialAuthResult.failure(
          provider: SocialAuthProvider.google,
          error: 'ID Token não recebido do Google',
        );
      }

      _logger.i('Google Sign-In successful for: ${account.email}');

      return SocialAuthResult.success(
        provider: SocialAuthProvider.google,
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
        userId: account.id,
        rawData: {
          'serverAuthCode': googleAuth.serverAuthCode,
          'account': {
            'id': account.id,
            'email': account.email,
            'displayName': account.displayName,
            'photoUrl': account.photoUrl,
          },
        },
      );
    } on PlatformException catch (e) {
      _logger.e('Google Sign-In platform error: ${e.code} - ${e.message}');

      String errorMessage;
      switch (e.code) {
        case 'sign_in_canceled':
          return SocialAuthResult.cancelled(SocialAuthProvider.google);
        case 'network_error':
          errorMessage = 'Erro de conexão. Verifique sua internet.';
          break;
        case 'sign_in_failed':
          errorMessage = 'Falha na autenticação com Google.';
          break;
        default:
          errorMessage = 'Erro inesperado: ${e.message}';
      }

      return SocialAuthResult.failure(
        provider: SocialAuthProvider.google,
        error: errorMessage,
      );
    } catch (e, stackTrace) {
      _logger.e('Google Sign-In unexpected error',
          error: e, stackTrace: stackTrace);

      return SocialAuthResult.failure(
        provider: SocialAuthProvider.google,
        error: 'Erro interno na autenticação: $e',
      );
    }
  }

  /// Valida dados do usuário Google
  ValidationResult _validateGoogleUserData(GoogleSignInAccount account) {
    // Valida email
    if (account.email.isEmpty) {
      return ValidationResult.invalid('Email não fornecido pelo Google');
    }

    final emailValidation =
        InputValidator.validate(account.email, ValidationType.email);
    if (!emailValidation.isValid) {
      return ValidationResult.invalid(
          'Email inválido: ${emailValidation.error}');
    }

    // Valida displayName (opcional)
    if (account.displayName != null && account.displayName!.isNotEmpty) {
      final nameValidation = InputValidator.validate(
        account.displayName!,
        ValidationType.userInput,
        maxLength: 100,
      );
      if (!nameValidation.isValid) {
        return ValidationResult.invalid(
            'Nome inválido: ${nameValidation.error}');
      }
    }

    return ValidationResult.valid(account.email);
  }

  /// Desconecta do Google
  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      _logger.i('Google Sign-Out successful');
    } catch (e, stackTrace) {
      _logger.e('Google Sign-Out failed', error: e, stackTrace: stackTrace);
    }
  }

  /// Desconecta completamente do Google
  Future<void> disconnectGoogle() async {
    try {
      await _googleSignIn.disconnect();
      _logger.i('Google disconnect successful');
    } catch (e, stackTrace) {
      _logger.e('Google disconnect failed', error: e, stackTrace: stackTrace);
    }
  }

  // ==========================================
  // APPLE SIGN-IN
  // ==========================================

  /// Autentica com Apple
  Future<SocialAuthResult> signInWithApple({
    List<AppleIDAuthorizationScopes>? scopes,
  }) async {
    if (!_isInitialized) {
      throw Exception('SocialAuthService not initialized');
    }

    // Verifica se Apple Sign-In está disponível
    if (!Platform.isIOS && !kIsWeb) {
      return SocialAuthResult.failure(
        provider: SocialAuthProvider.apple,
        error: 'Apple Sign-In apenas disponível em iOS e Web',
      );
    }

    try {
      _logger.d('Starting Apple Sign-In...');

      // Verifica disponibilidade
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        return SocialAuthResult.failure(
          provider: SocialAuthProvider.apple,
          error: 'Apple Sign-In não está disponível neste dispositivo',
        );
      }

      // Solicita autorização
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: scopes ?? _appleConfig.scopes,
        webAuthenticationOptions: kIsWeb
            ? WebAuthenticationOptions(
                clientId: _appleConfig.serviceId ?? 'com.example.app',
                redirectUri: Uri.parse('https://your-domain.com/auth/callback'),
              )
            : null,
      );

      // Valida credencial
      final validation = _validateAppleCredential(credential);
      if (!validation.isValid) {
        return SocialAuthResult.failure(
          provider: SocialAuthProvider.apple,
          error: validation.error ?? 'Credencial Apple inválida',
        );
      }

      // Extrai dados do usuário
      String? email;
      String? displayName;

      if (credential.email != null) {
        email = credential.email;
      }

      if (credential.givenName != null || credential.familyName != null) {
        final parts = <String>[];
        if (credential.givenName != null) parts.add(credential.givenName!);
        if (credential.familyName != null) parts.add(credential.familyName!);
        displayName = parts.join(' ').trim();
      }

      _logger
          .i('Apple Sign-In successful for user: ${credential.userIdentifier}');

      return SocialAuthResult.success(
        provider: SocialAuthProvider.apple,
        idToken: credential.identityToken,
        authorizationCode: credential.authorizationCode,
        email: email,
        displayName: displayName,
        userId: credential.userIdentifier,
        rawData: {
          'userIdentifier': credential.userIdentifier,
          'authorizationCode': credential.authorizationCode,
          'identityToken': credential.identityToken,
          'email': credential.email,
          'givenName': credential.givenName,
          'familyName': credential.familyName,
          'state': credential.state,
        },
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      _logger.e('Apple Sign-In authorization error: ${e.code} - ${e.message}');

      String errorMessage;
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          return SocialAuthResult.cancelled(SocialAuthProvider.apple);
        case AuthorizationErrorCode.failed:
          errorMessage = 'Falha na autenticação com Apple.';
          break;
        case AuthorizationErrorCode.invalidResponse:
          errorMessage = 'Resposta inválida da Apple.';
          break;
        case AuthorizationErrorCode.notHandled:
          errorMessage = 'Autenticação não processada.';
          break;
        case AuthorizationErrorCode.unknown:
        default:
          errorMessage = 'Erro desconhecido na autenticação Apple.';
      }

      return SocialAuthResult.failure(
        provider: SocialAuthProvider.apple,
        error: errorMessage,
      );
    } catch (e, stackTrace) {
      _logger.e('Apple Sign-In unexpected error',
          error: e, stackTrace: stackTrace);

      return SocialAuthResult.failure(
        provider: SocialAuthProvider.apple,
        error: 'Erro interno na autenticação: $e',
      );
    }
  }

  /// Valida credencial do Apple
  ValidationResult _validateAppleCredential(
      AuthorizationCredentialAppleID credential) {
    // Verifica campos obrigatórios
    if (credential.userIdentifier!.isEmpty) {
      return ValidationResult.invalid('ID do usuário não fornecido');
    }

    if (credential.identityToken == null || credential.identityToken!.isEmpty) {
      return ValidationResult.invalid('Identity Token não fornecido');
    }

    if (credential.authorizationCode.isEmpty) {
      return ValidationResult.invalid('Authorization Code não fornecido');
    }

    // Valida email se fornecido
    if (credential.email != null && credential.email!.isNotEmpty) {
      final emailValidation =
          InputValidator.validate(credential.email!, ValidationType.email);
      if (!emailValidation.isValid) {
        return ValidationResult.invalid(
            'Email inválido: ${emailValidation.error}');
      }
    }

    // Valida nomes se fornecidos
    if (credential.givenName != null && credential.givenName!.isNotEmpty) {
      final nameValidation = InputValidator.validate(
        credential.givenName!,
        ValidationType.userInput,
        maxLength: 50,
      );
      if (!nameValidation.isValid) {
        return ValidationResult.invalid(
            'Nome inválido: ${nameValidation.error}');
      }
    }

    return ValidationResult.valid(credential.userIdentifier);
  }

  // ==========================================
  // MÉTODOS UTILITÁRIOS
  // ==========================================

  /// Verifica se está logado no Google
  Future<bool> isSignedInGoogle() async {
    try {
      return await _googleSignIn.isSignedIn();
    } catch (e) {
      _logger.w('Failed to check Google sign-in status: $e');
      return false;
    }
  }

  /// Obtém conta Google atual
  Future<GoogleSignInAccount?> getCurrentGoogleAccount() async {
    try {
      return _googleSignIn.currentUser;
    } catch (e) {
      _logger.w('Failed to get current Google account: $e');
      return null;
    }
  }

  /// Verifica se Apple Sign-In está disponível
  Future<bool> isAppleSignInAvailable() async {
    try {
      if (!Platform.isIOS && !kIsWeb) return false;
      return await SignInWithApple.isAvailable();
    } catch (e) {
      _logger.w('Failed to check Apple Sign-In availability: $e');
      return false;
    }
  }

  /// Desconecta de todos os serviços
  Future<void> signOutAll() async {
    await Future.wait([
      signOutGoogle(),
      // Apple não tem signOut global, apenas por app
    ]);
  }

  /// Obtém informações de configuração
  Map<String, dynamic> getConfigInfo() {
    return {
      'google': {
        'clientId': _googleConfig.clientId,
        'scopes': _googleConfig.scopes,
        'configured': _googleConfig.clientId != null,
      },
      'apple': {
        'serviceId': _appleConfig.serviceId,
        'scopes': _appleConfig.scopes.map((s) => s.toString()).toList(),
        'configured': _appleConfig.serviceId != null,
      },
      'initialized': _isInitialized,
    };
  }

  /// Dispose
  void dispose() {
    _instance = null;
    _isInitialized = false;
  }
}

// ==========================================
// EXTENSIONS
// ==========================================

extension SocialAuthResultExtensions on SocialAuthResult {
  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'provider': provider.name,
      'idToken': idToken,
      'accessToken': accessToken,
      'authorizationCode': authorizationCode,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'userId': userId,
      'error': error,
      'rawData': rawData,
    };
  }

  /// Verifica se tem dados suficientes para autenticação
  bool get hasValidAuthData {
    if (!success) return false;

    switch (provider) {
      case SocialAuthProvider.google:
        return idToken != null && email != null;
      case SocialAuthProvider.apple:
        return identityToken != null && authorizationCode != null;
      default:
        return false;
    }
  }

  /// Obtém token principal para o provider
  String? get primaryToken {
    switch (provider) {
      case SocialAuthProvider.google:
        return idToken;
      case SocialAuthProvider.apple:
        return identityToken;
      default:
        return null;
    }
  }

  /// Alias para identityToken (Apple)
  String? get identityToken => idToken;
}

extension AppleIDAuthorizationScopesExtensions on AppleIDAuthorizationScopes {
  String get displayName {
    switch (this) {
      case AppleIDAuthorizationScopes.email:
        return 'Email';
      case AppleIDAuthorizationScopes.fullName:
        return 'Nome Completo';
    }
  }
}
