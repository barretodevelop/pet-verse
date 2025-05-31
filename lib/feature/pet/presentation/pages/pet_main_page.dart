// lib/features/pet/presentation/pages/pet_main_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:petverse/core/constants/app_constants.dart';
import 'package:petverse/core/model/pet_model.dart';
import 'package:petverse/core/providers/pet_provider.dart';
import 'package:petverse/core/providers/user_provider.dart';
import 'package:petverse/core/theme/app_theme.dart';

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
                width: 200.w,
                height: 200.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.r),
                  image: DecorationImage(
                    image: NetworkImage(pet!.imageUrl),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primarySoft.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.elasticOut)
                  .fadeIn(),

              SizedBox(height: 32.h),

              // Pet name
              Text(
                'Olá, ${pet.name}! 🐾',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.primarySoft,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideY(begin: 0.3, end: 0),

              SizedBox(height: 16.h),

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
            size: 80.sp,
            color: AppTheme.textLight,
          ),
          SizedBox(height: 24.h),
          Text(
            'Nenhum pet encontrado',
            style: AppTheme.headingMedium,
          ),
          SizedBox(height: 8.h),
          Text(
            'Você ainda não possui um pet.',
            style: AppTheme.bodyMedium,
          ),
          SizedBox(height: 32.h),
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
            width: 80.w,
            height: 80.w,
            child: Lottie.asset(
              AppConstants.loadingAnimation,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 16.h),
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
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: AppTheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Erro ao carregar pet',
            style: AppTheme.headingSmall,
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: AppTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Voltar ao Início'),
          ),
        ],
      ),
    );
  }
}
