import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Para LucideIcons
import '../../core/app_notifier.dart'; // Para acessar o appServiceProvider
import '../../models/pet.dart';
import 'bottom_sheet.dart'; // Para o modelo Pet

class InventorySheet extends ConsumerWidget {
  final bool show;
  final VoidCallback onClose;
  final Pet? pet; // O pet que está usando o inventário

  const InventorySheet({
    super.key,
    required this.show,
    required this.onClose,
    required this.pet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(appServiceProvider.select((state) => state.inventory));
    final appService = ref.read(appServiceProvider.notifier);
    final isDark = ref.watch(appServiceProvider.select((state) => state.isDark));

    // Filtra apenas acessórios
    final accessories = inventory.where((item) => item.type == 'accessory').toList();

    return AppBottomSheet(
      show: show,
      onClose: onClose,
      title: 'Acessórios para ${pet?.name ?? 'Pet'}',
      fullHeight: false, // Pode ser fullHeight se quiser mais espaço
      children: accessories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.package,
                      size: 64,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400), // Corrected
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum acessório no inventário.',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, // Corrected
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Compre alguns na Loja!',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade700, // Corrected
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              shrinkWrap: true, // Para usar dentro de um SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // Evita rolagem aninhada
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.8, // Ajuste para melhor visualização dos cards
              ),
              itemCount: accessories.length,
              itemBuilder: (context, index) {
                final item = accessories[index];
                return GestureDetector(
                  onTap: () {
                    if (pet != null) {
                      appService.useItem(item, pet!.id);
                      onClose();
                    }
                  },
                  child: Card(
                    color: isDark ? Colors.grey.shade800 : Colors.white, // Corrected
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item.emoji, style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 8),
                          Text(
                            item.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.effect,
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  isDark ? Colors.grey.shade400 : Colors.grey.shade600, // Corrected
                            ),
                            textAlign: TextAlign.center,
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
}
