// screens/main_screen.dart
import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:petverse/core/config/app_config.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/firebase_options.dart';
import 'package:petverse/presentation/providers/dependencies_provider.dart';
import 'package:petverse/presentation/providers/feedback_notification_provider.dart';
import 'package:petverse/presentation/providers/theme_provider.dart';
import 'package:petverse/presentation/screens/auth/app_wrapper.dart';
import 'package:petverse/presentation/screens/home/custom_app_bar.dart';
import 'package:petverse/presentation/screens/home/custom_bottom_nav.dart' hide ThemeConfig;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await _initializeFirebase();

  // ✅ DEBUG FIREBASE
  await Firebase.initializeApp();
  print('🔥 Firebase initialized: ${Firebase.apps.length} apps');

  // ✅ DEBUG AUTH
  final auth = FirebaseAuth.instance;
  print('🔐 Auth instance: ${auth.app.name}');

  // Initialize dependencies
  final providerOverrides = await _initializeDependencies();

  // Configure system UI
  await _configureSystemUI();

  // Run the application
  runApp(
    ProviderScope(
      overrides: providerOverrides,
      observers: [
        if (kDebugMode) AppProviderObserver(),
      ],
      child: const MyApp(),
    ),
  );
}

/// Initialize Firebase with error handling
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // await AppCheckService.initialize();

    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('❌ Firebase initialization failed: $e');
    // In a production app, you might want to show an error screen
    // or use offline mode if Firebase fails to initialize
  }
}

/// Initialize async dependencies like SharedPreferences
Future<List<Override>> _initializeDependencies() async {
  try {
    final sharedPreferences = await SharedPreferences.getInstance();
    debugPrint('✅ SharedPreferences initialized successfully');

    return [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ];
  } catch (e) {
    debugPrint('❌ Failed to initialize dependencies: $e');
    return [];
  }
}

/// Configure system UI overlay style
Future<void> _configureSystemUI() async {
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  debugPrint('✅ System UI configured successfully');
}

/// Root application widget
class PetGameApp extends ConsumerWidget {
  const PetGameApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme state to rebuild when theme changes
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      // App configuration
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: themeState.themeMode,

      // Route configuration
      home: const AppWrapper(),

      // App-wide configuration
      builder: (context, child) {
        return MediaQuery(
          // Ensure text scaling doesn't break the UI
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 0.8,
                  maxScaleFactor: 1.2,
                ),
          ),
          child: _AppErrorBoundary(child: child),
        );
      },

      // Localization (if needed in the future)
      // supportedLocales: const [
      //   Locale('en', 'US'),
      //   Locale('pt', 'BR'),
      // ],
    );
  }
}

/// Error boundary widget to catch and handle app-wide errors
class _AppErrorBoundary extends StatelessWidget {
  final Widget? child;

  const _AppErrorBoundary({this.child});

  @override
  Widget build(BuildContext context) {
    return child ?? const _AppErrorScreen();
  }
}

/// Error screen shown when the app fails to initialize
class _AppErrorScreen extends StatelessWidget {
  const _AppErrorScreen();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: ThemeConfig.primaryGradient,
          ),
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Please restart the app to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 2; // Start with Pet screen
  late AnimationController _screenTransitionController;
  late AnimationController _feedbackController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<Widget> _screens = [
    DashboardScreen(),
    ShopScreen(),
    PetScreen(),
    RankingScreen(),
    FeedScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupFeedbackSystem();
    ref.read(gameServiceProvider);
  }

  void _initAnimations() {
    _screenTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _screenTransitionController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _screenTransitionController,
      curve: Curves.easeOutBack,
    ));

    _screenTransitionController.forward();
  }

  void _setupFeedbackSystem() {
    // Listen to feedback provider for visual feedback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<FeedbackState>(feedbackProvider, (previous, next) {
        if (next.hasActiveFeedbacks &&
            (previous?.activeFeedbackCount ?? 0) < next.activeFeedbackCount) {
          _feedbackController.forward().then((_) => _feedbackController.reverse());
        }
      });
    });
  }

  void _handleSettingsClick() {}

  void _handleNotificationsClick() {
    // TODO: Implement notifications screen
    // ref.read(feedbackProvider.notifier).showInfo('Notificações em desenvolvimento!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          onSettingsClick: _handleSettingsClick,
          onNotificationsClick: _handleNotificationsClick,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _screens,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: ProfessionalBottomNav(
          currentIndex: _currentIndex,
          centerButtonIndex: 2, // Índice do botão de pets
          items: const [
            CustomBottomNavItem(
              icon: Icons.dashboard_rounded,
              activeIcon: Icons.dashboard,
              label: '',
            ),
            CustomBottomNavItem(
              icon: Icons.store_outlined,
              activeIcon: Icons.store,
              label: '',
            ),
            CustomBottomNavItem(
              icon: Icons.pets_outlined,
              activeIcon: Icons.pets,
              label: '',
            ),
            CustomBottomNavItem(
              icon: Icons.sports_esports_outlined,
              activeIcon: Icons.sports_esports,
              label: '',
            ),
            CustomBottomNavItem(
              icon: Icons.feed_outlined,
              activeIcon: Icons.feed,
              label: '',
            ),
          ],
          onTap: (index) => setState(() => _currentIndex = index),
        )

        ///_buildBottomNavigationBar(),

        );
  }
}

// screens/dashboard_screen.dart

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);

    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              '📊 Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                _buildDashboardCard(
                  '👤',
                  'Seu Perfil',
                  [
                    'Nível: ${gameState.level}',
                    'XP: ${gameState.xp}',
                    'Moedas: ${gameState.coins}',
                    'Gemas: ${gameState.gems}',
                  ],
                  const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 15),
                _buildDashboardCard(
                  '🐾',
                  'Visão Geral dos Pets',
                  [
                    'Total de Pets: ${gameState.userPets.length}',
                    'Pets Colaborativos: ${gameState.userPets.where((p) => p.isCollaborative).length}',
                    'Pet Ativo: ${gameState.activePet?.name ?? 'N/A'}',
                    'Humor do Pet Ativo: ${gameState.activePet?.getMood() ?? 'N/A'}',
                  ],
                  const Color(0xFFFFC107),
                ),
                const SizedBox(height: 15),
                _buildDashboardCard(
                  '✨',
                  'Missões & Eventos',
                  [
                    '✅ Alimente seu pet 5 vezes (Recompensa: 50 🪙)',
                    '⭐ Participe do Evento Semanal (Recompensa: 1 💎)',
                    '🤝 Colabore na adoção de um pet (Recompensa: 100 XP)',
                  ],
                  const Color(0xFF03A9F4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String icon, String title, List<String> items, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            child: Text(
              icon,
              style: TextStyle(
                fontSize: 30,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF667eea),
                  ),
                ),
                const Divider(color: Color(0xFFEEEEEE)),
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF2c3e50),
                          height: 1.6,
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// screens/pet_screen.dart

class PetScreen extends ConsumerStatefulWidget {
  const PetScreen({super.key});

  @override
  _PetScreenState createState() => _PetScreenState();
}

