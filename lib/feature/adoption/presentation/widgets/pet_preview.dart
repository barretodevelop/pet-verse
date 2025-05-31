import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/model/firebase_pet_model.dart';
import 'package:petverse/core/providers/firebase_adoption_provider.dart';

class PetPreviewWidget extends ConsumerWidget {
  final CollaborativeAdoptionRequest adoption;
  final bool showInteraction;

  const PetPreviewWidget({
    super.key,
    required this.adoption,
    this.showInteraction = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsFromRequestProvider(adoption.id));

    return Container(
      decoration: BoxDecoration(
        color: Color(adoption.requesterColorTheme).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Color(adoption.requesterColorTheme).withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                Icon(
                  Icons.pets,
                  color: Color(adoption.requesterColorTheme),
                  size: 16.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Pets Disponíveis (${adoption.selectedPetIds.length})',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(adoption.requesterColorTheme),
                  ),
                ),
                const Spacer(),
                if (showInteraction)
                  Icon(
                    Icons.touch_app,
                    color: Color(adoption.requesterColorTheme),
                    size: 14.sp,
                  ),
              ],
            ),
          ),

          // Pets Content
          petsAsync.when(
            data: (pets) => _buildPetsContent(pets, adoption),
            loading: () => _buildLoadingState(adoption),
            error: (error, _) => _buildErrorState(adoption),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsContent(
      List<FirebasePetModel> pets, CollaborativeAdoptionRequest adoption) {
    if (pets.isEmpty) {
      return _buildEmptyState(adoption);
    }

    return Padding(
      padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.w),
      child: Column(
        children: [
          // Grid dos pets
          Row(
            children: pets.asMap().entries.map((entry) {
              final index = entry.key;
              final pet = entry.value;
              final isLast = index == pets.length - 1;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: isLast ? 0 : 8.w),
                  child: _buildPetCard(pet, adoption, index),
                ),
              );
            }).toList(),
          ),

          // Dica de interação
          if (showInteraction) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Color(adoption.requesterColorTheme).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Toque em um pet para ver detalhes e adotar',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontStyle: FontStyle.italic,
                  color: Color(adoption.requesterColorTheme),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPetCard(
      FirebasePetModel pet, CollaborativeAdoptionRequest adoption, int index) {
    return GestureDetector(
      onTap: showInteraction ? () => _handlePetTap(pet, adoption) : null,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: Color(adoption.requesterColorTheme).withOpacity(0.3),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(adoption.requesterColorTheme).withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Foto do pet
            Stack(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: Color(adoption.requesterColorTheme).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      pet.photo,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ),

                // Badge de status
                Positioned(
                  top: -2.h,
                  right: -2.w,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: _getPetStatusColor(pet),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.w),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Nome do pet
            Text(
              pet.name,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            // Tipo e nível de cuidado
            Text(
              '${pet.type} • ${pet.careLevel}',
              style: TextStyle(
                fontSize: 8.sp,
                color: const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Barras de status
            _buildStatusBars(pet),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));
  }

  Widget _buildStatusBars(FirebasePetModel pet) {
    return Column(
      children: [
        // Barra de saúde
        Row(
          children: [
            Container(
              width: 4.w,
              height: 4.w,
              decoration: BoxDecoration(
                color: _getHealthColor(pet.health),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Container(
                height: 2.h,
                decoration: BoxDecoration(
                  color: _getHealthColor(pet.health).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: pet.health / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getHealthColor(pet.health),
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Barra de felicidade
        Row(
          children: [
            Container(
              width: 4.w,
              height: 4.w,
              decoration: BoxDecoration(
                color: _getHappinessColor(pet.happiness),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Container(
                height: 2.h,
                decoration: BoxDecoration(
                  color: _getHappinessColor(pet.happiness).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: pet.happiness / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getHappinessColor(pet.happiness),
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState(CollaborativeAdoptionRequest adoption) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              color: Color(adoption.requesterColorTheme),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Carregando pets...',
            style: TextStyle(
              fontSize: 12.sp,
              color: Color(adoption.requesterColorTheme),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(CollaborativeAdoptionRequest adoption) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: const Color(0xFFEF4444),
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Erro ao carregar pets',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFFEF4444),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(CollaborativeAdoptionRequest adoption) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Text(
        'Nenhum pet encontrado nesta adoção',
        style: TextStyle(
          fontSize: 12.sp,
          color: const Color(0xFF64748B),
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _handlePetTap(
      FirebasePetModel pet, CollaborativeAdoptionRequest adoption) {
    HapticFeedback.lightImpact();
    // Implementar navegação para detalhes do pet ou modal de adoção
    print('Pet selecionado: ${pet.name}');
  }

  Color _getPetStatusColor(FirebasePetModel pet) {
    if (!pet.isHealthy) return const Color(0xFFEF4444); // Vermelho
    if (pet.energy < 50) return const Color(0xFFF59E0B); // Amarelo
    return const Color(0xFF10B981); // Verde
  }

  Color _getHealthColor(int health) {
    if (health >= 80) return const Color(0xFF10B981);
    if (health >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _getHappinessColor(int happiness) {
    if (happiness >= 80) return const Color(0xFF3B82F6);
    if (happiness >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
