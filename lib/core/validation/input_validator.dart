import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';
import 'package:validators/validators.dart';

/// Resultado de validação
class ValidationResult {
  final bool isValid;
  final String? error;
  final dynamic sanitizedValue;

  const ValidationResult({
    required this.isValid,
    this.error,
    this.sanitizedValue,
  });

  factory ValidationResult.valid(dynamic sanitizedValue) {
    return ValidationResult(
      isValid: true,
      sanitizedValue: sanitizedValue,
    );
  }

  factory ValidationResult.invalid(String error) {
    return ValidationResult(
      isValid: false,
      error: error,
    );
  }
}

/// Tipos de validação disponíveis
enum ValidationType {
  petName,
  petDescription,
  userInput,
  apiPrompt,
  email,
  url,
  fileName,
  generic,
}

/// Sistema robusto de validação e sanitização de entrada
class InputValidator {
  static final Logger _logger = Logger();

  // Padrões de segurança
  static final RegExp _sqlInjectionPattern = RegExp(
    r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION|SCRIPT)\b)|[;\"\"\\]',
    caseSensitive: false,
  );

  static final RegExp _xssPattern = RegExp(
    r'<[^>]*script[^>]*>|javascript:|on\w+\s*=|<[^>]*>',
    caseSensitive: false,
  );

  static final RegExp _commandInjectionPattern = RegExp(
    r'[;&|`$(){}\[\]<>]',
  );

  static final RegExp _pathTraversalPattern = RegExp(
    r'\.\.\/|\.\.\\|\.\.|%2e%2e|%252e%252e',
    caseSensitive: false,
  );

  // Listas de palavras proibidas
  static const List<String> _prohibitedWords = [
    'script',
    'javascript',
    'eval',
    'exec',
    'system',
    'alert',
    'prompt',
    'confirm',
    'document',
    'window',
    'drop',
    'delete',
    'truncate',
    'update',
    'insert',
  ];

  static const List<String> _profanityWords = [
    // Adicionar palavras impróprias conforme necessário
    'spam', 'test_profanity',
  ];

  /// Valida e sanitiza entrada baseada no tipo
  static ValidationResult validate(
    String input,
    ValidationType type, {
    int? maxLength,
    int? minLength,
    bool allowEmpty = false,
    Map<String, dynamic>? customRules,
  }) {
    try {
      // Log de entrada (sem informações sensíveis)
      _logger.d('Validando entrada do tipo: ${type.name}');

      // Verifica se está vazio
      if (input.trim().isEmpty) {
        if (allowEmpty) {
          return ValidationResult.valid('');
        }
        return ValidationResult.invalid('Campo não pode estar vazio');
      }

      // Validação de comprimento básica
      if (minLength != null && input.length < minLength) {
        return ValidationResult.invalid(
            'Deve ter pelo menos $minLength caracteres');
      }

      if (maxLength != null && input.length > maxLength) {
        return ValidationResult.invalid(
            'Não pode ter mais que $maxLength caracteres');
      }

      // Verifica padrões de segurança perigosos
      final securityCheck = _checkSecurityPatterns(input);
      if (!securityCheck.isValid) {
        return securityCheck;
      }

      // Validação específica por tipo
      switch (type) {
        case ValidationType.petName:
          return _validatePetName(input);
        case ValidationType.petDescription:
          return _validatePetDescription(input);
        case ValidationType.userInput:
          return _validateUserInput(input);
        case ValidationType.apiPrompt:
          return _validateApiPrompt(input);
        case ValidationType.email:
          return _validateEmail(input);
        case ValidationType.url:
          return _validateUrl(input);
        case ValidationType.fileName:
          return _validateFileName(input);
        case ValidationType.generic:
          return _validateGeneric(input);
      }
    } catch (e, stackTrace) {
      _logger.e('Erro na validação', error: e, stackTrace: stackTrace);
      return ValidationResult.invalid('Erro interno de validação');
    }
  }

  /// Verifica padrões de segurança perigosos
  static ValidationResult _checkSecurityPatterns(String input) {
    // SQL Injection
    if (_sqlInjectionPattern.hasMatch(input)) {
      _logger.w('Tentativa de SQL injection detectada');
      return ValidationResult.invalid(
          'Entrada contém caracteres não permitidos');
    }

    // XSS
    if (_xssPattern.hasMatch(input)) {
      _logger.w('Tentativa de XSS detectada');
      return ValidationResult.invalid('Entrada contém código não permitido');
    }

    // Command Injection
    if (_commandInjectionPattern.hasMatch(input)) {
      _logger.w('Tentativa de command injection detectada');
      return ValidationResult.invalid(
          'Entrada contém caracteres especiais não permitidos');
    }

    // Path Traversal
    if (_pathTraversalPattern.hasMatch(input)) {
      _logger.w('Tentativa de path traversal detectada');
      return ValidationResult.invalid(
          'Entrada contém padrão de navegação não permitido');
    }

    // Palavras proibidas
    final lowerInput = input.toLowerCase();
    for (final word in _prohibitedWords) {
      if (lowerInput.contains(word)) {
        _logger.w('Palavra proibida detectada: $word');
        return ValidationResult.invalid(
            'Entrada contém conteúdo não permitido');
      }
    }

    return ValidationResult.valid(input);
  }

  /// Valida nome de pet
  static ValidationResult _validatePetName(String input) {
    final sanitized = _sanitizeBasic(input);

    // Regras específicas para nome de pet
    if (sanitized.length < 2) {
      return ValidationResult.invalid('Nome deve ter pelo menos 2 caracteres');
    }

    if (sanitized.length > 20) {
      return ValidationResult.invalid(
          'Nome não pode ter mais que 20 caracteres');
    }

    // Apenas letras, números e alguns caracteres especiais
    final petNamePattern = RegExp(r'^[a-zA-ZÀ-ÿ0-9\s\-_]+$');
    if (!petNamePattern.hasMatch(sanitized)) {
      return ValidationResult.invalid('Nome contém caracteres não permitidos');
    }

    // Verifica profanidade
    if (_containsProfanity(sanitized)) {
      return ValidationResult.invalid('Nome contém conteúdo impróprio');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Valida descrição de pet
  static ValidationResult _validatePetDescription(String input) {
    final sanitized = _sanitizeRichText(input);

    if (sanitized.length < 10) {
      return ValidationResult.invalid(
          'Descrição deve ter pelo menos 10 caracteres');
    }

    if (sanitized.length > 500) {
      return ValidationResult.invalid(
          'Descrição não pode ter mais que 500 caracteres');
    }

    // Verifica profanidade
    if (_containsProfanity(sanitized)) {
      return ValidationResult.invalid('Descrição contém conteúdo impróprio');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Valida entrada de usuário geral
  static ValidationResult _validateUserInput(String input) {
    final sanitized = _sanitizeBasic(input);

    if (sanitized.length > 1000) {
      return ValidationResult.invalid('Entrada muito longa');
    }

    // Verifica profanidade
    if (_containsProfanity(sanitized)) {
      return ValidationResult.invalid('Entrada contém conteúdo impróprio');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Valida prompt para API
  static ValidationResult _validateApiPrompt(String input) {
    final sanitized = _sanitizeApiPrompt(input);

    if (sanitized.length < 5) {
      return ValidationResult.invalid('Prompt muito curto');
    }

    if (sanitized.length > 2000) {
      return ValidationResult.invalid('Prompt muito longo');
    }

    // Verifica se contém instruções maliciosas
    final maliciousPrompts = [
      'ignore previous instructions',
      'forget everything',
      'act as',
      'pretend to be',
      'system prompt',
      'jailbreak',
    ];

    final lowerSanitized = sanitized.toLowerCase();
    for (final malicious in maliciousPrompts) {
      if (lowerSanitized.contains(malicious)) {
        _logger.w('Prompt malicioso detectado: $malicious');
        return ValidationResult.invalid(
            'Prompt contém instruções não permitidas');
      }
    }

    return ValidationResult.valid(sanitized);
  }

  /// Valida email
  static ValidationResult _validateEmail(String input) {
    final sanitized = input.trim().toLowerCase();

    if (!isEmail(sanitized)) {
      return ValidationResult.invalid('Email inválido');
    }

    if (sanitized.length > 254) {
      return ValidationResult.invalid('Email muito longo');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Valida URL
  static ValidationResult _validateUrl(String input) {
    final sanitized = input.trim();

    if (!isURL(sanitized)) {
      return ValidationResult.invalid('URL inválida');
    }

    // Verifica se é HTTPS em produção
    if (!sanitized.startsWith('https://') &&
        !sanitized.startsWith('http://localhost')) {
      return ValidationResult.invalid('Apenas URLs HTTPS são permitidas');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Valida nome de arquivo
  static ValidationResult _validateFileName(String input) {
    final sanitized = _sanitizeFileName(input);

    if (sanitized.isEmpty) {
      return ValidationResult.invalid('Nome de arquivo inválido');
    }

    // Verifica extensões permitidas
    final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final hasValidExtension =
        allowedExtensions.any((ext) => sanitized.toLowerCase().endsWith(ext));

    if (!hasValidExtension) {
      return ValidationResult.invalid('Tipo de arquivo não permitido');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Validação genérica
  static ValidationResult _validateGeneric(String input) {
    final sanitized = _sanitizeBasic(input);

    if (sanitized.length > 5000) {
      return ValidationResult.invalid('Entrada muito longa');
    }

    return ValidationResult.valid(sanitized);
  }

  // ========================================
  // MÉTODOS DE SANITIZAÇÃO
  // ========================================

  /// Sanitização básica
  static String _sanitizeBasic(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ') // Múltiplos espaços para um
        .replaceAll(RegExp(r'[<>]'), '') // Remove < e >
        .replaceAll(RegExp(r'[&]'), '&amp;') // Escapa &
        .replaceAll(RegExp(r'["]'), '&quot;') // Escapa aspas
        .replaceAll(RegExp(r'[\]'), '&#x27;'); // Escapa aspas simples
  }

  /// Sanitização para texto rico
  static String _sanitizeRichText(String input) {
    return input
        .trim()
        .replaceAll(
            RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Sanitização para prompts de API
  static String _sanitizeApiPrompt(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>]'), '') // Remove brackets
        .replaceAll(RegExp(r'[\[\]]'), '') // Remove square brackets
        .replaceAll(RegExp(r'[{}]'), '') // Remove curly brackets
        .replaceAll(RegExp(r'\s+'), ' '); // Normaliza espaços
  }

  /// Sanitização para nome de arquivo
  static String _sanitizeFileName(String input) {
    return input
        .trim()
        .replaceAll(
            RegExp(r'[^a-zA-Z0-9._-]'), '_') // Apenas caracteres seguros
        .replaceAll(RegExp(r'_{2,}'), '_') // Remove underscores múltiplos
        .replaceAll(
            RegExp(r'^[._-]+|[._-]+$'), ''); // Remove caracteres nas pontas
  }

  /// Verifica profanidade
  static bool _containsProfanity(String input) {
    final lowerInput = input.toLowerCase();
    return _profanityWords.any((word) => lowerInput.contains(word));
  }

  // ========================================
  // MÉTODOS UTILITÁRIOS
  // ========================================

  /// Gera hash da entrada para logging seguro
  static String _hashInput(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 8); // Apenas primeiros 8 caracteres
  }

  /// Validação em lote
  static Map<String, ValidationResult> validateBatch(
    Map<String, String> inputs,
    Map<String, ValidationType> types,
  ) {
    final results = <String, ValidationResult>{};

    for (final entry in inputs.entries) {
      final key = entry.key;
      final value = entry.value;
      final type = types[key] ?? ValidationType.generic;

      results[key] = validate(value, type);
    }

    return results;
  }

  /// Verifica se todos os resultados são válidos
  static bool areAllValid(Map<String, ValidationResult> results) {
    return results.values.every((result) => result.isValid);
  }

  /// Extrai valores sanitizados de um mapa de resultados
  static Map<String, dynamic> extractSanitizedValues(
    Map<String, ValidationResult> results,
  ) {
    final sanitized = <String, dynamic>{};

    for (final entry in results.entries) {
      if (entry.value.isValid) {
        sanitized[entry.key] = entry.value.sanitizedValue;
      }
    }

    return sanitized;
  }

  /// Extrai erros de um mapa de resultados
  static Map<String, String> extractErrors(
    Map<String, ValidationResult> results,
  ) {
    final errors = <String, String>{};

    for (final entry in results.entries) {
      if (!entry.value.isValid && entry.value.error != null) {
        errors[entry.key] = entry.value.error!;
      }
    }

    return errors;
  }
}

/// Extension para facilitar validação
extension StringValidation on String {
  ValidationResult validate(ValidationType type) {
    return InputValidator.validate(this, type);
  }

  bool get isValidPetName {
    return InputValidator.validate(this, ValidationType.petName).isValid;
  }

  bool get isValidEmail {
    return InputValidator.validate(this, ValidationType.email).isValid;
  }

  bool get isValidUrl {
    return InputValidator.validate(this, ValidationType.url).isValid;
  }
}
