// lib/services/notification_service.dart - ENHANCED VERSION
// ✅ MELHORADO: Integração com FCM + Background Service
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

final notificationServiceProvider = Provider((ref) => NotificationService());

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static bool _initialized = false;

  // ✅ Inicialização completa
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      print('🔄 NotificationService: Inicializando...');

      // 1. Inicializar notificações locais
      await _initializeLocalNotifications();

      // 2. Configurar FCM
      await _configureFCM();

      // 3. Solicitar permissões
      await _requestPermissions();

      // 4. Configurar handlers
      await _setupMessageHandlers();

      _initialized = true;
      print('✅ NotificationService: Inicializado com sucesso');
    } catch (e) {
      print('❌ NotificationService: Erro na inicialização: $e');
    }
  }

  // ✅ Configurar notificações locais
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
      // ✅ Removido: onDidReceiveLocalNotification
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    print('✅ NotificationService: Notificações locais configuradas');
  }

  // ✅ Configurar FCM
  static Future<void> _configureFCM() async {
    // Configurar settings do FCM
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Obter token FCM
    final token = await _fcm.getToken();
    if (token != null) {
      print('✅ FCM Token: ${token.substring(0, 20)}...');
      await _saveFCMToken(token);
    }

    // Listener para mudanças no token
    _fcm.onTokenRefresh.listen(_saveFCMToken);

    print('✅ NotificationService: FCM configurado');
  }

  // ✅ Solicitar permissões
  static Future<void> _requestPermissions() async {
    // Permissões FCM
    final fcmSettings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('✅ FCM Permission: ${fcmSettings.authorizationStatus}');

    // Permissões de notificação (Android 13+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    print('✅ NotificationService: Permissões solicitadas');
  }

  // ✅ Configurar handlers de mensagens
  static Future<void> _setupMessageHandlers() async {
    // Handler para mensagens em foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handler para mensagens que abrem o app
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handler para mensagem que iniciou o app (terminated state)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    print('✅ NotificationService: Handlers configurados');
  }

  // ✅ Handler para mensagens em foreground
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📨 Mensagem FCM recebida (foreground): ${message.messageId}');

    // Mostrar notificação local para mensagens em foreground
    await _showLocalNotificationFromFCM(message);
  }

  // ✅ Handler para mensagens que abrem o app
  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    print('📨 App aberto via notificação: ${message.messageId}');

    // Processar ação baseada no tipo da mensagem
    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'pet_critical':
        // Navegar para tela do pet crítico
        await _handlePetCriticalAction(data);
        break;
      case 'pet_death':
        // Navegar para tela de pets mortos
        await _handlePetDeathAction(data);
        break;
      case 'match_found':
        // Navegar para adoção colaborativa
        await _handleMatchFoundAction(data);
        break;
      default:
        print('⚠️ Tipo de notificação desconhecido: $type');
    }
  }

  // ✅ Mostrar notificação local a partir de FCM
  static Future<void> _showLocalNotificationFromFCM(
      RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      final androidDetails = AndroidNotificationDetails(
        data['channel_id'] ?? 'default',
        data['channel_name'] ?? 'Notificações PetCare',
        channelDescription:
            data['channel_description'] ?? 'Notificações do app PetCare',
        importance: _getImportanceFromData(data),
        priority: Priority.high,
        color: _getColorFromType(data['type']),
        playSound: true,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      await _localNotifications.show(
        message.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: jsonEncode(data),
      );
    }
  }

  // ✅ Callbacks de notificações locais
  static Future<void> _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    print('📱 Notificação local recebida (iOS): $title');
  }

  static Future<void> _onNotificationTapped(
      NotificationResponse response) async {
    print('👆 Notificação tocada: ${response.payload}');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        await _handleNotificationAction(data);
      } catch (e) {
        print('❌ Erro ao processar payload da notificação: $e');
      }
    }
  }

  // ✅ Processar ações de notificações
  static Future<void> _handleNotificationAction(
      Map<String, dynamic> data) async {
    final type = data['type'];

    switch (type) {
      case 'pet_critical':
        await _handlePetCriticalAction(data);
        break;
      case 'pet_death':
        await _handlePetDeathAction(data);
        break;
      case 'match_found':
        await _handleMatchFoundAction(data);
        break;
    }
  }

  static Future<void> _handlePetCriticalAction(
      Map<String, dynamic> data) async {
    print('🚨 Ação: Pet crítico - ${data['pet_name']}');
    // TODO: Navegar para tela do pet específico
  }

  static Future<void> _handlePetDeathAction(Map<String, dynamic> data) async {
    print('💀 Ação: Pet morreu - ${data['pet_name']}');
    // TODO: Navegar para tela de pets mortos
  }

  static Future<void> _handleMatchFoundAction(Map<String, dynamic> data) async {
    print('🤝 Ação: Match encontrado - ${data['pet_type']}');
    // TODO: Navegar para tela de adoção colaborativa
  }

  // ✅ API pública para notificações manuais
  static Future<void> showPetCareReminder(String petName,
      {String? emoji}) async {
    await _localNotifications.show(
      1,
      'Seu pet precisa de cuidado! 🐾',
      '${emoji ?? '🐾'} $petName está precisando de atenção',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pet_care',
          'Pet Care Reminders',
          channelDescription: 'Lembretes para cuidar dos seus pets',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.blue,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> showLevelUpNotification(String petName, int level,
      {String? emoji}) async {
    await _localNotifications.show(
      2,
      'Parabéns! 🎉',
      '${emoji ?? '🐾'} $petName subiu para o nível $level!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'level_up',
          'Level Up Notifications',
          channelDescription: 'Notificações de subida de nível',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.green,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> showMatchFoundNotification(String petName,
      {String? emoji}) async {
    await _localNotifications.show(
      3,
      'Match encontrado! 🤝',
      'Alguém quer colaborar com você no cuidado de ${emoji ?? '🐾'} $petName',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'collaboration',
          'Collaboration Notifications',
          channelDescription: 'Notificações de colaboração',
          importance: Importance.high,
          priority: Priority.high,
          color: Colors.purple,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> showCriticalPetAlert(String petName, int hoursLeft,
      {String? emoji}) async {
    await _localNotifications.show(
      999, // ID alto para prioridade
      '🚨 PET EM PERIGO CRÍTICO!',
      '${emoji ?? '💀'} $petName morrerá em ${hoursLeft}h se não for cuidado!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'critical_alert',
          'Alertas Críticos',
          channelDescription: 'Alertas urgentes sobre pets em perigo',
          importance: Importance.max,
          priority: Priority.max,
          color: Colors.red,
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
    );
  }

  // ✅ Helpers
  static Importance _getImportanceFromData(Map<String, dynamic> data) {
    final type = data['type'];
    switch (type) {
      case 'pet_critical':
        return Importance.max;
      case 'pet_death':
        return Importance.high;
      case 'match_found':
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }

  static Color? _getColorFromType(String? type) {
    switch (type) {
      case 'pet_critical':
        return Colors.red;
      case 'pet_death':
        return Colors.black;
      case 'match_found':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  static Future<void> _saveFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
    print('✅ FCM Token salvo');

    // TODO: Enviar token para o servidor
    // await _sendTokenToServer(token);
  }

  // ✅ Status e getters
  static bool get isInitialized => _initialized;

  static Future<String?> getFCMToken() async {
    return await _fcm.getToken();
  }

  static Future<String?> getStoredFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }
}

// ✅ Handler para mensagens FCM em background (top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 Mensagem FCM em background: ${message.messageId}');

  // Processar mensagem em background se necessário
  final data = message.data;
  final type = data['type'];

  switch (type) {
    case 'pet_critical':
      // Executar verificação imediata de pets
      print('🚨 Executando verificação crítica de pets');
      break;
    case 'force_check':
      // Forçar verificação manual
      print('🔄 Forçando verificação manual de pets');
      break;
  }
}
