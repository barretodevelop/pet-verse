import 'package:equatable/equatable.dart';

enum MessageType { text, quick, system }

class Message extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final MessageType type;

  const Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    required this.type,
  });

  bool get isQuickMessage => type == MessageType.quick;
  bool get isSystemMessage => type == MessageType.system;

  factory Message.fromRealtimeDB(String id, Map<dynamic, dynamic> data) {
    return Message(
      id: id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? 'Usuário',
      text: data['text'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] ?? 0),
      type: MessageType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toRealtimeDB() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type.name,
    };
  }

  @override
  List<Object?> get props => [id, senderId, senderName, text, timestamp, type];
}
