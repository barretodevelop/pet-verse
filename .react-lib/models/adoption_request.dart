import 'pet.dart'; // Importa o modelo Pet

class AdoptionRequest {
  final int id;
  final Pet pet;
  final int userId;
  final String userAvatar;
  final int expiresAt;
  final String status;

  AdoptionRequest({
    required this.id,
    required this.pet,
    required this.userId,
    required this.userAvatar,
    required this.expiresAt,
    required this.status,
  });

  factory AdoptionRequest.fromJson(Map<String, dynamic> json) {
    return AdoptionRequest(
      id: json['id'],
      pet: Pet.fromJson(json['pet']),
      userId: json['userId'],
      userAvatar: json['userAvatar'],
      expiresAt: json['expiresAt'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet': pet.toJson(),
      'userId': userId,
      'userAvatar': userAvatar,
      'expiresAt': expiresAt,
      'status': status,
    };
  }

  AdoptionRequest copyWith({String? status}) {
    return AdoptionRequest(
      id: id,
      pet: pet,
      userId: userId,
      userAvatar: userAvatar,
      expiresAt: expiresAt,
      status: status ?? this.status,
    );
  }
}
