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
    // Observa o estado do notifier de confirmação para mostrar o estado de carregamento
    final confirmationState = ref.watch(adoptionConfirmationNotifierProvider);

    return ElevatedButton(
      // Habilita o botão apenas se um pet estiver selecionado E não estiver carregando
      onPressed: (selectedPetId != null && !confirmationState.isLoading)
          ? () {
              // Chama o método confirm do notifier
              ref
                  .read(adoptionConfirmationNotifierProvider.notifier)
                  .confirm(requestId, selectedPetId);
            }
          : null,
      child: confirmationState.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white, // Ou a cor que se adequar ao seu tema
                strokeWidth: 2.0,
              ),
            )
          : const Text('Confirmar Adoção'),
    );
  }
}
