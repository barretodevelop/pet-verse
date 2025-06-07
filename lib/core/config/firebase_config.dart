// lib/core/config/firebase_config.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Configurações do Firebase para o Dashboard
class FirebaseConfig {
  /// Inicializa o Firebase e cria estrutura inicial se necessário
  static Future<void> initializeForDashboard() async {
    try {
      // Inicializa Firebase (se ainda não foi inicializado)
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Configura Firestore para offline
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      // Verifica se usuário está logado
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _ensureUserDocument(user.uid);
        await _ensureDailyTips();
      }
    } catch (e) {
      print('Erro ao inicializar Firebase para Dashboard: $e');
    }
  }

  /// Garante que o documento do usuário existe
  static Future<void> _ensureUserDocument(String userId) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'createdAt': FieldValue.serverTimestamp(),
        'lastActiveDate': FieldValue.serverTimestamp(),
        'dailyStreak': 0,
        'completedAchievements': 0,
        'totalPlayTime': 0,
        'gameScores': {},
        'achievements': {},
        'currency': {
          'coins': 1000,
          'gems': 50,
          'xp': 0,
        },
      });

      // Adiciona atividade inicial
      await userDoc.collection('activities').add({
        'title': 'Bem-vindo ao PetVerse!',
        'description': 'Sua jornada de adoção começa agora',
        'type': 'achievement',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Garante que existem dicas diárias
  static Future<void> _ensureDailyTips() async {
    final tipsCollection = FirebaseFirestore.instance.collection('daily_tips');
    final tipsSnapshot = await tipsCollection.limit(1).get();

    if (tipsSnapshot.docs.isEmpty) {
      // Adiciona dicas padrão
      final defaultTips = [
        {
          'title': 'Cuide do seu Pet',
          'content':
              'Alimente seu pet regularmente para mantê-lo feliz e saudável!',
          'category': 'pet_care',
          'active': true,
          'priority': 10,
        },
        {
          'title': 'Ganhe Mais Coins',
          'content': 'Jogue mini-games diariamente para aumentar sua fortuna!',
          'category': 'game',
          'active': true,
          'priority': 8,
        },
        {
          'title': 'Adoção Colaborativa',
          'content':
              'Crie solicitações de adoção e ajude outros usuários a encontrar seus pets!',
          'category': 'social',
          'active': true,
          'priority': 9,
        },
        {
          'title': 'Daily Streak',
          'content':
              'Entre todos os dias para manter sua sequência e ganhar recompensas extras!',
          'category': 'general',
          'active': true,
          'priority': 7,
        },
        {
          'title': 'Levels e XP',
          'content':
              'Cada ação no jogo te dá XP. Suba de nível para desbloquear novos recursos!',
          'category': 'general',
          'active': true,
          'priority': 6,
        },
      ];

      final batch = FirebaseFirestore.instance.batch();
      for (final tip in defaultTips) {
        final docRef = tipsCollection.doc();
        batch.set(docRef, tip);
      }
      await batch.commit();
    }
  }

  /// Cria dados de teste para desenvolvimento
  static Future<void> createTestData(String userId) async {
    final batch = FirebaseFirestore.instance.batch();

    // Adiciona atividades de teste
    final activitiesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('activities');

    final testActivities = [
      {
        'title': 'Pet Max foi alimentado',
        'description': 'Você alimentou Max e ele está feliz!',
        'type': 'pet_care',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(hours: 2)),
        ),
        'petId': 'pet_test_1',
      },
      {
        'title': 'Novo Score no Coin Clicker!',
        'description': 'Score de 1500 no Coin Clicker. Ganhou 150 coins!',
        'type': 'game',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(hours: 5)),
        ),
        'metadata': {
          'gameId': 'coin_clicker',
          'score': 1500,
          'coinsEarned': 150,
        },
      },
      {
        'title': 'Pet Luna foi adotado!',
        'description': 'Você adotou Luna através de adoção colaborativa',
        'type': 'adoption',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
        'petId': 'pet_test_2',
      },
      {
        'title': 'Conquista Desbloqueada!',
        'description': 'Você alcançou o nível 5!',
        'type': 'achievement',
        'timestamp': Timestamp.fromDate(
          DateTime.now().subtract(const Duration(days: 2)),
        ),
        'metadata': {
          'achievementId': 'level_5',
        },
      },
    ];

    for (final activity in testActivities) {
      final docRef = activitiesRef.doc();
      batch.set(docRef, activity);
    }

    await batch.commit();
  }
}

/// Extension para facilitar uso do Firebase no Dashboard
extension DashboardFirebaseExtensions on FirebaseFirestore {
  /// Referência rápida para coleção de usuários
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      collection('users');

  /// Referência rápida para coleção de dicas
  CollectionReference<Map<String, dynamic>> get tipsCollection =>
      collection('daily_tips');

  /// Referência rápida para documento do usuário atual
  DocumentReference<Map<String, dynamic>>? get currentUserDoc {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return userId != null ? usersCollection.doc(userId) : null;
  }
}
