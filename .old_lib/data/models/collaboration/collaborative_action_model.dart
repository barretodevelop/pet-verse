// File: lib/data/models/collaboration/collaborative_action_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_action_entity.dart';

class CollaborativeActionModel {
  final String id;
  final String userId;
  final String petId;
  final CollaborativeActionType actionType;
  final DateTime timestamp;
  final String anonymousName;
  final Map<String, dynamic> effects;
  final int xpGained;
  final Map<String, dynamic> metadata;

  CollaborativeActionModel({
    required this.id,
    required this.userId,
    required this.petId,
    required this.actionType,
    required this.timestamp,
    required this.anonymousName,
    required this.effects,
    required this.xpGained,
    required this.metadata,
  });

  factory CollaborativeActionModel.fromMap(Map<String, dynamic> map) {
    return CollaborativeActionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      petId: map['petId'] ?? '',
      actionType: CollaborativeActionType.values.firstWhere(
        (type) => type.name == map['actionType'],
        orElse: () => CollaborativeActionType.feed,
      ),
      timestamp: _parseTimestamp(map['timestamp']),
      anonymousName: map['anonymousName'] ?? '',
      effects: Map<String, dynamic>.from(map['effects'] ?? {}),
      xpGained: map['xpGained'] ?? 0,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'petId': petId,
      'actionType': actionType.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'anonymousName': anonymousName,
      'effects': effects,
      'xpGained': xpGained,
      'metadata': metadata,
    };
  }

  CollaborativeActionEntity toEntity() {
    return CollaborativeActionEntity(
      id: id,
      userId: userId,
      petId: petId,
      actionType: actionType,
      timestamp: timestamp,
      anonymousName: anonymousName,
      effects: effects,
      xpGained: xpGained,
      metadata: metadata,
    );
  }

  factory CollaborativeActionModel.fromEntity(CollaborativeActionEntity entity) {
    return CollaborativeActionModel(
      id: entity.id,
      userId: entity.userId,
      petId: entity.petId,
      actionType: entity.actionType,
      timestamp: entity.timestamp,
      anonymousName: entity.anonymousName,
      effects: entity.effects,
      xpGained: entity.xpGained,
      metadata: entity.metadata,
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }
}
