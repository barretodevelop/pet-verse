

// // File: lib/core/classes/collaborative/collaborative_pet_entity.dart
// import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
// import 'package:petverse/core/enums/enums/app_enums.dart';
// import 'package:petverse/domain/entities/collaboration/collaborative_action_entity.dart';

 
// class CollaborativePetEntity {
//   final String id;
//   final String name;
//   final String type;
//   final String imageUrl;
//   final String collaborationId;
//   final List<String> caretakerIds; // [userId1, userId2]
//   final CollaborationStatus status;
//   final RevealStatus revealStatus;
//   final int currentLevel;
//   final int revealLevel;
//   final int maxLevel;
//   final DateTime? matchedAt;
//   final DateTime? createdAt;
//   final DateTime? lastActionAt;
//   final Map<String, int> contributionStats; // {userId: contributions}
//   final List<CollaborativeAction> recentActions;
//   final Map<String, dynamic> stats; // hunger, happiness, energy, health
//   final int totalExperience;
//   final bool isActive;
//   final Map<String, String> anonymousNames; // {userId: "Cuidador A"}

//   const CollaborativePetEntity({
//     required this.id,
//     required this.name,
//     required this.type,
//     required this.imageUrl,
//     required this.collaborationId,
//     required this.caretakerIds,
//     required this.status,
//     required this.revealStatus,
//     required this.currentLevel,
//     required this.revealLevel,
//     required this.maxLevel,
//     this.matchedAt,
//     this.createdAt,
//     this.lastActionAt,
//     required this.contributionStats,
//     required this.recentActions,
//     required this.stats,
//     required this.totalExperience,
//     this.isActive = true,
//     required this.anonymousNames,
//   });

//   factory CollaborativePetEntity.fromMap(Map<String, dynamic> map) {
//     return CollaborativePetEntity(
//       id: map['id'] ?? '',
//       name: map['name'] ?? '',
//       type: map['type'] ?? '',
//       imageUrl: map['imageUrl'] ?? '',
//       collaborationId: map['collaborationId'] ?? '',
//       caretakerIds: List<String>.from(map['caretakerIds'] ?? []),
//       status: CollaborationStatus.fromString(map['status'] ?? ''),
//       revealStatus: RevealStatus.fromString(map['revealStatus'] ?? ''),
//       currentLevel: map['currentLevel'] ?? 1,
//       revealLevel: map['revealLevel'] ?? 10,
//       maxLevel: map['maxLevel'] ?? 50,
//       matchedAt: map['matchedAt'] != null 
//           ? DateTime.fromMillisecondsSinceEpoch(map['matchedAt'])
//           : null,
//       createdAt: map['createdAt'] != null 
//           ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
//           : null,
//       lastActionAt: map['lastActionAt'] != null 
//           ? DateTime.fromMillisecondsSinceEpoch(map['lastActionAt'])
//           : null,
//       contributionStats: Map<String, int>.from(map['contributionStats'] ?? {}),
//       recentActions: (map['recentActions'] as List<dynamic>? ?? [])
//           .map((action) => CollaborativeAction.fromMap(action))
//           .toList(),
//       stats: Map<String, dynamic>.from(map['stats'] ?? {}),
//       totalExperience: map['totalExperience'] ?? 0,
//       isActive: map['isActive'] ?? true,
//       anonymousNames: Map<String, String>.from(map['anonymousNames'] ?? {}),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'type': type,
//       'imageUrl': imageUrl,
//       'collaborationId': collaborationId,
//       'caretakerIds': caretakerIds,
//       'status': status.value,
//       'revealStatus': revealStatus.value,
//       'currentLevel': currentLevel,
//       'revealLevel': revealLevel,
//       'maxLevel': maxLevel,
//       'matchedAt': matchedAt?.millisecondsSinceEpoch,
//       'createdAt': createdAt?.millisecondsSinceEpoch,
//       'lastActionAt': lastActionAt?.millisecondsSinceEpoch,
//       'contributionStats': contributionStats,
//       'recentActions': recentActions.map((action) => action.toMap()).toList(),
//       'stats': stats,
//       'totalExperience': totalExperience,
//       'isActive': isActive,
//       'anonymousNames': anonymousNames,
//     };
//   }

//   // Getters para facilitar o uso
//   bool get canReveal => currentLevel >= revealLevel && revealStatus == RevealStatus.available;
//   bool get isWaitingForPartner => status == CollaborationStatus.waitingForPartner;
//   bool get isActiveCollaboration => status == CollaborationStatus.activeCollaboration;
//   bool get isRevealed => status == CollaborationStatus.revealed;
//   double get progressToReveal => currentLevel / revealLevel;
  
//   int getHunger() => stats['hunger'] ?? 50;
//   int getHappiness() => stats['happiness'] ?? 50;
//   int getEnergy() => stats['energy'] ?? 50;
//   int getHealth() => stats['health'] ?? 100;

//   CollaborativePetEntity copyWith({
//     String? id,
//     String? name,
//     String? type,
//     String? imageUrl,
//     String? collaborationId,
//     List<String>? caretakerIds,
//     CollaborationStatus? status,
//     RevealStatus? revealStatus,
//     int? currentLevel,
//     int? revealLevel,
//     int? maxLevel,
//     DateTime? matchedAt,
//     DateTime? createdAt,
//     DateTime? lastActionAt,
//     Map<String, int>? contributionStats,
//     List<CollaborativeAction>? recentActions,
//     Map<String, dynamic>? stats,
//     int? totalExperience,
//     bool? isActive,
//     Map<String, String>? anonymousNames,
//   }) {
//     return CollaborativePetEntity(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       type: type ?? this.type,
//       imageUrl: imageUrl ?? this.imageUrl,
//       collaborationId: collaborationId ?? this.collaborationId,
//       caretakerIds: caretakerIds ?? this.caretakerIds,
//       status: status ?? this.status,
//       revealStatus: revealStatus ?? this.revealStatus,
//       currentLevel: currentLevel ?? this.currentLevel,
//       revealLevel: revealLevel ?? this.revealLevel,
//       maxLevel: maxLevel ?? this.maxLevel,
//       matchedAt: matchedAt ?? this.matchedAt,
//       createdAt: createdAt ?? this.createdAt,
//       lastActionAt: lastActionAt ?? this.lastActionAt,
//       contributionStats: contributionStats ?? this.contributionStats,
//       recentActions: recentActions ?? this.recentActions,
//       stats: stats ?? this.stats,
//       totalExperience: totalExperience ?? this.totalExperience,
//       isActive: isActive ?? this.isActive,
//       anonymousNames: anonymousNames ?? this.anonymousNames,
//     );
//   }
// }

// // File: lib/core/classes/collaborative/user_collaboration_data.dart
// class UserCollaborationData {
//   final String userId;
//   final int experienceLevel;
//   final int maxCollaborativeSlots;
//   final List<String> activePetIds;
//   final List<String> completedCollaborations;
//   final int totalSuccessfulReveals;
//   final double cooperationRating;
//   final int totalActionsPerformed;
//   final DateTime? lastActiveAt;
//   final Map<String, int> preferredPetTypes; // {type: count}
//   final List<String> badges;
//   final bool isOnline;

//   const UserCollaborationData({
//     required this.userId,
//     required this.experienceLevel,
//     required this.maxCollaborativeSlots,
//     required this.activePetIds,
//     required this.completedCollaborations,
//     required this.totalSuccessfulReveals,
//     required this.cooperationRating,
//     required this.totalActionsPerformed,
//     this.lastActiveAt,
//     required this.preferredPetTypes,
//     required this.badges,
//     this.isOnline = false,
//   });

//   factory UserCollaborationData.fromMap(Map<String, dynamic> map) {
//     return UserCollaborationData(
//       userId: map['userId'] ?? '',
//       experienceLevel: map['experienceLevel'] ?? 1,
//       maxCollaborativeSlots: map['maxCollaborativeSlots'] ?? 1,
//       activePetIds: List<String>.from(map['activePetIds'] ?? []),
//       completedCollaborations: List<String>.from(map['completedCollaborations'] ?? []),
//       totalSuccessfulReveals: map['totalSuccessfulReveals'] ?? 0,
//       cooperationRating: (map['cooperationRating'] ?? 0.0).toDouble(),
//       totalActionsPerformed: map['totalActionsPerformed'] ?? 0,
//       lastActiveAt: map['lastActiveAt'] != null 
//           ? DateTime.fromMillisecondsSinceEpoch(map['lastActiveAt'])
//           : null,
//       preferredPetTypes: Map<String, int>.from(map['preferredPetTypes'] ?? {}),
//       badges: List<String>.from(map['badges'] ?? []),
//       isOnline: map['isOnline'] ?? false,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'userId': userId,
//       'experienceLevel': experienceLevel,
//       'maxCollaborativeSlots': maxCollaborativeSlots,
//       'activePetIds': activePetIds,
//       'completedCollaborations': completedCollaborations,
//       'totalSuccessfulReveals': totalSuccessfulReveals,
//       'cooperationRating': cooperationRating,
//       'totalActionsPerformed': totalActionsPerformed,
//       'lastActiveAt': lastActiveAt?.millisecondsSinceEpoch,
//       'preferredPetTypes': preferredPetTypes,
//       'badges': badges,
//       'isOnline': isOnline,
//     };
//   }

//   bool get hasAvailableSlots => activePetIds.length < maxCollaborativeSlots;
//   bool get isExperienced => experienceLevel >= 5;
//   bool get isReliable => cooperationRating >= 4.0;

//   UserCollaborationData copyWith({
//     String? userId,
//     int? experienceLevel,
//     int? maxCollaborativeSlots,
//     List<String>? activePetIds,
//     List<String>? completedCollaborations,
//     int? totalSuccessfulReveals,
//     double? cooperationRating,
//     int? totalActionsPerformed,
//     DateTime? lastActiveAt,
//     Map<String, int>? preferredPetTypes,
//     List<String>? badges,
//     bool? isOnline,
//   }) {
//     return UserCollaborationData(
//       userId: userId ?? this.userId,
//       experienceLevel: experienceLevel ?? this.experienceLevel,
//       maxCollaborativeSlots: maxCollaborativeSlots ?? this.maxCollaborativeSlots,
//       activePetIds: activePetIds ?? this.activePetIds,
//       completedCollaborations: completedCollaborations ?? this.completedCollaborations,
//       totalSuccessfulReveals: totalSuccessfulReveals ?? this.totalSuccessfulReveals,
//       cooperationRating: cooperationRating ?? this.cooperationRating,
//       totalActionsPerformed: totalActionsPerformed ?? this.totalActionsPerformed,
//       lastActiveAt: lastActiveAt ?? this.lastActiveAt,
//       preferredPetTypes: preferredPetTypes ?? this.preferredPetTypes,
//       badges: badges ?? this.badges,
//       isOnline: isOnline ?? this.isOnline,
//     );
//   }
// }

// // File: lib/core/classes/collaborative/collaboration_badge.dart
// import '../../enums/collaborative/badge_type.dart';

// class CollaborationBadge {
//   final String id;
//   final String name;
//   final String description;
//   final String iconUrl;
//   final BadgeType type;
//   final int requiredCount;
//   final bool isRare;
//   final DateTime? unlockedAt;
//   final String? unlockCondition;

//   const CollaborationBadge({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.iconUrl,
//     required this.type,
//     required this.requiredCount,
//     this.isRare = false,
//     this.unlockedAt,
//     this.unlockCondition,
//   });

//   factory CollaborationBadge.fromMap(Map<String, dynamic> map) {
//     return CollaborationBadge(
//       id: map['id'] ?? '',
//       name: map['name'] ?? '',
//       description: map['description'] ?? '',
//       iconUrl: map['iconUrl'] ?? '',
//       type: BadgeType.fromString(map['type'] ?? ''),
//       requiredCount: map['requiredCount'] ?? 1,
//       isRare: map['isRare'] ?? false,
//       unlockedAt: map['unlockedAt'] != null 
//           ? DateTime.fromMillisecondsSinceEpoch(map['unlockedAt'])
//           : null,
//       unlockCondition: map['unlockCondition'],
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'iconUrl': iconUrl,
//       'type': type.value,
//       'requiredCount': requiredCount,
//       'isRare': isRare,
//       'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
//       'unlockCondition': unlockCondition,
//     };
//   }

//   bool get isUnlocked => unlockedAt != null;

//   // Badges pré-definidos
//   static const List<CollaborationBadge> predefinedBadges = [
//     CollaborationBadge(
//       id: 'first_collaboration',
//       name: 'Primeira Colaboração',
//       description: 'Complete sua primeira adoção colaborativa',
//       iconUrl: '🤝',
//       type: BadgeType.collaboration,
//       requiredCount: 1,
//       unlockCondition: 'Complete 1 colaboração',
//     ),
//     CollaborationBadge(
//       id: 'pet_master_duo',
//       name: 'Pet Master Duo',
//       description: 'Alcance nível máximo com 10 pets colaborativos',
//       iconUrl: '👑',
//       type: BadgeType.achievement,
//       requiredCount: 10,
//       isRare: true,
//       unlockCondition: '10 pets nível máximo',
//     ),
//     CollaborationBadge(
//       id: 'anonymous_helper',
//       name: 'Helper Anônimo',
//       description: 'Execute 50 ações anônimas',
//       iconUrl: '🎭',
//       type: BadgeType.collaboration,
//       requiredCount: 50,
//       unlockCondition: '50 ações anônimas',
//     ),
//     CollaborationBadge(
//       id: 'reveal_master',
//       name: 'Reveal Master',
//       description: 'Complete 10 reveals bem-sucedidos',
//       iconUrl: '✨',
//       type: BadgeType.reveal,
//       requiredCount: 10,
//       isRare: true,
//       unlockCondition: '10 reveals aceitos',
//     ),
//     CollaborationBadge(
//       id: 'social_butterfly',
//       name: 'Borboleta Social',
//       description: 'Conheça 25 parceiros diferentes',
//       iconUrl: '🦋',
//       type: BadgeType.special,
//       requiredCount: 25,
//       isRare: true,
//       unlockCondition: '25 parceiros únicos',
//     ),
//   ];

//   CollaborationBadge copyWith({
//     String? id,
//     String? name,
//     String? description,
//     String? iconUrl,
//     BadgeType? type,
//     int? requiredCount,
//     bool? isRare,
//     DateTime? unlockedAt,
//     String? unlockCondition,
//   }) {
//     return CollaborationBadge(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       description: description ?? this.description,
//       iconUrl: iconUrl ?? this.iconUrl,
//       type: type ?? this.type,
//       requiredCount: requiredCount ?? this.requiredCount,
//       isRare: isRare ?? this.isRare,
//       unlockedAt: unlockedAt ?? this.unlockedAt,
//       unlockCondition: unlockCondition ?? this.unlockCondition,
//     );
//   }
// }

// // File: lib/core/classes/collaborative/cooperation_stats.dart
// class CooperationStats {
//   final int totalCollaborations;
//   final int successfulReveals;
//   final double averagePetLevel;
//   final int totalActionsPerformed;
//   final double partnerSatisfactionRating;
//   final List<String> preferredPetTypes;
//   final int consecutiveSuccesses;
//   final DateTime? lastCollaborationDate;
//   final Map<String, int> actionBreakdown; // {action_type: count}
//   final double responseTimeAverage; // em minutos
//   final int uniquePartnersCount;

//   const CooperationStats({
//     required this.totalCollaborations,
//     required this.successfulReveals,
//     required this.averagePetLevel,
//     required this.totalActionsPerformed,
//     required this.partnerSatisfactionRating,
//     required this.preferredPetTypes,
//     required this.consecutiveSuccesses,
//     this.lastCollaborationDate,
//     required this.actionBreakdown,
//     required this.responseTimeAverage,
//     required this.uniquePartnersCount,
//   });

//   factory CooperationStats.fromMap(Map<String, dynamic> map) {
//     return CooperationStats(
//       totalCollaborations: map['totalCollaborations'] ?? 0,
//       successfulReveals: map['successfulReveals'] ?? 0,
//       averagePetLevel: (map['averagePetLevel'] ?? 0.0).toDouble(),
//       totalActionsPerformed: map['totalActionsPerformed'] ?? 0,
//       partnerSatisfactionRating: (map['partnerSatisfactionRating'] ?? 0.0).toDouble(),
//       preferredPetTypes: List<String>.from(map['preferredPetTypes'] ?? []),
//       consecutiveSuccesses: map['consecutiveSuccesses'] ?? 0,
//       lastCollaborationDate: map['lastCollaborationDate'] != null 
//           ? DateTime.fromMillisecondsSinceEpoch(map['lastCollaborationDate'])
//           : null,
//       actionBreakdown: Map<String, int>.from(map['actionBreakdown'] ?? {}),
//       responseTimeAverage: (map['responseTimeAverage'] ?? 0.0).toDouble(),
//       uniquePartnersCount: map['uniquePartnersCount'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'totalCollaborations': totalCollaborations,
//       'successfulReveals': successfulReveals,
//       'averagePetLevel': averagePetLevel,
//       'totalActionsPerformed': totalActionsPerformed,
//       'partnerSatisfactionRating': partnerSatisfactionRating,
//       'preferredPetTypes': preferredPetTypes,
//       'consecutiveSuccesses': consecutiveSuccesses,
//       'lastCollaborationDate': lastCollaborationDate?.millisecondsSinceEpoch,
//       'actionBreakdown': actionBreakdown,
//       'responseTimeAverage': responseTimeAverage,
//       'uniquePartnersCount': uniquePartnersCount,
//     };
//   }

//   // Getters calculados
//   double get successRate => totalCollaborations > 0 
//       ? successfulReveals / totalCollaborations 
//       : 0.0;

//   double get actionsPerCollaboration => totalCollaborations > 0 
//       ? totalActionsPerformed / totalCollaborations 
//       : 0.0;

//   bool get isActiveUser => totalActionsPerformed >= 100;
//   bool get isReliablePartner => partnerSatisfactionRating >= 4.0;
//   bool get isFastResponder => responseTimeAverage <= 30; // menos de 30 min

//   String get experienceLevel {
//     if (totalCollaborations >= 50) return 'Expert';
//     if (totalCollaborations >= 20) return 'Avançado';
//     if (totalCollaborations >= 10) return 'Intermediário';
//     if (totalCollaborations >= 3) return 'Iniciante';
//     return 'Novato';
//   }

