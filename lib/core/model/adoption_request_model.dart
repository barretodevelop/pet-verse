// lib/shared/models/adoption_request_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/enums/enums.dart';

class AdoptionRequestModel {
  final String id;
  final String requesterId;
  final String requesterdisplayName;
  final List<String> selectedPetIds;
  final String? acceptedPetId;
  final String? coParentId;
  final String? coParentdisplayName;
  final AdoptionRequestStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String? shareLink;

  const AdoptionRequestModel({
    required this.id,
    required this.requesterId,
    required this.requesterdisplayName,
    required this.selectedPetIds,
    this.acceptedPetId,
    this.coParentId,
    this.coParentdisplayName,
    this.status = AdoptionRequestStatus.pending,
    required this.createdAt,
    required this.expiresAt,
    this.shareLink,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isPending => status == AdoptionRequestStatus.pending && !isExpired;
  int get daysRemaining => expiresAt.difference(DateTime.now()).inDays;

  factory AdoptionRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdoptionRequestModel(
      id: doc.id,
      requesterId: data['requesterId'] ?? '',
      requesterdisplayName: data['requesterdisplayName'] ?? '',
      selectedPetIds: List<String>.from(data['selectedPetIds'] ?? []),
      acceptedPetId: data['acceptedPetId'],
      coParentId: data['coParentId'],
      coParentdisplayName: data['coParentdisplayName'],
      status: AdoptionRequestStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => AdoptionRequestStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      shareLink: data['shareLink'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requesterId': requesterId,
      'requesterdisplayName': requesterdisplayName,
      'selectedPetIds': selectedPetIds,
      'acceptedPetId': acceptedPetId,
      'coParentId': coParentId,
      'coParentdisplayName': coParentdisplayName,
      'status': status.toString(),
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'shareLink': shareLink,
    };
  }
}
