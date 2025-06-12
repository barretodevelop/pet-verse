class ChatMessage {
  final int id;
  final String message;
  final String sender;
  final String senderAvatar;
  final int timestamp;

  ChatMessage({
    required this.id,
    required this.message,
    required this.sender,
    required this.senderAvatar,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      message: json['message'],
      sender: json['sender'],
      senderAvatar: json['senderAvatar'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'sender': sender,
      'senderAvatar': senderAvatar,
      'timestamp': timestamp,
    };
  }
}