class _PetScreenState extends ConsumerState<PetScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _bounceController;
  late Animation<double> _floatAnimation;
  late Animation<double> _bounceAnimation;

  String? _speechText;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: 0,
      end: 12, // Reduzido para movimento mais sutil
    ).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05, // Reduzido para efeito mais sutil
    ).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _onPetTap() async {
    final activePet = ref.read(activePetProvider);
    if (activePet == null) return;

    setState(() {
      _isLoading = true;
      _speechText = null;
    });

    try {
      final response = await PetService.generatePetResponse(activePet);
      setState(() {
        _speechText = response;
        _isLoading = false;
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _speechText = null;
          });
        }
      });
      PetStatusBottomSheet.show(context, activePet);
      ref.read(gameStateProvider.notifier).petClick();
    } catch (e) {
      setState(() {
        _speechText = '... (sem resposta)';
        _isLoading = false;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _speechText = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700; // Detecta telas pequenas

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF87CEEB), Color(0xFF98FB98)],
        ),
      ),
      child: Column(
        children: [
          // Header com slots e level - responsivo
          Container(
            height: isSmallScreen ? 70 : 80,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, // 5% da largura da tela
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Slots com largura flexível
                Expanded(
                  flex: 3,
                  child: CollaborationSlots(),
                ),
                SizedBox(width: screenWidth * 0.03),
                // Level info responsivo
                Consumer(
                  builder: (context, ref, child) {
                    final gameState = ref.watch(gameStateProvider);
                    return GestureDetector(
                      onTap: () => _showLevelInfo(context, gameState),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: isSmallScreen ? 8 : 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Color(0xFFFFD700),
                              size: isSmallScreen ? 18 : 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Nível ${gameState.level}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final activePet = ref.watch(activePetProvider);

                return Stack(
                  children: [
                    // Main pet area
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (activePet != null) ...[
                            // Pet com tamanho responsivo
                            AnimatedBuilder(
                              animation: Listenable.merge([_floatAnimation, _bounceAnimation]),
                              builder: (context, child) {
                                final petSize = screenWidth * (isSmallScreen ? 0.45 : 0.5);
                                return Transform.translate(
                                  offset: Offset(0, _floatAnimation.value),
                                  child: Transform.scale(
                                    scale: _bounceAnimation.value,
                                    child: SizedBox(
                                      width: petSize,
                                      height: petSize,
                                      child: PetContainer(
                                        pet: activePet,
                                        onTap: () => PetStatusBottomSheet.show(context, activePet),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            // Nome do pet responsivo
                            GestureDetector(
                              onTap: () => _changePetName(context, activePet.id),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05,
                                  vertical: isSmallScreen ? 10 : 12,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: screenWidth * 0.8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      activePet.name,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 20 : 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2c3e50),
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      activePet.type,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        color: const Color(0xFF2c3e50).withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            // Estado sem pet responsivo
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.08),
                              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.pets,
                                    size: screenWidth * (isSmallScreen ? 0.2 : 0.25),
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Text(
                                    'Nenhum Pet',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 20 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2c3e50),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Text(
                                    'Adote um amiguinho!',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      color: Color(0xFF7f8c8d),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Speech bubble responsiva
                    if (_speechText != null)
                      Positioned(
                        top: screenHeight * 0.02,
                        left: screenWidth * 0.05,
                        right: screenWidth * 0.05,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.9,
                          ),
                          child: PetSpeechBubble(text: _speechText!),
                        ),
                      ),

                    // Loading indicator responsivo
                    if (_isLoading)
                      Positioned(
                        top: screenHeight * 0.08,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06,
                              vertical: isSmallScreen ? 12 : 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: isSmallScreen ? 16 : 20,
                                  height: isSmallScreen ? 16 : 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.03),
                                Text(
                                  'Pet pensando...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Collaborator avatar responsivo
                    Positioned(
                      top: screenHeight * 0.04,
                      right: screenWidth * 0.05,
                      child: Transform.scale(
                        scale: isSmallScreen ? 1.0 : 1.2,
                        child: const CollaboratorAvatar(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom panel responsivo
          // Container(
          //   // constraints: BoxConstraints(
          //   //   minHeight: screenHeight * (isSmallScreen ? 0.22 : 0.25),
          //   //   maxHeight: screenHeight * (isSmallScreen ? 0.30 : 0.35),
          //   // ),
          //   child: Consumer(
          //     builder: (context, ref, child) {
          //       final activePet = ref.watch(activePetProvider);
          //       if (activePet != null) {
          //         return PetStatusPanel(pet: activePet);
          //       } else {
          //         return const AdoptionPanel();
          //       }
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  void _showLevelInfo(BuildContext context, gameState) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = MediaQuery.of(context).size.height < 700;

    final xpToNextLevel = gameState.level * 1000;
    final currentLevelXP = gameState.xp % 1000;
    final progress = (currentLevelXP / 1000 * 100).toStringAsFixed(1);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.star,
              color: Color(0xFFFFD700),
              size: isSmallScreen ? 24 : 28,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Informações de Nível',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Container(
          width: screenWidth * 0.8,
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLevelInfoRow('Nível Atual:', '${gameState.level}', Icons.grade, isSmallScreen),
              SizedBox(height: isSmallScreen ? 8 : 12),
              _buildLevelInfoRow('XP Atual:', '${gameState.xp}', Icons.flash_on, isSmallScreen),
              SizedBox(height: isSmallScreen ? 8 : 12),
              _buildLevelInfoRow('Próximo Nível:', '$xpToNextLevel XP', Icons.flag, isSmallScreen),
              SizedBox(height: isSmallScreen ? 8 : 12),
              _buildLevelInfoRow('Progresso:', '$progress%', Icons.trending_up, isSmallScreen),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498db),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelInfoRow(String label, String value, IconData icon, bool isSmallScreen) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF3498db),
          size: isSmallScreen ? 18 : 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2c3e50),
          ),
        ),
      ],
    );
  }

  void _changePetName(BuildContext context, String petId) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    final activePet = ref.read(activePetProvider);
    if (activePet == null) return;

    final controller = TextEditingController(text: activePet.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.edit,
              color: Color(0xFF3498db),
              size: isSmallScreen ? 20 : 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Mudar Nome do Pet',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Container(
          width: screenWidth * 0.8,
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: isSmallScreen ? 16 : 18),
            decoration: InputDecoration(
              hintText: 'Digite o novo nome',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 12 : 16,
              ),
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      ref
                          .read(gameStateProvider.notifier)
                          .updatePetName(petId, controller.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Nome alterado para ${controller.text.trim()}!',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498db),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Confirmar',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Carregar dados salvos na inicialização
    ref.read(gameStateProvider.notifier).loadFromStorage();

    return MaterialApp(
      title: 'Pet Game',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Poppins',
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// models/pet.dart
class Pet {
  final String id;
  final String name;
  final String type;
  final String avatar;
  final double happiness;
  final double hunger;
  final double energy;
  final double health;
  final String ownerId;
  final int level;
  final bool isCollaborative;
  final bool collaboratorMet;
  final int adoptionCost;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.avatar,
    this.happiness = 70.0,
    this.hunger = 30.0,
    this.energy = 60.0,
    this.health = 80.0,
    required this.ownerId,
    this.level = 1,
    this.isCollaborative = false,
    this.collaboratorMet = false,
    this.adoptionCost = 100,
  });

  Pet copyWith({
    String? id,
    String? name,
    String? type,
    String? avatar,
    double? happiness,
    double? hunger,
    double? energy,
    double? health,
    String? ownerId,
    int? level,
    bool? isCollaborative,
    bool? collaboratorMet,
    int? adoptionCost,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      avatar: avatar ?? this.avatar,
      happiness: happiness ?? this.happiness,
      hunger: hunger ?? this.hunger,
      energy: energy ?? this.energy,
      health: health ?? this.health,
      ownerId: ownerId ?? this.ownerId,
      level: level ?? this.level,
      isCollaborative: isCollaborative ?? this.isCollaborative,
      collaboratorMet: collaboratorMet ?? this.collaboratorMet,
      adoptionCost: adoptionCost ?? this.adoptionCost,
    );
  }

  String getMood() {
    double avg = (happiness + health + energy + (100 - hunger)) / 4;
    if (avg >= 80) return '😸 Muito Feliz';
    if (avg >= 60) return '😊 Feliz';
    if (avg >= 40) return '😐 Neutro';
    if (avg >= 20) return '😔 Triste';
    return '😿 Muito Triste';
  }
}

// models/collaborative_adoption.dart
class CollaborativeAdoption {
  final String id;
  final String petId;
  final String adopter1Id;
  final String status;

  CollaborativeAdoption({
    required this.id,
    required this.petId,
    required this.adopter1Id,
    this.status = 'waiting_for_partner',
  });
}

// models/inventory.dart
class Inventory {
  final int food;
  final int toys;
  final int medicine;
  final int accessories;
  final int foodPremium;

  Inventory({
    this.food = 5,
    this.toys = 3,
    this.medicine = 2,
    this.accessories = 0,
    this.foodPremium = 1,
  });

  Inventory copyWith({
    int? food,
    int? toys,
    int? medicine,
    int? accessories,
    int? foodPremium,
  }) {
    return Inventory(
      food: food ?? this.food,
      toys: toys ?? this.toys,
      medicine: medicine ?? this.medicine,
      accessories: accessories ?? this.accessories,
      foodPremium: foodPremium ?? this.foodPremium,
    );
  }
}

// models/shop_item.dart
class ShopItem {
  final String id;
  final String name;
  final String icon;
  final int price;
  final String type;

  ShopItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.price,
    required this.type,
  });
}

// models/adoptable_pet.dart
class AdoptablePet {
  final String id;
  final String name;
  final String type;
  final String avatar;
  final int adoptionCost;

  AdoptablePet({
    required this.id,
    required this.name,
    required this.type,
    required this.avatar,
    required this.adoptionCost,
  });
}

// models/game_state.dart
class GameState {
  static const int MEET_LEVEL_THRESHOLD = 3;
  static const String USER_ID = 'user123';

  final int coins;
  final int xp;
  final int gems;
  final int level;
  final int purchasedSlots;
  final List<Pet> userPets;
  final String? activePetId;
  final List<CollaborativeAdoption> collaborativeAdoptions;
  final Inventory inventory;

  GameState({
    this.coins = 1250,
    this.xp = 2850,
    this.gems = 45,
    this.level = 5,
    this.purchasedSlots = 0,
    this.userPets = const [],
    this.activePetId,
    this.collaborativeAdoptions = const [],
    Inventory? inventory,
  }) : inventory = inventory ?? Inventory();

  // Getters
  Pet? get activePet => userPets.cast<Pet?>().firstWhere(
        (pet) => pet?.id == activePetId,
        orElse: () => null,
      );

  // Adoptable pets list
  static final List<AdoptablePet> adoptablePetsList = [
    AdoptablePet(
        id: 'pet_dog1', name: 'Rex', type: 'Cachorro Forte', avatar: '🐶', adoptionCost: 200),
    AdoptablePet(
        id: 'pet_hamster1',
        name: 'Pipoca',
        type: 'Hamster Pequeno',
        avatar: '🐹',
        adoptionCost: 100),
    AdoptablePet(
        id: 'pet_bird1', name: 'Piu', type: 'Pássaro Cantador', avatar: '🐦', adoptionCost: 150),
    AdoptablePet(
        id: 'pet_fish1', name: 'Nemo', type: 'Peixe Dourado', avatar: '🐠', adoptionCost: 80),
    AdoptablePet(
        id: 'food_premium', name: 'Ração Especial', type: 'Comida', avatar: '🥩', adoptionCost: 75),
  ];

  // Shop items
  static final List<ShopItem> shopItems = [
    ShopItem(id: 'food', name: 'Comida Premium', icon: '🍎', price: 50, type: 'food'),
    ShopItem(id: 'toy', name: 'Brinquedo', icon: '🎾', price: 75, type: 'toy'),
    ShopItem(id: 'medicine', name: 'Remédio', icon: '💊', price: 100, type: 'medicine'),
    ShopItem(id: 'accessory', name: 'Acessório', icon: '🎀', price: 200, type: 'accessory'),
  ];

  // Copy methods for immutability
  GameState copyWith({
    int? coins,
    int? xp,
    int? gems,
    int? level,
    int? purchasedSlots,
    List<Pet>? userPets,
    String? activePetId,
    List<CollaborativeAdoption>? collaborativeAdoptions,
    Inventory? inventory,
  }) {
    return GameState(
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      gems: gems ?? this.gems,
      level: level ?? this.level,
      purchasedSlots: purchasedSlots ?? this.purchasedSlots,
      userPets: userPets ?? this.userPets,
      activePetId: activePetId ?? this.activePetId,
      collaborativeAdoptions: collaborativeAdoptions ?? this.collaborativeAdoptions,
      inventory: inventory ?? this.inventory,
    );
  }
}

// screens/shop_screen.dart

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              '🛍️ Loja de Itens',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.8,
              ),
              itemCount: GameState.shopItems.length,
              itemBuilder: (context, index) {
                final item = GameState.shopItems[index];
                return _buildShopItem(context, ref, item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem(BuildContext context, WidgetRef ref, item) {
    return GestureDetector(
      onTap: () => _buyItem(context, ref, item),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.icon,
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              '${item.price} 🪙',
              style: const TextStyle(
                color: Color(0xFFf39c12),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _buyItem(BuildContext context, WidgetRef ref, item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comprar Item'),
        content: Text('Deseja comprar ${item.name} por ${item.price} moedas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (ref.read(gameStateProvider.notifier).buyItem(item.type, item.price)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ ${item.name} comprado!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Moedas insuficientes!')),
                );
              }
              Navigator.of(context).pop();
            },
            child: const Text('Comprar'),
          ),
        ],
      ),
    );
  }
}

// screens/ranking_screen.dart

class RankingScreen extends ConsumerWidget {
  final List<Map<String, dynamic>> rankingData = [
    {'position': '1º', 'name': 'PetMaster2024', 'xp': 15430, 'avatar': '🥇'},
    {'position': '2º', 'name': 'CatLover99', 'xp': 12890, 'avatar': '🥈'},
    {'position': '3º', 'name': 'DogFriend', 'xp': 8450, 'avatar': '🥉'},
  ];

  RankingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);

    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              '🏆 Ranking de Jogadores',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: rankingData.length + 1,
              itemBuilder: (context, index) {
                if (index < rankingData.length) {
                  return _buildRankingItem(rankingData[index]);
                } else {
                  return _buildRankingItem({
                    'position': '4º',
                    'name': 'Você',
                    'xp': gameState.xp,
                    'avatar': '👤',
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingItem(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            data['position'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFf39c12),
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFff6b6b), Color(0xFFee5a24)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                data['avatar'],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c3e50),
                  ),
                ),
                Text(
                  '${data['xp']} XP',
                  style: const TextStyle(
                    color: Color(0xFF7f8c8d),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// screens/feed_screen.dart

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  String? _generatedNews;
  bool _isGeneratingNews = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '📰 Notícias do Mundo Pet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2c3e50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildNewsSection(),
            const SizedBox(height: 20),
            _buildEventsSection(),
            const SizedBox(height: 20),
            _buildMissionsSection(),
            const SizedBox(height: 20),
            _buildGenerateNewsButton(),
            if (_generatedNews != null) ...[
              const SizedBox(height: 15),
              _buildGeneratedNews(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSection() {
    return _buildSection(
      title: 'Últimas Notícias:',
      children: [
        _buildNewsItem('🐾 Um novo evento de caça ao tesouro começa na Floresta Encantada!'),
        _buildNewsItem('🌟 "Estrelinha" atingiu o Nível 10 e se tornou um pet lendário!'),
        _buildNewsItem('🎉 Desconto de 50% em todos os brinquedos da loja esta semana!'),
      ],
    );
  }

  Widget _buildEventsSection() {
    return _buildSection(
      title: 'Eventos Próximos:',
      children: [
        _buildEventItem('📅 15/06: Festival de Natação dos Peixes'),
        _buildEventItem('📅 20/06: Corrida Anual de Hamsters'),
      ],
    );
  }

  Widget _buildMissionsSection() {
    return _buildSection(
      title: 'Missões Ativas:',
      children: [
        _buildMissionItem('✅ Alimente seu pet 5 vezes (Recompensa: 50 🪙)'),
        _buildMissionItem('✅ Brinque com outro pet (Recompensa: 1 💎)'),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2c3e50),
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildNewsItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF555555),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildEventItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF555555),
        ),
      ),
    );
  }

  Widget _buildMissionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF555555),
        ),
      ),
    );
  }

  Widget _buildGenerateNewsButton() {
    return ElevatedButton.icon(
      onPressed: _isGeneratingNews ? null : _generateNews,
      icon: _isGeneratingNews
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.auto_awesome),
      label: Text(_isGeneratingNews ? 'Gerando...' : 'Gerar Notícia ✨'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildGeneratedNews() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFe0f2f7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _generatedNews!,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF333333),
          height: 1.4,
        ),
      ),
    );
  }

  void _generateNews() async {
    setState(() {
      _isGeneratingNews = true;
      _generatedNews = null;
    });

    try {
      final gameState = ref.read(gameStateProvider);
      final news = await NewsService.generateNews(gameState);
      setState(() {
        _generatedNews = news;
        _isGeneratingNews = false;
      });
    } catch (e) {
      setState(() {
        _generatedNews = 'Erro ao gerar notícia. Tente novamente.';
        _isGeneratingNews = false;
      });
    }
  }
}

