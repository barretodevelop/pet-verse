// File: lib/presentation/widgets/collaboration/collaboration_stats_widget.dart

import 'package:flutter/material.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/domain/entities/collaboration/user_collaboration_data_entity.dart';

class CollaborationStatsWidget extends StatelessWidget {
  final UserCollaborationDataEntity data;

  const CollaborationStatsWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ThemeConfig.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeConfig.primaryColor.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
        border: Border.all(
          color: ThemeConfig.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: ThemeConfig.primaryColor,
                size: 20,
              ),
              const SizedBox(width: ThemeConfig.spacing8),
              Text(
                'Suas Estatísticas',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ThemeConfig.primaryColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: ThemeConfig.spacing12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  '🏆',
                  'Nível',
                  data.experienceLevelName,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  '🤝',
                  'Colaborações',
                  '${data.stats.totalCollaborations}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  '👥',
                  'Reveals',
                  '${data.totalSuccessfulReveals}',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  '⭐',
                  'Rating',
                  data.cooperationRating.toStringAsFixed(1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String emoji, String label, String value) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: ThemeConfig.spacing4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}
