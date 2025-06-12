// File: lib/presentation/screens/home/dashboard/enhanced_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/presentation/providers/dependencies_provider.dart';
import 'package:petverse/presentation/providers/pet_provider.dart';
import 'package:petverse/presentation/providers/user_provider.dart';
import 'package:petverse/presentation/widgets/animations/animated_counter.dart';
import 'package:petverse/presentation/widgets/animations/floating_animation.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';

/// Enhanced Dashboard with improved UX/UI design
class EnhancedDashboardScreen extends ConsumerWidget {
  const EnhancedDashboardScreen({super.key});

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
        padding: const EdgeInsets.all(12), // Reduced spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Welcome Header - 50% smaller
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 400),
              child: _buildCompactWelcomeHeader(context, userGameData.user!),
            ),

            const SizedBox(height: 12),

            // // Enhanced Stats Row - Horizontal scroll
            // SlideFadeAnimation(
            //   duration: const Duration(milliseconds: 500),
            //   child: _buildEnhancedStatsRow(context, userGameData.user!),
            // ),

            // const SizedBox(height: 16),

            // Compact Pet Status
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 600),
              child: petGameData.hasCurrentPet
                  ? _buildCompactPetStatus(context, petGameData.currentPet!)
                  : _buildNoPetCard(context, ref),
            ),

            const SizedBox(height: 16),

            // Enhanced Quick Actions Grid - 2x3 layout
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 700),
              child: _buildEnhancedQuickActions(context, ref),
            ),

            const SizedBox(height: 16),

            // Daily Progress Tracker - New component
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 800),
              child: _buildDailyProgressTracker(context, userGameData.user!),
            ),

            const SizedBox(height: 16),

            // Recent Achievements - New component
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 900),
              child: _buildRecentAchievements(context, userGameData.user!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactWelcomeHeader(BuildContext context, user) {
    return Container(
      height: 80, // Reduced from 120+
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1), // New indigo color
            Color(0xFF8B5CF6), // Violet
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome back! 👋',
                  style: const TextStyle(
                    fontSize: 18, // Reduced font size
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level ${user.level} • Streak ${user.loginStreak} days 🔥',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🏆',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatsRow(BuildContext context, user) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildAnimatedStatCard(
            'Total XP',
            user.totalXp,
            Icons.auto_awesome,
            const Color(0xFF7C3AED),
            isAnimated: true,
          ),
          const SizedBox(width: 12),
          _buildAnimatedStatCard(
            'Coins',
            user.coins,
            Icons.monetization_on,
            const Color(0xFFFFB800),
            isAnimated: true,
          ),
          const SizedBox(width: 12),
          _buildAnimatedStatCard(
            'Gems',
            user.gems,
            Icons.diamond,
            const Color(0xFF00D2FF),
            isAnimated: true,
          ),
          const SizedBox(width: 12),
          // _buildAnimatedStatCard(
          //   'Achievements',
          //   user.achievementsUnlocked,
          //   Icons.emoji_events,
          //   const Color(0xFFEC4899),
          // ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatCard(
    String label,
    int value,
    IconData icon,
    Color color, {
    bool isAnimated = false,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          isAnimated
              ? AnimatedCounter(
                  value: value,
                  duration: const Duration(milliseconds: 1000),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                )
              : Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPetStatus(BuildContext context, pet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pet Avatar
          FloatingAnimation(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '🐱',
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Pet Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pet.type} • Level ${pet.level}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                // Mini stats row
                Row(
                  children: [
                    _buildMiniStat('💖', pet.happiness, const Color(0xFF34D399)),
                    const SizedBox(width: 8),
                    _buildMiniStat('🍖', pet.hunger, const Color(0xFFFF6B35)),
                    const SizedBox(width: 8),
                    _buildMiniStat('⚡', pet.energy, const Color(0xFF3B82F6)),
                  ],
                ),
              ],
            ),
          ),

          // Quick care button
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.pets,
              color: Color(0xFF6366F1),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String emoji, int value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 2),
        Text(
          '$value%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildNoPetCard(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adopt your first pet! 🐾',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start your pet caring journey',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => ref.read(bottomNavIndexProvider.notifier).state = 2,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFEC4899),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Adopt'),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedQuickActions(BuildContext context, WidgetRef ref) {
    final actions = [
      {'title': 'Shop', 'icon': Icons.store, 'color': const Color(0xFF06B6D4), 'index': 1},
      {'title': 'Pet Care', 'icon': Icons.pets, 'color': const Color(0xFFEC4899), 'index': 2},
      {
        'title': 'Games',
        'icon': Icons.sports_esports,
        'color': const Color(0xFF10B981),
        'index': 3
      },
      {'title': 'Community', 'icon': Icons.people, 'color': const Color(0xFFF59E0B), 'index': 4},
      {
        'title': 'Inventory',
        'icon': Icons.inventory,
        'color': const Color(0xFF6366F1),
        'index': -1
      },
      {
        'title': 'Achievements',
        'icon': Icons.emoji_events,
        'color': const Color(0xFFFFB800),
        'index': -2
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildQuickActionCard(
              context,
              ref,
              action['title'] as String,
              action['icon'] as IconData,
              action['color'] as Color,
              action['index'] as int,
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    WidgetRef ref,
    String title,
    IconData icon,
    Color color,
    int navigationIndex,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToAction(ref, navigationIndex),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyProgressTracker(BuildContext context, user) {
    final tasks = [
      {'name': 'Feed Pet', 'completed': true, 'icon': Icons.restaurant},
      {'name': 'Play Game', 'completed': false, 'icon': Icons.sports_esports},
      {'name': 'Visit Shop', 'completed': true, 'icon': Icons.store},
      {'name': 'Social Activity', 'completed': false, 'icon': Icons.people},
    ];

    final completedTasks = tasks.where((task) => task['completed'] == true).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.today,
                color: const Color(0xFF10B981),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Daily Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                '$completedTasks/${tasks.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: completedTasks / tasks.length,
            backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            minHeight: 6,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: tasks.map((task) {
              final completed = task['completed'] as bool;
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: completed
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  task['icon'] as IconData,
                  size: 16,
                  color: completed ? const Color(0xFF10B981) : Colors.grey,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFB800).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: const Color(0xFFFFB800),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Recent Achievements',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildAchievementBadge('🏆', 'First Pet'),
              const SizedBox(width: 8),
              _buildAchievementBadge('💰', '100 Coins'),
              const SizedBox(width: 8),
              _buildAchievementBadge('⭐', 'Level 5'),
              const Spacer(),
              Text(
                '+2 this week',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(String emoji, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB800).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAction(WidgetRef ref, int index) {
    if (index >= 0) {
      ref.read(bottomNavIndexProvider.notifier).state = index;
    } else {
      // Handle special actions like inventory or achievements
      switch (index) {
        case -1:
          // Navigate to inventory
          break;
        case -2:
          // Navigate to achievements
          break;
      }
    }
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: const Color(0xFFEF4444).withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFEF4444),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Retry logic here
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
