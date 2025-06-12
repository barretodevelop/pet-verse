// File: lib/domain/entities/daily_reward_entity.dart

import 'package:equatable/equatable.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';

/// Daily reward entity representing daily bonus rewards
class DailyRewardEntity extends Equatable {
  final String id;
  final int day;
  final RewardType type;
  final int amount;
  final String description;
  final bool isClaimed;
  final DateTime? claimedAt;

  const DailyRewardEntity({
    required this.id,
    required this.day,
    required this.type,
    required this.amount,
    required this.description,
    this.isClaimed = false,
    this.claimedAt,
  });

  DailyRewardEntity copyWith({
    String? id,
    int? day,
    RewardType? type,
    int? amount,
    String? description,
    bool? isClaimed,
    DateTime? claimedAt,
  }) {
    return DailyRewardEntity(
      id: id ?? this.id,
      day: day ?? this.day,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      isClaimed: isClaimed ?? this.isClaimed,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        day,
        type,
        amount,
        description,
        isClaimed,
        claimedAt,
      ];
}
