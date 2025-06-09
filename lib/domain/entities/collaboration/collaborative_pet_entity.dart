// File: lib/domain/entities/collaboration/collaborative_pet_entity.dart

import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/domain/entities/pet_entity.dart';

/// ✅ CORRIGIDO: Collaborative pet entity que estende corretamente PetEntity
class CollaborativePetEntity extends PetEntity {
  // ✅ CAMPOS ESPECÍFICOS DE COLABORAÇÃO (não existem na PetEntity base)
  final String collaborationId;
  final List<String> caretakerIds;
  final CollaborationStatus status;
  final CollaborationDifficulty difficulty;
  final int revealLevel;
  final bool revealRequested;
  final List<String> revealAccepted;
  final DateTime matchedAt;
  final Map<String, int> contributionStats;
  final List<dynamic> recentActions; // ✅ Tipo genérico para evitar referência circular
  final DateTime? revealRequestedAt;
  final String? createdByUserId;
  final Map<String, dynamic> collaborationRewards;

  const CollaborativePetEntity({
    // ✅ CAMPOS DA PetEntity BASE (todos obrigatórios)
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.type,
    required super.description,
    super.isAdopted = false,
    super.hunger = 100,
    super.happiness = 100,
    super.energy = 100,
    super.level = 1,
    super.xp = 0, // ✅ CORRIGIDO: era "experience"
    super.xpToNextLevel = 100, // ✅ ADICIONADO: campo obrigatório
    super.health = 100,
    required super.lastFed,
    required super.lastPlayed,
    required super.lastSlept,
    super.evolutionStage = 1, // ✅ ADICIONADO: campo obrigatório
    super.skills = const [], // ✅ ADICIONADO: campo obrigatório
    super.generatedByUserId, // ✅ CORRIGIDO: era "userId"

    // ✅ CAMPOS ESPECÍFICOS DE COLABORAÇÃO
    required this.collaborationId,
    required this.caretakerIds,
    required this.status,
    required this.difficulty,
    required this.revealLevel,
    required this.revealRequested,
    required this.revealAccepted,
    required this.matchedAt,
    required this.contributionStats,
    required this.recentActions,
    this.revealRequestedAt,
    this.createdByUserId,
    this.collaborationRewards = const {},
  });

  /// Verifica se pode fazer reveal baseado no nível atual
  bool get canReveal => level >= difficulty.revealLevel;

  /// Verifica se ambos os usuários aceitaram o reveal
  bool get isRevealed => revealAccepted.length == 2;

  /// Verifica se é uma colaboração ativa
  bool get isActiveCollaboration =>
      status == CollaborationStatus.activeCollaboration && caretakerIds.length == 2;

  /// Retorna o parceiro do usuário especificado
  String? getPartnerUserId(String currentUserId) {
    return caretakerIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  /// Calcula contribuição percentual do usuário
  double getUserContributionPercentage(String userId) {
    final userContribution = contributionStats[userId] ?? 0;
    final totalContributions = contributionStats.values.fold(0, (a, b) => a + b);
    return totalContributions > 0 ? (userContribution / totalContributions) * 100 : 0.0;
  }

  @override
  CollaborativePetEntity copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? type,
    String? description,
    bool? isAdopted,
    int? hunger,
    int? happiness,
    int? energy,
    int? level,
    int? xp, // ✅ CORRIGIDO: era "experience"
    int? xpToNextLevel, // ✅ ADICIONADO
    int? health,
    DateTime? lastFed,
    DateTime? lastPlayed,
    DateTime? lastSlept,
    int? evolutionStage, // ✅ ADICIONADO
    List<String>? skills, // ✅ ADICIONADO
    String? generatedByUserId, // ✅ CORRIGIDO: era "userId"
    String? collaborationId,
    List<String>? caretakerIds,
    CollaborationStatus? status,
    CollaborationDifficulty? difficulty,
    int? revealLevel,
    bool? revealRequested,
    List<String>? revealAccepted,
    DateTime? matchedAt,
    Map<String, int>? contributionStats,
    List<dynamic>? recentActions,
    DateTime? revealRequestedAt,
    String? createdByUserId,
    Map<String, dynamic>? collaborationRewards,
  }) {
    return CollaborativePetEntity(
      // ✅ CAMPOS DA PetEntity BASE
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      description: description ?? this.description,
      isAdopted: isAdopted ?? this.isAdopted,
      hunger: hunger ?? this.hunger,
      happiness: happiness ?? this.happiness,
      energy: energy ?? this.energy,
      health: health ?? this.health,
      level: level ?? this.level,
      xp: xp ?? this.xp, // ✅ CORRIGIDO
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel, // ✅ ADICIONADO
      lastFed: lastFed ?? this.lastFed,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      lastSlept: lastSlept ?? this.lastSlept,
      evolutionStage: evolutionStage ?? this.evolutionStage, // ✅ ADICIONADO
      skills: skills ?? this.skills, // ✅ ADICIONADO
      generatedByUserId: generatedByUserId ?? this.generatedByUserId, // ✅ CORRIGIDO

      // ✅ CAMPOS ESPECÍFICOS DE COLABORAÇÃO
      collaborationId: collaborationId ?? this.collaborationId,
      caretakerIds: caretakerIds ?? this.caretakerIds,
      status: status ?? this.status,
      difficulty: difficulty ?? this.difficulty,
      revealLevel: revealLevel ?? this.revealLevel,
      revealRequested: revealRequested ?? this.revealRequested,
      revealAccepted: revealAccepted ?? this.revealAccepted,
      matchedAt: matchedAt ?? this.matchedAt,
      contributionStats: contributionStats ?? this.contributionStats,
      recentActions: recentActions ?? this.recentActions,
      revealRequestedAt: revealRequestedAt ?? this.revealRequestedAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      collaborationRewards: collaborationRewards ?? this.collaborationRewards,
    );
  }
}

// =======================================
// FACTORY CONSTRUCTOR PARA CONVERTER PetEntity → CollaborativePetEntity
// =======================================

extension CollaborativePetEntityFromPet on PetEntity {
  /// ✅ Converter PetEntity normal para CollaborativePetEntity
  CollaborativePetEntity toCollaborative({
    required String collaborationId,
    required List<String> caretakerIds,
    required CollaborationStatus status,
    required CollaborationDifficulty difficulty,
    required DateTime matchedAt,
    int? revealLevel,
    Map<String, int>? contributionStats,
    String? createdByUserId,
  }) {
    return CollaborativePetEntity(
      // ✅ COPIAR TODOS OS CAMPOS DA PetEntity BASE
      id: id,
      name: name,
      imageUrl: imageUrl,
      type: type,
      description: description,
      isAdopted: isAdopted,
      hunger: hunger,
      happiness: happiness,
      energy: energy,
      level: level,
      xp: xp,
      health: health,
      xpToNextLevel: xpToNextLevel,
      lastFed: lastFed,
      lastPlayed: lastPlayed,
      lastSlept: lastSlept,
      evolutionStage: evolutionStage,
      skills: skills,
      generatedByUserId: generatedByUserId,

      // ✅ ADICIONAR CAMPOS ESPECÍFICOS DE COLABORAÇÃO
      collaborationId: collaborationId,
      caretakerIds: caretakerIds,
      status: status,
      difficulty: difficulty,
      revealLevel: revealLevel ?? difficulty.revealLevel,
      revealRequested: false,
      revealAccepted: [],
      matchedAt: matchedAt,
      contributionStats: contributionStats ?? {},
      recentActions: [],
      createdByUserId: createdByUserId,
      collaborationRewards: {},
    );
  }
}
