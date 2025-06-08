// File: lib/data/models/transaction_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/core/utils/helpers.dart';
import 'package:petverse/domain/entities/transaction_entity.dart';

/// Transaction model for data layer
class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.amount,
    required super.currency,
    required super.description,
    required super.timestamp,
    super.metadata,
  });

  /// Create TransactionModel from TransactionEntity
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      amount: entity.amount,
      currency: entity.currency,
      description: entity.description,
      timestamp: entity.timestamp,
      metadata: entity.metadata,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': Helpers.enumToString(type),
      'amount': amount,
      'currency': Helpers.enumToString(currency),
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'metadata': metadata,
    };
  }

  /// Create TransactionModel from Firestore document
  factory TransactionModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: Helpers.stringToEnum(TransactionType.values, data['type']) ?? TransactionType.purchase,
      amount: data['amount'] ?? 0,
      currency: Helpers.stringToEnum(CurrencyType.values, data['currency']) ?? CurrencyType.coins,
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp? ?? Timestamp.now()).toDate(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  /// Create TransactionModel from JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['userId'],
      type: Helpers.stringToEnum(TransactionType.values, json['type']) ?? TransactionType.purchase,
      amount: json['amount'],
      currency: Helpers.stringToEnum(CurrencyType.values, json['currency']) ?? CurrencyType.coins,
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': Helpers.enumToString(type),
      'amount': amount,
      'currency': Helpers.enumToString(currency),
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  TransactionModel copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    int? amount,
    CurrencyType? currency,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionModel(
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
}
