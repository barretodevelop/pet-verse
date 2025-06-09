// File: lib/presentation/screens/home/shop/shop_screen.dart

// /// Shop screen for purchasing items and upgrades
// class ShopScreen extends ConsumerWidget {
//   const ShopScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return const EnhancedShopScreen();
//   }
// }

// File: lib/presentation/screens/shop/shop_screen.dart
// COMPLETAMENTE RENOVADA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/core/utils/responsive_grid_helper.dart';
import 'package:petverse/presentation/providers/cart_provider.dart';
import 'package:petverse/presentation/providers/shop_provider.dart';
import 'package:petverse/presentation/widgets/shop/cart_widget.dart';
import 'package:petverse/presentation/widgets/shop/shop_item_card.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _showCart = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shopState = ref.watch(shopProvider);
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Conteúdo principal
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  children: [
                    // Header fixo
                    _buildShopHeader(context, shopState),

                    // Conteúdo scrollável
                    Expanded(
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          // Filtros e busca
                          SliverToBoxAdapter(
                            child: _buildFiltersSection(context, shopState),
                          ),

                          // Grid de itens
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ThemeConfig.spacing16,
                              vertical: ThemeConfig.spacing8,
                            ),
                            sliver: _buildItemsGrid(context, shopState),
                          ),

                          // Espaço extra no final
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 100),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Carrinho flutuante
          if (cartState.hasItems && !_showCart)
            Positioned(
              bottom: 20,
              right: 20,
              child: CartWidget(
                onTap: () => setState(() => _showCart = true),
              ),
            ),

          // Carrinho expandido
          if (_showCart)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: GestureDetector(
                  onTap: () => setState(() => _showCart = false),
                  child: Column(
                    children: [
                      const Spacer(),
                      GestureDetector(
                        onTap: () {}, // Evita fechar ao tocar no carrinho
                        child: const CartWidget(showDetails: true),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShopHeader(BuildContext context, ShopState shopState) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ThemeConfig.primaryColor, ThemeConfig.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacing16),
          child: Row(
            children: [
              // Título e contador
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🛒 Loja do Pet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${shopState.filteredItems.length} itens disponíveis',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // Botões de ação
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ordenação
                  PopupMenuButton<ShopSortType>(
                    icon: const Icon(Icons.sort, color: Colors.white, size: 24),
                    onSelected: (sort) => ref.read(shopProvider.notifier).sortItems(sort),
                    itemBuilder: (context) => ShopSortType.values
                        .map(
                          (sort) => PopupMenuItem(
                            value: sort,
                            child: Text(sort.displayName),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(width: 8),

                  // Refresh
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
                    onPressed: () => ref.read(shopProvider.notifier).loadShopItems(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context, ShopState shopState) {
    return Container(
      padding: const EdgeInsets.all(ThemeConfig.spacing16),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          // // Barra de busca
          // TextField(
          //   controller: _searchController,
          //   decoration: InputDecoration(
          //     hintText: 'Buscar itens...',
          //     prefixIcon: const Icon(Icons.search),
          //     suffixIcon: _searchController.text.isNotEmpty
          //         ? IconButton(
          //             icon: const Icon(Icons.clear),
          //             onPressed: () {
          //               _searchController.clear();
          //               ref.read(shopProvider.notifier).searchItems('');
          //             },
          //           )
          //         : null,
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(12),
          //       borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          //     ),
          //     enabledBorder: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(12),
          //       borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
          //     ),
          //     focusedBorder: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(12),
          //       borderSide: BorderSide(color: ThemeConfig.primaryColor),
          //     ),
          //     filled: true,
          //     fillColor: Theme.of(context).scaffoldBackgroundColor,
          //     contentPadding: const EdgeInsets.symmetric(
          //       horizontal: 16,
          //       vertical: 12,
          //     ),
          //   ),
          //   onChanged: (query) => ref.read(shopProvider.notifier).searchItems(query),
          // ),

          // const SizedBox(height: 16),

          // Filtros de categoria
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ItemCategory.values.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildCategoryChip(
                    'Todos',
                    shopState.selectedCategory == null,
                    () => ref.read(shopProvider.notifier).filterByCategory(null),
                  );
                }

                final category = ItemCategory.values[index - 1];
                return _buildCategoryChip(
                  _getCategoryName(category),
                  shopState.selectedCategory == category,
                  () => ref.read(shopProvider.notifier).filterByCategory(category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.bold : null,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Theme.of(context).cardColor,
        selectedColor: ThemeConfig.primaryColor,
        checkmarkColor: Colors.white,
        side: BorderSide(
          color: isSelected ? ThemeConfig.primaryColor : Colors.grey.withOpacity(0.3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
    );
  }

  Widget _buildItemsGrid(BuildContext context, ShopState shopState) {
    if (shopState.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (shopState.hasError) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar itens',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(shopState.errorMessage ?? 'Erro desconhecido'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(shopProvider.notifier).loadShopItems(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (shopState.filteredItems.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Nenhum item encontrado',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Tente ajustar os filtros ou busca'),
            ],
          ),
        ),
      );
    }

    // Grid responsivo usando ResponsiveGridHelper
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.crossAxisExtent;
        final columns = ResponsiveGridHelper.calculateColumns(screenWidth);
        final spacing = ResponsiveGridHelper.calculateSpacing(screenWidth);
        final aspectRatio = ResponsiveGridHelper.calculateAspectRatio(screenWidth);

        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = shopState.filteredItems[index];
              return ShopItemCard(
                key: ValueKey(item.id),
                item: item,
              );
            },
            childCount: shopState.filteredItems.length,
          ),
        );
      },
    );
  }

  String _getCategoryName(ItemCategory category) {
    switch (category) {
      case ItemCategory.food:
        return '🍖 Comida';
      case ItemCategory.toy:
        return '⚽ Brinquedos';
      case ItemCategory.medicine:
        return '💊 Medicina';
      case ItemCategory.decoration:
        return '🎨 Decoração';
      case ItemCategory.accessory:
        return '👔 Acessórios';
      case ItemCategory.special:
        return '✨ Especiais';
    }
  }
}

// class ShopScreen extends ConsumerStatefulWidget {
//   const ShopScreen({super.key});

//   @override
//   ConsumerState<ShopScreen> createState() => _ShopScreenState();
// }

// class _ShopScreenState extends ConsumerState<ShopScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   final TextEditingController _searchController = TextEditingController();
//   bool _showCart = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final shopState = ref.watch(shopProvider);
//     final cartState = ref.watch(cartProvider);
//     final userState = ref.watch(userGameDataProvider);

//     return Scaffold(
//       body: Stack(
//         children: [
//           // Conteúdo principal
//           AnimatedBuilder(
//             animation: _fadeAnimation,
//             builder: (context, child) {
//               return Opacity(
//                 opacity: _fadeAnimation.value,
//                 child: Column(
//                   children: [
//                     // Header da loja
//                     _buildShopHeader(context, shopState),

//                     // Filtros e busca
//                     _buildFiltersSection(context, shopState),

//                     // Grid de itens
//                     Expanded(
//                       child: _buildItemsGrid(context, shopState),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),

//           // Carrinho flutuante
//           if (cartState.hasItems && !_showCart)
//             Positioned(
//               bottom: 20,
//               right: 20,
//               child: CartWidget(
//                 onTap: () => setState(() => _showCart = true),
//               ),
//             ),

//           // Carrinho expandido
//           if (_showCart)
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.5),
//                 ),
//                 child: GestureDetector(
//                   onTap: () => setState(() => _showCart = false),
//                   child: SizedBox(
//                     height: MediaQuery.of(context).size.height,
//                     child: Column(
//                       children: [
//                         const Spacer(),
//                         GestureDetector(
//                           onTap: () {}, // Evita fechar ao tocar no carrinho
//                           child: const CartWidget(showDetails: true),
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildShopHeader(BuildContext context, ShopState shopState) {
//     return Container(
//       padding: const EdgeInsets.all(ThemeConfig.spacing16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [ThemeConfig.primaryColor, ThemeConfig.primaryColor.withOpacity(0.8)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             // Título
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     '🛒 Loja do Pet',
//                     style: TextStyle(
//                       fontSize: ThemeConfig.fontSize24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   Text(
//                     '${shopState.filteredItems.length} itens disponíveis',
//                     style: const TextStyle(
//                       fontSize: ThemeConfig.fontSize14,
//                       color: Colors.white70,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Botões de ação
//             Row(
//               children: [
//                 // Ordenação
//                 PopupMenuButton<ShopSortType>(
//                   icon: const Icon(Icons.sort, color: Colors.white),
//                   onSelected: (sort) => ref.read(shopProvider.notifier).sortItems(sort),
//                   itemBuilder: (context) => ShopSortType.values
//                       .map(
//                         (sort) => PopupMenuItem(
//                           value: sort,
//                           child: Text(sort.displayName),
//                         ),
//                       )
//                       .toList(),
//                 ),

//                 // Refresh
//                 IconButton(
//                   icon: const Icon(Icons.refresh, color: Colors.white),
//                   onPressed: () => ref.read(shopProvider.notifier).loadShopItems(),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFiltersSection(BuildContext context, ShopState shopState) {
//     return Container(
//       padding: const EdgeInsets.all(ThemeConfig.spacing16),
//       color: Theme.of(context).cardColor,
//       child: Column(
//         children: [
//           // Barra de busca
//           TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: 'Buscar itens...',
//               prefixIcon: const Icon(Icons.search),
//               suffixIcon: _searchController.text.isNotEmpty
//                   ? IconButton(
//                       icon: const Icon(Icons.clear),
//                       onPressed: () {
//                         _searchController.clear();
//                         ref.read(shopProvider.notifier).searchItems('');
//                       },
//                     )
//                   : null,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
//               ),
//               filled: true,
//               fillColor: Theme.of(context).scaffoldBackgroundColor,
//             ),
//             onChanged: (query) => ref.read(shopProvider.notifier).searchItems(query),
//           ),

//           const SizedBox(height: ThemeConfig.spacing12),

//           // Filtros de categoria
//           SizedBox(
//             height: 40,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: ItemCategory.values.length + 1, // +1 para "Todos"
//               itemBuilder: (context, index) {
//                 if (index == 0) {
//                   return _buildCategoryChip(
//                     'Todos',
//                     shopState.selectedCategory == null,
//                     () => ref.read(shopProvider.notifier).filterByCategory(null),
//                   );
//                 }

//                 final category = ItemCategory.values[index - 1];
//                 return _buildCategoryChip(
//                   _getCategoryName(category),
//                   shopState.selectedCategory == category,
//                   () => ref.read(shopProvider.notifier).filterByCategory(category),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryChip(String label, bool isSelected, VoidCallback onTap) {
//     return Padding(
//       padding: const EdgeInsets.only(right: ThemeConfig.spacing8),
//       child: FilterChip(
//         label: Text(label),
//         selected: isSelected,
//         onSelected: (_) => onTap(),
//         backgroundColor: Theme.of(context).cardColor,
//         selectedColor: ThemeConfig.primaryColor.withOpacity(0.2),
//         labelStyle: TextStyle(
//           color: isSelected ? ThemeConfig.primaryColor : null,
//           fontWeight: isSelected ? FontWeight.bold : null,
//         ),
//       ),
//     );
//   }

//   Widget _buildItemsGrid(BuildContext context, ShopState shopState) {
//     if (shopState.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (shopState.hasError) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 64, color: Colors.grey),
//             const SizedBox(height: ThemeConfig.spacing16),
//             Text(
//               'Erro ao carregar itens',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: ThemeConfig.spacing8),
//             Text(shopState.errorMessage ?? 'Erro desconhecido'),
//             const SizedBox(height: ThemeConfig.spacing16),
//             ElevatedButton(
//               onPressed: () => ref.read(shopProvider.notifier).loadShopItems(),
//               child: const Text('Tentar novamente'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (shopState.filteredItems.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
//             const SizedBox(height: ThemeConfig.spacing16),
//             Text(
//               'Nenhum item encontrado',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: ThemeConfig.spacing8),
//             const Text('Tente ajustar os filtros ou busca'),
//           ],
//         ),
//       );
//     }

//     // Grid responsivo com 3 colunas
//     return Padding(
//       padding: const EdgeInsets.all(ThemeConfig.spacing16),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           // Calcula o número de colunas baseado na largura da tela
//           int crossAxisCount = 3;
//           if (constraints.maxWidth > 600) {
//             crossAxisCount = 4;
//           } else if (constraints.maxWidth > 900) {
//             crossAxisCount = 5;
//           }

//           final itemWidth =
//               (constraints.maxWidth - (ThemeConfig.spacing16 * (crossAxisCount - 1))) /
//                   crossAxisCount;
//           final itemHeight = itemWidth * 1.4; // Aspect ratio

//           return GridView.builder(
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: crossAxisCount,
//               crossAxisSpacing: ThemeConfig.spacing12,
//               mainAxisSpacing: ThemeConfig.spacing12,
//               childAspectRatio: itemWidth / itemHeight,
//             ),
//             itemCount: shopState.filteredItems.length,
//             itemBuilder: (context, index) {
//               final item = shopState.filteredItems[index];
//               return ShopItemCard(
//                 key: ValueKey(item.id),
//                 item: item,
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   String _getCategoryName(ItemCategory category) {
//     switch (category) {
//       case ItemCategory.food:
//         return '🍖 Comida';
//       case ItemCategory.toy:
//         return '⚽ Brinquedos';
//       case ItemCategory.medicine:
//         return '💊 Medicina';
//       case ItemCategory.decoration:
//         return '🎨 Decoração';
//       case ItemCategory.accessory:
//         return '👔 Acessórios';
//       case ItemCategory.special:
//         return '✨ Especiais';
//     }
//   }
// }
