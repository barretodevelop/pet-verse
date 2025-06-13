// lib/main.dart - BACKGROUND SERVICE INTEGRATION
// ✅ INTEGRAÇÃO COMPLETA: Background Service + FCM
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/config/app_router.dart';
import 'package:petverse/config/app_theme.dart';
import 'package:petverse/providers/theme_provider.dart';
import 'package:petverse/services/background_service.dart'; // ✅ NOVO
import 'package:petverse/services/notification_service.dart'; // ✅ ATUALIZADO

// ✅ NOVO: Handler para mensagens FCM em background (deve ser top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inicializar Firebase no isolate de background
  await Firebase.initializeApp();

  print('📨 FCM Background Message: ${message.messageId}');
  print('📨 Data: ${message.data}');
  print('📨 Notification: ${message.notification?.title}');

  // Processar mensagem baseada no tipo
  final data = message.data;
  final type = data['type'];

  switch (type) {
    case 'pet_critical':
      print('🚨 Background: Pet crítico detectado');
      // Executar verificação imediata se necessário
      break;
    case 'force_check':
      print('🔄 Background: Forçando verificação de pets');
      // Trigger verificação manual
      break;
    case 'pet_death':
      print('💀 Background: Notificação de morte de pet');
      break;
    default:
      print('📨 Background: Tipo de mensagem: $type');
  }
}

void main() async {
  // ✅ INICIALIZAÇÃO CRÍTICA
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🚀 PetCare: Inicializando aplicação...');

    // ✅ 1. Inicializar Firebase
    await Firebase.initializeApp();
    print('✅ Firebase inicializado');

    // ✅ 2. Configurar handler FCM em background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    print('✅ FCM background handler configurado');

    // ✅ 3. Inicializar NotificationService
    await NotificationService.initialize();
    print('✅ NotificationService inicializado');

    // ✅ 4. Inicializar BackgroundService
    await BackgroundService.initialize();
    print('✅ BackgroundService inicializado');

    print('🎉 PetCare: Inicialização completa!');
  } catch (e) {
    print('❌ Erro na inicialização: $e');
    // App pode continuar mesmo com erro nos background services
  }

  // ✅ Executar app
  runApp(const ProviderScope(child: PetCareApp()));
}

class PetCareApp extends ConsumerStatefulWidget {
  const PetCareApp({super.key});

  @override
  ConsumerState<PetCareApp> createState() => _PetCareAppState();
}

