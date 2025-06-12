// File: lib/presentation/screens/home/pet/pet_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/utils/formatters.dart';
import 'package:petverse/core/utils/helpers.dart';
import 'package:petverse/presentation/providers/pet_provider.dart';
import 'package:petverse/presentation/widgets/animations/bounce_animation.dart';
import 'package:petverse/presentation/widgets/animations/floating_animation.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';

/// Pet care screen for interacting with adopted pets
class PetScreen extends ConsumerWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petGameState = ref.watch(petGameProvider);

    if (!petGameState.hasCurrentPet) {
      return _buildNoPetState(context);
    }

    final pet = petGameState.currentPet!;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(petGameProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          children: [
            // Pet image and basic info
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 600),
              child: _buildPetHeader(context, pet),
            ),

            const SizedBox(height: ThemeConfig.spacing24),

            // Pet stats
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 700),
              child: _buildPetStats(context, pet),
            ),

            const SizedBox(height: ThemeConfig.spacing24),

            // Pet actions
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 800),
              child: _buildPetActions(context, ref, pet),
            ),

            const SizedBox(height: ThemeConfig.spacing24),

            // Pet level progress
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 900),
              child: _buildPetLevelProgress(context, pet),
            ),

            const SizedBox(height: ThemeConfig.spacing24),

            // Pet info
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 1000),
              child: _buildPetInfo(context, pet),
            ),

            const SizedBox(height: ThemeConfig.spacing20),
          ],
        ),
      ),
    );
  }

  Widget _buildPetHeader(BuildContext context, pet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          children: [
            // Pet image with floating animation
            FloatingAnimation(
              child: Container(
                width: 160,
                height: 160,
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
                            size: ThemeConfig.iconSize64,
                            color: ThemeConfig.primaryColor,
                          ),
                        )
                      : const Icon(
                          Icons.pets_rounded,
                          size: ThemeConfig.iconSize64,
                          color: ThemeConfig.primaryColor,
                        ),
                ),
              ),
            ),

            const SizedBox(height: ThemeConfig.spacing16),

            // Pet name and type
            Text(
              pet.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: ThemeConfig.spacing4),

            Text(
              '${pet.type} • Level ${pet.level}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),

            const SizedBox(height: ThemeConfig.spacing8),

            // Pet mood indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConfig.spacing12,
                vertical: ThemeConfig.spacing6,
              ),
              decoration: BoxDecoration(
                color: _getPetMoodColor(pet).withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                border: Border.all(
                  color: _getPetMoodColor(pet).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getPetMoodEmoji(pet),
                    style: const TextStyle(fontSize: ThemeConfig.fontSize16),
                  ),
                  const SizedBox(width: ThemeConfig.spacing4),
                  Text(
                    _getPetMoodText(pet),
                    style: TextStyle(
                      color: _getPetMoodColor(pet),
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

  Widget _buildPetStats(BuildContext context, pet) {
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
            _buildStatBarWithLabel(
              context,
              'Hunger',
              pet.hunger,
              ThemeConfig.hungerColor,
              Icons.restaurant,
            ),
            const SizedBox(height: ThemeConfig.spacing12),
            _buildStatBarWithLabel(
              context,
              'Happiness',
              pet.happiness,
              ThemeConfig.happinessColor,
              Icons.mood,
            ),
            const SizedBox(height: ThemeConfig.spacing12),
            _buildStatBarWithLabel(
              context,
              'Energy',
              pet.energy,
              ThemeConfig.energyColor,
              Icons.battery_charging_full,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBarWithLabel(
    BuildContext context,
    String label,
    int value,
    Color color,
    IconData icon,
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
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConfig.spacing8,
                vertical: ThemeConfig.spacing2,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadius4),
              ),
              child: Text(
                '$value/100',
                style: TextStyle(
                  fontSize: ThemeConfig.fontSize12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: ThemeConfig.spacing8),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: ThemeConfig.spacing4),
        Text(
          _getStatDescription(label, value),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    );
  }

  String _getStatDescription(String stat, int value) {
    switch (stat.toLowerCase()) {
      case 'hunger':
        if (value >= 80) return 'Very full and satisfied';
        if (value >= 60) return 'Well fed';
        if (value >= 40) return 'Getting hungry';
        if (value >= 20) return 'Very hungry';
        return 'Starving! Feed me please!';
      case 'happiness':
        if (value >= 80) return 'Extremely happy and playful';
        if (value >= 60) return 'Content and cheerful';
        if (value >= 40) return 'Feeling okay';
        if (value >= 20) return 'A bit sad';
        return 'Very unhappy and lonely';
      case 'energy':
        if (value >= 80) return 'Full of energy and ready to play';
        if (value >= 60) return 'Energetic';
        if (value >= 40) return 'Moderate energy';
        if (value >= 20) return 'Getting tired';
        return 'Exhausted and needs rest';
      default:
        return '';
    }
  }

  Widget _buildPetActions(BuildContext context, WidgetRef ref, pet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pet Care',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  'Feed',
                  Icons.restaurant_menu_rounded,
                  ThemeConfig.hungerColor,
                  '10 coins',
                  () => _performPetAction(context, ref, 'feed'),
                ),
                _buildActionButton(
                  context,
                  'Play',
                  Icons.sports_esports_rounded,
                  ThemeConfig.happinessColor,
                  '5 coins',
                  () => _performPetAction(context, ref, 'play'),
                ),
                _buildActionButton(
                  context,
                  'Rest',
                  Icons.bedtime_rounded,
                  ThemeConfig.energyColor,
                  'Free',
                  () => _performPetAction(context, ref, 'rest'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    String cost,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacing4),
        child: BounceAnimation(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(ThemeConfig.spacing16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
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
                const SizedBox(height: ThemeConfig.spacing8),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
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

  Widget _buildPetLevelProgress(BuildContext context, pet) {
    final progress = pet.xpToNextLevel > 0 ? (pet.xp / pet.xpToNextLevel) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Level Progress',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress to Level ${pet.level + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${pet.xp}/${pet.xpToNextLevel} XP',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConfig.spacing12),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: ThemeConfig.primaryColor.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(ThemeConfig.primaryColor),
            ),
            const SizedBox(height: ThemeConfig.spacing8),
            Text(
              '${Formatters.formatPercentage(progress.clamp(0.0, 1.0))} complete',
              style: const TextStyle(
                fontSize: ThemeConfig.fontSize12,
                color: ThemeConfig.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetInfo(BuildContext context, pet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pet Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            _buildInfoRow('Type', pet.type),
            _buildInfoRow('Evolution Stage', pet.evolutionStage.toString()),
            _buildInfoRow('Last Fed', Formatters.formatRelativeTime(pet.lastFed)),
            _buildInfoRow('Last Played', Formatters.formatRelativeTime(pet.lastPlayed)),
            _buildInfoRow('Last Slept', Formatters.formatRelativeTime(pet.lastSlept)),
            const SizedBox(height: ThemeConfig.spacing12),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing8),
            Text(
              pet.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: ThemeConfig.fontSize14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: ThemeConfig.fontSize14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPetState(BuildContext context) {
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
              'No Pet Selected',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing8),
            Text(
              'Please adopt a pet first to see this screen.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performPetAction(BuildContext context, WidgetRef ref, String action) async {
    late Future<PetInteractionResult> actionFuture;

    switch (action) {
      case 'feed':
        actionFuture = ref.read(petGameProvider.notifier).feedCurrentPet();
        break;
      case 'play':
        actionFuture = ref.read(petGameProvider.notifier).playWithCurrentPet();
        break;
      case 'rest':
        actionFuture = ref.read(petGameProvider.notifier).restCurrentPet();
        break;
      default:
        return;
    }

    final result = await actionFuture;

    if (context.mounted) {
      Helpers.showSnackBar(
        context,
        result.message,
        backgroundColor: result.success ? ThemeConfig.successColor : ThemeConfig.errorColor,
      );
    }
  }

  Color _getPetMoodColor(pet) {
    final happiness = pet.happiness;
    if (happiness >= 80) return ThemeConfig.successColor;
    if (happiness >= 50) return Colors.orange;
    return ThemeConfig.errorColor;
  }

  String _getPetMoodEmoji(pet) {
    final happiness = pet.happiness;
    if (happiness >= 80) return '😊';
    if (happiness >= 60) return '🙂';
    if (happiness >= 40) return '😐';
    if (happiness >= 20) return '😟';
    return '😢';
  }

  String _getPetMoodText(pet) {
    final happiness = pet.happiness;
    if (happiness >= 80) return 'Happy';
    if (happiness >= 60) return 'Content';
    if (happiness >= 40) return 'Okay';
    if (happiness >= 20) return 'Sad';
    return 'Very Sad';
  }
}
