// lib/src/features/adoption/presentation/screens/pending_request_details_screen.dart
// REFACTOR - Feedback visual melhorado + Animações + Progress indicators

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/src/core/navigation/app_routes.dart';
import 'package:petverse/src/core/utils/snackbar_utils.dart';
import 'package:petverse/src/features/adoption/presentation/providers/adoption_providers.dart';
import 'package:petverse/src/features/adoption/presentation/widgets/confirm_adoption_button.dart';
import 'package:petverse/src/features/adoption/presentation/widgets/pet_option_card.dart';
import 'package:petverse/src/features/auth/presentation/providers/user_data_provider.dart';

class PendingRequestDetailsScreen extends ConsumerWidget {
  final String requestId;

  const PendingRequestDetailsScreen({
    super.key,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ouvir confirmação de adoção com feedback visual melhorado
    ref.listen<AsyncValue<void>>(adoptionConfirmationNotifierProvider,
        (previous, next) {
      next.when(
        data: (_) {
          // Haptic feedback para sucesso
          HapticFeedback.lightImpact();

          showAppSnackBar(context, '🎉 Adoção confirmada com sucesso!',
              type: SnackBarType.success);

          ref.invalidate(userHasPetProvider);

          // Delay para mostrar feedback antes de navegar
          Future.delayed(const Duration(milliseconds: 800), () {
            if (context.mounted) {
              context.go(AppRoutes.home);
            }
          });
        },
        error: (e, s) {
          HapticFeedback.heavyImpact();
          showAppSnackBar(
              context, '❌ Erro ao confirmar adoção: ${e.toString()}',
              type: SnackBarType.error);
        },
        loading: () {
          HapticFeedback.selectionClick();
        },
      );
    });

    final requestAsyncValue = ref.watch(adoptionRequestByIdProvider(requestId));
    final selectedPetId = ref.watch(selectedPetIdProvider(requestId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Solicitação'),
        centerTitle: true,
        elevation: 0,
      ),
      body: requestAsyncValue.when(
        data: (request) {
          if (request == null) {
            return _buildNotFoundState(context);
          }

          final petOptionsAsyncValue = ref
              .watch(adoptionRequestPetOptionsProvider(request.petOptionsIds));

          return petOptionsAsyncValue.when(
            data: (pets) => _buildSuccessState(
                context, ref, request, pets, selectedPetId, requestId),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(context, error),
          );
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(context, error),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Solicitação não encontrada',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta solicitação pode ter sido removida ou não existe',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Carregando detalhes...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Ops! Algo deu errado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Erro: ${error.toString()}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    WidgetRef ref,
    dynamic request,
    List<dynamic> pets,
    String? selectedPetId,
    String requestId,
  ) {
    return CustomScrollView(
      slivers: [
        // Header com informações da solicitação
        SliverToBoxAdapter(
          child: _buildRequestHeader(context, request),
        ),

        // Progress indicator para seleção
        SliverToBoxAdapter(
          child: _buildSelectionProgress(context, pets.length, selectedPetId),
        ),

        // Lista de pets
        SliverToBoxAdapter(
          child: _buildPetSelectionSection(
              context, ref, pets, selectedPetId, requestId),
        ),

        // Botão de confirmação
        SliverToBoxAdapter(
          child: _buildConfirmationSection(requestId),
        ),

        // Espaçamento final
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildRequestHeader(BuildContext context, dynamic request) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pets_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Solicitação de Adoção',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            Icons.tag_rounded,
            'ID da Solicitação',
            '#${request.id.substring(0, 8)}...',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            Icons.access_time_rounded,
            'Status',
            request.status.toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color:
              Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer
                    .withOpacity(0.8),
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
      ],
    );
  }

  Widget _buildSelectionProgress(
      BuildContext context, int totalPets, String? selectedPetId) {
    final isSelected = selectedPetId != null;
    final progress = isSelected ? 1.0 : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso da Seleção',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isSelected ? 'Pet Selecionado' : 'Aguardando Seleção',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor:
                  Theme.of(context).colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSelected
                ? '✓ Pronto para confirmar a adoção!'
                : 'Escolha um dos $totalPets pets disponíveis',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetSelectionSection(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> pets,
    String? selectedPetId,
    String requestId,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Escolha seu Companheiro',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Selecione um dos pets abaixo para iniciar sua jornada de cuidado',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          if (pets.isEmpty)
            _buildNoPetsAvailable(context)
          else
            ...pets.asMap().entries.map((entry) {
              final index = entry.key;
              final pet = entry.value;
              return AnimatedContainer(
                duration: Duration(milliseconds: 200 + (index * 100)),
                curve: Curves.easeOutBack,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: PetOptionCard(
                    pet: pet,
                    isSelected: pet.id == selectedPetId,
                    onSelect: (petId) {
                      HapticFeedback.selectionClick();
                      ref
                          .read(selectedPetIdProvider(requestId).notifier)
                          .state = petId;
                    },
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildNoPetsAvailable(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pets_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.error.withOpacity(0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhum pet encontrado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Não há pets disponíveis para esta solicitação',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationSection(String requestId) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ConfirmAdoptionButton(requestId: requestId),
    );
  }
}
