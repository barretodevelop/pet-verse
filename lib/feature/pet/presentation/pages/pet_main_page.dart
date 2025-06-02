// lib/features/pet/presentation/pages/pet_main_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:petverse/core/constants/app_constants.dart';
import 'package:petverse/core/model/pet_model.dart';
import 'package:petverse/core/providers/pet_provider.dart';
import 'package:petverse/core/providers/user_provider.dart';
import 'package:petverse/core/theme/bck-app_theme.dart';

class PetMainPage extends ConsumerWidget {
  const PetMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: userAsync.when(
            data: (user) {
              if (user?.currentPetId == null) {
                return _buildNoPetState(context);
              }

              return _buildPetMainContent(context, ref, user!.currentPetId!);
            },
            loading: () => _buildLoadingState(),
            error: (error, stack) =>
                _buildErrorState(context, error.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildPetMainContent(
      BuildContext context, WidgetRef ref, String petId) {
    final petAsync = ref.watch(petByIdProvider(petId));

    return petAsync.when(
      data: (PetModel? pet) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pet image
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  image: DecorationImage(
                    image: NetworkImage(pet!.imageUrl),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.elasticOut)
                  .fadeIn(),

              const SizedBox(height: 32),

              // Pet name
              Text(
                'Olá, ${pet.name}! 🐾',
                style: AppTheme.headlineLarge.copyWith(
                  color: AppTheme.primary,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 16),

              Text(
                'Seu pet está aqui! Esta seria a tela principal\nonde você cuidaria dele.',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 600.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ),
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(context, error.toString()),
    );
  }

  Widget _buildNoPetState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 80,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum pet encontrado',
            style: AppTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Você ainda não possui um pet.',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          // ElevatedButton(
          //   onPressed: () => context.go('/need-adoption'),
          //   child: const Text('Adotar um Pet'),
          // ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Lottie.asset(
              AppConstants.loadingAnimation,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Carregando seu pet...',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar pet',
            style: AppTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Voltar ao Início'),
          ),
        ],
      ),
    );
  }
}
