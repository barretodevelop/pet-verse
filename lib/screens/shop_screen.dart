import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/providers/inventory_provider.dart';
import 'package:petverse/providers/theme_provider.dart';
import 'package:petverse/providers/user_provider.dart';
// import 'package:petverse/services/firestore_service.dart'; // Não mais necessário aqui diretamente
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
          // ✅ CORREÇÃO: Filter buttons com altura adequada
          Container(
            height: 60, // ✅ Altura aumentada
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory == category;

                return Container(
                  margin: const EdgeInsets.only(right: 8), // ✅ Margem aumentada
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
                        fontSize: 13, // ✅ Fonte aumentada
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) =>
                        setState(() => _selectedCategory = category),
                    backgroundColor: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFF3F4F6),
                    selectedColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6), // ✅ Padding aumentado
                    materialTapTargetSize:
                        MaterialTapTargetSize.padded, // ✅ Área de toque maior
                  ),
                );
              },
            ),
          ),

          // ✅ CORREÇÃO: Grid com layout otimizado e elementos MAIORES
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16), // ✅ Padding aumentado
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9, // ✅ Proporção ajustada para mais altura
                crossAxisSpacing: 12, // ✅ Espaçamento aumentado
                mainAxisSpacing: 12,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final canAfford = (user?.coins ?? 0) >= item.cost;

                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius:
                        BorderRadius.circular(16), // ✅ Border radius maior
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.08), // ✅ Sombra mais visível
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12), // ✅ Padding aumentado
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // ✅ Distribuição melhorada
                      children: [
                        // ✅ CORREÇÃO: Emoji com tamanho fixo maior
                        Container(
                          height: 50, // ✅ Altura ajustada
                          alignment: Alignment.center,
                          child: Text(
                            item.emoji,
                            style: const TextStyle(
                                fontSize: 36), // ✅ Emoji ajustado
                          ),
                        ),

                        // ✅ CORREÇÃO: Nome com fonte maior
                        Padding(
                          // Usar Padding em vez de Container com altura fixa
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          // alignment: Alignment.center,
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 13, // ✅ Fonte ajustada
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // ✅ CORREÇÃO: Efeito com fonte maior
                        Padding(
                          // Usar Padding em vez de Container com altura fixa
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          // alignment: Alignment.center,
                          child: Text(
                            // ✅ CORREÇÃO: Usar o mapa 'effects'
                            item.effects.isNotEmpty
                                ? '${item.effects.keys.first}: +${item.effects.values.first}'
                                : 'Sem efeito especial',
                            style: TextStyle(
                              fontSize: 10, // ✅ Fonte ajustada
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // ✅ CORREÇÃO: PREÇO e BOTÃO com tamanhos muito maiores
                        Column(
                          children: [
                            // ✅ PREÇO SEMPRE VISÍVEL e MAIOR
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4), // ✅ Padding maior
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: canAfford
                                    ? const Color(0xFFFEF3C7)
                                    : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(
                                    8), // ✅ Border radius maior
                                border: Border.all(
                                  color: canAfford
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFEF4444),
                                  width: 1.5, // ✅ Borda mais visível
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.monetization_on,
                                    size: 16, // ✅ Ícone maior (era 8)
                                    color: canAfford
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFEF4444),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.cost}',
                                    style: TextStyle(
                                      fontSize: 13, // ✅ Fonte ajustada
                                      fontWeight: FontWeight.bold,
                                      color: canAfford
                                          ? const Color(0xFFA16207)
                                          : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ✅ CORREÇÃO: BOTÃO MAIOR e mais visível
                            SizedBox(
                              width: double.infinity,
                              height: 32, // ✅ Altura ajustada
                              child: canAfford
                                  ? ElevatedButton(
                                      onPressed: () => _buyItem(item),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF8B5CF6),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10)), // ✅ Border radius maior
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8), // ✅ Padding maior
                                        elevation:
                                            2, // ✅ Elevação para destaque
                                      ),
                                      child: Text(
                                        'Comprar',
                                        style: const TextStyle(
                                          fontSize: 12, // ✅ Fonte ajustada
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8), // ✅ Padding maior
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF374151)
                                            : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFE5E7EB)),
                                      ),
                                      child: Text(
                                        'Sem moedas',
                                        style: TextStyle(
                                          // Manter estilo original se for adequado
                                          fontSize: 12, // ✅ Fonte maior (era 7)
                                          color: isDark
                                              ? const Color(0xFF9CA3AF)
                                              : const Color(0xFF6B7280),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                            ),
                          ],
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

  // ✅ CORREÇÃO: Método de compra com feedback melhorado
  Future<void> _buyItem(dynamic item) async {
    // Adicionado 'dynamic' para o tipo do item, ou use seu ShopItemModel
    final user = ref.read(userProvider);
    final userNotifier = ref.read(userProvider.notifier);
    final inventoryNotifier = ref.read(inventoryProvider.notifier);
    // final firestoreService = FirestoreService(); // Não mais necessário aqui diretamente

    if (user != null && user.coins >= item.cost) {
      final newCoinAmount = (user.coins - item.cost).toInt();

      try {
        // Agora o UserNotifier lida com a persistência e atualização do estado
        await userNotifier.updateCoins(newCoinAmount);

        // Adicionar ao inventário - agora também é assíncrono e interage com o Firestore
        try {
          await inventoryNotifier.addItem(item);
        } catch (e) {
          print(
              '⚠️ ShopScreen: Falha ao adicionar item ao inventário do Firestore via provider: $e');
          // Considerar reverter a dedução de moedas ou mostrar um erro mais específico
        }

        // Feedback de sucesso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Text(item.emoji, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${item.name} comprado!',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text('-${item.cost} moedas',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
        print('✅ Item comprado localmente: ${item.name}');
      } catch (e) {
        // Se falhar ao atualizar no Firebase
        print('❌ Falha ao comprar item (erro vindo do UserNotifier): $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Erro ao comprar item. Tente novamente. (Erro: ${e.toString().substring(0, (e.toString().length > 50) ? 50 : e.toString().length)})'), // Limita o tamanho da msg de erro
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    } else {
      // Feedback de moedas insuficientes (local)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Moedas insuficientes!',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Você precisa de ${item.cost} moedas',
                          style: const TextStyle(fontSize: 12)),
                      Text('Saldo atual: ${user?.coins ?? 0}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }

      print(
          '❌ Compra falhou: moedas insuficientes (${user?.coins ?? 0}/${item.cost})');
    }
  }
}
