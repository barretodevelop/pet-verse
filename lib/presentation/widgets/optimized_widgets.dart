// lib/presentation/widgets/optimized_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/selector_extensions.dart';
import '../../core/providers/unified_optimized_providers.dart';
import '../../data/models/pet.dart';
import '../providers/optimized_currency_provider.dart';
import '../providers/optimized_pet_provider.dart';

/// Widget de moeda otimizado que só rebuilda quando necessário
class OptimizedCurrencyDisplay extends ConsumerWidget {
  final bool showDetails;
  final Color? textColor;

  const OptimizedCurrencyDisplay({
    super.key,
    this.showDetails = false,
    this.textColor,
    required bool showCoins,
    required bool showGems,
    required bool showXP,
    required bool showLevel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usa selectors específicos para evitar rebuilds desnecessários
    final coins = ref.currentUserCoins;
    final gems = ref.currentUserGems;
    final xp = ref.currentUserXP;

    // Só rebuilda se showDetails for true e houver mudança no nível
    final level = showDetails ? ref.currentUserLevel : 1;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CurrencyItem(
          icon: '💰',
          value: coins.toString(),
          color: const Color(0xFFFFD700),
          textColor: textColor,
        ),
        const SizedBox(width: 12),
        _CurrencyItem(
          icon: '💎',
          value: gems.toString(),
          color: const Color(0xFF40E0D0),
          textColor: textColor,
        ),
        if (showDetails) ...[
          const SizedBox(width: 12),
          _CurrencyItem(
            icon: '⭐',
            value: 'LV$level',
            color: const Color(0xFF32CD32),
            textColor: textColor,
          ),
        ],
      ],
    );
  }
}

/// Item individual de moeda (widget puro para performance)
class _CurrencyItem extends StatelessWidget {
  final String icon;
  final String value;
  final Color color;
  final Color? textColor;

