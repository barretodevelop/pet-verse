import 'package:flutter/material.dart';
import 'package:petverse/src/features/adoption/data/models/adoption_request_model.dart';

class AdoptionRequestCard extends StatelessWidget {
  final AdoptionRequest request;
  final VoidCallback? onTap; // Para lidar com o clique no card

  const AdoptionRequestCard({
    super.key,
    required this.request,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      child: InkWell(
        // Usar InkWell para adicionar efeito de clique
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Solicitação de Adoção #${request.id.substring(0, 6)}...', // Exibe parte do ID
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8.0),
              Text(
                'Pets Selecionados (${request.petOptionsIds.length}):',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8.0),
              // TODO: Substituir por uma lista horizontal de miniaturas dos pets
              Text(
                request.petOptionsIds
                    .join(', '), // Exibe os IDs dos pets por enquanto
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
