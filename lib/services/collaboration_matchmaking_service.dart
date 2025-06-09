// File: lib/services/collaboration_matchmaking_service.dart

import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';

class CollaborationMatchmakingService {
  static final CollaborationMatchmakingService _instance =
      CollaborationMatchmakingService._internal();
  factory CollaborationMatchmakingService() => _instance;
  CollaborationMatchmakingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Processar matchmaking para um pet
  Future<bool> processMatchmaking(String petId, String userId) async {
    try {
      final batch = _firestore.batch();

      // Buscar lista de espera
      final waitingListRef =
          _firestore.collection('collaborative_pets').doc(petId).collection('waiting_list');

      final waitingSnapshot = await waitingListRef.get();

      // Se já tem 2 pessoas na lista (incluindo a atual), fazer match
      if (waitingSnapshot.docs.isNotEmpty) {
        final existingUser = waitingSnapshot.docs.first.data()['userId'] as String;

        if (existingUser != userId) {
          // Fazer match
          final petRef = _firestore.collection('collaborative_pets').doc(petId);

          batch.update(petRef, {
            'caretakerIds': [existingUser, userId],
            'status': CollaborationStatus.activeCollaboration.name,
            'matchedAt': FieldValue.serverTimestamp(),
          });

          // Limpar lista de espera
          for (final doc in waitingSnapshot.docs) {
            batch.delete(doc.reference);
          }

          await batch.commit();

          // Notificar ambos os usuários
          await _notifyMatch(petId, [existingUser, userId]);

          return true;
        }
      }

      // Adicionar à lista de espera se não houve match
      await waitingListRef.add({
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return false;
    } catch (e) {
      developer.log('Erro no matchmaking: $e', name: 'CollaborationMatchmakingService');
      return false;
    }
  }

  /// Buscar pets recomendados baseado no perfil do usuário
  Future<List<String>> getRecommendedPets(String userId) async {
    try {
      // Buscar dados de colaboração do usuário
      final userDataSnapshot =
          await _firestore.collection('user_collaboration_data').doc(userId).get();

      if (!userDataSnapshot.exists) {
        // Usuário novo, retornar pets para iniciantes
        return await _getBeginnerPets();
      }

      final userData = userDataSnapshot.data()!;
      final experienceLevel = userData['experienceLevel'] as int? ?? 0;

      // Buscar pets baseado no nível de experiência
      final petsSnapshot = await _firestore
          .collection('collaborative_pets')
          .where('status', isEqualTo: CollaborationStatus.waitingForPartner.name)
          .where('difficulty', isEqualTo: _getDifficultyForLevel(experienceLevel).name)
          .limit(10)
          .get();

      return petsSnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      developer.log('Erro ao buscar pets recomendados: $e',
          name: 'CollaborationMatchmakingService');
      return [];
    }
  }

  /// Verificar compatibilidade entre usuários
  Future<double> checkUserCompatibility(String userId1, String userId2) async {
    try {
      final user1Data = await _getUserCollaborationData(userId1);
      final user2Data = await _getUserCollaborationData(userId2);

      if (user1Data == null || user2Data == null) return 0.5;

      double compatibility = 0.0;

      // Fator 1: Diferença de nível de experiência (máximo 0.3)
      final expDiff = (user1Data['experienceLevel'] - user2Data['experienceLevel']).abs();
      compatibility += (1.0 - (expDiff / 50).clamp(0.0, 1.0)) * 0.3;

      // Fator 2: Rating de cooperação (máximo 0.4)
      final avgRating = ((user1Data['cooperationRating'] + user2Data['cooperationRating']) / 2);
      compatibility += (avgRating / 5.0) * 0.4;

      // Fator 3: Preferências similares (máximo 0.3)
      final user1Prefs = Set<String>.from(user1Data['preferredPetTypes'] ?? []);
      final user2Prefs = Set<String>.from(user2Data['preferredPetTypes'] ?? []);
      final commonPrefs = user1Prefs.intersection(user2Prefs).length;
      final totalPrefs = user1Prefs.union(user2Prefs).length;

      if (totalPrefs > 0) {
        compatibility += (commonPrefs / totalPrefs) * 0.3;
      }

      return compatibility.clamp(0.0, 1.0);
    } catch (e) {
      developer.log('Erro ao verificar compatibilidade: $e',
          name: 'CollaborationMatchmakingService');
      return 0.5;
    }
  }

  Future<void> _notifyMatch(String petId, List<String> userIds) async {
    try {
      final batch = _firestore.batch();

      for (final userId in userIds) {
        final notificationRef =
            _firestore.collection('users').doc(userId).collection('notifications').doc();

        batch.set(notificationRef, {
          'type': 'collaboration_match',
          'petId': petId,
          'title': '🎉 Parceiro Encontrado!',
          'message': 'Você encontrou um parceiro para cuidar do pet colaborativo!',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      await batch.commit();
    } catch (e) {
      developer.log('Erro ao notificar match: $e', name: 'CollaborationMatchmakingService');
    }
  }

  Future<List<String>> _getBeginnerPets() async {
    final snapshot = await _firestore
        .collection('collaborative_pets')
        .where('status', isEqualTo: CollaborationStatus.waitingForPartner.name)
        .where('difficulty', isEqualTo: CollaborationDifficulty.beginner.name)
        .limit(5)
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  CollaborationDifficulty _getDifficultyForLevel(int level) {
    if (level < 10) return CollaborationDifficulty.beginner;
    if (level < 25) return CollaborationDifficulty.intermediate;
    if (level < 50) return CollaborationDifficulty.advanced;
    return CollaborationDifficulty.expert;
  }

  Future<Map<String, dynamic>?> _getUserCollaborationData(String userId) async {
    try {
      final snapshot = await _firestore.collection('user_collaboration_data').doc(userId).get();

      return snapshot.exists ? snapshot.data() : null;
    } catch (e) {
      return null;
    }
  }
}