  const _CurrencyItem({
    required this.icon,
    required this.value,
    required this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: textColor ?? color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de pet otimizado
class OptimizedPetCard extends ConsumerWidget {
  final String petId;
  final VoidCallback? onTap;
  final bool showActions;

  const OptimizedPetCard({
    super.key,
    required this.petId,
    this.onTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usa selector específico para obter apenas informações básicas
    final petInfo = ref.getPetBasicInfo(petId);

    if (petInfo == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com informações básicas
              _PetCardHeader(petInfo: petInfo),

              if (showActions) ...[
                const SizedBox(height: 12),
                // Stats e ações (só carrega quando necessário)
                _PetCardActions(petId: petId),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Header do card do pet (widget puro)
class _PetCardHeader extends StatelessWidget {
  final PetBasicInfo petInfo;

  const _PetCardHeader({required this.petInfo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar placeholder
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getTypeColor(petInfo.type),
          ),
          child: const Icon(
            Icons.pets,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),

        // Info do pet
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                petInfo.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                petInfo.type,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Status de adoção
        if (petInfo.isAdopted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Adotado',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'dog':
      case 'cachorro':
        return Colors.brown;
      case 'cat':
      case 'gato':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

/// Ações do pet (só carrega stats quando necessário)
class _PetCardActions extends ConsumerWidget {
  final String petId;

  const _PetCardActions({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usa selector específico para stats
    final stats = ref.getPetStats(petId);

    if (stats == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Barras de status
        _StatusBar(label: 'Fome', value: stats.hunger, color: Colors.orange),
        const SizedBox(height: 4),
        _StatusBar(
            label: 'Felicidade', value: stats.happiness, color: Colors.pink),
        const SizedBox(height: 4),
        _StatusBar(label: 'Energia', value: stats.energy, color: Colors.blue),

        const SizedBox(height: 12),

        // Botões de ação
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.restaurant,
                label: 'Alimentar',
                cost: '10💰',
                onPressed: () => ref.feedPet(petId),
                enabled: ref.canAfford(coins: 10),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                icon: Icons.sports_esports,
                label: 'Brincar',
                cost: '5💰',
                onPressed: () => ref.playWithPet(petId),
                enabled: ref.canAfford(coins: 5) && stats.energy > 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Barra de status do pet
class _StatusBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatusBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = value / 100.0;

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: _getStatusColor(percentage, color),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            '$value',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(double percentage, Color baseColor) {
    if (percentage > 0.7) return baseColor;
    if (percentage > 0.3) return Colors.orange;
    return Colors.red;
  }
}

/// Botão de ação otimizado
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String cost;
  final VoidCallback? onPressed;
  final bool enabled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.cost,
    this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
          Text(
            cost,
            style: TextStyle(
              fontSize: 8,
              color: enabled ? null : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista otimizada de pets
class OptimizedPetsList extends ConsumerWidget {
  final bool showOnlyAvailable;
  final String? filterType;

  const OptimizedPetsList({
    super.key,
    this.showOnlyAvailable = false,
    this.filterType,
    required int maxItems,
    required void Function(dynamic pet) onPetTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usa selector otimizado baseado nos filtros
    List<Pet> pets;

    if (showOnlyAvailable) {
      pets = ref.availablePets;
    } else {
      pets = ref.watch(optimizedPetsProvider.select((state) => state.pets));
    }

    // Aplica filtro de tipo se especificado
    if (filterType != null) {
      pets = pets.where((pet) => pet.type == filterType).toList();
    }

    if (pets.isEmpty) {
      return const _EmptyPetsWidget();
    }

    return ListView.builder(
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        return OptimizedPetCard(
          petId: pet.id,
          onTap: () => _showPetDetails(context, pet.id),
        );
      },
    );
  }

  void _showPetDetails(BuildContext context, String petId) {
    showDialog(
      context: context,
      builder: (context) => _PetDetailsDialog(petId: petId),
    );
  }
}

/// Widget de lista vazia
class _EmptyPetsWidget extends StatelessWidget {
  const _EmptyPetsWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum pet encontrado',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Que tal adotar um pet?',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog de detalhes do pet otimizado
class _PetDetailsDialog extends ConsumerWidget {
  final String petId;

  const _PetDetailsDialog({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.getPetById(petId);

    if (pet == null) {
      return AlertDialog(
        title: const Text('Erro'),
        content: const Text('Pet não encontrado'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cabeçalho
            Row(
              children: [
                Expanded(
                  child: Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Imagem do pet
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: const Icon(
                Icons.pets,
                size: 60,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            // Informações
            _DetailRow(label: 'Tipo', value: pet.type),
            _DetailRow(label: 'Nível', value: pet.level.toString()),
            _DetailRow(label: 'XP', value: '${pet.xp}/${pet.xpToNextLevel}'),

            const SizedBox(height: 16),

            // Descrição
            Text(
              pet.description,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Ações do dialog
            if (!pet.isAdopted) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.adoptPet(petId);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Adotar Pet'),
                ),
              ),
            ] else ...[
              Text(
                'Este pet já foi adotado!',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Row de detalhes
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
}

/// Widget de estatísticas globais otimizado
class OptimizedGlobalStatsWidget extends ConsumerWidget {
  const OptimizedGlobalStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.globalStats;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas Globais',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _StatItem(
              icon: Icons.pets,
              label: 'Total de Pets',
              value: stats.totalPets.toString(),
              color: Colors.blue,
            ),
            _StatItem(
              icon: Icons.favorite,
              label: 'Pets Disponíveis',
              value: stats.availablePets.toString(),
              color: Colors.green,
            ),
            _StatItem(
              icon: Icons.warning,
              label: 'Pets Críticos',
              value: stats.criticalPets.toString(),
              color: Colors.red,
            ),
            _StatItem(
              icon: Icons.speed,
              label: 'Taxa de Cache',
              value: '${(stats.cacheHitRate * 100).toStringAsFixed(1)}%',
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            if (stats.hasLocalChanges)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sync, color: Colors.orange[700], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Sincronizando mudanças...',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Item de estatística
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading indicator otimizado que só aparece quando necessário
class OptimizedLoadingIndicator extends ConsumerWidget {
  const OptimizedLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.isAppLoading;

    if (!isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Carregando...'),
        ],
      ),
    );
  }
}
