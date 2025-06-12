// File: lib/presentation/screens/home/pet/collaborative_pet_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/domain/entities/collaboration/collaborative_pet_entity.dart';
import 'package:petverse/presentation/providers/auth_provider.dart';
import 'package:petverse/presentation/providers/collaborative_pet_provider.dart';
import 'package:petverse/presentation/widgets/animations/bounce_animation.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';
import 'package:petverse/presentation/widgets/collaboration/real_time_action_widget.dart';
import 'package:petverse/presentation/widgets/collaboration/reveal_dialog_widget.dart';

class CollaborativePetDetailScreen extends ConsumerStatefulWidget {
  final CollaborativePetEntity pet;

  const CollaborativePetDetailScreen({
    super.key,
    required this.pet,
  });

  @override
  ConsumerState<CollaborativePetDetailScreen> createState() => _CollaborativePetDetailScreenState();
}

class _CollaborativePetDetailScreenState extends ConsumerState<CollaborativePetDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(collaborativePetProvider.notifier).selectPet(widget.pet.id);
      ref.read(collaborativePetProvider.notifier).watchPetUpdates(widget.pet.id);
      ref.read(collaborativePetProvider.notifier).watchPetActions(widget.pet.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final collaborativeState = ref.watch(collaborativePetProvider);
    final authState = ref.read(authProvider);
    final selectedPet = collaborativeState.selectedPet ?? widget.pet;

    return Scaffold(
      appBar: AppBar(
        title: Text('${selectedPet.name} ${selectedPet.status.emoji}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (selectedPet.canReveal)
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.amber),
              onPressed: () => _showRevealDialog(context, selectedPet, authState.firebaseUser!.uid),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          children: [
            // Pet Image e Status
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 600),
              child: _buildPetHeader(context, selectedPet),
            ),

            const SizedBox(height: ThemeConfig.spacing20),

            // Stats do Pet
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 700),
              child: _buildPetStats(context, selectedPet),
            ),

            const SizedBox(height: ThemeConfig.spacing20),

            // Collaboration Info
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 800),
              child: _buildCollaborationInfo(context, selectedPet, authState.firebaseUser!.uid),
            ),

            const SizedBox(height: ThemeConfig.spacing20),

            // Ações
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 900),
              child: _buildActionButtons(context, selectedPet, authState.firebaseUser!.uid),
            ),

            const SizedBox(height: ThemeConfig.spacing20),

            // Ações Recentes
            SlideFadeAnimation(
              duration: const Duration(milliseconds: 1000),
              child: _buildRecentActions(context, collaborativeState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetHeader(BuildContext context, CollaborativePetEntity pet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeConfig.primaryColor.withOpacity(0.1),
                border: Border.all(
                  color: ThemeConfig.primaryColor.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: pet.imageUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        pet.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.pets,
                          size: 48,
                          color: ThemeConfig.primaryColor,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.pets,
                      size: 48,
                      color: ThemeConfig.primaryColor,
                    ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            Text(
              pet.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text(pet.status.displayName),
                  backgroundColor: _getStatusColor(pet.status),
                ),
                const SizedBox(width: ThemeConfig.spacing8),
                Chip(
                  label: Text('Nível ${pet.level}'),
                  backgroundColor: ThemeConfig.primaryColor.withOpacity(0.1),
                ),
              ],
            ),
            if (pet.canReveal) ...[
              const SizedBox(height: ThemeConfig.spacing12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ThemeConfig.spacing12,
                  vertical: ThemeConfig.spacing8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.visibility, color: Colors.amber, size: 16),
                    const SizedBox(width: ThemeConfig.spacing4),
                    Text(
                      'Reveal Disponível!',
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPetStats(BuildContext context, CollaborativePetEntity pet) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status do Pet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            _buildStatBar('❤️ Felicidade', pet.happiness, Colors.pink),
            const SizedBox(height: ThemeConfig.spacing12),
            _buildStatBar('🍖 Fome', pet.hunger, Colors.orange),
            const SizedBox(height: ThemeConfig.spacing12),
            _buildStatBar('⚡ Energia', pet.energy, Colors.blue),
            const SizedBox(height: ThemeConfig.spacing12),
            _buildStatBar('🏥 Saúde', pet.health, Colors.green),
            const SizedBox(height: ThemeConfig.spacing16),
            // Row(
            //   children: [
            //     Expanded(
            //       child: _buildStatChip('XP', '${pet.experience}'),
            //     ),
            //     const SizedBox(width: ThemeConfig.spacing8),
            //     Expanded(
            //       child: _buildStatChip('Moedas', '${pet.coins}'),
            //     ),
            //     const SizedBox(width: ThemeConfig.spacing8),
            //     Expanded(
            //       child: _buildStatChip('Reveal', '${pet.level}/${pet.difficulty.revealLevel}'),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${value.toInt()}%'),
          ],
        ),
        const SizedBox(height: ThemeConfig.spacing4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ThemeConfig.fontSize16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: ThemeConfig.fontSize12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborationInfo(
      BuildContext context, CollaborativePetEntity pet, String currentUserId) {
    final userContribution = pet.getUserContributionPercentage(currentUserId);
    final partnerUserId = pet.getPartnerUserId(currentUserId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Colaboração',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: ThemeConfig.primaryColor.withOpacity(0.1),
                        child: const Icon(Icons.person),
                      ),
                      const SizedBox(height: ThemeConfig.spacing8),
                      const Text('Você'),
                      Text(
                        '${userContribution.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.favorite, color: Colors.red),
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        child: const Icon(Icons.person_outline),
                      ),
                      const SizedBox(height: ThemeConfig.spacing8),
                      Text(partnerUserId != null ? 'Parceiro' : 'Aguardando'),
                      Text(
                        partnerUserId != null
                            ? '${(100 - userContribution).toStringAsFixed(1)}%'
                            : '0%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            Text(
              'Dificuldade: ${pet.difficulty.displayName}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Adotado em: ${_formatDate(pet.matchedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CollaborativePetEntity pet, String userId) {
    final isPerformingAction = ref.watch(collaborativePetProvider).isPerformingAction;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              children: [
                _buildActionButton(
                  CollaborativeActionType.feed,
                  isPerformingAction,
                  () => _performAction(pet.id, userId, CollaborativeActionType.feed),
                ),
                _buildActionButton(
                  CollaborativeActionType.play,
                  isPerformingAction,
                  () => _performAction(pet.id, userId, CollaborativeActionType.play),
                ),
                _buildActionButton(
                  CollaborativeActionType.rest,
                  isPerformingAction,
                  () => _performAction(pet.id, userId, CollaborativeActionType.rest),
                ),
                _buildActionButton(
                  CollaborativeActionType.medicine,
                  isPerformingAction,
                  () => _performAction(pet.id, userId, CollaborativeActionType.medicine),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    CollaborativeActionType actionType,
    bool isLoading,
    VoidCallback onPressed,
  ) {
    return BounceAnimation(
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
        child: Container(
          margin: const EdgeInsets.all(ThemeConfig.spacing4),
          padding: const EdgeInsets.all(ThemeConfig.spacing8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                actionType.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: ThemeConfig.spacing4),
              Text(
                actionType.displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActions(BuildContext context, CollaborativePetState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações Recentes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            if (state.recentActions.isEmpty)
              const Text('Nenhuma ação realizada ainda')
            else
              ...state.recentActions.take(5).map(
                    (action) => RealTimeActionWidget(action: action),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _performAction(
      String petId, String userId, CollaborativeActionType actionType) async {
    await ref
        .read(collaborativePetProvider.notifier)
        .performCollaborativeAction(userId, petId, actionType);

    if (mounted) {
      final state = ref.read(collaborativePetProvider);
      if (state.hasSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(collaborativePetProvider.notifier).clearMessages();
      } else if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(collaborativePetProvider.notifier).clearMessages();
      }
    }
  }

  void _showRevealDialog(BuildContext context, CollaborativePetEntity pet, String userId) {
    showDialog(
      context: context,
      builder: (context) => RevealDialogWidget(
        pet: pet,
        onRevealRequested: () {
          ref.read(collaborativePetProvider.notifier).requestReveal(userId, pet.id);
        },
      ),
    );
  }

  Color _getStatusColor(CollaborationStatus status) {
    switch (status) {
      case CollaborationStatus.waitingForPartner:
        return Colors.orange.withOpacity(0.1);
      case CollaborationStatus.activeCollaboration:
        return Colors.green.withOpacity(0.1);
      case CollaborationStatus.revealAvailable:
        return Colors.amber.withOpacity(0.1);
      case CollaborationStatus.revealed:
        return Colors.blue.withOpacity(0.1);
      case CollaborationStatus.abandoned:
        return Colors.red.withOpacity(0.1);
      case CollaborationStatus.completed:
        return Colors.purple.withOpacity(0.1);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
