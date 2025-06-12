import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Para o ícone Coins
import '../../core/app_notifier.dart'; // Para acessar o appServiceProvider

class MissionsTab extends ConsumerWidget {
  const MissionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(appServiceProvider.select((state) => state.missions));
    final isDark = ref.watch(appServiceProvider.select((state) => state.isDark));

    return Container(
      // Background (equivalente ao bg-gray-900 ou bg-gradient-to-br)
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A202C) : null, // gray-900
        gradient: isDark
            ? null
            : const LinearGradient(
                colors: [
                  Color(0xFFF3E8FF), // purple-100
                  Color(0xFFE0F2FE), // blue-100
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      padding: const EdgeInsets.all(16.0), // p-6
      child: ListView.builder(
        itemCount: missions.length,
        padding: const EdgeInsets.all(0),
        itemBuilder: (context, index) {
          final mission = missions[index];
          final isCompleted = mission.progress >= mission.max;

          return Card(
            margin: const EdgeInsets.only(bottom: 16.0), // space-y-4
            color: isCompleted
                ? Colors.green.shade50 // bg-green-50
                : (isDark ? Colors.grey.shade800 : Colors.white), // Corrected
            elevation: 4.0, // shadow-lg
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0), // rounded-2xl
              side: BorderSide(
                color: isCompleted
                    ? Colors.green.shade300 // border-green-300
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade200), // Corrected
                width: 2.0,
              ),
            ),
            child: Opacity(
              opacity: isCompleted ? 0.75 : 1.0, // opacity-75
              child: Padding(
                padding: const EdgeInsets.all(16.0), // p-4
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${isCompleted ? '✅ ' : ''}${mission.title}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isDark ? Colors.white : Colors.grey.shade800, // Corrected
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mission.desc,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade600, // Corrected
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(LucideIcons.coins,
                                size: 16, color: Colors.yellow.shade500), // Corrected
                            const SizedBox(width: 4),
                            Text(
                              '${mission.reward}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.grey.shade800, // Corrected
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12), // mb-2
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: mission.max > 0 ? mission.progress / mission.max : 0,
                            backgroundColor:
                                isDark ? Colors.grey.shade700 : Colors.grey.shade200, // Corrected
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted
                                  ? Colors.green.shade500 // from-green-400 to-green-500
                                  : Colors.purple.shade500, // from-purple-500 to-blue-500
                            ),
                            minHeight: 8, // h-2
                          ),
                        ),
                        const SizedBox(width: 12), // mr-3
                        Text(
                          '${mission.progress}/${mission.max}',
                          style: TextStyle(
                            fontSize: 12, // text-xs
                            fontWeight: FontWeight.w600, // font-semibold
                            color:
                                isDark ? Colors.grey.shade300 : Colors.grey.shade600, // Corrected
                          ),
                        ),
                      ],
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
}
