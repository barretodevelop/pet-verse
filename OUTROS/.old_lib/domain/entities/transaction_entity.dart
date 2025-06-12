// File: lib/domain/entities/transaction_entity.dart

import 'package:equatable/equatable.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';

/// Transaction entity for tracking currency transactions
class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final int amount;
  final CurrencyType currency;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.description,
    required this.timestamp,
    this.metadata = const {},
  });

  TransactionEntity copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    int? amount,
    CurrencyType? currency,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        amount,
        currency,
        description,
        timestamp,
        metadata,
      ];
}
