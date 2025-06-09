// File: lib/presentation/widgets/shop/cart_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/enums/enums/app_enums.dart';
import 'package:petverse/core/utils/formatters.dart';
import 'package:petverse/presentation/providers/cart_provider.dart';
import 'package:petverse/presentation/providers/shop_provider.dart';
import 'package:petverse/presentation/providers/user_provider.dart';
import 'package:petverse/presentation/widgets/common/currency_display.dart';

class CartWidget extends ConsumerWidget {
  final VoidCallback? onTap;
  final bool showDetails;

  const CartWidget({
    super.key,
    this.onTap,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final userState = ref.watch(userGameDataProvider);

    if (cartState.isEmpty && !showDetails) {
      return const SizedBox.shrink();
    }

    return showDetails
        ? _buildDetailedCart(context, ref, cartState, userState)
        : _buildFloatingCart(context, cartState);
  }

  Widget _buildFloatingCart(BuildContext context, CartState cartState) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(ThemeConfig.borderRadius16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius16),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 120,
            maxWidth: 200,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ThemeConfig.primaryColor, ThemeConfig.primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(ThemeConfig.borderRadius16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone do carrinho com badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                  if (cartState.hasItems)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cartState.uniqueItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),

              if (cartState.hasItems) ...[
                const SizedBox(width: 8),
                // Valores de forma compacta
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (cartState.totalValue > 0)
                        Text(
                          '💰 ${Formatters.formatLargeNumber(cartState.totalValue)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (cartState.totalValueGems > 0)
                        Text(
                          '💎 ${cartState.totalValueGems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedCart(
      BuildContext context, WidgetRef ref, CartState cartState, UserGameDataState userState) {
    final screenSize = MediaQuery.of(context).size;
    final maxHeight = screenSize.height * 0.7;

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        maxWidth: screenSize.width - 32,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header responsivo
          _buildCartHeader(context, ref, cartState),

          // Conteúdo
          if (cartState.isEmpty)
            _buildEmptyCart()
          else
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lista de itens com altura limitada
                  _buildItemsList(context, ref, cartState, userState),

                  // Totais
                  _buildCartTotals(context, cartState),

                  // Botão de compra
                  _buildPurchaseButton(context, ref, cartState, userState),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartHeader(BuildContext context, WidgetRef ref, CartState cartState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ThemeConfig.primaryColor, ThemeConfig.primaryColor.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(ThemeConfig.borderRadius16),
          topRight: Radius.circular(ThemeConfig.borderRadius16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Carrinho (${cartState.uniqueItems} tipos)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (cartState.hasItems)
            IconButton(
              icon: const Icon(Icons.clear_all, color: Colors.white, size: 18),
              onPressed: () => _showClearCartConfirmation(context, ref),
              tooltip: 'Limpar carrinho',
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Seu carrinho está vazio',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Adicione alguns itens da loja!',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(
      BuildContext context, WidgetRef ref, CartState cartState, UserGameDataState userState) {
    return Flexible(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 200),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: cartState.items.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.2),
          ),
          itemBuilder: (context, index) {
            final item = cartState.items[index];
            return _buildCartItemTile(context, ref, item, userState.user?.level ?? 1);
          },
        ),
      ),
    );
  }

  Widget _buildCartItemTile(BuildContext context, WidgetRef ref, dynamic item, int userLevel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Ícone do item
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                item.shopItem.imageUrl,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Informações do item
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.shopItem.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Qtd: ${item.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Preço e ações
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.currency == CurrencyType.coins
                    ? '💰 ${Formatters.formatLargeNumber(item.totalPrice)}'
                    : '💎 ${item.totalPrice}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => ref.read(cartProvider.notifier).removeItem(item.id),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartTotals(BuildContext context, CartState cartState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cartState.totalSavings > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Economia:',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
                Text(
                  '💰 ${Formatters.formatLargeNumber(cartState.totalSavings.round())}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (cartState.totalValue > 0)
                      CurrencyDisplay(
                        icon: '💰',
                        value: cartState.totalValue,
                        color: ThemeConfig.coinsColor,
                      ),
                    if (cartState.totalValueGems > 0) ...[
                      const SizedBox(width: 8),
                      CurrencyDisplay(
                        icon: '💎',
                        value: cartState.totalValueGems,
                        color: ThemeConfig.gemsColor,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton(
      BuildContext context, WidgetRef ref, CartState cartState, UserGameDataState userState) {
    final canPurchase =
        cartState.canPurchase && userState.hasUser && cartState.canAfford(userState.user!);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: canPurchase ? () => _processPurchase(context, ref) : null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
            ),
            backgroundColor: canPurchase ? ThemeConfig.primaryColor : Colors.grey[300],
          ),
          child: cartState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  _getPurchaseButtonText(cartState, userState),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: canPurchase ? Colors.white : Colors.grey[600],
                  ),
                ),
        ),
      ),
    );
  }

  String _getPurchaseButtonText(CartState cartState, UserGameDataState userState) {
    if (!userState.hasUser) return 'Entre para comprar';
    if (!cartState.canAfford(userState.user!)) return 'Saldo insuficiente';
    return 'Finalizar Compra (${cartState.totalItems} itens)';
  }

  void _processPurchase(BuildContext context, WidgetRef ref) {
    ref.read(shopProvider.notifier).purchaseCart();
  }

  void _showClearCartConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Carrinho'),
        content: const Text('Tem certeza que deseja remover todos os itens do carrinho?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
