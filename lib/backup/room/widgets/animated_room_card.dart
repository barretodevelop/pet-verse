import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:petverse/backup/room/model/room.dart';

class AnimatedRoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;

  const AnimatedRoomCard({
    super.key,
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: room.isActive
                ? [Colors.purple.shade400, Colors.purple.shade600]
                : [Colors.orange.shade400, Colors.orange.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (room.isActive ? Colors.purple : Colors.orange)
                  .withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    room.isActive ? 'Ativa' : 'Aguardando',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  room.isActive ? Icons.check_circle : Icons.hourglass_empty,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Código: ${room.code}',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              room.isActive
                  ? '${room.parentIds.length} participantes'
                  : 'Esperando co-parent...',
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0).shimmer(
            duration: 2.seconds,
            delay: 1.seconds,
            color: Colors.white.withOpacity(0.3),
          ),
    );
  }
}
