// File: lib/domain/entities/collaboration/reveal_request_entity.dart

class RevealRequestEntity {
  final String id;
  final String petId;
  final String requestedByUserId;
  final String targetUserId;
  final DateTime requestedAt;
  final bool? accepted;
  final DateTime? respondedAt;
  final String? rejectionReason;
  final Map<String, dynamic> metadata;

  const RevealRequestEntity({
    required this.id,
    required this.petId,
    required this.requestedByUserId,
    required this.targetUserId,
    required this.requestedAt,
    this.accepted,
    this.respondedAt,
    this.rejectionReason,
    this.metadata = const {},
  });

  /// Status da solicitação
  String get status {
    if (accepted == null) return 'Pendente';
    return accepted! ? 'Aceito' : 'Rejeitado';
  }

  /// Verifica se ainda está pendente
  bool get isPending => accepted == null;

  /// Verifica se expirou (24h sem resposta)
  bool get isExpired {
    if (!isPending) return false;
    return DateTime.now().difference(requestedAt).inHours > 24;
  }

  RevealRequestEntity copyWith({
    String? id,
    String? petId,
    String? requestedByUserId,
    String? targetUserId,
    DateTime? requestedAt,
    bool? accepted,
    DateTime? respondedAt,
    String? rejectionReason,
    Map<String, dynamic>? metadata,
  }) {
    return RevealRequestEntity(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      requestedByUserId: requestedByUserId ?? this.requestedByUserId,
      targetUserId: targetUserId ?? this.targetUserId,
      requestedAt: requestedAt ?? this.requestedAt,
      accepted: accepted ?? this.accepted,
      respondedAt: respondedAt ?? this.respondedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Estatísticas de colaboração
class CollaborationStats {
  final int totalCollaborations;
  final int successfulReveals;
  final double averagePetLevel;
  final int totalActionsPerformed;
  final double partnerSatisfactionRating;
  final List<String> preferredPetTypes;
  final int totalXpGained;
  final Map<String, int> actionCounts;

  const CollaborationStats({
    required this.totalCollaborations,
    required this.successfulReveals,
    required this.averagePetLevel,
    required this.totalActionsPerformed,
    required this.partnerSatisfactionRating,
    required this.preferredPetTypes,
    required this.totalXpGained,
    required this.actionCounts,
  });

  /// Taxa de sucesso em reveals
  double get revealSuccessRate {
    return totalCollaborations > 0 ? (successfulReveals / totalCollaborations) * 100 : 0.0;
  }

  /// Ação mais realizada
  String get mostPerformedAction {
    if (actionCounts.isEmpty) return 'Nenhuma';
    final entry = actionCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
    return entry.key;
  }

  CollaborationStats copyWith({
    int? totalCollaborations,
    int? successfulReveals,
    double? averagePetLevel,
    int? totalActionsPerformed,
    double? partnerSatisfactionRating,
    List<String>? preferredPetTypes,
    int? totalXpGained,
    Map<String, int>? actionCounts,
  }) {
    return CollaborationStats(
      totalCollaborations: totalCollaborations ?? this.totalCollaborations,
      successfulReveals: successfulReveals ?? this.successfulReveals,
      averagePetLevel: averagePetLevel ?? this.averagePetLevel,
      totalActionsPerformed: totalActionsPerformed ?? this.totalActionsPerformed,
      partnerSatisfactionRating: partnerSatisfactionRating ?? this.partnerSatisfactionRating,
      preferredPetTypes: preferredPetTypes ?? this.preferredPetTypes,
      totalXpGained: totalXpGained ?? this.totalXpGained,
      actionCounts: actionCounts ?? this.actionCounts,
    );
  }
}
