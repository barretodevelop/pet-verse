import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importa os arquivos do seu core e dos modelos
import 'core/app_notifier.dart';
import 'models/user.dart'; // Para o mock inicial de login
// Importa os componentes UI e as telas
import 'ui/components/notification_bar.dart';
import 'ui/screens/home_screen.dart'; // Importa a HomeScreen
import 'ui/screens/login_screen.dart';
import 'ui/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o Flutter esteja inicializado
  final prefs = await SharedPreferences.getInstance(); // Inicializa SharedPreferences

  runApp(
    ProviderScope(
      // Sobrescreve o provedor de SharedPreferences com a instância real
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

// Floating Particles Component (Global)
class FloatingParticles extends ConsumerWidget {
  const FloatingParticles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final particles = ref.watch(appServiceProvider.select((state) => state.particles));

    return Stack(
      children: particles.map((p) {
        return Positioned(
          left: p.x,
          top: p.y,
          child: Opacity(
            opacity: p.opacity,
            child: Transform.scale(
              scale: p.scale,
              child: Text(
                p.type == 'heart'
                    ? '💖'
                    : p.type == 'star'
                        ? '⭐'
                        : p.type == 'coins'
                            ? '💰'
                            : '✨',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class MyApp extends ConsumerWidget {
  // Usamos ConsumerWidget para acessar providers
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Exemplo de como você pode assistir o AppState para determinar a tela inicial
    final appState = ref.watch(appServiceProvider);
    final appService = ref.read(appServiceProvider.notifier);

    // Usa um ConsumerStatefulWidget para gerenciar o estado da splash screen
    return MaterialApp(
      title: 'PetCare App',
      theme: ThemeData(
        fontFamily: 'Inter',
        primarySwatch: Colors.purple,
        useMaterial3: true,
        brightness: appState.isDark ? Brightness.dark : Brightness.light, // Controla o tema
      ),
      // A tela inicial será decidida pela _AppStartupScreen
      home: _AppStartupScreen(
        onLoginSuccess: (user) {
          // Quando o login é bem-sucedido, o AppNotifier é atualizado
          // e o Riverpod irá redesenhar a UI para a HomeScreen
          appService.setUser(user);
        },
      ),
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child, // O conteúdo da tela
            const NotificationBar(), // A barra de notificações flutuante
            const FloatingParticles(), // As partículas flutuantes globais
          ],
        );
      },
    );
  }
}

// Widget auxiliar para gerenciar a exibição da Splash Screen e navegação inicial
class _AppStartupScreen extends ConsumerStatefulWidget {
  final Function(User) onLoginSuccess; // Callback para quando o login for bem-sucedido

  const _AppStartupScreen({required this.onLoginSuccess});

  @override
  ConsumerState<_AppStartupScreen> createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends ConsumerState<_AppStartupScreen> {
  bool _showSplash = true; // Controla se a splash screen está visível

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // Simula o carregamento inicial e a transição da splash screen
  Future<void> _initializeApp() async {
    // Aqui você pode adicionar lógica para carregar dados iniciais,
    // verificar autenticação persistida, etc.
    await Future.delayed(const Duration(seconds: 2)); // Tempo da splash screen

    if (mounted) {
      setState(() {
        _showSplash = false; // Esconde a splash screen
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appServiceProvider);

    // Decide qual tela mostrar após a splash screen
    Widget screenAfterSplash;
    if (appState.user == null) {
      screenAfterSplash = LoginScreen(
        onLogin: widget.onLoginSuccess, // Passa o callback de login para a tela de Login
      );
    } else {
      // Quando o usuário estiver logado, esta será a tela principal (Home Screen)
      screenAfterSplash = const HomeScreen();
    }

    return Stack(
      children: [
        screenAfterSplash, // A tela principal (login ou home)
        if (_showSplash)
          SplashScreen(
            onFinish: () {
              // A splash screen agora gerencia sua própria conclusão via setState
              // e a tela subjacente já está definida, então apenas esconde a splash
              if (mounted) {
                setState(() {
                  _showSplash = false;
                });
              }
            },
          ),
      ],
    );
  }
}
