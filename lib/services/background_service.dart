// lib/services/background_service.dart - Real Background Service
// ✅ NOVO: Serviço real para monitoramento em background
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class BackgroundService {
  static const String _taskName = 'petCareCheck';
  static const String _periodicTaskName = 'petCarePeriodicCheck';
  static const Duration _checkInterval = Duration(hours: 4);
  static const Duration _deathThreshold = Duration(days: 5);

  static FlutterLocalNotificationsPlugin? _notificationsPlugin;
  static bool _isInitialized = false;

  // ✅ Inicialização do serviço
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🔄 BackgroundService: Inicializando...');

      // Inicializar WorkManager
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false, // Set to false in production
      );

      // Inicializar notificações locais
      await _initializeNotifications();

      // Registrar tarefas periódicas
      await _registerPeriodicTasks();

      _isInitialized = true;
      print('✅ BackgroundService: Inicializado com sucesso');
    } catch (e) {
      print('❌ BackgroundService: Erro na inicialização: $e');
      rethrow;
    }
  }

  // ✅ Inicializar sistema de notificações
  static Future<void> _initializeNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin!.initialize(settings);
    print('✅ BackgroundService: Notificações inicializadas');
  }

  // ✅ Registrar tarefas periódicas
  static Future<void> _registerPeriodicTasks() async {
    // Cancelar tarefas existentes
    await Workmanager().cancelAll();

    // Registrar verificação periódica a cada 4 horas
    await Workmanager().registerPeriodicTask(
      _periodicTaskName,
      _taskName,
      frequency: _checkInterval,
      initialDelay: const Duration(minutes: 5), // Primeira verificação em 5 min
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );

    print(
        '✅ BackgroundService: Tarefa periódica registrada (${_checkInterval.inHours}h)');
  }

  // ✅ Verificação manual (quando app abre)
  static Future<void> performManualCheck() async {
    print('🔄 BackgroundService: Verificação manual iniciada');
    try {
      await _checkPetsStatus();
      print('✅ BackgroundService: Verificação manual completa');
    } catch (e) {
      print('❌ BackgroundService: Erro na verificação manual: $e');
    }
  }

  // ✅ Verificação de status dos pets
  static Future<void> _checkPetsStatus() async {
    try {
      // Obter usuário atual (se logado)
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('⚠️ BackgroundService: Usuário não logado, pulando verificação');
        return;
      }

      // Buscar pets do usuário
      final petsSnapshot = await FirebaseFirestore.instance
          .collection('pets')
          .where('ownerId', isEqualTo: user.uid)
          .get();

      final now = DateTime.now();
      int petsAtRisk = 0;
      int petsCritical = 0;
      List<Map<String, dynamic>> riskyPets = [];

      for (final doc in petsSnapshot.docs) {
        final petData = doc.data();
        final lastCared = DateTime.fromMillisecondsSinceEpoch(
          petData['lastCared'] ?? now.millisecondsSinceEpoch,
        );
        final timeSinceLastCare = now.difference(lastCared);

        // Verificar se pet está em risco
        if (timeSinceLastCare > Duration(days: 3)) {
          final timeUntilDeath = _deathThreshold - timeSinceLastCare;

          if (timeUntilDeath.isNegative) {
            // Pet morreu - processar morte
            await _processPetDeath(doc.id, petData);
          } else if (timeUntilDeath.inHours <= 12) {
            // Pet crítico (< 12h para morrer)
            petsCritical++;
            riskyPets.add({
              'name': petData['name'],
              'hoursLeft': timeUntilDeath.inHours,
              'emoji': petData['emoji'],
            });
          } else if (timeUntilDeath.inHours <= 24) {
            // Pet em risco (< 24h para morrer)
            petsAtRisk++;
            riskyPets.add({
              'name': petData['name'],
              'hoursLeft': timeUntilDeath.inHours,
              'emoji': petData['emoji'],
            });
          }
        }
      }

      // Enviar notificações se necessário
      if (petsCritical > 0) {
        await _sendCriticalNotification(
            riskyPets.where((p) => p['hoursLeft'] <= 12).toList());
      } else if (petsAtRisk > 0) {
        await _sendRiskNotification(riskyPets);
      }

      // Salvar timestamp da última verificação
      await _saveLastCheckTime(now);

      print(
          '✅ BackgroundService: Verificação concluída - $petsAtRisk em risco, $petsCritical críticos');
    } catch (e) {
      print('❌ BackgroundService: Erro na verificação de pets: $e');
    }
  }

  // ✅ Processar morte de pet
  static Future<void> _processPetDeath(
      String petId, Map<String, dynamic> petData) async {
    try {
      print(
          '💀 BackgroundService: Processando morte do pet ${petData['name']}');

      // Marcar pet como morto
      await FirebaseFirestore.instance.collection('pets').doc(petId).update({
        'isDead': true,
        'deathDate': FieldValue.serverTimestamp(),
        'deathReason': 'Negligência - não foi cuidado por mais de 5 dias',
      });

      // Penalizar usuário (-50 XP)
      final userId = petData['ownerId'];
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final currentXP = userData['xp'] as int? ?? 0;
        final newXP = (currentXP - 50).clamp(0, double.infinity).toInt();
        final newLevel = (newXP / 100).floor() + 1;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'xp': newXP,
          'level': newLevel,
        });

        print(
            '⚡ BackgroundService: Usuário penalizado: $currentXP → $newXP XP');
      }

      // Adicionar post no feed
      await FirebaseFirestore.instance.collection('feed').add({
        'type': 'death',
        'content':
            '😢 ${petData['name']} ${petData['emoji']} faleceu por negligência',
        'userId': userId,
        'petId': petId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Enviar notificação de morte
      await _sendDeathNotification(petData['name'], petData['emoji']);

      print('💀 BackgroundService: Morte processada para ${petData['name']}');
    } catch (e) {
      print('❌ BackgroundService: Erro ao processar morte: $e');
    }
  }

  // ✅ Enviar notificação crítica
  static Future<void> _sendCriticalNotification(
      List<Map<String, dynamic>> criticalPets) async {
    if (_notificationsPlugin == null || criticalPets.isEmpty) return;

    final pet = criticalPets.first;
    await _notificationsPlugin!.show(
      1,
      '🚨 PET EM PERIGO CRÍTICO!',
      '${pet['emoji']} ${pet['name']} morrerá em ${pet['hoursLeft']}h se não for cuidado!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'critical_pet_care',
          'Alertas Críticos',
          channelDescription: 'Alertas urgentes sobre pets em perigo',
          importance: Importance.max,
          priority: Priority.high,
          color: Colors.red,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    print('🚨 BackgroundService: Notificação crítica enviada');
  }

  // ✅ Enviar notificação de risco
  static Future<void> _sendRiskNotification(
      List<Map<String, dynamic>> riskyPets) async {
    if (_notificationsPlugin == null || riskyPets.isEmpty) return;

    final pet = riskyPets.first;
    await _notificationsPlugin!.show(
      2,
      '⚠️ Seus pets precisam de cuidado!',
      '${pet['emoji']} ${pet['name']} e outros pets precisam de atenção',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care_warning',
          'Avisos de Cuidado',
          channelDescription: 'Lembretes para cuidar dos pets',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.orange,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    print('⚠️ BackgroundService: Notificação de risco enviada');
  }

  // ✅ Enviar notificação de morte
  static Future<void> _sendDeathNotification(
      String petName, String emoji) async {
    if (_notificationsPlugin == null) return;

    await _notificationsPlugin!.show(
      3,
      '💀 Pet Faleceu',
      '$emoji $petName faleceu por falta de cuidados. Você perdeu 50 XP.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_death',
          'Morte de Pets',
          channelDescription: 'Notificações de morte de pets',
          importance: Importance.max,
          priority: Priority.high,
          color: Colors.black,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    print('💀 BackgroundService: Notificação de morte enviada');
  }

  // ✅ Salvar timestamp da última verificação
  static Future<void> _saveLastCheckTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastBackgroundCheck', time.millisecondsSinceEpoch);
  }

  // ✅ Obter timestamp da última verificação
  static Future<DateTime?> getLastCheckTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('lastBackgroundCheck');
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  // ✅ Parar serviço (logout)
  static Future<void> stop() async {
    await Workmanager().cancelAll();
    print('🛑 BackgroundService: Serviço parado');
  }

  // ✅ Status do serviço
  static bool get isInitialized => _isInitialized;
}

// ✅ Callback do WorkManager (executa em background)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('🔄 BackgroundTask: Executando tarefa $task');

    try {
      // Inicializar Firebase no isolate
      await Firebase.initializeApp();

      // Executar verificação
      switch (task) {
        case 'petCareCheck':
        case 'petCarePeriodicCheck':
          await BackgroundService._checkPetsStatus();
          break;
        default:
          print('⚠️ BackgroundTask: Tarefa desconhecida: $task');
      }

      print('✅ BackgroundTask: Tarefa $task concluída');
      return Future.value(true);
    } catch (e) {
      print('❌ BackgroundTask: Erro na tarefa $task: $e');
      return Future.value(false);
    }
  });
}
