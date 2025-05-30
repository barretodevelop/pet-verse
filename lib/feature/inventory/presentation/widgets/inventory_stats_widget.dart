// lib/features/shop/presentation/widgets/inventory_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/enums/enums.dart';
import 'package:petverse/core/model/economy/game_item.dart';
import 'package:petverse/core/providers/inventory_providers.dart';

// Import providers and models
// import '../../application/providers/inventory_providers.dart';
// import '../../domain/models/shop_models.dart';

class InventoryStatsWidget extends ConsumerWidget {
  const InventoryStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(inventoryStatsProvider);
    final consumableItems = ref.watch(consumableItemsProvider);
    final collectibleItems = ref.watch(collectibleItemsProvider);
    final lowStockItems = ref.watch(lowStockItemsProvider);

    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: 20.h),
          _buildOverviewCards(context, stats),
          SizedBox(height: 20.h),
          _buildCategoryBreakdown(context, stats['category_breakdown']),
          SizedBox(height: 20.h),
          _buildRarityBreakdown(context, stats['rarity_breakdown']),
          SizedBox(height: 20.h),
          _buildQuickActions(
              context, ref, consumableItems, collectibleItems, lowStockItems),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.analytics,
            color: const Color(0xFF3B82F6),
            size: 24.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estatísticas do Inventário',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                'Resumo dos seus itens',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCards(BuildContext context, Map<String, dynamic> stats) {
    final cards = [
      {
        'title': 'Total de Itens',
        'value': '${stats['total_items']}',
        'icon': Icons.inventory_2,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Valor Total',
        'value': '${stats['total_value'].toInt()}',
        'subtitle': 'moedas',
        'icon': Icons.monetization_on,
        'color': const Color(0xFFF59E0B),
      },
      {
        'title': 'Itens Únicos',
        'value': '${stats['unique_items']}',
        'icon': Icons.star,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Valor Médio',
        'value': '${stats['average_value'].toInt()}',
        'subtitle': 'por item',
        'icon': Icons.trending_up,
        'color': const Color(0xFF3B82F6),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.2,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: (card['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: (card['color'] as Color).withOpacity(0.2),
              width: 1.w,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                card['icon'] as IconData,
                color: card['color'] as Color,
                size: 24.sp,
              ),
              const Spacer(),
              Text(
                card['value'] as String,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              if (card['subtitle'] != null) ...[
                Text(
                  card['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
              SizedBox(height: 4.h),
              Text(
                card['title'] as String,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: 100 * index))
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
      },
    );
  }

  Widget _buildCategoryBreakdown(
      BuildContext context, Map<ItemCategory, int> categoryBreakdown) {
    final total = categoryBreakdown.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Por Categoria',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 12.h),
        ...categoryBreakdown.entries.map((entry) {
          final category = entry.key;
          final count = entry.value;
          final percentage = count / total;

          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Text(
                  category.emoji,
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            category.displayName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '$count itens',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(category.hashCode | 0xFF000000),
                          ),
                          minHeight: 6.h,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRarityBreakdown(
      BuildContext context, Map<ItemRarity, int> rarityBreakdown) {
    final total = rarityBreakdown.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Por Raridade',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: rarityBreakdown.entries.map((entry) {
            final rarity = entry.key;
            final count = entry.value;
            final percentage = total > 0 ? (count / total * 100).round() : 0;

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Color(rarity.colorValue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Color(rarity.colorValue).withOpacity(0.3),
                    width: 1.w,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: Color(rarity.colorValue),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      rarity.displayName,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    WidgetRef ref,
    List<InventoryItem> consumableItems,
    List<InventoryItem> collectibleItems,
    List<InventoryItem> lowStockItems,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                title: 'Consumíveis',
                subtitle: '${consumableItems.length} itens',
                icon: Icons.fastfood,
                color: const Color(0xFF10B981),
                onTap: () =>
                    _showConsumableItems(context, ref, consumableItems),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildActionCard(
                context,
                title: 'Colecionáveis',
                subtitle: '${collectibleItems.length} itens',
                icon: Icons.collections,
                color: const Color(0xFF8B5CF6),
                onTap: () =>
                    _showCollectibleItems(context, ref, collectibleItems),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (lowStockItems.isNotEmpty) ...[
          _buildActionCard(
            context,
            title: 'Estoque Baixo',
            subtitle: '${lowStockItems.length} itens com pouca quantidade',
            icon: Icons.warning_amber,
            color: const Color(0xFFF59E0B),
            onTap: () => _showLowStockItems(context, ref, lowStockItems),
            fullWidth: true,
          ),
        ],
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : null,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  void _showConsumableItems(
      BuildContext context, WidgetRef ref, List<InventoryItem> items) {
    _showItemsList(
      context,
      title: 'Itens Consumíveis',
      items: items,
      emptyMessage: 'Nenhum item consumível encontrado',
    );
  }

  void _showCollectibleItems(
      BuildContext context, WidgetRef ref, List<InventoryItem> items) {
    _showItemsList(
      context,
      title: 'Itens Colecionáveis',
      items: items,
      emptyMessage: 'Nenhum item colecionável encontrado',
    );
  }

  void _showLowStockItems(
      BuildContext context, WidgetRef ref, List<InventoryItem> items) {
    _showItemsList(
      context,
      title: 'Estoque Baixo',
      items: items,
      emptyMessage: 'Todos os itens têm estoque adequado',
    );
  }

  void _showItemsList(
    BuildContext context, {
    required String title,
    required List<InventoryItem> items,
    required String emptyMessage,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFE2E8F0),
                    width: 1.w,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      size: 24.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox,
                            size: 64.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            emptyMessage,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(20.w),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                item.item.emoji,
                                style: TextStyle(fontSize: 32.sp),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.item.name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      'Quantidade: ${item.quantity}',
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
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(item.item.rarity.colorValue),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  item.item.rarity.displayName,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
