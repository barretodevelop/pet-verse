// lib/core/services/notification_service.dart
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Se você for agendar notificações em horários específicos (como 9h e 20h)
// precisará do pacote timezone. Adicione ao seu pubspec.yaml:
// dependencies:
//   timezone: ^0.9.3 // Use a versão mais recente
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest_all.dart' as tz; // Inicialize os dados de fuso horário

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Para usar o timezone, você precisaria inicializar seus dados:
    // tz.initializeAll();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: (id, title, body, payload) async {
      //   // Método obsoleto na v19.x, mas ainda pode ser usado se necessário
      //   // para lidar com notificações recebidas em primeiro plano no iOS < 10
      // },
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      // linux: LinuxInitializationSettings(), // Se você tiver suporte a Linux
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      // onDidReceiveBackgroundNotificationResponse: _onNotificationTap, // Para lidar em background (requer setup diferente)
    );

    // Solicitar permissões no iOS
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    // TODO: Navegar para a tela apropriada baseado no payload
    // Exemplo:
    // if (response.payload != null) {
    //   print('Payload da notificação: ${response.payload}');
    //   // Navigator.push(context, MaterialPageRoute(builder: (context) => SomePage(payload: response.payload)));
    // }
  }

  // Notificação quando pet está com fome
  Future<void> showHungryPetNotification(String petName) async {
    const androidDetails = AndroidNotificationDetails(
      'pet_care', // ID do canal
      'Cuidados do Pet', // Nome do canal
      channelDescription: 'Notificações sobre o estado do seu pet',
      importance: Importance.high, // Usar .high ou .max
      priority: Priority.high,
      playSound: true,
      // Adicione som personalizado se tiver
      // sound: RawResourceAndroidNotificationSound('nome_do_som'),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // sound: 'nome_do_som.aiff', // Nome do arquivo de som no Bundle
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1, // ID único da notificação
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
      importance: Importance
          .defaultImportance, // CORRIGIDO: Use Importance.high ou .low
      priority:
          Priority.defaultPriority, // CORRIGIDO: Use Priority.high ou .low
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
      importance: Importance
          .defaultImportance, // CORRIGIDO: Use Importance.high ou .low
      priority:
          Priority.defaultPriority, // CORRIGIDO: Use Priority.high ou .low
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
      importance: Importance
          .defaultImportance, // CORRIGIDO: Use Importance.high ou .low
      priority:
          Priority.defaultPriority, // CORRIGIDO: Use Priority.high ou .low
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Agendar para 9h e 20h todos os dias
    // A versão 19.x do periodicallyShow aceita 'NotificationDetails' diretamente.
    await _notifications.periodicallyShow(
      4, // ID da notificação
      'Hora de cuidar do pet! 🐾',
      'Seu pet está esperando por você',
      RepeatInterval.daily,
      details, // <--- Aqui passamos o objeto 'details' completo
      androidScheduleMode: AndroidScheduleMode
          .exactAllowWhileIdle, // Boa prática para agendamentos exatos
      payload: 'daily_reminder',
    );

    // --- Se você quiser AGENDAR PARA HORÁRIOS ESPECÍFICOS do dia (ex: 9h e 20h) ---
    // Você precisa do pacote 'timezone' e usar 'zonedSchedule'.
    // Exemplo para agendar às 9h AM (descomente e ajuste se precisar):
    /*
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9, 0, 0);

    // Se o horário de agendamento já passou hoje, agende para amanhã
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      5, // ID único para esta notificação
      'Lembrete Matinal do Pet ☀️',
      'Não se esqueça de cuidar do seu pet pela manhã!',
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repetir no mesmo horário todos os dias
      payload: 'daily_morning_reminder',
    );

    // Exemplo para agendar às 20h PM:
    tz.TZDateTime eveningScheduledTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, 20, 0, 0);
    if (eveningScheduledTime.isBefore(now)) {
      eveningScheduledTime = eveningScheduledTime.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      6, // Outro ID único
      'Lembrete Noturno do Pet 🌙',
      'Seu pet precisa de atenção antes de dormir!',
      eveningScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_evening_reminder',
    );
    */
  }

  // Cancelar todas as notificações
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
