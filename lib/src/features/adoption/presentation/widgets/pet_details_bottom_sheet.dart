import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/src/core/navigation/app_routes.dart';
import 'package:petverse/src/core/utils/snackbar_utils.dart'; // Importar o utilitário de SnackBar
import 'package:petverse/src/features/adoption/presentation/providers/adoption_providers.dart'; // For confirmation/rejection notifiers
import 'package:petverse/src/features/auth/presentation/providers/user_data_provider.dart'; // For userHasPetProvider invalidation
import 'package:petverse/src/features/pets/data/models/pet_model.dart';

// Bottom sheet to display pet details and adoption action buttons
class PetDetailsBottomSheet extends ConsumerWidget {
  final Pet pet;
  final String requestId; // The ID of the adoption request this pet belongs to

  const PetDetailsBottomSheet({
    super.key,
    required this.pet,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to confirmation state
    ref.listen<AsyncValue<void>>(adoptionConfirmationNotifierProvider,
        (previous, next) {
      next.when(
        data: (_) {
          // Dismiss the bottom sheet
          Navigator.of(context).pop();
          showAppSnackBar(context, 'Adoção confirmada com sucesso!',
              type: SnackBarType.success);
          ref.invalidate(userHasPetProvider); // Invalidate user pet status
          context.go(AppRoutes.home); // Navigate to home
        },
        error: (e, s) {
          // Dismiss the bottom sheet (optional, maybe keep it open to show error)
          // Navigator.of(context).pop();
          showAppSnackBar(context, 'Erro ao confirmar adoção: ${e.toString()}',
              type: SnackBarType.error);
        },
        loading: () {
          // Show loading indicator if needed (handled by button state)
        },
      );
    });
    // Listen to rejection state
    ref.listen<AsyncValue<void>>(adoptionRejectionNotifierProvider,
        (previous, next) {
      next.when(
        data: (_) {
          // Rejection successful.
          // The listener in PendingAdoptionsScreen will handle dismissing the sheet
          // and showing the primary snackbar.
        },
        error: (e, s) => showAppSnackBar(
            context, 'Erro ao rejeitar solicitação: ${e.toString()}',
            type: SnackBarType.error),
        loading: () {
          // Loading state for rejection is handled by the button's progress indicator
        },
      );
    });

    final confirmationState = ref.watch(adoptionConfirmationNotifierProvider);
    final rejectionState = ref.watch(adoptionRejectionNotifierProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Wrap content
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hero(
            // Adicionar Hero widget
            tag: 'pet-image-${pet.id}-$requestId', // Mesma tag usada no card
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: pet.imageUrl,
                height: 200, // Adjust height
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator())),
                errorWidget: (context, url, error) => const SizedBox(
                    height: 200,
                    child: Center(child: Icon(Icons.pets, size: 60))),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(pet.name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('${pet.species} - ${pet.breed}',
              style: Theme.of(context).textTheme.titleMedium),
          Text('Idade: ${pet.age} anos',
              style: Theme.of(context).textTheme.bodyMedium),
          Text('Gênero: ${pet.gender}',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Text(pet.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: confirmationState.isLoading
                ? null
                : () {
                    // Call confirmation logic
                    ref
                        .read(adoptionConfirmationNotifierProvider.notifier)
                        .confirm(requestId, pet.id);
                  },
            child: confirmationState.isLoading
                ? const CircularProgressIndicator()
                : const Text('Aceitar Solicitação'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: rejectionState.isLoading
                ? null
                : () {
                    // Call rejection logic
                    debugPrint('Rejecting request $requestId');
                    ref
                        .read(adoptionRejectionNotifierProvider.notifier)
                        .reject(requestId);
                  },
            child: rejectionState.isLoading
                ? const CircularProgressIndicator()
                : const Text('Recusar Solicitação'),
          ),
        ],
      ),
    );
  }
}