// widgets/collaboration_slots.dart

class CollaborationSlots extends ConsumerWidget {
  const CollaborationSlots({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: _buildSlots(context, ref, gameState),
    );
  }

  List<Widget> _buildSlots(BuildContext context, WidgetRef ref, gameState) {
    List<Widget> slots = [];

    // Add occupied slots (user pets)
    for (int i = 0; i < gameState.userPets.length; i++) {
      final pet = gameState.userPets[i];
      slots.add(_buildSlot(
        avatar: pet.isCollaborative && !pet.collaboratorMet ? '❓' : pet.avatar,
        isOccupied: true,
        onTap: () => _showSlotInfo(context, ref, gameState, i),
      ));
    }

    // Add waiting slots (collaborative adoptions)
    for (var adoption in gameState.collaborativeAdoptions) {
      final adoptablePet =
          GameState.adoptablePetsList.where((p) => p.id == adoption.petId).firstOrNull;
      if (adoptablePet != null) {
        slots.add(_buildSlot(
          avatar: adoptablePet.avatar,
          isWaiting: true,
          onTap: () => _showWaitingInfo(context, adoptablePet.name),
        ));
      }
    }

    // Calculate available slots
    const maxSlots = 4;
    const numInitialFreeSlots = 2;
    int usedSlots = gameState.userPets.length + gameState.collaborativeAdoptions.length;
    int availableSlots = 0;

    if (usedSlots < numInitialFreeSlots) {
      availableSlots = numInitialFreeSlots - usedSlots;
    }
    // availableSlots += gameState.purchasedSlots;

    // Add available slots
    for (int i = 0; i < availableSlots && (usedSlots + i) < maxSlots; i++) {
      slots.add(_buildSlot(
        avatar: '+',
        isAvailable: true,
        onTap: () => AdoptionDialog.show(context, ref),
      ));
    }

    // Add locked slots
    int currentDisplayCount = usedSlots + availableSlots.clamp(0, maxSlots - usedSlots);
    while (currentDisplayCount < maxSlots) {
      slots.add(_buildSlot(
        avatar: '🔒',
        isLocked: true,
        onTap: () => _unlockSlot(context, ref),
      ));
      currentDisplayCount++;
    }

    return slots;
  }

