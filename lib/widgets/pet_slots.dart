// PetSlots
// lib/widgets/pet_slots.dart - PetSlots
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/providers/app_provider.dart';
import 'package:petverse/providers/pet_provider.dart';
import 'package:petverse/providers/theme_provider.dart';
// import 'package:petverse/services/firestore_service.dart'; // Não mais necessário aqui diretamente
import 'package:petverse/providers/user_provider.dart';

class PetSlots extends ConsumerWidget {
  final VoidCallback? onSlotClick;

  const PetSlots({super.key, this.onSlotClick});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petProvider);
    final user = ref.watch(userProvider);
    final appState = ref.watch(appProvider);
    final isDark = ref.watch(themeProvider);

    final maxSlots = 2 + ((user?.level ?? 1) ~/ 5);
    final unlockedSlots =
        pets.length + 1; // +1 para sempre ter um slot vazio disponível
    final totalSlots = maxSlots.clamp(unlockedSlots, 10); // Máximo 10 slots

    print(
        '✅ PetSlots: ${pets.length} pets, $unlockedSlots desbloqueados, $totalSlots total, max: $maxSlots'); // Debug

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalSlots,
        itemBuilder: (context, index) {
          final pet = index < pets.length ? pets[index] : null;
          final isActive = index == appState.activePetIndex;
          final isLocked = index >= unlockedSlots;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              // ✅ CORREÇÃO CRÍTICA: Funcionalidade completa do onTap
              onTap: () => _handleSlotTap(context, ref, index, pet, isLocked),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF8B5CF6).withOpacity(0.2)
                      : (isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFF3F4F6)),
                  borderRadius: BorderRadius.circular(16),
                  border: isActive
                      ? Border.all(color: const Color(0xFF8B5CF6), width: 2)
                      : Border.all(color: Colors.transparent, width: 2),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    Center(
                      child: pet != null
                          ? Text(
                              pet.isUnique ? '✨' : pet.emoji,
                              style: const TextStyle(fontSize: 28),
                            )
                          : isLocked
                              ? const Icon(Icons.lock,
                                  color: Colors.grey, size: 24)
                              : Icon(Icons.add,
                                  color:
                                      isDark ? Colors.grey[400] : Colors.grey,
                                  size: 24),
                    ),

                    // ✅ Pet badges melhorados
                    if (pet != null) ...[
                      // Level badge
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)]),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1))
                            ],
                          ),
                          child: Center(
                            child: Text('${pet.level}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ),
                      ),

                      // Collaboration badge
                      if (pet.isCollab)
                        Positioned(
                          bottom: 2,
                          left: 2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                                color: Color(0xFF8B5CF6),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.people,
                                size: 10, color: Colors.white),
                          ),
                        ),

                      // Unique badge
                      if (pet.isUnique)
                        Positioned(
                          top: 2,
                          left: 2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Color(0xFFFBBF24),
                                Color(0xFFF59E0B)
                              ]),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome,
                                size: 10, color: Colors.white),
                          ),
                        ),

                      // Accessories indicator
                      if (pet.accessories.isNotEmpty)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle),
                            child: Text('${pet.accessories.length}',
                                style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ),
                    ],

                    // ✅ CORREÇÃO: Badge de gemas para slots bloqueados
                    if (isLocked)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: const Icon(Icons.diamond,
                              size: 12, color: Colors.white),
                        ),
                      ),

                    // ✅ ADIÇÃO: Indicador de slot vazio disponível
                    if (pet == null && !isLocked)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                              color: Color(0xFF10B981), shape: BoxShape.circle),
                          child: const Icon(Icons.add,
                              size: 8, color: Colors.white),
                        ),
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

  // ✅ CORREÇÃO CRÍTICA: Método centralizado para lidar com toque nos slots
  void _handleSlotTap(
      BuildContext context, WidgetRef ref, int index, pet, bool isLocked) {
    print(
        '🎯 Slot $index clicado - Pet: ${pet?.name ?? 'null'}, Locked: $isLocked'); // Debug

    try {
      if (pet != null) {
        // ✅ Slot com pet - ativar pet
        ref.read(appProvider.notifier).setActivePetIndex(index);
        print('✅ Pet ativado: ${pet.name} (índice $index)');

        // Feedback visual
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(pet.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text('${pet.name} selecionado!'),
              ],
            ),
            duration: const Duration(milliseconds: 1500),
            backgroundColor: const Color(0xFF8B5CF6),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else if (!isLocked) {
        // ✅ Slot vazio desbloqueado - abrir adoção
        print('✅ Abrindo adoção para slot $index');

        if (onSlotClick != null) {
          onSlotClick!();
        } else {
          print('⚠️ onSlotClick é null - não é possível abrir adoção');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Funcionalidade de adoção não disponível'),
              backgroundColor: Color(0xFFF59E0B),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // ✅ Slot bloqueado - mostrar dialog de desbloqueio
        print('🔒 Slot $index bloqueado - abrindo dialog de desbloqueio');
        _showUnlockDialog(context, ref, index);
      }
    } catch (e) {
      print('❌ Erro no toque do slot $index: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro: $e'),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ✅ CORREÇÃO CRÍTICA: Dialog completo de desbloqueio de slot
  void _showUnlockDialog(BuildContext context, WidgetRef ref, int slotIndex) {
    final user = ref.read(userProvider);
    final isDark = ref.read(themeProvider);
    const gemCost = 5;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_open,
                  color: Color(0xFF8B5CF6), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Desbloquear Slot ${slotIndex + 1}',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Deseja desbloquear um novo slot para adotar mais pets?',
              style: TextStyle(
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFF3E8FF), Color(0xFFDDD6FE)]),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.diamond,
                          color: Color(0xFF8B5CF6), size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Custo: $gemCost gemas',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AED),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Seu saldo: ${user?.gems ?? 0} gemas',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7C3AED),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ✅ Aviso se não tem gemas suficientes
            if ((user?.gems ?? 0) < gemCost) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF4444)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning,
                        color: Color(0xFFEF4444), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gemas insuficientes!',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Você precisa de mais ${gemCost - (user?.gems ?? 0)} gemas',
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Color(0xFF10B981), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Você tem gemas suficientes!',
                        style: TextStyle(
                          color: Color(0xFF065F46),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: (user?.gems ?? 0) >= gemCost
                ? () => _unlockSlot(context, ref, slotIndex, gemCost)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond, size: 18),
                const SizedBox(width: 6),
                Text('Desbloquear',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      ),
    );
  }

  // ✅ CORREÇÃO CRÍTICA: Lógica de desbloqueio de slot funcional
  Future<void> _unlockSlot(
      BuildContext context, WidgetRef ref, int slotIndex, int cost) async {
    final userNotifier = ref.read(userProvider.notifier);
    final user = ref.read(userProvider);
    // final firestoreService = FirestoreService(); // Não mais necessário aqui diretamente

    if (user != null && user.gems >= cost) {
      final newGemAmount = user.gems - cost;

      try {
        // Agora o UserNotifier lida com a persistência e atualização do estado
        await userNotifier.updateGems(newGemAmount);

        // Lógica de UI (fechar dialog, mostrar SnackBar) permanece aqui

        // Fechar dialog
        if (context.mounted) Navigator.of(context).pop();

        // Feedback de sucesso
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.lock_open,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Slot ${slotIndex + 1} desbloqueado!',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Gemas restantes: $newGemAmount',
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.celebration, color: Colors.white, size: 24),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        print(
            '✅ Slot $slotIndex desbloqueado localmente! Gemas: ${user.gems} → $newGemAmount');
      } catch (e) {
        // Se falhar ao atualizar no Firebase
        print('❌ Falha ao desbloquear slot (erro vindo do UserNotifier): $e');
        if (context.mounted)
          Navigator.of(context).pop(); // Fechar dialog mesmo em erro
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Erro ao desbloquear slot. Tente novamente. (Erro: ${e.toString().substring(0, (e.toString().length > 50) ? 50 : e.toString().length)})'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      'Gemas insuficientes! Você tem ${user?.gems ?? 0}, precisa de $cost.')),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 3),
        ),
      );
      print('❌ Gemas insuficientes: ${user?.gems ?? 0}/$cost');
    }
  }
}
