// DashboardScreen
// lib/screens/dashboard_screen.dart - DashboardScreen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/providers/inventory_provider.dart';
import 'package:petverse/providers/mission_provider.dart'; // Importar mission_provider
import 'package:petverse/providers/pet_provider.dart';
import 'package:petverse/providers/theme_provider.dart';
import 'package:petverse/providers/user_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final pets = ref.watch(petProvider);
    final inventory = ref.watch(inventoryProvider);
    final missionsState =
        ref.watch(missionProvider); // Obter estado das missões
    final isDark = ref.watch(themeProvider);

    // Calcular taxa de conclusão de missões
    final totalMissions = missionsState.length;
    final completedMissions =
        missionsState.where((m) => m.progress >= m.max).length;
    final missionCompletionRate = totalMissions > 0
        ? (completedMissions / totalMissions * 100).toStringAsFixed(0)
        : "0";
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF111827), Color(0xFF1F2937)])
            : const LinearGradient(
                colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)]),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar removido conforme discussão para um card mais enxuto
                // const SizedBox(width: 16), // Removido pois o avatar foi removido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.username ?? 'Usuário',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 16, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 4),
                          Text(
                            'Nível ${user?.level ?? 1}',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF374151)
                              : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: ((user?.xp ?? 0) % 100) / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [
                                Color(0xFF8B5CF6),
                                Color(0xFF3B82F6)
                              ]),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(user?.xp ?? 0) % 100}/100 XP • Total: ${user?.xp ?? 0} XP',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '🐾',
                  '${pets.length}',
                  'Pets Ativos',
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '📦',
                  '${inventory.length}',
                  'Inventário',
                  isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Achievement Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2937) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumo Geral',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Total Adotados',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${pets.length}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Missões Concluídas', // Label atualizado
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$missionCompletionRate%', // Usar a taxa calculada
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: completedMissions >
                                      0 // Condição de cor pode ser ajustada
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
