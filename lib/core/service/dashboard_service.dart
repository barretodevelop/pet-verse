// lib/data/services/dashboard_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Modelo para atividade recente
class RecentActivity {
  final String id;
  final String title;
  final String description;
  final String type; // 'pet_care', 'achievement', 'adoption', 'game'
  final DateTime timestamp;
  final String? petId;
  final Map<String, dynamic>? metadata;

  RecentActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.petId,
    this.metadata,
  });

  factory RecentActivity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecentActivity(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? 'general',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      petId: data['petId'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
      'petId': petId,
      'metadata': metadata,
    };
  }
}

/// Modelo para dica diária
class DailyTip {
  final String id;
  final String title;
  final String content;
  final String category; // 'pet_care', 'game', 'social', 'general'
  final int priority;
  final DateTime? expiresAt;

  DailyTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.priority = 0,
    this.expiresAt,
  });

  factory DailyTip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DailyTip(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'] ?? 'general',
      priority: data['priority'] ?? 0,
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
    );
  }
}

/// Modelo para estatísticas do dashboard
class DashboardStats {
  final int totalPets;
  final int adoptedPets;
  final int availablePets;
  final int completedAchievements;
  final int totalPlayTime; // em minutos
  final int dailyStreak;
  final DateTime lastActiveDate;
  final Map<String, int> gameScores; // scores por jogo

  DashboardStats({
    required this.totalPets,
    required this.adoptedPets,
    required this.availablePets,
    required this.completedAchievements,
    required this.totalPlayTime,
    required this.dailyStreak,
    required this.lastActiveDate,
    required this.gameScores,
  });

  factory DashboardStats.empty() {
    return DashboardStats(
      totalPets: 0,
      adoptedPets: 0,
      availablePets: 0,
      completedAchievements: 0,
      totalPlayTime: 0,
      dailyStreak: 0,
      lastActiveDate: DateTime.now(),
      gameScores: {},
    );
  }

