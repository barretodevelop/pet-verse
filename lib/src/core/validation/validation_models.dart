// lib/src/core/validation/validation_models.dart
// NOVO - Models centralizados para validações de negócio

import 'package:flutter/foundation.dart';

/// Resultado de uma validação
@immutable
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? errorCode;
  final Map<String, dynamic>? metadata;

  const ValidationResult({
    required this.isValid,
    this.errorMessage,
    this.errorCode,
    this.metadata,
  });

  const ValidationResult.valid() : this(isValid: true);

  const ValidationResult.invalid({
    required String message,
    String? code,
    Map<String, dynamic>? metadata,
  }) : this(
          isValid: false,
          errorMessage: message,
          errorCode: code,
          metadata: metadata,
        );

  @override
  String toString() => isValid
      ? 'ValidationResult.valid'
      : 'ValidationResult.invalid($errorMessage)';
}

/// Contexto para validações que precisam de dados externos
@immutable
class ValidationContext {
  final String? currentUserId;
  final DateTime currentTime;
  final Map<String, dynamic> data;

  const ValidationContext({
    this.currentUserId,
    required this.currentTime,
    this.data = const {},
  });

  ValidationContext copyWith({
    String? currentUserId,
    DateTime? currentTime,
    Map<String, dynamic>? data,
  }) {
    return ValidationContext(
      currentUserId: currentUserId ?? this.currentUserId,
      currentTime: currentTime ?? this.currentTime,
      data: data ?? this.data,
    );
  }
}

/// Validações para Pet
class PetValidations {
  static const int maxNameLength = 50;
  static const int minNameLength = 2;

  static ValidationResult validateName(String name) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return const ValidationResult.invalid(
        message: 'Nome do pet é obrigatório',
        code: 'PET_NAME_REQUIRED',
      );
    }

    if (trimmedName.length < minNameLength) {
      return const ValidationResult.invalid(
        message: 'Nome deve ter pelo menos $minNameLength caracteres',
        code: 'PET_NAME_TOO_SHORT',
      );
    }

    if (trimmedName.length > maxNameLength) {
      return const ValidationResult.invalid(
        message: 'Nome deve ter no máximo $maxNameLength caracteres',
        code: 'PET_NAME_TOO_LONG',
      );
    }

    // Verificar caracteres inválidos
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(trimmedName)) {
      return const ValidationResult.invalid(
        message: 'Nome pode conter apenas letras e espaços',
        code: 'PET_NAME_INVALID_CHARS',
      );
    }

    return const ValidationResult.valid();
  }

  static ValidationResult validateSpecies(String species) {
    const validSpecies = ['Cachorro', 'Gato', 'Pássaro', 'Peixe', 'Coelho'];

    if (!validSpecies.contains(species)) {
      return ValidationResult.invalid(
        message: 'Espécie deve ser uma das opções: ${validSpecies.join(', ')}',
        code: 'PET_SPECIES_INVALID',
        metadata: const {'validSpecies': validSpecies},
      );
    }

    return const ValidationResult.valid();
  }

  static ValidationResult validateAge(int age) {
    if (age < 0) {
      return const ValidationResult.invalid(
        message: 'Idade não pode ser negativa',
        code: 'PET_AGE_NEGATIVE',
      );
    }

    if (age > 30) {
      return const ValidationResult.invalid(
        message: 'Idade máxima é 30 anos',
        code: 'PET_AGE_TOO_HIGH',
      );
    }

    return const ValidationResult.valid();
  }

  static ValidationResult validateImageUrl(String imageUrl) {
    if (imageUrl.trim().isEmpty) {
      return const ValidationResult.invalid(
        message: 'URL da imagem é obrigatória',
        code: 'PET_IMAGE_REQUIRED',
      );
    }

    final uri = Uri.tryParse(imageUrl);
    if (uri == null || !uri.hasScheme) {
      return const ValidationResult.invalid(
        message: 'URL da imagem inválida',
        code: 'PET_IMAGE_INVALID_URL',
      );
    }

    return const ValidationResult.valid();
  }
}

