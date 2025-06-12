class FeedPost {
  final int id;
  final String type;
  final String content;
  final int? petId;
  final int timestamp;
  final int? userId;

  FeedPost({
    required this.id,
    required this.type,
    required this.content,
    this.petId,
    required this.timestamp,
    this.userId,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      petId: json['petId'],
      timestamp: json['timestamp'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'petId': petId,
      'timestamp': timestamp,
      'userId': userId,
    };
  }
}
