import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Para o ícone Coins
import '../../core/app_notifier.dart'; // Para acessar o appServiceProvider
import '../../data/mock_data.dart'; // Para SHOP_ITEMS

class ShopTab extends ConsumerStatefulWidget {
  const ShopTab({super.key});

  @override
  ConsumerState<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends ConsumerState<ShopTab> {
  String _currentFilter = 'todos'; // Estado para o filtro de categorias

  @override
  Widget build(BuildContext context) {
    final appService = ref.read(appServiceProvider.notifier); // Para chamar buyItem
    final appState = ref.watch(appServiceProvider); // Para ler coins e isDark

    final coins = appState.coins;
    final isDark = appState.isDark;

    // Obtém todas as categorias únicas e adiciona 'todos'
    final List<String> categories = [
      'todos',
      ...SHOP_ITEMS.map((item) => item.category).toSet().toList()
    ];

    // Filtra os itens da loja com base na categoria selecionada
    final filteredItems = _currentFilter == 'todos'
        ? SHOP_ITEMS
        : SHOP_ITEMS.where((item) => item.category == _currentFilter).toList();

    return Container(
      // Background (equivalente ao bg-gray-900 ou bg-gradient-to-br)
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A202C) : null, // gray-900
        gradient: isDark
            ? null
            : const LinearGradient(
                colors: [
                  Color(0xFFF3E8FF), // purple-100
                  Color(0xFFE0F2FE), // blue-100
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      padding: const EdgeInsets.all(16.0), // p-6
      child: Column(
        children: [
          // Filtros de Categoria
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 16.0), // space-y-4 (para espaçamento da coluna)
            child: Row(
              children: categories.map((category) {
                final isSelected = _currentFilter == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0), // space-x-2
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _currentFilter = category;
                        });
                      }
                    },
                    selectedColor: Colors.purple.shade500, // bg-purple-500
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey.shade300 : Colors.grey.shade700), // Corrected
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor:
                        isDark ? Colors.grey.shade700 : Colors.grey.shade100, // Corrected
                    side: BorderSide(
                      color: isSelected
                          ? Colors.purple.shade500
                          : (isDark ? Colors.grey.shade600 : Colors.grey.shade300), // Corrected
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Itens da Loja
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // grid-cols-3
                crossAxisSpacing: 12.0, // gap-3
                mainAxisSpacing: 12.0, // gap-3
                childAspectRatio: 0.75, // Ajuste para cards de itens (emojis maiores)
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final canAfford = coins >= item.cost;

                return Card(
                  color: isDark ? Colors.grey.shade800 : Colors.white, // Corrected
                  elevation: 4.0, // shadow-lg
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0), // rounded-2xl
                    side: BorderSide(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade200, // Corrected
                      width: 2.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0), // p-3
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribui o espaço
                      children: [
                        Text(
                          item.emoji,
                          style: const TextStyle(fontSize: 32), // text-3xl
                        ),
                        Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14, // text-sm
                            color: isDark ? Colors.white : Colors.grey.shade800, // Corrected
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.effect,
                          style: TextStyle(
                            fontSize: 10, // text-xs
                            color:
                                isDark ? Colors.grey.shade400 : Colors.grey.shade600, // Corrected
                          ),
                          textAlign: TextAlign.center,
                        ),
                        ElevatedButton(
                          onPressed: canAfford ? () => appService.buyItem(item) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade500, // from-purple-500 to-blue-500
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12.0), // py-2 px-3
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0), // rounded-xl
                            ),
                            elevation: 4.0, // shadow-lg
                          ).copyWith(
                            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return Colors.purple.shade500
                                      .withOpacity(0.5); // disabled:opacity-50
                                }
                                return Colors.purple.shade500;
                              },
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Ocupa o mínimo de espaço
                            children: [
                              Icon(LucideIcons.coins, size: 14, color: Colors.white), // w-3 h-3
                              const SizedBox(width: 4), // mr-1
                              Text(
                                '${item.cost}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600), // text-sm font-semibold
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
