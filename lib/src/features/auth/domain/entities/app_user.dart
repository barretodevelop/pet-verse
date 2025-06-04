import 'package:flutter/foundation.dart'; // Para @immutable

@immutable
class AppUser {
  final String id; // Firebase Auth UID
  final String username; // Display name
  final String? email;
  final String? photoUrl;
  final String? currentPetId; // ID do pet atualmente ativo para este usuário

  const AppUser({
    required this.id,
    required this.username,
    this.email,
    this.photoUrl,
    this.currentPetId,
  });

  AppUser copyWith({
    String? id,
    String? username,
    String? email,
    String? photoUrl,
    String? currentPetId,
    bool clearCurrentPetId = false,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      currentPetId:
          clearCurrentPetId ? null : currentPetId ?? this.currentPetId,
    );
  }
}
