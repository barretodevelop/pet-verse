// File: lib/presentation/screens/home/pet/collaborative_adoption_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/enums/collaboration/collaboration_enums.dart';
import 'package:petverse/core/widgets/error_widgets.dart';
import 'package:petverse/core/widgets/loading_widgets.dart';
import 'package:petverse/presentation/providers/auth_provider.dart';
import 'package:petverse/presentation/providers/collaborative_pet_provider.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';
import 'package:petverse/presentation/widgets/collaboration/collaboration_stats_widget.dart';
import 'package:petverse/presentation/widgets/collaboration/collaborative_pet_card.dart';

class CollaborativeAdoptionScreen extends ConsumerStatefulWidget {
  const CollaborativeAdoptionScreen({super.key});

  @override
  ConsumerState<CollaborativeAdoptionScreen> createState() => _CollaborativeAdoptionScreenState();
}

class _CollaborativeAdoptionScreenState extends ConsumerState<CollaborativeAdoptionScreen> {
  CollaborationDifficulty? _selectedDifficulty;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      final userId = authState.firebaseUser?.uid;
      if (userId != null) {
        ref.read(collaborativePetProvider.notifier).initialize(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final collaborativeState = ref.watch(collaborativePetProvider);
    final authState = ref.read(authProvider);

    if (authState.firebaseUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Faça login para acessar a adoção colaborativa'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🤝 Adoção Colaborativa'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(collaborativePetProvider.notifier).loadAvailableCollaborativePets(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(collaborativePetProvider.notifier).initialize(authState.firebaseUser!.uid);
        },
        child: CustomScrollView(
          slivers: [
            // Header com estatísticas
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(ThemeConfig.spacing16),
                child: SlideFadeAnimation(
                  duration: const Duration(milliseconds: 600),
                  child: _buildHeader(context, collaborativeState),
                ),
              ),
            ),

            // Filtros
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacing16),
                child: SlideFadeAnimation(
                  duration: const Duration(milliseconds: 700),
                  child: _buildFilters(context),
                ),
              ),
            ),

            // Lista de pets
            if (collaborativeState.isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(ThemeConfig.spacing40),
                    child: AppLoadingIndicator(),
                  ),
                ),
              )
            else if (collaborativeState.hasError)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(ThemeConfig.spacing16),
                  child: AppErrorWidget(
                    message: collaborativeState.errorMessage!,
                    onRetry: () => ref
                        .read(collaborativePetProvider.notifier)
                        .loadAvailableCollaborativePets(),
                  ),
                ),
              )
            else
              _buildPetsList(context, collaborativeState, authState.firebaseUser!.uid),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CollaborativePetState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seus Slots de Colaboração',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: ThemeConfig.spacing8),
                      Text(
                        'Cuide de pets junto com outros usuários anônimos',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConfig.spacing12,
                    vertical: ThemeConfig.spacing8,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeConfig.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                  ),
                  child: Text(
                    '${state.availableSlots}/${state.maxSlots}',
                    style: TextStyle(
                      color: ThemeConfig.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: ThemeConfig.fontSize16,
                    ),
                  ),
                ),
              ],
            ),
            if (state.userCollaborationData != null) ...[
              const SizedBox(height: ThemeConfig.spacing16),
              CollaborationStatsWidget(data: state.userCollaborationData!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing12),

            // Busca
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar pets...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: ThemeConfig.spacing12,
                  vertical: ThemeConfig.spacing8,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),

            const SizedBox(height: ThemeConfig.spacing12),

            // Filtro de dificuldade
            Wrap(
              spacing: ThemeConfig.spacing8,
              children: [
                FilterChip(
                  label: const Text('Todos'),
                  selected: _selectedDifficulty == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedDifficulty = null;
                    });
                  },
                ),
                ...CollaborationDifficulty.values.map(
                  (difficulty) => FilterChip(
                    label: Text(difficulty.displayName),
                    selected: _selectedDifficulty == difficulty,
                    onSelected: (selected) {
                      setState(() {
                        _selectedDifficulty = selected ? difficulty : null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetsList(BuildContext context, CollaborativePetState state, String userId) {
    final filteredPets = state.availablePets.where((pet) {
      // Filtro por busca
      if (_searchQuery.isNotEmpty && !pet.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // Filtro por dificuldade
      if (_selectedDifficulty != null && pet.difficulty != _selectedDifficulty) {
        return false;
      }

      return true;
    }).toList();

    if (filteredPets.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacing40),
          child: Column(
            children: [
              Icon(
                Icons.pets_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: ThemeConfig.spacing16),
              Text(
                'Nenhum pet encontrado',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: ThemeConfig.spacing8),
              Text(
                'Tente ajustar os filtros ou volte mais tarde',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(ThemeConfig.spacing16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: ThemeConfig.spacing12,
          mainAxisSpacing: ThemeConfig.spacing12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final pet = filteredPets[index];
            return SlideFadeAnimation(
              duration: Duration(milliseconds: 800 + (index * 100)),
              child: CollaborativePetCard(
                pet: pet,
                onAdopt: state.hasAvailableSlots ? () => _adoptPet(context, pet.id, userId) : null,
              ),
            );
          },
          childCount: filteredPets.length,
        ),
      ),
    );
  }

  Future<void> _adoptPet(BuildContext context, String petId, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🤝 Adoção Colaborativa'),
        content: const Text(
          'Você será pareado com outro usuário anônimo para cuidar deste pet juntos. '
          'Vocês poderão se conhecer quando o pet atingir o nível necessário para reveal.\n\n'
          'Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Adotar Junto'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(collaborativePetProvider.notifier).requestCollaborativeAdoption(userId, petId);

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
  }
}