  Widget _buildSlot({
    required String avatar,
    bool isOccupied = false,
    bool isWaiting = false,
    bool isAvailable = false,
    bool isLocked = false,
    required VoidCallback onTap,
  }) {
    Color backgroundColor;
    if (isOccupied) {
      backgroundColor = const Color(0xFFff6b6b);
    } else if (isWaiting) {
      backgroundColor = const Color(0xFFFFD700);
    } else if (isAvailable) {
      backgroundColor = Colors.white.withOpacity(0.2);
    } else {
      backgroundColor = const Color.fromARGB(255, 232, 226, 234);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.only(right: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(isOccupied || isWaiting ? 0.8 : 0.5),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            avatar,
            style: TextStyle(
              fontSize: 35,
              color: isAvailable ? const Color(0xFF666666) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showSlotInfo(BuildContext context, WidgetRef ref, gameState, int petIndex) {
    final pet = gameState.userPets[petIndex];
    String info = '🐱 Informações do Pet\n\n'
        'Nome: ${pet.name}\n'
        'Tipo: ${pet.type}\n'
        'Nível: ${pet.level}\n'
        'Felicidade: ${pet.happiness.round()}%\n'
        'Saúde: ${pet.health.round()}%\n'
        'Energia: ${pet.energy.round()}%\n'
        'Fome: ${pet.hunger.round()}%';

    if (pet.isCollaborative) {
      info += '\n\nParceiro: ${pet.collaboratorMet ? "Conhecido" : "Anónimo"}';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informações do Pet'),
        content: Text(info),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(gameStateProvider.notifier).setActivePet(pet.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✨ Agora você está cuidando de ${pet.name}!')),
              );
            },
            child: const Text('Tornar Ativo'),
          ),
          if (pet.isCollaborative &&
              !pet.collaboratorMet &&
              pet.level >= GameState.MEET_LEVEL_THRESHOLD)
            TextButton(
              onPressed: () {
                ref.read(gameStateProvider.notifier).meetCollaborator(pet.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('🎉 Você conheceu seu parceiro de adoção para ${pet.name}!')),
                );
              },
              child: const Text('Conhecer Parceiro'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showWaitingInfo(BuildContext context, String petName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Adoção Colaborativa: $petName aguardando parceiro...')),
    );
  }

  void _unlockSlot(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desbloquear Slot'),
        content: const Text('Deseja desbloquear um novo slot de pet por 10 gemas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (ref.read(gameStateProvider.notifier).unlockSlot()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🔓 Slot desbloqueado!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Precisa de 10 gemas para desbloquear um slot!')),
                );
              }
              Navigator.of(context).pop();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

// widgets/pet_container.dart

class PetContainer extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap;

  const PetContainer({
    super.key,
    required this.pet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            pet.avatar,
            style: const TextStyle(fontSize: 65),
          ),
        ),
      ),
    );
  }
}

// widgets/pet_speech_bubble.dart

