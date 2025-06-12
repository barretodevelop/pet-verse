// PetSlots
// lib/widgets/pet_slots.dart - PetSlots
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/providers/app_provider.dart' hide userProvider;
import 'package:petverse/providers/pet_provider.dart';
import 'package:petverse/providers/theme_provider.dart';
import 'package:petverse/providers/user_provider.dart';

class PetSlots extends ConsumerWidget {
  final VoidCallback?
      onSlotClick; // ✅ CORREÇÃO 1: Callback opcional com null safety

  const PetSlots({super.key, this.onSlotClick});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petProvider);
    final user = ref.watch(userProvider);
    final appState = ref.watch(appProvider);
    final isDark = ref.watch(themeProvider);

    final maxSlots = 2 + ((user?.level ?? 1) ~/ 5);
    final unlockedSlots = pets.length + 1;
    final totalSlots = maxSlots > unlockedSlots
        ? maxSlots
        : unlockedSlots +
            1; // ✅ CORREÇÃO 2: Sempre mostrar pelo menos um slot bloqueado

    print(
        '✅ PetSlots: ${pets.length} pets, $unlockedSlots desbloqueados, $totalSlots total'); // Debug

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
              // ✅ CORREÇÃO 3: Lógica completa de onTap com tratamento de erros
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
                              : const Icon(Icons.add,
                                  color: Colors.grey, size: 24),
                    ),

                    // Pet badges
                    if (pet != null) ...[
                      // Level badge
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF374151) : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${pet.level}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
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
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.people,
                              size: 10,
                              color: Colors.white,
                            ),
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
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],

                    // ✅ CORREÇÃO 4: Badge de gemas para slots bloqueados
                    if (isLocked)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFF8B5CF6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.diamond,
                            size: 12,
                            color: Colors.white,
                          ),
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

  // ✅ CORREÇÃO 5: Método centralizado para lidar com toque nos slots
  void _handleSlotTap(
      BuildContext context, WidgetRef ref, int index, pet, bool isLocked) {
    try {
      if (pet != null) {
        // Slot com pet - ativar pet
        ref.read(appProvider.notifier).setActivePetIndex(index);
        print('✅ Pet ativado: ${pet.name}');
      } else if (!isLocked) {
        // Slot vazio desbloqueado - abrir adoção
        print('✅ Abrindo adoção para slot $index');
        onSlotClick?.call();
      } else {
        // Slot bloqueado - mostrar dialog de desbloqueio
        print('✅ Slot $index bloqueado - abrindo dialog');
        _showUnlockDialog(context, ref);
      }
    } catch (e) {
      print('❌ Erro no toque do slot: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  // ✅ CORREÇÃO 6: Dialog completo de desbloqueio de slot
  void _showUnlockDialog(BuildContext context, WidgetRef ref) {
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
            const Icon(Icons.lock_open, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 8),
            Text(
              'Desbloquear Slot',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Deseja desbloquear um novo slot para pets?',
              style: TextStyle(
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF8B5CF6), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.diamond, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 8),
                  Text(
                    'Custo: $gemCost gemas',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Você tem: ${user?.gems ?? 0} gemas',
              style: TextStyle(
                fontSize: 12,
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),

            // ✅ CORREÇÃO 7: Aviso se não tem gemas suficientes
            if ((user?.gems ?? 0) < gemCost) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFEE2E2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Color(0xFFEF4444), size: 16),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Gemas insuficientes!',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 12,
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
            child: Text(
              'Cancelar',
              style: TextStyle(
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: (user?.gems ?? 0) >= gemCost
                ? () => _unlockSlot(context, ref, gemCost)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  // ✅ CORREÇÃO 8: Lógica de desbloqueio de slot
  void _unlockSlot(BuildContext context, WidgetRef ref, int cost) {
    final userNotifier = ref.read(userProvider.notifier);
    final user = ref.read(userProvider);

    if (user != null && user.gems >= cost) {
      // Deduzir gemas
      userNotifier.updateGems(user.gems - cost);

      // Fechar dialog
      Navigator.of(context).pop();

      // Mostrar feedback de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Novo slot desbloqueado!'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );

      print('✅ Slot desbloqueado! Gemas restantes: ${user.gems - cost}');
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Gemas insuficientes!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
  }
}
