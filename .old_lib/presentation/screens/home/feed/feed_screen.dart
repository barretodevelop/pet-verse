// File: lib/presentation/screens/home/feed/feed_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/utils/formatters.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';

/// Feed screen showing community activity and news
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        // Simulate refresh
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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

            // Quick stats
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 700),
              child: _buildQuickStats(context),
            ),

            const SizedBox(height: ThemeConfig.spacing24),

            // Feed items
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 800),
              child: _buildFeedSection(context),
            ),
          ],
        ),
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
            colors: [Colors.blue[600]!, Colors.cyan[600]!],
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
                        'Community Feed 📰',
                        style: TextStyle(
                          fontSize: ThemeConfig.fontSize28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: ThemeConfig.spacing8),
                      Text(
                        'Stay updated with the pet community!',
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
                    '🌍',
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

  Widget _buildQuickStats(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Stats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('🐾', 'Total Pets', '12.5K'),
                ),
                Expanded(
                  child: _buildStatItem('👥', 'Active Users', '3.2K'),
                ),
                Expanded(
                  child: _buildStatItem('🏆', 'Daily Challenges', '856'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: ThemeConfig.fontSize24),
        ),
        const SizedBox(height: ThemeConfig.spacing4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ThemeConfig.fontSize16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: ThemeConfig.fontSize12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: ThemeConfig.spacing16),
        ...List.generate(_feedItems.length, (index) {
          final item = _feedItems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: ThemeConfig.spacing12),
            child: SlideFadeAnimation(
              duration: Duration(milliseconds: 900 + (index * 100)),
              child: _buildFeedItem(context, item),
            ),
          );
        }),
        const SizedBox(height: ThemeConfig.spacing20),
        _buildLoadMoreButton(context),
      ],
    );
  }

  Widget _buildFeedItem(BuildContext context, Map<String, dynamic> item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: item['color'].withOpacity(0.1),
                  child: Text(
                    item['username'][0].toUpperCase(),
                    style: TextStyle(
                      color: item['color'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: ThemeConfig.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['username'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ThemeConfig.fontSize14,
                        ),
                      ),
                      Text(
                        Formatters.formatRelativeTime(item['timestamp']),
                        style: TextStyle(
                          fontSize: ThemeConfig.fontSize12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConfig.spacing8,
                    vertical: ThemeConfig.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadius4),
                  ),
                  child: Text(
                    item['type'],
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSize10,
                      color: item['color'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: ThemeConfig.spacing12),

            // Content
            Text(
              item['content'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: ThemeConfig.spacing12),

            // Action buttons
            Row(
              children: [
                _buildActionButton(
                  Icons.favorite_outline,
                  '${item['likes']}',
                  ThemeConfig.errorColor,
                  () {},
                ),
                const SizedBox(width: ThemeConfig.spacing16),
                _buildActionButton(
                  Icons.comment_outlined,
                  '${item['comments']}',
                  Colors.blue,
                  () {},
                ),
                const Spacer(),
                _buildActionButton(
                  Icons.share_outlined,
                  'Share',
                  Colors.grey,
                  () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: ThemeConfig.iconSize16,
            color: color,
          ),
          const SizedBox(width: ThemeConfig.spacing4),
          Text(
            label,
            style: TextStyle(
              fontSize: ThemeConfig.fontSize12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton(BuildContext context) {
    return Center(
      child: OutlinedButton(
        onPressed: () {
          // Load more functionality
        },
        child: const Text('Load More Posts'),
      ),
    );
  }

  // Mock data
  static final List<Map<String, dynamic>> _feedItems = [
    {
      'username': 'PetLover123',
      'content': 'Just adopted a new pet! So excited to start this journey! 🐶',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'type': 'Adoption',
      'likes': 24,
      'comments': 8,
      'color': ThemeConfig.successColor,
    },
    {
      'username': 'GameMaster99',
      'content': 'Completed the daily challenge and earned 100 coins! Who else is playing today?',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'type': 'Achievement',
      'likes': 15,
      'comments': 3,
      'color': ThemeConfig.accentColor,
    },
    {
      'username': 'AnimalFriend',
      'content': 'My pet just reached level 10! Time to celebrate with some premium food 🎉',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'type': 'Level Up',
      'likes': 31,
      'comments': 12,
      'color': ThemeConfig.primaryColor,
    },
    {
      'username': 'CasualPlayer',
      'content':
          'Does anyone have tips for keeping pet happiness high? Mine seems to get sad quickly.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 4)),
      'type': 'Question',
      'likes': 8,
      'comments': 15,
      'color': Colors.orange,
    },
  ];
}
