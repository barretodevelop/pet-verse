import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Para o ícone Rss
import '../../core/app_notifier.dart'; // Para acessar o appServiceProvider

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedPosts = ref.watch(appServiceProvider.select((state) => state.feedPosts));
    final isDark = ref.watch(appServiceProvider.select((state) => state.isDark));

    // Funções auxiliares para ícones e cores dos posts (replicando a lógica React)
    String getPostIcon(String type) {
      switch (type) {
        case 'adoption':
          return '🎉';
        case 'death':
          return '💀';
        case 'level_up':
          return '⭐';
        case 'collaboration':
          return '🤝';
        case 'return':
          return '🔄';
        case 'unique_generation':
          return '🎨';
        default:
          return '📢';
      }
    }

    Color getPostBackgroundColor(String type) {
      switch (type) {
        case 'adoption':
          return Colors.green.shade50;
        case 'death':
          return Colors.red.shade50;
        case 'level_up':
          return Colors.yellow.shade50;
        case 'collaboration':
          return Colors.purple.shade50;
        case 'unique_generation':
          return Colors.pink.shade50;
        default:
          return Colors.white;
      }
    }

    Color getPostBorderColor(String type) {
      switch (type) {
        case 'adoption':
          return Colors.green.shade300;
        case 'death':
          return Colors.red.shade300;
        case 'level_up':
          return Colors.yellow.shade300;
        case 'collaboration':
          return Colors.purple.shade300;
        case 'unique_generation':
          return Colors.pink.shade300;
        default:
          return Colors.grey.shade200;
      }
    }

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
      child: feedPosts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.rss,
                    size: 64, // w-16 h-16
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, // Corrected
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Feed de Notícias',
                    style: TextStyle(
                      fontSize: 20, // text-xl
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey.shade800, // Corrected
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Acompanhe as atividades da comunidade',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, // Corrected
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: feedPosts.length,
              padding: const EdgeInsets.all(0), // Remova o padding padrão do ListView
              itemBuilder: (context, index) {
                final post = feedPosts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0), // space-y-4
                  color: isDark
                      ? Colors.grey.shade800
                      : getPostBackgroundColor(post.type), // Corrected
                  elevation: 4.0, // shadow-lg
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0), // rounded-2xl
                    side: BorderSide(
                      color: isDark
                          ? Colors.grey.shade700
                          : getPostBorderColor(post.type), // Corrected
                      width: 2.0,
                    ),
                  ),
                  child: Opacity(
                    opacity: 1.0, // No specific opacity logic, so full opacity
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), // p-4
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getPostIcon(post.type),
                            style: const TextStyle(fontSize: 24), // text-2xl
                          ),
                          const SizedBox(width: 12), // space-x-3
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.content,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        isDark ? Colors.white : Colors.grey.shade800, // Corrected
                                  ),
                                  softWrap: true, // Garante que o texto quebre linhas
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  // Formata a data e hora
                                  '${DateTime.fromMillisecondsSinceEpoch(post.timestamp).toLocal().toString().split('.')[0]}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade500, // Corrected
                                  ),
                                ),
                              ],
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
}