  factory DashboardStats.fromFirestore(Map<String, dynamic> data) {
    return DashboardStats(
      totalPets: data['totalPets'] ?? 0,
      adoptedPets: data['adoptedPets'] ?? 0,
      availablePets: data['availablePets'] ?? 0,
      completedAchievements: data['completedAchievements'] ?? 0,
      totalPlayTime: data['totalPlayTime'] ?? 0,
      dailyStreak: data['dailyStreak'] ?? 0,
      lastActiveDate: data['lastActiveDate'] != null
          ? (data['lastActiveDate'] as Timestamp).toDate()
          : DateTime.now(),
      gameScores: Map<String, int>.from(data['gameScores'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalPets': totalPets,
      'adoptedPets': adoptedPets,
      'availablePets': availablePets,
      'completedAchievements': completedAchievements,
      'totalPlayTime': totalPlayTime,
      'dailyStreak': dailyStreak,
      'lastActiveDate': Timestamp.fromDate(lastActiveDate),
      'gameScores': gameScores,
    };
  }
}

/// Serviço para gerenciar dados do dashboard
class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  /// Busca estatísticas do dashboard
  Future<DashboardStats> getDashboardStats() async {
    if (_userId == null) return DashboardStats.empty();

    try {
      // Busca dados do usuário
      final userDoc = await _firestore.collection('users').doc(_userId).get();

      if (!userDoc.exists) {
        await _createUserDocument();
        return DashboardStats.empty();
      }

      final userData = userDoc.data()!;

      // Busca contagem de pets
      final petsQuery = await _firestore
          .collection('pets')
          .where('ownerId', isEqualTo: _userId)
          .get();

      final totalPets = petsQuery.docs.length;
      final adoptedPets =
          petsQuery.docs.where((doc) => doc.data()['isAdopted'] == true).length;

      // Calcula daily streak
      final lastActive = userData['lastActiveDate'] != null
          ? (userData['lastActiveDate'] as Timestamp).toDate()
          : DateTime.now();

      final daysSinceLastActive = DateTime.now().difference(lastActive).inDays;
      final currentStreak = daysSinceLastActive <= 1
          ? (userData['dailyStreak'] ?? 0) + (daysSinceLastActive == 1 ? 1 : 0)
          : 0;

      // Atualiza último acesso se necessário
      if (daysSinceLastActive >= 1) {
        await _updateDailyStreak(currentStreak);
      }

      return DashboardStats(
        totalPets: totalPets,
        adoptedPets: adoptedPets,
        availablePets: totalPets - adoptedPets,
        completedAchievements: userData['completedAchievements'] ?? 0,
        totalPlayTime: userData['totalPlayTime'] ?? 0,
        dailyStreak: currentStreak,
        lastActiveDate: DateTime.now(),
        gameScores: Map<String, int>.from(userData['gameScores'] ?? {}),
      );
    } catch (e) {
      print('Erro ao buscar stats do dashboard: $e');
      return DashboardStats.empty();
    }
  }

  /// Busca atividades recentes
  Stream<List<RecentActivity>> getRecentActivities({int limit = 10}) {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecentActivity.fromFirestore(doc))
            .toList());
  }

  /// Adiciona uma nova atividade
  Future<void> addActivity({
    required String title,
    required String description,
    required String type,
    String? petId,
    Map<String, dynamic>? metadata,
  }) async {
    if (_userId == null) return;

    final activity = RecentActivity(
      id: '',
      title: title,
      description: description,
      type: type,
      timestamp: DateTime.now(),
      petId: petId,
      metadata: metadata,
    );

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('activities')
        .add(activity.toFirestore());

    // Limita a 50 atividades mais recentes
    await _cleanOldActivities();
  }

  /// Busca dica do dia
  Future<DailyTip?> getDailyTip() async {
    try {
      // Busca dicas válidas
      final now = DateTime.now();
      final tipsQuery = await _firestore
          .collection('daily_tips')
          .where('active', isEqualTo: true)
          .orderBy('priority', descending: true)
          .get();

      final validTips = tipsQuery.docs
          .map((doc) => DailyTip.fromFirestore(doc))
          .where((tip) => tip.expiresAt == null || tip.expiresAt!.isAfter(now))
          .toList();

      if (validTips.isEmpty) return null;

      // Seleciona uma dica baseada no dia
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
      final selectedIndex = dayOfYear % validTips.length;

      return validTips[selectedIndex];
    } catch (e) {
      print('Erro ao buscar dica do dia: $e');
      return null;
    }
  }

  /// Atualiza tempo de jogo
  Future<void> updatePlayTime(int minutes) async {
    if (_userId == null) return;

    await _firestore.collection('users').doc(_userId).update({
      'totalPlayTime': FieldValue.increment(minutes),
      'lastActiveDate': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Atualiza score de um jogo
  Future<void> updateGameScore(String gameId, int score) async {
    if (_userId == null) return;

    await _firestore.collection('users').doc(_userId).update({
      'gameScores.$gameId': score,
    });
  }

  /// Marca uma conquista como completa
  Future<void> completeAchievement(String achievementId) async {
    if (_userId == null) return;

    await _firestore.collection('users').doc(_userId).update({
      'completedAchievements': FieldValue.increment(1),
      'achievements.$achievementId': true,
    });

    // Adiciona atividade
    await addActivity(
      title: 'Nova Conquista!',
      description: 'Você desbloqueou uma nova conquista',
      type: 'achievement',
      metadata: {'achievementId': achievementId},
    );
  }

  /// Cria documento inicial do usuário
  Future<void> _createUserDocument() async {
    if (_userId == null) return;

    await _firestore.collection('users').doc(_userId).set({
      'createdAt': Timestamp.now(),
      'lastActiveDate': Timestamp.now(),
      'dailyStreak': 0,
      'completedAchievements': 0,
      'totalPlayTime': 0,
      'gameScores': {},
      'achievements': {},
    });
  }

  /// Atualiza daily streak
  Future<void> _updateDailyStreak(int newStreak) async {
    if (_userId == null) return;

    await _firestore.collection('users').doc(_userId).update({
      'dailyStreak': newStreak,
      'lastActiveDate': Timestamp.now(),
    });

    // Adiciona atividade se manteve streak
    if (newStreak > 0) {
      await addActivity(
        title: 'Sequência Diária!',
        description: 'Você manteve sua sequência por $newStreak dias',
        type: 'achievement',
        metadata: {'streak': newStreak},
      );
    }
  }

  /// Limpa atividades antigas
  Future<void> _cleanOldActivities() async {
    if (_userId == null) return;

    final activities = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .get();

    if (activities.docs.length > 50) {
      final batch = _firestore.batch();

      // Deleta atividades além do limite
      for (int i = 50; i < activities.docs.length; i++) {
        batch.delete(activities.docs[i].reference);
      }

      await batch.commit();
    }
  }

  /// Busca estatísticas de pets em tempo real
  Stream<Map<String, int>> getPetStats() {
    if (_userId == null) return Stream.value({});

    return _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
      final pets = snapshot.docs;
      final adopted =
          pets.where((doc) => doc.data()['isAdopted'] == true).length;

      return {
        'total': pets.length,
        'adopted': adopted,
        'available': pets.length - adopted,
      };
    });
  }
}
