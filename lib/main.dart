// Entry point da aplicação
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/presentation/providers/theme_provider.dart';
import 'package:petverse/presentation/screens/home_screen.dart';
import 'package:petverse/presentation/screens/login_screen.dart';
import 'package:petverse/presentation/screens/splash_screen.dart';

/// Enum para controlar o estado da aplicação
enum AppState {
  loading,
  login,
  home,
}

/// Função principal da aplicação
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurações do sistema
  await _configureSystemSettings();

  // Inicializa a aplicação com Riverpod
  runApp(
    const ProviderScope(
      child: PetAdoteApp(),
    ),
  );
}

/// Configurações do sistema
Future<void> _configureSystemSettings() async {
  // Configuração da orientação (apenas portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configuração da barra de status
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

/// Widget raiz da aplicação
class PetAdoteApp extends ConsumerStatefulWidget {
  const PetAdoteApp({super.key});

  @override
  ConsumerState<PetAdoteApp> createState() => _PetAdoteAppState();
}

class _PetAdoteAppState extends ConsumerState<PetAdoteApp>
    with WidgetsBindingObserver {
  AppState _appState = AppState.loading;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      default:
        break;
    }
  }

  /// Inicializa a aplicação
  Future<void> _initializeApp() async {
    try {
      // Simula carregamento inicial
      await Future.delayed(const Duration(seconds: 3));

      // Verifica se o usuário já está logado (simplificado)
      final isLoggedIn = await _checkUserLoginStatus();

      setState(() {
        _appState = isLoggedIn ? AppState.home : AppState.login;
      });
    } catch (error) {
      // Em caso de erro, vai para o login
      setState(() {
        _appState = AppState.login;
      });

      // Log do erro em produção
      debugPrint('Erro na inicialização: $error');
    }
  }

  /// Verifica status de login do usuário
  Future<bool> _checkUserLoginStatus() async {
    // Em uma aplicação real, verificaria tokens, shared preferences, etc.
    // Por enquanto, sempre retorna true para demonstração
    return true;
  }

  /// Manipula sucesso no login
  void _handleLoginSuccess() {
    setState(() {
      _appState = AppState.home;
    });
  }

  /// Manipula erro no login
  void _handleLoginError(String error) {
    _showErrorSnackBar('Erro no login: $error');
  }

  /// Manipula quando o app volta do background
  void _handleAppResumed() {
    // Atualiza dados se necessário
    // Verifica notificações pendentes
    debugPrint('App resumido');
  }

  /// Manipula quando o app vai para o background
  void _handleAppPaused() {
    // Salva estado se necessário
    debugPrint('App pausado');
  }

  /// Manipula quando o app é finalizado
  void _handleAppDetached() {
    // Cleanup final
    debugPrint('App finalizado');
  }

  /// Mostra snackbar de erro
  void _showErrorSnackBar(String message) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Observa o tema atual
    final themeMode = ref.watch(themeModeProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);

    return MaterialApp(
      // Configurações básicas
      title: 'Pet Adote',
      debugShowCheckedModeBanner: false,

      // Temas
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,

      // Configurações de localização
      locale: const Locale('pt', 'BR'),

      // Roteamento baseado no estado
      home: _buildCurrentScreen(),

      // Builder para configurações globais
      builder: (context, child) {
        return _AppWrapper(child: child);
      },
    );
  }

  /// Constrói a tela atual baseada no estado
  Widget _buildCurrentScreen() {
    switch (_appState) {
      case AppState.loading:
        return SplashScreen(
          onComplete: () {
            // O onComplete é chamado quando a splash termina
            // mas o estado já é gerenciado pelo _initializeApp
          },
        );

      case AppState.login:
        return LoginScreen(
          onLoginSuccess: _handleLoginSuccess,
          onLoginError: _handleLoginError,
          enabledMethods: const [
            LoginType.google,
            LoginType.apple,
          ],
          showSkipOption: true,
        );

      case AppState.home:
        return const HomeScreen();
    }
  }
}

/// Wrapper global para configurações que afetam toda a aplicação
class _AppWrapper extends ConsumerWidget {
  final Widget? child;

