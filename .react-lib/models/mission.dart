class Mission {
  final int id;
  final String title;
  final String desc;
  final int reward;
  final int progress;
  final int max;

  Mission({
    required this.id,
    required this.title,
    required this.desc,
    required this.reward,
    required this.progress,
    required this.max,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      title: json['title'],
      desc: json['desc'],
      reward: json['reward'],
      progress: json['progress'],
      max: json['max'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'reward': reward,
      'progress': progress,
      'max': max,
    };
  }

  Mission copyWith({int? progress}) {
    return Mission(
      id: id,
      title: title,
      desc: desc,
      reward: reward,
      progress: progress ?? this.progress,
      max: max,
    );
  }
}
