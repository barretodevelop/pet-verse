// ShopScreen

// lib/screens/shop_screen.dart - ShopScreen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/providers/app_provider.dart';
import 'package:petverse/providers/inventory_provider.dart';
import 'package:petverse/providers/theme_provider.dart';
import 'package:petverse/utils/constants.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String _selectedCategory = 'todos';

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final user = ref.watch(userProvider);

    final categories = [
      'todos',
      'comida',
      'brinquedo',
      'medicina',
      'acessório'
    ];
    final filteredItems = _selectedCategory == 'todos'
        ? Constants.shopItems
        : Constants.shopItems
            .where((item) => item.category == _selectedCategory)
            .toList();

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF111827), Color(0xFF1F2937)])
            : const LinearGradient(
                colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)]),
      ),
      child: Column(
        children: [
          // ✅ CORREÇÃO: Filter buttons com scroll otimizado
          Container(
            height: 50, // ✅ Altura reduzida
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory == category;

                return Container(
                  margin: const EdgeInsets.only(right: 6), // ✅ Margem reduzida
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
                        fontSize: 11, // ✅ Fonte reduzida
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    backgroundColor: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFF3F4F6),
                    selectedColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2), // ✅ Padding reduzido
                    materialTapTargetSize: MaterialTapTargetSize
                        .shrinkWrap, // ✅ Área de toque compacta
                  ),
                );
              },
            ),
          ),

          // ✅ CORREÇÃO: Grid com layout otimizado para evitar overflow
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12), // ✅ Padding reduzido
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75, // ✅ Proporção otimizada
                crossAxisSpacing: 6, // ✅ Espaçamento reduzido
                mainAxisSpacing: 6,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final canAfford = (user?.coins ?? 0) >= item.cost;

                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6), // ✅ Padding otimizado
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceEvenly, // ✅ Distribuição uniforme
                      children: [
                        // ✅ Emoji com flex controlado
                        Flexible(
                          flex: 3,
                          child: FittedBox(
                            child: Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),

                        // ✅ Nome com overflow controlado
                        Flexible(
                          flex: 2,
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 9, // ✅ Fonte bem pequena
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1, // ✅ Máximo 1 linha
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // ✅ Efeito com overflow controlado
                        Flexible(
                          flex: 2,
                          child: Text(
                            item.effect,
                            style: TextStyle(
                              fontSize: 7, // ✅ Fonte muito pequena
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // ✅ CORREÇÃO: Botão com tamanho controlado + preço sempre visível
                        Flexible(
                          flex: 2,
                          child: Column(
                            children: [
                              // ✅ PREÇO SEMPRE VISÍVEL (independente se pode comprar)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: canAfford
                                      ? const Color(0xFFFEF3C7)
                                      : const Color(
                                          0xFFFEE2E2), // ✅ Cor diferente quando não pode comprar
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: canAfford
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFEF4444),
                                    width: 1,
                                  ),
                                ),
                                child: FittedBox(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.monetization_on,
                                        size: 8,
                                        color: canAfford
                                            ? const Color(0xFFF59E0B)
                                            : const Color(0xFFEF4444),
                                      ),
                                      const SizedBox(width: 1),
                                      Text(
                                        '${item.cost}',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: canAfford
                                              ? const Color(0xFFA16207)
                                              : const Color(0xFFEF4444),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // ✅ BOTÃO DE COMPRA (só aparece se pode comprar)
                              if (canAfford)
                                Expanded(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => _buyItem(item),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF8B5CF6),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2),
                                        minimumSize: const Size(0, 16),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const FittedBox(
                                        child: Text(
                                          'Comprar',
                                          style: TextStyle(fontSize: 7),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                // ✅ MENSAGEM quando não pode comprar
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: const Color(0xFFE5E7EB)),
                                    ),
                                    child: const FittedBox(
                                      child: Text(
                                        'Sem moedas',
                                        style: TextStyle(
                                          fontSize: 7,
                                          color: Color(0xFF9CA3AF),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
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

  // ✅ CORREÇÃO: Método de compra melhorado
  void _buyItem(item) {
    final user = ref.read(userProvider);
    final userNotifier = ref.read(userProvider.notifier);
    final inventoryNotifier = ref.read(inventoryProvider.notifier);

    if (user != null && user.coins >= item.cost) {
      // Deduzir moedas
      userNotifier.updateCoins((user.coins - item.cost).toInt());

      // Adicionar ao inventário
      inventoryNotifier.addItem(item);

      // Feedback de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(child: Text('${item.name} comprado!')),
              const Icon(Icons.check_circle, color: Colors.white),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          behavior: SnackBarBehavior.floating,
        ),
      );

      print('✅ Item comprado: ${item.name} por ${item.cost} moedas'); // Debug
    } else {
      // Feedback de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      'Moedas insuficientes! Você precisa de ${item.cost} moedas.')),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          behavior: SnackBarBehavior.floating,
        ),
      );

      print(
          '❌ Compra falhou: moedas insuficientes (${user?.coins ?? 0}/${item.cost})'); // Debug
    }
  }
}
agora voce assume como analista sistema com vasto conhecimento em game  e em flutter   ,conforme roteiro anexo e preciso validar e corrigir os problemas no projeto no githubb anexo aos conhecimento, seguir com desenvolvimento incremental , para otimize o maximo o desnevolviemnto para nao exceder o limite de mensagens