// lib/core/services/notification_service.dart
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Solicitar permissões no iOS
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions();
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    // TODO: Navegar para a tela apropriada baseado no payload
  }

  // Notificação quando pet está com fome
  Future<void> showHungryPetNotification(String petName) async {
    const androidDetails = AndroidNotificationDetails(
      'pet_care',
      'Cuidados do Pet',
      channelDescription: 'Notificações sobre o estado do seu pet',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      '$petName está com fome! 🍖',
      'Seu pet precisa de comida. Venha alimentá-lo!',
      details,
      payload: 'pet_hungry',
    );
  }

  // Notificação quando co-parent cuidou do pet
  Future<void> showCoParentCareNotification(
      String coParentName, String action) async {
    const androidDetails = AndroidNotificationDetails(
      'co_parent',
      'Atividades do Co-Parent',
      channelDescription: 'Notificações sobre ações do seu co-parent',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2,
      'Pet foi cuidado! 💕',
      '$coParentName $action',
      details,
      payload: 'co_parent_action',
    );
  }

  // Notificação de missão completada
  Future<void> showMissionCompleteNotification(String missionTitle) async {
    const androidDetails = AndroidNotificationDetails(
      'missions',
      'Missões',
      channelDescription: 'Notificações sobre missões',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      3,
      'Missão Completa! 🎉',
      'Você completou: $missionTitle. Colete sua recompensa!',
      details,
      payload: 'mission_complete',
    );
  }

  // Agendar notificação diária
  Future<void> scheduleDailyReminder() async {
    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Lembretes Diários',
      channelDescription: 'Lembretes para cuidar do seu pet',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Agendar para 9h e 20h todos os dias
    await _notifications.periodicallyShow(
      4,
      'Hora de cuidar do pet! 🐾',
      'Seu pet está esperando por você',
      RepeatInterval.daily,
      details,
      payload: 'daily_reminder',
    );
  }

  // Cancelar todas as notificações
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
