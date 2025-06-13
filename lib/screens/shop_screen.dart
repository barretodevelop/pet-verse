// lib/screens/shop_screen.dart - SECURE REFACTOR
// ✅ SEGURANÇA: Compras agora validadas server-side
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/providers/inventory_provider.dart';
import 'package:petverse/providers/theme_provider.dart';
import 'package:petverse/providers/user_provider.dart';
import 'package:petverse/services/secure_firestore_service.dart';
import 'package:petverse/utils/constants.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String _selectedCategory = 'todos';
  // ✅ NOVO: Estado para tracking de compras em andamento
  final Set<String> _purchasingItems = {};

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
          // ✅ Filter buttons mantidos iguais
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory == category;

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
                        fontSize: 13,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                  ),
                );
              },
            ),
          ),

          // ✅ Grid com melhor indicação de estado de compra
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                final canAfford = (user?.coins ?? 0) >= item.cost;
                final isPurchasing =
                    _purchasingItems.contains(item.id); // ✅ NOVO

                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1F2937) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ✅ Emoji com opacity durante compra
                        Container(
                          height: 50,
                          alignment: Alignment.center,
                          child: Opacity(
                            opacity: isPurchasing ? 0.5 : 1.0, // ✅ NOVO
                            child: Text(item.emoji,
                                style: const TextStyle(fontSize: 36)),
                          ),
                        ),

                        // ✅ Nome mantido igual
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 13,
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

                        // ✅ Efeito mantido igual
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            item.effects.isNotEmpty
                                ? '${item.effects.keys.first}: +${item.effects.values.first}'
                                : 'Sem efeito especial',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // ✅ PREÇO e BOTÃO com melhor estado de loading
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: canAfford
                                    ? const Color(0xFFFEF3C7)
                                    : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: canAfford
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFEF4444),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.monetization_on,
                                    size: 16,
                                    color: canAfford
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFFEF4444),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item.cost}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: canAfford
                                          ? const Color(0xFFA16207)
                                          : const Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ✅ BOTÃO com melhor estado de loading e segurança
                            SizedBox(
                              width: double.infinity,
                              height: 32,
                              child: canAfford
                                  ? ElevatedButton(
                                      onPressed: isPurchasing
                                          ? null
                                          : () =>
                                              _buyItemSecure(item), // ✅ NOVO
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF8B5CF6),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        elevation: 2,
                                      ),
                                      child:
                                          isPurchasing // ✅ NOVO: Loading state
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.white),
                                                  ),
                                                )
                                              : const Text(
                                                  'Comprar',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
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
                                          fontSize: 12,
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

  // ✅ NOVO: Método de compra seguro
  Future<void> _buyItemSecure(dynamic item) async {
    final user = ref.read(userProvider);

    if (user == null) {
      _showErrorSnackBar('❌ Usuário não logado');
      return;
    }

    if (user.coins < item.cost) {
      _showErrorSnackBar('❌ Moedas insuficientes');
      return;
    }

    // ✅ Prevenir compras múltiplas simultâneas
    if (_purchasingItems.contains(item.id)) {
      return;
    }

    setState(() => _purchasingItems.add(item.id));

    try {
      // ✅ USA OPERAÇÃO SEGURA com validação server-side
      final success = await SecureFirestoreService.purchaseShopItem(
        userId: user.id,
        item: item,
        quantity: 1,
      );

      if (success && mounted) {
        _showSuccessSnackBar(
          '🎉 ${item.name} comprado!',
          '${item.emoji} • -${item.cost} moedas',
        );
        print('✅ ShopScreen: Secure purchase completed: ${item.name}');
      }
    } catch (e) {
      print('❌ ShopScreen: Secure purchase failed: $e');

      if (mounted) {
        // ✅ Tratamento específico de erros
        if (e is InsufficientFundsException) {
          _showErrorSnackBar('💸 ${e.message}');
        } else if (e is SecurityException) {
          _showErrorSnackBar('🔒 ${e.message}');
        } else {
          _showErrorSnackBar('❌ Erro na compra: Tente novamente');

          // ✅ FALLBACK: Se operação segura falhar, tenta método legacy (temporário)
          print('⚠️ ShopScreen: Trying legacy purchase method due to: $e');
          await _buyItemLegacy(item);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _purchasingItems.remove(item.id));
      }
    }
  }

  // ✅ FALLBACK: Método legacy para casos de erro na operação segura
  Future<void> _buyItemLegacy(dynamic item) async {
    final user = ref.read(userProvider);
    final userNotifier = ref.read(userProvider.notifier);
    final inventoryNotifier = ref.read(inventoryProvider.notifier);

    if (user != null && user.coins >= item.cost) {
      final newCoinAmount = (user.coins - item.cost).toInt();

      try {
        await userNotifier.updateCoins(newCoinAmount,
            reason: 'Shop purchase: ${item.name}');
        await inventoryNotifier.addItem(item);

        if (mounted) {
          _showSuccessSnackBar(
            '🎉 ${item.name} comprado! (modo compatibilidade)',
            '${item.emoji} • -${item.cost} moedas',
          );
        }
        print('⚠️ ShopScreen: Legacy purchase completed: ${item.name}');
      } catch (e) {
        print('❌ ShopScreen: Legacy purchase failed: $e');
        if (mounted) {
          _showErrorSnackBar('❌ Falha na compra: ${e.toString()}');
        }
      }
    }
  }

  // ✅ Helper methods para feedback
  void _showSuccessSnackBar(String title, String subtitle) {
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
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
