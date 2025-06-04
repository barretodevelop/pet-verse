import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/features/adoption/presentation/providers/adoption_providers.dart'; // Importa os providers de adoção

// Botão para confirmar a adoção de um pet selecionado em uma solicitação pendente
class ConfirmAdoptionButton extends ConsumerWidget {
  final String requestId; // ID da solicitação de adoção

  const ConfirmAdoptionButton({super.key, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o ID do pet selecionado para esta solicitação para habilitar/desabilitar o botão
    final selectedPetId = ref.watch(selectedPetIdProvider(requestId));

    return ElevatedButton(
      onPressed: selectedPetId == null
          ? null
          : () {
              // TODO: Implementar lógica de confirmação de adoção
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Confirmar adoção do pet $selectedPetId para solicitação $requestId')),
              );
            },
      child: const Text('Confirmar Adoção'),
    );
  }
}
