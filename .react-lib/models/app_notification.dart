class AppNotification {
  final int id;
  final String message;
  final int timestamp;

  AppNotification(
      {required this.id, required this.message, required this.timestamp});

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
