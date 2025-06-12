﻿import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/models/inventory_user_item_model.dart'; // ✅ ADICIONADO: Import para InventoryUserItem
import 'package:petverse/models/item_model.dart'; // To cast item.baseItem
import 'package:petverse/models/pet_model.dart';
import 'package:petverse/providers/inventory_provider.dart';
import 'package:petverse/providers/pet_provider.dart'; // To update the pet
import 'package:petverse/providers/theme_provider.dart';
import 'package:petverse/providers/user_provider.dart';

// import 'bottom_sheet_base.dart'; // Removido: Não usaremos mais BottomSheetBase

class InventorySheet extends ConsumerWidget {
  // final bool show; // Removido
  // final VoidCallback onClose; // Removido
  final PetModel pet;
  final String category; // ✅ NOVO: Categoria dos itens a serem exibidos

  const InventorySheet({
    super.key,
    // required this.show, // Removido
    // required this.onClose, // Removido
    required this.pet,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    final isDark = ref.watch(themeProvider);

    // ✅ CORREÇÃO: Acessar category através de baseItem
    final categoryItems = inventory
        .where((invItem) => invItem.baseItem?.category == category)
        .toList();

    return Column(
      mainAxisSize: MainAxisSize
          .min, // Para que o Column não tente ocupar toda a altura desnecessariamente
      children: [
        // Header (similar ao que BottomSheetBase fazia)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _getCategoryTitle(category), // ✅ Título dinâmico
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pop(context), // Fecha o showModalBottomSheet
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
            height: 1,
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
        // Conteúdo principal (Grade ou mensagem de vazio)
        Expanded(
          // Para permitir que o GridView seja rolável se houver muitos itens
          child: categoryItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFD1D5DB),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum item de "$category" encontrado', // ✅ Mensagem dinâmica
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: categoryItems.length,
                  itemBuilder: (context, index) {
                    final invItem = categoryItems[index];
                    // ✅ CORREÇÃO: Acessar baseItem para detalhes do item
                    final baseItem = invItem.baseItem;
                    if (baseItem == null)
                      return const SizedBox
                          .shrink(); // Should not happen if populated correctly

                    // Apenas acessórios podem ser "equipados"
                    final isAccessory = baseItem.category == 'acessório';
                    final isEquipped = isAccessory &&
                        pet.accessories.any((acc) => acc.id == baseItem.id);

                    return GestureDetector(
                      onTap: () =>
                          _handleItemAction(context, ref, invItem, baseItem),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // color: isDark ? const Color(0xFF1F2937) : Colors.white, // ❌ REMOVIDO: Cor duplicada
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFE5E7EB),
                            width: isAccessory && isEquipped
                                ? 2
                                : 1, // Highlight if equipped
                          ),
                          color: isAccessory && isEquipped
                              ? (isDark
                                  ? Colors.purple.withOpacity(0.3)
                                  : Colors.purple.withOpacity(0.1))
                              : (isDark
                                  ? const Color(0xFF1F2937)
                                  : Colors.white),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Exibir quantidade do item
                              if (invItem.quantity >
                                  1) // ✅ Mostrar quantidade se > 1, para QUALQUER tipo de item
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'x${invItem.quantity}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),

                              Text(baseItem.emoji,
                                  style: const TextStyle(fontSize: 32)),
                              const SizedBox(height: 8),
                              Text(
                                baseItem.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1F2937),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                // Mostra o primeiro efeito como exemplo, ou uma descrição genérica
                                baseItem.effects.isNotEmpty
                                    ? '${baseItem.effects.keys.first}: +${baseItem.effects.values.first}'
                                    : 'Usar item',
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
                              if (isAccessory && isEquipped) ...[
                                const SizedBox(height: 5),
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                              ] else ...[
                                // Placeholder for consistent height if not equipped
                                const SizedBox(
                                    height: 5 +
                                        16), // Approximate height of the check icon + sizedbox
                              ],
                            ]),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _getCategoryTitle(String categoryKey) {
    switch (categoryKey) {
      case 'acessório':
        return 'Acessórios';
      case 'comida':
        return 'Alimentar Pet';
      case 'medicina':
        return 'Medicamentos';
      case 'brinquedo':
        return 'Brinquedos';
      default:
        return categoryKey.replaceRange(0, 1, categoryKey[0].toUpperCase());
    }
  }

  Future<void> _handleItemAction(
    BuildContext context,
    WidgetRef ref,
    InventoryUserItem invItem,
    ItemModel item, // Este é o baseItem
  ) async {
    final petNotifier = ref.read(petProvider.notifier);
    final inventoryNotifier = ref.read(inventoryProvider.notifier);
    final userNotifier = ref.read(userProvider.notifier);
    final user = ref.read(userProvider); // Para XP do usuário
    // final missionNotifier = ref.read(missionProvider.notifier); // Se for atualizar missões

    try {
      String snackBarMessage = "";

      if (item.category == 'acessório') {
        final isCurrentlyEquipped =
            pet.accessories.any((acc) => acc.id == item.id);
        List<ItemModel> updatedAccessories = List.from(pet.accessories);

        if (isCurrentlyEquipped) {
          updatedAccessories.removeWhere((acc) => acc.id == item.id);
          // Ao desequipar, o item volta para o inventário geral
          await inventoryNotifier
              .addItem(item); // Adiciona de volta ao inventário geral
          snackBarMessage = "${item.name} desequipado de ${pet.name}!";
          print('Accessory ${item.name} unequipped from ${pet.name}');
        } else {
          // Limitar a 1 acessório por enquanto
          if (updatedAccessories.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      '${pet.name} já pode usar apenas um acessório por vez!')),
            );
            return;
          }
          updatedAccessories.add(item);
          await inventoryNotifier.removeItem(
              invItem); // Remove do inventário geral pois está equipado
          snackBarMessage = "${item.name} equipado em ${pet.name}!";
          print('Accessory ${item.name} equipped on ${pet.name}');
        }
        final updatedPet = pet.copyWith(accessories: updatedAccessories);
        await petNotifier.updatePetData(updatedPet);
      } else if (item.category == 'comida' || item.category == 'medicina') {
        // Aplicar efeitos de itens consumíveis
        int newHappiness = pet.happiness;
        int newHunger = pet.hunger;
        int newEnergy = pet.energy;
        int newHealth = pet.health;

        item.effects.forEach((statName, value) {
          switch (statName) {
            case 'happiness':
              newHappiness = (pet.happiness + value).clamp(0, 100);
              break;
            case 'hunger':
              newHunger = (pet.hunger + value).clamp(0, 100);
              break;
            case 'energy':
              newEnergy = (pet.energy + value).clamp(0, 100);
              break;
            case 'health':
              newHealth = (pet.health + value).clamp(0, 100);
              break;
          }
        });

        await petNotifier.updatePetStats(pet.id,
            happiness: newHappiness,
            hunger: newHunger,
            energy: newEnergy,
            health: newHealth);
        await inventoryNotifier.removeItem(invItem); // Consumir item
        // O removeItem agora remove 1 por padrão
        snackBarMessage = "${item.name} usado em ${pet.name}!";
        await petNotifier.addPetXP(pet.id, 5); // Exemplo de XP
        if (user != null)
          await userNotifier.updateXP(user.xp + 2); // Exemplo de XP do usuário
        // missionNotifier.updateMissionProgress(missionId, 1); // Atualizar missão relevante
      } else if (item.category == 'brinquedo') {
        // Lógica para brinquedos (podem não ser consumíveis)
        // Aplicar efeitos, ex: aumentar felicidade, diminuir energia
        await petNotifier.updatePetStats(pet.id,
            happiness: (pet.happiness + (item.effects['happiness'] ?? 0))
                .clamp(0, 100),
            energy: (pet.energy + (item.effects['energy'] ?? 0)).clamp(0, 100));
        snackBarMessage = "${pet.name} brincou com ${item.name}!";
        await petNotifier.addPetXP(pet.id, 8);
        if (user != null) await userNotifier.updateXP(user.xp + 3);
        // Brinquedos podem ou não ser removidos do inventário
        // Se brinquedos forem consumíveis ou tiverem "usos", chame removeItem aqui.
      }

      if (snackBarMessage.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(snackBarMessage)),
        );
      }
      if (context.mounted) {
        // Sempre verifique se o widget está montado antes de usar o context em async gaps
        Navigator.pop(context); // Fecha o showModalBottomSheet
      }
    } catch (e) {
      print('❌ Error using accessory: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao usar acessório: ${e.toString()}')),
        );
      }
    }
  }
}
