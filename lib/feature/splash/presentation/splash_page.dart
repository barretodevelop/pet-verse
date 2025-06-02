// lib/feature/splash/presentation/splash_page.dart
// ATUALIZADO: Splash page com onboarding interativo integrado
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petverse/core/constants/app_constants.dart';
import 'package:petverse/core/theme/app_thema.dart';
import 'package:petverse/core/utils/app_utils.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';
import 'package:petverse/feature/auth/state/authentication_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      print('🚀 Iniciando app...');

      // Verificar se é primeira vez
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool(AppConstants.keyFirstLaunch) ?? true;

      // Esperar um mínimo para mostrar a splash
      await Future.delayed(const Duration(milliseconds: 2500));

      if (!mounted) return;

      // Se é primeira vez, mostrar onboarding
      if (isFirstLaunch) {
        setState(() => _showOnboarding = true);
        return;
      }

      // Verificar estado de autenticação se não é primeira vez
      final authState = ref.read(authenticationNotifierProvider);

      print(
          '🔍 Estado de auth: isAuthenticated=${authState.isAuthenticated}, isLoading=${authState.isLoading}');

      if (authState.isAuthenticated) {
        print('✅ Usuário logado, indo para home');
        context.go('/home');
      } else {
        print('❌ Usuário não logado, indo para login');
        context.go('/login');
      }
    } catch (e) {
      print('❌ Erro na inicialização: $e');
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Erro de Inicialização',
          style: AppTheme.lightTheme.textTheme.headlineSmall,
        ),
        content: Text(
          'Ocorreu um erro ao inicializar o app:\n$error',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeApp(); // Retry
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyFirstLaunch, false);

    AppUtils.showAnimatedFeedback(
      context: context,
      type: FeedbackType.success,
      message: 'Bem-vindo ao PetVerse!',
      subtitle: 'Sua jornada começa agora! 🐾',
    );

    // Aguardar um pouco e ir para login
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listener para mudanças de auth (manter funcionalidade original)
    ref.listen<AuthenticationState>(
      authenticationNotifierProvider,
      (previous, current) {
        if (_showOnboarding) return; // Não navegar se está no onboarding

        print('🎯 Auth state mudou: ${current.isAuthenticated}');

        if (previous?.isAuthenticated == false && current.isAuthenticated) {
          print('✅ Login detectado, navegando para home');
          context.go('/home');
        }

        if (previous?.isAuthenticated == true && !current.isAuthenticated) {
          print('❌ Logout detectado, navegando para login');
          context.go('/login');
        }
      },
    );

    if (_showOnboarding) {
      return InteractiveOnboardingPage(onComplete: _completeOnboarding);
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8FF),
              Color(0xFFFFFFFF),
              Color(0xFFF0F8FF),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Animation
                      AnimatedBuilder(
                        animation: _logoScale,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4ECDC4),
                                    Color.fromRGBO(78, 205, 196, 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(35),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4ECDC4)
                                        .withOpacity(0.3),
                                    blurRadius: 25,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.pets,
                                size: 70,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // App Name Animation
                      AnimatedBuilder(
                        animation: _textOpacity,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _textOpacity.value,
                            child: Column(
                              children: [
                                Text(
                                  AppConstants.appName,
                                  style: GoogleFonts.nunito(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF2D3748),
                                    letterSpacing: -1,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF4ECDC4)
                                            .withOpacity(0.1),
                                        const Color(0xFF4ECDC4)
                                            .withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: const Color(0xFF4ECDC4)
                                          .withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    AppConstants.appTagline,
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4ECDC4),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 80),

                      // Loading Animation
                      const EnhancedPulsingDots(),
                    ],
                  ),
                ),
              ),

              // Version Info
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Versão ${AppConstants.appVersion}',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced Loading Animation
class EnhancedPulsingDots extends StatefulWidget {
  const EnhancedPulsingDots({super.key});

  @override
  State<EnhancedPulsingDots> createState() => _EnhancedPulsingDotsState();
}

