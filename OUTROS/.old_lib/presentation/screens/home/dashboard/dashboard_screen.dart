// File: lib/presentation/screens/home/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/utils/formatters.dart';
import 'package:petverse/core/utils/helpers.dart';
import 'package:petverse/presentation/providers/dependencies_provider.dart';
import 'package:petverse/presentation/providers/pet_provider.dart';
import 'package:petverse/presentation/providers/user_provider.dart';
import 'package:petverse/presentation/widgets/animations/animated_counter.dart';
import 'package:petverse/presentation/widgets/animations/floating_animation.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';

/// Dashboard screen showing user progress and pet status
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGameData = ref.watch(userGameDataProvider);
    final petGameData = ref.watch(petGameProvider);

    if (userGameData.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userGameData.hasError || !userGameData.hasUser) {
      return _buildErrorState(context, userGameData.errorMessage);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userGameDataProvider);
        ref.invalidate(petGameProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 600),
              child: _buildWelcomeCard(context, userGameData.user!),
            ),

            const SizedBox(height: ThemeConfig.spacing20),

            // Progress section
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 700),
              child: _buildProgressSection(context, userGameData.user!),
            ),

            const SizedBox(height: ThemeConfig.spacing24),

            // Current pet section
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 800),
              child: petGameData.hasCurrentPet
                  ? _buildCurrentPetCard(context, petGameData.currentPet!)
                  : _buildNoPetCard(context, ref),
            ),

            const SizedBox(height: ThemeConfig.spacing24),

            // Quick actions section
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 900),
              child: _buildQuickActionsSection(context, ref),
            ),

            const SizedBox(height: ThemeConfig.spacing24),

            // Recent activity section
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 1000),
              child: _buildRecentActivitySection(context),
            ),

            const SizedBox(height: ThemeConfig.spacing20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, user) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
          gradient: ThemeConfig.primaryGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${user.displayName}! 👋',
                        style: const TextStyle(
                          fontSize: ThemeConfig.fontSize24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: ThemeConfig.spacing8),
                      Text(
                        'Welcome back to your pet world!',
                        style: TextStyle(
                          fontSize: ThemeConfig.fontSize16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(ThemeConfig.spacing12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
                  ),
                  child: const Text(
                    '🏆',
                    style: TextStyle(fontSize: ThemeConfig.fontSize32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            _buildLoginStreakInfo(user),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginStreakInfo(user) {
    return Container(
      padding: const EdgeInsets.all(ThemeConfig.spacing12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.orange,
            size: ThemeConfig.iconSize20,
          ),
          const SizedBox(width: ThemeConfig.spacing8),
          Text(
            'Login Streak: ${user.loginStreak} days',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            'Level ${user.level}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Your Progress'),
        const SizedBox(height: ThemeConfig.spacing12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total XP',
                user.totalXp,
                Icons.star_rounded,
                ThemeConfig.xpColor,
                isAnimated: true,
              ),
            ),
            const SizedBox(width: ThemeConfig.spacing12),
            Expanded(
              child: _buildStatCard(
                context,
                'Level',
                user.level,
                Icons.trending_up_rounded,
                ThemeConfig.successColor,
                isAnimated: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: ThemeConfig.spacing12),
        _buildLevelProgressBar(context, user),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    int value,
    IconData icon,
    Color color, {
    bool isAnimated = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(ThemeConfig.spacing8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
              ),
              child: Icon(
                icon,
                color: color,
                size: ThemeConfig.iconSize24,
              ),
            ),
            const SizedBox(height: ThemeConfig.spacing12),
            isAnimated
                ? AnimatedCounter(
                    value: value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  )
                : Text(
                    value.toString(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
            const SizedBox(height: ThemeConfig.spacing4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelProgressBar(BuildContext context, user) {
    final currentLevelXp = Helpers.calculateXpForLevel(user.level - 1);
    final nextLevelXp = Helpers.calculateXpForLevel(user.level);
    final progressXp = user.totalXp - currentLevelXp;
    final requiredXp = nextLevelXp - currentLevelXp;
    final progress = progressXp / requiredXp;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress to Level ${user.level + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '${Formatters.formatLargeNumber(progressXp)}/${Formatters.formatLargeNumber(requiredXp)} XP',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConfig.spacing12),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: ThemeConfig.primaryColor.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(ThemeConfig.primaryColor),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: ThemeConfig.spacing8),
            Text(
              '${Formatters.formatPercentage(progress.clamp(0.0, 1.0))} complete',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ThemeConfig.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPetCard(BuildContext context, pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Your Current Pet'),
        const SizedBox(height: ThemeConfig.spacing12),
        Card(
          child: InkWell(
            onTap: () {
              // Navigate to pet detail
              final ref = ProviderScope.containerOf(context);
              ref.read(bottomNavIndexProvider.notifier).state = 2;
            },
            borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
            child: Padding(
              padding: const EdgeInsets.all(ThemeConfig.spacing16),
              child: Row(
                children: [
                  // Pet avatar
                  FloatingAnimation(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: ThemeConfig.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius16),
                      ),
                      child: pet.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(ThemeConfig.borderRadius16),
                              child: Image.network(
                                pet.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.pets,
                                  size: ThemeConfig.iconSize48,
                                  color: ThemeConfig.primaryColor,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.pets,
                              size: ThemeConfig.iconSize48,
                              color: ThemeConfig.primaryColor,
                            ),
                    ),
                  ),

                  const SizedBox(width: ThemeConfig.spacing16),

                  // Pet info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: ThemeConfig.spacing4),
                        Text(
                          '${pet.type} • Level ${pet.level}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: ThemeConfig.spacing12),
                        _buildPetStatBars(pet),
                      ],
                    ),
                  ),

                  // Pet mood indicator
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(ThemeConfig.spacing8),
                        decoration: BoxDecoration(
                          color: _getPetMoodColor(pet).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                        ),
                        child: Text(
                          _getPetMoodEmoji(pet),
                          style: const TextStyle(fontSize: ThemeConfig.fontSize24),
                        ),
                      ),
                      const SizedBox(height: ThemeConfig.spacing4),
                      Text(
                        _getPetMoodText(pet),
                        style: TextStyle(
                          fontSize: ThemeConfig.fontSize10,
                          color: _getPetMoodColor(pet),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPetStatBars(pet) {
    return Column(
      children: [
        _buildStatBar('Happiness', pet.happiness, ThemeConfig.happinessColor),
        const SizedBox(height: ThemeConfig.spacing4),
        _buildStatBar('Hunger', pet.hunger, ThemeConfig.hungerColor),
        const SizedBox(height: ThemeConfig.spacing4),
        _buildStatBar('Energy', pet.energy, ThemeConfig.energyColor),
      ],
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: ThemeConfig.fontSize12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: ThemeConfig.spacing8),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: ThemeConfig.spacing8),
        SizedBox(
          width: 30,
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: ThemeConfig.fontSize12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
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

  Widget _buildNoPetCard(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Your Pet'),
        const SizedBox(height: ThemeConfig.spacing12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(ThemeConfig.spacing24),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadius16),
                  ),
                  child: Icon(
                    Icons.pets_outlined,
                    size: ThemeConfig.iconSize48,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: ThemeConfig.spacing16),
                Text(
                  'No Pet Yet!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: ThemeConfig.spacing8),
                Text(
                  'Adopt your first virtual companion and start your journey!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ThemeConfig.spacing20),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(bottomNavIndexProvider.notifier).state = 2;
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Adopt a Pet'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConfig.spacing20,
                      vertical: ThemeConfig.spacing12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Quick Actions'),
        const SizedBox(height: ThemeConfig.spacing12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Shop',
                Icons.store,
                ThemeConfig.accentColor,
                () => ref.read(bottomNavIndexProvider.notifier).state = 1,
              ),
            ),
            const SizedBox(width: ThemeConfig.spacing12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Games',
                Icons.sports_esports,
                Colors.purple,
                () => ref.read(bottomNavIndexProvider.notifier).state = 3,
              ),
            ),
            const SizedBox(width: ThemeConfig.spacing12),
            Expanded(
              child: _buildQuickActionCard(
                context,
                'Community',
                Icons.people,
                Colors.blue,
                () => ref.read(bottomNavIndexProvider.notifier).state = 4,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacing16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(ThemeConfig.spacing12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: ThemeConfig.iconSize24,
                ),
              ),
              const SizedBox(height: ThemeConfig.spacing8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: ThemeConfig.fontSize14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Recent Activity'),
        const SizedBox(height: ThemeConfig.spacing12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(ThemeConfig.spacing20),
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: ThemeConfig.iconSize48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: ThemeConfig.spacing12),
                Text(
                  'No Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: ThemeConfig.spacing8),
                Text(
                  'Start interacting with your pets to see activity here!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: ThemeConfig.spacing4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ThemeConfig.iconSize64,
              color: ThemeConfig.errorColor.withOpacity(0.6),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: ThemeConfig.errorColor,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing8),
            Text(
              errorMessage ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConfig.spacing20),
            ElevatedButton.icon(
              onPressed: () {
                final container = ProviderScope.containerOf(context);
                container.invalidate(userGameDataProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
