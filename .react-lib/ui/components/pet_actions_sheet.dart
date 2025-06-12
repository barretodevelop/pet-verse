import 'dart:math'; // Para min/max

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Para LucideIcons
import '../../core/app_notifier.dart'; // Para acessar o appServiceProvider
import '../../models/pet.dart'; // Para o modelo Pet
import 'bottom_sheet.dart'; // Para o BottomSheet base
import 'confirmation_modal.dart'; // Para o ConfirmationModal aninhado
import 'inventory_sheet.dart'; // Para o InventorySheet aninhado
import 'pet_chat_sheet.dart'; // Para o PetChatSheet aninhado

class PetActionsSheet extends ConsumerStatefulWidget {
  final Pet? pet; // O pet ativo
  final bool show;
  final VoidCallback onClose;

  const PetActionsSheet({
    super.key,
    required this.pet,
    required this.show,
    required this.onClose,
  });

  @override
  ConsumerState<PetActionsSheet> createState() => _PetActionsSheetState();
}

class _PetActionsSheetState extends ConsumerState<PetActionsSheet> {
  bool _showInventorySheet = false;
  bool _showReturnConfirm = false;
  bool _showChatSheet = false;

  @override
  Widget build(BuildContext context) {
    final appService = ref.read(appServiceProvider.notifier);
    final isDark = ref.watch(appServiceProvider.select((state) => state.isDark));

    if (widget.pet == null) return const SizedBox.shrink();

    // Replicando a lógica de ações do React
    final List<Map<String, dynamic>> actions = [
      {
        'emoji': '🍖',
        'name': 'Alimentar',
        'description': 'Saciar a fome do pet',
        'color': [Colors.orange.shade500, Colors.red.shade500],
        'onTap': () {
          appService.updatePetStats(widget.pet!.id, {
            'hunger': min(100, widget.pet!.hunger + 25),
            'happiness': min(100, widget.pet!.happiness + 10),
          });
          appService.addPetXP(widget.pet!.id, 10);
          appService.addUserXP(5);
          appService.updateMissionProgress(1, 1);
          appService.createParticle('heart', 250, 250); // Posição mockada
          widget.onClose();
        }
      },
      {
        'emoji': '🎾',
        'name': 'Brincar',
        'description': 'Aumentar felicidade',
        'color': [Colors.blue.shade500, Colors.purple.shade500],
        'onTap': () {
          appService.updatePetStats(widget.pet!.id, {
            'happiness': min(100, widget.pet!.happiness + 20),
            'energy': max(0, widget.pet!.energy - 10),
          });
          appService.addPetXP(widget.pet!.id, 15);
          appService.addUserXP(8);
          appService.updateMissionProgress(2, 1);
          appService.createParticle('star', 250, 250); // Posição mockada
          widget.onClose();
        }
      },
      {
        'emoji': '💤',
        'name': 'Cuidar',
        'description': 'Restaurar energia e saúde',
        'color': [Colors.green.shade500, Colors.teal.shade500],
        'onTap': () {
          appService.updatePetStats(widget.pet!.id, {
            'energy': min(100, widget.pet!.energy + 30),
            'health': min(100, widget.pet!.health + 15),
          });
          appService.addPetXP(widget.pet!.id, 12);
          appService.addUserXP(10);
          appService.updateMissionProgress(3, 1);
          appService.createParticle('sparkle', 250, 250); // Posição mockada
          widget.onClose();
        }
      },
      {
        'emoji': '💝',
        'name': 'Carinho',
        'description': 'Demonstrar amor',
        'color': [
          Colors.pink.shade500,
          Colors.red.shade500
        ], // Corrected (from 'rose-500' to red-500)
        'onTap': () {
          appService.updatePetStats(widget.pet!.id, {
            'happiness': min(100, widget.pet!.happiness + 15),
            'health': min(100, widget.pet!.health + 5),
          });
          appService.addPetXP(widget.pet!.id, 8);
          appService.addUserXP(3);
          appService.createParticle('heart', 250, 250); // Posição mockada
          widget.onClose();
        }
      },
    ];

    return Stack(
      children: [
        AppBottomSheet(
          show: widget.show,
          onClose: widget.onClose,
          title: 'Cuidar de ${widget.pet!.name}',
          children: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Collaboration Info (se o pet for colaborativo)
              if (widget.pet!.isCollab)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.purple.shade50, // Corrected
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.purple.shade200, width: 2.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blue.shade500,
                            child: Text(widget.pet!.userAvatar ?? '❓',
                                style: const TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 12),
                          Text(widget.pet!.emoji, style: const TextStyle(fontSize: 36)),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey.shade400, // Corrected
                            child: Text(
                                widget.pet!.identityRevealed == true
                                    ? widget.pet!.partnerAvatar ?? '❓'
                                    : '❓',
                                style: const TextStyle(fontSize: 24)),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.messageCircle, color: Colors.purple.shade500),
                        onPressed: () => setState(() => _showChatSheet = true),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.purple.shade100,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),

              // Ações
              Text(
                'Ações',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.grey.shade800, // Corrected
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0, // Torna os cards quadrados
                ),
                itemCount: actions.length,
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return GestureDetector(
                    onTap: widget.pet!.canInteract ? action['onTap'] : null,
                    child: Card(
                      color: isDark ? Colors.grey.shade800 : Colors.white, // Corrected
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Opacity(
                        opacity: widget.pet!.canInteract ? 1.0 : 0.5,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            gradient: LinearGradient(
                              colors: [
                                (action['color'] as List<Color>)[0].withOpacity(0.1),
                                (action['color'] as List<Color>)[1].withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color:
                                  isDark ? Colors.grey.shade700 : Colors.grey.shade200, // Corrected
                              width: 2.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(action['emoji'].toString(),
                                    style: const TextStyle(fontSize: 40)),
                                const SizedBox(height: 8),
                                Text(
                                  action['name'].toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color:
                                        isDark ? Colors.white : Colors.grey.shade800, // Corrected
                                  ),
                                ),
                                Text(
                                  action['description'].toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600, // Corrected
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
              // Botão de Acessórios
              Text(
                'Inventário',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.grey.shade800, // Corrected
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => setState(() => _showInventorySheet = true),
                child: Card(
                  color: isDark ? Colors.grey.shade800 : Colors.white, // Corrected
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('👑', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Text(
                          'Acessórios',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.grey.shade800, // Corrected
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(Equipar no pet)',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDark ? Colors.grey.shade400 : Colors.grey.shade600, // Corrected
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Botão Devolver Pet
              ElevatedButton.icon(
                onPressed: () => setState(() => _showReturnConfirm = true),
                icon: const Icon(LucideIcons.trash2, size: 20),
                label: const Text('Devolver Pet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),

        // Sheets/Modals aninhados
        InventorySheet(
          show: _showInventorySheet,
          onClose: () => setState(() => _showInventorySheet = false),
          pet: widget.pet,
        ),
        PetChatSheet(
          show: _showChatSheet,
          onClose: () => setState(() => _showChatSheet = false),
          pet: widget.pet,
        ),
        ConfirmationModal(
          show: _showReturnConfirm,
          title: 'Devolver Pet',
          message:
              'Tem certeza que deseja devolver ${widget.pet!.name}? Esta ação não pode ser desfeita.',
          cost: 3,
          onConfirm: () {
            appService.returnPet(widget.pet!.id);
            if (mounted) {
              setState(() => _showReturnConfirm = false);
              widget.onClose(); // Fecha a PetActionsSheet após devolver
            }
          },
          onCancel: () => setState(() => _showReturnConfirm = false),
        ),
      ],
    );
  }
}