//   CooperationStats copyWith({
//     int? totalCollaborations,
//     int? successfulReveals,
//     double? averagePetLevel,
//     int? totalActionsPerformed,
//     double? partnerSatisfactionRating,
//     List<String>? preferredPetTypes,
//     int? consecutiveSuccesses,
//     DateTime? lastCollaborationDate,
//     Map<String, int>? actionBreakdown,
//     double? responseTimeAverage,
//     int? uniquePartnersCount,
//   }) {
//     return CooperationStats(
//       totalCollaborations: totalCollaborations ?? this.totalCollaborations,
//       successfulReveals: successfulReveals ?? this.successfulReveals,
//       averagePetLevel: averagePetLevel ?? this.averagePetLevel,
//       totalActionsPerformed: totalActionsPerformed ?? this.totalActionsPerformed,
//       partnerSatisfactionRating: partnerSatisfactionRating ?? this.partnerSatisfactionRating,
//       preferredPetTypes: preferredPetTypes ?? this.preferredPetTypes,
//       consecutiveSuccesses: consecutiveSuccesses ?? this.consecutiveSuccesses,
//       lastCollaborationDate: lastCollaborationDate ?? this.lastCollaborationDate,
//       actionBreakdown: actionBreakdown ?? this.actionBreakdown,
//       responseTimeAverage: responseTimeAverage ?? this.responseTimeAverage,
//       uniquePartnersCount: uniquePartnersCount ?? this.uniquePartnersCount,
//     );
//   }
// }

// // File: lib/core/classes/collaborative/reveal_request.dart
// import '../../enums/collaborative/reveal_status.dart';

// class RevealRequest {
//   final String id;
//   final String collaborationId;
//   final String petId;
//   final String requesterId;
//   final String targetUserId;
//   final RevealStatus status;
//   final DateTime createdAt;
//   final DateTime? respondedAt;
//   final DateTime expiresAt;
//   final String? message;
//   final bool isAutomatic; // Se foi gerado automaticamente pelo sistema

//   const RevealRequest({
//     required this.id,
//     required this.collaborationId,
//     required this.petId,
//     required this.requesterId,
//     required this.targetUserId,
//     required this.status,
//     required this.createdAt,
//     this.respondedAt,
//     required this.expiresAt,
//     this.message,
//     this.isAutomatic = true,
//   });

//   factory RevealRequest.fromMap(Map<String, dynamic> map) {
//     return RevealRequest(
//       id: map['id'] ?? '',
//       collaborationId: map['collaborationId'] ?? '',
//       petId: map['petId'] ?? '',
//       requesterId: map['requesterId'] ?? '',
//       targetUserId: map['targetUserId'] ?? '',
//       status: RevealStatus.fromString(map['status'] ?? ''),
//       createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
//       respondedAt: map['respondedAt'] != null 
//           ? DateTime.fromMillisecondsSinceEpoch(map['respondedAt'])
//           : null,
//       expiresAt: DateTime.fromMillisecondsSinceEpoch(map['expiresAt'] ?? 0),
//       message: map['message'],
//       isAutomatic: map['isAutomatic'] ?? true,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'collaborationId': collaborationId,
//       'petId': petId,
//       'requesterId': requesterId,
//       'targetUserId': targetUserId,
//       'status': status.value,
//       'createdAt': createdAt.millisecondsSinceEpoch,
//       'respondedAt': respondedAt?.millisecondsSinceEpoch,
//       'expiresAt': expiresAt.millisecondsSinceEpoch,
//       'message': message,
//       'isAutomatic': isAutomatic,
//     };
//   }

//   bool get isExpired => DateTime.now().isAfter(expiresAt);
//   bool get isPending => status == RevealStatus.pending && !isExpired;
//   bool get isActive => [RevealStatus.available, RevealStatus.pending].contains(status);

//   Duration get timeRemaining => isExpired 
//       ? Duration.zero 
//       : expiresAt.difference(DateTime.now());

//   RevealRequest copyWith({
//     String? id,
//     String? collaborationId,
//     String? petId,
//     String? requesterId,
//     String? targetUserId,
//     RevealStatus? status,
//     DateTime? createdAt,
//     DateTime? respondedAt,
//     DateTime? expiresAt,
//     String? message,
//     bool? isAutomatic,
//   }) {
//     return RevealRequest(
//       id: id ?? this.id,
//       collaborationId: collaborationId ?? this.collaborationId,
//       petId: petId ?? this.petId,
//       requesterId: requesterId ?? this.requesterId,
//       targetUserId: targetUserId ?? this.targetUserId,
//       status: status ?? this.status,
//       createdAt: createdAt ?? this.createdAt,
//       respondedAt: respondedAt ?? this.respondedAt,
//       expiresAt: expiresAt ?? this.expiresAt,
//       message: message ?? this.message,
//       isAutomatic: isAutomatic ?? this.isAutomatic,
//     );
//   }
// }

// // File: lib/core/config/collaborative/collaboration_config.dart
// class CollaborationConfig {
//   // Configurações de nível e experiência
//   static const int defaultRevealLevel = 10;
//   static const int maxPetLevel = 50;
//   static const int experiencePerLevel = 100;
  
//   // Configurações de slots
//   static const int freeUserMaxSlots = 1;
//   static const int premiumUserMaxSlots = 3;
  
//   // Configurações de tempo
//   static const Duration matchTimeoutDuration = Duration(hours: 24);
//   static const Duration revealRequestDuration = Duration(hours: 48);
//   static const Duration inactivityThreshold = Duration(hours: 12);
  
//   // Configurações de matchmaking
//   static const int maxLevelDifference = 5;
//   static const double minCooperationRating = 3.0;
  
//   // Configurações de ações
//   static const Duration actionCooldown = Duration(minutes: 5);
//   static const int maxActionsPerHour = 12;
  
//   // Configurações de stats
//   static const Map<String, Map<String, int>> actionEffects = {
//     'feed': {'hunger': 20, 'happiness': 5, 'energy': -2},
//     'play': {'happiness': 15, 'energy': -10, 'hunger': -5},
//     'rest': {'energy': 25, 'happiness': 3},
//     'medicine': {'health': 30, 'happiness': -5},
//     'bath': {'happiness': 10, 'health': 5},
//     'training': {'experience': 20, 'energy': -15},
//     'love': {'happiness': 25, 'energy': 5},
//   };
  
//   // Configurações de notificação
//   static const Duration lowStatsNotificationThreshold = Duration(hours: 6);
//   static const int criticalStatLevel = 20;
  
//   // Mensagens padrão
//   static const Map<String, String> defaultMessages = {
//     'match_found': 'Parabéns! Encontramos um parceiro para você!',
//     'reveal_available': 'Seu pet atingiu o nível necessário para conhecer seu parceiro!',
//     'reveal_accepted': 'Seu parceiro aceitou se revelar! Agora vocês se conhecem!',
//     'reveal_rejected': 'Seu parceiro preferiu manter o anonimato por enquanto.',
//     'collaboration_complete': 'Parabéns! Vocês completaram uma colaboração com sucesso!',
//     'partner_inactive': 'Seu parceiro está inativo há mais de 12 horas.',
//   };
  
//   // URLs de assets padrão
//   static const Map<String, String> defaultAssets = {
//     'default_pet_image': 'assets/images/pets/default_collaborative_pet.png',
//     'anonymous_avatar': 'assets/images/avatars/anonymous.png',
//     'collaboration_badge': 'assets/images/badges/collaboration.png',
//   };
// }

// // File: lib/data/repositories/collaborative/collaborative_pet_repository.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dartz/dartz.dart';
// import '../../../core/classes/collaborative/collaborative_pet_entity.dart';
// import '../../../core/classes/collaborative/collaborative_action.dart';
// import '../../../core/enums/collaborative/collaboration_status.dart';
// import '../../../core/errors/failure.dart';

// abstract class CollaborativePetRepository {
//   // Buscar pets disponíveis para adoção colaborativa
//   Future<Either<Failure, List<CollaborativePetEntity>>> getAvailableCollaborativePets();
  
//   // Adicionar usuário à lista de espera
//   Future<Either<Failure, void>> addToWaitingList(String userId, String petId);
  
//   // Processar match entre usuários
//   Future<Either<Failure, CollaborativePetEntity>> processMatch(String petId, List<String> userIds);
  
//   // Atualizar pet com ação colaborativa
//   Future<Either<Failure, void>> addCollaborativeAction(String petId, CollaborativeAction action);
  
//   // Verificar se pode revelar parceiros
//   Future<Either<Failure, bool>> canRevealPartners(String petId);
  
//   // Processar reveal de parceiros
//   Future<Either<Failure, void>> processReveal(String petId, String userId, bool accepted);
  
//   // Obter pets colaborativos do usuário
//   Future<Either<Failure, List<CollaborativePetEntity>>> getUserCollaborativePets(String userId);
  
//   // Obter pet específico
//   Future<Either<Failure, CollaborativePetEntity?>> getCollaborativePet(String petId);
  
//   // Stream de atualizações em tempo real
//   Stream<CollaborativePetEntity> watchCollaborativePet(String petId);
  
//   // Abandonar colaboração
//   Future<Either<Failure, void>> abandonCollaboration(String petId, String userId);
// }

// class FirebaseCollaborativePetRepository implements CollaborativePetRepository {
//   final FirebaseFirestore _firestore;
  
//   const FirebaseCollaborativePetRepository(this._firestore);

//   @override
//   Future<Either<Failure, List<CollaborativePetEntity>>> getAvailableCollaborativePets() async {
//     try {
//       final querySnapshot = await _firestore
//           .collection('collaborative_pets')
//           .where('status', isEqualTo: CollaborationStatus.waitingForPartner.value)
//           .where('isActive', isEqualTo: true)
//           .orderBy('createdAt', descending: true)
//           .limit(20)
//           .get();

//       final pets = querySnapshot.docs
//           .map((doc) => CollaborativePetEntity.fromMap({
//                 'id': doc.id,
//                 ...doc.data(),
//               }))
//           .toList();

//       return Right(pets);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao buscar pets colaborativos: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> addToWaitingList(String userId, String petId) async {
//     try {
//       await _firestore.runTransaction((transaction) async {
//         final petRef = _firestore.collection('collaborative_pets').doc(petId);
//         final petSnapshot = await transaction.get(petRef);
        
//         if (!petSnapshot.exists) {
//           throw Exception('Pet não encontrado');
//         }
        
//         final petData = petSnapshot.data()!;
//         final caretakerIds = List<String>.from(petData['caretakerIds'] ?? []);
        
//         if (caretakerIds.contains(userId)) {
//           throw Exception('Usuário já está na lista de espera');
//         }
        
//         if (caretakerIds.length >= 2) {
//           throw Exception('Pet já tem dois cuidadores');
//         }
        
//         caretakerIds.add(userId);
        
//         transaction.update(petRef, {
//           'caretakerIds': caretakerIds,
//           'status': caretakerIds.length == 2 
//               ? CollaborationStatus.activeCollaboration.value
//               : CollaborationStatus.waitingForPartner.value,
//           'matchedAt': caretakerIds.length == 2 
//               ? FieldValue.serverTimestamp()
//               : null,
//         });
//       });

//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao entrar na lista de espera: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, CollaborativePetEntity>> processMatch(String petId, List<String> userIds) async {
//     try {
//       late CollaborativePetEntity updatedPet;
      
//       await _firestore.runTransaction((transaction) async {
//         final petRef = _firestore.collection('collaborative_pets').doc(petId);
//         final petSnapshot = await transaction.get(petRef);
        
//         if (!petSnapshot.exists) {
//           throw Exception('Pet não encontrado');
//         }
        
//         // Gerar nomes anônimos
//         final anonymousNames = <String, String>{};
//         for (int i = 0; i < userIds.length; i++) {
//           anonymousNames[userIds[i]] = 'Cuidador ${String.fromCharCode(65 + i)}'; // A, B, C...
//         }
        
//         transaction.update(petRef, {
//           'caretakerIds': userIds,
//           'status': CollaborationStatus.activeCollaboration.value,
//           'matchedAt': FieldValue.serverTimestamp(),
//           'anonymousNames': anonymousNames,
//           'lastActionAt': FieldValue.serverTimestamp(),
//         });
        
//         final updatedSnapshot = await petRef.get();
//         updatedPet = CollaborativePetEntity.fromMap({
//           'id': updatedSnapshot.id,
//           ...updatedSnapshot.data()!,
//         });
//       });

//       return Right(updatedPet);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao processar match: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> addCollaborativeAction(String petId, CollaborativeAction action) async {
//     try {
//       await _firestore.runTransaction((transaction) async {
//         final petRef = _firestore.collection('collaborative_pets').doc(petId);
//         final petSnapshot = await transaction.get(petRef);
        
//         if (!petSnapshot.exists) {
//           throw Exception('Pet não encontrado');
//         }
        
//         final petData = petSnapshot.data()!;
//         final currentStats = Map<String, dynamic>.from(petData['stats'] ?? {});
//         final recentActions = List<Map<String, dynamic>>.from(petData['recentActions'] ?? []);
//         final contributionStats = Map<String, int>.from(petData['contributionStats'] ?? {});
//         final currentExp = petData['totalExperience'] ?? 0;
        
//         // Aplicar efeitos da ação
//         action.effects.forEach((key, value) {
//           currentStats[key] = ((currentStats[key] ?? 50) + value).clamp(0, 100);
//         });
        
//         // Adicionar experiência
//         final newExp = currentExp + action.experienceGained;
//         final newLevel = (newExp / 100).floor() + 1;
        
//         // Atualizar contribuições do usuário
//         contributionStats[action.userId] = (contributionStats[action.userId] ?? 0) + 1;
        
//         // Adicionar ação recente (manter apenas as últimas 20)
//         recentActions.insert(0, action.toMap());
//         if (recentActions.length > 20) {
//           recentActions.removeRange(20, recentActions.length);
//         }
        
//         transaction.update(petRef, {
//           'stats': currentStats,
//           'totalExperience': newExp,
//           'currentLevel': newLevel,
//           'contributionStats': contributionStats,
//           'recentActions': recentActions,
//           'lastActionAt': FieldValue.serverTimestamp(),
//         });
//       });

//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao adicionar ação colaborativa: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, bool>> canRevealPartners(String petId) async {
//     try {
//       final petDoc = await _firestore.collection('collaborative_pets').doc(petId).get();
      
//       if (!petDoc.exists) {
//         return Left(DatabaseFailure('Pet não encontrado'));
//       }
      
//       final petData = petDoc.data()!;
//       final currentLevel = petData['currentLevel'] ?? 1;
//       final revealLevel = petData['revealLevel'] ?? 10;
//       final status = CollaborationStatus.fromString(petData['status'] ?? '');
      
//       final canReveal = currentLevel >= revealLevel && 
//                        status == CollaborationStatus.activeCollaboration;
      
//       return Right(canReveal);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao verificar reveal: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> processReveal(String petId, String userId, bool accepted) async {
//     try {
//       await _firestore.runTransaction((transaction) async {
//         final petRef = _firestore.collection('collaborative_pets').doc(petId);
//         final petSnapshot = await transaction.get(petRef);
        
//         if (!petSnapshot.exists) {
//           throw Exception('Pet não encontrado');
//         }
        
//         final petData = petSnapshot.data()!;
//         final revealAccepted = List<String>.from(petData['revealAccepted'] ?? []);
        
//         if (accepted && !revealAccepted.contains(userId)) {
//           revealAccepted.add(userId);
//         } else if (!accepted && revealAccepted.contains(userId)) {
//           revealAccepted.remove(userId);
//         }
        
//         final caretakerIds = List<String>.from(petData['caretakerIds'] ?? []);
//         final allAccepted = caretakerIds.every((id) => revealAccepted.contains(id));
        
//         transaction.update(petRef, {
//           'revealAccepted': revealAccepted,
//           'status': allAccepted 
//               ? CollaborationStatus.revealed.value
//               : CollaborationStatus.activeCollaboration.value,
//         });
//       });

//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao processar reveal: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, List<CollaborativePetEntity>>> getUserCollaborativePets(String userId) async {
//     try {
//       final querySnapshot = await _firestore
//           .collection('collaborative_pets')
//           .where('caretakerIds', arrayContains: userId)
//           .where('isActive', isEqualTo: true)
//           .orderBy('lastActionAt', descending: true)
//           .get();

//       final pets = querySnapshot.docs
//           .map((doc) => CollaborativePetEntity.fromMap({
//                 'id': doc.id,
//                 ...doc.data(),
//               }))
//           .toList();

//       return Right(pets);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao buscar pets do usuário: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, CollaborativePetEntity?>> getCollaborativePet(String petId) async {
//     try {
//       final petDoc = await _firestore.collection('collaborative_pets').doc(petId).get();
      
//       if (!petDoc.exists) {
//         return const Right(null);
//       }
      
//       final pet = CollaborativePetEntity.fromMap({
//         'id': petDoc.id,
//         ...petDoc.data()!,
//       });
      
//       return Right(pet);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao buscar pet: $e'));
//     }
//   }

//   @override
//   Stream<CollaborativePetEntity> watchCollaborativePet(String petId) {
//     return _firestore
//         .collection('collaborative_pets')
//         .doc(petId)
//         .snapshots()
//         .map((snapshot) => CollaborativePetEntity.fromMap({
//               'id': snapshot.id,
//               ...snapshot.data()!,
//             }));
//   }

//   @override
//   Future<Either<Failure, void>> abandonCollaboration(String petId, String userId) async {
//     try {
//       await _firestore.runTransaction((transaction) async {
//         final petRef = _firestore.collection('collaborative_pets').doc(petId);
//         final petSnapshot = await transaction.get(petRef);
        
//         if (!petSnapshot.exists) {
//           throw Exception('Pet não encontrado');
//         }
        
//         transaction.update(petRef, {
//           'status': CollaborationStatus.abandoned.value,
//           'isActive': false,
//           'abandonedBy': userId,
//           'abandonedAt': FieldValue.serverTimestamp(),
//         });
//       });

//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao abandonar colaboração: $e'));
//     }
//   }
// }

// // File: lib/data/repositories/collaborative/collaboration_repository.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dartz/dartz.dart';
// import '../../../core/classes/collaborative/user_collaboration_data.dart';
// import '../../../core/classes/collaborative/cooperation_stats.dart';
// import '../../../core/classes/collaborative/collaboration_badge.dart';
// import '../../../core/errors/failure.dart';

// abstract class CollaborationRepository {
//   Future<Either<Failure, UserCollaborationData>> getUserCollaborationData(String userId);
//   Future<Either<Failure, void>> updateUserCollaborationData(UserCollaborationData data);
//   Future<Either<Failure, CooperationStats>> getUserCooperationStats(String userId);
//   Future<Either<Failure, List<CollaborationBadge>>> getUserBadges(String userId);
//   Future<Either<Failure, void>> unlockBadge(String userId, String badgeId);
//   Future<Either<Failure, void>> updateCooperationRating(String userId, double rating);
// }

// class FirebaseCollaborationRepository implements CollaborationRepository {
//   final FirebaseFirestore _firestore;
  
//   const FirebaseCollaborationRepository(this._firestore);

//   @override
//   Future<Either<Failure, UserCollaborationData>> getUserCollaborationData(String userId) async {
//     try {
//       final doc = await _firestore.collection('user_collaboration_data').doc(userId).get();
      
