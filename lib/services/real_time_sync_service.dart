// File: lib/services/real_time_sync_service.dart

import 'dart:async';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/data/models/collaboration/collaborative_action_model.dart';
import 'package:petverse/data/models/collaboration/collaborative_pet_model.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_action_entity.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';

class RealTimeSyncService {
  static final RealTimeSyncService _instance = RealTimeSyncService._internal();
  factory RealTimeSyncService() => _instance;
  RealTimeSyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, StreamSubscription> _activeStreams = {};

  /// Stream de atualizações em tempo real do pet colaborativo
  Stream<CollaborativePetEntity> watchPetUpdates(String petId) {
    return _firestore.collection('collaborative_pets').doc(petId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw Exception('Pet colaborativo não encontrado');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      data['id'] = snapshot.id;

      return CollaborativePetModel.fromMap(data).toEntity();
    }).handleError((error) {
      developer.log('Erro ao assistir pet: $error', name: 'RealTimeSyncService');
    });
  }

  /// Stream de ações em tempo real
  Stream<CollaborativeActionEntity> watchPetActions(String petId) {
    return _firestore
        .collection('collaborative_pets')
        .doc(petId)
        .collection('actions')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        throw Exception('Nenhuma ação encontrada');
      }

      final doc = snapshot.docs.first;
      final data = doc.data();
      data['id'] = doc.id;

      return CollaborativeActionModel.fromMap(data).toEntity();
    }).handleError((error) {
      developer.log('Erro ao assistir ações: $error', name: 'RealTimeSyncService');
    });
  }

  /// Notificar ação para parceiro
  Future<void> notifyPartnerAction(String petId, String userId, String actionType) async {
    try {
      await _firestore.collection('collaborative_pets').doc(petId).collection('notifications').add({
        'type': 'partner_action',
        'userId': userId,
        'actionType': actionType,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    } catch (e) {
      developer.log('Erro ao notificar parceiro: $e', name: 'RealTimeSyncService');
    }
  }

  /// Sincronizar stats do pet em tempo real
  Future<void> syncPetStats(String petId, Map<String, dynamic> stats) async {
    try {
      await _firestore.collection('collaborative_pets').doc(petId).update({
        ...stats,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Erro ao sincronizar stats: $e', name: 'RealTimeSyncService');
    }
  }

  /// Limpar streams ativos
  void dispose() {
    for (final subscription in _activeStreams.values) {
      subscription.cancel();
    }
    _activeStreams.clear();
  }
}
