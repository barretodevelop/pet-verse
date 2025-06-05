import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';

/// Tela de splash/carregamento inicial do aplicativo
class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;

  const SplashScreen({
    super.key,
    this.onComplete,
    this.duration = const Duration(seconds: 3),
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _progressAnimation;

  final List<String> _loadingMessages = [
    'Preparando o ambiente...',
    'Carregando pets adoráveis...',
    'Configurando a magia...',
    'Quase pronto!',
  ];

  int _currentMessageIndex = 0;
  String _currentMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // Controller para animações do logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Controller para animações do texto
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Controller para a barra de progresso
    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Animações do logo
    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Animações do texto
    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    _textSlideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Animação da barra de progresso
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  void _startLoadingSequence() async {
    // Inicia as animações
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _progressController.forward();

    // Atualiza as mensagens de carregamento
    _updateLoadingMessages();

    // Aguarda o tempo total e chama o callback
    await Future.delayed(widget.duration);
    if (widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  void _updateLoadingMessages() async {
    final messageInterval =
        widget.duration.inMilliseconds ~/ _loadingMessages.length;

    for (int i = 0; i < _loadingMessages.length; i++) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = i;
          _currentMessage = _loadingMessages[i];
        });
      }

      if (i < _loadingMessages.length - 1) {
        await Future.delayed(Duration(milliseconds: messageInterval));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(isLightThemeProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLightTheme
                ? [
                    const Color(0xFF8A05BE),
                    const Color(0xFF4B0082),
                    const Color(0xFF2E0054),
                  ]
                : [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF000000),
                    const Color(0xFF0A0A0A),
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo animado
                _buildAnimatedLogo(),

                const SizedBox(height: 32),

                // Título animado
                _buildAnimatedTitle(),

                const SizedBox(height: 16),

                // Subtítulo
                _buildSubtitle(isLightTheme),

                const Spacer(flex: 3),

                // Seção de carregamento
                _buildLoadingSection(isLightTheme),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói o logo animado
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Transform.rotate(
            angle: _logoRotationAnimation.value * 0.1, // Rotação sutil
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.pets,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Constrói o título animado
  Widget _buildAnimatedTitle() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlideAnimation.value),
          child: Opacity(
            opacity: _textOpacityAnimation.value,
            child: const Text(
              'Pet Adote',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Constrói o subtítulo
  Widget _buildSubtitle(bool isLightTheme) {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlideAnimation.value * 0.5),
          child: Opacity(
            opacity: _textOpacityAnimation.value * 0.8,
            child: Text(
              'Encontre seu companheiro perfeito',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  /// Constrói a seção de carregamento
  Widget _buildLoadingSection(bool isLightTheme) {
    return Column(
      children: [
        // Barra de progresso
        _buildProgressBar(),

        const SizedBox(height: 24),

        // Mensagem de carregamento
        _buildLoadingMessage(),

        const SizedBox(height: 16),

        // Indicador de carregamento circular
        _buildLoadingIndicator(),
      ],
    );
  }

  /// Constrói a barra de progresso
  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            // Barra de progresso
            Container(
              width: double.infinity,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Porcentagem
            Text(
              '${(_progressAnimation.value * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Constrói a mensagem de carregamento
  Widget _buildLoadingMessage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _currentMessage,
        key: ValueKey(_currentMessageIndex),
        style: TextStyle(
          fontSize: 14,
          color: Colors.white.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Constrói o indicador de carregamento
  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }
}

/// Widget simplificado para uso rápido
class SimpleSplashScreen extends StatelessWidget {
  final VoidCallback? onComplete;

  const SimpleSplashScreen({
    super.key,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onComplete: onComplete,
      duration: const Duration(seconds: 2),
    );
  }
}

/// Extensão para facilitar o uso
extension SplashScreenExtensions on Widget {
  /// Envolve o widget com uma tela de splash
  Widget withSplash({
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onComplete,
  }) {
    return SplashScreen(
      duration: duration,
      onComplete: onComplete,
    );
  }
}