class PetSpeechBubble extends StatelessWidget {
  final String text;

  const PetSpeechBubble({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2c3e50),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// widgets/collaborator_avatar.dart

class CollaboratorAvatar extends ConsumerWidget {
  const CollaboratorAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePet = ref.watch(activePetProvider);

    if (activePet == null || !activePet.isCollaborative) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          activePet.collaboratorMet ? '🤝' : '❓',
          style: const TextStyle(
            fontSize: 24,
            color: Color(0xFF333333),
          ),
        ),
      ),
    );
  }
}

// providers/game_provider.dart

// StateNotifier para gerenciar o estado do jogo
class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(GameState());

  // Carregar dados do storage
  Future<void> loadFromStorage() async {
    try {
      final loadedState = await StorageService.loadGameState();
      if (loadedState != null) {
        state = loadedState;
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
  }

  // Salvar dados no storage
  Future<void> saveGame() async {
    await StorageService.saveGameState(state);
  }

  // Métodos de ação
  void addCoins(int amount) {
    final newXp = state.xp + (amount ~/ 10); // Bonus XP
    state = state.copyWith(
      coins: state.coins + amount,
      xp: newXp,
      level: _calculateLevel(newXp),
    );
    saveGame();
  }

  void addXP(int amount) {
    final newXp = state.xp + amount;
    state = state.copyWith(
      xp: newXp,
      level: _calculateLevel(newXp),
    );
    saveGame();
  }

  void addGems(int amount) {
    state = state.copyWith(gems: state.gems + amount);
    saveGame();
  }

  bool spendCoins(int amount) {
    if (state.coins >= amount) {
      state = state.copyWith(coins: state.coins - amount);
      saveGame();
      return true;
    }
    return false;
  }

  bool spendGems(int amount) {
    if (state.gems >= amount) {
      state = state.copyWith(gems: state.gems - amount);
      saveGame();
      return true;
    }
    return false;
  }

  int _calculateLevel(int xp) {
    return (xp / 1000).floor() + 1;
  }

  void addPet(Pet pet) {
    final newPets = [...state.userPets, pet];
    state = state.copyWith(
      userPets: newPets,
      activePetId: state.activePetId ?? pet.id,
    );
    saveGame();
  }

  void setActivePet(String petId) {
    if (state.userPets.any((pet) => pet.id == petId)) {
      state = state.copyWith(activePetId: petId);
      saveGame();
    }
  }

  void updatePetName(String petId, String newName) {
    final updatedPets = state.userPets.map((pet) {
      return pet.id == petId ? pet.copyWith(name: newName) : pet;
    }).toList();

    state = state.copyWith(userPets: updatedPets);
    saveGame();
  }

  void updatePetStats(
    String petId, {
    double? happiness,
    double? hunger,
    double? energy,
    double? health,
  }) {
    final updatedPets = state.userPets.map((pet) {
      if (pet.id == petId) {
        return pet.copyWith(
          happiness: happiness ?? pet.happiness,
          hunger: hunger ?? pet.hunger,
          energy: energy ?? pet.energy,
          health: health ?? pet.health,
        );
      }
      return pet;
    }).toList();

    state = state.copyWith(userPets: updatedPets);
    saveGame();
  }

  void meetCollaborator(String petId) {
    final updatedPets = state.userPets.map((pet) {
      if (pet.id == petId &&
          pet.isCollaborative &&
          !pet.collaboratorMet &&
          pet.level >= GameState.MEET_LEVEL_THRESHOLD) {
        return pet.copyWith(collaboratorMet: true);
      }
      return pet;
    }).toList();

    state = state.copyWith(userPets: updatedPets);
    saveGame();
  }

  bool buyItem(String itemType, int price) {
    if (state.coins < price) return false;

    Inventory newInventory;
    switch (itemType) {
      case 'food':
        newInventory = state.inventory.copyWith(food: state.inventory.food + 1);
        break;
      case 'toy':
        newInventory = state.inventory.copyWith(toys: state.inventory.toys + 1);
        break;
      case 'medicine':
        newInventory = state.inventory.copyWith(medicine: state.inventory.medicine + 1);
        break;
      case 'accessory':
        newInventory = state.inventory.copyWith(accessories: state.inventory.accessories + 1);
        break;
      case 'food_premium':
        newInventory = state.inventory.copyWith(foodPremium: state.inventory.foodPremium + 1);
        break;
      default:
        return false;
    }

    state = state.copyWith(
      coins: state.coins - price,
      inventory: newInventory,
    );
    saveGame();
    return true;
  }

  bool useItem(String itemType, String effect) {
    final pet = state.activePet;
    if (pet == null) return false;

    Inventory newInventory = state.inventory;
    int xpGain = 0;
    double? newHappiness, newHunger, newEnergy, newHealth;

    switch (itemType) {
      case 'food':
        if (state.inventory.food <= 0) return false;
        newInventory = state.inventory.copyWith(food: state.inventory.food - 1);
        newHunger = (pet.hunger + 30).clamp(0, 100);
        newHappiness = (pet.happiness + 10).clamp(0, 100);
        xpGain = 15;
        break;
      case 'food_premium':
        if (state.inventory.foodPremium <= 0) return false;
        newInventory = state.inventory.copyWith(foodPremium: state.inventory.foodPremium - 1);
        newHunger = (pet.hunger + 50).clamp(0, 100);
        newHappiness = (pet.happiness + 20).clamp(0, 100);
        xpGain = 25;
        break;
      case 'toy':
        if (state.inventory.toys <= 0) return false;
        newInventory = state.inventory.copyWith(toys: state.inventory.toys - 1);
        newEnergy = (pet.energy - 15).clamp(0, 100);
        newHappiness = (pet.happiness + 25).clamp(0, 100);
        xpGain = 20;
        break;
      case 'medicine':
        if (state.inventory.medicine <= 0) return false;
        newInventory = state.inventory.copyWith(medicine: state.inventory.medicine - 1);
        newHealth = (pet.health + 50).clamp(0, 100);
        newHappiness = (pet.happiness + 15).clamp(0, 100);
        xpGain = 25;
        break;
      default:
        return false;
    }

    updatePetStats(
      pet.id,
      happiness: newHappiness,
      hunger: newHunger,
      energy: newEnergy,
      health: newHealth,
    );

    final newXp = state.xp + xpGain;
    state = state.copyWith(
      inventory: newInventory,
      xp: newXp,
      level: _calculateLevel(newXp),
    );
    saveGame();
    return true;
  }

  void petSleep() {
    final pet = state.activePet;
    if (pet == null) return;

    updatePetStats(
      pet.id,
      energy: (pet.energy + 40).clamp(0, 100),
      health: (pet.health + 10).clamp(0, 100),
    );
    addXP(10);
  }

  void petClick() {
    final pet = state.activePet;
    if (pet == null) return;

    updatePetStats(
      pet.id,
      happiness: (pet.happiness + 5).clamp(0, 100),
    );
    addXP(2);
  }

  void addCollaborativeAdoption(CollaborativeAdoption adoption) {
    final newAdoptions = [...state.collaborativeAdoptions, adoption];
    state = state.copyWith(collaborativeAdoptions: newAdoptions);
    saveGame();
  }

  void removeCollaborativeAdoption(String adoptionId) {
    final newAdoptions =
        state.collaborativeAdoptions.where((adoption) => adoption.id != adoptionId).toList();
    state = state.copyWith(collaborativeAdoptions: newAdoptions);
    saveGame();
  }

  bool unlockSlot() {
    if (state.gems >= 10) {
      state = state.copyWith(
        gems: state.gems - 10,
        purchasedSlots: state.purchasedSlots + 1,
      );
      saveGame();
      return true;
    }
    return false;
  }

  void updatePetStatsAutomatically() {
    final updatedPets = state.userPets.map((pet) {
      if (pet.id == state.activePetId) {
        Pet updatedPet = pet.copyWith(
          hunger: (pet.hunger - 0.5).clamp(0, 100),
          energy: (pet.energy - 0.3).clamp(0, 100),
          happiness: (pet.happiness - 0.2).clamp(0, 100),
        );

        // Health deterioration
        if (updatedPet.health < 30) {
          updatedPet = updatedPet.copyWith(
            happiness: (updatedPet.happiness - 0.5).clamp(0, 100),
          );
        }

        if (updatedPet.hunger < 20) {
          updatedPet = updatedPet.copyWith(
            health: (updatedPet.health - 0.3).clamp(0, 100),
          );
        }

        return updatedPet;
      }
      return pet;
    }).toList();

    state = state.copyWith(userPets: updatedPets);
  }
}

// Provider principal do estado do jogo
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

// Providers derivados para facilitar acesso
final activePetProvider = Provider<Pet?>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.activePet;
});

