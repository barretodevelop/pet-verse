import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_notifier.dart'; // Importa o appServiceProvider

class NotificationBar extends ConsumerWidget {
  const NotificationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa as notificações do AppState
    final notifications = ref.watch(appServiceProvider.select((state) => state.notifications));
    final isDark = ref.watch(appServiceProvider.select((state) => state.isDark));

    if (notifications.isEmpty) {
      return const SizedBox.shrink(); // Não mostra nada se não houver notificações
    }

    return Positioned(
      top: 20.0, // Equivalente a top-20 no Tailwind
      left: 16.0, // Equivalente a left-4 no Tailwind
      right: 16.0, // Equivalente a right-4 no Tailwind
      child: SafeArea(
        // Garante que não invada a área da notch
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: notifications.take(2).map((notification) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              color: isDark ? const Color(0xFF2D3748) : Colors.white, // bg-gray-800 ou bg-white
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0), // rounded-2xl
              ),
              elevation: 4.0, // shadow-lg
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: const Border(
                    left: BorderSide(
                      color: Colors.purple, // border-purple-500
                      width: 4.0,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // px-4 py-3
                child: Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14.0, // text-sm
                    color: isDark ? Colors.white : Colors.grey[800], // text-white ou text-gray-800
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
