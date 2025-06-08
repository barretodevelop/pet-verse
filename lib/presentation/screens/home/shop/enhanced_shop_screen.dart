// File: lib/presentation/screens/home/shop/enhanced_shop_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/presentation/providers/inventory_provider.dart';
import 'package:petverse/presentation/providers/shop_provider.dart';
import 'package:petverse/presentation/providers/user_provider.dart';
import 'package:petverse/presentation/widgets/animations/bounce_animation.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';

class EnhancedShopScreen extends ConsumerWidget {
  const EnhancedShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopState = ref.watch(shopProvider);
    final userGameData = ref.watch(userGameDataProvider);

    return RefreshIndicator(
      onRefresh: () async {
        // Reload shop data
        ref.invalidate(shopProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user currency
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 600),
              child: _buildShopHeader(context, userGameData),
            ),

            const SizedBox(height: ThemeConfig.spacing24),

            // Category filters
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 700),
              child: _buildCategoryFilters(context, ref, shopState),
            ),

            const SizedBox(height: ThemeConfig.spacing24),

            // Items grid
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 800),
              child: _buildItemsGrid(context, ref, shopState),
            ),

            const SizedBox(height: ThemeConfig.spacing20),
          ],
        ),
      ),
    );
  }

  Widget _buildShopHeader(BuildContext context, UserGameDataState userGameData) {
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
                        'Pet Shop 🛒',
                        style: TextStyle(
                          fontSize: ThemeConfig.fontSize28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: ThemeConfig.spacing8),
                      Text(
                        'Everything your pets need to be happy!',
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

            const SizedBox(height: ThemeConfig.spacing16),

            // User currency display
            if (userGameData.hasUser)
              Container(
                padding: const EdgeInsets.all(ThemeConfig.spacing12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCurrencyItem('💰', userGameData.user!.coins),
                    _buildCurrencyItem('💎', userGameData.user!.gems),
                    _buildCurrencyItem('⭐', userGameData.user!.totalXp),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyItem(String emoji, int value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: ThemeConfig.fontSize16)),
        const SizedBox(width: ThemeConfig.spacing4),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: ThemeConfig.fontSize14,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters(BuildContext context, WidgetRef ref, ShopState shopState) {
    const categories = ItemCategory.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: ThemeConfig.spacing12),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1, // +1 for "All" option
            itemBuilder: (context, index) {
              if (index == 0) {
                // "All" filter
                return _buildCategoryChip(
                  context,
                  ref,
                  'All',
                  null,
                  shopState.selectedCategory == null,
                );
              }

              final category = categories[index - 1];
              return _buildCategoryChip(
                context,
                ref,
                _getCategoryName(category),
                category,
                shopState.selectedCategory == category,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    ItemCategory? category,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: ThemeConfig.spacing8),
      child: BounceAnimation(
        onTap: () {
          ref.read(shopProvider.notifier).selectCategory(category);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConfig.spacing16,
            vertical: ThemeConfig.spacing8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? ThemeConfig.primaryColor : Colors.grey[200],
            borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: ThemeConfig.fontSize14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemsGrid(BuildContext context, WidgetRef ref, ShopState shopState) {
    if (shopState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!shopState.hasItems) {
      return const Center(
        child: Text('No items available'),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: ThemeConfig.spacing12,
        mainAxisSpacing: ThemeConfig.spacing12,
      ),
      itemCount: shopState.filteredItems.length,
      itemBuilder: (context, index) {
        final item = shopState.filteredItems[index];
        return _buildShopItemCard(context, ref, item);
      },
    );
  }

  Widget _buildShopItemCard(BuildContext context, WidgetRef ref, ShopItem item) {
    return BounceAnimation(
      onTap: () => _showPurchaseDialog(context, ref, item),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacing12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item image
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                  ),
                  child: Center(
                    child: Text(
                      _getCategoryEmoji(item.category),
                      style: const TextStyle(fontSize: ThemeConfig.fontSize48),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: ThemeConfig.spacing8),

              // Item name
              Text(
                item.name,
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
                item.description,
                style: TextStyle(
                  fontSize: ThemeConfig.fontSize12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: ThemeConfig.spacing8),

              // Price and buy button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${item.price} ${_getCurrencyEmoji(item.currency)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(item.category),
                      fontSize: ThemeConfig.fontSize14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(ThemeConfig.spacing4),
                    decoration: BoxDecoration(
                      color: ThemeConfig.primaryColor,
                      borderRadius: BorderRadius.circular(ThemeConfig.borderRadius4),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                      size: ThemeConfig.iconSize16,
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

  void _showPurchaseDialog(BuildContext context, WidgetRef ref, ShopItem item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Purchase ${item.name}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.description),
              const SizedBox(height: ThemeConfig.spacing16),
              Text(
                'Price: ${item.price} ${_getCurrencyEmoji(item.currency)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ThemeConfig.fontSize16,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _purchaseItem(context, ref, item);
              },
              child: const Text('Buy'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _purchaseItem(BuildContext context, WidgetRef ref, ShopItem item) async {
    final result = await ref.read(shopProvider.notifier).purchaseItem(item);

    if (result.success) {
      // Add to inventory
      ref.read(inventoryProvider.notifier).addItem(item, 1);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: ThemeConfig.successColor,
          ),
        );
      }
    }
  }

  String _getCategoryName(ItemCategory category) {
    switch (category) {
      case ItemCategory.food:
        return 'Food';
      case ItemCategory.toys:
        return 'Toys';
      case ItemCategory.medicine:
        return 'Medicine';
      case ItemCategory.accessories:
        return 'Accessories';
      case ItemCategory.special:
        return 'Special';
    }
  }

  String _getCategoryEmoji(ItemCategory category) {
    switch (category) {
      case ItemCategory.food:
        return '🍖';
      case ItemCategory.toys:
        return '🎾';
      case ItemCategory.medicine:
        return '💊';
      case ItemCategory.accessories:
        return '👑';
      case ItemCategory.special:
        return '⭐';
    }
  }

  Color _getCategoryColor(ItemCategory category) {
    switch (category) {
      case ItemCategory.food:
        return ThemeConfig.hungerColor;
      case ItemCategory.toys:
        return ThemeConfig.happinessColor;
      case ItemCategory.medicine:
        return Colors.red;
      case ItemCategory.accessories:
        return Colors.purple;
      case ItemCategory.special:
        return ThemeConfig.accentColor;
    }
  }

  String _getCurrencyEmoji(CurrencyType currency) {
    switch (currency) {
      case CurrencyType.coins:
        return '💰';
      case CurrencyType.gems:
        return '💎';
      case CurrencyType.xp:
        return '⭐';
    }
  }
}