/// Validações para Adoption Request
class AdoptionValidations {
  static const int exactPetCount = 3;
  static const int maxRequestLifeDays = 7;
  static const int minFriendCodeLength = 6;
  static const int maxFriendCodeLength = 12;

  static ValidationResult validatePetSelection(List<String> petIds) {
    if (petIds.isEmpty) {
      return const ValidationResult.invalid(
        message: 'Selecione pelo menos um pet',
        code: 'ADOPTION_NO_PETS_SELECTED',
      );
    }

    if (petIds.length > exactPetCount) {
      return const ValidationResult.invalid(
        message: 'Máximo de $exactPetCount pets permitidos',
        code: 'ADOPTION_TOO_MANY_PETS',
        metadata: {'maxCount': exactPetCount},
      );
    }

    // Verificar duplicatas
    final uniquePets = petIds.toSet();
    if (uniquePets.length != petIds.length) {
      return const ValidationResult.invalid(
        message: 'Pets duplicados não são permitidos',
        code: 'ADOPTION_DUPLICATE_PETS',
      );
    }

    // Verificar IDs vazios
    if (petIds.any((id) => id.trim().isEmpty)) {
      return const ValidationResult.invalid(
        message: 'IDs de pets inválidos encontrados',
        code: 'ADOPTION_INVALID_PET_IDS',
      );
    }

    return const ValidationResult.valid();
  }

  static ValidationResult validateFriendCode(String friendCode) {
    final trimmedCode = friendCode.trim();

    if (trimmedCode.isEmpty) {
      return const ValidationResult.invalid(
        message: 'Código de amigo é obrigatório',
        code: 'FRIEND_CODE_REQUIRED',
      );
    }

    if (trimmedCode.length < minFriendCodeLength) {
      return const ValidationResult.invalid(
        message: 'Código deve ter pelo menos $minFriendCodeLength caracteres',
        code: 'FRIEND_CODE_TOO_SHORT',
      );
    }

    if (trimmedCode.length > maxFriendCodeLength) {
      return const ValidationResult.invalid(
        message: 'Código deve ter no máximo $maxFriendCodeLength caracteres',
        code: 'FRIEND_CODE_TOO_LONG',
      );
    }

    // Verificar formato (alfanumérico)
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(trimmedCode.toUpperCase())) {
      return const ValidationResult.invalid(
        message: 'Código deve conter apenas letras e números',
        code: 'FRIEND_CODE_INVALID_FORMAT',
      );
    }

    return const ValidationResult.valid();
  }

  static ValidationResult validateRequestAge(
    DateTime createdAt,
    ValidationContext context,
  ) {
    final daysSinceCreation = context.currentTime.difference(createdAt).inDays;

    if (daysSinceCreation > maxRequestLifeDays) {
      return ValidationResult.invalid(
        message: 'Solicitação expirou (máximo $maxRequestLifeDays dias)',
        code: 'ADOPTION_REQUEST_EXPIRED',
        metadata: {
          'maxDays': maxRequestLifeDays,
          'daysSinceCreation': daysSinceCreation,
        },
      );
    }

    return const ValidationResult.valid();
  }

  static ValidationResult validateUserEligibility(
    String userId,
    ValidationContext context,
  ) {
    if (userId.trim().isEmpty) {
      return const ValidationResult.invalid(
        message: 'ID do usuário inválido',
        code: 'USER_ID_INVALID',
      );
    }

    if (context.currentUserId == null) {
      return const ValidationResult.invalid(
        message: 'Usuário não autenticado',
        code: 'USER_NOT_AUTHENTICATED',
      );
    }

    if (userId == context.currentUserId) {
      return const ValidationResult.invalid(
        message: 'Não é possível adotar seu próprio pet',
        code: 'ADOPTION_SELF_ADOPTION',
      );
    }

    return const ValidationResult.valid();
  }
}

/// Validações para User
class UserValidations {
  static const int maxUsernameLength = 30;
  static const int minUsernameLength = 3;

