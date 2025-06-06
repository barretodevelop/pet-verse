// lib/core/firebase/firebase_auth_service.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../auth/auth_middleware.dart';
import '../config/app_config.dart';
import '../validation/input_validator.dart';

/// Resultado da autenticação Firebase
class FirebaseAuthResult {
  final bool success;
  final User? user;
  final String? idToken;
  final String? accessToken;
  final String? error;
  final AuthType? authType;

  const FirebaseAuthResult({
    required this.success,
    this.user,
    this.idToken,
    this.accessToken,
    this.error,
    this.authType,
  });

  factory FirebaseAuthResult.success({
    required User user,
    String? idToken,
    String? accessToken,
    AuthType? authType,
  }) {
    return FirebaseAuthResult(
      success: true,
      user: user,
      idToken: idToken,
      accessToken: accessToken,
      authType: authType,
    );
  }

  factory FirebaseAuthResult.failure(String error, {AuthType? authType}) {
    return FirebaseAuthResult(
      success: false,
      error: error,
      authType: authType,
    );
  }
}

/// Serviço de autenticação Firebase integrado com o sistema existente
class FirebaseAuthService {
  static final Logger _logger = Logger();
  static FirebaseAuthService? _instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  StreamSubscription<User?>? _authStateSubscription;

  FirebaseAuthService._({
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _googleSignIn = googleSignIn;

  /// Singleton instance
  static FirebaseAuthService get instance {
    if (_instance == null) {
      throw Exception('FirebaseAuthService must be initialized first');
    }
    return _instance!;
  }

  /// Inicializa o serviço
  static Future<void> initialize() async {
    if (_instance != null) return;

    try {
      final config = AppConfig.instance;

      // Configura Google Sign-In
      final googleSignIn = GoogleSignIn(
        clientId: config.getString('GOOGLE_CLIENT_ID_IOS'),
        scopes: ['email', 'profile'],
      );

      _instance = FirebaseAuthService._(
        auth: FirebaseAuth.instance,
        googleSignIn: googleSignIn,
      );

      await _instance!._setupAuthSettings();
      _instance!._startAuthStateListener();

      _logger.i('FirebaseAuthService initialized');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize FirebaseAuthService',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Configurações de autenticação
  Future<void> _setupAuthSettings() async {
    try {
      // Configurações de segurança
      await _auth.setSettings(
        appVerificationDisabledForTesting: !AppConfig.instance.isProduction,
        userAccessGroup: AppConfig.instance.isProduction
            ? 'group.com.petadote.shared'
            : null,
      );

      // Idioma baseado na localização
      await _auth.setLanguageCode('pt');

      _logger.d('Firebase Auth settings configured');
    } catch (e) {
      _logger.w('Failed to configure auth settings: $e');
    }
  }

  /// Inicia listener de estado de autenticação
  void _startAuthStateListener() {
    _authStateSubscription = _auth.authStateChanges().listen(
      (User? user) {
        _logger.d('Auth state changed: ${user?.uid ?? 'null'}');
      },
      onError: (error) {
        _logger.e('Auth state listener error: $error');
      },
    );
  }

  // ========================================
  // MÉTODOS DE AUTENTICAÇÃO
  // ========================================

  /// Login com Google
  Future<FirebaseAuthResult> signInWithGoogle() async {
    try {
      _logger.d('Starting Firebase Google Sign-In...');

      // 1. Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return FirebaseAuthResult.failure(
          'Login cancelado pelo usuário',
          authType: AuthType.google,
        );
      }

      // 2. Valida dados do usuário
      final validation = _validateGoogleUser(googleUser);
      if (!validation.isValid) {
        await _googleSignIn.signOut();
        return FirebaseAuthResult.failure(
          validation.error ?? 'Dados do usuário inválidos',
          authType: AuthType.google,
        );
      }

      // 3. Obtém credenciais
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Firebase Sign-In
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        return FirebaseAuthResult.failure(
          'Falha na autenticação Firebase',
          authType: AuthType.google,
        );
      }

      // 5. Obtém token ID
      final idToken = await user.getIdToken();

      _logger.i('Firebase Google Sign-In successful: ${user.email}');

      return FirebaseAuthResult.success(
        user: user,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
        authType: AuthType.google,
      );
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth error: ${e.code} - ${e.message}');
      return FirebaseAuthResult.failure(
        _getFirebaseAuthErrorMessage(e.code),
        authType: AuthType.google,
      );
    } catch (e, stackTrace) {
      _logger.e('Google Sign-In error', error: e, stackTrace: stackTrace);
      return FirebaseAuthResult.failure(
        'Erro interno na autenticação: $e',
        authType: AuthType.google,
      );
    }
  }

  /// Login com Apple
  Future<FirebaseAuthResult> signInWithApple() async {
    try {
      _logger.d('Starting Firebase Apple Sign-In...');

      // 1. Apple Sign-In
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. Valida credencial
      final validation = _validateAppleCredential(appleCredential);
      if (!validation.isValid) {
        return FirebaseAuthResult.failure(
          validation.error ?? 'Credencial Apple inválida',
          authType: AuthType.apple,
        );
      }

      // 3. Cria credencial Firebase
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 4. Firebase Sign-In
      final UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);
      final User? user = userCredential.user;

      if (user == null) {
        return FirebaseAuthResult.failure(
          'Falha na autenticação Firebase',
          authType: AuthType.apple,
        );
      }

      // 5. Atualiza perfil se necessário
      if (user.displayName == null && appleCredential.givenName != null) {
        final displayName = [
          appleCredential.givenName,
          appleCredential.familyName,
        ].where((name) => name != null).join(' ').trim();

        if (displayName.isNotEmpty) {
          await user.updateDisplayName(displayName);
        }
      }

      // 6. Obtém token ID
      final idToken = await user.getIdToken();

      _logger.i('Firebase Apple Sign-In successful: ${user.uid}');

      return FirebaseAuthResult.success(
        user: user,
        idToken: idToken,
        authType: AuthType.apple,
      );
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth error: ${e.code} - ${e.message}');
      return FirebaseAuthResult.failure(
        _getFirebaseAuthErrorMessage(e.code),
        authType: AuthType.apple,
      );
    } catch (e, stackTrace) {
      _logger.e('Apple Sign-In error', error: e, stackTrace: stackTrace);
      return FirebaseAuthResult.failure(
        'Erro interno na autenticação: $e',
        authType: AuthType.apple,
      );
    }
  }