  const _AppWrapper({this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MediaQuery(
      // Remove padding desnecessário em alguns dispositivos
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}

/// Classe para configurações globais da aplicação
class AppConfig {
  // URLs da API (quando implementar backend)
  static const String baseUrl = 'https://api.petadote.com';
  static const String apiVersion = 'v1';

  // Configurações de tempo
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Configurações de cache
  static const int maxCacheSize = 100; // MB
  static const Duration cacheTimeout = Duration(hours: 24);

  // Configurações de pet
  static const int maxPetsInRequest = 3;
  static const int adoptionRequestDuration = 5; // dias

  // Configurações de moeda
  static const int initialCoins = 1000;
  static const int initialGems = 50;
  static const int initialXP = 0;

  // Configurações de custos
  static const int petGenerationCost = 20; // gems
  static const int feedPetCost = 10; // coins
  static const int playPetCost = 5; // coins
  static const int restPetCost = 8; // coins

  // Configurações de recompensas
  static const int adoptionReward = 100; // coins
  static const int playXPReward = 10; // xp
  static const int dailyRewardCoins = 100;
  static const int dailyRewardGems = 5;
  static const int dailyRewardXP = 50;

  // Configurações de interface
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);

  // Configurações de animação
  static const Curve defaultCurve = Curves.easeInOut;
  static const Duration defaultTransition = Duration(milliseconds: 200);

  // Configurações de debug
  static const bool enableDebugLogging = true;
  static const bool enablePerformanceOverlay = false;
}

/// Utilitários globais da aplicação
class AppUtils {
  /// Formata números para exibição amigável
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// Retorna saudação baseada no horário
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  /// Calcula a cor da borda baseada no nível
  static Color getBorderColorByLevel(int level) {
    if (level >= 10) return const Color(0xFFFFD700); // Dourado
    if (level >= 5) return const Color(0xFFC0C0C0); // Prata
    return const Color(0xFFCD7F32); // Bronze
  }

  /// Verifica se uma string é um email válido
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Gera ID único
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Log de debug (apenas em desenvolvimento)
  static void debugLog(String message) {
    if (AppConfig.enableDebugLogging) {
      debugPrint('[PetAdote] $message');
    }
  }
}

/// Extensões úteis para o contexto
extension AppContextExtensions on BuildContext {
  /// Retorna o tema atual
  ThemeData get theme => Theme.of(this);

  /// Retorna as cores do tema atual
  ColorScheme get colors => theme.colorScheme;

  /// Retorna se o tema atual é claro
  bool get isLightTheme => theme.brightness == Brightness.light;

  /// Retorna o tamanho da tela
  Size get screenSize => MediaQuery.of(this).size;

  /// Retorna a largura da tela
  double get screenWidth => screenSize.width;

  /// Retorna a altura da tela
  double get screenHeight => screenSize.height;

  /// Mostra snackbar de sucesso
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Mostra snackbar de erro
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Mostra snackbar de informação
  void showInfoSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Constantes de cores customizadas
class AppColors {
  // Cores primárias
  static const Color primaryPurple = Color(0xFF8A05BE);
  static const Color primaryIndigo = Color(0xFF4B0082);

  // Cores secundárias
  static const Color amber = Color(0xFFFFD700);
  static const Color cyan = Color(0xFF40E0D0);
  static const Color lime = Color(0xFF32CD32);

  // Cores de status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Cores de nível
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
}

/// Constantes de texto
class AppStrings {
  // Títulos principais
  static const String appName = 'Pet Adote';
  static const String appSlogan = 'Encontre seu companheiro perfeito';

  // Mensagens de erro comuns
  static const String errorGeneric = 'Algo deu errado. Tente novamente.';
  static const String errorNetwork = 'Erro de conexão. Verifique sua internet.';
  static const String errorLogin =
      'Falha no login. Verifique suas credenciais.';

  // Mensagens de sucesso
  static const String successLogin = 'Login realizado com sucesso!';
  static const String successAdoption = 'Parabéns! Pet adotado com sucesso!';
  static const String successPetGenerated = 'Pet único gerado com sucesso!';

  // Labels de navegação
  static const String navDashboard = 'Dashboard';
  static const String navStore = 'Loja';
  static const String navPet = 'Pet';
  static const String navGames = 'Games';
  static const String navFeed = 'Feed';

  // Actions
  static const String actionCancel = 'Cancelar';
  static const String actionConfirm = 'Confirmar';
  static const String actionClose = 'Fechar';
  static const String actionSave = 'Salvar';
  static const String actionDelete = 'Excluir';
  static const String actionEdit = 'Editar';
}
