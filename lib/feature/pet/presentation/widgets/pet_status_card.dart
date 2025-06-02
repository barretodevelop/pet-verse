// lib/feature/pet/presentation/widgets/pet_status_card.dart
// ATUALIZADO: Card expressivo com animações emocionais
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/model/pet_model.dart';
import 'package:petverse/core/providers/pet_provider.dart';
import 'package:petverse/core/utils/app_utils.dart';
import 'package:petverse/core/widgets/loading_animation.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';
import 'package:petverse/feature/home/presentation/widgets/loading_error_screens.dart';

enum PetMood {
  happy,
  playful,
  sleepy,
  hungry,
  excited,
  calm,
  sad,
  sick,
  energetic,
  content
}

class PetStatusCard extends ConsumerWidget {
  final String petId;
  final AnimationController floatController;

  const PetStatusCard({
    super.key,
    required this.petId,
    required this.floatController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petAsync = ref.watch(petByIdProvider(petId));

    return petAsync.when(
      data: (pet) => pet != null
          ? ExpressivePetCard(pet: pet, floatController: floatController)
          : const _NoPetFoundCard(),
      loading: () => const LoadingAnimation(
        message: 'Carregando seu pet...',
        type: LoadingType.pets,
      ),
      error: (_, __) => ErrorScreen(
        message: 'Erro ao carregar detalhes do pet.',
        onRetry: () => ref.invalidate(petByIdProvider(petId)),
      ),
    );
  }
}

class ExpressivePetCard extends StatefulWidget {
  final PetModel pet;
  final AnimationController floatController;

  const ExpressivePetCard({
    super.key,
    required this.pet,
    required this.floatController,
  });

  @override
  State<ExpressivePetCard> createState() => _ExpressivePetCardState();
}

class _ExpressivePetCardState extends State<ExpressivePetCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _moodController;
  bool _isPressed = false;

  // Ações recentes mockadas - em produção viria do estado
  final List<String> _recentActions = ['Alimentou', 'Brincou', 'Descansou'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _moodController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Animar baseado no humor
    final mood = _determinePetMood();
    if (mood == PetMood.excited || mood == PetMood.happy) {
      _pulseController.repeat(reverse: true);
    }

    _moodController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _moodController.dispose();
    super.dispose();
  }

  PetMood _determinePetMood() {
    final happiness = widget.pet.happiness;
    final energy = widget.pet.energy;
    final health = widget.pet.health;

    if (health < 30) return PetMood.sick;
    if (happiness >= 90 && energy >= 80) return PetMood.excited;
    if (happiness >= 80) return PetMood.happy;
    if (energy >= 80) return PetMood.energetic;
    if (energy <= 30) return PetMood.sleepy;
    if (happiness <= 40) return PetMood.sad;
    if (happiness >= 60 && energy >= 50) return PetMood.playful;
    if (happiness >= 50 && energy <= 60) return PetMood.calm;

    return PetMood.content;
  }

  Color get _moodColor {
    switch (_determinePetMood()) {
      case PetMood.happy:
        return const Color(0xFF4ECDC4);
      case PetMood.excited:
        return const Color(0xFFFF4757);
      case PetMood.playful:
        return const Color(0xFFFF6B9D);
      case PetMood.sleepy:
        return const Color(0xFF9B59B6);
      case PetMood.hungry:
        return const Color(0xFFFF9500);
      case PetMood.calm:
        return const Color(0xFF5D9CEC);
      case PetMood.sad:
        return const Color(0xFF74b9ff);
      case PetMood.sick:
        return const Color(0xFFFF7675);
      case PetMood.energetic:
        return const Color(0xFF00b894);
      case PetMood.content:
        return const Color(0xFF6c5ce7);
    }
  }

  String get _moodText {
    switch (_determinePetMood()) {
      case PetMood.happy:
        return 'Feliz e contente! 😊';
      case PetMood.excited:
        return 'Super animado! ⚡';
      case PetMood.playful:
        return 'Quer brincar! 🎾';
      case PetMood.sleepy:
        return 'Está com sono... 😴';
      case PetMood.hungry:
        return 'Está com fome! 🍖';
      case PetMood.calm:
        return 'Relaxado e zen 🧘';
      case PetMood.sad:
        return 'Precisa de carinho 💙';
      case PetMood.sick:
        return 'Não está bem 🏥';
      case PetMood.energetic:
        return 'Cheio de energia! 💚';
      case PetMood.content:
        return 'Satisfeito 😌';
    }
  }

