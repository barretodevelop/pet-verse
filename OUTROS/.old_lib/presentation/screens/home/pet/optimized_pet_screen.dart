// File: lib/presentation/screens/home/pet/optimized_pet_screen.dart
// Pet Screen otimizada com layout game-first e sistema de slots dinâmicos

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';
import 'package:petverse/domain/entities/pet_entity.dart';
import 'package:petverse/presentation/providers/auth_provider.dart';
import 'package:petverse/presentation/providers/collaboration_slots_provider.dart';
import 'package:petverse/presentation/providers/collaborative_pet_provider.dart';
import 'package:petverse/presentation/providers/enhanced_pet_provider.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';
import 'package:petverse/presentation/widgets/pet/enhanced_adoption_modal.dart';
import 'package:petverse/presentation/widgets/pet/pet_slot_widget.dart';

class OptimizedPetScreen extends ConsumerStatefulWidget {
  const OptimizedPetScreen({super.key});

  @override
  ConsumerState<OptimizedPetScreen> createState() => _OptimizedPetScreenState();
}

class _OptimizedPetScreenState extends ConsumerState<OptimizedPetScreen>
    with TickerProviderStateMixin {
  late AnimationController _petAnimationController;
  late AnimationController _particleController;
  late AnimationController _backgroundController;

  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeProviders();
  }

  void _setupAnimations() {
    _petAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: 0,
      end: -10,
    ).animate(CurvedAnimation(
      parent: _petAnimationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _petAnimationController,
      curve: Curves.easeInOut,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    _petAnimationController.repeat(reverse: true);
    _backgroundController.repeat();
  }

  void _initializeProviders() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      final userId = authState.firebaseUser?.uid;
      if (userId != null) {
        ref.read(collaborativePetProvider.notifier).initialize(userId);
        ref.read(enhancedPetGameProvider.notifier).loadUserPets(userId);
        _syncSlotsWithPets();
      }
    });
  }

  void _syncSlotsWithPets() {
    final collaborativeState = ref.read(collaborativePetProvider);
    ref.read(collaborationSlotsProvider.notifier).syncWithUserPets(collaborativeState.userPets);
  }

  @override
  void dispose() {
    _petAnimationController.dispose();
    _particleController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slotsState = ref.watch(collaborationSlotsProvider);
    final enhancedState = ref.watch(enhancedPetGameProvider);
    final collaborativeState = ref.watch(collaborativePetProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                final authState = ref.read(authProvider);
                final userId = authState.firebaseUser?.uid;
                if (userId != null) {
                  await ref.read(collaborativePetProvider.notifier).initialize(userId);
                  await ref.read(enhancedPetGameProvider.notifier).loadUserPets(userId);
                  _syncSlotsWithPets();
                }
              },
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context),
                  _buildSlotsSection(slotsState),
                  if (enhancedState.hasSelectedPet) ...[
                    _buildSelectedPetSection(enhancedState.selectedPet!),
                    _buildActionsSection(),
                  ],
                  _buildStatsSection(enhancedState, collaborativeState),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100), // Bottom padding
                  ),
                ],
              ),
            ),
          ),

          // Floating particles
          if (_particleController.isAnimating) _buildFloatingParticles(),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                _backgroundAnimation.value,
                1.0,
              ],
              colors: [
                const Color(0xFF667eea),
                const Color(0xFF764ba2),
                const Color(0xFF667eea),
              ],
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: SlideFadeAnimation(
        duration: const Duration(milliseconds: 500),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🏡 Meus Pets',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cuide bem dos seus companheiros virtuais',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.pets,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotsSection(CollaborationSlotsState slotsState) {
    return SliverToBoxAdapter(
      child: SlideFadeAnimation(
        duration: const Duration(milliseconds: 600),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Slots header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.grid_view,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Slots de Pets (${slotsState.occupiedSlots}/${slotsState.maxSlots})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (slotsState.hasAvailableSlots)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${slotsState.availableSlots}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Slots grid
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: slotsState.slots.length,
                  itemBuilder: (context, index) {
                    final slot = slotsState.slots[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: PetSlotWidget(
                        slot: slot,
                        onTap: () => _handleSlotTap(slot),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedPetSection(dynamic selectedPet) {
    return SliverToBoxAdapter(
      child: SlideFadeAnimation(
        duration: const Duration(milliseconds: 700),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Pet avatar with animation
              AnimatedBuilder(
                animation: _petAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: GestureDetector(
                        onTap: _onPetTap,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _getPetEmoji(selectedPet),
                              style: const TextStyle(fontSize: 60),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Pet name and level
              Text(
                _getPetName(selectedPet),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Level ${_getPetLevel(selectedPet)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return SliverToBoxAdapter(
      child: SlideFadeAnimation(
        duration: const Duration(milliseconds: 800),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildActionButton(
                icon: Icons.restaurant,
                label: 'Alimentar',
                color: Colors.orange,
                onTap: () => _performAction('feed'),
              ),
              _buildActionButton(
                icon: Icons.sports_esports,
                label: 'Brincar',
                color: Colors.green,
                onTap: () => _performAction('play'),
              ),
              _buildActionButton(
                icon: Icons.bed,
                label: 'Descansar',
                color: Colors.blue,
                onTap: () => _performAction('rest'),
              ),
              _buildActionButton(
                icon: Icons.medical_services,
                label: 'Cuidar',
                color: Colors.red,
                onTap: () => _performAction('heal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(dynamic enhancedState, dynamic collaborativeState) {
    return SliverToBoxAdapter(
      child: SlideFadeAnimation(
        duration: const Duration(milliseconds: 900),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 Estatísticas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Pets Totais',
                      '${enhancedState.userPets.length}',
                      Icons.pets,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Colaborativos',
                      '${collaborativeState.userPets.length}',
                      Icons.people,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: ParticlesPainter(_particleController.value),
            ),
          ),
        );
      },
    );
  }

  void _handleSlotTap(CollaborationSlot slot) {
    if (slot.isOccupied && slot.pet != null) {
      // Select pet for interaction
      ref.read(enhancedPetGameProvider.notifier).selectPet(slot.pet!);
    } else if (slot.isAvailable) {
      // Show enhanced adoption modal
      _showEnhancedAdoptionModal();
    } else {
      // Show premium dialog
      _showPremiumDialog();
    }
  }

  void _showEnhancedAdoptionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EnhancedAdoptionModal(),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⭐ Premium Required'),
        content: const Text(
          'Este slot é exclusivo para usuários premium. '
          'Upgrade sua conta para desbloquear mais slots de pets!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to premium upgrade
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: const Text(
              'Upgrade',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _onPetTap() {
    _particleController.forward().then((_) {
      _particleController.reset();
    });

    // Add happiness or interaction effect
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Seu pet ficou feliz!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _performAction(String action) {
    _particleController.forward().then((_) {
      _particleController.reset();
    });

    String message;
    switch (action) {
      case 'feed':
        message = '🍖 Pet alimentado com sucesso!';
        break;
      case 'play':
        message = '🎾 Que brincadeira divertida!';
        break;
      case 'rest':
        message = '😴 Seu pet está descansando...';
        break;
      case 'heal':
        message = '💊 Pet tratado com carinho!';
        break;
      default:
        message = '✨ Ação realizada!';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getPetEmoji(dynamic pet) {
    // Usar sistema de compatibilidade seguro
    if (pet is PetEntity) {
      if (pet.imageUrl.contains('🐱')) return '🐱';
      if (pet.imageUrl.contains('🐶')) return '🐶';
      if (pet.imageUrl.contains('🐹')) return '🐹';
      if (pet.imageUrl.contains('🐰')) return '🐰';
      if (pet.imageUrl.contains('🦊')) return '🦊';

      // Baseado no tipo
      switch (pet.type.toLowerCase()) {
        case 'cat':
          return '🐱';
        case 'dog':
          return '🐶';
        case 'hamster':
          return '🐹';
        case 'rabbit':
          return '🐰';
        case 'fox':
          return '🦊';
        default:
          return '🐾';
      }
    } else if (pet is CollaborativePetEntity) {
      if (pet.imageUrl.contains('🐱')) return '🐱';
      if (pet.imageUrl.contains('🐶')) return '🐶';
      if (pet.imageUrl.contains('🐹')) return '🐹';
      if (pet.imageUrl.contains('🐰')) return '🐰';
      if (pet.imageUrl.contains('🦊')) return '🦊';

      // Baseado no tipo
      switch (pet.type.toLowerCase()) {
        case 'cat':
          return '🐱';
        case 'dog':
          return '🐶';
        case 'hamster':
          return '🐹';
        case 'rabbit':
          return '🐰';
        case 'fox':
          return '🦊';
        default:
          return '🐾';
      }
    }
    return '🐾';
  }

  String _getPetName(dynamic pet) {
    if (pet is PetEntity) {
      return pet.name;
    } else if (pet is CollaborativePetEntity) {
      return pet.name;
    }
    return 'Pet';
  }

  int _getPetLevel(dynamic pet) {
    if (pet is PetEntity) {
      return pet.level;
    } else if (pet is CollaborativePetEntity) {
      return pet.level;
    }
    return 1;
  }
}

// Custom painter for floating particles
class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 10; i++) {
      final x = (size.width * 0.1 * i) + (animationValue * 50);
      final y = size.height * 0.5 + (animationValue * -100);
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
