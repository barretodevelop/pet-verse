// lib/src/features/auth/domain/entities/user_pet_status.dart
// NOVO - Model robusto para status do usuário e pets

import 'package:flutter/foundation.dart';

@immutable
class UserPetStatus {
  final UserPetStatusType type;
  final List<String> petIds;
  final String? currentActivePetId;
  final bool hasActiveAdoptionRequest;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const UserPetStatus._({
    required this.type,
    this.petIds = const [],
    this.currentActivePetId,
    this.hasActiveAdoptionRequest = false,
    this.errorMessage,
    this.lastUpdated,
  });

  // Factory constructors para diferentes estados
  factory UserPetStatus.unauthenticated() {
    return const UserPetStatus._(
      type: UserPetStatusType.unauthenticated,
    );
  }

  factory UserPetStatus.noPets() {
    return UserPetStatus._(
      type: UserPetStatusType.noPets,
      lastUpdated: DateTime.now(),
    );
  }

  factory UserPetStatus.hasPets(List<String> petIds, {String? activePetId}) {
    return UserPetStatus._(
      type: UserPetStatusType.hasPets,
      petIds: petIds,
      currentActivePetId: activePetId ?? petIds.first,
      lastUpdated: DateTime.now(),
    );
  }

  factory UserPetStatus.pendingAdoption({bool hasActiveRequest = false}) {
    return UserPetStatus._(
      type: UserPetStatusType.pendingAdoption,
      hasActiveAdoptionRequest: hasActiveRequest,
      lastUpdated: DateTime.now(),
    );
  }

  factory UserPetStatus.error(String message) {
    return UserPetStatus._(
      type: UserPetStatusType.error,
      errorMessage: message,
      lastUpdated: DateTime.now(),
    );
  }

  factory UserPetStatus.loading() {
    return const UserPetStatus._(
      type: UserPetStatusType.loading,
    );
  }

  // Factory para criar a partir de dados do Firestore
  factory UserPetStatus.fromUserData(
    Map<String, dynamic> userData,
    List<String> petIds,
  ) {
    if (petIds.isEmpty) {
      return UserPetStatus.noPets();
    }

    final activePetId = userData['currentActivePetId'] as String?;
    final hasActiveRequest =
        userData['hasActiveAdoptionRequest'] as bool? ?? false;

    if (hasActiveRequest) {
      return UserPetStatus.pendingAdoption(hasActiveRequest: true);
    }

    return UserPetStatus.hasPets(
      petIds,
      activePetId: activePetId,
    );
  }

  // Getters de conveniência
  bool get isAuthenticated => type != UserPetStatusType.unauthenticated;
  bool get hasPets => type == UserPetStatusType.hasPets && petIds.isNotEmpty;
  bool get canAdopt =>
      type == UserPetStatusType.noPets && !hasActiveAdoptionRequest;
  bool get isLoading => type == UserPetStatusType.loading;
  bool get hasError => type == UserPetStatusType.error;
  bool get isPendingAdoption => type == UserPetStatusType.pendingAdoption;

  // Métodos de conveniência para UI
  String get displayMessage {
    switch (type) {
      case UserPetStatusType.unauthenticated:
        return 'Usuário não autenticado';
      case UserPetStatusType.noPets:
        return 'Nenhum pet adotado ainda';
      case UserPetStatusType.hasPets:
        return 'Você tem ${petIds.length} pet(s)';
      case UserPetStatusType.pendingAdoption:
        return 'Adoção em andamento';
      case UserPetStatusType.loading:
        return 'Carregando...';
      case UserPetStatusType.error:
        return errorMessage ?? 'Erro desconhecido';
    }
  }

  // CopyWith para atualizações imutáveis
  UserPetStatus copyWith({
    UserPetStatusType? type,
    List<String>? petIds,
    String? currentActivePetId,
    bool? hasActiveAdoptionRequest,
    String? errorMessage,
    DateTime? lastUpdated,
    bool clearCurrentActivePetId = false,
    bool clearErrorMessage = false,
  }) {
    return UserPetStatus._(
      type: type ?? this.type,
      petIds: petIds ?? this.petIds,
      currentActivePetId: clearCurrentActivePetId
          ? null
          : currentActivePetId ?? this.currentActivePetId,
      hasActiveAdoptionRequest:
          hasActiveAdoptionRequest ?? this.hasActiveAdoptionRequest,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPetStatus &&
        other.type == type &&
        listEquals(other.petIds, petIds) &&
        other.currentActivePetId == currentActivePetId &&
        other.hasActiveAdoptionRequest == hasActiveAdoptionRequest &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      type,
      Object.hashAll(petIds),
      currentActivePetId,
      hasActiveAdoptionRequest,
      errorMessage,
    );
  }

  @override
  String toString() {
    return 'UserPetStatus(type: $type, petIds: $petIds, active: $currentActivePetId, pending: $hasActiveAdoptionRequest)';
  }
}

enum UserPetStatusType {
  unauthenticated,
  loading,
  noPets,
  hasPets,
  pendingAdoption,
  error,
}
