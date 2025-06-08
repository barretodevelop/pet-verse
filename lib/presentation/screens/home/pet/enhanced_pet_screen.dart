// File: lib/presentation/screens/home/pet/enhanced_pet_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/presentation/providers/dependencies_provider.dart';
import 'package:petverse/presentation/providers/enhanced_pet_provider.dart';
import 'package:petverse/presentation/widgets/animations/bounce_animation.dart';
import 'package:petverse/presentation/widgets/animations/floating_animation.dart';
import 'package:petverse/presentation/widgets/animations/pulse_animation.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';
import 'package:petverse/services/pet_stats_service.dart';

/// Enhanced pet screen with multiple pets support and real-time stats
class EnhancedPetScreen extends ConsumerWidget {
  const EnhancedPetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petGameState = ref.watch(enhancedPetGameProvider);

    if (!petGameState.hasUserPets) {
      return _buildNoPetsState(context, ref);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(enhancedPetGameProvider);
      },
      child: CustomScrollView(
        slivers: [
          // Pet selection header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(ThemeConfig.spacing16),
              child: SlideFadeAnimation(
                duration: const Duration(milliseconds: 600),
                child: _buildPetSelectionHeader(context, ref, petGameState),
              ),
            ),
          ),

          // Selected pet details
          if (petGameState.hasSelectedPet)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacing16),
                child: Column(
                  children: [
                    SlideFadeAnimation(
                      duration: const Duration(milliseconds: 700),
                      child: _buildSelectedPetCard(context, ref, petGameState.selectedPet!),
                    ),
                    const SizedBox(height: ThemeConfig.spacing16),
                    SlideFadeAnimation(
                      duration: const Duration(milliseconds: 800),
                      child: _buildPetStatsCard(context, petGameState.selectedPet!),
                    ),
                    const SizedBox(height: ThemeConfig.spacing16),
                    SlideFadeAnimation(
                      duration: const Duration(milliseconds: 900),
                      child: _buildPetActionsCard(context, ref, petGameState.selectedPet!),
                    ),
                    const SizedBox(height: ThemeConfig.spacing16),
                    SlideFadeAnimation(
                      duration: const Duration(milliseconds: 1000),
                      child: _buildPetEvolutionCard(context, petGameState.selectedPet!),
                    ),
                  ],
                ),
              ),
            ),

          // Pets needing care
          if (petGameState.petsNeedingCare.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(ThemeConfig.spacing16),
                child: SlideFadeAnimation(
                  duration: const Duration(milliseconds: 1100),
                  child: _buildCareAlerts(context, ref, petGameState.petsNeedingCare),
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: ThemeConfig.spacing20),
          ),
        ],
      ),
    );
  }

  Widget _buildPetSelectionHeader(BuildContext context, WidgetRef ref, EnhancedPetGameState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Your Pets (${state.userPets.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (state.isTimerActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConfig.spacing8,
                      vertical: ThemeConfig.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeConfig.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PulseAnimation(
                          child: Icon(
                            Icons.favorite,
                            size: ThemeConfig.iconSize16,
                            color: ThemeConfig.successColor,
                          ),
                        ),
                        SizedBox(width: ThemeConfig.spacing4),
                        Text(
                          'Active',
                          style: TextStyle(
                            color: ThemeConfig.successColor,
                            fontSize: ThemeConfig.fontSize12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: ThemeConfig.spacing16),

            // Pet selection carousel
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.userPets.length,
                itemBuilder: (context, index) {
                  final pet = state.userPets[index];
                  final isSelected = state.selectedPet?.id == pet.id;

                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < state.userPets.length - 1 ? ThemeConfig.spacing12 : 0,
                    ),
                    child: _buildPetSelectionCard(context, ref, pet, isSelected),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetSelectionCard(BuildContext context, WidgetRef ref, pet, bool isSelected) {
    final mood = PetStatsService.calculateMood(pet);
    final needsCare = PetStatsService.needsUrgentCare(pet);

    return BounceAnimation(
      onTap: () {
        if (!isSelected) {
          ref.read(enhancedPetGameProvider.notifier).selectPet(pet);
        }
      },
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: isSelected ? ThemeConfig.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
          border: Border.all(
            color: isSelected ? ThemeConfig.primaryColor : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacing8),
          child: Column(
            children: [
              // Pet avatar with status
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: ThemeConfig.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: pet.imageUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              pet.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.pets,
                                size: ThemeConfig.iconSize24,
                                color: ThemeConfig.primaryColor,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.pets,
                            size: ThemeConfig.iconSize24,
                            color: ThemeConfig.primaryColor,
                          ),
                  ),

                  // Care alert indicator
                  if (needsCare)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: PulseAnimation(
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: ThemeConfig.errorColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.priority_high,
                            size: 8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: ThemeConfig.spacing8),

              // Pet name
              Text(
                pet.name,
                style: TextStyle(
                  fontSize: ThemeConfig.fontSize12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? ThemeConfig.primaryColor : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ThemeConfig.spacing2),

              // Mood emoji
              Text(
                PetStatsService.getMoodEmoji(mood),
                style: const TextStyle(fontSize: ThemeConfig.fontSize16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedPetCard(BuildContext context, WidgetRef ref, pet) {
    final mood = PetStatsService.calculateMood(pet);
    final health = PetStatsService.calculateOverallHealth(pet);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          children: [
            // Pet image with floating animation
            FloatingAnimation(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: ThemeConfig.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ThemeConfig.primaryColor.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: pet.imageUrl.isNotEmpty
                      ? Image.network(
                          pet.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.pets_rounded,
                            size: ThemeConfig.iconSize48,
                            color: ThemeConfig.primaryColor,
                          ),
                        )
                      : const Icon(
                          Icons.pets_rounded,
                          size: ThemeConfig.iconSize48,
                          color: ThemeConfig.primaryColor,
                        ),
                ),
              ),
            ),

            const SizedBox(height: ThemeConfig.spacing16),

            // Pet name and level
            Text(
              pet.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: ThemeConfig.spacing4),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${pet.type} • Level ${pet.level}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(width: ThemeConfig.spacing8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConfig.spacing8,
                    vertical: ThemeConfig.spacing2,
                  ),
                  decoration: BoxDecoration(
                    color: PetStatsService.needsUrgentCare(pet)
                        ? ThemeConfig.errorColor.withOpacity(0.1)
                        : health >= 70
                            ? ThemeConfig.successColor.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadius4),
                  ),
                  child: Text(
                    '${health.round()}% Health',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSize10,
                      fontWeight: FontWeight.bold,
                      color: PetStatsService.needsUrgentCare(pet)
                          ? ThemeConfig.errorColor
                          : health >= 70
                              ? ThemeConfig.successColor
                              : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: ThemeConfig.spacing12),

            // Mood display
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConfig.spacing16,
                vertical: ThemeConfig.spacing8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    PetStatsService.getMoodEmoji(mood),
                    style: const TextStyle(fontSize: ThemeConfig.fontSize20),
                  ),
                  const SizedBox(width: ThemeConfig.spacing8),
                  Text(
                    PetStatsService.getMoodDescription(mood),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: ThemeConfig.fontSize14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetStatsCard(BuildContext context, pet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pet Stats',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            _buildAnimatedStatBar(
              context,
              'Hunger',
              pet.hunger,
              ThemeConfig.hungerColor,
              Icons.restaurant,
              _getStatUrgency(pet.hunger),
            ),
            const SizedBox(height: ThemeConfig.spacing12),
            _buildAnimatedStatBar(
              context,
              'Happiness',
              pet.happiness,
              ThemeConfig.happinessColor,
              Icons.mood,
              _getStatUrgency(pet.happiness),
            ),
            const SizedBox(height: ThemeConfig.spacing12),
            _buildAnimatedStatBar(
              context,
              'Energy',
              pet.energy,
              ThemeConfig.energyColor,
              Icons.battery_charging_full,
              _getStatUrgency(pet.energy),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStatBar(
    BuildContext context,
    String label,
    int value,
    Color color,
    IconData icon,
    bool isUrgent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: ThemeConfig.iconSize16,
                  color: color,
                ),
                const SizedBox(width: ThemeConfig.spacing8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (isUrgent) ...[
                  const SizedBox(width: ThemeConfig.spacing4),
                  const PulseAnimation(
                    child: Icon(
                      Icons.warning,
                      size: ThemeConfig.iconSize16,
                      color: ThemeConfig.errorColor,
                    ),
                  ),
                ],
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConfig.spacing8,
                vertical: ThemeConfig.spacing2,
              ),
              decoration: BoxDecoration(
                color: isUrgent ? ThemeConfig.errorColor.withOpacity(0.1) : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadius4),
              ),
              child: Text(
                '$value/100',
                style: TextStyle(
                  fontSize: ThemeConfig.fontSize12,
                  fontWeight: FontWeight.bold,
                  color: isUrgent ? ThemeConfig.errorColor : color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: ThemeConfig.spacing8),

        // Animated progress bar
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: value / 100),
          builder: (context, animatedValue, child) {
            return LinearProgressIndicator(
              value: animatedValue,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isUrgent ? ThemeConfig.errorColor : color,
              ),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPetActionsCard(BuildContext context, WidgetRef ref, pet) {
    final carePriority = PetStatsService.getCarePriority(pet);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pet Care',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (carePriority != 'Good')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConfig.spacing8,
                      vertical: ThemeConfig.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeConfig.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                    ),
                    child: Text(
                      'Needs: $carePriority',
                      style: const TextStyle(
                        fontSize: ThemeConfig.fontSize12,
                        fontWeight: FontWeight.bold,
                        color: ThemeConfig.warningColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEnhancedActionButton(
                  context,
                  ref,
                  pet,
                  'Feed',
                  Icons.restaurant_menu_rounded,
                  ThemeConfig.hungerColor,
                  '10 💰',
                  PetAction.feeding,
                  isRecommended: carePriority == 'Feed',
                ),
                _buildEnhancedActionButton(
                  context,
                  ref,
                  pet,
                  'Play',
                  Icons.sports_esports_rounded,
                  ThemeConfig.happinessColor,
                  '5 💰',
                  PetAction.playing,
                  isRecommended: carePriority == 'Play',
                ),
                _buildEnhancedActionButton(
                  context,
                  ref,
                  pet,
                  'Rest',
                  Icons.bedtime_rounded,
                  ThemeConfig.energyColor,
                  'Free',
                  PetAction.sleeping,
                  isRecommended: carePriority == 'Rest',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedActionButton(
    BuildContext context,
    WidgetRef ref,
    pet,
    String label,
    IconData icon,
    Color color,
    String cost,
    PetAction action, {
    bool isRecommended = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacing4),
        child: BounceAnimation(
          onTap: () => _performAction(context, ref, pet.id, action),
          child: Container(
            padding: const EdgeInsets.all(ThemeConfig.spacing16),
            decoration: BoxDecoration(
              color: isRecommended ? color.withOpacity(0.2) : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
              border: Border.all(
                color: isRecommended ? color : color.withOpacity(0.3),
                width: isRecommended ? 3 : 2,
              ),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(ThemeConfig.spacing12),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: ThemeConfig.iconSize24,
                      ),
                    ),
                    if (isRecommended)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: PulseAnimation(
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: ThemeConfig.accentColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.star,
                              size: 8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: ThemeConfig.spacing8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: isRecommended ? FontWeight.bold : FontWeight.w600,
                    fontSize: ThemeConfig.fontSize14,
                  ),
                ),
                const SizedBox(height: ThemeConfig.spacing2),
                Text(
                  cost,
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSize10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetEvolutionCard(BuildContext context, pet) {
    final shouldEvolve = PetStatsService.shouldEvolve(pet);
    final nextStage = PetStatsService.getNextEvolutionStage(pet);
    final currentStageName =
        PetStatsService.getEvolutionStageName(EvolutionStage.values[pet.evolutionStage - 1]);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Evolution',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConfig.spacing8,
                    vertical: ThemeConfig.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: shouldEvolve
                        ? ThemeConfig.accentColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                  ),
                  child: Text(
                    currentStageName,
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSize12,
                      fontWeight: FontWeight.bold,
                      color: shouldEvolve ? ThemeConfig.accentColor : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            if (shouldEvolve) ...[
              PulseAnimation(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(ThemeConfig.spacing16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [ThemeConfig.accentColor, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🌟',
                        style: TextStyle(fontSize: ThemeConfig.fontSize32),
                      ),
                      const SizedBox(height: ThemeConfig.spacing8),
                      const Text(
                        'Evolution Available!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: ThemeConfig.fontSize16,
                        ),
                      ),
                      const SizedBox(height: ThemeConfig.spacing4),
                      Text(
                        'Your pet can evolve to ${PetStatsService.getEvolutionStageName(nextStage)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: ThemeConfig.fontSize12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Evolution progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Next Evolution: Level ${_getNextEvolutionLevel(pet.level)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${pet.level}/${_getNextEvolutionLevel(pet.level)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: ThemeConfig.fontSize14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ThemeConfig.spacing8),
              LinearProgressIndicator(
                value: pet.level / _getNextEvolutionLevel(pet.level),
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(ThemeConfig.primaryColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCareAlerts(BuildContext context, WidgetRef ref, List petsNeedingCare) {
    return Card(
      color: ThemeConfig.errorColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const PulseAnimation(
                  child: Icon(
                    Icons.warning,
                    color: ThemeConfig.errorColor,
                    size: ThemeConfig.iconSize20,
                  ),
                ),
                const SizedBox(width: ThemeConfig.spacing8),
                Text(
                  'Pets Need Care!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: ThemeConfig.errorColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConfig.spacing12),
            ...petsNeedingCare.map((pet) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing4),
                  child: Row(
                    children: [
                      Text(
                        PetStatsService.getMoodEmoji(PetStatsService.calculateMood(pet)),
                        style: const TextStyle(fontSize: ThemeConfig.fontSize16),
                      ),
                      const SizedBox(width: ThemeConfig.spacing8),
                      Expanded(
                        child: Text(
                          '${pet.name} needs ${PetStatsService.getCarePriority(pet).toLowerCase()}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      BounceAnimation(
                        onTap: () {
                          ref.read(enhancedPetGameProvider.notifier).selectPet(pet);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeConfig.spacing8,
                            vertical: ThemeConfig.spacing4,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeConfig.primaryColor,
                            borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                          ),
                          child: const Text(
                            'Care',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ThemeConfig.fontSize12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPetsState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets_outlined,
              size: ThemeConfig.iconSize64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            Text(
              'No Pets Yet!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing8),
            Text(
              'Adopt your first pet to start your journey!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConfig.spacing20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to adoption screen
                ref.read(bottomNavIndexProvider.notifier).state = 2;
              },
              icon: const Icon(Icons.add),
              label: const Text('Adopt a Pet'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performAction(
      BuildContext context, WidgetRef ref, String petId, PetAction action) async {
    final result = await ref.read(enhancedPetGameProvider.notifier).performPetAction(petId, action);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? ThemeConfig.successColor : ThemeConfig.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  bool _getStatUrgency(int value) => value < 30;

  int _getNextEvolutionLevel(int currentLevel) {
    const evolutionLevels = [5, 10, 20, 35, 50];
    for (final level in evolutionLevels) {
      if (currentLevel < level) return level;
    }
    return 100; // Max level
  }
}
