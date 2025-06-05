import 'pet.dart';

/// Status possíveis para uma solicitação de adoção
enum AdoptionRequestStatus {
  pending('pending'),
  completed('completed'),
  expired('expired'),
  cancelled('cancelled');

  const AdoptionRequestStatus(this.value);
  final String value;

  static AdoptionRequestStatus fromString(String value) {
    return AdoptionRequestStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AdoptionRequestStatus.pending,
    );
  }
}

/// Modelo de dados para representar uma Solicitação de Adoção
class AdoptionRequest {
  final String id;
  final String creatorUserId;
  final List<Pet> petsInRequest;
  final int daysLeft;
  final DateTime createdAt;
  final DateTime expiresAt;
  AdoptionRequestStatus status;
  String? joinerUserId;
  String? chosenPetId;

  AdoptionRequest({
    required this.id,
    required this.creatorUserId,
    required this.petsInRequest,
    required this.daysLeft,
    DateTime? createdAt,
    DateTime? expiresAt,
    this.status = AdoptionRequestStatus.pending,
    this.joinerUserId,
    this.chosenPetId,
  })  : createdAt = createdAt ?? DateTime.now(),
        expiresAt = expiresAt ?? DateTime.now().add(Duration(days: daysLeft));

  /// Cria uma cópia da solicitação com novos valores opcionais
  AdoptionRequest copyWith({
    String? id,
    String? creatorUserId,
    List<Pet>? petsInRequest,
    int? daysLeft,
    DateTime? createdAt,
    DateTime? expiresAt,
    AdoptionRequestStatus? status,
    String? joinerUserId,
    String? chosenPetId,
  }) {
    return AdoptionRequest(
      id: id ?? this.id,
      creatorUserId: creatorUserId ?? this.creatorUserId,
      petsInRequest: petsInRequest ?? this.petsInRequest,
      daysLeft: daysLeft ?? this.daysLeft,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      joinerUserId: joinerUserId ?? this.joinerUserId,
      chosenPetId: chosenPetId ?? this.chosenPetId,
    );
  }

  /// Converte a solicitação para Map para serialização
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorUserId': creatorUserId,
      'petsInRequest': petsInRequest.map((pet) => pet.toJson()).toList(),
      'daysLeft': daysLeft,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'status': status.value,
      'joinerUserId': joinerUserId,
      'chosenPetId': chosenPetId,
    };
  }

  /// Cria uma solicitação a partir de Map (deserialização)
  factory AdoptionRequest.fromJson(Map<String, dynamic> json) {
    return AdoptionRequest(
      id: json['id'] as String,
      creatorUserId: json['creatorUserId'] as String,
      petsInRequest: (json['petsInRequest'] as List<dynamic>)
          .map((petJson) => Pet.fromJson(petJson as Map<String, dynamic>))
          .toList(),
      daysLeft: json['daysLeft'] as int,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(Duration(days: json['daysLeft'] as int)),
      status: json['status'] != null
          ? AdoptionRequestStatus.fromString(json['status'] as String)
          : AdoptionRequestStatus.pending,
      joinerUserId: json['joinerUserId'] as String?,
      chosenPetId: json['chosenPetId'] as String?,
    );
  }

  /// Verifica se a solicitação está ativa (pending e não expirada)
  bool get isActive {
    return status == AdoptionRequestStatus.pending &&
        DateTime.now().isBefore(expiresAt);
  }

  /// Verifica se a solicitação expirou
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Calcula os dias restantes reais baseado na data atual
  int get actualDaysLeft {
    if (isExpired) return 0;
    final difference = expiresAt.difference(DateTime.now());
    return difference.inDays + (difference.inHours % 24 > 0 ? 1 : 0);
  }

  /// Retorna o pet escolhido na adoção, se existir
  Pet? get chosenPet {
    if (chosenPetId == null) return null;
    try {
      return petsInRequest.firstWhere((pet) => pet.id == chosenPetId);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se um usuário pode participar desta solicitação
  bool canUserJoin(String userId) {
    return status == AdoptionRequestStatus.pending &&
        creatorUserId != userId &&
        joinerUserId == null &&
        !isExpired;
  }

  /// Calcula a porcentagem de tempo restante
  double get timeProgress {
    if (isExpired) return 0.0;
    final totalDuration = expiresAt.difference(createdAt);
    final remainingDuration = expiresAt.difference(DateTime.now());
    return (totalDuration.inMilliseconds - remainingDuration.inMilliseconds) /
        totalDuration.inMilliseconds;
  }

  /// Retorna uma descrição amigável do status
  String get statusDescription {
    switch (status) {
      case AdoptionRequestStatus.pending:
        return isExpired ? 'Expirada' : 'Aguardando adotador';
      case AdoptionRequestStatus.completed:
        return 'Adoção concluída';
      case AdoptionRequestStatus.expired:
        return 'Tempo esgotado';
      case AdoptionRequestStatus.cancelled:
        return 'Cancelada';
    }
  }

  /// Completa a solicitação com um joiner e pet escolhido
  AdoptionRequest complete(String joinerUserId, String chosenPetId) {
    return copyWith(
      status: AdoptionRequestStatus.completed,
      joinerUserId: joinerUserId,
      chosenPetId: chosenPetId,
    );
  }

  /// Cancela a solicitação
  AdoptionRequest cancel() {
    return copyWith(status: AdoptionRequestStatus.cancelled);
  }

  /// Marca como expirada
  AdoptionRequest expire() {
    return copyWith(status: AdoptionRequestStatus.expired);
  }

  @override
  String toString() {
    return 'AdoptionRequest(id: $id, creator: $creatorUserId, pets: ${petsInRequest.length}, status: ${status.value}, daysLeft: $daysLeft)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdoptionRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
