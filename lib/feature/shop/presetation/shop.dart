import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/economy/game_item.dart';
import 'package:petverse/core/model/mocks.dart';
import 'package:petverse/core/providers/shop_provider.dart';

// Import dos módulos criados
// import 'shop_models.dart';
// import 'shop_providers.dart';

class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredItemsAsync = ref.watch(filteredShopItemsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final wallet = ref.watch(userWalletProvider);
    final isLoadingPurchase = ref.watch(isLoadingPurchaseProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, ref, wallet),
      body: Stack(
        children: [
          Column(
            children: [
              _buildCategoryTabs(context, ref, selectedCategory),
              _buildSearchBar(context, ref),
              Expanded(
                child: filteredItemsAsync.when(
                  loading: () => _buildLoadingState(),
                  error: (error, stack) =>
                      _buildErrorState(context, ref, error.toString()),
                  data: (items) => _buildItemsGrid(context, ref, items, wallet),
                ),
              ),
            ],
          ),
          if (isLoadingPurchase) _buildPurchaseLoadingOverlay(),
        ],
      ),
      floatingActionButton: _buildFloatingActions(context, ref),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, UserWallet wallet) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back_ios,
          color: const Color(0xFF0F172A),
          size: 22.sp,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loja de Itens',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          Text(
            'Encontre tudo para seu pet',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🪙', style: TextStyle(fontSize: 16.sp)),
              SizedBox(width: 4.w),
              Text(
                '${wallet.coins}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              Text('💎', style: TextStyle(fontSize: 16.sp)),
              SizedBox(width: 4.w),
              Text(
                '${wallet.gems}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs(
      BuildContext context, WidgetRef ref, ItemCategory selectedCategory) {
    final categoriesWithCount = ref.watch(categoriesWithCountProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categoriesWithCount.map<Widget>((catData) {
            final category = catData['category'] as ItemCategory;
            final isSelected = selectedCategory == category;
            final count = catData['count'] as int;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(selectedCategoryProvider.notifier).state = category;
              },
              child: Container(
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFE2E8F0),
                    width: 1.w,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      catData['emoji'] as String,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      catData['name'] as String,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                    if (count > 0) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : const Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value;
        },
        decoration: InputDecoration(
          hintText: 'Buscar itens...',
          hintStyle: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: const Color(0xFF64748B),
            size: 20.sp,
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF3B82F6),
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            'Carregando itens...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64.sp,
              color: const Color(0xFFEF4444),
            ),
            SizedBox(height: 16.h),
            Text(
              'Ops! Algo deu errado',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Não foi possível carregar os itens da loja',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(shopItemsProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              icon: Icon(Icons.refresh, size: 18.sp, color: Colors.white),
              label: Text(
                'Tentar Novamente',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsGrid(BuildContext context, WidgetRef ref,
      List<GameItem> items, UserWallet wallet) {
    if (items.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    return GridView.builder(
      padding: EdgeInsets.all(20.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItemCard(context, ref, items[index], wallet, index);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '📦',
              style: TextStyle(fontSize: 64.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Nenhum item encontrado',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Não há itens disponíveis em "${selectedCategory.displayName}"',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            TextButton.icon(
              onPressed: () {
                ref.read(selectedCategoryProvider.notifier).state =
                    ItemCategory.food;
              },
              icon: Icon(Icons.category, size: 18.sp),
              label: const Text('Ver Todas as Categorias'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, WidgetRef ref, GameItem item,
      UserWallet wallet, int index) {
    final canAfford = wallet.canAfford(item);
    final itemQuantity =
        ref.watch(userInventoryProvider.notifier).getItemQuantity(item.id);
    final rarityColor = Color(item.rarity.colorValue);

    return GestureDetector(
      onTap: () => _showItemDetails(context, ref, item, wallet),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: rarityColor.withOpacity(0.3),
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: rarityColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Item Icon with quantity badge
            Stack(
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: rarityColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: rarityColor.withOpacity(0.2),
                      width: 1.w,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      item.emoji,
                      style: TextStyle(fontSize: 32.sp),
                    ),
                  ),
                ),
                if (itemQuantity > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$itemQuantity',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 12.h),

            // Item Name
            Text(
              item.name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 6.h),

            // Rarity Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: rarityColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                item.rarity.displayName,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            const Spacer(),

            // Effects Preview
            if (item.effects.isNotEmpty) ...[
              Wrap(
                spacing: 4.w,
                runSpacing: 4.h,
                children: item.effects.entries.take(2).map((effect) {
                  final effectData = MockDataService.getEffectData(effect.key);
                  return Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '+${effect.value.toInt()}${effect.key == 'xp_multiplier' ? 'x' : '%'} ${effectData['emoji']}',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 8.h),
            ],

            // Price Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canAfford
                    ? () => _showPurchaseConfirmation(context, ref, item)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford
                      ? const Color(0xFF10B981)
                      : const Color(0xFF94A3B8),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.coins != null) ...[
                      Text('🪙', style: TextStyle(fontSize: 12.sp)),
                      SizedBox(width: 2.w),
                      Text(
                        '${item.coins}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    if (item.coins != null && item.gems != null) ...[
                      SizedBox(width: 4.w),
                      Text('+',
                          style:
                              TextStyle(fontSize: 9.sp, color: Colors.white)),
                      SizedBox(width: 4.w),
                    ],
                    if (item.gems != null) ...[
                      Text('💎', style: TextStyle(fontSize: 12.sp)),
                      SizedBox(width: 2.w),
                      Text(
                        '${item.gems}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                    if (item.isFree) ...[
                      Icon(Icons.card_giftcard,
                          size: 14.sp, color: Colors.white),
                      SizedBox(width: 4.w),
                      Text(
                        'Grátis',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
        .slideY(begin: 0.2, end: 0.0);
  }

  void _showItemDetails(
      BuildContext context, WidgetRef ref, GameItem item, UserWallet wallet) {
    final canAfford = wallet.canAfford(item);
    final itemQuantity =
        ref.read(userInventoryProvider.notifier).getItemQuantity(item.id);
    final rarityColor = Color(item.rarity.colorValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.r),
            topRight: Radius.circular(28.r),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    // Item Icon Large
                    Stack(
                      children: [
                        Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            color: rarityColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: rarityColor.withOpacity(0.3),
                              width: 2.w,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              item.emoji,
                              style: TextStyle(fontSize: 60.sp),
                            ),
                          ),
                        ),
                        if (itemQuantity > 0)
                          Positioned(
                            right: 5.w,
                            top: 5.h,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Possui: $itemQuantity',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 12.h),

                    // Rarity Badge
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: rarityColor,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: rarityColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            item.rarity.displayName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 28.h),

                    // Effects Detail
                    if (item.effects.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.w,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_fix_high,
                                  size: 20.sp,
                                  color: const Color(0xFF3B82F6),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Efeitos do Item',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            ...item.effects.entries.map((effect) {
                              final effectData =
                                  MockDataService.getEffectData(effect.key);
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32.w,
                                      height: 32.w,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981)
                                            .withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          effectData['emoji'],
                                          style: TextStyle(fontSize: 16.sp),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            effectData['name'],
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                          Text(
                                            effectData['description'],
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        '+${effect.value.toInt()}${effect.key == 'xp_multiplier' ? 'x' : '%'}',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      SizedBox(height: 28.h),
                    ],

                    // Price Display
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: canAfford
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: canAfford
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                          width: 1.w,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                canAfford ? Icons.check_circle : Icons.cancel,
                                size: 20.sp,
                                color: canAfford
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                canAfford
                                    ? 'Você pode comprar este item'
                                    : 'Saldo insuficiente',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: canAfford
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Preço: ',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              if (item.coins != null) ...[
                                Text('🪙', style: TextStyle(fontSize: 20.sp)),
                                SizedBox(width: 4.w),
                                Text(
                                  '${item.coins}',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                              if (item.coins != null && item.gems != null) ...[
                                SizedBox(width: 8.w),
                                Text(
                                  '+',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                              ],
                              if (item.gems != null) ...[
                                Text('💎', style: TextStyle(fontSize: 20.sp)),
                                SizedBox(width: 4.w),
                                Text(
                                  '${item.gems}',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                              if (item.isFree) ...[
                                Icon(
                                  Icons.card_giftcard,
                                  size: 24.sp,
                                  color: const Color(0xFF10B981),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Grátis!',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Purchase Button
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canAfford
                      ? () {
                          Navigator.pop(context);
                          _showPurchaseConfirmation(context, ref, item);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford
                        ? const Color(0xFF10B981)
                        : const Color(0xFF94A3B8),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        canAfford ? Icons.shopping_cart_checkout : Icons.block,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        canAfford ? 'Comprar Agora' : 'Saldo Insuficiente',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseConfirmation(
      BuildContext context, WidgetRef ref, GameItem item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        title: Row(
          children: [
            Text(
              item.emoji,
              style: TextStyle(fontSize: 28.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Confirmar Compra',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tem certeza que deseja comprar "${item.name}"?',
              style: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.w,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detalhes da compra:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Item:',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Custo:',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Row(
                        children: [
                          if (item.coins != null) ...[
                            Text('🪙', style: TextStyle(fontSize: 16.sp)),
                            SizedBox(width: 4.w),
                            Text(
                              '${item.coins}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                          if (item.coins != null && item.gems != null) ...[
                            SizedBox(width: 8.w),
                            Text(' + ', style: TextStyle(fontSize: 12.sp)),
                            SizedBox(width: 8.w),
                          ],
                          if (item.gems != null) ...[
                            Text('💎', style: TextStyle(fontSize: 16.sp)),
                            SizedBox(width: 4.w),
                            Text(
                              '${item.gems}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                          if (item.isFree) ...[
                            Text(
                              'Grátis',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _purchaseItem(context, ref, item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Confirmar Compra',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _purchaseItem(BuildContext context, WidgetRef ref, GameItem item) async {
    try {
      HapticFeedback.mediumImpact();

      // Set loading state
      ref.read(isLoadingPurchaseProvider.notifier).state = true;

      // Process purchase using the action provider
      await ref.read(purchaseItemProvider(item));

      // Remove loading state
      ref.read(isLoadingPurchaseProvider.notifier).state = false;

      // Show success animation
      _showPurchaseSuccessAnimation(context, item);
    } catch (e) {
      // Remove loading state
      ref.read(isLoadingPurchaseProvider.notifier).state = false;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Erro ao processar compra: ${e.toString()}',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
    }
  }

  void _showPurchaseSuccessAnimation(BuildContext context, GameItem item) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 240.w,
            height: 240.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      item.emoji,
                      style: TextStyle(fontSize: 50.sp),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Icon(
                  Icons.check_circle,
                  size: 32.sp,
                  color: const Color(0xFF10B981),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Compra Realizada!',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                  ),
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .scale(
                duration: 400.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 200.ms),
        ),
      ),
    );

    // Auto close after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);

        // Show final snackbar confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(item.emoji, style: TextStyle(fontSize: 20.sp)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text('${item.name} foi adicionado ao seu inventário!'),
                ),
                Icon(Icons.inventory_2, color: Colors.white, size: 20.sp),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Ver Inventário',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to inventory (when implemented)
                // Navigator.pushNamed(context, '/inventory');
              },
            ),
          ),
        );
      }
    });
  }

  Widget _buildPurchaseLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF3B82F6),
              ),
              SizedBox(height: 16.h),
              Text(
                'Processando compra...',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActions(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Inventory button
        FloatingActionButton(
          heroTag: "inventory",
          onPressed: () {
            // Navigate to inventory page
            // Navigator.pushNamed(context, '/inventory');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inventário será implementado em breve!'),
                backgroundColor: Color(0xFF3B82F6),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          backgroundColor: const Color(0xFF3B82F6),
          child: Icon(Icons.inventory_2, color: Colors.white, size: 24.sp),
        ),
        SizedBox(height: 16.h),

        // Debug/Reset button (only in development)
        FloatingActionButton(
          heroTag: "debug",
          onPressed: () => _showDebugMenu(context, ref),
          backgroundColor: const Color(0xFF64748B),
          mini: true,
          child: Icon(Icons.developer_mode, color: Colors.white, size: 20.sp),
        ),
      ],
    );
  }

  void _showDebugMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Menu de Desenvolvimento',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reset Loja'),
              onTap: () {
                Navigator.pop(context);
                ref.invalidate(shopItemsProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text('Adicionar 1000 moedas'),
              onTap: () {
                Navigator.pop(context);
                ref.read(userWalletProvider.notifier).addCurrency(coins: 1000);
              },
            ),
            ListTile(
              leading: const Icon(Icons.diamond),
              title: const Text('Adicionar 50 gemas'),
              onTap: () {
                Navigator.pop(context);
                ref.read(userWalletProvider.notifier).addCurrency(gems: 50);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text('Reset Tudo'),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(resetAllDataProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dados resetados!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