final inventoryProvider = Provider<Inventory>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.inventory;
});

final coinsProvider = Provider<int>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.coins;
});

final xpProvider = Provider<int>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.xp;
});

final gemsProvider = Provider<int>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.gems;
});

final levelProvider = Provider<int>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.level;
});

final userPetsProvider = Provider<List<Pet>>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.userPets;
});

final collaborativeAdoptionsProvider = Provider<List<CollaborativeAdoption>>((ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.collaborativeAdoptions;
});

// Provider para auto-update do jogo
final gameServiceProvider = Provider((ref) {
  return GameService(ref);
});

// Service class for auto-updates
class GameService {
  final Ref ref;
  Timer? _autoUpdateTimer;
  Timer? _autoSaveTimer;

  GameService(this.ref) {
    startAutoUpdate();
    startAutoSave();
  }

  void startAutoUpdate() {
    _autoUpdateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      ref.read(gameStateProvider.notifier).updatePetStatsAutomatically();
    });
  }

  void startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      ref.read(gameStateProvider.notifier).saveGame();
    });
  }

  void dispose() {
    _autoUpdateTimer?.cancel();
    _autoSaveTimer?.cancel();
    ref.read(gameStateProvider.notifier).saveGame();
  }
}

// services/storage_service.dart

class StorageService {
  static const String _gameStateKey = 'game_state';

  // Salvar estado do jogo
  static Future<void> saveGameState(GameState gameState) async {
    final prefs = await SharedPreferences.getInstance();

    final gameData = {
      'coins': gameState.coins,
      'xp': gameState.xp,
      'gems': gameState.gems,
      'level': gameState.level,
      'purchasedSlots': gameState.purchasedSlots,
      'activePetId': gameState.activePetId,
      'userPets': gameState.userPets
          .map((pet) => {
                'id': pet.id,
                'name': pet.name,
                'type': pet.type,
                'avatar': pet.avatar,
                'happiness': pet.happiness,
                'hunger': pet.hunger,
                'energy': pet.energy,
                'health': pet.health,
                'ownerId': pet.ownerId,
                'level': pet.level,
                'isCollaborative': pet.isCollaborative,
                'collaboratorMet': pet.collaboratorMet,
                'adoptionCost': pet.adoptionCost,
              })
          .toList(),
      'inventory': {
        'food': gameState.inventory.food,
        'toys': gameState.inventory.toys,
        'medicine': gameState.inventory.medicine,
        'accessories': gameState.inventory.accessories,
        'foodPremium': gameState.inventory.foodPremium,
      },
      'collaborativeAdoptions': gameState.collaborativeAdoptions
          .map((adoption) => {
                'id': adoption.id,
                'petId': adoption.petId,
                'adopter1Id': adoption.adopter1Id,
                'status': adoption.status,
              })
          .toList(),
    };

    await prefs.setString(_gameStateKey, jsonEncode(gameData));
  }

  // Carregar estado do jogo
  static Future<GameState?> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final gameDataStr = prefs.getString(_gameStateKey);
      if (gameDataStr == null) return null;

      final gameData = jsonDecode(gameDataStr);

      final pets = (gameData['userPets'] as List?)
              ?.map((petData) => Pet(
                    id: petData['id'],
                    name: petData['name'],
                    type: petData['type'],
                    avatar: petData['avatar'],
                    happiness: petData['happiness']?.toDouble() ?? 70.0,
                    hunger: petData['hunger']?.toDouble() ?? 30.0,
                    energy: petData['energy']?.toDouble() ?? 60.0,
                    health: petData['health']?.toDouble() ?? 80.0,
                    ownerId: petData['ownerId'],
                    level: petData['level'] ?? 1,
                    isCollaborative: petData['isCollaborative'] ?? false,
                    collaboratorMet: petData['collaboratorMet'] ?? false,
                    adoptionCost: petData['adoptionCost'] ?? 100,
                  ))
              .toList() ??
          <Pet>[];

      final inventoryData = gameData['inventory'] ?? {};
      final inventory = Inventory(
        food: inventoryData['food'] ?? 5,
        toys: inventoryData['toys'] ?? 3,
        medicine: inventoryData['medicine'] ?? 2,
        accessories: inventoryData['accessories'] ?? 0,
        foodPremium: inventoryData['foodPremium'] ?? 1,
      );

      final adoptions = (gameData['collaborativeAdoptions'] as List?)
              ?.map((adoptionData) => CollaborativeAdoption(
                    id: adoptionData['id'],
                    petId: adoptionData['petId'],
                    adopter1Id: adoptionData['adopter1Id'],
                    status: adoptionData['status'] ?? 'waiting_for_partner',
                  ))
              .toList() ??
          <CollaborativeAdoption>[];

      return GameState(
        coins: gameData['coins'] ?? 1250,
        xp: gameData['xp'] ?? 2850,
        gems: gameData['gems'] ?? 45,
        level: gameData['level'] ?? 5,
        purchasedSlots: gameData['purchasedSlots'] ?? 0,
        userPets: pets,
        activePetId: gameData['activePetId'],
        collaborativeAdoptions: adoptions,
        inventory: inventory,
      );
    } catch (e) {
      print('Erro ao carregar dados salvos: $e');
      return null;
    }
  }

  // Limpar todos os dados salvos
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameStateKey);
  }
}

// services/pet_service.dart

class PetService {
  static const String _apiKey = ''; // Add your Gemini API key here
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static Future<String> generatePetResponse(Pet pet) async {
    if (_apiKey.isEmpty) {
      // Fallback responses when no API key is provided
      final responses = [
        'Miau! Estou feliz hoje! 😸',
        'Woof! Quer brincar comigo? 🎾',
        'Estou com um pouco de fome... 🍖',
        'Que bom te ver! ❤️',
        'Preciso descansar um pouco 😴',
      ];
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      return responses[(pet.happiness ~/ 20).clamp(0, responses.length - 1)];
    }

    final prompt = 'Gere uma curta e fofa frase que meu animal de estimação diria. '
        'Ele é um ${pet.type} chamado ${pet.name}. '
        'Sua felicidade é ${pet.happiness.toStringAsFixed(0)}%, '
        'fome é ${pet.hunger.toStringAsFixed(0)}%, '
        'e energia é ${pet.energy.toStringAsFixed(0)}%. '
        'Responda apenas com a frase do pet.';

    final payload = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt}
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
      }

      return '... (sem resposta)';
    } catch (e) {
      throw Exception('Erro ao gerar resposta do pet');
    }
  }
}

