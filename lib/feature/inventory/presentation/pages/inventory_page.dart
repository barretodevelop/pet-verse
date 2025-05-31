// lib/features/shop/presentation/pages/inventory_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/enums/enums.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: ItemCategory.values.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  // @override
  // void dispose() {
  //   _tabController.dispose();
  //   _searchController.dispose();
  //   super.dispose();
  // }

  // @override
  // Widget build(BuildContext context) {
  //   final inventory = ref.watch(userInventoryProvider);
  //   final inventoryByCategory = ref.watch(inventoryByCategoryProvider);
  //   final wallet = ref.watch(userWalletProvider);
  //   final searchQuery = ref.watch(searchQueryProvider);

  //   return Scaffold(
  //     backgroundColor: const Color(0xFFF8FAFC),
  //     appBar: _buildAppBar(context, ref, wallet, inventory),
  //     body: Column(
  //       children: [
  //         _buildSearchAndFilter(context, ref),
  //         _buildCategoryTabs(context, inventoryByCategory),
  //         Expanded(
  //           child: TabBarView(
  //             controller: _tabController,
  //             children: ItemCategory.values.map((category) {
  //               final categoryItems = _filterItems(
  //                   inventoryByCategory[category] ?? [], searchQuery);
  //               return _buildInventoryGrid(
  //                   context, ref, categoryItems, category);
  //             }).toList(),
  //           ),
  //         ),
  //       ],
  //     ),
  //     floatingActionButton: _buildFloatingActions(context, ref),
  //   );
  // }

  // PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref,
  //     UserWallet wallet, List<InventoryItem> inventory) {
  //   final totalItems = inventory.fold(0, (sum, item) => sum + item.quantity);
  //   final totalValue =
  //       inventory.fold(0.0, (sum, item) => sum + item.totalValue);

  //   return AppBar(
  //     backgroundColor: Colors.transparent,
  //     elevation: 0,
  //     leading: IconButton(
  //       onPressed: () => Navigator.pop(context),
  //       icon: Icon(Icons.arrow_back_ios,
  //           color: const Color(0xFF0F172A), size: 22.sp),
  //     ),
  //     title: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Meu Inventário',
  //           style: TextStyle(
  //               fontSize: 20.sp,
  //               fontWeight: FontWeight.w700,
  //               color: const Color(0xFF0F172A)),
  //         ),
  //         Text(
  //           '$totalItems itens • Valor: ${totalValue.toInt()} moedas',
  //           style: TextStyle(
  //               fontSize: 12.sp,
  //               color: const Color(0xFF64748B),
  //               fontWeight: FontWeight.w400),
  //         ),
  //       ],
  //     ),
  //     actions: [
  //       Container(
  //         margin: EdgeInsets.only(right: 16.w),
  //         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
  //         decoration: BoxDecoration(
  //           gradient: const LinearGradient(
  //               colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)]),
  //           borderRadius: BorderRadius.circular(20.r),
  //           boxShadow: [
  //             BoxShadow(
  //                 color: const Color(0xFF8B5CF6).withOpacity(0.3),
  //                 blurRadius: 8,
  //                 offset: const Offset(0, 2))
  //           ],
  //         ),
  //         child: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(Icons.inventory_2, color: Colors.white, size: 16.sp),
  //             SizedBox(width: 6.w),
  //             Text('$totalItems',
  //                 style: TextStyle(
  //                     fontSize: 14.sp,
  //                     fontWeight: FontWeight.w700,
  //                     color: Colors.white)),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildSearchAndFilter(BuildContext context, WidgetRef ref) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Container(
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(16.r),
  //               border: Border.all(color: const Color(0xFFE2E8F0)),
  //               boxShadow: [
  //                 BoxShadow(
  //                     color: Colors.black.withOpacity(0.05),
  //                     blurRadius: 4,
  //                     offset: const Offset(0, 1))
  //               ],
  //             ),
  //             child: TextField(
  //               controller: _searchController,
  //               onChanged: (value) =>
  //                   ref.read(searchQueryProvider.notifier).state = value,
  //               decoration: InputDecoration(
  //                 hintText: 'Buscar no inventário...',
  //                 hintStyle: TextStyle(
  //                     color: const Color(0xFF94A3B8), fontSize: 14.sp),
  //                 prefixIcon: Icon(Icons.search,
  //                     color: const Color(0xFF64748B), size: 20.sp),
  //                 suffixIcon: _searchController.text.isNotEmpty
  //                     ? IconButton(
  //                         onPressed: () {
  //                           _searchController.clear();
  //                           ref.read(searchQueryProvider.notifier).state = '';
  //                         },
  //                         icon: Icon(Icons.clear,
  //                             color: const Color(0xFF64748B), size: 18.sp),
  //                       )
  //                     : null,
  //                 border: InputBorder.none,
  //                 contentPadding:
  //                     EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
  //               ),
  //             ),
  //           ),
  //         ),
  //         SizedBox(width: 12.w),
  //         Container(
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF3B82F6),
  //             borderRadius: BorderRadius.circular(16.r),
  //             boxShadow: [
  //               BoxShadow(
  //                   color: const Color(0xFF3B82F6).withOpacity(0.3),
  //                   blurRadius: 8,
  //                   offset: const Offset(0, 2))
  //             ],
  //           ),
  //           child: IconButton(
  //             onPressed: () => _showFilterOptions(context, ref),
  //             icon: Icon(Icons.tune, color: Colors.white, size: 20.sp),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildCategoryTabs(BuildContext context,
  //     Map<ItemCategory, List<InventoryItem>> inventoryByCategory) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 20.w),
  //     child: TabBar(
  //       controller: _tabController,
  //       isScrollable: true,
  //       indicator: BoxDecoration(
  //         color: const Color(0xFF3B82F6),
  //         borderRadius: BorderRadius.circular(16.r),
  //       ),
  //       labelColor: Colors.white,
  //       unselectedLabelColor: const Color(0xFF64748B),
  //       labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
  //       unselectedLabelStyle:
  //           TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
  //       tabs: ItemCategory.values.map((category) {
  //         final count = inventoryByCategory[category]
  //                 ?.fold(0, (sum, item) => sum + item.quantity) ??
  //             0;
  //         return Tab(
  //           child: Container(
  //             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
  //             child: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(category.emoji),
  //                 SizedBox(width: 6.w),
  //                 Text(category.displayName),
  //                 if (count > 0) ...[
  //                   SizedBox(width: 6.w),
  //                   Container(
  //                     padding:
  //                         EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
  //                     decoration: BoxDecoration(
  //                       color: Colors.white.withOpacity(0.2),
  //                       borderRadius: BorderRadius.circular(8.r),
  //                     ),
  //                     child: Text('$count',
  //                         style: TextStyle(
  //                             fontSize: 10.sp, fontWeight: FontWeight.w700)),
  //                   ),
  //                 ],
  //               ],
  //             ),
  //           ),
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }

  // Widget _buildInventoryGrid(BuildContext context, WidgetRef ref,
  //     List<InventoryItem> items, ItemCategory category) {
  //   if (items.isEmpty) return _buildEmptyState(context, ref, category);

  //   return GridView.builder(
  //     padding: EdgeInsets.all(20.w),
  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 2,
  //       crossAxisSpacing: 16.w,
  //       mainAxisSpacing: 16.h,
  //       childAspectRatio: 0.75,
  //     ),
  //     itemCount: items.length,
  //     itemBuilder: (context, index) =>
  //         _buildInventoryCard(context, ref, items[index], index),
  //   );
  // }

  // Widget _buildInventoryCard(BuildContext context, WidgetRef ref,
  //     InventoryItem inventoryItem, int index) {
  //   final item = inventoryItem.item;
  //   final rarityColor = Color(item.rarity.colorValue);
  //   final canUse = inventoryItem.isConsumable;

  //   return GestureDetector(
  //     onTap: () => _showItemDetails(context, ref, inventoryItem),
  //     child: Container(
  //       padding: EdgeInsets.all(16.w),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(20.r),
  //         border: Border.all(color: rarityColor.withOpacity(0.3), width: 2.w),
  //         boxShadow: [
  //           BoxShadow(
  //               color: rarityColor.withOpacity(0.1),
  //               blurRadius: 12,
  //               offset: const Offset(0, 4)),
  //           BoxShadow(
  //               color: Colors.black.withOpacity(0.05),
  //               blurRadius: 4,
  //               offset: const Offset(0, 1)),
  //         ],
  //       ),
  //       child: Column(
  //         children: [
  //           // Item Icon with quantity
  //           Stack(
  //             children: [
  //               Container(
  //                 width: 64.w,
  //                 height: 64.w,
  //                 decoration: BoxDecoration(
  //                   color: rarityColor.withOpacity(0.1),
  //                   shape: BoxShape.circle,
  //                   border: Border.all(
  //                       color: rarityColor.withOpacity(0.2), width: 1.w),
  //                 ),
  //                 child: Center(
  //                     child:
  //                         Text(item.emoji, style: TextStyle(fontSize: 32.sp))),
  //               ),
  //               Positioned(
  //                 right: 0,
  //                 top: 0,
  //                 child: Container(
  //                   padding: EdgeInsets.all(6.w),
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xFF10B981),
  //                     shape: BoxShape.circle,
  //                     border: Border.all(color: Colors.white, width: 2.w),
  //                   ),
  //                   child: Text(
  //                     '${inventoryItem.quantity}',
  //                     style: TextStyle(
  //                         fontSize: 12.sp,
  //                         fontWeight: FontWeight.w700,
  //                         color: Colors.white),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 12.h),

  //           // Item name & rarity
  //           Text(
  //             item.name,
  //             style: TextStyle(
  //                 fontSize: 14.sp,
  //                 fontWeight: FontWeight.w700,
  //                 color: const Color(0xFF0F172A)),
  //             textAlign: TextAlign.center,
  //             maxLines: 2,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //           SizedBox(height: 6.h),
  //           Container(
  //             padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
  //             decoration: BoxDecoration(
  //                 color: rarityColor,
  //                 borderRadius: BorderRadius.circular(12.r)),
  //             child: Text(
  //               item.rarity.displayName,
  //               style: TextStyle(
  //                   fontSize: 10.sp,
  //                   fontWeight: FontWeight.w600,
  //                   color: Colors.white),
  //             ),
  //           ),

  //           const Spacer(),

  //           // Effects preview
  //           if (item.effects.isNotEmpty) ...[
  //             Wrap(
  //               spacing: 4.w,
  //               children: item.effects.entries.take(2).map((effect) {
  //                 final effectData = MockDataService.getEffectData(effect.key);
  //                 return Container(
  //                   padding:
  //                       EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xFF10B981).withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(8.r),
  //                   ),
  //                   child: Text(
  //                     '+${effect.value.toInt()}${effect.key == 'xp_multiplier' ? 'x' : '%'} ${effectData['emoji']}',
  //                     style: TextStyle(
  //                         fontSize: 9.sp,
  //                         fontWeight: FontWeight.w500,
  //                         color: const Color(0xFF10B981)),
  //                   ),
  //                 );
  //               }).toList(),
  //             ),
  //             SizedBox(height: 8.h),
  //           ],

  //           // Action button
  //           SizedBox(
  //             width: double.infinity,
  //             child: ElevatedButton(
  //               onPressed: canUse
  //                   ? () => _showUseItemDialog(context, ref, inventoryItem)
  //                   : null,
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: canUse
  //                     ? const Color(0xFF3B82F6)
  //                     : const Color(0xFF94A3B8),
  //                 padding: EdgeInsets.symmetric(vertical: 8.h),
  //                 shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12.r)),
  //                 elevation: 0,
  //               ),
  //               child: Text(
  //                 canUse ? 'Usar Item' : 'Colecionável',
  //                 style: TextStyle(
  //                     fontSize: 12.sp,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.white),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   )
  //       .animate(delay: Duration(milliseconds: 100 * index))
  //       .fadeIn(duration: 600.ms)
  //       .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
  //       .slideY(begin: 0.2, end: 0.0);
  // }

  // Widget _buildEmptyState(
  //     BuildContext context, WidgetRef ref, ItemCategory category) {
  //   return Center(
  //     child: Padding(
  //       padding: EdgeInsets.all(32.w),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text('📦', style: TextStyle(fontSize: 64.sp)),
  //           SizedBox(height: 16.h),
  //           Text(
  //             'Nenhum item encontrado',
  //             style: TextStyle(
  //                 fontSize: 18.sp,
  //                 fontWeight: FontWeight.w600,
  //                 color: const Color(0xFF0F172A)),
  //           ),
  //           SizedBox(height: 8.h),
  //           Text(
  //             'Você ainda não possui itens em "${category.displayName}"',
  //             style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
  //             textAlign: TextAlign.center,
  //           ),
  //           SizedBox(height: 24.h),
  //           ElevatedButton.icon(
  //             onPressed: () => Navigator.pop(context),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFF3B82F6),
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12.r)),
  //             ),
  //             icon: Icon(Icons.shopping_cart, size: 18.sp),
  //             label: const Text('Ir para Loja'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // List<InventoryItem> _filterItems(List<InventoryItem> items, String query) {
  //   if (query.isEmpty) return items;
  //   final lowerQuery = query.toLowerCase();
  //   return items.where((item) {
  //     final name = item.item.name.toLowerCase();
  //     final description = item.item.description.toLowerCase();
  //     return name.contains(lowerQuery) || description.contains(lowerQuery);
  //   }).toList();
  // }

  // void _showItemDetails(
  //     BuildContext context, WidgetRef ref, InventoryItem inventoryItem) {
  //   final item = inventoryItem.item;
  //   final rarityColor = Color(item.rarity.colorValue);

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => Container(
  //       height: MediaQuery.of(context).size.height * 0.8,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(28.r), topRight: Radius.circular(28.r)),
  //       ),
  //       child: Column(
  //         children: [
  //           Container(
  //             margin: EdgeInsets.only(top: 12.h),
  //             width: 40.w,
  //             height: 4.h,
  //             decoration: BoxDecoration(
  //                 color: const Color(0xFFE2E8F0),
  //                 borderRadius: BorderRadius.circular(2.r)),
  //           ),
  //           Expanded(
  //             child: SingleChildScrollView(
  //               padding: EdgeInsets.all(24.w),
  //               child: Column(
  //                 children: [
  //                   // Header com ícone e info
  //                   Row(
  //                     children: [
  //                       Container(
  //                         width: 80.w,
  //                         height: 80.w,
  //                         decoration: BoxDecoration(
  //                           color: rarityColor.withOpacity(0.1),
  //                           shape: BoxShape.circle,
  //                           border: Border.all(
  //                               color: rarityColor.withOpacity(0.3),
  //                               width: 2.w),
  //                         ),
  //                         child: Center(
  //                             child: Text(item.emoji,
  //                                 style: TextStyle(fontSize: 40.sp))),
  //                       ),
  //                       SizedBox(width: 16.w),
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text(
  //                               item.name,
  //                               style: TextStyle(
  //                                   fontSize: 22.sp,
  //                                   fontWeight: FontWeight.w700,
  //                                   color: const Color(0xFF0F172A)),
  //                             ),
  //                             SizedBox(height: 4.h),
  //                             Container(
  //                               padding: EdgeInsets.symmetric(
  //                                   horizontal: 12.w, vertical: 6.h),
  //                               decoration: BoxDecoration(
  //                                   color: rarityColor,
  //                                   borderRadius: BorderRadius.circular(16.r)),
  //                               child: Text(
  //                                 item.rarity.displayName,
  //                                 style: TextStyle(
  //                                     fontSize: 12.sp,
  //                                     fontWeight: FontWeight.w700,
  //                                     color: Colors.white),
  //                               ),
  //                             ),
  //                             SizedBox(height: 8.h),
  //                             Row(
  //                               children: [
  //                                 Icon(Icons.inventory_2,
  //                                     size: 16.sp,
  //                                     color: const Color(0xFF64748B)),
  //                                 SizedBox(width: 6.w),
  //                                 Text(
  //                                   'Quantidade: ${inventoryItem.quantity}',
  //                                   style: TextStyle(
  //                                       fontSize: 14.sp,
  //                                       fontWeight: FontWeight.w600,
  //                                       color: const Color(0xFF64748B)),
  //                                 ),
  //                               ],
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: 24.h),

  //                   // Descrição
  //                   Container(
  //                     width: double.infinity,
  //                     padding: EdgeInsets.all(16.w),
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xFFF8FAFC),
  //                       borderRadius: BorderRadius.circular(12.r),
  //                       border: Border.all(color: const Color(0xFFE2E8F0)),
  //                     ),
  //                     child: Text(
  //                       item.description,
  //                       style: TextStyle(
  //                           fontSize: 14.sp,
  //                           color: const Color(0xFF64748B),
  //                           height: 1.5),
  //                     ),
  //                   ),
  //                   SizedBox(height: 20.h),

  //                   // Efeitos
  //                   if (item.effects.isNotEmpty) ...[
  //                     Container(
  //                       width: double.infinity,
  //                       padding: EdgeInsets.all(16.w),
  //                       decoration: BoxDecoration(
  //                         color: const Color(0xFFF0F9FF),
  //                         borderRadius: BorderRadius.circular(12.r),
  //                         border: Border.all(
  //                             color: const Color(0xFF3B82F6).withOpacity(0.2)),
  //                       ),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Row(
  //                             children: [
  //                               Icon(Icons.auto_fix_high,
  //                                   size: 20.sp,
  //                                   color: const Color(0xFF3B82F6)),
  //                               SizedBox(width: 8.w),
  //                               Text(
  //                                 'Efeitos do Item',
  //                                 style: TextStyle(
  //                                     fontSize: 16.sp,
  //                                     fontWeight: FontWeight.w700,
  //                                     color: const Color(0xFF0F172A)),
  //                               ),
  //                             ],
  //                           ),
  //                           SizedBox(height: 12.h),
  //                           ...item.effects.entries.map((effect) {
  //                             final effectData =
  //                                 MockDataService.getEffectData(effect.key);
  //                             return Padding(
  //                               padding: EdgeInsets.only(bottom: 8.h),
  //                               child: Row(
  //                                 children: [
  //                                   Text(effectData['emoji'],
  //                                       style: TextStyle(fontSize: 16.sp)),
  //                                   SizedBox(width: 8.w),
  //                                   Expanded(
  //                                     child: Text(
  //                                       '${effectData['name']}: +${effect.value.toInt()}${effect.key == 'xp_multiplier' ? 'x' : '%'}',
  //                                       style: TextStyle(
  //                                           fontSize: 14.sp,
  //                                           color: const Color(0xFF0F172A)),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             );
  //                           }),
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(height: 20.h),
  //                   ],

  //                   // Info adicional
  //                   Container(
  //                     width: double.infinity,
  //                     padding: EdgeInsets.all(16.w),
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xFFFFFBEB),
  //                       borderRadius: BorderRadius.circular(12.r),
  //                       border: Border.all(
  //                           color: const Color(0xFFF59E0B).withOpacity(0.2)),
  //                     ),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           'Informações do Item',
  //                           style: TextStyle(
  //                               fontSize: 14.sp,
  //                               fontWeight: FontWeight.w700,
  //                               color: const Color(0xFF0F172A)),
  //                         ),
  //                         SizedBox(height: 8.h),
  //                         _buildInfoRow('Categoria', item.category.displayName),
  //                         _buildInfoRow('Adquirido em',
  //                             _formatDate(inventoryItem.purchasedAt)),
  //                         _buildInfoRow('Valor estimado',
  //                             '${inventoryItem.totalValue.toInt()} moedas'),
  //                         if (inventoryItem.isUsed)
  //                           _buildInfoRow(
  //                               'Usado em', _formatDate(inventoryItem.usedAt!)),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),

  //           // Botões de ação
  //           if (inventoryItem.isConsumable) ...[
  //             Container(
  //               padding: EdgeInsets.all(24.w),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 boxShadow: [
  //                   BoxShadow(
  //                       color: Colors.black.withOpacity(0.05),
  //                       blurRadius: 10,
  //                       offset: const Offset(0, -2))
  //                 ],
  //               ),
  //               child: Row(
  //                 children: [
  //                   Expanded(
  //                     child: ElevatedButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                         _showUseItemDialog(context, ref, inventoryItem);
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: const Color(0xFF3B82F6),
  //                         padding: EdgeInsets.symmetric(vertical: 16.h),
  //                         shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(12.r)),
  //                       ),
  //                       child: Text(
  //                         'Usar Item',
  //                         style: TextStyle(
  //                             fontSize: 16.sp,
  //                             fontWeight: FontWeight.w700,
  //                             color: Colors.white),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildInfoRow(String label, String value) {
  //   return Padding(
  //     padding: EdgeInsets.only(bottom: 4.h),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(label,
  //             style:
  //                 TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B))),
  //         Text(value,
  //             style: TextStyle(
  //                 fontSize: 12.sp,
  //                 fontWeight: FontWeight.w600,
  //                 color: const Color(0xFF0F172A))),
  //       ],
  //     ),
  //   );
  // }

  // void _showUseItemDialog(
  //     BuildContext context, WidgetRef ref, InventoryItem inventoryItem) {
  //   int useQuantity = 1;

  //   showDialog(
  //     context: context,
  //     builder: (context) => StatefulBuilder(
  //       builder: (context, setState) => AlertDialog(
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
  //         title: Row(
  //           children: [
  //             Text(inventoryItem.item.emoji, style: TextStyle(fontSize: 24.sp)),
  //             SizedBox(width: 12.w),
  //             Expanded(
  //               child: Text(
  //                 'Usar ${inventoryItem.item.name}',
  //                 style: TextStyle(
  //                     fontSize: 18.sp,
  //                     fontWeight: FontWeight.w700,
  //                     color: const Color(0xFF0F172A)),
  //               ),
  //             ),
  //           ],
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               'Quantos itens você deseja usar?',
  //               style:
  //                   TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
  //             ),
  //             SizedBox(height: 20.h),

  //             // Quantity selector
  //             Container(
  //               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
  //               decoration: BoxDecoration(
  //                 color: const Color(0xFFF8FAFC),
  //                 borderRadius: BorderRadius.circular(12.r),
  //                 border: Border.all(color: const Color(0xFFE2E8F0)),
  //               ),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   IconButton(
  //                     onPressed: useQuantity > 1
  //                         ? () => setState(() => useQuantity--)
  //                         : null,
  //                     icon: Icon(Icons.remove_circle_outline,
  //                         color: useQuantity > 1
  //                             ? const Color(0xFF3B82F6)
  //                             : const Color(0xFF94A3B8)),
  //                   ),
  //                   Column(
  //                     children: [
  //                       Text(
  //                         '$useQuantity',
  //                         style: TextStyle(
  //                             fontSize: 24.sp,
  //                             fontWeight: FontWeight.w700,
  //                             color: const Color(0xFF0F172A)),
  //                       ),
  //                       Text(
  //                         'de ${inventoryItem.quantity}',
  //                         style: TextStyle(
  //                             fontSize: 12.sp, color: const Color(0xFF64748B)),
  //                       ),
  //                     ],
  //                   ),
  //                   IconButton(
  //                     onPressed: useQuantity < inventoryItem.quantity
  //                         ? () => setState(() => useQuantity++)
  //                         : null,
  //                     icon: Icon(Icons.add_circle_outline,
  //                         color: useQuantity < inventoryItem.quantity
  //                             ? const Color(0xFF3B82F6)
  //                             : const Color(0xFF94A3B8)),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             SizedBox(height: 16.h),

  //             // Effects preview
  //             if (inventoryItem.item.effects.isNotEmpty) ...[
  //               Container(
  //                 width: double.infinity,
  //                 padding: EdgeInsets.all(12.w),
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFF10B981).withOpacity(0.1),
  //                   borderRadius: BorderRadius.circular(8.r),
  //                 ),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       'Efeitos aplicados:',
  //                       style: TextStyle(
  //                           fontSize: 12.sp,
  //                           fontWeight: FontWeight.w600,
  //                           color: const Color(0xFF10B981)),
  //                     ),
  //                     SizedBox(height: 4.h),
  //                     ...inventoryItem.item.effects.entries.map((effect) {
  //                       final effectData =
  //                           MockDataService.getEffectData(effect.key);
  //                       final totalEffect = effect.value * useQuantity;
  //                       return Text(
  //                         '${effectData['emoji']} ${effectData['name']}: +${totalEffect.toInt()}${effect.key == 'xp_multiplier' ? 'x' : '%'}',
  //                         style: TextStyle(
  //                             fontSize: 11.sp, color: const Color(0xFF10B981)),
  //                       );
  //                     }),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: Text('Cancelar',
  //                 style: TextStyle(
  //                     fontSize: 14.sp, color: const Color(0xFF64748B))),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               _useItem(context, ref, inventoryItem, useQuantity);
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFF10B981),
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8.r)),
  //             ),
  //             child: Text('Usar Item',
  //                 style: TextStyle(
  //                     fontSize: 14.sp,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.white)),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // void _useItem(BuildContext context, WidgetRef ref,
  //     InventoryItem inventoryItem, int quantity) async {
  //   try {
  //     // HapticFeedback.mediumImpact();

  //     // Use item via provider
  //     for (int i = 0; i < quantity; i++) {
  //       await ref.read(useItemProvider(inventoryItem.item.id));
  //     }

  //     // Show success animation
  //     _showUseSuccessAnimation(context, inventoryItem, quantity);
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Row(
  //           children: [
  //             Icon(Icons.error, color: Colors.white, size: 20.sp),
  //             SizedBox(width: 8.w),
  //             Expanded(child: Text('Erro ao usar item: ${e.toString()}')),
  //           ],
  //         ),
  //         backgroundColor: const Color(0xFFEF4444),
  //         behavior: SnackBarBehavior.floating,
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
  //       ),
  //     );
  //   }
  // }

  // void _showUseSuccessAnimation(
  //     BuildContext context, InventoryItem inventoryItem, int quantity) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     barrierColor: Colors.black.withOpacity(0.8),
  //     builder: (context) => Center(
  //       child: Material(
  //         color: Colors.transparent,
  //         child: Container(
  //           width: 240.w,
  //           height: 240.w,
  //           decoration: BoxDecoration(
  //               color: Colors.white, borderRadius: BorderRadius.circular(24.r)),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Container(
  //                 width: 100.w,
  //                 height: 100.w,
  //                 decoration: BoxDecoration(
  //                   color: const Color(0xFF10B981).withOpacity(0.1),
  //                   shape: BoxShape.circle,
  //                 ),
  //                 child: Center(
  //                     child: Text(inventoryItem.item.emoji,
  //                         style: TextStyle(fontSize: 50.sp))),
  //               ),
  //               SizedBox(height: 20.h),
  //               Icon(Icons.check_circle,
  //                   size: 32.sp, color: const Color(0xFF10B981)),
  //               SizedBox(height: 12.h),
  //               Text(
  //                 'Item Usado!',
  //                 style: TextStyle(
  //                     fontSize: 20.sp,
  //                     fontWeight: FontWeight.w700,
  //                     color: const Color(0xFF10B981)),
  //               ),
  //               SizedBox(height: 8.h),
  //               Text(
  //                 '${inventoryItem.item.name} ${quantity > 1 ? '(${quantity}x)' : ''}',
  //                 style: TextStyle(
  //                     fontSize: 14.sp, color: const Color(0xFF64748B)),
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         )
  //             .animate()
  //             .scale(duration: 400.ms, curve: Curves.elasticOut)
  //             .fadeIn(duration: 200.ms),
  //       ),
  //     ),
  //   );

  //   Future.delayed(const Duration(milliseconds: 2000), () {
  //     if (Navigator.canPop(context)) {
  //       Navigator.pop(context);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Row(
  //             children: [
  //               Text(inventoryItem.item.emoji,
  //                   style: TextStyle(fontSize: 20.sp)),
  //               SizedBox(width: 12.w),
  //               Expanded(
  //                   child: Text(
  //                       'Efeitos de ${inventoryItem.item.name} aplicados!')),
  //               Icon(Icons.pets, color: Colors.white, size: 20.sp),
  //             ],
  //           ),
  //           backgroundColor: const Color(0xFF10B981),
  //           behavior: SnackBarBehavior.floating,
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12.r)),
  //           duration: const Duration(seconds: 3),
  //         ),
  //       );
  //     }
  //   });
  // }

  // void _showFilterOptions(BuildContext context, WidgetRef ref) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r))),
  //     builder: (context) => Container(
  //       padding: EdgeInsets.all(24.w),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Row(
  //             children: [
  //               Icon(Icons.tune, color: const Color(0xFF3B82F6), size: 24.sp),
  //               SizedBox(width: 12.w),
  //               Text(
  //                 'Filtros e Ordenação',
  //                 style: TextStyle(
  //                     fontSize: 20.sp,
  //                     fontWeight: FontWeight.w700,
  //                     color: const Color(0xFF0F172A)),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 20.h),
  //           Text('Ordenar por:',
  //               style: TextStyle(
  //                   fontSize: 16.sp,
  //                   fontWeight: FontWeight.w600,
  //                   color: const Color(0xFF0F172A))),
  //           SizedBox(height: 12.h),
  //           ...[
  //             'Mais recentes',
  //             'Quantidade',
  //             'Raridade',
  //             'Nome A-Z'
  //           ].map((option) => ListTile(
  //                 leading: const Icon(Icons.sort, color: Color(0xFF64748B)),
  //                 title: Text(option),
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   // Implement sorting logic here
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                         content:
  //                             Text('Ordenação por $option será implementada')),
  //                   );
  //                 },
  //               )),
  //           SizedBox(height: 16.h),
  //           Text('Filtrar por raridade:',
  //               style: TextStyle(
  //                   fontSize: 16.sp,
  //                   fontWeight: FontWeight.w600,
  //                   color: const Color(0xFF0F172A))),
  //           SizedBox(height: 12.h),
  //           Wrap(
  //             spacing: 8.w,
  //             children: ItemRarity.values
  //                 .map((rarity) => FilterChip(
  //                       label: Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           Container(
  //                             width: 12.w,
  //                             height: 12.w,
  //                             decoration: BoxDecoration(
  //                                 color: Color(rarity.colorValue),
  //                                 shape: BoxShape.circle),
  //                           ),
  //                           SizedBox(width: 6.w),
  //                           Text(rarity.displayName,
  //                               style: TextStyle(fontSize: 12.sp)),
  //                         ],
  //                       ),
  //                       onSelected: (selected) {
  //                         // Implement rarity filter logic here
  //                       },
  //                     ))
  //                 .toList(),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildFloatingActions(BuildContext context, WidgetRef ref) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.end,
  //     children: [
  //       // Shop button
  //       FloatingActionButton(
  //         heroTag: "shop",
  //         onPressed: () => Navigator.pop(context),
  //         backgroundColor: const Color(0xFF10B981),
  //         child: Icon(Icons.shopping_cart, color: Colors.white, size: 24.sp),
  //       ),
  //       SizedBox(height: 12.h),

  //       // Sort button
  //       FloatingActionButton(
  //         heroTag: "sort",
  //         onPressed: () => _showFilterOptions(context, ref),
  //         backgroundColor: const Color(0xFF3B82F6),
  //         mini: true,
  //         child: Icon(Icons.sort, color: Colors.white, size: 20.sp),
  //       ),
  //     ],
  //   );
  // }

  // String _formatDate(DateTime date) {
  //   final now = DateTime.now();
  //   final difference = now.difference(date);

  //   if (difference.inDays > 7) {
  //     return '${date.day}/${date.month}/${date.year}';
  //   } else if (difference.inDays > 0) {
  //     return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
  //   } else if (difference.inHours > 0) {
  //     return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
  //   } else {
  //     return 'Agora mesmo';
  //   }
  // }

  // PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref,
  //     UserWallet wallet, List<InventoryItem> inventory) {
  //   final totalItems = inventory.fold(0, (sum, item) => sum + item.quantity);
  //   final totalValue =
  //       inventory.fold(0.0, (sum, item) => sum + item.totalValue);

  //   return AppBar(
  //     backgroundColor: Colors.transparent,
  //     elevation: 0,
  //     leading: IconButton(
  //       onPressed: () => Navigator.pop(context),
  //       icon: Icon(Icons.arrow_back_ios,
  //           color: const Color(0xFF0F172A), size: 22.sp),
  //     ),
  //     title: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Meu Inventário',
  //           style: TextStyle(
  //               fontSize: 20.sp,
  //               fontWeight: FontWeight.w700,
  //               color: const Color(0xFF0F172A)),
  //         ),
  //         Text(
  //           '$totalItems itens • Valor: ${totalValue.toInt()} moedas',
  //           style: TextStyle(
  //               fontSize: 12.sp,
  //               color: const Color(0xFF64748B),
  //               fontWeight: FontWeight.w400),
  //         ),
  //       ],
  //     ),
  //     actions: [
  //       Container(
  //         margin: EdgeInsets.only(right: 16.w),
  //         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
  //         decoration: BoxDecoration(
  //           gradient: const LinearGradient(
  //               colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)]),
  //           borderRadius: BorderRadius.circular(20.r),
  //           boxShadow: [
  //             BoxShadow(
  //                 color: const Color(0xFF8B5CF6).withOpacity(0.3),
  //                 blurRadius: 8,
  //                 offset: const Offset(0, 2))
  //           ],
  //         ),
  //         child: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(Icons.inventory_2, color: Colors.white, size: 16.sp),
  //             SizedBox(width: 6.w),
  //             Text('$totalItems',
  //                 style: TextStyle(
  //                     fontSize: 14.sp,
  //                     fontWeight: FontWeight.w700,
  //                     color: Colors.white)),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildSearchAndFilter(BuildContext context, WidgetRef ref) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Container(
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(16.r),
  //               border: Border.all(color: const Color(0xFFE2E8F0)),
  //               boxShadow: [
  //                 BoxShadow(
  //                     color: Colors.black.withOpacity(0.05),
  //                     blurRadius: 4,
  //                     offset: const Offset(0, 1))
  //               ],
  //             ),
  //             child: TextField(
  //               controller: _searchController,
  //               onChanged: (value) =>
  //                   ref.read(searchQueryProvider.notifier).state = value,
  //               decoration: InputDecoration(
  //                 hintText: 'Buscar no inventário...',
  //                 hintStyle: TextStyle(
  //                     color: const Color(0xFF94A3B8), fontSize: 14.sp),
  //                 prefixIcon: Icon(Icons.search,
  //                     color: const Color(0xFF64748B), size: 20.sp),
  //                 suffixIcon: _searchController.text.isNotEmpty
  //                     ? IconButton(
  //                         onPressed: () {
  //                           _searchController.clear();
  //                           ref.read(searchQueryProvider.notifier).state = '';
  //                         },
  //                         icon: Icon(Icons.clear,
  //                             color: const Color(0xFF64748B), size: 18.sp),
  //                       )
  //                     : null,
  //                 border: InputBorder.none,
  //                 contentPadding:
  //                     EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
  //               ),
  //             ),
  //           ),
  //         ),
  //         SizedBox(width: 12.w),
  //         Container(
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF3B82F6),
  //             borderRadius: BorderRadius.circular(16.r),
  //             boxShadow: [
  //               BoxShadow(
  //                   color: const Color(0xFF3B82F6).withOpacity(0.3),
  //                   blurRadius: 8,
  //                   offset: const Offset(0, 2))
  //             ],
  //           ),
  //           child: IconButton(
  //             onPressed: () => _showFilterOptions(context, ref),
  //             icon: Icon(Icons.tune, color: Colors.white, size: 20.sp),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildCategoryTabs(BuildContext context,
  //     Map<ItemCategory, List<InventoryItem>> inventoryByCategory) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 20.w),
  //     child: TabBar(
  //       controller: _tabController,
  //       isScrollable: true,
  //       indicator: BoxDecoration(
  //         color: const Color(0xFF3B82F6),
  //         borderRadius: BorderRadius.circular(16.r),
  //       ),
  //       labelColor: Colors.white,
  //       unselectedLabelColor: const Color(0xFF64748B),
  //       labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
  //       unselectedLabelStyle:
  //           TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
  //       tabs: ItemCategory.values.map((category) {
  //         final count = inventoryByCategory[category]
  //                 ?.fold(0, (sum, item) => sum + item.quantity) ??
  //             0;
  //         return Tab(
  //           child: Container(
  //             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
  //             child: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(category.emoji),
  //                 SizedBox(width: 6.w),
  //                 Text(category.displayName),
  //                 if (count > 0) ...[
  //                   SizedBox(width: 6.w),
  //                   Container(
  //                     padding:
  //                         EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
  //                     decoration: BoxDecoration(
  //                       color: Colors.white.withOpacity(0.2),
  //                       borderRadius: BorderRadius.circular(8.r),
  //                     ),
  //                     child: Text('$count',
  //                         style: TextStyle(
  //                             fontSize: 10.sp, fontWeight: FontWeight.w700)),
  //                   ),
  //                 ],
  //               ],
  //             ),
  //           ),
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }

  // Widget _buildInventoryGrid(BuildContext context, WidgetRef ref,
  //     List<InventoryItem> items, ItemCategory category) {
  //   if (items.isEmpty) return _buildEmptyState(context, ref, category);

  //   return GridView.builder(
  //     padding: EdgeInsets.all(20.w),
  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 2,
  //       crossAxisSpacing: 16.w,
  //       mainAxisSpacing: 16.h,
  //       childAspectRatio: 0.75,
  //     ),
  //     itemCount: items.length,
  //     itemBuilder: (context, index) =>
  //         _buildInventoryCard(context, ref, items[index], index),
  //   );
  // }

  // Widget _buildInventoryCard(BuildContext context, WidgetRef ref,
  //     InventoryItem inventoryItem, int index) {
  //   final item = inventoryItem.item;
  //   final rarityColor = Color(item.rarity.colorValue);
  //   final canUse = inventoryItem.isConsumable;

  //   return GestureDetector(
  //     onTap: () => _showItemDetails(context, ref, inventoryItem),
  //     child: Container(
  //       padding: EdgeInsets.all(16.w),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(20.r),
  //         border: Border.all(color: rarityColor.withOpacity(0.3), width: 2.w),
  //         boxShadow: [
  //           BoxShadow(
  //               color: rarityColor.withOpacity(0.1),
  //               blurRadius: 12,
  //               offset: const Offset(0, 4)),
  //           BoxShadow(
  //               color: Colors.black.withOpacity(0.05),
  //               blurRadius: 4,
  //               offset: const Offset(0, 1)),
  //         ],
  //       ),
  //       child: Column(
  //         children: [
  //           // Item Icon with quantity
  //           Stack(
  //             children: [
  //               Container(
  //                 width: 64.w,
  //                 height: 64.w,
  //                 decoration: BoxDecoration(
  //                   color: rarityColor.withOpacity(0.1),
  //                   shape: BoxShape.circle,
  //                   border: Border.all(
  //                       color: rarityColor.withOpacity(0.2), width: 1.w),
  //                 ),
  //                 child: Center(
  //                     child:
  //                         Text(item.emoji, style: TextStyle(fontSize: 32.sp))),
  //               ),
  //               Positioned(
  //                 right: 0,
  //                 top: 0,
  //                 child: Container(
  //                   padding: EdgeInsets.all(6.w),
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xFF10B981),
  //                     shape: BoxShape.circle,
  //                     border: Border.all(color: Colors.white, width: 2.w),
  //                   ),
  //                   child: Text(
  //                     '${inventoryItem.quantity}',
  //                     style: TextStyle(
  //                         fontSize: 12.sp,
  //                         fontWeight: FontWeight.w700,
  //                         color: Colors.white),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(height: 12.h),

  //           // Item name & rarity
  //           Text(
  //             item.name,
  //             style: TextStyle(
  //                 fontSize: 14.sp,
  //                 fontWeight: FontWeight.w700,
  //                 color: const Color(0xFF0F172A)),
  //             textAlign: TextAlign.center,
  //             maxLines: 2,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //           SizedBox(height: 6.h),
  //           Container(
  //             padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
  //             decoration: BoxDecoration(
  //                 color: rarityColor,
  //                 borderRadius: BorderRadius.circular(12.r)),
  //             child: Text(
  //               item.rarity.displayName,
  //               style: TextStyle(
  //                   fontSize: 10.sp,
  //                   fontWeight: FontWeight.w600,
  //                   color: Colors.white),
  //             ),
  //           ),

  //           const Spacer(),

  //           // Effects preview
  //           if (item.effects.isNotEmpty) ...[
  //             Wrap(
  //               spacing: 4.w,
  //               children: item.effects.entries.take(2).map((effect) {
  //                 final effectData = MockDataService.getEffectData(effect.key);
  //                 return Container(
  //                   padding:
  //                       EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xFF10B981).withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(8.r),
  //                   ),
  //                   child: Text(
  //                     '+${effect.value.toInt()}${effect.key == 'xp_multiplier' ? 'x' : '%'} ${effectData['emoji']}',
  //                     style: TextStyle(
  //                         fontSize: 9.sp,
  //                         fontWeight: FontWeight.w500,
  //                         color: const Color(0xFF10B981)),
  //                   ),
  //                 );
  //               }).toList(),
  //             ),
  //             SizedBox(height: 8.h),
  //           ],

  //           // Action button
  //           SizedBox(
  //             width: double.infinity,
  //             child: ElevatedButton(
  //               onPressed: canUse
  //                   ? () => _showUseItemDialog(context, ref, inventoryItem)
  //                   : null,
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: canUse
  //                     ? const Color(0xFF3B82F6)
  //                     : const Color(0xFF94A3B8),
  //                 padding: EdgeInsets.symmetric(vertical: 8.h),
  //                 shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(12.r)),
  //                 elevation: 0,
  //               ),
  //               child: Text(
  //                 canUse ? 'Usar Item' : 'Colecionável',
  //                 style: TextStyle(
  //                     fontSize: 12.sp,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.white),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   )
  //       .animate(delay: Duration(milliseconds: 100 * index))
  //       .fadeIn(duration: 600.ms)
  //       .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
  //       .slideY(begin: 0.2, end: 0.0);
  // }

  // Widget _buildEmptyState(
  //     BuildContext context, WidgetRef ref, ItemCategory category) {
  //   return Center(
  //     child: Padding(
  //       padding: EdgeInsets.all(32.w),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text('📦', style: TextStyle(fontSize: 64.sp)),
  //           SizedBox(height: 16.h),
  //           Text(
  //             'Nenhum item encontrado',
  //             style: TextStyle(
  //                 fontSize: 18.sp,
  //                 fontWeight: FontWeight.w600,
  //                 color: const Color(0xFF0F172A)),
  //           ),
  //           SizedBox(height: 8.h),
  //           Text(
  //             'Você ainda não possui itens em "${category.displayName}"',
  //             style: TextStyle(fontSize: 14.sp, color: const Color(0xFF64748B)),
  //             textAlign: TextAlign.center,
  //           ),
  //           SizedBox(height: 24.h),
  //           ElevatedButton.icon(
  //             onPressed: () => Navigator.pop(context),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFF3B82F6),
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12.r)),
  //             ),
  //             icon: Icon(Icons.shopping_cart, size: 18.sp),
  //             label: const Text('Ir para Loja'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // List<InventoryItem> _filterItems(List<InventoryItem> items, String query) {
  //   if (query.isEmpty) return items;
  //   final lowerQuery = query.toLowerCase();
  //   return items.where((item) {
  //     final name = item.item.name.toLowerCase();
  //     final description = item.item.description.toLowerCase();
  //     return name.contains(lowerQuery) || description.contains(lowerQuery);
  //   }).toList();
  // }

  // void _showItemDetails(
  //     BuildContext context, WidgetRef ref, InventoryItem inventoryItem) {
  //   final item = inventoryItem.item;
  //   final rarityColor = Color(item.rarity.colorValue);

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => Container(
  //       height: MediaQuery.of(context).size.height * 0.8,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(28.r), topRight: Radius.circular(28.r)),
  //       ),
  //       child: Column(
  //         children: [
  //           Container(
  //             margin: EdgeInsets.only(top: 12.h),
  //             width: 40.w,
  //             height: 4.h,
  //             decoration: BoxDecoration(
  //                 color: const Color(0xFFE2E8F0),
  //                 borderRadius: BorderRadius.circular(2.r)),
  //           ),
  //           Expanded(
  //             child: SingleChildScrollView(
  //               padding: EdgeInsets.all(24.w),
  //               child: Column(
  //                 children: [
  //                   // Header com ícone e info
  //                   Row(
  //                     children: [
  //                       Container(
  //                         width: 80.w,
  //                         height: 80.w,
  //                         decoration: BoxDecoration(
  //                           color: rarityColor.withOpacity(0.1),
  //                           shape: BoxShape.circle,
  //                           border: Border.all(
  //                               color: rarityColor.withOpacity(0.3),
  //                               width: 2.w),
  //                         ),
  //                         child: Center(
  //                             child: Text(item.emoji,
  //                                 style: TextStyle(fontSize: 40.sp))),
  //                       ),
  //                       SizedBox(width: 16.w),
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text(
  //                               item.name,
  //                               style: TextStyle(
  //                                   fontSize: 22.sp,
  //                                   fontWeight: FontWeight.w700,
  //                                   color: const Color(0xFF0F172A)),
  //                             ),
  //                             SizedBox(height: 4.h),
  //                             Container(
  //                               padding: EdgeInsets.symmetric(
  //                                   horizontal: 12.w, vertical: 6.h),
  //                               decoration: BoxDecoration(
  //                                   color: rarityColor,
  //                                   borderRadius: BorderRadius.circular(16.r)),
  //                               child: Text(
  //                                 item.rarity.displayName,
  //                                 style: TextStyle(
  //                                     fontSize: 12.sp,
  //                                     fontWeight: FontWeight.w700,
  //                                     color: Colors.white),
  //                               ),
  //                             ),
  //                             SizedBox(height: 8.h),
  //                             Row(
  //                               children: [
  //                                 Icon(Icons.inventory_2,
  //                                     size: 16.sp,
  //                                     color: const Color(0xFF64748B)),
  //                                 SizedBox(width: 6.w),
  //                                 Text(
  //                                   'Quantidade: ${inventoryItem.quantity}',
  //                                   style: TextStyle(
  //                                       fontSize: 14.sp,
  //                                       fontWeight: FontWeight.w600,
  //                                       color: const Color(0xFF64748B)),
  //                                 ),
  //                               ],
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(height: 24.h),

  //                   // Descrição
  //                   Container(
  //                     width: double.infinity,
  //                     padding: EdgeInsets.all(16.w),
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xFFF8FAFC),
  //                       borderRadius: BorderRadius.circular(12.r),
  //                       border: Border.all(color: const Color(0xFFE2E8F0)),
  //                     ),
  //                     child: Text(
  //                       item.description,
  //                       style: TextStyle(
  //                           fontSize: 14.sp,
  //                           color: const Color(0xFF64748B),
  //                           height: 1.5),
  //                     ),
  //                   ),
  //                   SizedBox(height: 20.h),

  //                   // Efeitos
  //                   if (item.effects.isNotEmpty) ...[
  //                     Container(
  //                       width: double.infinity,
  //                       padding: EdgeInsets.all(16.w),
  //                       decoration: BoxDecoration(
  //                         color: const Color(0xFFF0F9FF),
  //                         borderRadius: BorderRadius.circular(12.r),
  //                         border: Border.all(
  //                             color: const Color(0xFF3B82F6).withOpacity(0.2)),
  //                       ),
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Row(
  //                             children: [
  //                               Icon(Icons.auto_fix_high,
  //                                   size: 20.sp,
  //                                   color: const Color(0xFF3B82F6)),
  //                               SizedBox(width: 8.w),
  //                               Text(
  //                                 'Efeitos do Item',
  //                                 style: TextStyle(
  //                                     fontSize: 16.sp,
  //                                     fontWeight: FontWeight.w700,
  //                                     color: const Color(0xFF0F172A)),
  //                               ),
  //                             ],
  //                           ),
  //                           SizedBox(height: 12.h),
  //                           ...item.effects.entries.map((effect) {
  //                             final effectData =
  //                                 MockDataService.getEffectData(effect.key);
  //                             return Padding(
  //                               padding: EdgeInsets.only(bottom: 8.h),
  //                               child: Row(
  //                                 children: [
  //                                   Text(effectData['emoji'],
  //                                       style: TextStyle(fontSize: 16.sp)),
  //                                   SizedBox(width: 8.w),
  //                                   Expanded(
  //                                     child: Text(
  //                                       '${effectData['name']}: +${effect.value.toInt()}${effect.key == 'xp_multiplier' ? 'x' : '%'}',
  //                                       style: TextStyle(
  //                                           fontSize: 14.sp,
  //                                           color: const Color(0xFF0F172A)),
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             );
  //                           }),
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(height: 20.h),
  //                   ],

  //                   // Info adicional
  //                   Container(
  //                     width: double.infinity,
  //                     padding: EdgeInsets.all(16.w),
  //                     decoration: BoxDecoration(
  //                       color: const Color(0xFFFFFBEB),
  //                       borderRadius: BorderRadius.circular(12.r),
  //                       border: Border.all(
  //                           color: const Color(0xFFF59E0B).withOpacity(0.2)),
  //                     ),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           'Informações do Item',
  //                           style: TextStyle(
  //                               fontSize: 14.sp,
  //                               fontWeight: FontWeight.w700,
  //                               color: const Color(0xFF0F172A)),
  //                         ),
  //                         SizedBox(height: 8.h),
  //                         _buildInfoRow('Categoria', item.category.displayName),
  //                         _buildInfoRow('Adquirido em',
  //                             _formatDate(inventoryItem.purchasedAt)),
  //                         _buildInfoRow('Valor estimado',
  //                             '${inventoryItem.totalValue.toInt()} moedas'),
  //                         if (inventoryItem.isUsed)
  //                           _buildInfoRow(
  //                               'Usado em', _formatDate(inventoryItem.usedAt!)),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),

  //           // Botões de ação
  //           if (inventoryItem.isConsumable) ...[
  //             Container(
  //               padding: EdgeInsets.all(24.w),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 boxShadow: [
  //                   BoxShadow(
  //                       color: Colors.black.withOpacity(0.05),
  //                       blurRadius: 10,
  //                       offset: const Offset(0, -2))
  //                 ],
  //               ),
  //               child: Row(
  //                 children: [
  //                   Expanded(
  //                     child: ElevatedButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                         _showUseItemDialog(context, ref, inventoryItem);
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: const Color(0xFF3B82F6),
  //                         padding: EdgeInsets.symmetric(vertical: 16.h),
  //                         shape: RoundedRectangleBorder(
  //                             borderRadius: BorderRadius.circular(12.r)),
  //                       ),
  //                       child: Text(
  //                         'Usar Item',
  //                         style: TextStyle(
  //                             fontSize: 16.sp,
  //                             fontWeight: FontWeight.w700,
  //                             color: Colors.white),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
