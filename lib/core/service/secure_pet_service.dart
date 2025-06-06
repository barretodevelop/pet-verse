// Imports necessários
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:petverse/core/network/rate_limiter.dart';
import 'package:petverse/core/providers/secure_provider.dart';

import '../../data/models/pet.dart';
import '../auth/auth_middleware.dart';
import '../config/app_config.dart';
import '../network/secure_http_client.dart';
import '../validation/input_validator.dart';

/// Serviço seguro para operações com pets
class SecurePetService {
  static final Logger _logger = Logger();

  final SecureHttpClient _httpClient;
  final AuthMiddleware _authMiddleware;
  final AppConfig _config;

  SecurePetService({
    required SecureHttpClient httpClient,
    required AuthMiddleware authMiddleware,
    required AppConfig config,
  })  : _httpClient = httpClient,
        _authMiddleware = authMiddleware,
        _config = config;

  // ========================================
  // GERAÇÃO SEGURA DE PETS
  // ========================================

  /// Gera um pet único usando IA com validação completa
  Future<PetGenerationResult> generateUniquePet({
    required String userPrompt,
    required String userId,
  }) async {
    try {
      _logger.d('Starting secure pet generation for user: $userId');

      // 1. Validação de entrada
      final promptValidation = await _validatePrompt(userPrompt);
      if (!promptValidation.isValid) {
        return PetGenerationResult.failure(
          'Prompt inválido: ${promptValidation.error}',
        );
      }

      // 2. Verificação de autenticação
      final isAuthenticated = await _authMiddleware.isAuthenticated();
      if (!isAuthenticated) {
        return PetGenerationResult.failure('Usuário não autenticado');
      }

      // 3. Verificação de rate limiting
      final canGenerate = await _checkGenerationRateLimit(userId);
      if (!canGenerate.allowed) {
        return PetGenerationResult.rateLimited(
          canGenerate.retryAfter ?? const Duration(minutes: 1),
          canGenerate.reason ?? 'Limite de gerações excedido',
        );
      }

      // 4. Preparação do prompt seguro
      final securePrompt = _buildSecurePrompt(promptValidation.sanitizedValue!);

      // 5. Geração via IA
      final aiResult = await _generateWithAI(securePrompt, userId);
      if (!aiResult.success) {
        return PetGenerationResult.failure(aiResult.error!);
      }

      // 6. Validação da resposta da IA
      final validatedResponse = await _validateAIResponse(aiResult.data!);
      if (!validatedResponse.isValid) {
        return PetGenerationResult.failure(
          'Resposta da IA inválida: ${validatedResponse.error}',
        );
      }

      // 7. Criação do pet
      final pet = await _createPetFromAIResponse(
        validatedResponse.sanitizedValue!,
        userId,
      );

      // 8. Registro da geração para auditoria
      await _logPetGeneration(userId, pet.id, securePrompt);

      _logger.i('Pet generated successfully: ${pet.id}');
      return PetGenerationResult.success(pet);
    } catch (e, stackTrace) {
      _logger.e('Pet generation failed', error: e, stackTrace: stackTrace);
      return PetGenerationResult.failure('Erro interno na geração: $e');
    }
  }

  /// Valida prompt do usuário
  Future<ValidationResult> _validatePrompt(String prompt) async {
    // Validação básica
    final basicValidation = InputValidator.validate(
      prompt,
      ValidationType.apiPrompt,
      maxLength: 500,
      minLength: 10,
    );

    if (!basicValidation.isValid) {
      return basicValidation;
    }

    // Validações específicas para geração de pets
    final sanitizedPrompt = basicValidation.sanitizedValue as String;

    // Verifica se não está tentando gerar conteúdo impróprio
    final inappropriatePatterns = [
      r'\b(nude|naked|sexual|explicit)\b',
      r'\b(violence|violent|kill|death)\b',
      r'\b(drugs|alcohol|smoking)\b',
      r'\b(hate|racist|offensive)\b',
    ];

    for (final pattern in inappropriatePatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(sanitizedPrompt)) {
        return ValidationResult.invalid(
          'Prompt contém conteúdo não permitido para geração de pets',
        );
      }
    }

    // Verifica se tem palavras-chave relacionadas a pets
    final petKeywords = [
      'pet',
      'animal',
      'dog',
      'cat',
      'cachorro',
      'gato',
      'fofo',
      'cute',
      'adorable',
      'friendly',
      'amigável'
    ];

