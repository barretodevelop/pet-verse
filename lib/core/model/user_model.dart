// lib/shared/models/user_model.dart
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/model/user_settings.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? currentPetId;
  final List<String> petIds;
  final UserSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.currentPetId,
    this.petIds = const [],
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasPet => currentPetId != null && currentPetId!.isNotEmpty;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      avatarUrl: data['avatarUrl'],
      currentPetId: data['currentPetId'],
      petIds: List<String>.from(data['petIds'] ?? []),
      settings: UserSettings.fromMap(data['settings']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'currentPetId': currentPetId,
      'petIds': petIds,
      'settings': settings.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? currentPetId,
    List<String>? petIds,
    UserSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentPetId: currentPetId ?? this.currentPetId,
      petIds: petIds ?? this.petIds,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static Future<UserModel?> fromMap(Map<String, dynamic>? data) async {
    if (data == null) return null;

    return UserModel(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      avatarUrl: data['avatarUrl'],
      currentPetId: data['currentPetId'],
      petIds: List<String>.from(data['petIds'] ?? []),
      settings: UserSettings.fromMap(data['settings']),
      createdAt:
          DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

// Classes UserSettings mantêm-se iguais (NotificationSettings, PrivacySettings, GameplaySettings)
class UserSettings {
  final NotificationSettings notifications;
  final PrivacySettings privacy;
  final GameplaySettings gameplay;

  const UserSettings({
    required this.notifications,
    required this.privacy,
    required this.gameplay,
  });

  factory UserSettings.defaultSettings() {
    return UserSettings(
      notifications: NotificationSettings.defaultSettings(),
      privacy: PrivacySettings.defaultSettings(),
      gameplay: GameplaySettings.defaultSettings(),
    );
  }

  factory UserSettings.fromMap(Map<String, dynamic>? map) {
    map = map ?? {};
    return UserSettings(
      notifications: NotificationSettings.fromMap(map['notifications']),
      privacy: PrivacySettings.fromMap(map['privacy']),
      gameplay: GameplaySettings.fromMap(map['gameplay']),
    );
  }

  factory UserSettings.fromJson(String jsonString) {
    return UserSettings.fromMap(jsonDecode(jsonString));
  }

  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications.toMap(),
      'privacy': privacy.toMap(),
      'gameplay': gameplay.toMap(),
    };
  }

  String toJson() => jsonEncode(toMap());

  UserSettings copyWith({
    NotificationSettings? notifications,
    PrivacySettings? privacy,
    GameplaySettings? gameplay,
  }) {
    return UserSettings(
      notifications: notifications ?? this.notifications,
      privacy: privacy ?? this.privacy,
      gameplay: gameplay ?? this.gameplay,
    );
  }
}

// // lib/shared/models/user_model.dart
// import 'package:cloud_firestore/cloud_firestore.dart';

// class UserModel {
//   final String id;
//   final String email;
//   final String displayName;
//   final String? avatarUrl;
//   final String? currentPetId;
//   final List<String> petIds;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   const UserModel({
//     required this.id,
//     required this.email,
//     required this.displayName,
//     this.avatarUrl,
//     this.currentPetId,
//     this.petIds = const [],
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   bool get hasPet => currentPetId != null && currentPetId!.isNotEmpty;

//   factory UserModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return UserModel(
//       id: doc.id,
//       email: data['email'] ?? '',
//       displayName: data['displayName'] ?? '',
//       avatarUrl: data['avatarUrl'],
//       currentPetId: data['currentPetId'],
//       petIds: List<String>.from(data['petIds'] ?? []),
//       createdAt: (data['createdAt'] as Timestamp).toDate(),
//       updatedAt: (data['updatedAt'] as Timestamp).toDate(),
//     );
//   }

//   Map<String, dynamic> toFirestore() {
//     return {
//       'email': email,
//       'displayName': displayName,
//       'avatarUrl': avatarUrl,
//       'currentPetId': currentPetId,
//       'petIds': petIds,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'updatedAt': Timestamp.fromDate(updatedAt),
//     };
//   }

//   UserModel copyWith({
//     String? id,
//     String? email,
//     String? displayName,
//     String? avatarUrl,
//     String? currentPetId,
//     List<String>? petIds,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       email: email ?? this.email,
//       displayName: displayName ?? this.displayName,
//       avatarUrl: avatarUrl ?? this.avatarUrl,
//       currentPetId: currentPetId ?? this.currentPetId,
//       petIds: petIds ?? this.petIds,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }

//   static Future<UserModel?> fromMap(Map<String, dynamic>? data) async {
//     return null;
//   }
// }
