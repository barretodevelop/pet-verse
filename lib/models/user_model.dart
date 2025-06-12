// UserModel
// UserModel
class UserModel {
  final String id, username, avatar, email;
  final int level,
      xp,
      coins,
      gems,
      purchasedSlotsCount; // ✅ Added purchasedSlotsCount
  final DateTime createdAt;
  final List<String> ownedPetIds;
  final Map<String, dynamic> aiConfig;

  UserModel({
    required this.id,
    required this.username,
    required this.avatar,
    required this.email,
    required this.level,
    required this.xp,
    required this.coins,
    required this.gems,
    required this.createdAt,
    required this.ownedPetIds,
    required this.aiConfig,
    this.purchasedSlotsCount = 2, // ✅ Default to 2 slots
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'avatar': avatar,
        'email': email,
        'level': level,
        'xp': xp,
        'coins': coins,
        'gems': gems,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'ownedPetIds': ownedPetIds,
        'aiConfig': aiConfig,
        'purchasedSlotsCount': purchasedSlotsCount, // ✅ Add to JSON
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        username: json['username'],
        avatar: json['avatar'],
        email: json['email'],
        level: json['level'],
        xp: json['xp'],
        coins: json['coins'],
        gems: json['gems'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
        ownedPetIds: List<String>.from(json['ownedPetIds'] ?? []),
        aiConfig: json['aiConfig'] ?? {},
        purchasedSlotsCount: json['purchasedSlotsCount'] as int? ??
            2, // ✅ Read from JSON, default to 2
      );

  // ✅ COMPLETO
  UserModel copyWith({
    String? id,
    String? username,
    String? avatar,
    String? email,
    int? level,
    int? xp,
    int? coins,
    int? gems,
    DateTime? createdAt,
    List<String>? ownedPetIds,
    Map<String, dynamic>? aiConfig,
    int? purchasedSlotsCount, // ✅ Add to copyWith
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      createdAt: createdAt ?? this.createdAt,
      ownedPetIds: ownedPetIds ?? this.ownedPetIds,
      aiConfig: aiConfig ?? this.aiConfig,
      purchasedSlotsCount: purchasedSlotsCount ??
          this.purchasedSlotsCount, // ✅ Handle in copyWith
    );
  }
}
