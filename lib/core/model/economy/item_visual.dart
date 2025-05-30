class ItemVisual {
  final String emoji;
  final String actionDescription;

  ItemVisual({
    required this.emoji,
    required this.actionDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'actionDescription': actionDescription,
    };
  }

  factory ItemVisual.fromJson(Map<String, dynamic> json) {
    return ItemVisual(
      emoji: json['emoji'],
      actionDescription: json['actionDescription'],
    );
  }
}
