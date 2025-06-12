class Particle {
  final int id;
  final String type;
  double x;
  double y;
  double opacity;
  double scale;
  double vx;
  double vy;

  Particle({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.opacity = 1.0,
    this.scale = 1.0,
    this.vx = 0.0,
    this.vy = 0.0,
  });

  factory Particle.fromJson(Map<String, dynamic> json) {
    return Particle(
      id: json['id'],
      type: json['type'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      opacity: json['opacity'].toDouble(),
      scale: json['scale'].toDouble(),
      vx: json['vx'].toDouble(),
      vy: json['vy'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'x': x,
      'y': y,
      'opacity': opacity,
      'scale': scale,
      'vx': vx,
      'vy': vy,
    };
  }

  Particle copyWith({
    double? x,
    double? y,
    double? opacity,
    double? scale,
    double? vx,
    double? vy,
  }) {
    return Particle(
      id: id,
      type: type,
      x: x ?? this.x,
      y: y ?? this.y,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
      vx: vx ?? this.vx,
      vy: vy ?? this.vy,
    );
  }
}
