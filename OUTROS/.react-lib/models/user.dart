class User {
  final String username;
  final String avatar;
  final int level;
  final int xp;
  final int id;

  User({
    required this.username,
    required this.avatar,
    this.level = 1,
    this.xp = 0,
    required this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      avatar: json['avatar'],
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'avatar': avatar,
      'level': level,
      'xp': xp,
      'id': id,
    };
  }

  User copyWith(
      {String? username, String? avatar, int? level, int? xp, int? id}) {
    return User(
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      id: id ?? this.id,
    );
  }
}
