import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/providers/active_request_provider.dart';
import 'package:petverse/core/providers/app_state_provider.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';
import 'package:petverse/feature/home/presentation/widgets/active_request_card.dart';
import 'package:petverse/feature/home/presentation/widgets/adoption_options_widget.dart';
import 'package:petverse/feature/home/presentation/widgets/loading_error_screens.dart';
import 'package:petverse/feature/pet/presentation/widgets/pet_status_card.dart';

class PetsTabPageContent extends ConsumerStatefulWidget {
  final AnimationController floatController;

  const PetsTabPageContent({super.key, required this.floatController});

  @override
  ConsumerState<PetsTabPageContent> createState() => _PetsTabPageContentState();
}

class _PetsTabPageContentState extends ConsumerState<PetsTabPageContent> {
  @override
  Widget build(BuildContext context) {
    final hasActivePet = ref.watch(hasActivePetProvider);
    final activePetId = ref.watch(activePetIdProvider);
    final authState = ref.watch(authenticationNotifierProvider);
    final user = authState.userModel;

    final activeRequestAsync = ref.watch(watchUserActiveRequestProvider);

    return activeRequestAsync.when(
      data: (activeRequest) {
        if (activeRequest != null) {
          return ActiveRequestCard(activeRequest: activeRequest);
        }
        if (hasActivePet && activePetId != null) {
          return PetStatusCard(
              petId: activePetId, floatController: widget.floatController);
        }
        if (user != null) {
          return AdoptionOptionsWidget(user: user);
        }
        return const LoadingScreen();
      },
      loading: () => const LoadingScreen(),
      error: (_, __) {
        // Fallback para interface normal em caso de erro no request
        if (hasActivePet && activePetId != null) {
          return PetStatusCard(
              petId: activePetId, floatController: widget.floatController);
        } else if (user != null) {
          return AdoptionOptionsWidget(user: user);
        } else {
          return const LoadingScreen();
        }
      },
    );
  }
}
