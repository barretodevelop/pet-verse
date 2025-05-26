import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Pet extends Equatable {
  final String id;
  final String name;
  final String roomId;
  final List<String> parentIds;
  final int hunger; // 0-100
  final int happiness; // 0-100
  final int cleanliness; // 0-100
  final DateTime lastFed;
  final DateTime lastPlayed;
  final DateTime lastCleaned;
  final String? lastCaredBy;
  final Map<String, dynamic>? customization;
  final DateTime createdAt;

  const Pet({
    required this.id,
    required this.name,
    required this.roomId,
    required this.parentIds,
    required this.hunger,
    required this.happiness,
    required this.cleanliness,
    required this.lastFed,
    required this.lastPlayed,
    required this.lastCleaned,
    this.lastCaredBy,
    this.customization,
    required this.createdAt,
  });

  bool get isHungry => hunger < 30;
  bool get isSad => happiness < 30;
  bool get isDirty => cleanliness < 30;

  String get status {
    if (isHungry) return 'Com fome';
    if (isSad) return 'Triste';
    if (isDirty) return 'Precisa de banho';
    if (happiness > 70) return 'Feliz!';
    return 'Normal';
  }

  String get mood {
    final hour = DateTime.now().hour;
    if (hour >= 22 || hour < 6) return 'sleepy';
    if (hour >= 6 && hour < 12) return 'energetic';
    if (hour >= 12 && hour < 18) return 'playful';
    return 'calm';
  }

  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pet(
      id: doc.id,
      name: data['name'] ?? 'Pet',
      roomId: data['roomId'] ?? '',
      parentIds: List<String>.from(data['parentIds'] ?? []),
      hunger: data['hunger'] ?? 50,
      happiness: data['happiness'] ?? 50,
      cleanliness: data['cleanliness'] ?? 50,
      lastFed: (data['lastFed'] as Timestamp).toDate(),
      lastPlayed: (data['lastPlayed'] as Timestamp).toDate(),
      lastCleaned: (data['lastCleaned'] as Timestamp).toDate(),
      lastCaredBy: data['lastCaredBy'],
      customization: data['customization'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'roomId': roomId,
      'parentIds': parentIds,
      'hunger': hunger,
      'happiness': happiness,
      'cleanliness': cleanliness,
      'lastFed': Timestamp.fromDate(lastFed),
      'lastPlayed': Timestamp.fromDate(lastPlayed),
      'lastCleaned': Timestamp.fromDate(lastCleaned),
      'lastCaredBy': lastCaredBy,
      'customization': customization,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Pet copyWith({
    String? name,
    int? hunger,
    int? happiness,
    int? cleanliness,
    DateTime? lastFed,
    DateTime? lastPlayed,
    DateTime? lastCleaned,
    String? lastCaredBy,
    Map<String, dynamic>? customization,
  }) {
    return Pet(
      id: id,
      name: name ?? this.name,
      roomId: roomId,
      parentIds: parentIds,
      hunger: hunger ?? this.hunger,
      happiness: happiness ?? this.happiness,
      cleanliness: cleanliness ?? this.cleanliness,
      lastFed: lastFed ?? this.lastFed,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      lastCleaned: lastCleaned ?? this.lastCleaned,
      lastCaredBy: lastCaredBy ?? this.lastCaredBy,
      customization: customization ?? this.customization,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        roomId,
        parentIds,
        hunger,
        happiness,
        cleanliness,
        lastFed,
        lastPlayed,
        lastCleaned,
        lastCaredBy,
        customization,
        createdAt
      ];
}
