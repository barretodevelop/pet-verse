// lib/features/adoption/presentation/widgets/pet_selection_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:petverse/core/constants/app_constants.dart';
import 'package:petverse/core/model/pet_model.dart';
import 'package:petverse/core/providers/pet_provider.dart';

import '../../../../core/theme/bck-app_theme.dart';
import '../../../../core/utils/app_utils.dart';

class PetSelectionCard extends ConsumerStatefulWidget {
  final PetModel pet;

  const PetSelectionCard({
    super.key,
    required this.pet,
  });

  @override
  ConsumerState<PetSelectionCard> createState() => _PetSelectionCardState();
}

class _PetSelectionCardState extends ConsumerState<PetSelectionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _selectionController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: AppTheme.primary.withOpacity(0.05),
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  void _handleSelection() {
    final selectedPetsNotifier = ref.read(selectedPetsProvider.notifier);
    final isSelected = selectedPetsNotifier.isPetSelected(widget.pet.id);

    if (isSelected) {
      selectedPetsNotifier.removePet(widget.pet.id);
      _selectionController.reverse();
      AppUtils.lightImpact();
    } else if (selectedPetsNotifier.canSelectMore) {
      selectedPetsNotifier.addPet(widget.pet.id);
      _selectionController.forward();
      AppUtils.mediumImpact();
    } else {
      AppUtils.showInfoSnackbar(
          context, 'Você pode selecionar no máximo 3 pets');
      AppUtils.heavyImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPetsNotifier = ref.watch(selectedPetsProvider.notifier);
    final isSelected = selectedPetsNotifier.isPetSelected(widget.pet.id);

    // Update animation based on selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isSelected && !_selectionController.isCompleted) {
        _selectionController.forward();
      } else if (!isSelected && _selectionController.isCompleted) {
        _selectionController.reverse();
      }
    });

    return AnimatedBuilder(
      animation: _selectionController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _handleSelection,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? AppTheme.primary : Colors.transparent,
                    blurRadius: isSelected ? 15 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Pet Image
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(widget.pet.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Selection indicator
                      if (isSelected)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        )
                            .animate()
                            .scale(
                                begin: const Offset(0, 0),
                                end: const Offset(1, 1))
                            .fadeIn(),

                      // Health indicator
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getHealthColor(widget.pet.health),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.pet.health}%',
                            style: AppTheme.captionText.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // Pet Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and type
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.pet.name,
                                style: AppTheme.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentCoral.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.pet.type,
                                style: AppTheme.captionText.copyWith(
                                  color: AppTheme.accentCoral,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Breed
                        Text(
                          widget.pet.breed,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Stats
                        Row(
                          children: [
                            _buildStatChip('❤️', widget.pet.happiness),
                            const SizedBox(width: 8),
                            _buildStatChip('⚡', widget.pet.energy),
                            const Spacer(),
                            if (isSelected)
                              Icon(
                                Icons.favorite,
                                color: AppTheme.accentCoral,
                                size: 16,
                              )
                                  .animate(
                                      onPlay: (controller) =>
                                          controller.repeat())
                                  .scale(
                                    begin: const Offset(0.8, 0.8),
                                    end: const Offset(1.2, 1.2),
                                    duration: 1000.ms,
                                  ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(String emoji, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.textLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 2),
          Text(
            value.toString(),
            style: AppTheme.captionText.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getHealthColor(int health) {
    if (health >= 80) return AppTheme.success;
    if (health >= 50) return AppTheme.warning;
    return AppTheme.error;
  }
}

extension on Color {
  copyWith({required Color color, required FontWeight fontWeight}) {}
}

// lib/features/adoption/presentation/widgets/selected_pets_summary.dart
class SelectedPetsSummary extends ConsumerWidget {
  final List<PetModel> pets;

  const SelectedPetsSummary({
    super.key,
    required this.pets,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Resumo da Seleção',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Estes são os pets que você escolheu para adoção. Um co-parent poderá escolher um deles.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Selected pets list
          ...pets.asMap().entries.map((entry) {
            final index = entry.key;
            final pet = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildSelectedPetCard(context, ref, pet, index),
            );
          }),

          const SizedBox(height: 16),

          // Info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient.scale(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.accentCoral.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.accentCoral,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Como funciona?',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentCoral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Seu pedido ficará público por 5 dias\n'
                  '• Outros usuários verão estes pets\n'
                  '• Quando alguém escolher um, vocês dois o receberão\n'
                  '• Você será notificado quando isso acontecer',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPetCard(
      BuildContext context, WidgetRef ref, PetModel pet, int index) {
    return Dismissible(
      key: Key(pet.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        ref.read(selectedPetsProvider.notifier).removePet(pet.id);
        AppUtils.showInfoSnackbar(context, '${pet.name} removido da seleção');
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: AppTheme.error,
          size: 24,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppTheme.primary.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primary.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Selection number
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Pet image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(pet.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Pet info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${pet.breed} • ${pet.type}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Remove button
            IconButton(
              onPressed: () {
                ref.read(selectedPetsProvider.notifier).removePet(pet.id);
                AppUtils.lightImpact();
              },
              icon: Icon(
                Icons.close,
                color: AppTheme.textLight,
                size: 20,
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: Duration(milliseconds: index * 100))
          .slideX(begin: 0.2, end: 0),
    );
  }
}

// lib/features/adoption/presentation/widgets/create_request_success.dart
class CreateRequestSuccess extends StatefulWidget {
  final String requestId;
  final VoidCallback onShare;
  final VoidCallback onViewPublicList;
  final VoidCallback onGoHome;

  const CreateRequestSuccess({
    super.key,
    required this.requestId,
    required this.onShare,
    required this.onViewPublicList,
    required this.onGoHome,
  });

  @override
  State<CreateRequestSuccess> createState() => _CreateRequestSuccessState();
}

class _CreateRequestSuccessState extends State<CreateRequestSuccess>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _celebrationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),

                // Success animation
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Lottie.asset(
                    AppConstants.adoptionAnimation,
                    controller: _celebrationController,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 32),

                // Success message
                Text(
                  'Pedido Criado! 🎉',
                  style: AppTheme.headlineLarge.copyWith(
                    color: AppTheme.success,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 500.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 16),

                Text(
                  'Seu pedido de adoção foi publicado com sucesso! '
                  'Agora é só aguardar alguém escolher um dos seus pets.',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 700.ms)
                    .slideY(begin: 0.3, end: 0),

                const SizedBox(height: 32),

                // Info card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.primary,
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.schedule,
                              color: AppTheme.success,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Válido por 5 dias',
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Expira em ${AppUtils.formatDate(DateTime.now().add(const Duration(days: 5)))}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ID do Pedido: ${widget.requestId.substring(0, 8).toUpperCase()}',
                          style: AppTheme.bodySmall.copyWith(
                            fontFamily: 'monospace',
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 900.ms)
                    .slideY(begin: 0.3, end: 0),

                const Spacer(),

                // Action buttons
                Column(
                  children: [
                    // Share button
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.05),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: widget.onShare,
                              icon: const Icon(Icons.share),
                              label: const Text('Compartilhar com Amigos'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentCoral,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // View public list button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: widget.onViewPublicList,
                        icon: const Icon(Icons.list),
                        label: const Text('Ver Lista Pública'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Go home button
                    TextButton(
                      onPressed: widget.onGoHome,
                      child: Text(
                        'Voltar ao Início',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 1100.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
