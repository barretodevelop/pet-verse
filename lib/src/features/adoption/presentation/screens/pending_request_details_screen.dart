import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/src/core/navigation/app_routes.dart';
import 'package:petverse/src/core/utils/snackbar_utils.dart'; // Import snackbar utility
import 'package:petverse/src/features/adoption/presentation/providers/adoption_providers.dart';
import 'package:petverse/src/features/adoption/presentation/widgets/confirm_adoption_button.dart';
import 'package:petverse/src/features/adoption/presentation/widgets/pet_option_card.dart';
import 'package:petverse/src/features/auth/presentation/providers/user_data_provider.dart'; // Importar o userHasPetProvider

class PendingRequestDetailsScreen extends ConsumerWidget {
  final String requestId; // Para receber o ID da rota

  const PendingRequestDetailsScreen({
    super.key,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ouvir o estado do notifier de confirmação de adoção
    ref.listen<AsyncValue<void>>(adoptionConfirmationNotifierProvider,
        (previous, next) {
      next.when(
        data: (_) {
          showAppSnackBar(context, 'Adoção confirmada com sucesso!',
              type: SnackBarType.success);

          // Invalida o provider que verifica se o usuário tem pet para forçar a re-busca
          // Isso garante que o router tenha o status mais recente para redirecionamento
          ref.invalidate(userHasPetProvider);

          // Navega para a Home. O router agora usará o status atualizado de userHasPet.
          context.go(AppRoutes.home);
        },
        error: (e, s) {
          showAppSnackBar(context, 'Erro ao confirmar adoção: ${e.toString()}',
              type: SnackBarType.error);
        },
        loading: () {
          // Opcional: Mostrar um indicador de carregamento global se necessário
        },
      );
    });

    // Observa o provider que busca a solicitação pelo ID
    final requestAsyncValue = ref.watch(adoptionRequestByIdProvider(requestId));

    // Observa o ID do pet selecionado para esta solicitação
    final selectedPetId = ref.watch(selectedPetIdProvider(requestId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da Solicitação')),
      body: requestAsyncValue.when(
        data: (request) {
          if (request == null) {
            return const Center(child: Text('Solicitação não encontrada.'));
          }

          // Agora que temos a solicitação, buscamos os detalhes dos pets
          final petOptionsAsyncValue = ref
              .watch(adoptionRequestPetOptionsProvider(request.petOptionsIds));

          return petOptionsAsyncValue.when(
            data: (pets) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID da Solicitação: ${request.id.substring(0, 6)}...'),
                    Text(
                        'Iniciador: ${request.initiatorUserId.substring(0, 6)}...'),
                    Text('Status: ${request.status}'),
                    const SizedBox(height: 16),
                    const Text(
                      'Escolha um dos pets para adotar:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (pets.isEmpty)
                      const Text(
                          'Nenhum pet encontrado para esta solicitação.'),
                    ...pets.map((pet) => PetOptionCard(
                          pet: pet,
                          isSelected: pet.id ==
                              selectedPetId, // Passa o estado de seleção
                          onSelect: (petId) {
                            // Passa a função para selecionar
                            ref
                                .read(selectedPetIdProvider(requestId).notifier)
                                .state = petId;
                          },
                        )),
                    const SizedBox(height: 24), // Espaço antes do botão
                    ConfirmAdoptionButton(
                        requestId:
                            requestId), // Adiciona o botão de confirmação
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Erro ao carregar detalhes dos pets: $error'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erro ao carregar solicitação: $error'),
        ),
      ),
    );
  }
}