//       if (!doc.exists) {
//         // Criar dados iniciais para usuário novo
//         final initialData = UserCollaborationData(
//           userId: userId,
//           experienceLevel: 1,
//           maxCollaborativeSlots: 1,
//           activePetIds: [],
//           completedCollaborations: [],
//           totalSuccessfulReveals: 0,
//           cooperationRating: 5.0,
//           totalActionsPerformed: 0,
//           preferredPetTypes: {},
//           badges: [],
//         );
        
//         await _firestore.collection('user_collaboration_data').doc(userId).set(initialData.toMap());
//         return Right(initialData);
//       }
      
//       final data = UserCollaborationData.fromMap({
//         'userId': doc.id,
//         ...doc.data()!,
//       });
      
//       return Right(data);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao buscar dados de colaboração: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> updateUserCollaborationData(UserCollaborationData data) async {
//     try {
//       await _firestore.collection('user_collaboration_data').doc(data.userId).set(
//         data.toMap(),
//         SetOptions(merge: true),
//       );
      
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao atualizar dados de colaboração: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, CooperationStats>> getUserCooperationStats(String userId) async {
//     try {
//       final doc = await _firestore.collection('cooperation_stats').doc(userId).get();
      
//       if (!doc.exists) {
//         // Criar stats iniciais
//         final initialStats = CooperationStats(
//           totalCollaborations: 0,
//           successfulReveals: 0,
//           averagePetLevel: 0.0,
//           totalActionsPerformed: 0,
//           partnerSatisfactionRating: 5.0,
//           preferredPetTypes: [],
//           consecutiveSuccesses: 0,
//           actionBreakdown: {},
//           responseTimeAverage: 0.0,
//           uniquePartnersCount: 0,
//         );
        
//         await _firestore.collection('cooperation_stats').doc(userId).set(initialStats.toMap());
//         return Right(initialStats);
//       }
      
//       final stats = CooperationStats.fromMap(doc.data()!);
//       return Right(stats);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao buscar estatísticas: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, List<CollaborationBadge>>> getUserBadges(String userId) async {
//     try {
//       final querySnapshot = await _firestore
//           .collection('user_badges')
//           .where('userId', isEqualTo: userId)
//           .where('unlockedAt', isNull: false)
//           .get();

//       final badges = querySnapshot.docs
//           .map((doc) => CollaborationBadge.fromMap(doc.data()))
//           .toList();

//       return Right(badges);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao buscar badges: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> unlockBadge(String userId, String badgeId) async {
//     try {
//       final badgeRef = _firestore.collection('user_badges').doc('${userId}_$badgeId');
      
//       await badgeRef.set({
//         'userId': userId,
//         'badgeId': badgeId,
//         'unlockedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
      
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao desbloquear badge: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> updateCooperationRating(String userId, double rating) async {
//     try {
//       await _firestore.collection('user_collaboration_data').doc(userId).update({
//         'cooperationRating': rating,
//         'lastActiveAt': FieldValue.serverTimestamp(),
//       });
      
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao atualizar rating: $e'));
//     }
//   }
// }

// // File: lib/data/services/collaborative/real_time_sync_service.dart
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../core/classes/collaborative/collaborative_pet_entity.dart';
// import '../../../core/classes/collaborative/collaborative_action.dart';

// class RealTimeSyncService {
//   final FirebaseFirestore _firestore;
//   final Map<String, StreamSubscription> _subscriptions = {};
//   final StreamController<CollaborativePetEntity> _petUpdatesController = 
//       StreamController<CollaborativePetEntity>.broadcast();
//   final StreamController<CollaborativeAction> _actionUpdatesController = 
//       StreamController<CollaborativeAction>.broadcast();

//   RealTimeSyncService(this._firestore);

//   // Stream para atualizações do pet
//   Stream<CollaborativePetEntity> get petUpdates => _petUpdatesController.stream;
  
//   // Stream para novas ações
//   Stream<CollaborativeAction> get actionUpdates => _actionUpdatesController.stream;

//   // Iniciar sincronização em tempo real para um pet
//   void startSyncForPet(String petId) {
//     if (_subscriptions.containsKey(petId)) {
//       return; // Já está sincronizando
//     }

//     final subscription = _firestore
//         .collection('collaborative_pets')
//         .doc(petId)
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.exists) {
//         final pet = CollaborativePetEntity.fromMap({
//           'id': snapshot.id,
//           ...snapshot.data()!,
//         });
//         _petUpdatesController.add(pet);
        
//         // Verificar se há novas ações
//         _checkForNewActions(pet);
//       }
//     });

//     _subscriptions[petId] = subscription;
//   }

//   // Parar sincronização para um pet
//   void stopSyncForPet(String petId) {
//     final subscription = _subscriptions.remove(petId);
//     subscription?.cancel();
//   }

//   // Verificar novas ações e emitir eventos
//   void _checkForNewActions(CollaborativePetEntity pet) {
//     if (pet.recentActions.isNotEmpty) {
//       final latestAction = pet.recentActions.first;
//       _actionUpdatesController.add(latestAction);
//     }
//   }

//   // Parar todas as sincronizações
//   void stopAllSync() {
//     for (final subscription in _subscriptions.values) {
//       subscription.cancel();
//     }
//     _subscriptions.clear();
//   }

//   // Limpar recursos
//   void dispose() {
//     stopAllSync();
//     _petUpdatesController.close();
//     _actionUpdatesController.close();
//   }
// }

// // File: lib/data/services/collaborative/collaboration_service.dart
// import 'package:dartz/dartz.dart';
// import '../../../core/classes/collaborative/collaborative_pet_entity.dart';
// import '../../../core/classes/collaborative/collaborative_action.dart';
// import '../../../core/classes/collaborative/user_collaboration_data.dart';
// import '../../../core/enums/collaborative/action_type.dart';
// import '../../../core/enums/collaborative/collaboration_status.dart';
// import '../../../core/config/collaborative/collaboration_config.dart';
// import '../../../core/errors/failure.dart';
// import '../../repositories/collaborative/collaborative_pet_repository.dart';
// import '../../repositories/collaborative/collaboration_repository.dart';

// class CollaborationService {
//   final CollaborativePetRepository _petRepository;
//   final CollaborationRepository _collaborationRepository;

//   const CollaborationService(this._petRepository, this._collaborationRepository);

//   // Executar ação colaborativa com validações
//   Future<Either<Failure, CollaborativeAction>> executeCollaborativeAction({
//     required String petId,
//     required String userId,
//     required ActionType actionType,
//   }) async {
//     try {
//       // 1. Verificar se o pet existe e o usuário pode interagir
//       final petResult = await _petRepository.getCollaborativePet(petId);
//       final pet = petResult.fold(
//         (failure) => throw Exception(failure.message),
//         (pet) => pet,
//       );

//       if (pet == null) {
//         return Left(ValidationFailure('Pet não encontrado'));
//       }

//       if (!pet.caretakerIds.contains(userId)) {
//         return Left(ValidationFailure('Usuário não é cuidador deste pet'));
//       }

//       if (pet.status != CollaborationStatus.activeCollaboration) {
//         return Left(ValidationFailure('Colaboração não está ativa'));
//       }

//       // 2. Verificar cooldown de ações
//       final lastAction = pet.recentActions
//           .where((action) => action.userId == userId)
//           .fold<DateTime?>(null, (latest, action) {
//         if (latest == null || action.timestamp.isAfter(latest)) {
//           return action.timestamp;
//         }
//         return latest;
//       });

//       if (lastAction != null) {
//         final timeSinceLastAction = DateTime.now().difference(lastAction);
//         if (timeSinceLastAction < CollaborationConfig.actionCooldown) {
//           return Left(ValidationFailure(
//             'Aguarde ${CollaborationConfig.actionCooldown.inMinutes} minutos entre ações'
//           ));
//         }
//       }

//       // 3. Criar a ação
//       final action = CollaborativeAction(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         userId: userId,
//         actionType: actionType,
//         timestamp: DateTime.now(),
//         anonymousName: pet.anonymousNames[userId] ?? 'Cuidador',
//         effects: Map<String, dynamic>.from(
//           CollaborationConfig.actionEffects[actionType.value] ?? {}
//         ),
//         experienceGained: actionType.experiencePoints,
//       );

//       // 4. Aplicar a ação
//       final addActionResult = await _petRepository.addCollaborativeAction(petId, action);
//       return addActionResult.fold(
//         (failure) => Left(failure),
//         (_) => Right(action),
//       );
//     } catch (e) {
//       return Left(UnknownFailure('Erro ao executar ação: $e'));
//     }
//   }

//   // Verificar se usuário pode solicitar adoção colaborativa
//   Future<Either<Failure, bool>> canRequestCollaborativeAdoption(String userId) async {
//     try {
//       final userDataResult = await _collaborationRepository.getUserCollaborationData(userId);
//       final userData = userDataResult.fold(
//         (failure) => throw Exception(failure.message),
//         (data) => data,
//       );

//       return Right(userData.hasAvailableSlots);
//     } catch (e) {
//       return Left(UnknownFailure('Erro ao verificar slots: $e'));
//     }
//   }

//   // Calcular estatísticas de colaboração
//   Future<Either<Failure, Map<String, dynamic>>> calculateCollaborationStats(String petId) async {
//     try {
//       final petResult = await _petRepository.getCollaborativePet(petId);
//       final pet = petResult.fold(
//         (failure) => throw Exception(failure.message),
//         (pet) => pet,
//       );

//       if (pet == null) {
//         return Left(ValidationFailure('Pet não encontrado'));
//       }

//       final stats = <String, dynamic>{};
      
//       // Estatísticas gerais
//       stats['totalActions'] = pet.recentActions.length;
//       stats['currentLevel'] = pet.currentLevel;
//       stats['progressToReveal'] = pet.progressToReveal;
//       stats['daysActive'] = pet.matchedAt != null 
//           ? DateTime.now().difference(pet.matchedAt!).inDays
//           : 0;

//       // Estatísticas por cuidador
//       final caretakerStats = <String, Map<String, dynamic>>{};
//       for (final caretakerId in pet.caretakerIds) {
//         final userActions = pet.recentActions
//             .where((action) => action.userId == caretakerId)
//             .toList();
        
//         caretakerStats[caretakerId] = {
//           'actionCount': userActions.length,
//           'contribution': pet.contributionStats[caretakerId] ?? 0,
//           'lastAction': userActions.isNotEmpty 
//               ? userActions.first.timestamp
//               : null,
//           'anonymousName': pet.anonymousNames[caretakerId] ?? 'Cuidador',
//         };
//       }
//       stats['caretakers'] = caretakerStats;

//       // Saúde geral do pet
//       stats['health'] = {
//         'hunger': pet.getHunger(),
//         'happiness': pet.getHappiness(),
//         'energy': pet.getEnergy(),
//         'health': pet.getHealth(),
//       };

//       return Right(stats);
//     } catch (e) {
//       return Left(UnknownFailure('Erro ao calcular estatísticas: $e'));
//     }
//   }

//   // Validar se reveal está disponível
//   Future<Either<Failure, bool>> validateRevealAvailability(String petId) async {
//     try {
//       final canRevealResult = await _petRepository.canRevealPartners(petId);
//       return canRevealResult;
//     } catch (e) {
//       return Left(UnknownFailure('Erro ao validar reveal: $e'));
//     }
//   }
// }

// // File: lib/data/services/collaborative/matchmaking_service.dart
// import 'package:dartz/dartz.dart';
// import '../../../core/classes/collaborative/collaborative_pet_entity.dart';
// import '../../../core/classes/collaborative/user_collaboration_data.dart';
// import '../../../core/enums/collaborative/collaboration_status.dart';
// import '../../../core/config/collaborative/collaboration_config.dart';
// import '../../../core/errors/failure.dart';
// import '../../repositories/collaborative/collaborative_pet_repository.dart';
// import '../../repositories/collaborative/collaboration_repository.dart';

// class MatchmakingService {
//   final CollaborativePetRepository _petRepository;
//   final CollaborationRepository _collaborationRepository;

//   const MatchmakingService(this._petRepository, this._collaborationRepository);

//   // Encontrar match para usuário
//   Future<Either<Failure, CollaborativePetEntity?>> findMatch(String userId) async {
//     try {
//       // 1. Buscar dados do usuário
//       final userDataResult = await _collaborationRepository.getUserCollaborationData(userId);
//       final userData = userDataResult.fold(
//         (failure) => throw Exception(failure.message),
//         (data) => data,
//       );

//       if (!userData.hasAvailableSlots) {
//         return Left(ValidationFailure('Usuário não tem slots disponíveis'));
//       }

//       // 2. Buscar pets disponíveis
//       final availablePetsResult = await _petRepository.getAvailableCollaborativePets();
//       final availablePets = availablePetsResult.fold(
//         (failure) => throw Exception(failure.message),
//         (pets) => pets,
//       );

//       if (availablePets.isEmpty) {
//         return const Right(null);
//       }

//       // 3. Filtrar pets compatíveis
//       final compatiblePets = <CollaborativePetEntity>[];
      
//       for (final pet in availablePets) {
//         if (await _isCompatible(userId, userData, pet)) {
//           compatiblePets.add(pet);
//         }
//       }

//       if (compatiblePets.isEmpty) {
//         return const Right(null);
//       }

//       // 4. Ordenar por compatibilidade e selecionar o melhor
//       compatiblePets.sort((a, b) {
//         final scoreA = _calculateCompatibilityScore(userData, a);
//         final scoreB = _calculateCompatibilityScore(userData, b);
//         return scoreB.compareTo(scoreA);
//       });

//       final selectedPet = compatiblePets.first;

//       // 5. Processar o match
//       final matchResult = await _petRepository.processMatch(
//         selectedPet.id,
//         [selectedPet.caretakerIds.first, userId],
//       );

//       return matchResult.fold(
//         (failure) => Left(failure),
//         (pet) => Right(pet),
//       );

//     } catch (e) {
//       return Left(UnknownFailure('Erro no matchmaking: $e'));
//     }
//   }

//   // Verificar compatibilidade entre usuário e pet
//   Future<bool> _isCompatible(
//     String userId, 
//     UserCollaborationData userData, 
//     CollaborativePetEntity pet
//   ) async {
//     // Verificar se o usuário não é o próprio criador do pet
//     if (pet.caretakerIds.contains(userId)) {
//       return false;
//     }

//     // Verificar se há apenas um cuidador esperando
//     if (pet.caretakerIds.length != 1) {
//       return false;
//     }

//     try {
//       // Buscar dados do outro cuidador
//       final otherCaretakerId = pet.caretakerIds.first;
//       final otherUserDataResult = await _collaborationRepository
//           .getUserCollaborationData(otherCaretakerId);
      
//       final otherUserData = otherUserDataResult.fold(
//         (failure) => null,
//         (data) => data,
//       );

//       if (otherUserData == null) {
//         return false;
//       }

//       // Verificar diferença de nível de experiência
//       final levelDifference = (userData.experienceLevel - otherUserData.experienceLevel).abs();
//       if (levelDifference > CollaborationConfig.maxLevelDifference) {
//         return false;
//       }

//       // Verificar rating mínimo
//       if (userData.cooperationRating < CollaborationConfig.minCooperationRating ||
//           otherUserData.cooperationRating < CollaborationConfig.minCooperationRating) {
//         return false;
//       }

//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Calcular score de compatibilidade
//   double _calculateCompatibilityScore(UserCollaborationData userData, CollaborativePetEntity pet) {
//     double score = 0.0;

//     // Score baseado no rating de cooperação
//     score += userData.cooperationRating * 20;

//     // Score baseado na experiência
//     score += userData.experienceLevel * 5;

//     // Score baseado no tipo de pet preferido
//     if (userData.preferredPetTypes.containsKey(pet.type)) {
//       score += userData.preferredPetTypes[pet.type]! * 10;
//     }

//     // Score baseado na atividade recente
//     if (userData.lastActiveAt != null) {
//       final daysSinceLastActive = DateTime.now().difference(userData.lastActiveAt!).inDays;
//       score += (7 - daysSinceLastActive.clamp(0, 7)) * 5; // Máximo 35 pontos
//     }

//     // Score baseado no histórico de reveals bem-sucedidos
//     score += userData.totalSuccessfulReveals * 3;

//     return score;
//   }

//   // Buscar pets recomendados para o usuário
//   Future<Either<Failure, List<CollaborativePetEntity>>> getRecommendedPets(String userId) async {
//     try {
//       final userDataResult = await _collaborationRepository.getUserCollaborationData(userId);
//       final userData = userDataResult.fold(
//         (failure) => throw Exception(failure.message),
//         (data) => data,
//       );

//       final availablePetsResult = await _petRepository.getAvailableCollaborativePets();
//       final availablePets = availablePetsResult.fold(
//         (failure) => throw Exception(failure.message),
//         (pets) => pets,
//       );

//       final recommendedPets = <CollaborativePetEntity>[];
      
//       for (final pet in availablePets) {
//         if (await _isCompatible(userId, userData, pet)) {
//           recommendedPets.add(pet);
//         }
//       }

//       // Ordenar por score de compatibilidade
//       recommendedPets.sort((a, b) {
//         final scoreA = _calculateCompatibilityScore(userData, a);
//         final scoreB = _calculateCompatibilityScore(userData, b);
//         return scoreB.compareTo(scoreA);
//       });

//       return Right(recommendedPets.take(10).toList());
//     } catch (e) {
//       return Left(UnknownFailure('Erro ao buscar pets recomendados: $e'));
//     }
//   }
// }



// // File: lib/domain/usecases/collaborative/request_collaborative_adoption.dart
// import 'package:dartz/dartz.dart';
// import '../../../core/classes/collaborative/collaborative_pet_entity.dart';
// import '../../../core/errors/failure.dart';
// import '../../../data/repositories/collaborative/collaborative_pet_repository.dart';
// import '../../../data/repositories/collaborative/collaboration_repository.dart';
// import '../../../data/services/collaborative/collaboration_service.dart';

// class RequestCollaborativeAdoption {
//   final CollaborativePetRepository _petRepository;
//   final CollaborationService _collaborationService;

//   const RequestCollaborativeAdoption(this._petRepository, this._collaborationService);

//   Future<Either<Failure, CollaborativePetEntity>> call(String userId, String petId) async {
//     try {
//       // 1. Verificar se usuário pode solicitar adoção
//       final canRequestResult = await _collaborationService.canRequestCollaborativeAdoption(userId);
//       final canRequest = canRequestResult.fold(
//         (failure) => throw Exception(failure.message),
//         (canRequest) => canRequest,
//       );

//       if (!canRequest) {
//         return Left(ValidationFailure('Usuário não pode solicitar mais adoções colaborativas'));
//       }

//       // 2. Adicionar à lista de espera
//       final addToWaitingResult = await _petRepository.addToWaitingList(userId, petId);
//       return addToWaitingResult.fold(
//         (failure) => Left(failure),
//         (_) async {
//           // 3. Buscar pet atualizado
//           final petResult = await _petRepository.getCollaborativePet(petId);
//           return petResult.fold(
//             (failure) => Left(failure),
//             (pet) => pet != null ? Right(pet) : Left(ValidationFailure('Pet não encontrado')),
//           );
//         },
//       );
//     } catch (e) {
//       return Left(UnknownFailure('Erro ao solicitar adoção colaborativa: $e'));
//     }
//   }
// }

// // File: lib/domain/usecases/collaborative/perform_collaborative_action.dart
// import 'package:dartz/dartz.dart';
// import '../../../core/classes/collaborative/collaborative_action.dart';
// import '../../../core/enums/collaborative/action_type.dart';
// import '../../../core/errors/failure.dart';
// import '../../../data/services/collaborative/collaboration_service.dart';

// class PerformCollaborativeAction {
//   final CollaborationService _collaborationService;

//   const PerformCollaborativeAction(this._collaborationService);

//   Future<Either<Failure, CollaborativeAction>> call({
//     required String petId,
//     required String userId,
//     required ActionType actionType,
//   }) async {
//     return await _collaborationService.executeCollaborativeAction(
//       petId: petId,
//       userId: userId,
//       actionType: actionType,
//     );
//   }
// }

// // File: lib/domain/usecases/collaborative/find_collaboration_match.dart
// import 'package:dartz/dartz.dart';
// import '../../../core/classes/collaborative/collaborative_pet_entity.dart';
// import '../../../core/errors/failure.dart';
// import '../../../data/services/collaborative/matchmaking_service.dart';

// class FindCollaborationMatch {
//   final MatchmakingService _matchmakingService;

//   const FindCollaborationMatch(this._matchmakingService);

//   Future<Either<Failure, CollaborativePetEntity?>> call(String userId) async {
//     return await _matchmakingService.findMatch(userId);
//   }
// }

// // File: lib/presentation/providers/collaborative/collaborative_pet_provider.dart
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/classes/collaborative/collaborative_pet_entity.dart';
// import '../../../core/classes/collaborative/collaborative_action.dart';
// import '../../../core/enums/collaborative/action_type.dart';
// import '../../../core/enums/collaborative/collaboration_status.dart';
// import '../../../domain/usecases/collaborative/request_collaborative_adoption.dart';
// import '../../../domain/usecases/collaborative/perform_collaborative_action.dart';
// import '../../../data/services/collaborative/real_time_sync_service.dart';

// @immutable
// class CollaborativePetState {
//   final List<CollaborativePetEntity> availablePets;
//   final List<CollaborativePetEntity> myCollaborativePets;
//   final List<String> waitingList;
//   final Map<String, List<CollaborativeAction>> recentActions;
//   final bool isLoading;
//   final String? errorMessage;
//   final bool isListeningToUpdates;
//   final DateTime? lastSyncTime;

//   const CollaborativePetState({
//     this.availablePets = const [],
//     this.myCollaborativePets = const [],
//     this.waitingList = const [],
//     this.recentActions = const {},
//     this.isLoading = false,
//     this.errorMessage,
//     this.isListeningToUpdates = false,
//     this.lastSyncTime,
//   });

//   CollaborativePetState copyWith({
//     List<CollaborativePetEntity>? availablePets,
//     List<CollaborativePetEntity>? myCollaborativePets,
//     List<String>? waitingList,
//     Map<String, List<CollaborativeAction>>? recentActions,
//     bool? isLoading,
//     String? errorMessage,
//     bool? isListeningToUpdates,
//     DateTime? lastSyncTime,
//   }) {
//     return CollaborativePetState(
//       availablePets: availablePets ?? this.availablePets,
//       myCollaborativePets: myCollaborativePets ?? this.myCollaborativePets,
//       waitingList: waitingList ?? this.waitingList,
//       recentActions: recentActions ?? this.recentActions,
//       isLoading: isLoading ?? this.isLoading,
//       errorMessage: errorMessage,
//       isListeningToUpdates: isListeningToUpdates ?? this.isListeningToUpdates,
//       lastSyncTime: lastSyncTime ?? this.lastSyncTime,
//     );
//   }
// }

// class CollaborativePetNotifier extends StateNotifier<CollaborativePetState> {
//   final RequestCollaborativeAdoption _requestAdoption;
//   final PerformCollaborativeAction _performAction;
//   final RealTimeSyncService _syncService;

//   CollaborativePetNotifier(
//     this._requestAdoption,
//     this._performAction,
//     this._syncService,
//   ) : super(const CollaborativePetState()) {
//     _initializeRealTimeSync();
//   }

//   void _initializeRealTimeSync() {
//     // Escutar atualizações de pets
//     _syncService.petUpdates.listen((pet) {
//       _updatePetInState(pet);
//     });

//     // Escutar novas ações
//     _syncService.actionUpdates.listen((action) {
//       _addActionToState(action);
//     });
//   }

//   // Buscar pets disponíveis para adoção colaborativa
//   Future<void> loadAvailablePets() async {
//     state = state.copyWith(isLoading: true, errorMessage: null);
    
//     // Simulate repository call - would be injected in real implementation
//     // final result = await _petRepository.getAvailableCollaborativePets();
    
//     // For now, create mock data
//     await Future.delayed(const Duration(seconds: 1));
    
//     state = state.copyWith(
//       isLoading: false,
//       availablePets: _createMockAvailablePets(),
//       lastSyncTime: DateTime.now(),
//     );
//   }

//   // Solicitar adoção colaborativa
//   Future<void> requestCollaborativeAdoption(String userId, String petId) async {
//     state = state.copyWith(isLoading: true, errorMessage: null);
    
//     final result = await _requestAdoption.call(userId, petId);
    
//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           isLoading: false,
//           errorMessage: failure.message,
//         );
//       },
//       (pet) {
//         state = state.copyWith(
//           isLoading: false,
//           waitingList: [...state.waitingList, petId],
//         );
        
//         // Iniciar sync em tempo real se há match
//         if (pet.status == CollaborationStatus.activeCollaboration) {
//           startRealTimeSync(petId);
//         }
//       },
//     );
//   }

//   // Executar ação no pet
//   Future<void> performAction(String petId, String userId, ActionType action) async {
//     final result = await _performAction.call(
//       petId: petId,
//       userId: userId,
//       actionType: action,
//     );
    
//     result.fold(
//       (failure) {
//         state = state.copyWith(errorMessage: failure.message);
//       },
//       (collaborativeAction) {
//         _addActionToState(collaborativeAction);
//       },
//     );
//   }

//   // Configurar sync em tempo real
//   void startRealTimeSync(String petId) {
//     _syncService.startSyncForPet(petId);
//     state = state.copyWith(isListeningToUpdates: true);
//   }

//   void stopRealTimeSync(String petId) {
//     _syncService.stopSyncForPet(petId);
    
//     // Verificar se ainda há pets sendo sincronizados
//     final hasActivePets = state.myCollaborativePets
//         .any((pet) => pet.status == CollaborationStatus.activeCollaboration);
    
//     state = state.copyWith(isListeningToUpdates: hasActivePets);
//   }

//   // Atualizar pet no estado
//   void _updatePetInState(CollaborativePetEntity updatedPet) {
//     final myPets = state.myCollaborativePets.map((pet) {
//       return pet.id == updatedPet.id ? updatedPet : pet;
//     }).toList();
    
//     final availablePets = state.availablePets.map((pet) {
//       return pet.id == updatedPet.id ? updatedPet : pet;
//     }).toList();
    
//     state = state.copyWith(
//       myCollaborativePets: myPets,
//       availablePets: availablePets,
//       lastSyncTime: DateTime.now(),
//     );
//   }

//   // Adicionar ação ao estado
//   void _addActionToState(CollaborativeAction action) {
//     final currentActions = Map<String, List<CollaborativeAction>>.from(state.recentActions);
//     final petActions = currentActions[action.userId] ?? [];
    
//     currentActions[action.userId] = [action, ...petActions].take(10).toList();
    
//     state = state.copyWith(recentActions: currentActions);
//   }

//   // Criar dados mock para teste
//   List<CollaborativePetEntity> _createMockAvailablePets() {
//     return [
//       CollaborativePetEntity(
//         id: 'pet_001',
//         name: 'Luna',
//         type: 'cat',
//         imageUrl: 'assets/images/pets/cat_luna.png',
//         collaborationId: 'collab_001',
//         caretakerIds: ['user_123'],
//         status: CollaborationStatus.waitingForPartner,
//         revealStatus: RevealStatus.notAvailable,
//         currentLevel: 1,
//         revealLevel: 10,
//         maxLevel: 50,
//         createdAt: DateTime.now().subtract(const Duration(hours: 2)),
//         contributionStats: {'user_123': 5},
//         recentActions: [],
//         stats: {'hunger': 60, 'happiness': 70, 'energy': 50, 'health': 100},
//         totalExperience: 50,
//         anonymousNames: {'user_123': 'Cuidador A'},
//       ),
//       CollaborativePetEntity(
//         id: 'pet_002',
//         name: 'Max',
//         type: 'dog',
//         imageUrl: 'assets/images/pets/dog_max.png',
//         collaborationId: 'collab_002',
//         caretakerIds: ['user_456'],
//         status: CollaborationStatus.waitingForPartner,
//         revealStatus: RevealStatus.notAvailable,
//         currentLevel: 3,
//         revealLevel: 10,
//         maxLevel: 50,
//         createdAt: DateTime.now().subtract(const Duration(hours: 1)),
//         contributionStats: {'user_456': 12},
//         recentActions: [],
//         stats: {'hunger': 45, 'happiness': 80, 'energy': 65, 'health': 95},
//         totalExperience: 150,
//         anonymousNames: {'user_456': 'Cuidador A'},
//       ),
//     ];
//   }

//   @override
//   void dispose() {
//     _syncService.dispose();
//     super.dispose();
//   }
// }

// // File: lib/presentation/providers/collaborative/matchmaking_provider.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/classes/collaborative/collaborative_pet_entity.dart';
// import '../../../domain/usecases/collaborative/find_collaboration_match.dart';

// @immutable
// class MatchmakingState {
//   final List<CollaborativePetEntity> recommendedPets;
//   final CollaborativePetEntity? currentMatch;
//   final bool isSearching;
//   final bool hasFoundMatch;
//   final String? errorMessage;
//   final DateTime? lastSearchTime;

//   const MatchmakingState({
//     this.recommendedPets = const [],
//     this.currentMatch,
//     this.isSearching = false,
//     this.hasFoundMatch = false,
//     this.errorMessage,
//     this.lastSearchTime,
//   });

//   MatchmakingState copyWith({
//     List<CollaborativePetEntity>? recommendedPets,
//     CollaborativePetEntity? currentMatch,
//     bool? isSearching,
//     bool? hasFoundMatch,
//     String? errorMessage,
//     DateTime? lastSearchTime,
//   }) {
//     return MatchmakingState(
//       recommendedPets: recommendedPets ?? this.recommendedPets,
//       currentMatch: currentMatch ?? this.currentMatch,
//       isSearching: isSearching ?? this.isSearching,
//       hasFoundMatch: hasFoundMatch ?? this.hasFoundMatch,
//       errorMessage: errorMessage,
//       lastSearchTime: lastSearchTime ?? this.lastSearchTime,
//     );
//   }
// }

// class MatchmakingNotifier extends StateNotifier<MatchmakingState> {
//   final FindCollaborationMatch _findMatch;

//   MatchmakingNotifier(this._findMatch) : super(const MatchmakingState());

//   // Buscar match para o usuário
//   Future<void> findMatch(String userId) async {
//     state = state.copyWith(
//       isSearching: true,
//       errorMessage: null,
//       hasFoundMatch: false,
//     );

//     final result = await _findMatch.call(userId);

//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           isSearching: false,
//           errorMessage: failure.message,
//         );
//       },
//       (match) {
//         state = state.copyWith(
//           isSearching: false,
//           currentMatch: match,
//           hasFoundMatch: match != null,
//           lastSearchTime: DateTime.now(),
//         );
//       },
//     );
//   }

//   // Limpar match atual
//   void clearMatch() {
//     state = state.copyWith(
//       currentMatch: null,
//       hasFoundMatch: false,
//     );
//   }

//   // Rejeitar match e buscar próximo
//   Future<void> rejectMatchAndFindNext(String userId) async {
//     clearMatch();
//     await findMatch(userId);
//   }
// }

// // Provider definitions
// final collaborativePetProvider = StateNotifierProvider<CollaborativePetNotifier, CollaborativePetState>((ref) {
//   // These would be injected from dependency injection container
//   throw UnimplementedError('Provider dependencies need to be configured');
// });

// final matchmakingProvider = StateNotifierProvider<MatchmakingNotifier, MatchmakingState>((ref) {
//   // These would be injected from dependency injection container
//   throw UnimplementedError('Provider dependencies need to be configured');
// });

// // File: lib/presentation/screens/collaborative_adoption/collaborative_adoption_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../providers/collaborative/collaborative_pet_provider.dart';
// import '../../providers/collaborative/matchmaking_provider.dart';
// import '../../widgets/collaborative_pet/collaborative_pet_card.dart';
// import '../../widgets/shared/collaborative/collaboration_badge_widget.dart';

// class CollaborativeAdoptionScreen extends ConsumerStatefulWidget {
//   const CollaborativeAdoptionScreen({super.key});

//   @override
//   ConsumerState<CollaborativeAdoptionScreen> createState() => _CollaborativeAdoptionScreenState();
// }

// class _CollaborativeAdoptionScreenState extends ConsumerState<CollaborativeAdoptionScreen>
//     with TickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
    
//     // Carregar dados iniciais
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(collaborativePetProvider.notifier).loadAvailablePets();
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final collaborativeState = ref.watch(collaborativePetProvider);
//     final matchmakingState = ref.watch(matchmakingProvider);

//     return Scaffold(
//       backgroundColor: const Color(0xFF1A1A2E),
//       appBar: AppBar(
//         title: const Text(
//           'Adoção Colaborativa',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         backgroundColor: const Color(0xFF16213E),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.auto_awesome, color: Colors.amber),
//             onPressed: () => _showSmartMatchDialog(context),
//             tooltip: 'Match Inteligente',
//           ),
//           IconButton(
//             icon: const Icon(Icons.emoji_events, color: Colors.orange),
//             onPressed: () => _showBadgesDialog(context),
//             tooltip: 'Badges Colaborativos',
//           ),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           indicatorColor: Colors.amber,
//           labelColor: Colors.white,
//           unselectedLabelColor: Colors.grey[400],
//           tabs: const [
//             Tab(
//               icon: Icon(Icons.pets),
//               text: 'Disponíveis',
//             ),
//             Tab(
//               icon: Icon(Icons.favorite),
//               text: 'Meus Pets',
//             ),
//             Tab(
//               icon: Icon(Icons.timeline),
//               text: 'Atividades',
//             ),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildAvailablePetsTab(context, collaborativeState),
//           _buildMyPetsTab(context, collaborativeState),
//           _buildActivitiesTab(context, collaborativeState),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: matchmakingState.isSearching 
//             ? null 
//             : () => _startSmartMatch(context),
//         backgroundColor: Colors.amber,
//         foregroundColor: Colors.black,
//         icon: matchmakingState.isSearching 
//             ? const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
//                 ),
//               )
//             : const Icon(Icons.auto_awesome),
//         label: Text(
//           matchmakingState.isSearching ? 'Buscando...' : 'Match Rápido',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }

//   Widget _buildAvailablePetsTab(BuildContext context, CollaborativePetState state) {
//     if (state.isLoading) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: Colors.amber),
//             SizedBox(height: 16),
//             Text(
//               'Buscando pets disponíveis...',
//               style: TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//       );
//     }

//     if (state.errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.error_outline,
//               color: Colors.red,
//               size: 64,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Erro: ${state.errorMessage}',
//               style: const TextStyle(color: Colors.red),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => ref.read(collaborativePetProvider.notifier).loadAvailablePets(),
//               child: const Text('Tentar Novamente'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (state.availablePets.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.pets,
//               color: Colors.grey[400],
//               size: 64,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Nenhum pet disponível no momento',
//               style: TextStyle(
//                 color: Colors.grey[400],
//                 fontSize: 18,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Tente novamente em alguns minutos',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () => ref.read(collaborativePetProvider.notifier).loadAvailablePets(),
//               icon: const Icon(Icons.refresh),
//               label: const Text('Atualizar'),
//             ),
//           ],
//         ),
//       );
//     }

//     return RefreshIndicator(
//       onRefresh: () async {
//         ref.read(collaborativePetProvider.notifier).loadAvailablePets();
//       },
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: state.availablePets.length,
//         itemBuilder: (context, index) {
//           final pet = state.availablePets[index];
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 16),
//             child: CollaborativePetCard(
//               pet: pet,
//               onAdopt: () => _requestAdoption(context, pet.id),
//               showAdoptButton: true,
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildMyPetsTab(BuildContext context, CollaborativePetState state) {
//     if (state.myCollaborativePets.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.favorite_border,
//               color: Colors.grey[400],
//               size: 64,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Você ainda não tem pets colaborativos',
//               style: TextStyle(
//                 color: Colors.grey[400],
//                 fontSize: 18,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Adote um pet na aba "Disponíveis"',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: state.myCollaborativePets.length,
//       itemBuilder: (context, index) {
//         final pet = state.myCollaborativePets[index];
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 16),
//           child: CollaborativePetCard(
//             pet: pet,
//             onTap: () => _openPetDetail(context, pet),
//             showProgress: true,
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildActivitiesTab(BuildContext context, CollaborativePetState state) {
//     final allActions = state.recentActions.values
//         .expand((actions) => actions)
//         .toList()
//       ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

//     if (allActions.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.timeline,
//               color: Colors.grey[400],
//               size: 64,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Nenhuma atividade ainda',
//               style: TextStyle(
//                 color: Colors.grey[400],
//                 fontSize: 18,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Comece a cuidar dos seus pets!',
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: allActions.length,
//       itemBuilder: (context, index) {
//         final action = allActions[index];
//         return Card(
//           color: const Color(0xFF16213E),
//           margin: const EdgeInsets.only(bottom: 8),
//           child: ListTile(
//             leading: CircleAvatar(
//               backgroundColor: Colors.amber,
//               child: Text(
//                 action.actionType.icon,
//                 style: const TextStyle(fontSize: 18),
//               ),
//             ),
//             title: Text(
//               '${action.anonymousName} ${action.actionType.displayName}',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             subtitle: Text(
//               _formatTimeAgo(action.timestamp),
//               style: TextStyle(color: Colors.grey[400]),
//             ),
//             trailing: Text(
//               '+${action.experienceGained} XP',
//               style: const TextStyle(
//                 color: Colors.amber,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _requestAdoption(BuildContext context, String petId) {
//     // Simular userId - em implementação real viria do auth
//     const userId = 'current_user_id';
    
//     ref.read(collaborativePetProvider.notifier).requestCollaborativeAdoption(userId, petId);
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Solicitação de adoção enviada!'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   void _openPetDetail(BuildContext context, pet) {
//     Navigator.pushNamed(
//       context,
//       '/collaborative-pet-detail',
//       arguments: pet,
//     );
//   }

//   void _startSmartMatch(BuildContext context) {
//     const userId = 'current_user_id';
//     ref.read(matchmakingProvider.notifier).findMatch(userId);
//   }

//   void _showSmartMatchDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF16213E),
//         title: const Text(
//           '🤖 Match Inteligente',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: const Text(
//           'O sistema irá encontrar o pet mais compatível com seu perfil de cuidador.\n\nBaseado em:\n• Seu nível de experiência\n• Tipos de pet preferidos\n• Horário de atividade\n• Rating de cooperação',
//           style: TextStyle(color: Colors.grey),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancelar'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _startSmartMatch(context);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
//             child: const Text(
//               'Encontrar Match',
//               style: TextStyle(color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showBadgesDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF16213E),
//         title: const Text(
//           '🏆 Badges Colaborativos',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: SizedBox(
//           width: double.maxFinite,
//           height: 300,
//           child: ListView(
//             children: const [
//               CollaborationBadgeWidget(
//                 badgeId: 'first_collaboration',
//                 name: 'Primeira Colaboração',
//                 description: 'Complete sua primeira adoção colaborativa',
//                 icon: '🤝',
//                 isUnlocked: true,
//               ),
//               CollaborationBadgeWidget(
//                 badgeId: 'pet_master_duo',
//                 name: 'Pet Master Duo',
//                 description: 'Alcance nível máximo com 10 pets',
//                 icon: '👑',
//                 isUnlocked: false,
//                 progress: 0.3,
//               ),
//               CollaborationBadgeWidget(
//                 badgeId: 'reveal_master',
//                 name: 'Reveal Master',
//                 description: 'Complete 10 reveals bem-sucedidos',
//                 icon: '✨',
//                 isUnlocked: false,
//                 progress: 0.7,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Fechar'),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatTimeAgo(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);
    
//     if (difference.inMinutes < 1) {
//       return 'Agora mesmo';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes}m atrás';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours}h atrás';
//     } else {
//       return '${difference.inDays}d atrás';
//     }
//   }
// }

// // File: lib/presentation/screens/collaborative_adoption/active_collaboration_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/classes/collaborative/collaborative_pet_entity.dart';
// import '../../../core/enums/collaborative/action_type.dart';
// import '../../../core/enums/collaborative/collaboration_status.dart';
// import '../../providers/collaborative/collaborative_pet_provider.dart';
// import '../../widgets/collaborative_pet/real_time_actions_feed.dart';
// import '../../widgets/collaborative_pet/collaboration_stats_widget.dart';
// import '../../widgets/shared/collaborative/reveal_progress_indicator.dart';

// class ActiveCollaborationScreen extends ConsumerStatefulWidget {
//   final CollaborativePetEntity pet;

//   const ActiveCollaborationScreen({
//     super.key,
//     required this.pet,
//   });

//   @override
//   ConsumerState<ActiveCollaborationScreen> createState() => _ActiveCollaborationScreenState();
// }

// class _ActiveCollaborationScreenState extends ConsumerState<ActiveCollaborationScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _petAnimationController;
//   late AnimationController _actionAnimationController;
//   bool _isPerformingAction = false;

//   @override
//   void initState() {
//     super.initState();
//     _petAnimationController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat();
    
//     _actionAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     // Iniciar sincronização em tempo real
//     ref.read(collaborativePetProvider.notifier).startRealTimeSync(widget.pet.id);
//   }

//   @override
//   void dispose() {
//     _petAnimationController.dispose();
//     _actionAnimationController.dispose();
//     ref.read(collaborativePetProvider.notifier).stopRealTimeSync(widget.pet.id);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(collaborativePetProvider);
    
//     // Encontrar o pet atualizado no estado
//     final currentPet = state.myCollaborativePets
//         .firstWhere((p) => p.id == widget.pet.id, orElse: () => widget.pet);

//     return Scaffold(
//       backgroundColor: const Color(0xFF1A1A2E),
//       appBar: AppBar(
//         title: Text(
//           currentPet.name,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: const Color(0xFF16213E),
//         elevation: 0,
//         actions: [
//           if (currentPet.canReveal)
//             IconButton(
//               icon: const Icon(Icons.visibility, color: Colors.amber),
//               onPressed: () => _showRevealDialog(context, currentPet),
//               tooltip: 'Revelar Parceiro',
//             ),
//           IconButton(
//             icon: Icon(
//               state.isListeningToUpdates ? Icons.sync : Icons.sync_disabled,
//               color: state.isListeningToUpdates ? Colors.green : Colors.grey,
//             ),
//             onPressed: null,
//             tooltip: state.isListeningToUpdates ? 'Sincronização Ativa' : 'Sincronização Inativa',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Pet Display Section
//           Expanded(
//             flex: 3,
//             child: Container(
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [Color(0xFF16213E), Color(0xFF1A1A2E)],
//                 ),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Status and Level Info
//                   Container(
//                     margin: const EdgeInsets.all(16),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.black26,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         _buildStatItem('Nível', '${currentPet.currentLevel}', Colors.amber),
//                         _buildStatItem('Fome', '${currentPet.getHunger()}', Colors.orange),
//                         _buildStatItem('Felicidade', '${currentPet.getHappiness()}', Colors.pink),
//                         _buildStatItem('Energia', '${currentPet.getEnergy()}', Colors.blue),
//                       ],
//                     ),
//                   ),

//                   // Pet Avatar
//                   AnimatedBuilder(
//                     animation: _petAnimationController,
//                     builder: (context, child) {
//                       return Transform.scale(
//                         scale: 1.0 + (0.05 * _petAnimationController.value),
//                         child: Container(
//                           width: 200,
//                           height: 200,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.amber.withOpacity(0.1),
//                             border: Border.all(
//                               color: Colors.amber,
//                               width: 3,
//                             ),
//                           ),
//                           child: Center(
//                             child: Text(
//                               _getPetEmoji(currentPet.type),
//                               style: const TextStyle(fontSize: 80),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 16),

//                   // Pet Name and Partner Info
//                   Text(
//                     currentPet.name,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   if (currentPet.isRevealed)
//                     const Text(
//                       'Parceiros Revelados! 👥',
//                       style: TextStyle(
//                         color: Colors.amber,
//                         fontSize: 16,
//                       ),
//                     )
//                   else
//                     Text(
//                       'Cuidando com ${_getPartnerName(currentPet)}',
//                       style: TextStyle(
//                         color: Colors.grey[400],
//                         fontSize: 16,
//                       ),
//                     ),

//                   const SizedBox(height: 16),

//                   // Reveal Progress
//                   if (!currentPet.isRevealed)
//                     RevealProgressIndicator(
//                       currentLevel: currentPet.currentLevel,
//                       revealLevel: currentPet.revealLevel,
//                       canReveal: currentPet.canReveal,
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           // Action Buttons Section
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 if (_isPerformingAction)
//                   const LinearProgressIndicator(
//                     color: Colors.amber,
//                     backgroundColor: Colors.grey,
//                   ),
//                 const SizedBox(height: 16),
//                 _buildActionButtons(context, currentPet),
//               ],
//             ),
//           ),

//           // Real-time Actions Feed
//           Expanded(
//             flex: 2,
//             child: Container(
//               decoration: const BoxDecoration(
//                 color: Color(0xFF16213E),
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Row(
//                       children: [
//                         const Icon(
//                           Icons.timeline,
//                           color: Colors.amber,
//                         ),
//                         const SizedBox(width: 8),
//                         const Text(
//                           'Atividades Recentes',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const Spacer(),
//                         if (state.lastSyncTime != null)
//                           Text(
//                             'Atualizado: ${_formatTime(state.lastSyncTime!)}',
//                             style: TextStyle(
//                               color: Colors.grey[400],
//                               fontSize: 12,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: RealTimeActionsFeed(
//                       petId: currentPet.id,
//                       actions: currentPet.recentActions,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, String value, Color color) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             color: color,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.grey[400],
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons(BuildContext context, CollaborativePetEntity pet) {
//     return Wrap(
//       spacing: 12,
//       runSpacing: 12,
//       children: ActionType.values.map((action) {
//         return _buildActionButton(context, pet, action);
//       }).toList(),
//     );
//   }

//   Widget _buildActionButton(BuildContext context, CollaborativePetEntity pet, ActionType action) {
//     return AnimatedBuilder(
//       animation: _actionAnimationController,
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _isPerformingAction ? 0.95 : 1.0,
//           child: ElevatedButton(
//             onPressed: _isPerformingAction ? null : () => _performAction(context, pet, action),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.amber,
//               foregroundColor: Colors.black,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   action.icon,
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   action.displayName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _performAction(BuildContext context, CollaborativePetEntity pet, ActionType action) async {
//     setState(() {
//       _isPerformingAction = true;
//     });

//     _actionAnimationController.forward().then((_) {
//       _actionAnimationController.reverse();
//     });

//     const userId = 'current_user_id'; // Em implementação real, viria do auth
    
//     await ref.read(collaborativePetProvider.notifier).performAction(
//       pet.id,
//       userId,
//       action,
//     );

//     setState(() {
//       _isPerformingAction = false;
//     });

//     // Mostrar feedback visual
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('${action.displayName} realizado! +${action.experiencePoints} XP'),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   void _showRevealDialog(BuildContext context, CollaborativePetEntity pet) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF16213E),
//         title: const Text(
//           '🎭 Revelar Parceiro?',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: Text(
//           'Parabéns! ${pet.name} atingiu o nível ${pet.revealLevel}!\n\n'
//           'Vocês cuidaram tão bem que agora podem se conhecer. '
//           'Deseja revelar sua identidade para seu parceiro?\n\n'
//           '⚠️ Esta ação requer que ambos aceitem.',
//           style: const TextStyle(color: Colors.grey),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Mais Tarde'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _requestReveal(context, pet);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
//             child: const Text(
//               'Sim, Revelar!',
//               style: TextStyle(color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _requestReveal(BuildContext context, CollaborativePetEntity pet) {
//     // Implementar lógica de reveal
//     Navigator.pushNamed(
//       context,
//       '/reveal-request',
//       arguments: pet,
//     );
//   }

//   String _getPetEmoji(String type) {
//     switch (type.toLowerCase()) {
//       case 'cat':
//         return '🐱';
//       case 'dog':
//         return '🐶';
//       case 'bird':
//         return '🐦';
//       case 'fish':
//         return '🐠';
//       case 'rabbit':
//         return '🐰';
//       default:
//         return '🐾';
//     }
//   }

//   String _getPartnerName(CollaborativePetEntity pet) {
//     const currentUserId = 'current_user_id';
//     final partnerNames = pet.anonymousNames.entries
//         .where((entry) => entry.key != currentUserId)
//         .map((entry) => entry.value);
    
//     return partnerNames.isNotEmpty ? partnerNames.first : 'Parceiro Anônimo';
//   }

//   String _formatTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);
    
//     if (difference.inMinutes < 1) {
//       return 'agora';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes}m';
//     } else {
//       return '${difference.inHours}h';
//     }
//   }
// }

// // File: lib/presentation/screens/reveal_system/reveal_request_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/classes/collaborative/collaborative_pet_entity.dart';
// import '../../../core/classes/collaborative/reveal_request.dart';
// import '../../../core/enums/collaborative/reveal_status.dart';
// import '../../providers/collaborative/reveal_provider.dart';

// class RevealRequestScreen extends ConsumerStatefulWidget {
//   final CollaborativePetEntity pet;

//   const RevealRequestScreen({
//     super.key,
//     required this.pet,
//   });

//   @override
//   ConsumerState<RevealRequestScreen> createState() => _RevealRequestScreenState();
// }

// class _RevealRequestScreenState extends ConsumerState<RevealRequestScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _confettiController;
//   bool _hasResponded = false;

//   @override
//   void initState() {
//     super.initState();
//     _pulseController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat();
    
//     _confettiController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     );
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _confettiController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final revealState = ref.watch(revealProvider);

//     return Scaffold(
//       backgroundColor: const Color(0xFF1A1A2E),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               children: [
//                 const SizedBox(height: 40),
                
//                 // Header com ícone animado
//                 AnimatedBuilder(
//                   animation: _pulseController,
//                   builder: (context, child) {
//                     return Transform.scale(
//                       scale: 1.0 + (0.1 * _pulseController.value),
//                       child: Container(
//                         width: 120,
//                         height: 120,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.amber.withOpacity(0.2),
//                           border: Border.all(
//                             color: Colors.amber,
//                             width: 3,
//                           ),
//                         ),
//                         child: const Center(
//                           child: Text(
//                             '🎭',
//                             style: TextStyle(fontSize: 50),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 32),

//                 // Título principal
//                 const Text(
//                   'Momento Especial!',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),

//                 const SizedBox(height: 16),

//                 // Pet info
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF16213E),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: Colors.amber.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Text(
//                         widget.pet.name,
//                         style: const TextStyle(
//                           color: Colors.amber,
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Nível ${widget.pet.currentLevel}',
//                         style: TextStyle(
//                           color: Colors.grey[400],
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         '🎉 Parabéns! Vocês cuidaram tão bem juntos que agora podem se conhecer!',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 32),

//                 // Explicação do reveal
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.deepPurple.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: Colors.deepPurple.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Row(
//                         children: [
//                           Icon(
//                             Icons.info_outline,
//                             color: Colors.deepPurple,
//                           ),
//                           SizedBox(width: 8),
//                           Text(
//                             'Como funciona o Reveal:',
//                             style: TextStyle(
//                               color: Colors.deepPurple,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       _buildInfoItem(
//                         '👥',
//                         'Ambos precisam aceitar',
//                         'Seu parceiro também será perguntado se quer se revelar',
//                       ),
//                       const SizedBox(height: 12),
//                       _buildInfoItem(
//                         '⏰',
//                         'Tempo limitado',
//                         'Esta oportunidade expira em 48 horas',
//                       ),
//                       const SizedBox(height: 12),
//                       _buildInfoItem(
//                         '🤝',
//                         'Consentimento mútuo',
//                         'Se alguém rejeitar, continuam anônimos',
//                       ),
//                       const SizedBox(height: 12),
//                       _buildInfoItem(
//                         '💫',
//                         'Experiência única',
//                         'Primeira vez que se conhecem após cuidar juntos!',
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 // Status do reveal
//                 if (revealState.isLoading)
//                   const Column(
//                     children: [
//                       CircularProgressIndicator(color: Colors.amber),
//                       SizedBox(height: 16),
//                       Text(
//                         'Processando sua resposta...',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ],
//                   )
//                 else if (_hasResponded)
//                   _buildResponseStatus(revealState)
//                 else
//                   _buildActionButtons(),

//                 const SizedBox(height: 20),

//                 // Estatísticas da colaboração
//                 _buildCollaborationStats(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoItem(String emoji, String title, String description) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           emoji,
//           style: const TextStyle(fontSize: 20),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 description,
//                 style: TextStyle(
//                   color: Colors.grey[400],
//                   fontSize: 13,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         const Text(
//           'Deseja conhecer seu parceiro?',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 24),
        
//         // Botão Aceitar
//         SizedBox(
//           width: double.infinity,
//           height: 56,
//           child: ElevatedButton.icon(
//             onPressed: () => _respondToReveal(true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//             icon: const Icon(Icons.favorite, size: 24),
//             label: const Text(
//               'Sim, quero conhecer!',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),

//         const SizedBox(height: 16),

//         // Botão Rejeitar
//         SizedBox(
//           width: double.infinity,
//           height: 56,
//           child: ElevatedButton.icon(
//             onPressed: () => _respondToReveal(false),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.grey[700],
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//             icon: const Icon(Icons.visibility_off, size: 24),
//             label: const Text(
//               'Prefiro manter anônimo',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),

//         const SizedBox(height: 16),

//         Text(
//           'Sua escolha será comunicada ao seu parceiro',
//           style: TextStyle(
//             color: Colors.grey[500],
//             fontSize: 14,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildResponseStatus(revealState) {
//     if (revealState.hasError) {
//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.red.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.red.withOpacity(0.3)),
//         ),
//         child: Column(
//           children: [
//             const Icon(
//               Icons.error_outline,
//               color: Colors.red,
//               size: 48,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Erro ao processar resposta',
//               style: TextStyle(
//                 color: Colors.red,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               revealState.errorMessage ?? 'Tente novamente',
//               style: TextStyle(color: Colors.grey[400]),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   _hasResponded = false;
//                 });
//               },
//               child: const Text('Tentar Novamente'),
//             ),
//           ],
//         ),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.green.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.green.withOpacity(0.3)),
//       ),
//       child: Column(
//         children: [
//           const Icon(
//             Icons.check_circle_outline,
//             color: Colors.green,
//             size: 48,
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Resposta enviada!',
//             style: TextStyle(
//               color: Colors.green,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Aguardando resposta do seu parceiro...',
//             style: TextStyle(color: Colors.grey[400]),
//           ),
//           const SizedBox(height: 16),
//           const LinearProgressIndicator(
//             color: Colors.amber,
//             backgroundColor: Colors.grey,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Você será notificado quando ele responder',
//             style: TextStyle(
//               color: Colors.grey[500],
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCollaborationStats() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF16213E),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             '📊 Estatísticas da Colaboração',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatCard(
//                   'Nível Alcançado',
//                   '${widget.pet.currentLevel}',
//                   Colors.amber,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildStatCard(
//                   'Dias Juntos',
//                   _calculateDaysTogether(),
//                   Colors.pink,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatCard(
//                   'Ações Totais',
//                   '${widget.pet.recentActions.length}',
//                   Colors.blue,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildStatCard(
//                   'Experiência',
//                   '${widget.pet.totalExperience} XP',
//                   Colors.green,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(String label, String value, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         children: [
//           Text(
//             value,
//             style: TextStyle(
//               color: color,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.grey[400],
//               fontSize: 12,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   void _respondToReveal(bool accept) {
//     setState(() {
//       _hasResponded = true;
//     });

//     const userId = 'current_user_id';
//     ref.read(revealProvider.notifier).respondToReveal(
//       widget.pet.id,
//       userId,
//       accept,
//     );

//     if (accept) {
//       _confettiController.forward();
//     }
//   }

//   String _calculateDaysTogether() {
//     if (widget.pet.matchedAt == null) return '0';
//     final days = DateTime.now().difference(widget.pet.matchedAt!).inDays;
//     return days.toString();
//   }
// }

// // File: lib/presentation/screens/reveal_system/revealed_partner_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/classes/collaborative/collaborative_pet_entity.dart';

// class RevealedPartnerScreen extends ConsumerStatefulWidget {
//   final CollaborativePetEntity pet;
//   final Map<String, dynamic> partnerInfo;

//   const RevealedPartnerScreen({
//     super.key,
//     required this.pet,
//     required this.partnerInfo,
//   });

//   @override
//   ConsumerState<RevealedPartnerScreen> createState() => _RevealedPartnerScreenState();
// }

// class _RevealedPartnerScreenState extends ConsumerState<RevealedPartnerScreen>
//     with TickerProviderStateMixin {
//   late AnimationController _celebrationController;
//   late AnimationController _avatarController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _rotationAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _celebrationController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
    
//     _avatarController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _avatarController,
//       curve: Curves.elasticOut,
//     ));

//     _rotationAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _celebrationController,
//       curve: Curves.linear,
//     ));

//     // Iniciar animações
//     _avatarController.forward();
//     _celebrationController.repeat();
//   }

//   @override
//   void dispose() {
//     _celebrationController.dispose();
//     _avatarController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1A1A2E),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),

//                 // Header de celebração
//                 AnimatedBuilder(
//                   animation: _rotationAnimation,
//                   builder: (context, child) {
//                     return Transform.rotate(
//                       angle: _rotationAnimation.value * 0.1,
//                       child: const Text(
//                         '🎉 PARCEIROS REVELADOS! 🎉',
//                         style: TextStyle(
//                           color: Colors.amber,
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 32),

//                 // Pet info no centro
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF16213E),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: Colors.amber.withOpacity(0.5),
//                       width: 2,
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Text(
//                         widget.pet.name,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'Nível ${widget.pet.currentLevel} • ${_getPetType(widget.pet.type)}',
//                         style: TextStyle(
//                           color: Colors.grey[400],
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         _getPetEmoji(widget.pet.type),
//                         style: const TextStyle(fontSize: 80),
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Apresenta orgulhosamente seus cuidadores:',
//                         style: TextStyle(
//                           color: Colors.amber,
//                           fontSize: 16,
//                           fontStyle: FontStyle.italic,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 32),

//                 // Perfil do parceiro revelado
//                 AnimatedBuilder(
//                   animation: _scaleAnimation,
//                   builder: (context, child) {
//                     return Transform.scale(
//                       scale: _scaleAnimation.value,
//                       child: Container(
//                         padding: const EdgeInsets.all(24),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                             colors: [
//                               Colors.purple.withOpacity(0.2),
//                               Colors.pink.withOpacity(0.2),
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: Colors.purple.withOpacity(0.5),
//                             width: 2,
//                           ),
//                         ),
//                         child: Column(
//                           children: [
//                             // Avatar do parceiro
//                             Container(
//                               width: 100,
//                               height: 100,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.purple.withOpacity(0.3),
//                                 border: Border.all(
//                                   color: Colors.purple,
//                                   width: 3,
//                                 ),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   _getPartnerAvatar(),
//                                   style: const TextStyle(fontSize: 40),
//                                 ),
//                               ),
//                             ),

//                             const SizedBox(height: 16),

//                             // Nome do parceiro
//                             Text(
//                               widget.partnerInfo['name'] ?? 'Sarah',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),

//                             const SizedBox(height: 8),

//                             // Level e rating
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                   decoration: BoxDecoration(
//                                     color: Colors.amber.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Text(
//                                     'Nível ${widget.partnerInfo['level'] ?? 15}',
//                                     style: const TextStyle(
//                                       color: Colors.amber,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                   decoration: BoxDecoration(
//                                     color: Colors.green.withOpacity(0.2),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       const Icon(
//                                         Icons.star,
//                                         color: Colors.green,
//                                         size: 16,
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Text(
//                                         '${widget.partnerInfo['rating'] ?? 4.8}',
//                                         style: const TextStyle(
//                                           color: Colors.green,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: 16),

//                             // Bio do parceiro
//                             Container(
//                               padding: const EdgeInsets.all(16),
//                               decoration: BoxDecoration(
//                                 color: Colors.black26,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 widget.partnerInfo['bio'] ?? 'Amo cuidar de pets! 🐾\nAdoro colaborações!',
//                                 style: TextStyle(
//                                   color: Colors.grey[300],
//                                   fontSize: 16,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),

//                             const SizedBox(height: 20),

//                             // Estatísticas da parceria
//                             const Text(
//                               'Estatísticas da Parceria:',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 12),
                            
//                             _buildPartnershipStats(),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 32),

//                 // Botões de ação
//                 _buildActionButtons(context),

//                 const SizedBox(height: 20),

//                 // Mensagem de continuidade
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.blue.withOpacity(0.3)),
//                   ),
//                   child: Column(
//                     children: [
//                       const Icon(
//                         Icons.favorite,
//                         color: Colors.pink,
//                         size: 32,
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Agora vocês podem:',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         '• Continuar cuidando do ${widget.pet.name}\n'
//                         '• Conversar diretamente via chat\n'
//                         '• Iniciar novas colaborações juntos\n'
//                         '• Competir em duplas nos eventos',
//                         style: TextStyle(
//                           color: Colors.grey[400],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPartnershipStats() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatItem(
//                   'Dias Juntos',
//                   _calculateDaysTogether(),
//                   Icons.calendar_today,
//                   Colors.blue,
//                 ),
//               ),
//               Expanded(
//                 child: _buildStatItem(
//                   'Ações Colaborativas',
//                   '${widget.pet.recentActions.length}',
//                   Icons.handshake,
//                   Colors.green,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatItem(
//                   'Sua Contribuição',
//                   '${_calculateUserContribution()}%',
//                   Icons.person,
//                   Colors.amber,
//                 ),
//               ),
//               Expanded(
//                 child: _buildStatItem(
//                   'Parceiro',
//                   '${100 - _calculateUserContribution()}%',
//                   Icons.person_outline,
//                   Colors.purple,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, String value, IconData icon, Color color) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 20),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: TextStyle(
//             color: color,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.grey[400],
//             fontSize: 12,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons(BuildContext context) {
//     return Column(
//       children: [
//         // Botão principal - Continuar cuidando
//         SizedBox(
//           width: double.infinity,
//           height: 56,
//           child: ElevatedButton.icon(
//             onPressed: () {
//               Navigator.pushReplacementNamed(
//                 context,
//                 '/active-collaboration',
//                 arguments: widget.pet,
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.amber,
//               foregroundColor: Colors.black,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//             ),
//             icon: const Icon(Icons.pets, size: 24),
//             label: Text(
//               'Continuar Cuidando do ${widget.pet.name}',
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),

//         const SizedBox(height: 12),

//         // Botões secundários
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: () => _openChat(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 icon: const Icon(Icons.chat, size: 20),
//                 label: const Text('Chat'),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: () => _addFriend(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.purple,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 icon: const Icon(Icons.person_add, size: 20),
//                 label: const Text('Adicionar'),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   void _openChat(BuildContext context) {
//     // Implementar abertura do chat
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Chat em desenvolvimento!'),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }

//   void _addFriend(BuildContext context) {
//     // Implementar adicionar como amigo
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Parceiro adicionado aos amigos!'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }

//   String _getPetEmoji(String type) {
//     switch (type.toLowerCase()) {
//       case 'cat':
//         return '🐱';
//       case 'dog':
//         return '🐶';
//       case 'bird':
//         return '🐦';
//       case 'fish':
//         return '🐠';
//       case 'rabbit':
//         return '🐰';
//       default:
//         return '🐾';
//     }
//   }

//   String _getPetType(String type) {
//     switch (type.toLowerCase()) {
//       case 'cat':
//         return 'Gato';
//       case 'dog':
//         return 'Cachorro';
//       case 'bird':
//         return 'Pássaro';
//       case 'fish':
//         return 'Peixe';
//       case 'rabbit':
//         return 'Coelho';
//       default:
//         return 'Pet';
//     }
//   }

//   String _getPartnerAvatar() {
//     return '👩'; // Em implementação real, seria baseado no perfil do usuário
//   }

//   String _calculateDaysTogether() {
//     if (widget.pet.matchedAt == null) return '0';
//     final days = DateTime.now().difference(widget.pet.matchedAt!).inDays;
//     return days.toString();
//   }

//   int _calculateUserContribution() {
//     const currentUserId = 'current_user_id';
//     final userContributions = widget.pet.contributionStats[currentUserId] ?? 0;
//     final totalContributions = widget.pet.contributionStats.values.fold(0, (sum, value) => sum + value);
    
//     if (totalContributions == 0) return 50;
//     return ((userContributions / totalContributions) * 100).round();
//   }
// }

// // File: lib/presentation/widgets/collaborative_pet/collaborative_pet_card.dart
// import 'package:flutter/material.dart';
// import '../../../core/classes/collaborative/collaborative_pet_entity.dart';
// import '../../../core/enums/collaborative/collaboration_status.dart';

// class CollaborativePetCard extends StatelessWidget {
//   final CollaborativePetEntity pet;
//   final VoidCallback? onTap;
//   final VoidCallback? onAdopt;
//   final bool showAdoptButton;
//   final bool showProgress;

//   const CollaborativePetCard({
//     super.key,
//     required this.pet,
//     this.onTap,
//     this.onAdopt,
//     this.showAdoptButton = false,
//     this.showProgress = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: const Color(0xFF16213E),
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(
//           color: _getStatusColor().withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header com status
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor().withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           pet.status.icon,
//                           style: const TextStyle(fontSize: 12),
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           pet.status.displayName,
//                           style: TextStyle(
//                             color: _getStatusColor(),
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Spacer(),
//                   if (pet.canReveal)
//                     Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: BoxDecoration(
//                         color: Colors.amber.withOpacity(0.2),
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.visibility,
//                         color: Colors.amber,
//                         size: 16,
//                       ),
//                     ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // Pet info section
//               Row(
//                 children: [
//                   // Pet avatar
//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: _getStatusColor().withOpacity(0.1),
//                       border: Border.all(
//                         color: _getStatusColor(),
//                         width: 2,
//                       ),
//                     ),
//                     child: Center(
//                       child: Text(
//                         _getPetEmoji(pet.type),
//                         style: const TextStyle(fontSize: 32),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 16),

//                   // Pet details
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           pet.name,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           _getPetTypeDisplayName(pet.type),
//                           style: TextStyle(
//                             color: Colors.grey[400],
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.star,
//                               color: Colors.amber,
//                               size: 16,
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               'Nível ${pet.currentLevel}',
//                               style: const TextStyle(
//                                 color: Colors.amber,
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // Stats section
//               _buildStatsSection(),

//               // Progress section (if enabled)
//               if (showProgress) ...[
//                 const SizedBox(height: 16),
//                 _buildProgressSection(),
//               ],

//               // Caretakers info
//               const SizedBox(height: 16),
//               _buildCaretakersSection(),

//               // Action button
//               if (showAdoptButton && onAdopt != null) ...[
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: onAdopt,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.amber,
//                       foregroundColor: Colors.black,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     icon: const Icon(Icons.favorite),
//                     label: const Text(
//                       'Solicitar Adoção',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsSection() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.black26,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildStatItem('Fome', pet.getHunger(), Colors.orange),
//           _buildStatItem('❤️', pet.getHappiness(), Colors.pink),
//           _buildStatItem('⚡', pet.getEnergy(), Colors.blue),
//           _buildStatItem('🏥', pet.getHealth(), Colors.green),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, int value, Color color) {
//     return Column(
//       children: [
//         Text(
//           value.toString(),
//           style: TextStyle(
//             color: color,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.grey[400],
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildProgressSection() {
//     final progress = pet.progressToReveal.clamp(0.0, 1.0);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Icon(
//               Icons.visibility,
//               color: Colors.amber,
//               size: 16,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'Progresso para Reveal',
//               style: TextStyle(
//                 color: Colors.grey[300],
//                 fontSize: 14,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const Spacer(),
//             Text(
//               '${pet.currentLevel}/${pet.revealLevel}',
//               style: const TextStyle(
//                 color: Colors.amber,
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         LinearProgressIndicator(
//           value: progress,
//           backgroundColor: Colors.grey[700],
//           color: progress >= 1.0 ? Colors.green : Colors.amber,
//           minHeight: 6,
//         ),
//         if (progress >= 1.0) ...[
//           const SizedBox(height: 4),
//           const Text(
//             '✨ Reveal disponível!',
//             style: TextStyle(
//               color: Colors.green,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildCaretakersSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Cuidadores:',
//           style: TextStyle(
//             color: Colors.grey[300],
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 8),
//         if (pet.status == CollaborationStatus.waitingForPartner)
//           Row(
//             children: [
//               _buildCaretakerAvatar(pet.anonymousNames.values.first, true),
//               const SizedBox(width: 8),
//               Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: Colors.grey[600]!,
//                     width: 2,
//                     style: BorderStyle.values[1], // dashed
//                   ),
//                 ),
//                 child: Icon(
//                   Icons.add,
//                   color: Colors.grey[600],
//                   size: 16,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'Aguardando parceiro...',
//                 style: TextStyle(
//                   color: Colors.grey[500],
//                   fontSize: 12,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ],
//           )
//         else
//           Row(
//             children: pet.anonymousNames.values.map((name) {
//               final isActive = _isCaretakerActive(name);
//               return Padding(
//                 padding: const EdgeInsets.only(right: 8),
//                 child: _buildCaretakerAvatar(name, isActive),
//               );
//             }).toList(),
//           ),
//       ],
//     );
//   }

//   Widget _buildCaretakerAvatar(String name, bool isActive) {
//     return Container(
//       width: 32,
//       height: 32,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: isActive ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
//         border: Border.all(
//           color: isActive ? Colors.green : Colors.grey,
//           width: 2,
//         ),
//       ),
//       child: Center(
//         child: Text(
//           name.substring(name.length - 1), // Última letra (A, B, etc.)
//           style: TextStyle(
//             color: isActive ? Colors.green : Colors.grey,
//             fontSize: 12,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   bool _isCaretakerActive(String name) {
//     // Simulação - em implementação real, verificaria última atividade
//     return DateTime.now().millisecond % 2 == 0;
//   }

//   Color _getStatusColor() {
//     switch (pet.status) {
//       case CollaborationStatus.waitingForPartner:
//         return Colors.amber;
//       case CollaborationStatus.activeCollaboration:
//         return Colors.green;
//       case CollaborationStatus.revealAvailable:
//         return Colors.purple;
//       case CollaborationStatus.revealed:
//         return Colors.blue;
//       case CollaborationStatus.abandoned:
//         return Colors.red;
//       case CollaborationStatus.completed:
//         return Colors.teal;
//     }
//   }

//   String _getPetEmoji(String type) {
//     switch (type.toLowerCase()) {
//       case 'cat':
//         return '🐱';
//       case 'dog':
//         return '🐶';
//       case 'bird':
//         return '🐦';
//       case 'fish':
//         return '🐠';
//       case 'rabbit':
//         return '🐰';
//       default:
//         return '🐾';
//     }
//   }

//   String _getPetTypeDisplayName(String type) {
//     switch (type.toLowerCase()) {
//       case 'cat':
//         return 'Gato';
//       case 'dog':
//         return 'Cachorro';
//       case 'bird':
//         return 'Pássaro';
//       case 'fish':
//         return 'Peixe';
//       case 'rabbit':
//         return 'Coelho';
//       default:
//         return 'Pet';
//     }
//   }
// }

// // File: lib/presentation/widgets/collaborative_pet/real_time_actions_feed.dart
// import 'package:flutter/material.dart';
// import '../../../core/classes/collaborative/collaborative_action.dart';

// class RealTimeActionsFeed extends StatefulWidget {
//   final String petId;
//   final List<CollaborativeAction> actions;

//   const RealTimeActionsFeed({
//     super.key,
//     required this.petId,
//     required this.actions,
//   });

//   @override
//   State<RealTimeActionsFeed> createState() => _RealTimeActionsFeedState();
// }

// class _RealTimeActionsFeedState extends State<RealTimeActionsFeed>
//     with TickerProviderStateMixin {
//   late AnimationController _newActionController;
//   String? _lastActionId;

//   @override
//   void initState() {
//     super.initState();
//     _newActionController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//   }

//   @override
//   void didUpdateWidget(RealTimeActionsFeed oldWidget) {
//     super.didUpdateWidget(oldWidget);
    
//     // Verificar se há nova ação
//     if (widget.actions.isNotEmpty && 
//         widget.actions.first.id != _lastActionId) {
//       _lastActionId = widget.actions.first.id;
//       _newActionController.forward().then((_) {
//         _newActionController.reverse();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _newActionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.actions.isEmpty) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.timeline,
//               color: Colors.grey,
//               size: 48,
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Nenhuma atividade ainda',
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 16,
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'As ações aparecerão aqui em tempo real',
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       itemCount: widget.actions.length,
//       itemBuilder: (context, index) {
//         final action = widget.actions[index];
//         final isNewest = index == 0;
        
//         return AnimatedBuilder(
//           animation: _newActionController,
//           builder: (context, child) {
//             final scale = isNewest && _newActionController.isAnimating
//                 ? 1.0 + (0.05 * _newActionController.value)
//                 : 1.0;
            
//             return Transform.scale(
//               scale: scale,
//               child: _buildActionItem(action, isNewest),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildActionItem(CollaborativeAction action, bool isNewest) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Timeline indicator
//           Column(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _getActionColor(action).withOpacity(0.2),
//                   border: Border.all(
//                     color: _getActionColor(action),
//                     width: 2,
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     action.actionType.icon,
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//               if (!isNewest)
//                 Container(
//                   width: 2,
//                   height: 20,
//                   color: Colors.grey[700],
//                 ),
//             ],
//           ),

//           const SizedBox(width: 16),

//           // Action content
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: isNewest 
//                     ? _getActionColor(action).withOpacity(0.1)
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(8),
//                 border: isNewest 
//                     ? Border.all(color: _getActionColor(action).withOpacity(0.3))
//                     : null,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         action.anonymousName,
//                         style: TextStyle(
//                           color: _getActionColor(action),
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                         decoration: BoxDecoration(
//                           color: _getActionColor(action).withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           '+${action.experienceGained} XP',
//                           style: TextStyle(
//                             color: _getActionColor(action),
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const Spacer(),
//                       Text(
//                         _formatTimeAgo(action.timestamp),
//                         style: TextStyle(
//                           color: Colors.grey[500],
//                           fontSize: 12,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 4),

//                   Text(
//                     _getActionDescription(action),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 14,
//                     ),
//                   ),

//                   if (action.effects.isNotEmpty) ...[
//                     const SizedBox(height: 8),
//                     _buildEffectsRow(action.effects),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEffectsRow(Map<String, dynamic> effects) {
//     return Wrap(
//       spacing: 8,
//       children: effects.entries.map((entry) {
//         final value = entry.value as int;
//         final isPositive = value > 0;
        
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: (isPositive ? Colors.green : Colors.red).withOpacity(0.2),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             '${_getStatIcon(entry.key)} ${isPositive ? '+' : ''}$value',
//             style: TextStyle(
//               color: isPositive ? Colors.green : Colors.red,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Color _getActionColor(CollaborativeAction action) {
//     switch (action.actionType.value) {
//       case 'feed':
//         return Colors.orange;
//       case 'play':
//         return Colors.pink;
//       case 'rest':
//         return Colors.blue;
//       case 'medicine':
//         return Colors.green;
//       case 'bath':
//         return Colors.cyan;
//       case 'training':
//         return Colors.purple;
//       case 'love':
//         return Colors.red;
//       default:
//         return Colors.amber;
//     }
//   }

//   String _getActionDescription(CollaborativeAction action) {
//     switch (action.actionType.value) {
//       case 'feed':
//         return 'Alimentou o pet com carinho';
//       case 'play':
//         return 'Brincou e se divertiu com o pet';
//       case 'rest':
//         return 'Ajudou o pet a descansar';
//       case 'medicine':
//         return 'Deu remédio ao pet';
//       case 'bath':
//         return 'Deu um banho relaxante';
//       case 'training':
//         return 'Treinou o pet com paciência';
//       case 'love':
//         return 'Fez carinho no pet';
//       default:
//         return 'Interagiu com o pet';
//     }
//   }

//   String _getStatIcon(String stat) {
//     switch (stat) {
//       case 'hunger':
//         return '🍽️';
//       case 'happiness':
//         return '😊';
//       case 'energy':
//         return '⚡';
//       case 'health':
//         return '❤️';
//       case 'experience':
//         return '⭐';
//       default:
//         return '📊';
//     }
//   }

//   String _formatTimeAgo(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);
    
//     if (difference.inMinutes < 1) {
//       return 'agora';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes}m';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours}h';
//     } else {
//       return '${difference.inDays}d';
//     }
//   }
// }

// // File: lib/presentation/widgets/shared/collaborative/reveal_progress_indicator.dart
// import 'package:flutter/material.dart';

// class RevealProgressIndicator extends StatefulWidget {
//   final int currentLevel;
//   final int revealLevel;
//   final bool canReveal;

//   const RevealProgressIndicator({
//     super.key,
//     required this.currentLevel,
//     required this.revealLevel,
//     required this.canReveal,
//   });

//   @override
//   State<RevealProgressIndicator> createState() => _RevealProgressIndicatorState();
// }

// class _RevealProgressIndicatorState extends State<RevealProgressIndicator>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _shimmerController;

//   @override
//   void initState() {
//     super.initState();
//     _pulseController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
    
//     _shimmerController = AnimationController(
//       duration: const Duration(seconds: 1.5),
//       vsync: this,
//     );

//     if (widget.canReveal) {
//       _pulseController.repeat();
//       _shimmerController.repeat();
//     }
//   }

//   @override
//   void didUpdateWidget(RevealProgressIndicator oldWidget) {
//     super.didUpdateWidget(oldWidget);
    
//     if (widget.canReveal && !oldWidget.canReveal) {
//       _pulseController.repeat();
//       _shimmerController.repeat();
//     } else if (!widget.canReveal && oldWidget.canReveal) {
//       _pulseController.stop();
//       _shimmerController.stop();
//     }
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _shimmerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final progress = (widget.currentLevel / widget.revealLevel).clamp(0.0, 1.0);
    
//     return Container(
//       padding: const EdgeInsets.all(16),
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: widget.canReveal 
//             ? Colors.amber.withOpacity(0.1)
//             : Colors.black26,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: widget.canReveal 
//               ? Colors.amber.withOpacity(0.5)
//               : Colors.grey.withOpacity(0.3),
//           width: widget.canReveal ? 2 : 1,
//         ),
//       ),
//       child: Column(
//         children: [
//           // Header
//           Row(
//             children: [
//               AnimatedBuilder(
//                 animation: _pulseController,
//                 builder: (context, child) {
//                   final scale = widget.canReveal 
//                       ? 1.0 + (0.1 * _pulseController.value)
//                       : 1.0;
                  
//                   return Transform.scale(
//                     scale: scale,
//                     child: Icon(
//                       widget.canReveal ? Icons.visibility : Icons.visibility_off,
//                       color: widget.canReveal ? Colors.amber : Colors.grey,
//                       size: 24,
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 'Progresso para Reveal',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 '${widget.currentLevel}/${widget.revealLevel}',
//                 style: TextStyle(
//                   color: widget.canReveal ? Colors.amber : Colors.grey,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 16),

//           // Progress bar
//           Stack(
//             children: [
//               Container(
//                 height: 8,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[700],
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//               AnimatedBuilder(
//                 animation: _shimmerController,
//                 builder: (context, child) {
//                   return Container(
//                     height: 8,
//                     width: MediaQuery.of(context).size.width * progress,
//                     decoration: BoxDecoration(
//                       gradient: widget.canReveal
//                           ? LinearGradient(
//                               colors: [
//                                 Colors.amber,
//                                 Colors.amber.withOpacity(0.7),
//                                 Colors.amber,
//                               ],
//                               stops: [
//                                 (_shimmerController.value - 0.3).clamp(0.0, 1.0),
//                                 _shimmerController.value.clamp(0.0, 1.0),
//                                 (_shimmerController.value + 0.3).clamp(0.0, 1.0),
//                               ],
//                             )
//                           : null,
//                       color: widget.canReveal ? null : Colors.amber,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),

//           const SizedBox(height: 12),

//           // Status message
//           if (widget.canReveal)
//             AnimatedBuilder(
//               animation: _pulseController,
//               builder: (context, child) {
//                 return Opacity(
//                   opacity: 0.7 + (0.3 * _pulseController.value),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.celebration,
//                         color: Colors.amber,
//                         size: 16,
//                       ),
//                       SizedBox(width: 8),
//                       Text(
//                         'Reveal disponível! Toque para conhecer seu parceiro',
//                         style: TextStyle(
//                           color: Colors.amber,
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             )
//           else
//             Text(
//               'Continue cuidando para desbloquear o reveal',
//               style: TextStyle(
//                 color: Colors.grey[400],
//                 fontSize: 14,
//               ),
//               textAlign: TextAlign.center,
//             ),
//         ],
//       ),
//     );
//   }
// }

// // File: lib/presentation/widgets/shared/collaborative/collaboration_badge_widget.dart
// import 'package:flutter/material.dart';

// class CollaborationBadgeWidget extends StatefulWidget {
//   final String badgeId;
//   final String name;
//   final String description;
//   final String icon;
//   final bool isUnlocked;
//   final double? progress;
//   final VoidCallback? onTap;

//   const CollaborationBadgeWidget({
//     super.key,
//     required this.badgeId,
//     required this.name,
//     required this.description,
//     required this.icon,
//     required this.isUnlocked,
//     this.progress,
//     this.onTap,
//   });

//   @override
//   State<CollaborationBadgeWidget> createState() => _CollaborationBadgeWidgetState();
// }

// class _CollaborationBadgeWidgetState extends State<CollaborationBadgeWidget>
//     with TickerProviderStateMixin {
//   late AnimationController _unlockController;
//   late AnimationController _shimmerController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _rotateAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _unlockController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
    
//     _shimmerController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.2,
//     ).animate(CurvedAnimation(
//       parent: _unlockController,
//       curve: Curves.elasticOut,
//     ));

//     _rotateAnimation = Tween<double>(
//       begin: 0.0,
//       end: 0.1,
//     ).animate(CurvedAnimation(
//       parent: _unlockController,
//       curve: Curves.easeInOut,
//     ));

//     if (widget.isUnlocked) {
//       _shimmerController.repeat();
//     }
//   }

//   @override
//   void didUpdateWidget(CollaborationBadgeWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
    
//     if (widget.isUnlocked && !oldWidget.isUnlocked) {
//       _unlockController.forward();
//       _shimmerController.repeat();
//     }
//   }

//   @override
//   void dispose() {
//     _unlockController.dispose();
//     _shimmerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: widget.isUnlocked 
//               ? Colors.amber.withOpacity(0.1)
//               : Colors.grey.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: widget.isUnlocked 
//                 ? Colors.amber.withOpacity(0.5)
//                 : Colors.grey.withOpacity(0.3),
//             width: widget.isUnlocked ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             // Badge icon
//             AnimatedBuilder(
//               animation: Listenable.merge([_unlockController, _shimmerController]),
//               builder: (context, child) {
//                 return Transform.scale(
//                   scale: _scaleAnimation.value,
//                   child: Transform.rotate(
//                     angle: _rotateAnimation.value,
//                     child: Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: widget.isUnlocked 
//                             ? Colors.amber.withOpacity(0.2)
//                             : Colors.grey.withOpacity(0.2),
//                         border: Border.all(
//                           color: widget.isUnlocked ? Colors.amber : Colors.grey,
//                           width: 2,
//                         ),
//                         boxShadow: widget.isUnlocked ? [
//                           BoxShadow(
//                             color: Colors.amber.withOpacity(0.3),
//                             blurRadius: 8,
//                             spreadRadius: 2,
//                           ),
//                         ] : null,
//                       ),
//                       child: Center(
//                         child: Text(
//                           widget.icon,
//                           style: TextStyle(
//                             fontSize: 24,
//                             color: widget.isUnlocked ? null : Colors.grey,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),

//             const SizedBox(width: 16),

//             // Badge info
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         widget.name,
//                         style: TextStyle(
//                           color: widget.isUnlocked ? Colors.white : Colors.grey,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       if (widget.isUnlocked) ...[
//                         const SizedBox(width: 8),
//                         Icon(
//                           Icons.check_circle,
//                           color: Colors.green,
//                           size: 16,
//                         ),
//                       ],
//                     ],
//                   ),

//                   const SizedBox(height: 4),

//                   Text(
//                     widget.description,
//                     style: TextStyle(
//                       color: widget.isUnlocked 
//                           ? Colors.grey[300]
//                           : Colors.grey[500],
//                       fontSize: 14,
//                     ),
//                   ),

//                   if (!widget.isUnlocked && widget.progress != null) ...[
//                     const SizedBox(height: 8),
//                     _buildProgressBar(),
//                   ],

//                   if (widget.isUnlocked) ...[
//                     const SizedBox(height: 8),
//                     AnimatedBuilder(
//                       animation: _shimmerController,
//                       builder: (context, child) {
//                         return Opacity(
//                           opacity: 0.7 + (0.3 * _shimmerController.value),
//                           child: Text(
//                             '✨ Desbloqueado!',
//                             style: TextStyle(
//                               color: Colors.amber,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProgressBar() {
//     final progress = widget.progress ?? 0.0;
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               'Progresso: ${(progress * 100).toInt()}%',
//               style: TextStyle(
//                 color: Colors.grey[400],
//                 fontSize: 12,
//               ),
//             ),
//             const Spacer(),
//             Text(
//               '${(progress * 100).toInt()}/100',
//               style: TextStyle(
//                 color: Colors.grey[400],
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         LinearProgressIndicator(
//           value: progress,
//           backgroundColor: Colors.grey[700],
//           color: progress >= 1.0 ? Colors.green : Colors.blue,
//           minHeight: 4,
//         ),
//       ],
//     );
//   }
// }

// // File: lib/presentation/widgets/collaborative_pet/collaboration_stats_widget.dart
// import 'package:flutter/material.dart';
// import '../../../core/classes/collaborative/collaborative_pet_entity.dart';
// import '../../../core/classes/collaborative/cooperation_stats.dart';

// class CollaborationStatsWidget extends StatelessWidget {
//   final CollaborativePetEntity pet;
//   final CooperationStats? stats;

//   const CollaborationStatsWidget({
//     super.key,
//     required this.pet,
//     this.stats,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF16213E),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: Colors.blue.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           const Row(
//             children: [
//               Icon(
//                 Icons.analytics,
//                 color: Colors.blue,
//                 size: 24,
//               ),
//               SizedBox(width: 8),
//               Text(
//                 'Estatísticas da Colaboração',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 20),

//           // Pet stats
//           _buildSection(
//             'Pet Stats',
//             [
//               _buildStatRow('Nível Atual', '${pet.currentLevel}', Icons.star, Colors.amber),
//               _buildStatRow('Experiência Total', '${pet.totalExperience} XP', Icons.trending_up, Colors.green),
//               _buildStatRow('Progresso Reveal', '${(pet.progressToReveal * 100).toInt()}%', Icons.visibility, Colors.purple),
//             ],
//           ),

//           const SizedBox(height: 16),

//           // Collaboration stats
//           if (stats != null)
//             _buildSection(
//               'Estatísticas Gerais',
//               [
//                 _buildStatRow('Colaborações', '${stats!.totalCollaborations}', Icons.handshake, Colors.blue),
//                 _buildStatRow('Reveals Bem-sucedidos', '${stats!.successfulReveals}', Icons.people, Colors.pink),
//                 _buildStatRow('Rating de Cooperação', stats!.partnerSatisfactionRating.toStringAsFixed(1), Icons.star_rate, Colors.orange),
//                 _buildStatRow('Ações Realizadas', '${stats!.totalActionsPerformed}', Icons.touch_app, Colors.cyan),
//               ],
//             ),

//           const SizedBox(height: 16),

//           // Caretaker contributions
//           _buildSection(
//             'Contribuições por Cuidador',
//             pet.contributionStats.entries.map((entry) {
//               final anonymousName = pet.anonymousNames[entry.key] ?? 'Cuidador';
//               final percentage = _calculateContributionPercentage(entry.key);
//               return _buildContributionRow(anonymousName, entry.value, percentage);
//             }).toList(),
//           ),

//           if (pet.recentActions.isNotEmpty) ...[
//             const SizedBox(height: 16),
//             _buildSection(
//               'Atividade Recente',
//               [
//                 _buildStatRow(
//                   'Última Ação',
//                   _formatTimeAgo(pet.recentActions.first.timestamp),
//                   Icons.access_time,
//                   Colors.grey,
//                 ),
//                 _buildStatRow(
//                   'Ações Hoje',
//                   '${_getActionsToday()}',
//                   Icons.today,
//                   Colors.indigo,
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildSection(String title, List<Widget> children) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             color: Colors.grey[300],
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 12),
//         ...children,
//       ],
//     );
//   }

//   Widget _buildStatRow(String label, String value, IconData icon, Color color) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(width: 12),
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.grey[400],
//               fontSize: 14,
//             ),
//           ),
//           const Spacer(),
//           Text(
//             value,
//             style: TextStyle(
//               color: color,
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContributionRow(String name, int contributions, double percentage) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: _getCaretakerColor(name).withOpacity(0.2),
//                   border: Border.all(
//                     color: _getCaretakerColor(name),
//                     width: 2,
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     name.substring(name.length - 1),
//                     style: TextStyle(
//                       color: _getCaretakerColor(name),
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 name,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 '$contributions ações',
//                 style: TextStyle(
//                   color: Colors.grey[400],
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           LinearProgressIndicator(
//             value: percentage / 100,
//             backgroundColor: Colors.grey[700],
//             color: _getCaretakerColor(name),
//             minHeight: 6,
//           ),
//           const SizedBox(height: 4),
//           Align(
//             alignment: Alignment.centerRight,
//             child: Text(
//               '${percentage.toInt()}%',
//               style: TextStyle(
//                 color: _getCaretakerColor(name),
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getCaretakerColor(String name) {
//     // Cores baseadas no nome do cuidador
//     if (name.contains('A')) return Colors.blue;
//     if (name.contains('B')) return Colors.green;
//     if (name.contains('C')) return Colors.purple;
//     return Colors.orange;
//   }

//   double _calculateContributionPercentage(String userId) {
//     final userContributions = pet.contributionStats[userId] ?? 0;
//     final totalContributions = pet.contributionStats.values.fold(0, (sum, value) => sum + value);
    
//     if (totalContributions == 0) return 0.0;
//     return (userContributions / totalContributions) * 100;
//   }

//   int _getActionsToday() {
//     final today = DateTime.now();
//     return pet.recentActions.where((action) {
//       return action.timestamp.year == today.year &&
//              action.timestamp.month == today.month &&
//              action.timestamp.day == today.day;
//     }).length;
//   }

//   String _formatTimeAgo(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);
    
//     if (difference.inMinutes < 1) {
//       return 'Agora mesmo';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes}m atrás';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours}h atrás';
//     } else {
//       return '${difference.inDays}d atrás';
//     }
//   }
// }

// // File: lib/presentation/providers/collaborative/reveal_provider.dart
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/classes/collaborative/reveal_request.dart';
// import '../../../core/enums/collaborative/reveal_status.dart';
// import '../../../data/services/collaborative/reveal_service.dart';

// @immutable
// class RevealState {
//   final List<RevealRequest> pendingRequests;
//   final List<RevealRequest> completedRequests;
//   final RevealRequest? currentRequest;
//   final bool isLoading;
//   final bool hasError;
//   final String? errorMessage;
//   final Map<String, dynamic>? revealedPartnerInfo;
//   final bool hasNewReveal;

//   const RevealState({
//     this.pendingRequests = const [],
//     this.completedRequests = const [],
//     this.currentRequest,
//     this.isLoading = false,
//     this.hasError = false,
//     this.errorMessage,
//     this.revealedPartnerInfo,
//     this.hasNewReveal = false,
//   });

//   RevealState copyWith({
//     List<RevealRequest>? pendingRequests,
//     List<RevealRequest>? completedRequests,
//     RevealRequest? currentRequest,
//     bool? isLoading,
//     bool? hasError,
//     String? errorMessage,
//     Map<String, dynamic>? revealedPartnerInfo,
//     bool? hasNewReveal,
//   }) {
//     return RevealState(
//       pendingRequests: pendingRequests ?? this.pendingRequests,
//       completedRequests: completedRequests ?? this.completedRequests,
//       currentRequest: currentRequest ?? this.currentRequest,
//       isLoading: isLoading ?? this.isLoading,
//       hasError: hasError ?? this.hasError,
//       errorMessage: errorMessage,
//       revealedPartnerInfo: revealedPartnerInfo ?? this.revealedPartnerInfo,
//       hasNewReveal: hasNewReveal ?? this.hasNewReveal,
//     );
//   }
// }

// class RevealNotifier extends StateNotifier<RevealState> {
//   final RevealService _revealService;

//   RevealNotifier(this._revealService) : super(const RevealState());

//   // Criar solicitação de reveal
//   Future<void> createRevealRequest(String petId, String userId) async {
//     state = state.copyWith(isLoading: true, hasError: false);

//     final result = await _revealService.createRevealRequest(petId, userId);

//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           isLoading: false,
//           hasError: true,
//           errorMessage: failure.message,
//         );
//       },
//       (request) {
//         state = state.copyWith(
//           isLoading: false,
//           currentRequest: request,
//           pendingRequests: [...state.pendingRequests, request],
//         );
//       },
//     );
//   }

//   // Responder a um reveal request
//   Future<void> respondToReveal(String petId, String userId, bool accept) async {
//     state = state.copyWith(isLoading: true, hasError: false);

//     final result = await _revealService.respondToRevealRequest(petId, userId, accept);

//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           isLoading: false,
//           hasError: true,
//           errorMessage: failure.message,
//         );
//       },
//       (response) {
//         // Atualizar lista de requests
//         final updatedPending = state.pendingRequests
//             .where((request) => request.petId != petId)
//             .toList();
        
//         final completedRequest = state.pendingRequests
//             .firstWhere((request) => request.petId == petId);

//         final updatedCompleted = [
//           ...state.completedRequests,
//           completedRequest.copyWith(
//             status: accept ? RevealStatus.accepted : RevealStatus.rejected,
//             respondedAt: DateTime.now(),
//           ),
//         ];

//         state = state.copyWith(
//           isLoading: false,
//           pendingRequests: updatedPending,
//           completedRequests: updatedCompleted,
//           revealedPartnerInfo: accept ? response['partnerInfo'] : null,
//           hasNewReveal: accept,
//         );
//       },
//     );
//   }

//   // Buscar requests pendentes
//   Future<void> loadPendingRequests(String userId) async {
//     state = state.copyWith(isLoading: true);

//     final result = await _revealService.getUserPendingRequests(userId);

//     result.fold(
//       (failure) {
//         state = state.copyWith(
//           isLoading: false,
//           hasError: true,
//           errorMessage: failure.message,
//         );
//       },
//       (requests) {
//         state = state.copyWith(
//           isLoading: false,
//           pendingRequests: requests,
//         );
//       },
//     );
//   }

//   // Verificar se há novos reveals disponíveis
//   Future<void> checkForNewReveals(String userId) async {
//     final result = await _revealService.getUserPendingRequests(userId);

//     result.fold(
//       (failure) {
//         // Silenciosamente falha - não atualizar UI
//       },
//       (requests) {
//         final hasNew = requests.length > state.pendingRequests.length;
//         if (hasNew) {
//           state = state.copyWith(
//             pendingRequests: requests,
//             hasNewReveal: true,
//           );
//         }
//       },
//     );
//   }

//   // Marcar como visualizado
//   void markRevealAsViewed() {
//     state = state.copyWith(hasNewReveal: false);
//   }

//   // Limpar erro
//   void clearError() {
//     state = state.copyWith(hasError: false, errorMessage: null);
//   }

//   // Limpar dados do reveal
//   void clearRevealData() {
//     state = state.copyWith(
//       currentRequest: null,
//       revealedPartnerInfo: null,
//       hasNewReveal: false,
//     );
//   }
// }

// // Serviço de Reveal (Mock implementation)
// class RevealService {
//   // Criar solicitação de reveal
//   Future<Either<Failure, RevealRequest>> createRevealRequest(String petId, String userId) async {
//     try {
//       await Future.delayed(const Duration(seconds: 1)); // Simular API call
      
//       final request = RevealRequest(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//         collaborationId: 'collab_$petId',
//         petId: petId,
//         requesterId: userId,
//         targetUserId: 'partner_user_id', // Seria obtido do pet
//         status: RevealStatus.pending,
//         createdAt: DateTime.now(),
//         expiresAt: DateTime.now().add(const Duration(hours: 48)),
//         isAutomatic: true,
//       );

//       return Right(request);
//     } catch (e) {
//       return Left(UnknownFailure('Erro ao criar solicitação de reveal: $e'));
//     }
//   }

//   // Responder a solicitação de reveal
//   Future<Either<Failure, Map<String, dynamic>>> respondToRevealRequest(
//     String petId, 
//     String userId, 
//     bool accept
//   ) async {
//     try {
//       await Future.delayed(const Duration(seconds: 1)); // Simular API call
      
//       if (accept) {
//         // Retornar informações do parceiro revelado
//         final partnerInfo = {
//           'id': 'partner_user_id',
//           'name': 'Sarah',
//           'level': 15,
//           'rating': 4.8,
//           'bio': 'Amo cuidar de pets! 🐾\nAdoro colaborações!',
//           'avatar': '👩',
//           'totalPets': 23,
//           'joinDate': DateTime.now().subtract(const Duration(days: 180)),
//         };

//         return Right({
//           'success': true,
//           'partnerInfo': partnerInfo,
//         });
//       } else {
//         return Right({
//           'success': true,
//           'message': 'Reveal rejeitado. Continuando anônimo.',
//         });
//       }
//     } catch (e) {
//       return Left(UnknownFailure('Erro ao responder reveal: $e'));
//     }
//   }

//   // Buscar requests pendentes do usuário
//   Future<Either<Failure, List<RevealRequest>>> getUserPendingRequests(String userId) async {
//     try {
//       await Future.delayed(const Duration(milliseconds: 500)); // Simular API call
      
//       // Mock data - em implementação real viria do Firestore
//       final requests = <RevealRequest>[
//         // Exemplo de request pendente
//         if (DateTime.now().second % 3 == 0) // Simular request ocasional
//           RevealRequest(
//             id: 'request_${DateTime.now().millisecondsSinceEpoch}',
//             collaborationId: 'collab_example',
//             petId: 'pet_example',
//             requesterId: 'other_user',
//             targetUserId: userId,
//             status: RevealStatus.pending,
//             createdAt: DateTime.now().subtract(const Duration(hours: 1)),
//             expiresAt: DateTime.now().add(const Duration(hours: 47)),
//             isAutomatic: true,
//           ),
//       ];

//       return Right(requests);
//     } catch (e) {
//       return Left(UnknownFailure('Erro ao buscar requests: $e'));
//     }
//   }
// }

// // Import necessário para Either e Failure
// import 'package:dartz/dartz.dart';
// import '../../../core/errors/failure.dart';

// // Provider definition
// final revealProvider = StateNotifierProvider<RevealNotifier, RevealState>((ref) {
//   final revealService = RevealService(); // Seria injetado via DI
//   return RevealNotifier(revealService);
// });


// // File: lib/core/config/collaborative/dependencies.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Repository Providers
// import '../../../data/repositories/collaborative/collaborative_pet_repository.dart';
// import '../../../data/repositories/collaborative/collaboration_repository.dart';
// import '../../../data/repositories/collaborative/matchmaking_repository.dart';

// // Service Providers
// import '../../../data/services/collaborative/real_time_sync_service.dart';
// import '../../../data/services/collaborative/collaboration_service.dart';
// import '../../../data/services/collaborative/matchmaking_service.dart';
// import '../../../data/services/collaborative/reveal_service.dart';

// // Use Case Providers
// import '../../../domain/usecases/collaborative/request_collaborative_adoption.dart';
// import '../../../domain/usecases/collaborative/perform_collaborative_action.dart';
// import '../../../domain/usecases/collaborative/find_collaboration_match.dart';
// import '../../../domain/usecases/collaborative/process_reveal.dart';

// // Provider Exports
// import '../../../presentation/providers/collaborative/collaborative_pet_provider.dart';
// import '../../../presentation/providers/collaborative/matchmaking_provider.dart';
// import '../../../presentation/providers/collaborative/reveal_provider.dart';

// // Firebase Firestore Provider
// final firestoreProvider = Provider<FirebaseFirestore>((ref) {
//   return FirebaseFirestore.instance;
// });

// // Repository Providers
// final collaborativePetRepositoryProvider = Provider<CollaborativePetRepository>((ref) {
//   final firestore = ref.watch(firestoreProvider);
//   return FirebaseCollaborativePetRepository(firestore);
// });

// final collaborationRepositoryProvider = Provider<CollaborationRepository>((ref) {
//   final firestore = ref.watch(firestoreProvider);
//   return FirebaseCollaborationRepository(firestore);
// });

// final matchmakingRepositoryProvider = Provider<MatchmakingRepository>((ref) {
//   final firestore = ref.watch(firestoreProvider);
//   return FirebaseMatchmakingRepository(firestore);
// });

// // Service Providers
// final realTimeSyncServiceProvider = Provider<RealTimeSyncService>((ref) {
//   final firestore = ref.watch(firestoreProvider);
//   return RealTimeSyncService(firestore);
// });

// final collaborationServiceProvider = Provider<CollaborationService>((ref) {
//   final petRepository = ref.watch(collaborativePetRepositoryProvider);
//   final collaborationRepository = ref.watch(collaborationRepositoryProvider);
//   return CollaborationService(petRepository, collaborationRepository);
// });

// final matchmakingServiceProvider = Provider<MatchmakingService>((ref) {
//   final petRepository = ref.watch(collaborativePetRepositoryProvider);
//   final collaborationRepository = ref.watch(collaborationRepositoryProvider);
//   return MatchmakingService(petRepository, collaborationRepository);
// });

// final revealServiceProvider = Provider<RevealService>((ref) {
//   return RevealService();
// });

// // Use Case Providers
// final requestCollaborativeAdoptionProvider = Provider<RequestCollaborativeAdoption>((ref) {
//   final petRepository = ref.watch(collaborativePetRepositoryProvider);
//   final collaborationService = ref.watch(collaborationServiceProvider);
//   return RequestCollaborativeAdoption(petRepository, collaborationService);
// });

// final performCollaborativeActionProvider = Provider<PerformCollaborativeAction>((ref) {
//   final collaborationService = ref.watch(collaborationServiceProvider);
//   return PerformCollaborativeAction(collaborationService);
// });

// final findCollaborationMatchProvider = Provider<FindCollaborationMatch>((ref) {
//   final matchmakingService = ref.watch(matchmakingServiceProvider);
//   return FindCollaborationMatch(matchmakingService);
// });

// final processRevealProvider = Provider<ProcessReveal>((ref) {
//   final revealService = ref.watch(revealServiceProvider);
//   return ProcessReveal(revealService);
// });

// // Main Feature Providers
// final collaborativePetNotifierProvider = StateNotifierProvider<CollaborativePetNotifier, CollaborativePetState>((ref) {
//   final requestAdoption = ref.watch(requestCollaborativeAdoptionProvider);
//   final performAction = ref.watch(performCollaborativeActionProvider);
//   final syncService = ref.watch(realTimeSyncServiceProvider);
  
//   return CollaborativePetNotifier(requestAdoption, performAction, syncService);
// });

// final matchmakingNotifierProvider = StateNotifierProvider<MatchmakingNotifier, MatchmakingState>((ref) {
//   final findMatch = ref.watch(findCollaborationMatchProvider);
//   return MatchmakingNotifier(findMatch);
// });

// final revealNotifierProvider = StateNotifierProvider<RevealNotifier, RevealState>((ref) {
//   final revealService = ref.watch(revealServiceProvider);
//   return RevealNotifier(revealService);
// });

// // File: lib/presentation/routes/collaborative_routes.dart
// import 'package:flutter/material.dart';
// import '../screens/collaborative_adoption/collaborative_adoption_screen.dart';
// import '../screens/collaborative_adoption/available_pets_screen.dart';
// import '../screens/collaborative_adoption/active_collaboration_screen.dart';
// import '../screens/reveal_system/reveal_request_screen.dart';
// import '../screens/reveal_system/revealed_partner_screen.dart';
// import '../../core/classes/collaborative/collaborative_pet_entity.dart';

// class CollaborativeRoutes {
//   static const String collaborativeAdoption = '/collaborative-adoption';
//   static const String availablePets = '/available-pets';
//   static const String activeCollaboration = '/active-collaboration';
//   static const String revealRequest = '/reveal-request';
//   static const String revealedPartner = '/revealed-partner';

//   static Map<String, WidgetBuilder> get routes => {
//     collaborativeAdoption: (context) => const CollaborativeAdoptionScreen(),
//     availablePets: (context) => const AvailablePetsScreen(),
//   };

//   static Route<dynamic> generateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case activeCollaboration:
//         final pet = settings.arguments as CollaborativePetEntity;
//         return MaterialPageRoute(
//           builder: (context) => ActiveCollaborationScreen(pet: pet),
//           settings: settings,
//         );

//       case revealRequest:
//         final pet = settings.arguments as CollaborativePetEntity;
//         return MaterialPageRoute(
//           builder: (context) => RevealRequestScreen(pet: pet),
//           settings: settings,
//         );

//       case revealedPartner:
//         final args = settings.arguments as Map<String, dynamic>;
//         final pet = args['pet'] as CollaborativePetEntity;
//         final partnerInfo = args['partnerInfo'] as Map<String, dynamic>;
//         return MaterialPageRoute(
//           builder: (context) => RevealedPartnerScreen(
//             pet: pet,
//             partnerInfo: partnerInfo,
//           ),
//           settings: settings,
//         );

//       default:
//         return MaterialPageRoute(
//           builder: (context) => const Scaffold(
//             body: Center(
//               child: Text('Rota não encontrada'),
//             ),
//           ),
//         );
//     }
//   }
// }

// // File: lib/presentation/screens/collaborative_adoption/available_pets_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../providers/collaborative/collaborative_pet_provider.dart';
// import '../../widgets/collaborative_pet/collaborative_pet_card.dart';

// class AvailablePetsScreen extends ConsumerStatefulWidget {
//   const AvailablePetsScreen({super.key});

//   @override
//   ConsumerState<AvailablePetsScreen> createState() => _AvailablePetsScreenState();
// }

// class _AvailablePetsScreenState extends ConsumerState<AvailablePetsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(collaborativePetNotifierProvider.notifier).loadAvailablePets();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(collaborativePetNotifierProvider);

//     return Scaffold(
//       backgroundColor: const Color(0xFF1A1A2E),
//       appBar: AppBar(
//         title: const Text(
//           'Pets Disponíveis',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: const Color(0xFF16213E),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh, color: Colors.white),
//             onPressed: () => ref.read(collaborativePetNotifierProvider.notifier).loadAvailablePets(),
//           ),
//         ],
//       ),
//       body: state.isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: Colors.amber),
//             )
//           : state.availablePets.isEmpty
//               ? const Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.pets,
//                         color: Colors.grey,
//                         size: 64,
//                       ),
//                       SizedBox(height: 16),
//                       Text(
//                         'Nenhum pet disponível',
//                         style: TextStyle(
//                           color: Colors.grey,
//                           fontSize: 18,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : RefreshIndicator(
//                   onRefresh: () async {
//                     ref.read(collaborativePetNotifierProvider.notifier).loadAvailablePets();
//                   },
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: state.availablePets.length,
//                     itemBuilder: (context, index) {
//                       final pet = state.availablePets[index];
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 16),
//                         child: CollaborativePetCard(
//                           pet: pet,
//                           onAdopt: () => _requestAdoption(pet.id),
//                           showAdoptButton: true,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//     );
//   }

//   void _requestAdoption(String petId) {
//     const userId = 'current_user_id';
//     ref.read(collaborativePetNotifierProvider.notifier).requestCollaborativeAdoption(userId, petId);
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Solicitação de adoção enviada!'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
// }

// // File: lib/data/repositories/collaborative/matchmaking_repository.dart
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dartz/dartz.dart';
// import '../../../core/classes/collaborative/collaborative_pet_entity.dart';
// import '../../../core/classes/collaborative/user_collaboration_data.dart';
// import '../../../core/errors/failure.dart';

// abstract class MatchmakingRepository {
//   Future<Either<Failure, List<CollaborativePetEntity>>> getRecommendedPets(String userId);
//   Future<Either<Failure, UserCollaborationData>> getUserPreferences(String userId);
//   Future<Either<Failure, void>> updateUserPreferences(String userId, Map<String, dynamic> preferences);
//   Future<Either<Failure, List<String>>> getCompatibleUsers(String userId);
// }

// class FirebaseMatchmakingRepository implements MatchmakingRepository {
//   final FirebaseFirestore _firestore;
  
//   const FirebaseMatchmakingRepository(this._firestore);

//   @override
//   Future<Either<Failure, List<CollaborativePetEntity>>> getRecommendedPets(String userId) async {
//     try {
//       // Mock implementation - em produção, usaria algoritmo de recomendação
//       final querySnapshot = await _firestore
//           .collection('collaborative_pets')
//           .where('status', isEqualTo: 'waiting_for_partner')
//           .limit(10)
//           .get();

//       final pets = querySnapshot.docs
//           .map((doc) => CollaborativePetEntity.fromMap({
//                 'id': doc.id,
//                 ...doc.data(),
//               }))
//           .toList();

//       return Right(pets);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao buscar pets recomendados: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, UserCollaborationData>> getUserPreferences(String userId) async {
//     try {
//       final doc = await _firestore.collection('user_collaboration_data').doc(userId).get();
      
//       if (doc.exists) {
//         final data = UserCollaborationData.fromMap({
//           'userId': doc.id,
//           ...doc.data()!,
//         });
//         return Right(data);
//       } else {
//         return Left(NotFoundFailure('Dados do usuário não encontrados'));
//       }
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao buscar preferências: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> updateUserPreferences(String userId, Map<String, dynamic> preferences) async {
//     try {
//       await _firestore.collection('user_collaboration_data').doc(userId).update(preferences);
//       return const Right(null);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao atualizar preferências: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, List<String>>> getCompatibleUsers(String userId) async {
//     try {
//       // Mock implementation - algoritmo de compatibilidade
//       final querySnapshot = await _firestore
//           .collection('user_collaboration_data')
//           .where('userId', isNotEqualTo: userId)
//           .where('isOnline', isEqualTo: true)
//           .limit(50)
//           .get();

//       final userIds = querySnapshot.docs.map((doc) => doc.id).toList();
//       return Right(userIds);
//     } catch (e) {
//       return Left(DatabaseFailure('Erro ao buscar usuários compatíveis: $e'));
//     }
//   }
// }

// // File: lib/domain/usecases/collaborative/process_reveal.dart
// import 'package:dartz/dartz.dart';
// import '../../../core/classes/collaborative/reveal_request.dart';
// import '../../../core/errors/failure.dart';
// import '../../../data/services/collaborative/reveal_service.dart';

// class ProcessReveal {
//   final RevealService _revealService;

//   const ProcessReveal(this._revealService);

//   Future<Either<Failure, Map<String, dynamic>>> call({
//     required String petId,
//     required String userId,
//     required bool accept,
//   }) async {
//     return await _revealService.respondToRevealRequest(petId, userId, accept);
//   }

//   Future<Either<Failure, RevealRequest>> createReveal({
//     required String petId,
//     required String userId,
//   }) async {
//     return await _revealService.createRevealRequest(petId, userId);
//   }
// }

// // File: lib/core/errors/failure.dart (Complemento se não existir)
// abstract class Failure {
//   final String message;
  
//   const Failure(this.message);
// }

// class DatabaseFailure extends Failure {
//   const DatabaseFailure(super.message);
// }

// class ValidationFailure extends Failure {
//   const ValidationFailure(super.message);
// }

// class UnknownFailure extends Failure {
//   const UnknownFailure(super.message);
// }

// class NotFoundFailure extends Failure {
//   const NotFoundFailure(super.message);
// }

// class NetworkFailure extends Failure {
//   const NetworkFailure(super.message);
// }