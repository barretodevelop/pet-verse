// File: lib/presentation/screens/home/shop/shop_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/theme_config.dart';
import '../../../widgets/animations/bounce_animation.dart';
import '../../../widgets/animations/slide_fade_animation.dart';

/// Shop screen for purchasing items and upgrades
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

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

          // Featured items
          SlideFadeAnimation(
            duration: const Duration(milliseconds: 700),
            child: _buildFeaturedSection(context),
          ),

          const SizedBox(height: ThemeConfig.spacing24),

          // Categories
          SlideFadeAnimation(
            duration: const Duration(milliseconds: 800),
            child: _buildCategoriesSection(context),
          ),

          const SizedBox(height: ThemeConfig.spacing24),

          // Coming soon items
          SlideFadeAnimation(
            duration: const Duration(milliseconds: 900),
            child: _buildComingSoonSection(context),
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
            colors: [ThemeConfig.accentColor, Colors.orange[600]!],
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
                        'Pet Shop 🛒',
                        style: TextStyle(
                          fontSize: ThemeConfig.fontSize28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: ThemeConfig.spacing8),
                      Text(
                        'Everything your pet needs to be happy!',
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
                    '🏪',
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

  Widget _buildFeaturedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Items',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: ThemeConfig.spacing16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _featuredItems.length,
            itemBuilder: (context, index) {
              final item = _featuredItems[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < _featuredItems.length - 1 ? ThemeConfig.spacing12 : 0,
                ),
                child: _buildFeaturedItemCard(context, item),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedItemCard(BuildContext context, Map<String, dynamic> item) {
    return BounceAnimation(
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item image/icon
              Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: item['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                ),
                child: Center(
                  child: Text(
                    item['emoji'],
                    style: const TextStyle(fontSize: ThemeConfig.fontSize32),
                  ),
                ),
              ),

              const SizedBox(height: ThemeConfig.spacing12),

              // Item name
              Text(
                item['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ThemeConfig.fontSize14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: ThemeConfig.spacing4),

              // Item description
              Text(
                item['description'],
                style: TextStyle(
                  fontSize: ThemeConfig.fontSize12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Price and buy button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item['price']} ${item['currency']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: item['color'],
                    ),
                  ),
                  Icon(
                    Icons.add_shopping_cart,
                    size: ThemeConfig.iconSize16,
                    color: item['color'],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
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
            childAspectRatio: 1.5,
            crossAxisSpacing: ThemeConfig.spacing12,
            mainAxisSpacing: ThemeConfig.spacing12,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _buildCategoryCard(context, category);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> category) {
    return BounceAnimation(
      child: Card(
        child: InkWell(
          onTap: () => _showComingSoonDialog(context),
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
              gradient: LinearGradient(
                colors: [
                  category['color'].withOpacity(0.1),
                  category['color'].withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(ThemeConfig.spacing16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category['emoji'],
                    style: const TextStyle(fontSize: ThemeConfig.fontSize32),
                  ),
                  const SizedBox(height: ThemeConfig.spacing8),
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: category['color'],
                      fontSize: ThemeConfig.fontSize16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoonSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing24),
        child: Column(
          children: [
            Icon(
              Icons.construction,
              size: ThemeConfig.iconSize48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            Text(
              'Shop Coming Soon!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing8),
            Text(
              'We\'re working hard to bring you an amazing shopping experience. Stay tuned for food, toys, accessories, and more!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConfig.spacing20),
            ElevatedButton.icon(
              onPressed: () => _showComingSoonDialog(context),
              icon: const Icon(Icons.notifications),
              label: const Text('Notify Me'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
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
          'This feature is under development and will be available in a future update. Thank you for your patience!',
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
  static final List<Map<String, dynamic>> _featuredItems = [
    {
      'name': 'Premium Food',
      'description': 'Delicious and nutritious',
      'price': 50,
      'currency': 'coins',
      'emoji': '🍖',
      'color': ThemeConfig.hungerColor,
    },
    {
      'name': 'Energy Drink',
      'description': 'Restores energy instantly',
      'price': 30,
      'currency': 'coins',
      'emoji': '⚡',
      'color': ThemeConfig.energyColor,
    },
    {
      'name': 'Luxury Bed',
      'description': 'For the perfect sleep',
      'price': 5,
      'currency': 'gems',
      'emoji': '🛏️',
      'color': Colors.purple,
    },
  ];

  static final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Food',
      'emoji': '🍎',
      'color': ThemeConfig.hungerColor,
    },
    {
      'name': 'Toys',
      'emoji': '🎾',
      'color': ThemeConfig.happinessColor,
    },
    {
      'name': 'Accessories',
      'emoji': '👑',
      'color': Colors.purple,
    },
    {
      'name': 'Medicine',
      'emoji': '💊',
      'color': Colors.red,
    },
  ];
}