// services/news_service.dart

class NewsService {
  static const String _apiKey = ''; // Add your Gemini API key here
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  static Future<String> generateNews(GameState gameState) async {
    if (_apiKey.isEmpty) {
      // Fallback news when no API key is provided
      final fallbackNews = [
        '🐾 Descoberta nova espécie de pet virtual na região montanhosa!',
        '🏆 Torneio de pets acontecerá no próximo mês com prêmios incríveis!',
        '💎 Evento especial: Triplo de XP durante o fim de semana!',
        '🎪 Festival de pets começou! Participe e ganhe recompensas exclusivas!',
        '🌟 Novos acessórios chegaram à loja! Venha conferir!',
      ];
      await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
      return fallbackNews[(gameState.level % fallbackNews.length)];
    }

    final prompt = 'Gere uma notícia criativa e divertida sobre o mundo dos pets virtuais. '
        'O jogador tem nível ${gameState.level}, ${gameState.userPets.length} pets, '
        '${gameState.coins} moedas e ${gameState.gems} gemas. '
        'A notícia deve ser relacionada ao universo do jogo e ter tom alegre. '
        'Máximo 100 palavras.';

    final payload = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt}
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
      }

      return 'Erro ao gerar notícia. Tente novamente.';
    } catch (e) {
      throw Exception('Erro ao gerar notícia');
    }
  }
}

// // widgets/pet_status_panel.dart
class PetStatusPanel extends ConsumerStatefulWidget {
  final Pet pet;

  const PetStatusPanel({super.key, required this.pet});

  @override
  ConsumerState<PetStatusPanel> createState() => _PetStatusPanelState();
}