class _EnhancedPulsingDotsState extends State<EnhancedPulsingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Start animations with delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4ECDC4).withOpacity(
                      0.3 + (_animations[index].value * 0.7),
                    ),
                    const Color(0xFF4ECDC4).withOpacity(
                      0.5 + (_animations[index].value * 0.5),
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(
                      _animations[index].value * 0.4,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

// ============ INTERACTIVE ONBOARDING PAGE ============

class InteractiveOnboardingPage extends StatefulWidget {
  final VoidCallback onComplete;

  const InteractiveOnboardingPage({
    super.key,
    required this.onComplete,
  });

  @override
  State<InteractiveOnboardingPage> createState() =>
      _InteractiveOnboardingPageState();
}

class _InteractiveOnboardingPageState extends State<InteractiveOnboardingPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _floatingController;
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Bem-vindo ao PetVerse! 🐾',
      subtitle: 'O mundo mais fofo de cuidado virtual de pets',
      description:
          'Aqui você pode adotar, cuidar e compartilhar momentos especiais com pets virtuais adoráveis.',
      emoji: '🌟',
      backgroundColor: const Color(0xFF4ECDC4),
      interactionType: OnboardingInteraction.floating,
    ),
    OnboardingStep(
      title: 'Adoção Colaborativa 🤝',
      subtitle: 'Cuidem juntos de um pet especial',
      description:
          'Você pode escolher até 3 pets e aguardar outro cuidador se interessar. Assim vocês dividem a responsabilidade!',
      emoji: '👥',
      backgroundColor: const Color(0xFF5D9CEC),
      interactionType: OnboardingInteraction.swipeCards,
    ),
    OnboardingStep(
      title: 'Missões Diárias 🎯',
      subtitle: 'Complete desafios e ganhe recompensas',
      description:
          'Alimente, brinque, cuide da higiene e complete missões para ganhar moedas e experiência.',
      emoji: '🏆',
      backgroundColor: const Color(0xFFFF6B9D),
      interactionType: OnboardingInteraction.tapToComplete,
    ),
    OnboardingStep(
      title: 'Sua Jornada Começa! 🚀',
      subtitle: 'Pronto para seu primeiro pet?',
      description:
          'Agora você está pronto para começar sua jornada no PetVerse. Vamos encontrar seu primeiro companheiro!',
      emoji: '✨',
      backgroundColor: const Color(0xFFFFD93D),
      interactionType: OnboardingInteraction.celebration,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _nextPage() {
    AppUtils.lightImpact();

    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _steps[_currentPage].backgroundColor.withOpacity(0.1),
              _steps[_currentPage].backgroundColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header com progresso
              _buildProgressHeader(),

              // Conteúdo principal
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    AppUtils.lightImpact();
                  },
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return _buildStepContent(_steps[index]);
                  },
                ),
              ),

              // Footer com navegação
              _buildNavigationFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Barra de progresso personalizada
          Row(
            children: List.generate(_steps.length, (index) {
              final isActive = index <= _currentPage;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? LinearGradient(
                            colors: [
                              _steps[_currentPage].backgroundColor,
                              _steps[_currentPage]
                                  .backgroundColor
                                  .withOpacity(0.7),
                            ],
                          )
                        : null,
                    color: isActive ? null : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: _steps[_currentPage]
                                  .backgroundColor
                                  .withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              ).animate(target: isActive ? 1 : 0).scaleX(
                    begin: 0.3,
                    end: 1.0,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  );
            }),
          ),

          const SizedBox(height: 16),

          // Contador de páginas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _steps[_currentPage].backgroundColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentPage + 1} de ${_steps.length}',
              style: TextStyle(
                fontSize: 14,
                color: _steps[_currentPage].backgroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(OnboardingStep step) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Animação principal baseada no tipo
          _buildMainAnimation(step),

          const SizedBox(height: 40),

          // Título
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
              height: 1.1,
              letterSpacing: -0.5,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideY(begin: 30, end: 0),

          const SizedBox(height: 16),

          // Subtítulo
          Text(
            step.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: step.backgroundColor,
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 20, end: 0),

          const SizedBox(height: 24),

          // Descrição
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              height: 1.6,
            ),
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .slideY(begin: 20, end: 0),

          const Spacer(),

          // Dica de interação
          _buildInteractionHint(step),
        ],
      ),
    );
  }

  Widget _buildMainAnimation(OnboardingStep step) {
    switch (step.interactionType) {
      case OnboardingInteraction.floating:
        return AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _floatingController.value * 20),
              child: _buildEmojiContainer(step),
            );
          },
        );

      case OnboardingInteraction.swipeCards:
        return _buildSwipeCardsDemo(step);

      case OnboardingInteraction.tapToComplete:
        return _buildTapDemo(step);

      case OnboardingInteraction.celebration:
        return _buildCelebrationAnimation(step);
    }
  }

  Widget _buildEmojiContainer(OnboardingStep step) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            step.backgroundColor.withOpacity(0.25),
            step.backgroundColor.withOpacity(0.15),
            step.backgroundColor.withOpacity(0.05),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: step.backgroundColor.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Center(
        child: Text(
          step.emoji,
          style: const TextStyle(fontSize: 70),
        ),
      ),
    )
        .animate()
        .scale(
            begin: const Offset(0.5, 0.5),
            duration: 800.ms,
            curve: Curves.elasticOut)
        .then()
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5));
  }

  Widget _buildSwipeCardsDemo(OnboardingStep step) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: List.generate(3, (index) {
          return Positioned(
            left: 30 + (index * 12),
            top: index * 6.0,
            child: Container(
              width: 140,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    step.backgroundColor.withOpacity(0.9 - (index * 0.2)),
                    step.backgroundColor.withOpacity(0.7 - (index * 0.2)),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: step.backgroundColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: Offset(0, 6 + index * 3.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ['🐱', '🐶', '🐰'][index],
                    style: const TextStyle(fontSize: 50),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ['Mimi', 'Rex', 'Luna'][index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: index * 200))
              .fadeIn(duration: 500.ms)
              .slideX(begin: 100, end: 0)
              .then(delay: 1000.ms)
              .animate(onPlay: (controller) => controller.repeat())
              .moveX(begin: 0, end: 8, duration: 3000.ms)
              .then()
              .moveX(begin: 8, end: 0, duration: 3000.ms);
        }),
      ),
    );
  }

  Widget _buildTapDemo(OnboardingStep step) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                step.backgroundColor.withOpacity(0.3),
                step.backgroundColor.withOpacity(0.1),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.emoji,
              style: const TextStyle(fontSize: 60),
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.15, 1.15),
              duration: 1200.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.15, 1.15),
              end: const Offset(1.0, 1.0),
              duration: 1200.ms,
            ),
        const SizedBox(height: 24),
        Text(
          'Toque para interagir!',
          style: TextStyle(
            fontSize: 16,
            color: step.backgroundColor,
            fontWeight: FontWeight.w600,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .fadeIn(duration: 1000.ms)
            .then()
            .fadeOut(duration: 1000.ms),
      ],
    );
  }

  Widget _buildCelebrationAnimation(OnboardingStep step) {
    return Stack(
      children: [
        // Confetti particles
        ...List.generate(12, (index) {
          return Positioned(
            left: 20 + (index * 25),
            top: 30,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: [
                  step.backgroundColor,
                  Colors.pink,
                  Colors.blue,
                  Colors.green,
                ][index % 4],
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .moveY(begin: 0, end: 250, duration: 2500.ms)
                .fadeOut(begin: 1, duration: 300.ms),
          );
        }),

        // Main emoji
        Center(
          child: _buildEmojiContainer(step),
        ),
      ],
    );
  }

  Widget _buildInteractionHint(OnboardingStep step) {
    if (_currentPage == _steps.length - 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.swipe,
          color: step.backgroundColor.withOpacity(0.7),
          size: 22,
        ),
        const SizedBox(width: 8),
        Text(
          'Deslize para continuar',
          style: TextStyle(
            fontSize: 14,
            color: step.backgroundColor.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 1200.ms)
        .then()
        .fadeOut(duration: 1200.ms);
  }

  Widget _buildNavigationFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Botão voltar
          if (_currentPage > 0)
            GestureDetector(
              onTap: () {
                AppUtils.lightImpact();
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            )
          else
            const SizedBox(width: 44),

          const Spacer(),

          // Indicadores de página (dots)
          Row(
            children: List.generate(_steps.length, (index) {
              final isActive = index == _currentPage;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: isActive ? 24 : 10,
                height: 10,
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(
                          colors: [
                            _steps[_currentPage].backgroundColor,
                            _steps[_currentPage]
                                .backgroundColor
                                .withOpacity(0.7),
                          ],
                        )
                      : null,
                  color: isActive ? null : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
              ).animate(target: isActive ? 1 : 0).scaleX(duration: 300.ms);
            }),
          ),

          const Spacer(),

          // Botão próximo/finalizar
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _steps[_currentPage].backgroundColor,
                    _steps[_currentPage].backgroundColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color:
                        _steps[_currentPage].backgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentPage == _steps.length - 1 ? 'Começar!' : 'Próximo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_currentPage == _steps.length - 1) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.rocket_launch,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String subtitle;
  final String description;
  final String emoji;
  final Color backgroundColor;
  final OnboardingInteraction interactionType;

  OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.emoji,
    required this.backgroundColor,
    required this.interactionType,
  });
}

enum OnboardingInteraction {
  floating,
  swipeCards,
  tapToComplete,
  celebration,
}
