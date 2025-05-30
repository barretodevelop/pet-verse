import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum RoomStatus { waiting, active, ended }

class Room extends Equatable {
  final String id;
  final String code;
  final RoomStatus status;
  final DateTime createdAt;
  final String createdBy;
  final List<String> parentIds;
  final String? petId;
  final DateTime? matchedAt;
  final Map<String, dynamic>? settings;

  const Room({
    required this.id,
    required this.code,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    required this.parentIds,
    this.petId,
    this.matchedAt,
    this.settings,
  });

  bool get isFull => parentIds.length >= 2;
  bool get isWaiting => status == RoomStatus.waiting;
  bool get isActive => status == RoomStatus.active;

  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      code: data['code'] ?? '',
      status: RoomStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => RoomStatus.waiting,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      parentIds: List<String>.from(data['parentIds'] ?? []),
      petId: data['petId'],
      matchedAt: data['matchedAt'] != null
          ? (data['matchedAt'] as Timestamp).toDate()
          : null,
      settings: data['settings'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
      'parentIds': parentIds,
      'petId': petId,
      'matchedAt': matchedAt != null ? Timestamp.fromDate(matchedAt!) : null,
      'settings': settings,
    };
  }

  Room copyWith({
    String? id,
    String? code,
    RoomStatus? status,
    DateTime? createdAt,
    String? createdBy,
    List<String>? parentIds,
    String? petId,
    DateTime? matchedAt,
    Map<String, dynamic>? settings,
  }) {
    return Room(
      id: id ?? this.id,
      code: code ?? this.code,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      parentIds: parentIds ?? this.parentIds,
      petId: petId ?? this.petId,
      matchedAt: matchedAt ?? this.matchedAt,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        status,
        createdAt,
        createdBy,
        parentIds,
        petId,
        matchedAt,
        settings
      ];
}
