// File: lib/presentation/screens/home/pet/new_pet_screen.dart (MODIFICADO)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/presentation/providers/auth_provider.dart';
import 'package:petverse/presentation/providers/collaboration_slots_provider.dart';
import 'package:petverse/presentation/providers/collaborative_pet_provider.dart';
import 'package:petverse/presentation/providers/pet_provider.dart';
import 'package:petverse/presentation/screens/home/pet/collaborative_adoption_screen.dart';
import 'package:petverse/presentation/screens/home/pet/collaborative_pet_detail_screen.dart';
import 'package:petverse/presentation/screens/home/pet/pet_adoption_screen.dart';
import 'package:petverse/presentation/widgets/animations/floating_animation.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';
import 'package:petverse/presentation/widgets/collaboration/pet_slot_card.dart';

/// Tela principal de pets com sistema de slots para adoção colaborativa
class NewPetScreen extends ConsumerStatefulWidget {
  const NewPetScreen({super.key});

  @override
  ConsumerState<NewPetScreen> createState() => _NewPetScreenState();
}

class _NewPetScreenState extends ConsumerState<NewPetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      final userId = authState.firebaseUser?.uid;
      if (userId != null) {
        ref.read(collaborativePetProvider.notifier).initialize(userId);
        _syncSlotsWithPets();
      }
    });
  }

  void _syncSlotsWithPets() {
    final collaborativeState = ref.read(collaborativePetProvider);
    ref.read(collaborationSlotsProvider.notifier).syncWithUserPets(collaborativeState.userPets);
  }

  @override
  Widget build(BuildContext context) {
    final petGameState = ref.watch(petGameProvider);
    final collaborativeState = ref.watch(collaborativePetProvider);
    final slotsState = ref.watch(collaborationSlotsProvider);
    final authState = ref.read(authProvider);

    // Se não tem pets normais nem colaborativos, mostrar tela de adoção
    if (!petGameState.hasCurrentPet && collaborativeState.userPets.isEmpty) {
      return _buildNoPetsState(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐾 Meus Pets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAdoptionOptions(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (authState.firebaseUser != null) {
            await ref
                .read(collaborativePetProvider.notifier)
                .initialize(authState.firebaseUser!.uid);
            _syncSlotsWithPets();
          }
        },
        child: CustomScrollView(
          slivers: [
            // Pet principal no centro (se existir)
            if (petGameState.hasCurrentPet)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(ThemeConfig.spacing16),
                  child: SlideFadeAnimation(
                    duration: const Duration(milliseconds: 600),
                    child: _buildMainPetCard(context, petGameState.currentPet!),
                  ),
                ),
              ),

            // Header dos slots colaborativos
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(ThemeConfig.spacing16),
                child: SlideFadeAnimation(
                  duration: const Duration(milliseconds: 700),
                  child: _buildCollaborativeSlotsHeader(context, slotsState),
                ),
              ),
            ),

            // Grid de slots colaborativos
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacing16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: ThemeConfig.spacing12,
                  mainAxisSpacing: ThemeConfig.spacing12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final slot = slotsState.slots[index];
                    return SlideFadeAnimation(
                      duration: Duration(milliseconds: 800 + (index * 100)),
                      child: PetSlotCard(
                        slot: slot,
                        onTap: () => _handleSlotTap(context, slot, authState.firebaseUser!.uid),
                      ),
                    );
                  },
                  childCount: slotsState.slots.length,
                ),
              ),
            ),

            // Botão para expandir slots (premium)
            if (slotsState.usedSlots == slotsState.maxSlots)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(ThemeConfig.spacing16),
                  child: SlideFadeAnimation(
                    duration: const Duration(milliseconds: 1000),
                    child: _buildExpandSlotsCard(context),
                  ),
                ),
              ),

            // Espaçamento final
            const SliverToBoxAdapter(
              child: SizedBox(height: ThemeConfig.spacing40),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPetsState(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingAnimation(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: ThemeConfig.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ThemeConfig.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pets,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: ThemeConfig.spacing24),
            Text(
              'Hora de Adotar!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing12),
            Text(
              'Você ainda não tem nenhum pet. Que tal adotar um amiguinho?',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ThemeConfig.spacing32),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PetAdoptionScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.pets),
                    label: const Text('Adoção Individual'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing16),
                    ),
                  ),
                ),
                const SizedBox(height: ThemeConfig.spacing12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CollaborativeAdoptionScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.group),
                    label: const Text('Adoção Colaborativa'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConfig.spacing24),
            Container(
              padding: const EdgeInsets.all(ThemeConfig.spacing16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(height: ThemeConfig.spacing8),
                  Text(
                    'Na adoção colaborativa, você cuida de um pet junto com outro usuário anônimo!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue[800],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainPetCard(BuildContext context, dynamic pet) {
    return Card(
      elevation: 8,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
          gradient: ThemeConfig.primaryGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacing20),
          child: Row(
            children: [
              // Pet image
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: pet.imageUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          pet.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.pets,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.pets,
                        size: 48,
                        color: Colors.white,
                      ),
              ),

              const SizedBox(width: ThemeConfig.spacing20),

              // Pet info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Nível ${pet.level}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: ThemeConfig.spacing12),
                    Row(
                      children: [
                        _buildStatChip('❤️', '${pet.happiness.toInt()}%'),
                        const SizedBox(width: ThemeConfig.spacing8),
                        _buildStatChip('🍖', '${pet.hunger.toInt()}%'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String emoji, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConfig.spacing8,
        vertical: ThemeConfig.spacing4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: ThemeConfig.spacing4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborativeSlotsHeader(BuildContext context, CollaborationSlotsState slotsState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.group,
                  color: ThemeConfig.primaryColor,
                ),
                const SizedBox(width: ThemeConfig.spacing8),
                Expanded(
                  child: Text(
                    'Adoção Colaborativa',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ThemeConfig.spacing8,
                    vertical: ThemeConfig.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeConfig.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                  ),
                  child: Text(
                    '${slotsState.usedSlots}/${slotsState.maxSlots}',
                    style: TextStyle(
                      color: ThemeConfig.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
    );
  }

  Widget _buildExpandSlotsCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => _showPremiumDialog(context),
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacing16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orange],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: ThemeConfig.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expandir Slots',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      'Tenha mais pets colaborativos com o plano premium',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSlotTap(BuildContext context, CollaborationSlot slot, String userId) {
    if (slot.isOccupied && slot.petId != null) {
      // Navegar para detalhes do pet colaborativo
      final collaborativeState = ref.read(collaborativePetProvider);
      final pet = collaborativeState.userPets.firstWhere(
        (p) => p.id == slot.petId,
        orElse: () => collaborativeState.userPets.first,
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CollaborativePetDetailScreen(pet: pet),
        ),
      );
    } else if (slot.isAvailable) {
      // Navegar para adoção colaborativa
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const CollaborativeAdoptionScreen(),
        ),
      );
    } else {
      // Slot premium bloqueado
      _showPremiumDialog(context);
    }
  }

  void _showAdoptionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ThemeConfig.borderRadius16),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escolha o Tipo de Adoção',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: ThemeConfig.spacing20),
            ListTile(
              leading: const Icon(Icons.pets, color: Colors.blue),
              title: const Text('Adoção Individual'),
              subtitle: const Text('Cuide do seu pet sozinho'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PetAdoptionScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Colors.purple),
              title: const Text('Adoção Colaborativa'),
              subtitle: const Text('Cuide junto com outro usuário anônimo'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CollaborativeAdoptionScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💎 Premium'),
        content: const Text(
          'Para ter mais slots de colaboração, faça upgrade para o plano premium!\n\n'
          '• Slots ilimitados\n'
          '• Match prioritário\n'
          '• Pets especiais\n'
          '• Sem anúncios',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Depois'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implementar upgrade premium
            },
            child: const Text('Fazer Upgrade'),
          ),
        ],
      ),
    );
  }
}



// // analise o codigo e ajuste minha regra de navegacao no APP

// // login sucesso -->  Home --> abre com a tela de PET como primeira pagina 


// ┌─────────────────────────┐
// │ 🐾 Meus Pets           │
// ├─────────────────────────┤
// │ ┌─ Pet Principal ─┐    │
// │ │ 🐕 Rex (Lv.5)   │    │
// │ │ ❤️85% 🍖70%     │    │
// │ └─────────────────┘    │
// │                         │
// │ 🤝 Adoção Colaborativa │
// │ Slots: ●●○ (2/3)       │
// │ ┌───┐ ┌───┐ ┌───┐     │
// │ │🐱 │ │🐰 │ │ + │     │
// │ │Max│ │Lua│ │   │     │
// │ └───┘ └───┘ └───┘     │




// card com Slot de pets  

