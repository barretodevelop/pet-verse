import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/model/pet_model.dart';
import 'package:petverse/core/providers/pet_provider.dart';
import 'package:petverse/core/theme/app_theme.dart';
import 'package:petverse/core/utils/app_utils.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';
import 'package:petverse/feature/home/presentation/widgets/loading_error_screens.dart';

class PetStatusCard extends ConsumerWidget {
  final String petId;
  final AnimationController floatController; // Manter a animação

  const PetStatusCard({
    super.key,
    required this.petId,
    required this.floatController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petAsync = ref.watch(petByIdProvider(petId));

    return petAsync.when(
      data: (pet) => pet != null
          ? _PetDetailsCard(pet: pet, floatController: floatController)
          : const _NoPetFoundCard(),
      loading: () => const LoadingScreen(),
      error: (_, __) => ErrorScreen(
        message: 'Erro ao carregar detalhes do pet.',
        onRetry: () => ref.invalidate(petByIdProvider(petId)),
      ),
    );
  }
}

class _PetDetailsCard extends StatelessWidget {
  final PetModel pet;
  final AnimationController floatController;

  const _PetDetailsCard({
    required this.pet,
    required this.floatController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: floatController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, floatController.value * 8),
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      pet.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.pets,
                            size: 60.sp,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
          Text(
            pet.name,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppTheme.accentCoral.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '${pet.breed} • ${pet.type}',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.accentCoral,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Column(
            children: [
              _PetStatBar(
                  'Felicidade', pet.happiness, AppTheme.accentCoral, '❤️'),
              SizedBox(height: 12.h),
              _PetStatBar('Saúde', pet.health, AppTheme.success, '🏥'),
              SizedBox(height: 12.h),
              _PetStatBar('Energia', pet.energy, AppTheme.warning, '⚡'),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _PetActionButton(
                  label: 'Alimentar',
                  icon: Icons.restaurant,
                  color: AppTheme.accentCoral,
                  onTap: () => AppUtils.mediumImpact(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _PetActionButton(
                  label: 'Brincar',
                  icon: Icons.sports_tennis,
                  color: AppTheme.primary,
                  onTap: () => AppUtils.mediumImpact(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _PetActionButton(
                  label: 'Cuidar',
                  icon: Icons.medical_services,
                  color: AppTheme.success,
                  onTap: () => AppUtils.mediumImpact(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PetStatBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final String emoji;

  const _PetStatBar(this.label, this.value, this.color, this.emoji);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 16.sp),
        ),
        SizedBox(width: 8.w),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Container(
            height: 8.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value / 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '$value%',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PetActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PetActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoPetFoundCard extends StatelessWidget {
  const _NoPetFoundCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: const [
            BoxShadow(
              color: AppTheme.primary,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pets,
              size: 80.sp,
              color: AppTheme.textLight,
            ),
            SizedBox(height: 16.h),
            Text(
              'Pet não encontrado',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Não foi possível carregar\nas informações do seu pet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 20.h),
            Consumer(
              // Using Consumer here to access ref
              builder: (context, ref, child) {
                return ElevatedButton(
                  onPressed: () {
                    AppUtils.lightImpact();
                    ref
                        .read(authenticationNotifierProvider.notifier)
                        .refreshUserModel();
                  },
                  child: const Text('Tentar Novamente'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