class _PetCareAppState extends ConsumerState<PetCareApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    // ✅ Observer para lifecycle do app
    WidgetsBinding.instance.addObserver(this);

    // ✅ Setup inicial pós-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAppLifecycle();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ NOVO: Configuração do lifecycle do app
  Future<void> _setupAppLifecycle() async {
    try {
      print('🔄 PetCare: Configurando lifecycle...');

      // Verificação inicial ao abrir app
      if (BackgroundService.isInitialized) {
        await BackgroundService.performManualCheck();
        print('✅ Verificação inicial de pets executada');
      }

      // Handler para quando app volta do background
      _setupForegroundMessageHandler();
    } catch (e) {
      print('❌ Erro no setup do lifecycle: $e');
    }
  }

  // ✅ NOVO: Handler para mensagens FCM quando app está em foreground
  void _setupForegroundMessageHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 FCM Foreground Message: ${message.notification?.title}');

      // Mostrar notificação local para mensagens em foreground
      _handleForegroundMessage(message);
    });

    // Handler para quando notificação é tocada (app aberto via notificação)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📨 App aberto via notificação: ${message.data}');
      _handleNotificationTap(message);
    });

    // Verificar se app foi aberto por notificação (terminated state)
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print('📨 App iniciado via notificação: ${message.data}');
        _handleNotificationTap(message);
      }
    });
  }

  // ✅ Handler para mensagens em foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'pet_critical':
        // Mostrar notificação crítica
        await NotificationService.showCriticalPetAlert(
          data['pet_name'] ?? 'Pet',
          int.tryParse(data['hours_left'] ?? '0') ?? 0,
          emoji: data['pet_emoji'],
        );
        break;
      case 'pet_death':
        // Mostrar notificação de morte
        await _showPetDeathNotification(data);
        break;
      case 'match_found':
        // Mostrar notificação de match
        await NotificationService.showMatchFoundNotification(
          data['pet_name'] ?? 'Pet',
          emoji: data['pet_emoji'],
        );
        break;
      default:
        // Usar dados da notificação FCM diretamente
        if (message.notification != null) {
          await _showGenericNotification(message.notification!);
        }
    }
  }

  Future<void> _showPetDeathNotification(Map<String, dynamic> data) async {
    // Implementar notificação específica de morte
    print('💀 Mostrando notificação de morte: ${data['pet_name']}');
  }

  Future<void> _showGenericNotification(RemoteNotification notification) async {
    await NotificationService.showPetCareReminder(
      notification.body ?? 'Mensagem do PetCare',
    );
  }

  // ✅ Handler para toque em notificações
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    final data = message.data;
    final type = data['type'];

    // TODO: Implementar navegação baseada no tipo da notificação
    switch (type) {
      case 'pet_critical':
        // Navegar para pet específico
        print('🎯 Navegando para pet crítico: ${data['pet_id']}');
        break;
      case 'pet_death':
        // Navegar para tela de pets mortos
        print('🎯 Navegando para pets mortos');
        break;
      case 'match_found':
        // Navegar para adoção colaborativa
        print('🎯 Navegando para match encontrado');
        break;
    }
  }

  // ✅ Lifecycle do app (quando sai/volta do background)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        print('📱 App: voltou para foreground');
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        print('📱 App: foi para background');
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        print('📱 App: foi terminado');
        _onAppTerminated();
        break;
      case AppLifecycleState.hidden:
        print('📱 App: foi minimizado');
        break;
      case AppLifecycleState.inactive:
        print('📱 App: ficou inativo');
        break;
    }
  }

  // ✅ NOVO: Quando app volta do background
  Future<void> _onAppResumed() async {
    try {
      // Verificar pets quando usuário volta ao app
      if (BackgroundService.isInitialized) {
        print('🔄 App resumed: executando verificação de pets');
        await BackgroundService.performManualCheck();
      }

      // Limpar badge de notificações (iOS)
      await _clearNotificationBadge();
    } catch (e) {
      print('❌ Erro ao processar app resumed: $e');
    }
  }

  // ✅ Quando app vai para background
  Future<void> _onAppPaused() async {
    try {
      print('📱 App pausado: background service assumirá');
      // Background service já está configurado para continuar funcionando
    } catch (e) {
      print('❌ Erro ao processar app paused: $e');
    }
  }

  // ✅ Quando app é terminado
  Future<void> _onAppTerminated() async {
    try {
      print('📱 App terminado: background service continuará');
      // WorkManager continuará executando mesmo com app fechado
    } catch (e) {
      print('❌ Erro ao processar app terminated: $e');
    }
  }

  // ✅ Limpar badge de notificações
  Future<void> _clearNotificationBadge() async {
    try {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: false, // Remove badge
        sound: true,
      );
    } catch (e) {
      print('❌ Erro ao limpar badge: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'PetCare',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,

      // ✅ NOVO: Builder para debug de background service
      builder: (context, child) {
        return Stack(
          children: [
            child!,

            // ✅ Debug info no canto superior (apenas em debug mode)
            if (kDebugMode) _buildDebugInfo(),
          ],
        );
      },
    );
  }

  // ✅ NOVO: Debug info para desenvolvimento
  Widget _buildDebugInfo() {
    return Positioned(
      top: 50,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Background: ${BackgroundService.isInitialized ? '✅' : '❌'}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Notifications: ${NotificationService.isInitialized ? '✅' : '❌'}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ NOVO: Debug mode flag
const bool kDebugMode = true; // Set to false in production
