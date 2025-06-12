// File: lib/presentation/widgets/pet/pet_slot_widget.dart
// Widget para slots dinâmicos de pets na interface game-first

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';
import 'package:petverse/presentation/providers/collaboration_slots_provider.dart';
import 'package:petverse/presentation/widgets/animations/bounce_animation.dart';
import 'package:petverse/presentation/widgets/animations/pulse_animation.dart';

class PetSlotWidget extends ConsumerWidget {
  final CollaborationSlot slot;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const PetSlotWidget({
    super.key,
    required this.slot,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (slot.isOccupied && slot.pet != null) {
      return _buildOccupiedSlot(context);
    } else if (slot.isAvailable) {
      return _buildAvailableSlot(context);
    } else {
      return _buildLockedSlot(context);
    }
  }

  Widget _buildOccupiedSlot(BuildContext context) {
    final pet = slot.pet!;
    final needsAttention = _petNeedsAttention(pet);

    return BounceAnimation(
      onTap: onTap,
      child: Container(
        width: width ?? 160,
        height: height ?? 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius16),
          gradient: _getSlotGradient(),
          boxShadow: [
            BoxShadow(
              color: _getStatusColor().withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Pet avatar
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (needsAttention)
                    PulseAnimation(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Pet emoji/avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getPetEmoji(pet),
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Pet name
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Lv.${pet.level}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Status indicator
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),

            // Collaboration indicator
            if (slot.status == CollaborationStatus.activeCollaboration)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.people,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableSlot(BuildContext context) {
    return BounceAnimation(
      onTap: onTap,
      child: Container(
        width: width ?? 160,
        height: height ?? 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius16),
          border: Border.all(
            color: ThemeConfig.primaryColor.withOpacity(0.5),
            width: 2,
            style: BorderStyle.solid,
          ),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              ThemeConfig.primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: ThemeConfig.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: ThemeConfig.primaryColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.add,
                color: ThemeConfig.primaryColor,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Adotar Pet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              slot.type == SlotType.premium
                  ? 'Slot Premium'
                  : 'Slot Gratuito', // ✅ CORRIGIDO: usar slot.type
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedSlot(BuildContext context) {
    return Container(
      width: width ?? 160,
      height: height ?? 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius16),
        color: Colors.grey[300],
        border: Border.all(
          color: Colors.grey[400]!,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock,
              color: Colors.grey[600],
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Slot Bloqueado',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            slot.type == SlotType.premium
                ? 'Premium Required'
                : 'Especial', // ✅ CORRIGIDO: usar slot.type
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  LinearGradient _getSlotGradient() {
    switch (slot.status) {
      case CollaborationStatus.activeCollaboration:
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CollaborationStatus.waitingForPartner:
        return const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case CollaborationStatus.revealAvailable:
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getStatusColor() {
    switch (slot.status) {
      case CollaborationStatus.activeCollaboration:
        return Colors.purple;
      case CollaborationStatus.waitingForPartner:
        return Colors.cyan;
      case CollaborationStatus.revealAvailable:
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  bool _petNeedsAttention(CollaborativePetEntity pet) {
    // Verificar se o pet precisa de atenção baseado nos stats
    return pet.hunger < 30 || pet.happiness < 30 || pet.energy < 20 || pet.health < 40;
  }

  String _getPetEmoji(CollaborativePetEntity pet) {
    // Retornar emoji baseado no imageUrl ou usar padrão
    if (pet.imageUrl.contains('🐱')) return '🐱';
    if (pet.imageUrl.contains('🐶')) return '🐶';
    if (pet.imageUrl.contains('🐹')) return '🐹';
    if (pet.imageUrl.contains('🐰')) return '🐰';
    if (pet.imageUrl.contains('🦊')) return '🦊';
    return '🐾'; // Padrão
  }
}