    final hasPetKeywords = petKeywords.any(
      (keyword) => sanitizedPrompt.toLowerCase().contains(keyword),
    );

    if (!hasPetKeywords) {
      _logger.w('Prompt without pet keywords: $sanitizedPrompt');
      // Não bloqueia, mas adiciona contexto
    }

    return ValidationResult.valid(sanitizedPrompt);
  }

  /// Verifica rate limiting para geração
  Future<RequestAttemptResult> _checkGenerationRateLimit(String userId) async {
    const endpoint = '/ai/generate-pet';

    // Verifica limite global
    final globalLimit =
        await _httpClient.secureClient.rateLimiter.canMakeRequest(endpoint);

    if (!globalLimit.allowed) {
      return globalLimit;
    }

    // Verifica limite por usuário (mais restritivo)
    final userLimit = await _httpClient.secureClient.rateLimiter
        .canMakeRequest(endpoint, userId: userId);

    return userLimit;
  }

  /// Constrói prompt seguro para IA
  String _buildSecurePrompt(String userPrompt) {
    // Template seguro que previne prompt injection
    return '''
Generate a unique pet description based on the following request: "$userPrompt"

Requirements:
- Create a family-friendly pet
- Include: name, type, personality, appearance
- Keep description positive and appropriate
- Output as JSON with keys: name, type, description, personality_traits
- Limit description to 200 characters
- Do not include any external references or links

Pet description:''';
  }

  /// Gera pet usando IA
  Future<AIGenerationResult> _generateWithAI(
    String prompt,
    String userId,
  ) async {
    try {
      // Usa Gemini API através do cliente seguro
      final response = await _httpClient.geminiRequest<Map<String, dynamic>>(
        '/v1/models/gemini-pro:generateContent',
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ],
            }
          ],
          'generationConfig': {
            'temperature': 0.8,
            'maxOutputTokens': 1000,
            'topP': 0.8,
            'topK': 40,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
            },
          ],
        },
        userId: userId,
      );

      final responseData = response.data;
      if (responseData == null) {
        return AIGenerationResult.failure('Resposta vazia da IA');
      }

      // Extrai o conteúdo gerado
      final candidates = responseData['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        return AIGenerationResult.failure('Nenhum resultado gerado');
      }

      final firstCandidate = candidates.first as Map<String, dynamic>;
      final content = firstCandidate['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;

      if (parts == null || parts.isEmpty) {
        return AIGenerationResult.failure('Conteúdo vazio gerado');
      }

      final text = parts.first['text'] as String?;
      if (text == null || text.isEmpty) {
        return AIGenerationResult.failure('Texto vazio gerado');
      }

      return AIGenerationResult.success(text);
    } catch (e, stackTrace) {
      _logger.e('AI generation failed', error: e, stackTrace: stackTrace);
      return AIGenerationResult.failure('Falha na geração de IA: $e');
    }
  }

  /// Valida resposta da IA
  Future<ValidationResult> _validateAIResponse(String aiResponse) async {
    try {
      // Remove formatação markdown se presente
      String cleanResponse =
          aiResponse.replaceAll('```json', '').replaceAll('```', '').trim();

      // Tenta parsear como JSON
      Map<String, dynamic> petData;
      try {
        petData = jsonDecode(cleanResponse) as Map<String, dynamic>;
      } catch (e) {
        // Se não for JSON válido, tenta extrair informações do texto
        petData = _extractPetDataFromText(cleanResponse);
      }

      // Valida campos obrigatórios
      final requiredFields = ['name', 'type', 'description'];
      for (final field in requiredFields) {
        if (!petData.containsKey(field) || petData[field] == null) {
          return ValidationResult.invalid('Campo obrigatório ausente: $field');
        }
      }

      // Valida cada campo individualmente
      final validations = <String, ValidationResult>{};

      validations['name'] = InputValidator.validate(
        petData['name'].toString(),
        ValidationType.petName,
      );

      validations['type'] = InputValidator.validate(
        petData['type'].toString(),
        ValidationType.generic,
        maxLength: 50,
      );

      validations['description'] = InputValidator.validate(
        petData['description'].toString(),
        ValidationType.petDescription,
      );

      // Verifica se todas as validações passaram
      final errors = validations.entries
          .where((entry) => !entry.value.isValid)
          .map((entry) => '${entry.key}: ${entry.value.error}')
          .toList();

      if (errors.isNotEmpty) {
        return ValidationResult.invalid(
            'Campos inválidos: ${errors.join(', ')}');
      }

      // Constrói dados sanitizados
      final sanitizedData = {
        'name': validations['name']!.sanitizedValue,
        'type': validations['type']!.sanitizedValue,
        'description': validations['description']!.sanitizedValue,
        if (petData.containsKey('personality_traits'))
          'personality_traits': petData['personality_traits'],
      };

      return ValidationResult.valid(sanitizedData);
    } catch (e, stackTrace) {
      _logger.e('AI response validation failed',
          error: e, stackTrace: stackTrace);
      return ValidationResult.invalid('Erro na validação da resposta: $e');
    }
  }

  /// Extrai dados do pet de texto não estruturado
  Map<String, dynamic> _extractPetDataFromText(String text) {
    // Implementação simples para extrair informações quando não há JSON
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty);

    String? name, type, description;

    for (final line in lines) {
      final lower = line.toLowerCase();
      if (lower.contains('name') || lower.contains('nome')) {
        name = _extractValueFromLine(line);
      } else if (lower.contains('type') || lower.contains('tipo')) {
        type = _extractValueFromLine(line);
      } else if (lower.contains('description') || lower.contains('descrição')) {
        description = _extractValueFromLine(line);
      }
    }

    return {
      'name': name ?? 'Pet Único',
      'type': type ?? 'Animal Especial',
      'description': description ?? text.split('\n').first,
    };
  }

  /// Extrai valor de uma linha de texto
  String _extractValueFromLine(String line) {
    final colonIndex = line.indexOf(':');
    if (colonIndex != -1 && colonIndex < line.length - 1) {
      return line.substring(colonIndex + 1).trim();
    }
    return line.trim();
  }

  /// Cria pet a partir da resposta da IA
  Future<Pet> _createPetFromAIResponse(
    Map<String, dynamic> aiData,
    String userId,
  ) async {
    final petId =
        'ai_pet_${DateTime.now().millisecondsSinceEpoch}_${userId.hashCode}';

    // Gera imagem placeholder ou via IA
    final imageUrl = await _generatePetImage(aiData['description'] as String) ??
        'https://placehold.co/150x150/8A05BE/FFFFFF?text=🤖';

    return Pet(
      id: petId,
      name: aiData['name'] as String,
      imageUrl: imageUrl,
      type: aiData['type'] as String,
      description: aiData['description'] as String,
      isAdopted: false,
      generatedByUserId: userId,
      hunger: 80,
      happiness: 75,
      energy: 90,
      level: 1,
      xp: 0,
      xpToNextLevel: 100,
    );
  }

  /// Gera imagem do pet (opcional)
  Future<String?> _generatePetImage(String description) async {
    try {
      if (!_config.hasApiKey('imagen')) {
        _logger.w('Imagen API key not configured, using placeholder');
        return null;
      }

      // Implementação seria similar à geração de texto
      // Por simplicidade, retorna placeholder
      return null;
    } catch (e) {
      _logger.w('Pet image generation failed: $e');
      return null;
    }
  }

  /// Registra geração para auditoria
  Future<void> _logPetGeneration(
    String userId,
    String petId,
    String prompt,
  ) async {
    try {
      await _httpClient.backendRequest<void>(
        '/api/v1/audit/pet-generation',
        method: 'POST',
        data: {
          'userId': userId,
          'petId': petId,
          'prompt': prompt,
          'timestamp': DateTime.now().toIso8601String(),
          'source': 'mobile_app',
        },
        userId: userId,
      );
    } catch (e) {
      _logger.w('Failed to log pet generation: $e');
      // Não propaga erro pois não é crítico
    }
  }

  // ========================================
  // OPERAÇÕES DE PET SEGURAS
  // ========================================

  /// Alimenta pet com validações
  Future<PetActionResult> feedPet({
    required String petId,
    required String userId,
  }) async {
    return _executePetAction(
      action: 'feed',
      petId: petId,
      userId: userId,
      cost: 10, // coins
      effects: {'hunger': 20, 'happiness': 5},
    );
  }

  /// Brinca com pet
  Future<PetActionResult> playWithPet({
    required String petId,
    required String userId,
  }) async {
    return _executePetAction(
      action: 'play',
      petId: petId,
      userId: userId,
      cost: 5, // coins
      effects: {'hunger': -10, 'happiness': 25, 'energy': -15},
      xpReward: 10,
    );
  }

  /// Executa ação genérica no pet
  Future<PetActionResult> _executePetAction({
    required String action,
    required String petId,
    required String userId,
    required int cost,
    required Map<String, int> effects,
    int xpReward = 0,
  }) async {
    try {
      // Validações
      final petValidation =
          InputValidator.validate(petId, ValidationType.generic);
      final userValidation =
          InputValidator.validate(userId, ValidationType.generic);

      if (!petValidation.isValid || !userValidation.isValid) {
        return PetActionResult.failure('IDs inválidos');
      }

      // Verifica autenticação
      final isAuthenticated = await _authMiddleware.isAuthenticated();
      if (!isAuthenticated) {
        return PetActionResult.failure('Usuário não autenticado');
      }

      // Verifica rate limiting
      final endpoint = '/pet/$action';
      final canAct = await _httpClient.secureClient.rateLimiter
          .canMakeRequest(endpoint, userId: userId);

      if (!canAct.allowed) {
        return PetActionResult.rateLimited(
          canAct.retryAfter ?? const Duration(minutes: 1),
        );
      }

      // Executa ação
      final response = await _httpClient.backendRequest<Map<String, dynamic>>(
        '/api/v1/pets/$petId/actions',
        method: 'POST',
        data: {
          'action': action,
          'cost': cost,
          'effects': effects,
          'xpReward': xpReward,
          'timestamp': DateTime.now().toIso8601String(),
        },
        userId: userId,
      );

      final result = response.data;
      if (result?['success'] == true) {
        return PetActionResult.success(result!);
      } else {
        return PetActionResult.failure(
          result?['message'] as String? ?? 'Ação falhou',
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Pet action failed', error: e, stackTrace: stackTrace);
      return PetActionResult.failure('Erro interno: $e');
    }
  }
}

// ========================================
// CLASSES DE RESULTADO
// ========================================

/// Resultado da geração de pet
class PetGenerationResult {
  final bool success;
  final Pet? pet;
  final String? error;
  final Duration? retryAfter;
  final bool isRateLimited;

  const PetGenerationResult({
    required this.success,
    this.pet,
    this.error,
    this.retryAfter,
    this.isRateLimited = false,
  });

  factory PetGenerationResult.success(Pet pet) {
    return PetGenerationResult(success: true, pet: pet);
  }

  factory PetGenerationResult.failure(String error) {
    return PetGenerationResult(success: false, error: error);
  }

  factory PetGenerationResult.rateLimited(Duration retryAfter, String error) {
    return PetGenerationResult(
      success: false,
      error: error,
      retryAfter: retryAfter,
      isRateLimited: true,
    );
  }
}

/// Resultado da geração de IA
class AIGenerationResult {
  final bool success;
  final String? data;
  final String? error;

  const AIGenerationResult({
    required this.success,
    this.data,
    this.error,
  });

  factory AIGenerationResult.success(String data) {
    return AIGenerationResult(success: true, data: data);
  }

  factory AIGenerationResult.failure(String error) {
    return AIGenerationResult(success: false, error: error);
  }
}

/// Resultado de ação no pet
class PetActionResult {
  final bool success;
  final Map<String, dynamic>? data;
  final String? error;
  final Duration? retryAfter;
  final bool isRateLimited;

  const PetActionResult({
    required this.success,
    this.data,
    this.error,
    this.retryAfter,
    this.isRateLimited = false,
  });

  factory PetActionResult.success(Map<String, dynamic> data) {
    return PetActionResult(success: true, data: data);
  }

  factory PetActionResult.failure(String error) {
    return PetActionResult(success: false, error: error);
  }

  factory PetActionResult.rateLimited(Duration retryAfter) {
    return PetActionResult(
      success: false,
      error: 'Rate limit excedido',
      retryAfter: retryAfter,
      isRateLimited: true,
    );
  }
}

// ========================================
// PROVIDER
// ========================================

/// Provider para SecurePetService
final securePetServiceProvider = Provider<SecurePetService>((ref) {
  final httpClient = ref.watch(secureHttpClientProvider);
  final authMiddleware = ref.watch(authMiddlewareProvider);
  final config = ref.watch(appConfigProvider);

  return SecurePetService(
    httpClient: httpClient,
    authMiddleware: authMiddleware,
    config: config,
  );
});
