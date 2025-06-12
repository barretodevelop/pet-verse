// File: lib/presentation/screens/home/shop/enhanced_shop_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/domain/entities/shop_item_entity.dart';
import 'package:petverse/presentation/providers/user_provider.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';

/// Enhanced Shop Screen with gaming-focused design
class EnhancedShopScreen extends ConsumerStatefulWidget {
  const EnhancedShopScreen({super.key});

  @override
  ConsumerState<EnhancedShopScreen> createState() => _EnhancedShopScreenState();
}

class _EnhancedShopScreenState extends ConsumerState<EnhancedShopScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late TabController _categoryController;
  final TextEditingController _searchController = TextEditingController();

  ItemCategory _selectedCategory = ItemCategory.food;
  String _searchQuery = '';
  bool _showCart = false;

  // Mock data for demonstration
  final List<ShopItemEntity> _mockItems = [
    ShopItemEntity(
      id: 'food_basic_meat',
      name: 'Basic Meat',
      description: 'Simple meat that restores hunger',
      imageUrl: '🍖',
      basePrice: 10,
      currency: CurrencyType.coins,
      category: ItemCategory.food,
      rarity: ItemRarity.common,
      effects: const {ItemEffectType.hunger: 25},
      createdAt: DateTime.now(),
    ),
    ShopItemEntity(
      id: 'food_premium_steak',
      name: 'Premium Steak',
      description: 'Delicious steak that greatly restores hunger',
      imageUrl: '🥩',
      basePrice: 25,
      currency: CurrencyType.coins,
      category: ItemCategory.food,
      rarity: ItemRarity.uncommon,
      effects: const {ItemEffectType.hunger: 45, ItemEffectType.happiness: 10},
      createdAt: DateTime.now(),
    ),
    ShopItemEntity(
      id: 'food_superfood',
      name: 'Superfood',
      description: 'Magical food that boosts all stats',
      imageUrl: '⭐',
      basePrice: 2,
      currency: CurrencyType.gems,
      category: ItemCategory.food,
      rarity: ItemRarity.epic,
      effects: const {
        ItemEffectType.hunger: 50,
        ItemEffectType.happiness: 30,
        ItemEffectType.energy: 20
      },
      createdAt: DateTime.now(),
    ),

    // TOY ITEMS
    ShopItemEntity(
      id: 'toy_ball',
      name: 'Ball',
      description: 'Simple ball that makes pets happy',
      imageUrl: '⚽',
      basePrice: 15,
      currency: CurrencyType.coins,
      category: ItemCategory.toy,
      rarity: ItemRarity.common,
      effects: const {ItemEffectType.happiness: 30},
      createdAt: DateTime.now(),
    ),
    ShopItemEntity(
      id: 'toy_premium_rope',
      name: 'Premium Rope',
      description: 'High-quality rope toy',
      imageUrl: '🪢',
      basePrice: 35,
      currency: CurrencyType.coins,
      category: ItemCategory.toy,
      rarity: ItemRarity.rare,
      effects: const {ItemEffectType.happiness: 50, ItemEffectType.energy: -5},
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _categoryController = TabController(
      length: ItemCategory.values.length,
      vsync: this,
    );

    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _categoryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ShopItemEntity> get _filteredItems {
    return _mockItems.where((item) {
      final matchesCategory = item.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty || item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch && item.isAvailable;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userGameDataProvider);

    return Scaffold(
      body: Column(
        children: [
          // Enhanced Shop Header
          SlideFadeAnimation(
            duration: const Duration(milliseconds: 400),
            child: _buildShopHeader(context, userState),
          ),

          // Category Filters
          SlideFadeAnimation(
            duration: const Duration(milliseconds: 500),
            child: _buildCategoryFilters(context),
          ),

          // Search Bar
          SlideFadeAnimation(
            duration: const Duration(milliseconds: 600),
            child: _buildSearchBar(context),
          ),

          // Featured Items Section
          if (_selectedCategory == ItemCategory.food) ...[
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 700),
              child: _buildFeaturedSection(context),
            ),
          ],

          // Items Grid
          Expanded(
            child: SlideFadeAnimation(
              duration: const Duration(milliseconds: 800),
              child: _buildItemsGrid(context),
            ),
          ),
        ],
      ),

      // Floating Cart Button
      floatingActionButton: _buildFloatingCart(context),
    );
  }

  Widget _buildShopHeader(BuildContext context, userState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pet Shop 🛍️',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Find everything for your pet!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Settings or profile
                  },
                  icon: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Currency Display
            Row(
              children: [
                Expanded(
                  child: _buildCurrencyCard(
                    'Coins',
                    userState.user?.coins ?? 0,
                    Icons.monetization_on,
                    const Color(0xFFFFB800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCurrencyCard(
                    'Gems',
                    userState.user?.gems ?? 0,
                    Icons.diamond,
                    const Color(0xFF00D2FF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyCard(String title, int amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            amount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ItemCategory.values.length,
        itemBuilder: (context, index) {
          final category = ItemCategory.values[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        )
                      : null,
                  color: isSelected ? null : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getCategoryEmoji(category),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getCategoryName(category),
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search items...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF6366F1)),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: const Icon(Icons.clear),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context) {
    final featuredItems = _mockItems
        .where((item) => item.rarity == ItemRarity.epic || item.rarity == ItemRarity.legendary)
        .take(3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.star, color: Color(0xFFFFB800), size: 20),
              const SizedBox(width: 8),
              Text(
                'Featured Items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: featuredItems.length,
            itemBuilder: (context, index) {
              final item = featuredItems[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildFeaturedItemCard(item),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFeaturedItemCard(ShopItemEntity item) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: _getRarityGradient(item.rarity),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getRarityColor(item.rarity).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                item.imageUrl,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      item.currency == CurrencyType.coins ? Icons.monetization_on : Icons.diamond,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.basePrice}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsGrid(BuildContext context) {
    if (_filteredItems.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        return _buildEnhancedItemCard(_filteredItems[index]);
      },
    );
  }

  Widget _buildEnhancedItemCard(ShopItemEntity item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showItemDetails(item),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image with rarity background
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: _getRarityGradient(item.rarity),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        item.imageUrl,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                    // Rarity Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _buildRarityBadge(item.rarity),
                    ),
                  ],
                ),
              ),
            ),

            // Item Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          item.currency == CurrencyType.coins
                              ? Icons.monetization_on
                              : Icons.diamond,
                          size: 16,
                          color: item.currency == CurrencyType.coins
                              ? const Color(0xFFFFB800)
                              : const Color(0xFF00D2FF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.basePrice}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item.currency == CurrencyType.coins
                                ? const Color(0xFFFFB800)
                                : const Color(0xFF00D2FF),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            size: 16,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRarityBadge(ItemRarity rarity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        rarity.name.toUpperCase(),
        style: TextStyle(
          color: _getRarityColor(rarity),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for different items or check other categories',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCart(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _showCart = !_showCart;
        });
      },
      backgroundColor: const Color(0xFF6366F1),
      child: Stack(
        children: [
          const Icon(Icons.shopping_cart, color: Colors.white),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(6),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: const Text(
                '3', // Mock cart count
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(ShopItemEntity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item header
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: _getRarityGradient(item.rarity),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              item.imageUrl,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildRarityBadge(item.rarity),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Effects
                    if (item.effects.isNotEmpty) ...[
                      const Text(
                        'Effects:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...item.effects.entries.map(
                        (effect) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6366F1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${effect.key}: +${effect.value}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Purchase button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _purchaseItem(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.currency == CurrencyType.coins
                                  ? Icons.monetization_on
                                  : Icons.diamond,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Buy for ${item.basePrice}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _purchaseItem(ShopItemEntity item) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart! 🛒'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Helper methods

  String _getCategoryName(ItemCategory category) {
    switch (category) {
      case ItemCategory.food:
        return 'Food';
      case ItemCategory.toy:
        return 'Toys';
      case ItemCategory.medicine:
        return 'Medicine';
      case ItemCategory.decoration:
        return 'Decoration';
      case ItemCategory.accessory:
        return 'Accessories';
      case ItemCategory.special:
        return 'Special';
    }
  }

  String _getCategoryEmoji(ItemCategory category) {
    switch (category) {
      case ItemCategory.food:
        return '🍖';
      case ItemCategory.toy:
        return '🎾';
      case ItemCategory.medicine:
        return '💊';
      case ItemCategory.decoration:
        return '🎨';
      case ItemCategory.accessory:
        return '👔';
      case ItemCategory.special:
        return '✨';
    }
  }

  LinearGradient _getRarityGradient(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return const LinearGradient(
          colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
        );
      case ItemRarity.rare:
        return const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        );
      case ItemRarity.epic:
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        );
      case ItemRarity.legendary:
        return const LinearGradient(
          colors: [Color(0xFFFFB800), Color(0xFFF59E0B)],
        );
      case ItemRarity.uncommon:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return const Color(0xFF9CA3AF);
      case ItemRarity.rare:
        return const Color(0xFF3B82F6);
      case ItemRarity.epic:
        return const Color(0xFF8B5CF6);
      case ItemRarity.legendary:
        return const Color(0xFFFFB800);
      case ItemRarity.uncommon:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}
