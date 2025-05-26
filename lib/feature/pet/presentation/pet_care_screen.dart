// lib/features/pet/pages/pet_care_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/feature/pet/model/pet.dart';
import 'package:petverse/feature/pet/provider/pet_provider.dart';
import 'package:petverse/feature/pet/widgets/care_button.dart';
import 'package:petverse/feature/pet/widgets/floating_emoji.dart';
import 'package:petverse/feature/pet/widgets/pet_avatar.dart';
import 'package:petverse/feature/pet/widgets/status_bar.dart';

class PetCarePage extends ConsumerStatefulWidget {
  const PetCarePage({super.key});

  @override
  ConsumerState<PetCarePage> createState() => _PetCarePageState();
}

class _PetCarePageState extends ConsumerState<PetCarePage>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _floatingController;

  final List<FloatingEmoji> _floatingEmojis = [];
  final bool _isDraggingFood = false;
  final bool _isDraggingToy = false;
  final bool _isDraggingShower = false;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _showFloatingEmoji(String emoji, Offset position) {
    final newEmoji = FloatingEmoji(
      emoji: emoji,
      position: position,
      key: UniqueKey(),
    );

    setState(() {
      _floatingEmojis.add(newEmoji);
    });

    // Remover após animação
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _floatingEmojis.removeWhere((e) => e.key == newEmoji.key);
        });
      }
    });
  }

  Future<void> _feedPet() async {
    final offset = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );

    _showFloatingEmoji('🍖', offset);
    await ref.read(petControllerProvider.notifier).feedPet();

    // Vibração suave (adicionar haptic_feedback no pubspec)
    // HapticFeedback.lightImpact();
  }

  Future<void> _playWithPet() async {
    final offset = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );

    _showFloatingEmoji('🎾', offset);
    await ref.read(petControllerProvider.notifier).playWithPet();
  }

  Future<void> _cleanPet() async {
    final offset = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );

    _showFloatingEmoji('🫧', offset);
    await ref.read(petControllerProvider.notifier).cleanPet();
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petStreamProvider);
    final theme = Theme.of(context);

    return petState.when(
      data: (pet) {
        if (pet == null) {
          return const Center(
            child: Text('Nenhum pet encontrado'),
          );
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _getBackgroundColorForMood(pet.mood).withOpacity(0.3),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Decoração de fundo animada
                  ..._buildBackgroundDecorations(),

                  // Conteúdo principal
                  Column(
                    children: [
                      // Header com nome do pet
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pet.name,
                                  style:
                                      theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Nível ${_calculateLevel(pet)}',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getMoodColor(pet.mood),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                pet.status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0),

                      // Pet Avatar
                      Expanded(
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Sombra animada
                              Container(
                                width: 200,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              )
                                  .animate(
                                    onPlay: (controller) =>
                                        controller.repeat(reverse: true),
                                  )
                                  .scaleX(
                                      begin: 0.8, end: 1.0, duration: 3.seconds)
                                  .fade(begin: 0.3, end: 0.5),

                              // Pet com animação de respiração
                              AnimatedBuilder(
                                animation: _breathingController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 1.0 +
                                        (_breathingController.value * 0.05),
                                    child: PetAvatar(
                                      pet: pet,
                                      size: 250,
                                    ),
                                  );
                                },
                              ),

                              // Indicadores de status ao redor do pet
                              ..._buildStatusIndicators(pet),
                            ],
                          ),
                        ),
                      ),

                      // Barras de Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            StatusBar(
                              label: 'Fome',
                              value: pet.hunger,
                              color: Colors.orange,
                              icon: Icons.restaurant,
                            ),
                            const SizedBox(height: 12),
                            StatusBar(
                              label: 'Felicidade',
                              value: pet.happiness,
                              color: Colors.pink,
                              icon: Icons.favorite,
                            ),
                            const SizedBox(height: 12),
                            StatusBar(
                              label: 'Limpeza',
                              value: pet.cleanliness,
                              color: Colors.blue,
                              icon: Icons.water_drop,
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .slideY(begin: 0.2, end: 0),

                      // Botões de Ação
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CareButton(
                              icon: Icons.restaurant,
                              label: 'Alimentar',
                              color: Colors.orange,
                              onTap: _feedPet,
                              isDisabled: pet.hunger > 80,
                            ),
                            CareButton(
                              icon: Icons.sports_baseball,
                              label: 'Brincar',
                              color: Colors.pink,
                              onTap: _playWithPet,
                              isDisabled: pet.happiness > 80,
                            ),
                            CareButton(
                              icon: Icons.bathtub,
                              label: 'Banho',
                              color: Colors.blue,
                              onTap: _cleanPet,
                              isDisabled: pet.cleanliness > 80,
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideY(begin: 0.3, end: 0),
                    ],
                  ),

                  // Emojis flutuantes
                  ..._floatingEmojis,
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Erro: $error')),
    );
  }

  List<Widget> _buildBackgroundDecorations() {
    return [
      // Nuvens flutuantes
      Positioned(
        top: 50,
        left: -50,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_floatingController.value * 30, 0),
              child: Container(
                width: 100,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            );
          },
        ),
      ),
      Positioned(
        top: 100,
        right: -30,
        child: AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(-_floatingController.value * 20, 0),
              child: Container(
                width: 80,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  List<Widget> _buildStatusIndicators(Pet pet) {
    final indicators = <Widget>[];

    if (pet.isHungry) {
      indicators.add(
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant,
              color: Colors.white,
              size: 20,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(
                  begin: const Offset(0.8, 0),
                  end: const Offset(1.2, 0),
                  duration: 1.seconds)
              .then()
              .scale(
                  begin: const Offset(1.2, 0),
                  end: const Offset(0.8, 0),
                  duration: 1.seconds),
        ),
      );
    }

    if (pet.isSad) {
      indicators.add(
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.pink,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sports_baseball,
              color: Colors.white,
              size: 20,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shake(hz: 3, duration: 1.seconds)
              .then(delay: 1.seconds),
        ),
      );
    }

    if (pet.isDirty) {
      indicators.add(
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.water_drop,
              color: Colors.white,
              size: 20,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 2.seconds),
        ),
      );
    }

    return indicators;
  }

  Color _getBackgroundColorForMood(String mood) {
    switch (mood) {
      case 'sleepy':
        return Colors.indigo;
      case 'energetic':
        return Colors.orange;
      case 'playful':
        return Colors.pink;
      default:
        return Colors.purple;
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'sleepy':
        return Colors.indigo;
      case 'energetic':
        return Colors.orange;
      case 'playful':
        return Colors.pink;
      default:
        return Colors.purple;
    }
  }

  int _calculateLevel(Pet pet) {
    // Lógica simples de nível baseada em interações
    final totalInteractions =
        (100 - pet.hunger) + pet.happiness + pet.cleanliness;
    return (totalInteractions / 100).floor() + 1;
  }
}
