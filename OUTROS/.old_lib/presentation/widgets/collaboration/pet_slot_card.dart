// File: lib/presentation/widgets/collaboration/pet_slot_card.dart

import 'package:flutter/material.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/presentation/providers/collaboration_slots_provider.dart';
import 'package:petverse/presentation/widgets/animations/bounce_animation.dart';

class PetSlotCard extends StatelessWidget {
  final CollaborationSlot slot;
  final VoidCallback? onTap;
  final bool isSelected;

  const PetSlotCard({
    super.key,
    required this.slot,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return BounceAnimation(
      child: Card(
        elevation: isSelected ? 8 : 2,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: isSelected ? Border.all(color: ThemeConfig.primaryColor, width: 2) : null,
            ),
            child: AspectRatio(
              aspectRatio: 0.8,
              child: Column(
                children: [
                  // Header com tipo do slot
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: ThemeConfig.spacing8,
                      vertical: ThemeConfig.spacing4,
                    ),
                    color: _getSlotTypeColor(slot.type),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          slot.type.emoji,
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          slot.type.displayName,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Conteúdo do slot
                  Expanded(
                    child: slot.isOccupied ? _buildOccupiedSlot(context) : _buildEmptySlot(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOccupiedSlot(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemeConfig.spacing12),
      child: Column(
        children: [
          // Pet Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getStatusColor(slot.status!),
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
              ),
              child: Stack(
                children: [
                  Center(
                    child: slot.pet!.imageUrl.isNotEmpty == true
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                            child: Image.network(
                              slot.pet!.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.pets,
                                size: 32,
                                color: ThemeConfig.primaryColor,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.pets,
                            size: 32,
                            color: ThemeConfig.primaryColor,
                          ),
                  ),

                  // Status indicator
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        slot.status!.emoji,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: ThemeConfig.spacing8),

          // Pet Info
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text(
                  slot.pet?.name ?? 'Pet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  slot.status!.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: _getStatusTextColor(slot.status!),
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySlot(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemeConfig.spacing12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.add,
              size: 32,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: ThemeConfig.spacing8),
          Text(
            slot.isAvailable ? 'Adotar Pet' : 'Bloqueado',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: slot.isAvailable ? ThemeConfig.primaryColor : Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
          if (!slot.isAvailable)
            Text(
              'Premium',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: Colors.amber[700],
                  ),
            ),
        ],
      ),
    );
  }

  Color _getSlotTypeColor(SlotType type) {
    switch (type) {
      case SlotType.regular:
        return ThemeConfig.primaryColor;
      case SlotType.premium:
        return Colors.amber[700]!;
      case SlotType.special:
        return Colors.purple;
    }
  }

  Color _getStatusColor(CollaborationStatus status) {
    switch (status) {
      case CollaborationStatus.waitingForPartner:
        return Colors.orange.withOpacity(0.2);
      case CollaborationStatus.activeCollaboration:
        return Colors.green.withOpacity(0.2);
      case CollaborationStatus.revealAvailable:
        return Colors.amber.withOpacity(0.2);
      case CollaborationStatus.revealed:
        return Colors.blue.withOpacity(0.2);
      case CollaborationStatus.abandoned:
        return Colors.red.withOpacity(0.2);
      case CollaborationStatus.completed:
        return Colors.purple.withOpacity(0.2);
    }
  }

  Color _getStatusTextColor(CollaborationStatus status) {
    switch (status) {
      case CollaborationStatus.waitingForPartner:
        return Colors.orange[700]!;
      case CollaborationStatus.activeCollaboration:
        return Colors.green[700]!;
      case CollaborationStatus.revealAvailable:
        return Colors.amber[800]!;
      case CollaborationStatus.revealed:
        return Colors.blue[700]!;
      case CollaborationStatus.abandoned:
        return Colors.red[700]!;
      case CollaborationStatus.completed:
        return Colors.purple[700]!;
    }
  }
}