  /// Login com email/senha
  Future<FirebaseAuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Valida email
      final emailValidation =
          InputValidator.validate(email, ValidationType.email);
      if (!emailValidation.isValid) {
        return FirebaseAuthResult.failure(
          'Email inválido',
          authType: AuthType.email,
        );
      }

      // Valida senha
      if (password.length < 6) {
        return FirebaseAuthResult.failure(
          'Senha deve ter pelo menos 6 caracteres',
          authType: AuthType.email,
        );
      }

      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: emailValidation.sanitizedValue as String,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        return FirebaseAuthResult.failure(
          'Falha na autenticação',
          authType: AuthType.email,
        );
      }

      final idToken = await user.getIdToken();

      _logger.i('Firebase email Sign-In successful: ${user.email}');

      return FirebaseAuthResult.success(
        user: user,
        idToken: idToken,
        authType: AuthType.email,
      );
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth error: ${e.code} - ${e.message}');
      return FirebaseAuthResult.failure(
        _getFirebaseAuthErrorMessage(e.code),
        authType: AuthType.email,
      );
    } catch (e, stackTrace) {
      _logger.e('Email Sign-In error', error: e, stackTrace: stackTrace);
      return FirebaseAuthResult.failure(
        'Erro interno na autenticação: $e',
        authType: AuthType.email,
      );
    }
  }

  /// Registra usuário com email/senha
  Future<FirebaseAuthResult> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      // Valida email
      final emailValidation =
          InputValidator.validate(email, ValidationType.email);
      if (!emailValidation.isValid) {
        return FirebaseAuthResult.failure(
          'Email inválido',
          authType: AuthType.email,
        );
      }

      // Valida senha
      if (password.length < 6) {
        return FirebaseAuthResult.failure(
          'Senha deve ter pelo menos 6 caracteres',
          authType: AuthType.email,
        );
      }

      // Valida nome se fornecido
      if (displayName != null) {
        final nameValidation = InputValidator.validate(
          displayName,
          ValidationType.userInput,
          maxLength: 100,
        );
        if (!nameValidation.isValid) {
          return FirebaseAuthResult.failure(
            'Nome inválido: ${nameValidation.error}',
            authType: AuthType.email,
          );
        }
        displayName = nameValidation.sanitizedValue as String;
      }

      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailValidation.sanitizedValue as String,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        return FirebaseAuthResult.failure(
          'Falha no registro',
          authType: AuthType.email,
        );
      }

      // Atualiza perfil se nome fornecido
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      // Envia email de verificação
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }

      final idToken = await user.getIdToken();

      _logger.i('Firebase email registration successful: ${user.email}');

      return FirebaseAuthResult.success(
        user: user,
        idToken: idToken,
        authType: AuthType.email,
      );
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth error: ${e.code} - ${e.message}');
      return FirebaseAuthResult.failure(
        _getFirebaseAuthErrorMessage(e.code),
        authType: AuthType.email,
      );
    } catch (e, stackTrace) {
      _logger.e('Email registration error', error: e, stackTrace: stackTrace);
      return FirebaseAuthResult.failure(
        'Erro interno no registro: $e',
        authType: AuthType.email,
      );
    }
  }

  /// Login anônimo
  Future<FirebaseAuthResult> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      final User? user = userCredential.user;

      if (user == null) {
        return FirebaseAuthResult.failure(
          'Falha na autenticação anônima',
          authType: AuthType.guest,
        );
      }

      final idToken = await user.getIdToken();

      _logger.i('Firebase anonymous Sign-In successful: ${user.uid}');

      return FirebaseAuthResult.success(
        user: user,
        idToken: idToken,
        authType: AuthType.guest,
      );
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth error: ${e.code} - ${e.message}');
      return FirebaseAuthResult.failure(
        _getFirebaseAuthErrorMessage(e.code),
        authType: AuthType.guest,
      );
    } catch (e, stackTrace) {
      _logger.e('Anonymous Sign-In error', error: e, stackTrace: stackTrace);
      return FirebaseAuthResult.failure(
        'Erro interno na autenticação: $e',
        authType: AuthType.guest,
      );
    }
  }

  // ========================================
  // MÉTODOS UTILITÁRIOS
  // ========================================

  /// Logout
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      _logger.i('Firebase sign out successful');
    } catch (e, stackTrace) {
      _logger.e('Sign out error', error: e, stackTrace: stackTrace);
    }
  }

  /// Usuário atual
  User? get currentUser => _auth.currentUser;

  /// Stream de mudanças de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Obtém token ID do usuário atual
  Future<String?> getCurrentUserIdToken() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      return await user.getIdToken();
    } catch (e) {
      _logger.w('Failed to get ID token: $e');
      return null;
    }
  }

  /// Atualiza token
  Future<void> refreshCurrentUser() async {
    try {
      await currentUser?.reload();
    } catch (e) {
      _logger.w('Failed to refresh user: $e');
    }
  }

  /// Valida usuário Google
  ValidationResult _validateGoogleUser(GoogleSignInAccount user) {
    if (user.email.isEmpty) {
      return ValidationResult.invalid('Email não fornecido');
    }

    final emailValidation =
        InputValidator.validate(user.email, ValidationType.email);
    if (!emailValidation.isValid) {
      return ValidationResult.invalid(
          'Email inválido: ${emailValidation.error}');
    }

    return ValidationResult.valid(user.email);
  }

  /// Valida credencial Apple
  ValidationResult _validateAppleCredential(
      AuthorizationCredentialAppleID credential) {
    if (credential.userIdentifier!.isEmpty) {
      return ValidationResult.invalid('ID do usuário não fornecido');
    }

    if (credential.identityToken == null) {
      return ValidationResult.invalid('Token de identidade não fornecido');
    }

    return ValidationResult.valid(credential.userIdentifier);
  }

  /// Converte códigos de erro Firebase para mensagens amigáveis
  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado';
      case 'wrong-password':
        return 'Senha incorreta';
      case 'email-already-in-use':
        return 'Email já está em uso';
      case 'weak-password':
        return 'Senha muito fraca';
      case 'invalid-email':
        return 'Email inválido';
      case 'user-disabled':
        return 'Conta desabilitada';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet';
      default:
        return 'Erro de autenticação: $code';
    }
  }

  /// Dispose
  void dispose() {
    _authStateSubscription?.cancel();
    _instance = null;
  }
}
