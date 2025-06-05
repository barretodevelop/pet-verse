// lib/src/features/onboarding/presentation/screens/adoption_onboarding_screen.dart
// NOVA INCLUSÃO - Tutorial interativo para o sistema de adoção colaborativa

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/src/core/navigation/app_routes.dart';
import 'package:petverse/src/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider para controlar se o onboarding já foi visto
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('has_seen_adoption_onboarding') ?? false;
});

class AdoptionOnboardingScreen extends ConsumerStatefulWidget {
  const AdoptionOnboardingScreen({super.key});

  @override
  ConsumerState<AdoptionOnboardingScreen> createState() =>
      _AdoptionOnboardingScreenState();
}

class _AdoptionOnboardingScreenState
    extends ConsumerState<AdoptionOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late AnimationController _backgroundController;

  int _currentStep = 0;
  final int _totalSteps = 4;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: '🐾 Bem-vindo ao PetVerse!',
      description:
          'Descubra um novo jeito de cuidar de pets virtuais com amigos de forma anônima.',
      icon: Icons.pets,
      detailedText:
          'No PetVerse, você não cuida de pets sozinho. Encontre parceiros para uma experiência colaborativa única!',
    ),
    OnboardingStep(
      title: '🤝 Adoção Colaborativa',
      description:
          'Escolha 3 pets e encontre alguém para cuidar junto com você.',
      icon: Icons.group,
      detailedText:
          'Selecione até 3 pets que gostaria de adotar. Outro usuário escolherá um deles e vocês cuidarão juntos!',
    ),
    OnboardingStep(
      title: '🎭 Totalmente Anônimo',
      description:
          'Cuide dos pets sem revelar sua identidade. Apenas diversão pura!',
      icon: Icons.visibility_off,
      detailedText:
          'Sua privacidade está protegida. Interaja através de ações no pet, sem exposição pessoal.',
    ),
    OnboardingStep(
      title: '🚀 Vamos Começar!',
      description:
          'Está pronto para encontrar seu primeiro parceiro de cuidados?',
      icon: Icons.rocket_launch,
      detailedText:
          'Hora de mergulhar na experiência! Vamos encontrar pets incríveis esperando por cuidadores.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Start background animation
    _backgroundController.repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressController.animateTo(_currentStep / (_totalSteps - 1));
      HapticFeedback.lightImpact();
    } else {
      _finishOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _progressController.animateTo(_currentStep / (_totalSteps - 1));
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _finishOnboarding() async {
    HapticFeedback.mediumImpact();

    // Mark onboarding as seen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_adoption_onboarding', true);

    // Navigate to adoption screen
    if (mounted) {
      context.go(AppRoutes.adoptionInitial);
    }
  }

  void _skipOnboarding() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pular Tutorial?'),
        content: const Text(
            'Tem certeza que deseja pular? O tutorial ajuda a entender melhor como funciona a adoção colaborativa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _finishOnboarding();
            },
            child: const Text('Sim, pular'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryPurple.withOpacity(0.1),
              theme.scaffoldBackgroundColor,
              AppColors.primaryPurple.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with progress
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Passo ${_currentStep + 1} de $_totalSteps',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: _skipOnboarding,
                          child: Text(
                            'Pular',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: theme.dividerColor.withOpacity(0.3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (_currentStep + 1) / _totalSteps,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryPurple,
                                    AppColors.primaryPurple.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                    _progressController.animateTo(index / (_totalSteps - 1));
                  },
                  itemCount: _totalSteps,
                  itemBuilder: (context, index) {
                    final step = _steps[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon with animation
                          AnimatedBuilder(
                            animation: _backgroundController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 +
                                    (0.1 *
                                        (1 +
                                            (_backgroundController.value * 2 -
                                                    1)
                                                .abs())),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.primaryPurple
                                            .withOpacity(0.2),
                                        AppColors.primaryPurple
                                            .withOpacity(0.05),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    step.icon,
                                    size: 48,
                                    color: AppColors.primaryPurple,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 40),

                          // Title
                          Text(
                            step.title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPurple,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          // Description
                          Text(
                            step.description,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          // Detailed text
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: theme.cardColor,
                              border: Border.all(
                                color: AppColors.primaryPurple.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              step.detailedText,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(
                                color: AppColors.primaryPurple),
                          ),
                          child: const Text('Anterior'),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: _currentStep == 0 ? 1 : 1,
                      child: ElevatedButton(
                        onPressed: _nextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentStep == _totalSteps - 1
                              ? 'Começar!'
                              : 'Próximo',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final String detailedText;
  final IconData icon;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.detailedText,
    required this.icon,
  });
}