  static ValidationResult validateUsername(String username) {
    final trimmedUsername = username.trim();

    if (trimmedUsername.isEmpty) {
      return const ValidationResult.invalid(
        message: 'Nome de usuário é obrigatório',
        code: 'USERNAME_REQUIRED',
      );
    }

    if (trimmedUsername.length < minUsernameLength) {
      return const ValidationResult.invalid(
        message: 'Nome deve ter pelo menos $minUsernameLength caracteres',
        code: 'USERNAME_TOO_SHORT',
      );
    }

    if (trimmedUsername.length > maxUsernameLength) {
      return const ValidationResult.invalid(
        message: 'Nome deve ter no máximo $maxUsernameLength caracteres',
        code: 'USERNAME_TOO_LONG',
      );
    }

    // Verificar caracteres válidos (alfanumérico + alguns especiais)
    if (!RegExp(r'^[a-zA-Z0-9_.-]+$').hasMatch(trimmedUsername)) {
      return const ValidationResult.invalid(
        message: 'Nome pode conter apenas letras, números, _, . e -',
        code: 'USERNAME_INVALID_CHARS',
      );
    }

    return const ValidationResult.valid();
  }

  static ValidationResult validateEmail(String email) {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      return const ValidationResult.invalid(
        message: 'E-mail é obrigatório',
        code: 'EMAIL_REQUIRED',
      );
    }

    // Regex básico para e-mail
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(trimmedEmail)) {
      return const ValidationResult.invalid(
        message: 'Formato de e-mail inválido',
        code: 'EMAIL_INVALID_FORMAT',
      );
    }

    return const ValidationResult.valid();
  }
}

/// Validações de Sistema
class SystemValidations {
  static ValidationResult validatePageSize(int pageSize) {
    if (pageSize <= 0) {
      return const ValidationResult.invalid(
        message: 'Tamanho da página deve ser positivo',
        code: 'PAGE_SIZE_INVALID',
      );
    }

    if (pageSize > 100) {
      return const ValidationResult.invalid(
        message: 'Tamanho máximo da página é 100',
        code: 'PAGE_SIZE_TOO_LARGE',
      );
    }

    return const ValidationResult.valid();
  }

  static ValidationResult validateId(String id, String fieldName) {
    final trimmedId = id.trim();

    if (trimmedId.isEmpty) {
      return ValidationResult.invalid(
        message: '$fieldName é obrigatório',
        code: 'ID_REQUIRED',
        metadata: {'fieldName': fieldName},
      );
    }

    // Verificar formato básico de ID
    if (trimmedId.length < 10) {
      return ValidationResult.invalid(
        message: '$fieldName deve ter pelo menos 10 caracteres',
        code: 'ID_TOO_SHORT',
        metadata: {'fieldName': fieldName},
      );
    }

    return const ValidationResult.valid();
  }
}

/// Helper para combinar múltiplas validações
class ValidationHelper {
  static ValidationResult combineResults(List<ValidationResult> results) {
    final invalid = results.where((r) => !r.isValid).toList();

    if (invalid.isEmpty) {
      return const ValidationResult.valid();
    }

    // Retornar o primeiro erro encontrado
    final firstError = invalid.first;

    // Se há múltiplos erros, combinar mensagens
    if (invalid.length > 1) {
      final messages =
          invalid.map((r) => r.errorMessage).where((m) => m != null).join('; ');

      return ValidationResult.invalid(
        message: messages,
        code: 'MULTIPLE_VALIDATION_ERRORS',
        metadata: {
          'errorCount': invalid.length,
          'errors': invalid
              .map((r) => {
                    'message': r.errorMessage,
                    'code': r.errorCode,
                  })
              .toList(),
        },
      );
    }

    return firstError;
  }

  static bool areAllValid(List<ValidationResult> results) {
    return results.every((r) => r.isValid);
  }

  static List<String> getErrorMessages(List<ValidationResult> results) {
    return results
        .where((r) => !r.isValid)
        .map((r) => r.errorMessage)
        .where((m) => m != null)
        .cast<String>()
        .toList();
  }
}
