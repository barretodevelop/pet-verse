// lib/shared/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final String? currentPetId;
  final List<String> petIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.currentPetId,
    this.petIds = const [],
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
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'currentPetId': currentPetId,
      'petIds': petIds,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static Future<UserModel?> fromMap(Map<String, dynamic>? data) async {
    return null;
  }
}
