// File: lib/presentation/screens/home/pet/enhanced_pet_screen.dart

/// Enhanced Pet care screen with improved UX/UI
// File: lib/presentation/screens/home/pet/enhanced_pet_screen.dart

// Required imports for math
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/presentation/providers/pet_provider.dart';
import 'package:petverse/presentation/widgets/animations/bounce_animation.dart';

/// Enhanced Pet care screen with gaming-focused UX/UI design
class EnhancedPetScreen extends ConsumerStatefulWidget {
  const EnhancedPetScreen({super.key});

  @override
  ConsumerState<EnhancedPetScreen> createState() => _EnhancedPetScreenState();
}

class _EnhancedPetScreenState extends ConsumerState<EnhancedPetScreen>
    with TickerProviderStateMixin {
  late AnimationController _petInteractionController;
  late AnimationController _heartController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late Animation<double> _heartAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    _initGameAnimations();
    _startIdleAnimations();
  }

  void _initGameAnimations() {
    // Pet interaction feedback
    _petInteractionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Heart burst animation
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Idle breathing pulse
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Environmental sparkles
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _heartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.linear),
    );
  }

  void _startIdleAnimations() {
    _pulseController.repeat(reverse: true);
    _sparkleController.repeat();
  }

  @override
  void dispose() {
    _petInteractionController.dispose();
    _heartController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petGameState = ref.watch(petGameProvider);

    if (!petGameState.hasCurrentPet) {
      return _buildGameOnboardingState(context, ref);
    }

    final pet = petGameState.currentPet!;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1B2E), // Gaming dark theme
      body: Stack(
        children: [
          // Animated background
          _buildGameBackground(),

          // Main content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero pet section
              SliverToBoxAdapter(
                child: _buildHeroPetSection(context, pet),
              ),

              // Gaming HUD overlay
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -40),
                  child: _buildGameHUD(context, pet),
                ),
              ),

              // Action buttons in floating cards
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildQuickActions(context, pet, ref),
                    const SizedBox(height: 16),
                    _buildProgressCard(context, pet),
                    const SizedBox(height: 16),
                    _buildDailyMissions(context, pet),
                    const SizedBox(height: 100), // Bottom padding for floating nav
                  ]),
                ),
              ),
            ],
          ),

          // Floating particles overlay
          _buildParticleOverlay(),
        ],
      ),
    );
  }

  Widget _buildGameBackground() {
    return AnimatedBuilder(
      animation: _sparkleController,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [
                Color(0xFF2D1B69),
                Color(0xFF1A1B2E),
                Color(0xFF0F0F23),
              ],
            ),
          ),
          child: CustomPaint(
            painter: StarfieldPainter(_sparkleAnimation.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildHeroPetSection(BuildContext context, pet) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: Stack(
        children: [
          // Pet avatar with gaming aura
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: AnimatedBuilder(
                animation: Listenable.merge([_pulseAnimation, _petInteractionController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value * (1.0 + (_petInteractionController.value * 0.15)),
                    child: GestureDetector(
                      onTap: () => _triggerPetInteraction(pet),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _getPetAuraColor(pet).withOpacity(0.4),
                              _getPetAuraColor(pet).withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getPetAuraColor(pet).withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '🐱', // pet.emoji
                                style: const TextStyle(fontSize: 80),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Floating heart burst
          _buildHeartBurst(),

          // Pet name with gaming typography
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getPetAuraColor(pet).withOpacity(0.8),
                        _getPetAuraColor(pet).withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getPetAuraColor(pet).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getPetAuraColor(pet).withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'LVL ${pet.level} • ${pet.type.toUpperCase()}',
                    style: TextStyle(
                      color: _getPetAuraColor(pet),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Status indicator with gaming style
          Positioned(
            top: 50,
            right: 20,
            child: _buildGameStatusIndicator(pet),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartBurst() {
    return AnimatedBuilder(
      animation: _heartAnimation,
      builder: (context, child) {
        if (_heartAnimation.value == 0) return const SizedBox.shrink();

        return Positioned.fill(
          child: Stack(
            children: List.generate(5, (index) {
              final angle = (index * 72) * 3.14159 / 180;
              final distance = _heartAnimation.value * 80;
              final x = MediaQuery.of(context).size.width / 2 + (distance * math.cos(angle));
              final y = MediaQuery.of(context).size.height * 0.3 + (distance * math.sin(angle));

              return Positioned(
                left: x - 20,
                top: y - 20,
                child: Transform.scale(
                  scale: _heartAnimation.value * (1.5 - index * 0.2),
                  child: Opacity(
                    opacity: 1.0 - _heartAnimation.value,
                    child: Text(
                      ['💖', '✨', '💕', '⭐', '💝'][index],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildGameHUD(BuildContext context, pet) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.black.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _getPetAuraColor(pet).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildStatBar(
                    'Hunger', pet.hunger, const Color(0xFFFF6B6B), Icons.restaurant, '🍖'),
                const SizedBox(height: 16),
                _buildStatBar('Happiness', pet.happiness, const Color(0xFF4ECDC4),
                    Icons.sentiment_very_satisfied, '😊'),
                const SizedBox(height: 16),
                _buildStatBar('Energy', pet.energy, const Color(0xFF45B7D1), Icons.flash_on, '⚡'),
                const SizedBox(height: 16),
                _buildStatBar('Health', pet.health, const Color(0xFF96CEB4), Icons.favorite, '❤️'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, int value, Color color, IconData icon, String emoji) {
    final percentage = value / 100;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$value%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  widthFactor: percentage,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.6),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, pet, WidgetRef ref) {
    final actions = [
      {
        'title': 'FEED',
        'subtitle': 'Give treats',
        'icon': '🍖',
        'color': const Color(0xFFFF6B6B),
        'action': () => _performGameAction('feed', pet, ref),
        'enabled': pet.hunger < 90,
        'cooldown': false,
      },
      {
        'title': 'PLAY',
        'subtitle': 'Have fun',
        'icon': '🎾',
        'color': const Color(0xFF4ECDC4),
        'action': () => _performGameAction('play', pet, ref),
        'enabled': pet.energy > 20,
        'cooldown': false,
      },
      {
        'title': 'REST',
        'subtitle': 'Restore energy',
        'icon': '💤',
        'color': const Color(0xFF45B7D1),
        'action': () => _performGameAction('rest', pet, ref),
        'enabled': pet.energy < 90,
        'cooldown': false,
      },
      {
        'title': 'HEAL',
        'subtitle': 'Use medicine',
        'icon': '💊',
        'color': const Color(0xFF96CEB4),
        'action': () => _performGameAction('medicine', pet, ref),
        'enabled': pet.health < 80,
        'cooldown': false,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildGameActionButton(
          action['title'] as String,
          action['subtitle'] as String,
          action['icon'] as String,
          action['color'] as Color,
          action['action'] as VoidCallback,
          action['enabled'] as bool,
        );
      },
    );
  }

  Widget _buildGameActionButton(
    String title,
    String subtitle,
    String icon,
    Color color,
    VoidCallback onTap,
    bool enabled,
  ) {
    return BounceAnimation(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.8),
                      color.withOpacity(0.6),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.3),
                      Colors.grey.withOpacity(0.2),
                    ],
                  ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
            border: Border.all(
              color: enabled ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: enabled ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: enabled ? Colors.white.withOpacity(0.8) : Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, pet) {
    final currentLevelXp = pet.xp % 100;
    final nextLevel = pet.level + 1;
    final mood = _calculateMood(pet);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: mood['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Mood section
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MOOD',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      mood['emoji'],
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mood['status'],
                            style: TextStyle(
                              color: mood['color'],
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            mood['description'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: Colors.white.withOpacity(0.2),
          ),
          // XP Progress section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NEXT LEVEL',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LEVEL $nextLevel',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: currentLevelXp / 100,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$currentLevelXp/100 XP',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMissions(BuildContext context, pet) {
    final missions = [
      {'task': 'Feed your pet', 'completed': pet.hunger > 70, 'reward': '10 XP', 'icon': '🍖'},
      {'task': 'Play together', 'completed': pet.happiness > 70, 'reward': '15 XP', 'icon': '🎾'},
      {'task': 'Rest well', 'completed': pet.energy > 50, 'reward': '5 XP', 'icon': '💤'},
      {'task': 'Stay healthy', 'completed': pet.health > 80, 'reward': '20 XP', 'icon': '❤️'},
    ];

    final completedMissions = missions.where((mission) => mission['completed'] == true).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🎯', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'DAILY MISSIONS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$completedMissions/${missions.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...missions.map((mission) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: mission['completed'] as bool
                            ? const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)])
                            : LinearGradient(colors: [
                                Colors.grey.withOpacity(0.3),
                                Colors.grey.withOpacity(0.2)
                              ]),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        mission['completed'] as bool ? Icons.check : Icons.radio_button_unchecked,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      mission['icon'] as String,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mission['task'] as String,
                        style: TextStyle(
                          color: mission['completed'] as bool
                              ? Colors.white.withOpacity(0.6)
                              : Colors.white,
                          decoration:
                              mission['completed'] as bool ? TextDecoration.lineThrough : null,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: mission['completed'] as bool
                            ? const Color(0xFF4ECDC4).withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        mission['reward'] as String,
                        style: TextStyle(
                          color: mission['completed'] as bool
                              ? const Color(0xFF4ECDC4)
                              : Colors.white.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGameStatusIndicator(pet) {
    final status = _calculateOverallStatus(pet);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            status['color'],
            status['color'].withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: status['color'].withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status['emoji'],
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            status['text'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticleOverlay() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _sparkleController,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(_sparkleAnimation.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildGameOnboardingState(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B2E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFF2D1B69),
              Color(0xFF1A1B2E),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF8B5CF6),
                        Color(0xFF3B82F6),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '🐾',
                      style: TextStyle(fontSize: 64),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'READY TO ADOPT?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF6366F1).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Begin your epic pet care adventure\nand create an unbreakable bond',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    // Navigate to pet adoption
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Text(
                      'START ADVENTURE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Gaming helper methods

  Color _getPetAuraColor(pet) {
    switch (pet.type.toLowerCase()) {
      case 'cat':
        return const Color(0xFFFF6B9D);
      case 'dog':
        return const Color(0xFF4ECDC4);
      case 'bird':
        return const Color(0xFF45B7D1);
      default:
        return const Color(0xFF6366F1);
    }
  }

  Map<String, dynamic> _calculateMood(pet) {
    final avgStats = (pet.happiness + pet.hunger + pet.energy + pet.health) / 4;

    if (avgStats >= 85) {
      return {
        'status': 'LEGENDARY',
        'emoji': '🌟',
        'color': const Color(0xFFFFD700),
        'description': 'Your pet is at peak performance!',
      };
    } else if (avgStats >= 70) {
      return {
        'status': 'EXCELLENT',
        'emoji': '😍',
        'color': const Color(0xFF4ECDC4),
        'description': 'Amazing condition!',
      };
    } else if (avgStats >= 50) {
      return {
        'status': 'GOOD',
        'emoji': '😊',
        'color': const Color(0xFF96CEB4),
        'description': 'Doing well.',
      };
    } else if (avgStats >= 30) {
      return {
        'status': 'FAIR',
        'emoji': '😐',
        'color': const Color(0xFFFFA726),
        'description': 'Needs attention.',
      };
    } else {
      return {
        'status': 'CRITICAL',
        'emoji': '😰',
        'color': const Color(0xFFFF6B6B),
        'description': 'Immediate care required!',
      };
    }
  }

  Map<String, dynamic> _calculateOverallStatus(pet) {
    final criticalStats = [pet.hunger, pet.happiness, pet.energy, pet.health];
    final minStat = criticalStats.reduce((a, b) => a < b ? a : b);

    if (minStat < 20) {
      return {'emoji': '🆘', 'text': 'CRITICAL', 'color': const Color(0xFFFF6B6B)};
    } else if (minStat < 50) {
      return {'emoji': '⚠️', 'text': 'WARNING', 'color': const Color(0xFFFFA726)};
    } else if (minStat < 80) {
      return {'emoji': '✅', 'text': 'STABLE', 'color': const Color(0xFF4ECDC4)};
    } else {
      return {'emoji': '⭐', 'text': 'PERFECT', 'color': const Color(0xFFFFD700)};
    }
  }

  void _triggerPetInteraction(pet) {
    HapticFeedback.mediumImpact();

    // Trigger multiple animation sequences
    _petInteractionController.forward().then((_) {
      _petInteractionController.reverse();
    });

    _heartController.forward().then((_) {
      _heartController.reset();
    });

    // Gaming feedback with XP gain
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('💖'),
            const SizedBox(width: 8),
            Expanded(child: Text('${pet.name} gained +5 XP from your love!')),
            const Text('✨'),
          ],
        ),
        backgroundColor: _getPetAuraColor(pet),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _performGameAction(String action, pet, WidgetRef ref) {
    HapticFeedback.lightImpact();

    // Here you would call the actual pet care methods with XP rewards
    // ref.read(petGameProvider.notifier).performAction(action);

    final rewards = {
      'feed': {'message': '${pet.name} devoured the food!', 'xp': 10, 'emoji': '🍖'},
      'play': {'message': '${pet.name} had an amazing time!', 'xp': 15, 'emoji': '🎾'},
      'rest': {'message': '${pet.name} feels recharged!', 'xp': 5, 'emoji': '💤'},
      'medicine': {'message': '${pet.name} is healing rapidly!', 'xp': 20, 'emoji': '💊'},
    };

    final reward = rewards[action]!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(reward['emoji'] as String),
            const SizedBox(width: 8),
            Expanded(child: Text(reward['message'] as String)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${reward['xp']} XP',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: _getPetAuraColor(pet),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Gaming-focused custom painters

class StarfieldPainter extends CustomPainter {
  final double animationValue;

  StarfieldPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Animate twinkling stars
    for (int i = 0; i < 50; i++) {
      final x = (i * 47.3) % size.width;
      final y = (i * 73.7) % size.height;
      final opacity = (math.sin(animationValue * 6.28 + i) + 1) / 2;

      paint.color = Colors.white.withOpacity(opacity * 0.4);
      canvas.drawCircle(Offset(x, y), 1.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Floating magical particles
    for (int i = 0; i < 20; i++) {
      final x = (i * 67.3) % size.width;
      final baseY = (i * 91.7) % size.height;
      final y = baseY + (math.sin(animationValue * 2 + i) * 20);
      final opacity = (math.cos(animationValue * 3 + i * 2) + 1) / 2;

      paint.color = const Color(0xFF6366F1).withOpacity(opacity * 0.2);
      canvas.drawCircle(Offset(x, y), 2.0 + opacity, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
