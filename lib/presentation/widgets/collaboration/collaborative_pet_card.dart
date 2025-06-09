// File: lib/presentation/widgets/collaboration/collaborative_pet_card.dart

import 'package:flutter/material.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';
import 'package:petverse/presentation/widgets/animations/bounce_animation.dart';

class CollaborativePetCard extends StatelessWidget {
  final CollaborativePetEntity pet;
  final VoidCallback? onAdopt;
  final VoidCallback? onTap;

  const CollaborativePetCard({
    super.key,
    required this.pet,
    this.onAdopt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BounceAnimation(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _getStatusColor(pet.status),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: pet.imageUrl.isNotEmpty
                            ? Image.network(
                                pet.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.pets,
                                  size: 48,
                                  color: ThemeConfig.primaryColor,
                                ),
                              )
                            : Icon(
                                Icons.pets,
                                size: 48,
                                color: ThemeConfig.primaryColor,
                              ),
                      ),

                      // Status Badge
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            pet.status.emoji,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),

                      // Level Badge
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeConfig.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Lv.${pet.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(ThemeConfig.spacing12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: ThemeConfig.spacing4),
                      Text(
                        pet.difficulty.displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: ThemeConfig.spacing4),
                      Text(
                        pet.status.displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _getStatusTextColor(pet.status),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: ThemeConfig.spacing8),
                      if (onAdopt != null)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onAdopt,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: const Text('Adotar Junto'),
                          ),
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                '~${_getEstimatedTime(pet.difficulty)} para reveal',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(CollaborationStatus status) {
    switch (status) {
      case CollaborationStatus.waitingForPartner:
        return Colors.orange.withOpacity(0.1);
      case CollaborationStatus.activeCollaboration:
        return Colors.green.withOpacity(0.1);
      case CollaborationStatus.revealAvailable:
        return Colors.amber.withOpacity(0.1);
      case CollaborationStatus.revealed:
        return Colors.blue.withOpacity(0.1);
      case CollaborationStatus.abandoned:
        return Colors.red.withOpacity(0.1);
      case CollaborationStatus.completed:
        return Colors.purple.withOpacity(0.1);
    }
  }

  Color _getStatusTextColor(CollaborationStatus status) {
    switch (status) {
      case CollaborationStatus.waitingForPartner:
        return Colors.orange;
      case CollaborationStatus.activeCollaboration:
        return Colors.green;
      case CollaborationStatus.revealAvailable:
        return Colors.amber[800]!;
      case CollaborationStatus.revealed:
        return Colors.blue;
      case CollaborationStatus.abandoned:
        return Colors.red;
      case CollaborationStatus.completed:
        return Colors.purple;
    }
  }

  String _getEstimatedTime(CollaborationDifficulty difficulty) {
    switch (difficulty) {
      case CollaborationDifficulty.beginner:
        return '1-2 semanas';
      case CollaborationDifficulty.intermediate:
        return '2-3 semanas';
      case CollaborationDifficulty.advanced:
        return '3-4 semanas';
      case CollaborationDifficulty.expert:
        return '1-2 meses';
    }
  }
}
