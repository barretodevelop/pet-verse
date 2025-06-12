class Accessory {
  final int id;
  final String name;
  final String emoji;
  final String type;
  final String effect;
  final String category;

  Accessory({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    required this.effect,
    required this.category,
  });

  factory Accessory.fromJson(Map<String, dynamic> json) {
    return Accessory(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      type: json['type'],
      effect: json['effect'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'type': type,
      'effect': effect,
      'category': category,
    };
  }

  Accessory copyWith({
    int? id,
    String? name,
    String? emoji,
    String? type,
    String? effect,
    String? category,
  }) {
    return Accessory(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
      effect: effect ?? this.effect,
      category: category ?? this.category,
    );
  }
}
