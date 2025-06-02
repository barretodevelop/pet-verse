import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:petverse/shared/models/app_event.dart';
import 'package:petverse/shared/widgets/styled_app_bar.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEvent = ref.watch(eventManagerProvider).getActiveEvent();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const StyledAppBar(title: "Eventos Especiais"),
      body: Center(
        child: activeEvent != null
            ? Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (activeEvent.bannerAssetPath != null)
                        Image.asset(activeEvent.bannerAssetPath!,
                            height: 100,
                            errorBuilder: (c, e, s) => const Icon(
                                Icons.image_not_supported,
                                size: 50)),
                      const SizedBox(height: 16),
                      Text(activeEvent.name,
                          style: theme.textTheme.headlineMedium?.copyWith(
                              color: activeEvent.themeColor,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                          "Ativo até: ${DateFormat('dd/MM/yyyy').format(activeEvent.endDate)}",
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Navegar para a loja ou missões filtradas pelo evento, se aplicável
                          if (activeEvent.eventItemIds.isNotEmpty) {
                            context.go(
                                '/main/shop'); // A loja já considera o evento
                          } else if (activeEvent.eventQuestIds.isNotEmpty) {
                            context.go(
                                '/main/quests'); // As missões já consideram o evento
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: activeEvent.themeColor),
                        child: const Text("Ver Detalhes do Evento",
                            style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
              )
            : Text("Nenhum evento ativo no momento.",
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.onSurface)),
      ),
    );
  }
}