class _PetStatusPanelState extends ConsumerState<PetStatusPanel> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    );
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusGrid(),
            const SizedBox(height: 18),
            _buildActionButtons(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusGrid() {
    return SizedBox(
      height: 130,
      child: Row(
        children: [
          // Coluna esquerda
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    '❤️',
                    'Felicidade',
                    widget.pet.happiness,
                    const Color(0xFFff6b6b),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildStatusItem(
                    '🍖',
                    'Fome',
                    widget.pet.hunger,
                    const Color(0xFF4ecdc4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Coluna direita
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    '⚡',
                    'Energia',
                    widget.pet.energy,
                    const Color(0xFF45b7d1),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildStatusItem(
                    '💊',
                    'Saúde',
                    widget.pet.health,
                    const Color(0xFF96ceb4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String icon, String label, double value, Color color) {
    final isCritical = value < 30;
    final isLow = value >= 30 && value < 50;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCritical
              ? Colors.red.withOpacity(0.8)
              : isLow
                  ? Colors.orange.withOpacity(0.8)
                  : Colors.transparent,
          width: 2,
        ),
        boxShadow: isCritical
            ? [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: isCritical
          ? AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _pulseAnimation.value,
                  child: _buildStatusContent(icon, label, value, color),
                );
              },
            )
          : _buildStatusContent(icon, label, value, color),
    );
  }

  Widget _buildStatusContent(String icon, String label, double value, Color color) {
    return Row(
      children: [
        // Ícone
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Texto e porcentagem
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${value.round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double value, Color color) {
    return Container(
      width: double.infinity,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            widthFactor: value / 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          // Shimmer effect
          AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              return FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                      begin: Alignment(-1.0 + _slideController.value * 2, 0.0),
                      end: Alignment(1.0 + _slideController.value * 2, 0.0),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            '🍖',
            'Alimentar',
            const Color(0xFFff6b6b),
            inventory.food > 0 || inventory.foodPremium > 0,
            inventory.food + inventory.foodPremium,
            'Reduz a fome',
            () => _performAction(context, ref, 'food'),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildActionButton(
            '🎮',
            'Brincar',
            const Color(0xFF4ecdc4),
            inventory.toys > 0,
            inventory.toys,
            'Aumenta felicidade',
            () => _performAction(context, ref, 'toy'),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildActionButton(
            '😴',
            'Descansar',
            const Color(0xFF45b7d1),
            true,
            null,
            'Restaura energia (grátis)',
            () => _performAction(context, ref, 'sleep'),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildActionButton(
            '💊',
            'Medicar',
            const Color(0xFF96ceb4),
            widget.pet.health < 100 && inventory.medicine > 0,
            inventory.medicine,
            'Melhora saúde',
            () => _performAction(context, ref, 'medicine'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String icon,
    String label,
    Color color,
    bool enabled,
    int? count,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 80,
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.5),
                      Colors.grey.withOpacity(0.3),
                    ],
                  ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 150),
                      scale: enabled ? 1.0 : 0.8,
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (count != null && count > 0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _performAction(BuildContext context, WidgetRef ref, String action) {
    // Aqui você pode chamar suas funções existentes
    switch (action) {
      case 'food':
        // Chama sua lógica existente para alimentar
        InventoryDialog.show(context, ref, 'food');
        _showSuccessAnimation('🍖');
        break;
      case 'toy':
        InventoryDialog.show(context, ref, 'toy');
        _showSuccessAnimation('🎮');
        break;
      case 'sleep':
        ref.read(gameStateProvider.notifier).petSleep();
        _showSuccessAnimation('😴');
        break;
      case 'medicine':
        InventoryDialog.show(context, ref, 'medicine');
        _showSuccessAnimation('💊');
        break;
    }
  }

  void _showSuccessAnimation(String icon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => _SuccessAnimation(icon: icon),
    );
  }
}

// Animação de sucesso
class _SuccessAnimation extends StatefulWidget {
  final String icon;

  const _SuccessAnimation({required this.icon});

  @override
  State<_SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<_SuccessAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) Navigator.of(context).pop();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// EXTENSÃO PARA FACILITAR O USO COM BOTTOMSHEET
extension PetStatusBottomSheet on PetStatusPanel {
  static void show(BuildContext context, Pet pet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => PetStatusPanel(pet: pet),
    );
  }
}
// widgets/adoption_panel.dart

class AdoptionPanel extends ConsumerWidget {
  const AdoptionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      constraints: const BoxConstraints(maxHeight: 140),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Adote um Novo Companheiro!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comece a sua jornada de cuidado com pets adotando um amigo peludo, escamoso ou com penas!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Você pode adotar sozinho ou em parceria com outro jogador.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => AdoptionDialog.show(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C4FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Adotar Agora!'),
          ),
        ],
      ),
    );
  }
}

// dialogs/adoption_dialog.dart

class AdoptionDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final gameState = ref.read(gameStateProvider);
    final hasPets = gameState.userPets.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolha o Tipo de Adoção'),
        content: const Text('Deseja adotar um pet sozinho ou em modo colaborativo?'),
        actions: [
          if (!hasPets)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showAdoptablePets(context, ref, false);
              },
              child: const Text('Solo'),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showAdoptablePets(context, ref, true);
            },
            child: const Text('Colaborativa'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  static void _showAdoptablePets(BuildContext context, WidgetRef ref, bool isCollaborative) {
    showDialog(
      context: context,
      builder: (context) => _AdoptablePetsDialog(ref: ref, isCollaborative: isCollaborative),
    );
  }
}

class _AdoptablePetsDialog extends ConsumerWidget {
  final WidgetRef ref;
  final bool isCollaborative;

  const _AdoptablePetsDialog({required this.ref, required this.isCollaborative});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);

    return AlertDialog(
      title: Text(isCollaborative ? 'Adotar (Colaborativa)' : 'Adotar (Solo)'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (isCollaborative) ...[
                _buildWaitingSection(context, ref, gameState),
                const Divider(),
                const Text('Inicie uma Nova Adoção Colaborativa:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
              _buildAvailablePetsGrid(context, ref, gameState),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _buildWaitingSection(BuildContext context, WidgetRef ref, gameState) {
    final waitingPets = gameState.collaborativeAdoptions
        .where((adoption) => GameState.adoptablePetsList.any((pet) => pet.id == adoption.petId))
        .toList();

    if (waitingPets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Text(
            'Nenhum pet aguardando parceiro. Seja o primeiro a iniciar uma adoção colaborativa!'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pets Aguardando Parceiro:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...waitingPets.map((adoption) {
          final pet = GameState.adoptablePetsList.firstWhere((p) => p.id == adoption.petId);
          final isFirstAdopter = adoption.adopter1Id == GameState.USER_ID;

          return ListTile(
            leading: Text(pet.avatar, style: const TextStyle(fontSize: 24)),
            title: Text(pet.name),
            subtitle: Text('Adotante: ${isFirstAdopter ? "Você" : adoption.adopter1Id}'),
            trailing: ElevatedButton(
              onPressed:
                  isFirstAdopter ? null : () => _joinCollaborativeAdoption(context, ref, adoption),
              child: Text(isFirstAdopter ? 'Aguardando...' : 'Juntar-se'),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAvailablePetsGrid(BuildContext context, WidgetRef ref, gameState) {
    final availablePets = GameState.adoptablePetsList
        .where((pet) =>
            !gameState.collaborativeAdoptions.any((adoption) => adoption.petId == pet.id) &&
            !gameState.userPets.any((userPet) => userPet.id == pet.id))
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: availablePets.length,
      itemBuilder: (context, index) {
        final pet = availablePets[index];
        return GestureDetector(
          onTap: () => _startNewAdoption(context, ref, pet),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(pet.avatar, style: const TextStyle(fontSize: 32)),
                  Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(pet.type, style: const TextStyle(fontSize: 10)),
                  Text('${pet.adoptionCost}🪙', style: const TextStyle(color: Colors.orange)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _startNewAdoption(BuildContext context, WidgetRef ref, dynamic adoptablePet) {
    final gameState = ref.read(gameStateProvider);

    if (gameState.coins < adoptablePet.adoptionCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Moedas insuficientes para adotar ${adoptablePet.name}!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Adoção'),
        content:
            Text('Deseja adotar ${adoptablePet.name} por ${adoptablePet.adoptionCost} moedas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(gameStateProvider.notifier).spendCoins(adoptablePet.adoptionCost);

              if (isCollaborative) {
                final adoption = CollaborativeAdoption(
                  id: 'collab_${DateTime.now().millisecondsSinceEpoch}',
                  petId: adoptablePet.id,
                  adopter1Id: GameState.USER_ID,
                );
                ref.read(gameStateProvider.notifier).addCollaborativeAdoption(adoption);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('🤝 Você iniciou a adoção colaborativa de ${adoptablePet.name}!')),
                );
              } else {
                final newPet = Pet(
                  id: adoptablePet.id,
                  name: adoptablePet.name,
                  type: adoptablePet.type,
                  avatar: adoptablePet.avatar,
                  ownerId: GameState.USER_ID,
                  adoptionCost: adoptablePet.adoptionCost,
                );
                ref.read(gameStateProvider.notifier).addPet(newPet);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('🎉 Você adotou ${newPet.name}!')),
                );
              }
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _joinCollaborativeAdoption(
      BuildContext context, WidgetRef ref, CollaborativeAdoption adoption) {
    final adoptablePet = GameState.adoptablePetsList.firstWhere((p) => p.id == adoption.petId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Juntar-se à Adoção'),
        content: Text('Deseja se juntar à adoção de ${adoptablePet.name}? (Sem custo adicional)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final gameState = ref.read(gameStateProvider);
              ref.read(gameStateProvider.notifier).removeCollaborativeAdoption(adoption.id);
              final newPet = Pet(
                id: adoptablePet.id,
                name: adoptablePet.name,
                type: adoptablePet.type,
                avatar: adoptablePet.avatar,
                ownerId: '${adoption.adopter1Id},${GameState.USER_ID}',
                isCollaborative: true,
                adoptionCost: adoptablePet.adoptionCost,
              );
              ref.read(gameStateProvider.notifier).addPet(newPet);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🎉 Você se juntou e adotou ${newPet.name}!')),
              );
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

// dialogs/inventory_dialog.dart

class InventoryDialog {
  static void show(BuildContext context, WidgetRef ref, String actionType) {
    showDialog(
      context: context,
      builder: (context) => _InventoryDialog(ref: ref, actionType: actionType),
    );
  }
}

class _InventoryDialog extends ConsumerWidget {
  final WidgetRef ref;
  final String actionType;

  const _InventoryDialog({required this.ref, required this.actionType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final items = _getRelevantItems(gameState);

    if (items.isEmpty) {
      return AlertDialog(
        title: const Text('Inventário Vazio'),
        content: Text('Você não tem itens de $actionType no inventário. Visite a loja!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Seu Inventário'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () => _useItem(context, ref, item),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item['icon'], style: const TextStyle(fontSize: 24)),
                      Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Qtd: ${item['count']}', style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 5),
                      ElevatedButton(
                        onPressed: () => _useItem(context, ref, item),
                        child: const Text('Usar'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getRelevantItems(gameState) {
    List<Map<String, dynamic>> items = [];

    if (actionType == 'food') {
      if (gameState.inventory.food > 0) {
        items.add({
          'type': 'food',
          'name': 'Comida Padrão',
          'count': gameState.inventory.food,
          'effect': 'normal',
          'icon': '🍎',
        });
      }
      if (gameState.inventory.foodPremium > 0) {
        items.add({
          'type': 'food_premium',
          'name': 'Ração Especial',
          'count': gameState.inventory.foodPremium,
          'effect': 'premium',
          'icon': '🥩',
        });
      }
    } else if (actionType == 'toy') {
      if (gameState.inventory.toys > 0) {
        items.add({
          'type': 'toy',
          'name': 'Brinquedo',
          'count': gameState.inventory.toys,
          'effect': 'normal',
          'icon': '🎾',
        });
      }
    } else if (actionType == 'medicine') {
      if (gameState.inventory.medicine > 0) {
        items.add({
          'type': 'medicine',
          'name': 'Remédio',
          'count': gameState.inventory.medicine,
          'effect': 'normal',
          'icon': '💊',
        });
      }
    }

    return items.where((item) => item['count'] > 0).toList();
  }

  void _useItem(BuildContext context, WidgetRef ref, Map<String, dynamic> item) {
    if (ref.read(gameStateProvider.notifier).useItem(item['type'], item['effect'])) {
      String message = '';
      if (item['type'] == 'food') {
        message = '🍖 Pet alimentado com ${item['name']}!';
      } else if (item['type'] == 'food_premium') {
        message = '🥩 Pet alimentado com ${item['name']}!';
      } else if (item['type'] == 'toy') {
        message = '🎮 Que divertido!';
      } else if (item['type'] == 'medicine') {
        message = '💊 Pet curado!';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Não foi possível usar ${item['name']}!')),
      );
    }
  }
}
