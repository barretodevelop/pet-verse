// File: lib/presentation/widgets/collaboration/real_time_action_widget.dart

import 'package:flutter/material.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_action_entity.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';

class RealTimeActionWidget extends StatelessWidget {
  final CollaborativeActionEntity action;

  const RealTimeActionWidget({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return SlideFadeAnimation(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: ThemeConfig.spacing8),
        padding: const EdgeInsets.all(ThemeConfig.spacing12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            // Action emoji
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: action.actionType.name.contains('feed')
                    ? Colors.orange.withOpacity(0.1)
                    : action.actionType.name.contains('play')
                        ? Colors.green.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  action.actionType.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(width: ThemeConfig.spacing12),

            // Action info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.displayText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (action.xpGained > 0) ...[
                    const SizedBox(height: ThemeConfig.spacing2),
                    Text(
                      '+${action.xpGained} XP',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ],
              ),
            ),

            // Time indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ThemeConfig.spacing6,
                vertical: ThemeConfig.spacing2,
              ),
              decoration: BoxDecoration(
                color: _getTimeColor(action.minutesAgo),
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadius4),
              ),
              child: Text(
                _getTimeText(action.minutesAgo),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTimeColor(int minutesAgo) {
    if (minutesAgo < 5) return Colors.green;
    if (minutesAgo < 30) return Colors.orange;
    return Colors.grey;
  }

  String _getTimeText(int minutesAgo) {
    if (minutesAgo < 1) return 'AGORA';
    if (minutesAgo < 60) return '${minutesAgo}min';
    final hours = minutesAgo ~/ 60;
    return '${hours}h';
  }
}
