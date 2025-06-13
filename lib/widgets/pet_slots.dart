// lib/widgets/pet_slots.dart - SECURE REFACTOR
// ✅ SEGURANÇA: Desbloqueio de slots agora validado server-side
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/providers/app_provider.dart';
import 'package:petverse/providers/pet_provider.dart';
import 'package:petverse/providers/theme_provider.dart';
import 'package:petverse/providers/user_provider.dart';
import 'package:petverse/services/secure_firestore_service.dart'; // ✅ NOVO

class PetSlots extends ConsumerStatefulWidget {
  final VoidCallback? onSlotClick;

  const PetSlots({super.key, this.onSlotClick});

  @override
  ConsumerState<PetSlots> createState() => _PetSlotsState();
}

class _PetSlotsState extends ConsumerState<PetSlots> {
  // ✅ NOVO: Estado para tracking de desbloqueios em andamento
  bool _isUnlocking = false;

  @override
  Widget build(BuildContext context) {
    final pets = ref.watch(petProvider);
    final user = ref.watch(userProvider);
    final appState = ref.watch(appProvider);
    final isDark = ref.watch(themeProvider);

    final purchasedSlots = user?.purchasedSlotsCount ?? 2;
    final maxPossibleSlotsByLevel = 3 + ((user?.level ?? 1) ~/ 5);
    final absoluteMaxSlots = 10;

    int displaySlotsCount = purchasedSlots;
    if (purchasedSlots < maxPossibleSlotsByLevel &&
        purchasedSlots < absoluteMaxSlots) {
      displaySlotsCount = purchasedSlots + 1;
    }

    print(
        '✅ PetSlots: ${pets.length} pets, Purchased: $purchasedSlots, Displaying: $displaySlotsCount, MaxByLevel: $maxPossibleSlotsByLevel');

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
        itemCount: displaySlotsCount,
        itemBuilder: (context, index) {
          final pet = index < pets.length ? pets[index] : null;
          final isActive = index == appState.activePetIndex;
          final isLocked = index >= purchasedSlots;

          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
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
                          ? Text(pet.emoji,
                              style: const TextStyle(fontSize: 28))
                          : isLocked
                              ? (_isUnlocking
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.grey),
                                      ),
                                    )
                                  : const Icon(Icons.lock,
                                      color: Colors.grey, size: 24))
                              : Icon(Icons.add,
                                  color:
                                      isDark ? Colors.grey[400] : Colors.grey,
                                  size: 24),
                    ),

                    // ✅ Pet badges mantidos iguais
                    if (pet != null) ...[
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

                    // ✅ Badge de gemas melhorado para slots bloqueados
                    if (isLocked && !_isUnlocking)
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

  void _handleSlotTap(
      BuildContext context, WidgetRef ref, int index, pet, bool isLocked) {
    print(
        '🎯 Slot $index clicado - Pet: ${pet?.name ?? 'null'}, Locked: $isLocked');

    try {
      if (pet != null) {
        ref.read(appProvider.notifier).setActivePetIndex(index);
        print('✅ Pet ativado: ${pet.name} (índice $index)');

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
        print('✅ Abrindo adoção para slot $index');
        if (widget.onSlotClick != null) {
          widget.onSlotClick!();
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

  void _showUnlockDialog(BuildContext context, WidgetRef ref, int slotIndex) {
    final user = ref.watch(userProvider);
    final isDark = ref.watch(themeProvider);
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
                                color: Color(0xFFEF4444), fontSize: 12),
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
            onPressed: (user?.gems ?? 0) >= gemCost && !_isUnlocking
                ? () => _unlockSlotSecure(
                    context, ref, slotIndex, gemCost) // ✅ NOVO
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: _isUnlocking // ✅ NOVO: Loading state
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.diamond, size: 18),
                      SizedBox(width: 6),
                      Text('Desbloquear',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      ),
    );
  }

  // ✅ NOVO: Método seguro para desbloqueio de slot
  Future<void> _unlockSlotSecure(
      BuildContext context, WidgetRef ref, int slotIndex, int cost) async {
    final user = ref.read(userProvider);
    final userNotifier = ref.read(userProvider.notifier);

    if (user == null || user.gems < cost) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '❌ Gemas insuficientes! Você tem ${user?.gems ?? 0}, precisa de $cost.'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() => _isUnlocking = true);

    try {
      // ✅ USA OPERAÇÃO SEGURA com validação server-side
      await userNotifier.purchaseSlot(gemCost: cost);

      if (context.mounted) Navigator.of(context).pop();

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
                      Text('🎉 Slot ${slotIndex + 1} desbloqueado!',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Gemas restantes: ${user.gems - cost}',
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
      print('✅ Slot $slotIndex desbloqueado com segurança! Custo: $cost gemas');
    } catch (e) {
      print('❌ Falha no desbloqueio seguro do slot: $e');

      if (context.mounted) Navigator.of(context).pop();
      if (context.mounted) {
        // ✅ Tratamento específico de erros
        if (e is InsufficientFundsException) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('💸 ${e.message}'),
                backgroundColor: const Color(0xFFEF4444)),
          );
        } else if (e is SecurityException) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('🔒 ${e.message}'),
                backgroundColor: const Color(0xFFEF4444)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Erro no desbloqueio. Tente novamente.'),
              backgroundColor: Color(0xFFEF4444),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isUnlocking = false);
      }
    }
  }
}
