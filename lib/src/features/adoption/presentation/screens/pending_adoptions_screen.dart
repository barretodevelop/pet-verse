import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Importe go_router
import 'package:petverse/src/core/navigation/app_routes.dart'; // Importe AppRoutes
import 'package:petverse/src/features/adoption/presentation/providers/adoption_providers.dart';
import 'package:petverse/src/features/adoption/presentation/widgets/adoption_request_card.dart'; // Importe o novo widget

class PendingAdoptionsScreen extends ConsumerWidget {
  const PendingAdoptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o stream de solicitações pendentes
    final pendingRequestsAsyncValue =
        ref.watch(pendingAdoptionRequestsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pets Aguardando Parceiro')),
      body: pendingRequestsAsyncValue.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(
              child: Text('Nenhum pet aguardando parceiro no momento.'),
            );
          }
          // Exibe a lista de solicitações
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index]; // Obtém a solicitação
              return AdoptionRequestCard(
                // Usa o novo widget de card
                request: request, // Passa a solicitação para o card
                onTap: () {
                  // Implementa a navegação aqui
                  context.push(
                      '${AppRoutes.pendingAdoptions}/${request.id}'); // Navega para a rota de detalhes com o ID
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erro ao carregar solicitações: $error'),
        ),
      ),
    );
  }
}
