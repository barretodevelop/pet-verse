// File: lib/presentation/screens/home/games/games_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme_config.dart';
import '../../../widgets/animations/bounce_animation.dart';
import '../../../widgets/animations/slide_fade_animation.dart';

/// Games screen with mini-games and challenges
class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConfig.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          SlideFadeAnimation(
            duration: const Duration(milliseconds: 600),
            child: _buildHeader(context),
          ),

          const SizedBox(height: ThemeConfig.spacing24),

          // Daily challenge
          SlideFadeAnimation(
            duration: const Duration(milliseconds: 700),
            child: _buildDailyChallengeSection(context),
          ),

          const SizedBox(height: ThemeConfig.spacing24),

          // Mini games
          SlideFadeAnimation(
            duration: const Duration(milliseconds: 800),
            child: _buildMiniGamesSection(context),
          ),

          const SizedBox(height: ThemeConfig.spacing24),

          // Leaderboard
          SlideFadeAnimation(
            duration: const Duration(milliseconds: 900),
            child: _buildLeaderboardSection(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
          gradient: LinearGradient(
            colors: [Colors.purple[600]!, Colors.blue[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                      const Text(
                        'Game Center 🎮',
                        style: TextStyle(
                          fontSize: ThemeConfig.fontSize28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: ThemeConfig.spacing8),
                      Text(
                        'Play games to earn rewards and have fun!',
                        style: TextStyle(
                          fontSize: ThemeConfig.fontSize16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(ThemeConfig.spacing16),
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
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallengeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Challenge',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: ThemeConfig.spacing12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(ThemeConfig.spacing16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: ThemeConfig.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
                  ),
                  child: const Center(
                    child: Text(
                      '🎯',
                      style: TextStyle(fontSize: ThemeConfig.fontSize24),
                    ),
                  ),
                ),
                const SizedBox(width: ThemeConfig.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Feed 5 Pets',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ThemeConfig.fontSize16,
                        ),
                      ),
                      const SizedBox(height: ThemeConfig.spacing4),
                      Text(
                        'Progress: 1/5',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: ThemeConfig.fontSize14,
                        ),
                      ),
                      const SizedBox(height: ThemeConfig.spacing8),
                      LinearProgressIndicator(
                        value: 0.2,
                        backgroundColor: ThemeConfig.accentColor.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(ThemeConfig.accentColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: ThemeConfig.spacing16),
                Column(
                  children: [
                    const Text(
                      'Reward',
                      style: TextStyle(
                        fontSize: ThemeConfig.fontSize12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: ThemeConfig.spacing4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeConfig.spacing8,
                        vertical: ThemeConfig.spacing4,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeConfig.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius4),
                      ),
                      child: const Text(
                        '+100 💰',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ThemeConfig.accentColor,
                          fontSize: ThemeConfig.fontSize12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniGamesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mini Games',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: ThemeConfig.spacing16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: ThemeConfig.spacing12,
            mainAxisSpacing: ThemeConfig.spacing12,
          ),
          itemCount: _miniGames.length,
          itemBuilder: (context, index) {
            final game = _miniGames[index];
            return _buildGameCard(context, game);
          },
        ),
      ],
    );
  }

  Widget _buildGameCard(BuildContext context, Map<String, dynamic> game) {
    return BounceAnimation(
      child: Card(
        child: InkWell(
          onTap: () => _showComingSoonDialog(context),
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
          child: Padding(
            padding: const EdgeInsets.all(ThemeConfig.spacing16),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: game['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
                  ),
                  child: Center(
                    child: Text(
                      game['emoji'],
                      style: const TextStyle(fontSize: ThemeConfig.fontSize24),
                    ),
                  ),
                ),
                const SizedBox(height: ThemeConfig.spacing12),
                Text(
                  game['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ThemeConfig.fontSize14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: ThemeConfig.spacing4),
                Text(
                  game['description'],
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSize12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.leaderboard,
                  color: ThemeConfig.primaryColor,
                ),
                const SizedBox(width: ThemeConfig.spacing8),
                Text(
                  'Leaderboard',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            ...List.generate(3, (index) {
              final player = _leaderboardData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing4),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getRankColor(index + 1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: ThemeConfig.fontSize12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: ThemeConfig.spacing12),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: ThemeConfig.primaryColor.withOpacity(0.1),
                      child: Text(
                        player['name'][0],
                        style: const TextStyle(
                          color: ThemeConfig.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: ThemeConfig.spacing12),
                    Expanded(
                      child: Text(
                        player['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${player['score']} pts',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: ThemeConfig.spacing12),
            Center(
              child: TextButton(
                onPressed: () => _showComingSoonDialog(context),
                child: const Text('View Full Leaderboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return ThemeConfig.accentColor;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.orange[400]!;
      default:
        return Colors.grey;
    }
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: ThemeConfig.primaryColor),
            SizedBox(width: ThemeConfig.spacing8),
            Text('Coming Soon'),
          ],
        ),
        content: const Text(
          'This game is under development and will be available in a future update. Stay tuned for exciting mini-games!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Mock data
  static final List<Map<String, dynamic>> _miniGames = [
    {
      'name': 'Pet Match',
      'description': 'Match pets to score points',
      'emoji': '🧩',
      'color': Colors.blue,
    },
    {
      'name': 'Food Catch',
      'description': 'Catch falling food items',
      'emoji': '🍎',
      'color': Colors.green,
    },
    {
      'name': 'Pet Racing',
      'description': 'Race your pets to victory',
      'emoji': '🏃',
      'color': Colors.orange,
    },
    {
      'name': 'Memory Game',
      'description': 'Test your memory skills',
      'emoji': '🧠',
      'color': Colors.purple,
    },
  ];

  static final List<Map<String, dynamic>> _leaderboardData = [
    {'name': 'PetMaster2024', 'score': 15420},
    {'name': 'AnimalLover99', 'score': 12350},
    {'name': 'FurryFriend', 'score': 11200},
  ];
}
