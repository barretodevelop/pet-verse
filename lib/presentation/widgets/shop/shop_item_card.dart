// File: lib/presentation/widgets/shop/shop_item_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/core/utils/formatters.dart';
import 'package:petverse/domain/entities/shop_item_entity.dart';
import 'package:petverse/presentation/providers/cart_provider.dart';
import 'package:petverse/presentation/providers/user_provider.dart';

class ShopItemCard extends ConsumerStatefulWidget {
  final ShopItemEntity item;
  final VoidCallback? onTap;

  const ShopItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  ConsumerState<ShopItemCard> createState() => _ShopItemCardState();
}

class _ShopItemCardState extends ConsumerState<ShopItemCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userGameDataProvider);
    final cartState = ref.watch(cartProvider);
    final userLevel = userState.user?.level ?? 1;
    final price = widget.item.calculatePrice(userLevel: userLevel, quantity: _quantity);
    final isInCart = cartState.containsShopItem(widget.item.id);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown: (_) => _animationController.forward(),
          onTapUp: (_) => _animationController.reverse(),
          onTapCancel: () => _animationController.reverse(),
          onTap: widget.onTap ?? () => _showItemDetails(context),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: constraints.maxWidth,
                  // height: constraints.maxWidth * 3.8, // Proporção fixa
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: isInCart
                        ? Border.all(color: ThemeConfig.primaryColor, width: 2.5)
                        : Border.all(color: Colors.blue.withOpacity(0.3), width: 2.5),
                  ),
                  child: Column(
                    children: [
                      // Header com imagem - 45% da altura
                      Expanded(
                        flex: 45,
                        child: _buildImageHeader(context, constraints),
                      ),

                      // Conteúdo - 55% da altura
                      Expanded(
                        flex: 55,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nome e raridade
                              Expanded(
                                flex: 3,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.item.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          height: 1.1,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getRarityColor(),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _getRarityColor().withOpacity(0.3),
                                            blurRadius: 4,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Preço
                              Expanded(
                                flex: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (widget.item.currency == CurrencyType.coins
                                            ? ThemeConfig.coinsColor
                                            : ThemeConfig.gemsColor)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: (widget.item.currency == CurrencyType.coins
                                              ? ThemeConfig.coinsColor
                                              : ThemeConfig.gemsColor)
                                          .withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.item.currency == CurrencyType.coins ? '💰' : '💎',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          Formatters.formatLargeNumber(price),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: widget.item.currency == CurrencyType.coins
                                                ? ThemeConfig.coinsColor
                                                : ThemeConfig.gemsColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // const SizedBox(height: 8),

                              // Botão de ação
                              // Expanded(
                              //   flex: 2,
                              //   child: _buildActionButton(context, userState, isInCart, price),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildImageHeader(BuildContext context, BoxConstraints constraints) {
    return Container(
      decoration: BoxDecoration(
        gradient: _getRarityGradient(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          // Imagem central
          Center(
            child: Text(
              widget.item.imageUrl,
              style: TextStyle(
                fontSize: constraints.maxWidth * 0.35,
              ),
            ),
          ),

          // Badges no topo esquerdo
          Positioned(
            top: 8,
            left: 8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.item.isNew) _buildBadge('NEW', Colors.green),
                if (widget.item.isFeatured) _buildBadge('⭐', Colors.orange),
              ],
            ),
          ),

          // Desconto no topo direito
          if (widget.item.hasActiveDiscount)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  '-${(widget.item.discountPercentage * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // // Indicador de efeitos na parte inferior
          // if (widget.item.effects.isNotEmpty)
          //   Positioned(
          //     bottom: 8,
          //     left: 8,
          //     right: 8,
          //     child: Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          //       decoration: BoxDecoration(
          //         color: Colors.black.withOpacity(0.7),
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       child: Text(
          //         '+${widget.item.effects.length} efeito${widget.item.effects.length > 1 ? 's' : ''}',
          //         style: const TextStyle(
          //           color: Colors.white,
          //           fontSize: 9,
          //           fontWeight: FontWeight.w500,
          //         ),
          //         textAlign: TextAlign.center,
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, UserGameDataState userState, bool isInCart, int price) {
    final canAfford = userState.hasUser &&
        ((widget.item.currency == CurrencyType.coins && userState.user!.coins >= price) ||
            (widget.item.currency == CurrencyType.gems && userState.user!.gems >= price));

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canAfford ? () => _addToCart() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isInCart
              ? Colors.green
              : canAfford
                  ? ThemeConfig.primaryColor
                  : Colors.grey[300],
          foregroundColor: isInCart || canAfford ? Colors.white : Colors.grey[600],
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: canAfford ? 2 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isInCart
                  ? Icons.check_circle
                  : canAfford
                      ? Icons.add_shopping_cart
                      : Icons.block,
              size: 14,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                isInCart
                    ? 'No Carrinho'
                    : canAfford
                        ? 'Adicionar'
                        : 'Sem Fundos',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getRarityGradient() {
    switch (widget.item.rarity) {
      case ItemRarity.common:
        return LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ItemRarity.uncommon:
        return LinearGradient(
          colors: [Colors.green[300]!, Colors.green[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ItemRarity.rare:
        return LinearGradient(
          colors: [Colors.blue[300]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ItemRarity.epic:
        return LinearGradient(
          colors: [Colors.purple[300]!, Colors.purple[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ItemRarity.legendary:
        return LinearGradient(
          colors: [Colors.orange[300]!, Colors.orange[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getRarityColor() {
    switch (widget.item.rarity) {
      case ItemRarity.common:
        return Colors.grey;
      case ItemRarity.uncommon:
        return Colors.green;
      case ItemRarity.rare:
        return Colors.blue;
      case ItemRarity.epic:
        return Colors.purple;
      case ItemRarity.legendary:
        return Colors.orange;
    }
  }

  void _addToCart() {
    ref.read(cartProvider.notifier).addItem(
          shopItem: widget.item,
          quantity: _quantity,
          userLevel: ref.read(userGameDataProvider).user?.level ?? 1,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.item.name} adicionado ao carrinho!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showItemDetails(BuildContext context) {
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

            // Conteúdo scrollável
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header do item
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: _getRarityGradient(),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              widget.item.imageUrl,
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
                                widget.item.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.item.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Preço
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            widget.item.currency == CurrencyType.coins ? '💰' : '💎',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Formatters.formatLargeNumber(widget.item.calculatePrice(
                              userLevel: ref.read(userGameDataProvider).user?.level ?? 1,
                              quantity: _quantity,
                            )),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: widget.item.currency == CurrencyType.coins
                                  ? ThemeConfig.coinsColor
                                  : ThemeConfig.gemsColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Efeitos
                    if (widget.item.effects.isNotEmpty) ...[
                      const Text(
                        'Efeitos:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.item.effects.entries.map(
                        (effect) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: ThemeConfig.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${effect.key.name}: +${effect.value}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Controles de quantidade e botão
                    Row(
                      children: [
                        const Text('Quantidade: '),
                        IconButton(
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _quantity++),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            _addToCart();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Adicionar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
}
