// lib/core/onboarding/interactive_onboarding.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Barra de progresso personalizada
          Row(
            children: List.generate(_steps.length, (index) {
              final isActive = index <= _currentPage;
              final isCurrent = index == _currentPage;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 4,
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ).animate(target: isActive ? 1 : 0).scaleX(
                    begin: 0.3,
                    end: 1.0,
                    duration: 300.ms,
                    curve: Curves.easeOutCubic,
                  );
            }),
          ),

          const SizedBox(height: 12),

          // Contador de páginas
          Text(
            '${_currentPage + 1} de ${_steps.length}',
            style: TextStyle(
              fontSize: 14,
              color: _steps[_currentPage].backgroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(OnboardingStep step) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Animação principal baseada no tipo
          _buildMainAnimation(step),

          const SizedBox(height: 40),

          // Título
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3748),
              height: 1.2,
            ),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 600.ms)
              .slideY(begin: 30, end: 0),

          const SizedBox(height: 12),

          // Subtítulo
          Text(
            step.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: step.backgroundColor,
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 20, end: 0),

          const SizedBox(height: 20),

          // Descrição
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
              height: 1.5,
            ),
          )
              .animate()
              .fadeIn(delay: 600.ms, duration: 600.ms)
              .slideY(begin: 20, end: 0),

          const Spacer(),

          // Interação específica do step
          _buildStepInteraction(step),
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
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            step.backgroundColor.withOpacity(0.2),
            step.backgroundColor.withOpacity(0.1),
            step.backgroundColor.withOpacity(0.05),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: step.backgroundColor.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Text(
          step.emoji,
          style: const TextStyle(fontSize: 60),
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
      height: 180,
      child: Stack(
        children: List.generate(3, (index) {
          return Positioned(
            left: 20 + (index * 8),
            top: index * 4.0,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    step.backgroundColor.withOpacity(0.8 - (index * 0.2)),
                    step.backgroundColor.withOpacity(0.6 - (index * 0.2)),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: step.backgroundColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4 + index * 2.0),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ['🐱', '🐶', '🐰'][index],
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ['Mimi', 'Rex', 'Luna'][index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
              .moveX(begin: 0, end: 5, duration: 2000.ms)
              .then()
              .moveX(begin: 5, end: 0, duration: 2000.ms);
        }),
      ),
    );
  }

  Widget _buildTapDemo(OnboardingStep step) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
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
              style: const TextStyle(fontSize: 50),
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.1, 1.1),
              duration: 1000.ms,
            )
            .then()
            .scale(
              begin: const Offset(1.1, 1.1),
              end: const Offset(1.0, 1.0),
              duration: 1000.ms,
            ),
        const SizedBox(height: 20),
        Text(
          'Toque para interagir!',
          style: TextStyle(
            fontSize: 14,
            color: step.backgroundColor,
            fontWeight: FontWeight.w500,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .fadeIn(duration: 800.ms)
            .then()
            .fadeOut(duration: 800.ms),
      ],
    );
  }

  Widget _buildCelebrationAnimation(OnboardingStep step) {
    return Stack(
      children: [
        // Confetti particles
        ...List.generate(10, (index) {
          return Positioned(
            left: 20 + (index * 30),
            top: 20,
            child: Container(
              width: 8,
              height: 8,
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
                .moveY(begin: 0, end: 200, duration: 2000.ms)
                .fadeOut(begin: 1, delay: 300.ms),
          );
        }),

        // Main emoji
        Center(
          child: _buildEmojiContainer(step),
        ),
      ],
    );
  }

  Widget _buildStepInteraction(OnboardingStep step) {
    if (_currentPage == _steps.length - 1) {
      // Último step - botão especial
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _nextPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: step.backgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            'Começar Aventura! 🚀',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // Steps normais - dica de swipe ou tap
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.swipe,
          color: step.backgroundColor.withOpacity(0.7),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Deslize para continuar',
          style: TextStyle(
            fontSize: 14,
            color: step.backgroundColor.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(duration: 1000.ms)
        .then()
        .fadeOut(duration: 1000.ms);
  }

  Widget _buildNavigationFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Botão voltar
          if (_currentPage > 0)
            GestureDetector(
              onTap: () {
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
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 20 : 8,
                height: 8,
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
                  borderRadius: BorderRadius.circular(4),
                ),
              ).animate(target: isActive ? 1 : 0).scaleX(duration: 200.ms);
            }),
          ),

          const Spacer(),

          // Botão pular/próximo
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _steps[_currentPage].backgroundColor,
                    _steps[_currentPage].backgroundColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _currentPage == _steps.length - 1 ? 'Finalizar' : 'Próximo',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
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
