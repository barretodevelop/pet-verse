class ShopItem {
  final int id;
  final String name;
  final String emoji;
  final int cost;
  final String type;
  final String effect;
  final String category;

  ShopItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.cost,
    required this.type,
    required this.effect,
    required this.category,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      cost: json['cost'],
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
      'cost': cost,
      'type': type,
      'effect': effect,
      'category': category,
    };
  }

  ShopItem copyWith({
    int? id,
    String? name,
    String? emoji,
    int? cost,
    String? type,
    String? effect,
    String? category,
  }) {
    return ShopItem(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      cost: cost ?? this.cost,
      type: type ?? this.type,
      effect: effect ?? this.effect,
      category: category ?? this.category,
    );
  }
}
