// File: lib/presentation/widgets/pet/enhanced_adoption_modal.dart
// Modal de adoção UX Rica com abas Individual vs Colaborativa

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/domain/entities/pet_entity.dart';
import 'package:petverse/presentation/providers/collaborative_pet_provider.dart';
import 'package:petverse/presentation/providers/pet_provider.dart';
import 'package:petverse/presentation/widgets/animations/bounce_animation.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';

class EnhancedAdoptionModal extends ConsumerStatefulWidget {
  const EnhancedAdoptionModal({super.key});

  @override
  ConsumerState<EnhancedAdoptionModal> createState() => _EnhancedAdoptionModalState();
}

class _EnhancedAdoptionModalState extends ConsumerState<EnhancedAdoptionModal>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  int _selectedIndividualPet = -1;
  int _selectedCollaborativePet = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeOut,
    ));

    _backgroundController.forward();

    // Load pets data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petGameProvider.notifier).loadAvailablePets();
      ref.read(collaborativePetProvider.notifier).loadAvailableCollaborativePets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildIndividualTab(),
                        _buildCollaborativeTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return SlideFadeAnimation(
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🏠 Pet Sanctuary',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Escolha como quer adotar seu novo companheiro',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            BounceAnimation(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SlideFadeAnimation(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: ThemeConfig.primaryColor,
            borderRadius: BorderRadius.circular(14),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 20),
                  SizedBox(width: 8),
                  Text('Individual'),
                ],
              ),
            ),
            Tab(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 20),
                  SizedBox(width: 8),
                  Text('Colaborativa'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualTab() {
    final petGameState = ref.watch(petGameProvider);

    return Column(
      children: [
        // Tab description
        SlideFadeAnimation(
          duration: const Duration(milliseconds: 700),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adoção Individual',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cuide do seu pet sozinho. Controle total sobre as decisões.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Pets grid
        Expanded(
          child: _buildPetsGrid(
            pets: petGameState.availablePets,
            isLoading: petGameState.isLoading,
            selectedIndex: _selectedIndividualPet,
            onPetSelected: (index) {
              setState(() {
                _selectedIndividualPet = index;
              });
            },
            onAdopt: (pet) => _adoptIndividualPet(pet),
            isIndividual: true,
          ),
        ),
      ],
    );
  }

  Widget _buildCollaborativeTab() {
    final collaborativeState = ref.watch(collaborativePetProvider);

    return Column(
      children: [
        // Tab description
        SlideFadeAnimation(
          duration: const Duration(milliseconds: 700),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple[200]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people,
                    color: Colors.purple[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adoção Colaborativa',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cuide do pet junto com outro jogador anônimo. Experiência compartilhada!',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Available slots info
        if (!collaborativeState.hasAvailableSlots)
          SlideFadeAnimation(
            duration: const Duration(milliseconds: 750),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Você não tem slots disponíveis. Considere upgrade premium.',
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Pets grid
        Expanded(
          child: _buildPetsGrid(
            pets: collaborativeState.availablePets,
            isLoading: collaborativeState.isLoading,
            selectedIndex: _selectedCollaborativePet,
            onPetSelected: collaborativeState.hasAvailableSlots
                ? (index) {
                    setState(() {
                      _selectedCollaborativePet = index;
                    });
                  }
                : null,
            onAdopt:
                collaborativeState.hasAvailableSlots ? (pet) => _adoptCollaborativePet(pet) : null,
            isIndividual: false,
          ),
        ),
      ],
    );
  }

  Widget _buildPetsGrid({
    required List pets,
    required bool isLoading,
    required int selectedIndex,
    required void Function(int)? onPetSelected,
    required void Function(dynamic)? onAdopt,
    required bool isIndividual,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pets.isEmpty) {
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
              'Nenhum pet disponível',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        final isSelected = selectedIndex == index;

        return SlideFadeAnimation(
          duration: Duration(milliseconds: 800 + (index * 100)),
          child: BounceAnimation(
            onTap: onPetSelected != null
                ? () {
                    onPetSelected(index);
                    if (isSelected && onAdopt != null) {
                      onAdopt(pet);
                    }
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isSelected ? (isIndividual ? Colors.blue : Colors.purple) : Colors.grey[300]!,
                  width: isSelected ? 3 : 1,
                ),
                gradient: isSelected
                    ? LinearGradient(
                        colors: isIndividual
                            ? [Colors.blue[50]!, Colors.blue[100]!]
                            : [Colors.purple[50]!, Colors.purple[100]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: (isIndividual ? Colors.blue : Colors.purple).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pet avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getPetAvatar(pet),
                        style: const TextStyle(fontSize: 30),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Pet name
                  Text(
                    _getPetName(pet),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Pet type/breed
                  Text(
                    _getPetBreed(pet),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Action button
                  if (isSelected && onAdopt != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isIndividual ? Colors.blue : Colors.purple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Adotar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else if (onAdopt == null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Indisponível',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _adoptIndividualPet(dynamic pet) async {
    // TODO: Implementar adoção individual
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Adoção individual em desenvolvimento!'),
      ),
    );
  }

  Future<void> _adoptCollaborativePet(dynamic pet) async {
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text(
              'Adotar Junto',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // TODO: Implementar lógica de adoção colaborativa
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Procurando parceiro para adoção...'),
          backgroundColor: Colors.purple,
        ),
      );
    }
  }

  String _getPetAvatar(dynamic pet) {
    if (pet is PetEntity) {
      return pet.avatar ?? '🐱';
    }
    return pet.avatar ?? '🐱';
  }

  String _getPetName(dynamic pet) {
    if (pet is PetEntity) {
      return pet.name;
    }
    return pet.name ?? 'Pet';
  }

  String _getPetBreed(dynamic pet) {
    if (pet is PetEntity) {
      return pet.breed ?? 'Mixed';
    }
    return pet.breed ?? 'Mixed';
  }
}