  String get _moodEmoji {
    switch (_determinePetMood()) {
      case PetMood.happy:
        return '😊';
      case PetMood.excited:
        return '🤩';
      case PetMood.playful:
        return '😄';
      case PetMood.sleepy:
        return '😴';
      case PetMood.hungry:
        return '🤤';
      case PetMood.calm:
        return '😌';
      case PetMood.sad:
        return '😢';
      case PetMood.sick:
        return '🤒';
      case PetMood.energetic:
        return '⚡';
      case PetMood.content:
        return '🙂';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                _moodColor.withOpacity(0.05),
                _moodColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: _moodColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _moodColor.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: _moodColor.withOpacity(0.08),
                blurRadius: 50,
                offset: const Offset(0, 25),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                // Pet Avatar com animação baseada no humor
                _buildAnimatedAvatar(),

                const SizedBox(height: 24),

                // Nome e informações básicas
                _buildPetHeader(),

                const SizedBox(height: 20),

                // Mood indicator
                _buildMoodIndicator(),

                const SizedBox(height: 24),

                // Status bars melhorados
                _buildEnhancedStatusBars(),

                const SizedBox(height: 20),

                // Ações recentes
                _buildRecentActions(),

                const SizedBox(height: 24),

                // Botões de ação melhorados
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 800.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildAnimatedAvatar() {
    Widget avatar = Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            _moodColor.withOpacity(0.25),
            _moodColor.withOpacity(0.15),
            _moodColor.withOpacity(0.05),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _moodColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Pet image/emoji
          Center(
            child: ClipOval(
              child: widget.pet.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.pet.imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_moodColor, _moodColor.withOpacity(0.7)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.pets,
                            size: 60,
                            color: Colors.white,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_moodColor, _moodColor.withOpacity(0.7)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          // Mood emoji overlay
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _moodColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  _moodEmoji,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Animações diferentes por humor
    switch (_determinePetMood()) {
      case PetMood.excited:
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.1),
              child: avatar,
            );
          },
        );

      case PetMood.sleepy:
        return AnimatedBuilder(
          animation: widget.floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, widget.floatController.value * 6),
              child: avatar,
            );
          },
        );

      case PetMood.playful:
        return avatar
            .animate(onPlay: (controller) => controller.repeat())
            .rotate(end: 0.02, duration: 1000.ms)
            .then()
            .rotate(end: -0.02, duration: 1000.ms);

      case PetMood.happy:
        return EmotionalAnimations.petHappyBounce(child: avatar);

      default:
        return AnimatedBuilder(
          animation: widget.floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, widget.floatController.value * 8),
              child: avatar,
            );
          },
        );
    }
  }

  Widget _buildPetHeader() {
    return Column(
      children: [
        Text(
          widget.pet.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _moodColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${widget.pet.breed} • ${widget.pet.type}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _moodColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _moodColor.withOpacity(0.2),
            _moodColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _moodColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _moodEmoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            _moodText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _moodColor,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms)
        .scale(begin: const Offset(0.8, 0.8))
        .shimmer(delay: 1000.ms, duration: 1500.ms);
  }

  Widget _buildEnhancedStatusBars() {
    return Column(
      children: [
        _buildStatusBar(
            'Felicidade', widget.pet.happiness, const Color(0xFF4ECDC4), '❤️'),
        const SizedBox(height: 14),
        _buildStatusBar(
            'Saúde', widget.pet.health, const Color(0xFF00b894), '🏥'),
        const SizedBox(height: 14),
        _buildStatusBar(
            'Energia', widget.pet.energy, const Color(0xFF5D9CEC), '⚡'),
      ],
    );
  }

  Widget _buildStatusBar(String label, int value, Color color, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5568),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ).animate().scaleX(
                    begin: 0,
                    end: 1,
                    duration: 800.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$value%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActions() {
    if (_recentActions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Atividades recentes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF718096),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _recentActions.take(3).map((action) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: _moodColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: _moodColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                action,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: _moodColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'Alimentar',
            icon: Icons.restaurant,
            color: const Color(0xFFFF9500),
            onTap: () {
              HapticFeedback.mediumImpact();
              AppUtils.showSuccessSnackbar(
                  context, '${widget.pet.name} adorou a comida! 🍖');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'Brincar',
            icon: Icons.sports_tennis,
            color: const Color(0xFF5D9CEC),
            onTap: () {
              HapticFeedback.mediumImpact();
              AppUtils.showSuccessSnackbar(
                  context, '${widget.pet.name} se divertiu muito! 🎾');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'Cuidar',
            icon: Icons.medical_services,
            color: const Color(0xFF00b894),
            onTap: () {
              HapticFeedback.mediumImpact();
              AppUtils.showSuccessSnackbar(
                  context, '${widget.pet.name} está se sentindo melhor! 💊');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return EmotionalAnimations.enhancedTapFeedback(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoPetFoundCard extends StatelessWidget {
  const _NoPetFoundCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF64748B).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pets_outlined,
                size: 40,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pet não encontrado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Não foi possível carregar\nas informações do seu pet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Consumer(
              builder: (context, ref, child) {
                return ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(authenticationNotifierProvider.notifier)
                        .refreshUserModel();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar Novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
