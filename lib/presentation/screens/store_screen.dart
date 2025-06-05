import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/data/models/user_currency.dart';

import '../providers/currency_provider.dart';
import '../providers/theme_provider.dart';

/// Categorias de itens na loja
enum StoreCategory {
  coins('Coins', Icons.monetization_on, Colors.amber),
  gems('Gems', Icons.diamond, Colors.cyan),
  petFood('Comida para Pet', Icons.restaurant, Colors.orange),
  petToys('Brinquedos', Icons.toys, Colors.pink),
  accessories('Acessórios', Icons.pets, Colors.purple),
  premium('Premium', Icons.star, Color.fromARGB(255, 181, 137, 6));

  const StoreCategory(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

/// Item da loja
class StoreItem {
  final String id;
  final String name;
  final String description;
  final int priceCoins;
  final int priceGems;
  final IconData icon;
  final Color color;
  final StoreCategory category;
  final bool isPopular;
  final bool isOnSale;
  final double? discountPercent;

  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    this.priceCoins = 0,
    this.priceGems = 0,
    required this.icon,
    required this.color,
    required this.category,
    this.isPopular = false,
    this.isOnSale = false,
    this.discountPercent,
  });
}

/// Tela da loja com itens para compra
class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  StoreCategory _selectedCategory = StoreCategory.coins;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Itens da loja
  static const List<StoreItem> _storeItems = [
    // Coins
    StoreItem(
      id: 'coins_100',
      name: '100 Coins',
      description: 'Pacote básico de moedas',
      priceGems: 5,
      icon: Icons.monetization_on,
      color: Colors.amber,
      category: StoreCategory.coins,
    ),
    StoreItem(
      id: 'coins_500',
      name: '500 Coins',
      description: 'Pacote intermediário',
      priceGems: 20,
      icon: Icons.monetization_on,
      color: Colors.amber,
      category: StoreCategory.coins,
      isPopular: true,
    ),
    StoreItem(
      id: 'coins_1000',
      name: '1000 Coins',
      description: 'Pacote premium de moedas',
      priceGems: 35,
      icon: Icons.monetization_on,
      color: Colors.amber,
      category: StoreCategory.coins,
      isOnSale: true,
      discountPercent: 20,
    ),

    // Gems
    StoreItem(
      id: 'gems_10',
      name: '10 Gems',
      description: 'Pacote básico de gemas',
      priceCoins: 150,
      icon: Icons.diamond,
      color: Colors.cyan,
      category: StoreCategory.gems,
    ),
    StoreItem(
      id: 'gems_50',
      name: '50 Gems',
      description: 'Pacote intermediário',
      priceCoins: 700,
      icon: Icons.diamond,
      color: Colors.cyan,
      category: StoreCategory.gems,
      isPopular: true,
    ),

    // Comida para Pet
    StoreItem(
      id: 'food_basic',
      name: 'Ração Premium',
      description: 'Aumenta a felicidade do pet',
      priceCoins: 50,
      icon: Icons.restaurant,
      color: Colors.orange,
      category: StoreCategory.petFood,
    ),
    StoreItem(
      id: 'food_deluxe',
      name: 'Petisco Especial',
      description: 'Aumenta significativamente a felicidade',
      priceCoins: 100,
      icon: Icons.cake,
      color: Colors.orange,
      category: StoreCategory.petFood,
      isPopular: true,
    ),

    // Brinquedos
    StoreItem(
      id: 'toy_ball',
      name: 'Bolinha Mágica',
      description: 'Aumenta a energia do pet',
      priceCoins: 80,
      icon: Icons.sports_soccer,
      color: Colors.pink,
      category: StoreCategory.petToys,
    ),
    StoreItem(
      id: 'toy_rope',
      name: 'Corda Divertida',
      description: 'Pet fica mais ativo',
      priceCoins: 60,
      icon: Icons.toys,
      color: Colors.pink,
      category: StoreCategory.petToys,
    ),

    // Acessórios
    StoreItem(
      id: 'collar_basic',
      name: 'Coleira Elegante',
      description: 'Deixa seu pet mais bonito',
      priceGems: 5,
      icon: Icons.pets,
      color: Colors.purple,
      category: StoreCategory.accessories,
    ),

    // Premium
    StoreItem(
      id: 'premium_monthly',
      name: 'Assinatura Mensal',
      description: 'Benefícios exclusivos por 30 dias',
      priceGems: 50,
      icon: Icons.star,
      color: Color(0xFFFFD700),
      category: StoreCategory.premium,
      isPopular: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(isLightThemeProvider);
    final userCurrency = ref.watch(userCurrencyProvider);
    final filteredItems = _getFilteredItems();

    return Scaffold(
      backgroundColor: isLightTheme ? Colors.red[50] : Colors.red[900],
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: SafeArea(
              child: Column(
                children: [
                  // Header da loja
                  _buildStoreHeader(isLightTheme, userCurrency),

                  // Barra de pesquisa
                  _buildSearchBar(isLightTheme),

                  // Seletor de categorias
                  _buildCategorySelector(isLightTheme),

                  // Lista de itens
                  Expanded(
                    child: _buildItemsList(
                        filteredItems, isLightTheme, userCurrency),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Constrói o cabeçalho da loja
  Widget _buildStoreHeader(bool isLightTheme, UserCurrency userCurrency) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLightTheme
              ? [Colors.red[400]!, Colors.red[600]!]
              : [Colors.red[700]!, Colors.red[900]!],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.store,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Loja Pet Adote',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showShoppingCart(),
                icon: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCurrencyDisplay(
                  '💰 ${userCurrency.coinsFormatted}',
                  'Coins',
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildCurrencyDisplay(
                  '💎 ${userCurrency.gemsFormatted}',
                  'Gems',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói um display de moeda
  Widget _buildCurrencyDisplay(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  /// Constrói a barra de pesquisa
  Widget _buildSearchBar(bool isLightTheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar itens...',
          prefixIcon: const Icon(Icons.search),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isLightTheme ? Colors.white : Colors.grey[800],
        ),
      ),
    );
  }

  /// Constrói o seletor de categorias
  Widget _buildCategorySelector(bool isLightTheme) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: StoreCategory.values.length,
        itemBuilder: (context, index) {
          final category = StoreCategory.values[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? category.color
                      : (isLightTheme ? Colors.white : Colors.grey[800]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? category.color
                        : (isLightTheme
                            ? Colors.grey[300]!
                            : Colors.grey[600]!),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: category.color.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category.icon,
                      color: isSelected
                          ? Colors.white
                          : (isLightTheme
                              ? Colors.grey[700]
                              : Colors.grey[300]),
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isLightTheme
                                ? Colors.grey[700]
                                : Colors.grey[300]),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  /// Constrói a lista de itens
  Widget _buildItemsList(
      List<StoreItem> items, bool isLightTheme, UserCurrency userCurrency) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: isLightTheme ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum item encontrado',
              style: TextStyle(
                fontSize: 18,
                color: isLightTheme ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildStoreItemCard(item, isLightTheme, userCurrency),
        );
      },
    );
  }

  /// Constrói um card de item da loja
  Widget _buildStoreItemCard(
      StoreItem item, bool isLightTheme, UserCurrency userCurrency) {
    final canBuyWithCoins =
        item.priceCoins > 0 && userCurrency.canAffordCoins(item.priceCoins);
    final canBuyWithGems =
        item.priceGems > 0 && userCurrency.canAffordGems(item.priceGems);
    final canBuy = canBuyWithCoins || canBuyWithGems;

    return Container(
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.white : Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.color.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícone do item
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 16),

                // Informações do item
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isLightTheme
                              ? Colors.grey[800]
                              : Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isLightTheme
                              ? Colors.grey[600]
                              : Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Preços
                      Row(
                        children: [
                          if (item.priceCoins > 0) ...[
                            _buildPriceTag(
                              '💰 ${item.priceCoins}',
                              Colors.amber,
                              canBuyWithCoins,
                            ),
                            if (item.priceGems > 0) const SizedBox(width: 8),
                          ],
                          if (item.priceGems > 0)
                            _buildPriceTag(
                              '💎 ${item.priceGems}',
                              Colors.cyan,
                              canBuyWithGems,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Botão de compra
                ElevatedButton(
                  onPressed: canBuy ? () => _buyItem(item) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: canBuy ? 4 : 0,
                  ),
                  child: Text(
                    canBuy ? 'Comprar' : 'Sem saldo',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Tags especiais
          if (item.isPopular)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Popular',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          if (item.isOnSale)
            Positioned(
              top: 8,
              right: item.isPopular ? 80 : 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.discountPercent?.toInt()}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Constrói uma tag de preço
  Widget _buildPriceTag(String price, Color color, bool canAfford) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            canAfford ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              canAfford ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Text(
        price,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: canAfford ? color : Colors.grey,
        ),
      ),
    );
  }

  /// Filtra os itens baseado na categoria e pesquisa
  List<StoreItem> _getFilteredItems() {
    return _storeItems.where((item) {
      final matchesCategory = item.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery) ||
          item.description.toLowerCase().contains(_searchQuery);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Compra um item
  void _buyItem(StoreItem item) {
    final currencyNotifier = ref.read(userCurrencyProvider.notifier);
    bool purchased = false;

    // Tenta comprar com coins primeiro, depois com gems
    if (item.priceCoins > 0 && currencyNotifier.spendCoins(item.priceCoins)) {
      purchased = true;
    } else if (item.priceGems > 0 &&
        currencyNotifier.spendGems(item.priceGems)) {
      purchased = true;
    }

    if (purchased) {
      _showPurchaseSuccessDialog(item);
      // Aqui você aplicaria os efeitos do item comprado
      _applyItemEffect(item);
    } else {
      _showInsufficientFundsDialog();
    }
  }

  /// Aplica os efeitos do item comprado
  void _applyItemEffect(StoreItem item) {
    final currencyNotifier = ref.read(userCurrencyProvider.notifier);

    switch (item.id) {
      case 'coins_100':
        currencyNotifier.addCoins(100);
        break;
      case 'coins_500':
        currencyNotifier.addCoins(500);
        break;
      case 'coins_1000':
        currencyNotifier.addCoins(1000);
        break;
      case 'gems_10':
        currencyNotifier.addGems(10);
        break;
      case 'gems_50':
        currencyNotifier.addGems(50);
        break;
      // Outros itens teriam efeitos específicos
      default:
        // Efeito genérico para itens de pet
        break;
    }
  }

  /// Mostra diálogo de compra bem-sucedida
  void _showPurchaseSuccessDialog(StoreItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compra Realizada!'),
        content: Text('Você comprou: ${item.name}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  /// Mostra diálogo de saldo insuficiente
  void _showInsufficientFundsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saldo Insuficiente'),
        content: const Text('Você não tem saldo suficiente para esta compra.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  /// Mostra o carrinho de compras
  void _showShoppingCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Carrinho'),
        content: const Text('Funcionalidade em desenvolvimento.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

/// Cor dourada customizada
extension CustomColors on Color {
  static const Color gold = Color(0xFFFFD700);
}
