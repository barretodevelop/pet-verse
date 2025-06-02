import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(adoption.requesterColorTheme).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.pets,
                  color: Color(adoption.requesterColorTheme),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Pets Disponíveis (${adoption.selectedPetIds.length})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(adoption.requesterColorTheme),
                  ),
                ),
                const Spacer(),
                if (showInteraction)
                  Icon(
                    Icons.touch_app,
                    color: Color(adoption.requesterColorTheme),
                    size: 14,
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
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
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
                  margin: EdgeInsets.only(right: isLast ? 0 : 8),
                  child: _buildPetCard(pet, adoption, index),
                ),
              );
            }).toList(),
          ),

          // Dica de interação
          if (showInteraction) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(adoption.requesterColorTheme).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Toque em um pet para ver detalhes e adotar',
                style: TextStyle(
                  fontSize: 10,
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(adoption.requesterColorTheme).withOpacity(0.3),
            width: 1,
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(adoption.requesterColorTheme).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      pet.photo,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                // Badge de status
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getPetStatusColor(pet),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Nome do pet
            Text(
              pet.name,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            // Tipo e nível de cuidado
            Text(
              '${pet.type} • ${pet.careLevel}',
              style: const TextStyle(
                fontSize: 8,
                color: Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 4),

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
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: _getHealthColor(pet.health),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: _getHealthColor(pet.health).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: pet.health / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getHealthColor(pet.health),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 2),

        // Barra de felicidade
        Row(
          children: [
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: _getHappinessColor(pet.happiness),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: _getHappinessColor(pet.happiness).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(1),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: pet.happiness / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getHappinessColor(pet.happiness),
                      borderRadius: BorderRadius.circular(1),
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
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(adoption.requesterColorTheme),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Carregando pets...',
            style: TextStyle(
              fontSize: 12,
              color: Color(adoption.requesterColorTheme),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(CollaborativeAdoptionRequest adoption) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Color(0xFFEF4444),
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Erro ao carregar pets',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFFEF4444),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(CollaborativeAdoptionRequest adoption) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Text(
        'Nenhum pet encontrado nesta adoção',
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF64748B),
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
