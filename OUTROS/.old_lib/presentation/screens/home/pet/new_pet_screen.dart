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

/// Tela principal de pets otimizada - Layout compacto com menos scroll
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          if (authState.firebaseUser != null) {
            await ref
                .read(collaborativePetProvider.notifier)
                .initialize(authState.firebaseUser!.uid);
            _syncSlotsWithPets();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // 1. SLOTS COLABORATIVOS NO TOPO - Mais compactos
              SlideFadeAnimation(
                duration: const Duration(milliseconds: 500),
                child:
                    _buildOptimizedSlotsSection(context, slotsState, authState.firebaseUser!.uid),
              ),

              const SizedBox(height: 12),

              // 2. PET PRINCIPAL NO CENTRO - Ícone maior, padding menor
              if (petGameState.hasCurrentPet)
                SlideFadeAnimation(
                  duration: const Duration(milliseconds: 600),
                  child: _buildOptimizedMainPet(context, petGameState.currentPet!),
                ),

              const SizedBox(height: 12),

              // 3. STATUS E AÇÕES COMBINADOS - Layout horizontal
              if (petGameState.hasCurrentPet)
                SlideFadeAnimation(
                  duration: const Duration(milliseconds: 700),
                  child: _buildCombinedStatusActions(context, petGameState.currentPet!, ref),
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizedSlotsSection(
      BuildContext context, CollaborationSlotsState slotsState, String userId) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header compacto
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: ThemeConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.group,
                  color: ThemeConfig.primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Adoção Colaborativa',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ThemeConfig.primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${slotsState.slots}/${slotsState.maxSlots}',
                  style: TextStyle(
                    color: ThemeConfig.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Slots mais compactos
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: slotsState.slots.length,
              itemBuilder: (context, index) {
                final slot = slotsState.slots[index];
                return Padding(
                  padding: EdgeInsets.only(right: index < slotsState.slots.length - 1 ? 8 : 0),
                  child: _buildOptimizedSlotCard(slot, userId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizedSlotCard(CollaborationSlot slot, String userId) {
    return GestureDetector(
      onTap: () => _handleSlotTap(context, slot, userId),
      child: Container(
        width: 90,
        height: 70,
        decoration: BoxDecoration(
          gradient: slot.isOccupied
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ThemeConfig.primaryColor.withOpacity(0.8),
                    ThemeConfig.primaryColor.withOpacity(0.6),
                  ],
                )
              : slot.isAvailable
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).disabledColor.withOpacity(0.2),
                        Theme.of(context).disabledColor.withOpacity(0.1),
                      ],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.amber.withOpacity(0.3),
                        Colors.orange.withOpacity(0.2),
                      ],
                    ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: slot.isOccupied
                ? Colors.white.withOpacity(0.3)
                : slot.isAvailable
                    ? Theme.of(context).disabledColor.withOpacity(0.3)
                    : Colors.amber.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (slot.isOccupied) ...[
              Text(
                '🐱',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 2),
              Text(
                'Pet ${slot.index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ] else if (slot.isAvailable) ...[
              Icon(
                Icons.add,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                'Adotar',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              const Icon(
                Icons.lock,
                color: Colors.amber,
                size: 18,
              ),
              const SizedBox(height: 2),
              const Text(
                'Premium',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizedMainPet(BuildContext context, dynamic pet) {
    return Container(
      padding: const EdgeInsets.all(24), // Reduzido de 80 para 24
      decoration: BoxDecoration(
        gradient: ThemeConfig.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pet Avatar - Tamanho oficial para jogos (120px)
          FloatingAnimation(
            child: Container(
              width: 120, // Aumentado para tamanho oficial
              height: 120,
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
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.pets,
                      size: 60, // Ícone grande oficial
                      color: Colors.white,
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // Pet Info - Tipografia otimizada
          Text(
            pet.name,
            style: const TextStyle(
              fontSize: 20, // Reduzido de 22 para 20
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Nível ${pet.level} • ${pet.type}',
            style: const TextStyle(
              fontSize: 14, // Melhorado de 14 (legível)
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedStatusActions(BuildContext context, dynamic pet, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status & Cuidados',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
          ),
          const SizedBox(height: 12),

          // Layout horizontal: Status à esquerda, Ações à direita
          Row(
            children: [
              // Status Bars - Lado esquerdo (compacto)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildCompactStatusRow(
                        '❤️', 'Felicidade', pet.happiness.toInt(), const Color(0xFFFF6B6B)),
                    const SizedBox(height: 8),
                    _buildCompactStatusRow(
                        '🍖', 'Fome', pet.hunger.toInt(), const Color(0xFF4ECDC4)),
                    const SizedBox(height: 8),
                    _buildCompactStatusRow(
                        '⚡', 'Energia', pet.energy.toInt(), const Color(0xFF45B7D1)),
                    const SizedBox(height: 8),
                    _buildCompactStatusRow(
                        '💊', 'Saúde', pet.health.toInt(), const Color(0xFF96CEB4)),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Action Buttons - Lado direito (2x2 grid)
              Expanded(
                flex: 2,
                child: _buildActionGrid(context, pet, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatusRow(String emoji, String label, int value, Color color) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$value%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  widthFactor: value / 100,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionGrid(BuildContext context, dynamic pet, WidgetRef ref) {
    final actions = [
      {
        'title': 'Alimentar',
        'icon': Icons.restaurant,
        'color': const Color(0xFFFF6B6B),
        'enabled': pet.hunger < 90
      },
      {
        'title': 'Brincar',
        'icon': Icons.sports_esports,
        'color': const Color(0xFF4ECDC4),
        'enabled': pet.energy > 20
      },
      {
        'title': 'Descansar',
        'icon': Icons.bedtime,
        'color': const Color(0xFF45B7D1),
        'enabled': pet.energy < 90
      },
      {
        'title': 'Medicar',
        'icon': Icons.medical_services,
        'color': const Color(0xFF96CEB4),
        'enabled': pet.health < 80
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildOptimizedActionButton(
          action['title'] as String,
          action['icon'] as IconData,
          action['color'] as Color,
          action['enabled'] as bool,
          () => _performAction(action['title'] as String, pet, ref),
        );
      },
    );
  }

  Widget _buildOptimizedActionButton(
      String title, IconData icon, Color color, bool enabled, VoidCallback onTap) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                )
              : LinearGradient(
                  colors: [
                    Theme.of(context).disabledColor.withOpacity(0.1),
                    Theme.of(context).disabledColor.withOpacity(0.05)
                  ],
                ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                enabled ? color.withOpacity(0.3) : Theme.of(context).disabledColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: enabled ? color : Theme.of(context).disabledColor,
              size: 16,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: enabled
                    ? Theme.of(context).textTheme.bodyMedium?.color
                    : Theme.of(context).disabledColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPetsState(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingAnimation(
              child: Container(
                width: 120, // Tamanho oficial também aqui
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
            const SizedBox(height: 24),
            Text(
              'Hora de Adotar!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Você ainda não tem nenhum pet. Que tal adotar um amiguinho?',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const PetAdoptionScreen()),
                    ),
                    icon: const Icon(Icons.pets),
                    label: const Text('Adoção Individual'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const CollaborativeAdoptionScreen()),
                    ),
                    icon: const Icon(Icons.group),
                    label: const Text('Adoção Colaborativa'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(height: 8),
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

  // Métodos auxiliares mantidos
  void _handleSlotTap(BuildContext context, CollaborationSlot slot, String userId) {
    if (slot.isOccupied && slot.petId != null) {
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
      _showAdoptionOptions(context);
    } else {
      _showPremiumDialog(context);
    }
  }

  void _showAdoptionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escolha o Tipo de Adoção',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.pets, color: Colors.blue),
              title: const Text('Adoção Individual'),
              subtitle: const Text('Cuide do seu pet sozinho'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PetAdoptionScreen()),
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
                  MaterialPageRoute(builder: (context) => const CollaborativeAdoptionScreen()),
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

  void _performAction(String action, dynamic pet, WidgetRef ref) {
    // Implementar ações do pet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action realizado com sucesso!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}















// /// Tela principal de pets otimizada - Slots no topo, Pet no centro, Ações embaixo
// class NewPetScreen extends ConsumerStatefulWidget {
//   const NewPetScreen({super.key});

//   @override
//   ConsumerState<NewPetScreen> createState() => _NewPetScreenState();
// }

// class _NewPetScreenState extends ConsumerState<NewPetScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final authState = ref.read(authProvider);
//       final userId = authState.firebaseUser?.uid;
//       if (userId != null) {
//         ref.read(collaborativePetProvider.notifier).initialize(userId);
//         _syncSlotsWithPets();
//       }
//     });
//   }

//   void _syncSlotsWithPets() {
//     final collaborativeState = ref.read(collaborativePetProvider);
//     ref.read(collaborationSlotsProvider.notifier).syncWithUserPets(collaborativeState.userPets);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final petGameState = ref.watch(petGameProvider);
//     final collaborativeState = ref.watch(collaborativePetProvider);
//     final slotsState = ref.watch(collaborationSlotsProvider);
//     final authState = ref.read(authProvider);

//     // Se não tem pets normais nem colaborativos, mostrar tela de adoção
//     if (!petGameState.hasCurrentPet && collaborativeState.userPets.isEmpty) {
//       return _buildNoPetsState(context);
//     }

//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       // appBar: AppBar(
//       //   title: const Text('🐾 Meus Pets'),
//       //   backgroundColor: Colors.transparent,
//       //   elevation: 0,
//       //   actions: [
//       //     IconButton(
//       //       icon: const Icon(Icons.add),
//       //       onPressed: () => _showAdoptionOptions(context),
//       //     ),
//       //   ],
//       // ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           if (authState.firebaseUser != null) {
//             await ref
//                 .read(collaborativePetProvider.notifier)
//                 .initialize(authState.firebaseUser!.uid);
//             _syncSlotsWithPets();
//           }
//         },
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             children: [
//               // 1. SLOTS COLABORATIVOS NO TOPO
//               SlideFadeAnimation(
//                 duration: const Duration(milliseconds: 500),
//                 child: _buildCompactSlotsSection(context, slotsState, authState.firebaseUser!.uid),
//               ),

//               const SizedBox(height: 16),

//               // 2. PET PRINCIPAL NO CENTRO
//               if (petGameState.hasCurrentPet)
//                 SlideFadeAnimation(
//                   duration: const Duration(milliseconds: 600),
//                   child: _buildCompactMainPet(context, petGameState.currentPet!),
//                 ),

//               const SizedBox(height: 16),

//               // 3. STATUS E AÇÕES EMBAIXO
//               if (petGameState.hasCurrentPet) ...[
//                 SlideFadeAnimation(
//                   duration: const Duration(milliseconds: 700),
//                   child: _buildCompactStats(context, petGameState.currentPet!),
//                 ),
//                 const SizedBox(height: 12),
//                 SlideFadeAnimation(
//                   duration: const Duration(milliseconds: 800),
//                   child: _buildCompactActions(context, petGameState.currentPet!, ref),
//                 ),
//               ],

//               // Botão expandir slots se necessário
//               // if (slotsState.usedSlots == slotsState.maxSlots) ...[
//               //   const SizedBox(height: 16),
//               //   _buildExpandSlotsButton(context),
//               // ],

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCompactSlotsSection(
//       BuildContext context, CollaborationSlotsState slotsState, String userId) {
//     return Container(
//       padding: const EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header dos slots
//           // Row(
//           //   children: [
//           //     Container(
//           //       padding: const EdgeInsets.all(8),
//           //       decoration: BoxDecoration(
//           //         color: ThemeConfig.primaryColor.withOpacity(0.1),
//           //         borderRadius: BorderRadius.circular(10),
//           //       ),
//           //       child: Icon(
//           //         Icons.group,
//           //         color: ThemeConfig.primaryColor,
//           //         size: 18,
//           //       ),
//           //     ),
//           //     const SizedBox(width: 12),
//           //     Expanded(
//           //       child: Column(
//           //         crossAxisAlignment: CrossAxisAlignment.start,
//           //         children: [
//           //           Text(
//           //             'Adoção Colaborativa',
//           //             style: Theme.of(context).textTheme.titleSmall?.copyWith(
//           //                   fontWeight: FontWeight.w600,
//           //                 ),
//           //           ),
//           //           Text(
//           //             'Cuide junto com outros usuários',
//           //             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//           //                   color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
//           //                   fontSize: 11,
//           //                 ),
//           //           ),
//           //         ],
//           //       ),
//           //     ),
//           //     Container(
//           //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           //       decoration: BoxDecoration(
//           //         color: ThemeConfig.primaryColor.withOpacity(0.15),
//           //         borderRadius: BorderRadius.circular(8),
//           //       ),
//           //       child: Text(
//           //         '${slotsState.usedSlots}/${slotsState.maxSlots}',
//           //         style: TextStyle(
//           //           color: ThemeConfig.primaryColor,
//           //           fontWeight: FontWeight.bold,
//           //           fontSize: 12,
//           //         ),
//           //       ),
//           //     ),
//           //   ],
//           // ),

//           // const SizedBox(height: 12),

//           // Grid compacto de slots
//           SizedBox(
//             height: 90,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: slotsState.slots.length,
//               itemBuilder: (context, index) {
//                 final slot = slotsState.slots[index];
//                 return Padding(
//                   padding: EdgeInsets.only(right: index < slotsState.slots.length - 1 ? 8 : 0),
//                   child: _buildCompactSlotCard(slot, userId),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactSlotCard(CollaborationSlot slot, String userId) {
//     return GestureDetector(
//       onTap: () => _handleSlotTap(context, slot, userId),
//       child: Container(
//         width: 80,
//         height: 90,
//         decoration: BoxDecoration(
//           gradient: slot.isOccupied
//               ? LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [
//                     ThemeConfig.primaryColor.withOpacity(0.8),
//                     ThemeConfig.primaryColor.withOpacity(0.6),
//                   ],
//                 )
//               : slot.isAvailable
//                   ? LinearGradient(
//                       colors: [
//                         Theme.of(context).disabledColor.withOpacity(0.2),
//                         Theme.of(context).disabledColor.withOpacity(0.1),
//                       ],
//                     )
//                   : LinearGradient(
//                       colors: [
//                         Colors.amber.withOpacity(0.3),
//                         Colors.orange.withOpacity(0.2),
//                       ],
//                     ),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: slot.isOccupied
//                 ? Colors.white.withOpacity(0.3)
//                 : slot.isAvailable
//                     ? Theme.of(context).disabledColor.withOpacity(0.3)
//                     : Colors.amber.withOpacity(0.5),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (slot.isOccupied) ...[
//               Text(
//                 '🐱', // pet emoji based on slot.petId
//                 style: const TextStyle(fontSize: 24),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Pet ${slot.index + 1}',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ] else if (slot.isAvailable) ...[
//               Icon(
//                 Icons.add,
//                 color: Colors.grey[600],
//                 size: 24,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Adotar',
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 10,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ] else ...[
//               const Icon(
//                 Icons.lock,
//                 color: Colors.amber,
//                 size: 20,
//               ),
//               const SizedBox(height: 4),
//               const Text(
//                 'Premium',
//                 style: TextStyle(
//                   color: Colors.amber,
//                   fontSize: 9,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCompactMainPet(BuildContext context, dynamic pet) {
//     return Container(
//       padding: const EdgeInsets.all(80),
//       decoration: BoxDecoration(
//         gradient: ThemeConfig.primaryGradient,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: ThemeConfig.primaryColor.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Pet Avatar
//           FloatingAnimation(
//             child: Container(
//               // width: 100,
//               // height: 100,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.2),
//                 border: Border.all(color: Colors.white, width: 3),
//               ),
//               child: pet.imageUrl.isNotEmpty
//                   ? ClipOval(
//                       child: Image.network(
//                         pet.imageUrl,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) => const Icon(
//                           Icons.pets,
//                           size: 80,
//                           color: Colors.white,
//                         ),
//                       ),
//                     )
//                   : const Icon(
//                       Icons.pets,
//                       size: 80,
//                       color: Colors.white,
//                     ),
//             ),
//           ),

//           const SizedBox(height: 8),

//           // Pet Info
//           Text(
//             pet.name,
//             style: const TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           Text(
//             'Nível ${pet.level} • ${pet.type}',
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.white70,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactStats(BuildContext context, dynamic pet) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Status do Pet',
//             style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                   child: _buildCompactStatBar(
//                       '❤️', 'Felicidade', pet.happiness.toInt(), const Color(0xFFFF6B6B))),
//               const SizedBox(width: 12),
//               Expanded(
//                   child: _buildCompactStatBar(
//                       '🍖', 'Fome', pet.hunger.toInt(), const Color(0xFF4ECDC4))),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                   child: _buildCompactStatBar(
//                       '⚡', 'Energia', pet.energy.toInt(), const Color(0xFF45B7D1))),
//               const SizedBox(width: 12),
//               Expanded(
//                   child: _buildCompactStatBar(
//                       '💊', 'Saúde', pet.health.toInt(), const Color(0xFF96CEB4))),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactStatBar(String emoji, String label, int value, Color color) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(emoji, style: const TextStyle(fontSize: 14)),
//             const SizedBox(width: 6),
//             Expanded(
//               child: Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//             Text(
//               '$value%',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 6),
//         Container(
//           height: 6,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(3),
//           ),
//           child: FractionallySizedBox(
//             widthFactor: value / 100,
//             alignment: Alignment.centerLeft,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: color,
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCompactActions(BuildContext context, dynamic pet, WidgetRef ref) {
//     final actions = [
//       {
//         'title': 'Alimentar',
//         'icon': Icons.restaurant,
//         'color': const Color(0xFFFF6B6B),
//         'enabled': pet.hunger < 90
//       },
//       {
//         'title': 'Brincar',
//         'icon': Icons.sports_esports,
//         'color': const Color(0xFF4ECDC4),
//         'enabled': pet.energy > 20
//       },
//       {
//         'title': 'Descansar',
//         'icon': Icons.bedtime,
//         'color': const Color(0xFF45B7D1),
//         'enabled': pet.energy < 90
//       },
//       {
//         'title': 'Medicar',
//         'icon': Icons.medical_services,
//         'color': const Color(0xFF96CEB4),
//         'enabled': pet.health < 80
//       },
//     ];

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Ações de Cuidado',
//             style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//           ),
//           const SizedBox(height: 12),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 2.5,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//             ),
//             itemCount: actions.length,
//             itemBuilder: (context, index) {
//               final action = actions[index];
//               return _buildCompactActionButton(
//                 action['title'] as String,
//                 action['icon'] as IconData,
//                 action['color'] as Color,
//                 action['enabled'] as bool,
//                 () => _performAction(action['title'] as String, pet, ref),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactActionButton(
//       String title, IconData icon, Color color, bool enabled, VoidCallback onTap) {
//     return InkWell(
//       onTap: enabled ? onTap : null,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           gradient: enabled
//               ? LinearGradient(
//                   colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
//                 )
//               : LinearGradient(
//                   colors: [
//                     Theme.of(context).disabledColor.withOpacity(0.1),
//                     Theme.of(context).disabledColor.withOpacity(0.05)
//                   ],
//                 ),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color:
//                 enabled ? color.withOpacity(0.3) : Theme.of(context).disabledColor.withOpacity(0.2),
//             width: 1,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               color: enabled ? color : Theme.of(context).disabledColor,
//               size: 18,
//             ),
//             const SizedBox(width: 6),
//             Text(
//               title,
//               style: TextStyle(
//                 color: enabled
//                     ? Theme.of(context).textTheme.bodyMedium?.color
//                     : Theme.of(context).disabledColor,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildExpandSlotsButton(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: InkWell(
//         onTap: () => _showPremiumDialog(context),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.add, color: Colors.white, size: 20),
//             const SizedBox(width: 8),
//             const Text(
//               'Expandir Slots Premium',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w600,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoPetsState(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             FloatingAnimation(
//               child: Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   gradient: ThemeConfig.primaryGradient,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: ThemeConfig.primaryColor.withOpacity(0.3),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: const Icon(
//                   Icons.pets,
//                   size: 50,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'Hora de Adotar!',
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Você ainda não tem nenhum pet. Que tal adotar um amiguinho?',
//               style: Theme.of(context).textTheme.bodyLarge,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 32),
//             Column(
//               children: [
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () => Navigator.of(context).push(
//                       MaterialPageRoute(builder: (context) => const PetAdoptionScreen()),
//                     ),
//                     icon: const Icon(Icons.pets),
//                     label: const Text('Adoção Individual'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton.icon(
//                     onPressed: () => Navigator.of(context).push(
//                       MaterialPageRoute(builder: (context) => const CollaborativeAdoptionScreen()),
//                     ),
//                     icon: const Icon(Icons.group),
//                     label: const Text('Adoção Colaborativa'),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 children: [
//                   const Icon(Icons.info_outline, color: Colors.blue),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Na adoção colaborativa, você cuida de um pet junto com outro usuário anônimo!',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: Colors.blue[800],
//                         ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Métodos auxiliares mantidos
//   void _handleSlotTap(BuildContext context, CollaborationSlot slot, String userId) {
//     if (slot.isOccupied && slot.petId != null) {
//       final collaborativeState = ref.read(collaborativePetProvider);
//       final pet = collaborativeState.userPets.firstWhere(
//         (p) => p.id == slot.petId,
//         orElse: () => collaborativeState.userPets.first,
//       );

//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => CollaborativePetDetailScreen(pet: pet),
//         ),
//       );
//     } else if (slot.isAvailable) {
//       // Navigator.of(context).push(
//       //   MaterialPageRoute(
//       //     builder: (context) => const CollaborativeAdoptionScreen(),
//       //   ),
//       // );
//       _showAdoptionOptions(context);
//     } else {
//       _showPremiumDialog(context);
//     }
//   }

//   void _showAdoptionOptions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (context) => Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Escolha o Tipo de Adoção',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             const SizedBox(height: 20),
//             ListTile(
//               leading: const Icon(Icons.pets, color: Colors.blue),
//               title: const Text('Adoção Individual'),
//               subtitle: const Text('Cuide do seu pet sozinho'),
//               onTap: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).push(
//                   MaterialPageRoute(builder: (context) => const PetAdoptionScreen()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.group, color: Colors.purple),
//               title: const Text('Adoção Colaborativa'),
//               subtitle: const Text('Cuide junto com outro usuário anônimo'),
//               onTap: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).push(
//                   MaterialPageRoute(builder: (context) => const CollaborativeAdoptionScreen()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showPremiumDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('💎 Premium'),
//         content: const Text(
//           'Para ter mais slots de colaboração, faça upgrade para o plano premium!\n\n'
//           '• Slots ilimitados\n'
//           '• Match prioritário\n'
//           '• Pets especiais\n'
//           '• Sem anúncios',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Depois'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               // Implementar upgrade premium
//             },
//             child: const Text('Fazer Upgrade'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _performAction(String action, dynamic pet, WidgetRef ref) {
//     // Implementar ações do pet
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('$action realizado com sucesso!'),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }
  
// class NewPetScreen extends ConsumerStatefulWidget {
//   const NewPetScreen({super.key});

//   @override
//   ConsumerState<NewPetScreen> createState() => _NewPetScreenState();
// }

// class _NewPetScreenState extends ConsumerState<NewPetScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final authState = ref.read(authProvider);
//       final userId = authState.firebaseUser?.uid;
//       if (userId != null) {
//         ref.read(collaborativePetProvider.notifier).initialize(userId);
//         _syncSlotsWithPets();
//       }
//     });
//   }

//   void _syncSlotsWithPets() {
//     final collaborativeState = ref.read(collaborativePetProvider);
//     ref.read(collaborationSlotsProvider.notifier).syncWithUserPets(collaborativeState.userPets);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final petGameState = ref.watch(petGameProvider);
//     final collaborativeState = ref.watch(collaborativePetProvider);
//     final slotsState = ref.watch(collaborationSlotsProvider);
//     final authState = ref.read(authProvider);

//     // Se não tem pets normais nem colaborativos, mostrar tela de adoção
//     if (!petGameState.hasCurrentPet && collaborativeState.userPets.isEmpty) {
//       return _buildNoPetsState(context);
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('🐾 Meus Pets'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () => _showAdoptionOptions(context),
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           if (authState.firebaseUser != null) {
//             await ref
//                 .read(collaborativePetProvider.notifier)
//                 .initialize(authState.firebaseUser!.uid);
//             _syncSlotsWithPets();
//           }
//         },
//         child: CustomScrollView(
//           slivers: [
//             // Pet principal no centro (se existir)
//             if (petGameState.hasCurrentPet)
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(ThemeConfig.spacing16),
//                   child: SlideFadeAnimation(
//                     duration: const Duration(milliseconds: 600),
//                     child: _buildMainPetCard(context, petGameState.currentPet!),
//                   ),
//                 ),
//               ),

//             // Header dos slots colaborativos
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.all(ThemeConfig.spacing16),
//                 child: SlideFadeAnimation(
//                   duration: const Duration(milliseconds: 700),
//                   child: _buildCollaborativeSlotsHeader(context, slotsState),
//                 ),
//               ),
//             ),

//             // Grid de slots colaborativos
//             SliverPadding(
//               padding: const EdgeInsets.symmetric(horizontal: ThemeConfig.spacing16),
//               sliver: SliverGrid(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   childAspectRatio: 0.8,
//                   crossAxisSpacing: ThemeConfig.spacing12,
//                   mainAxisSpacing: ThemeConfig.spacing12,
//                 ),
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) {
//                     final slot = slotsState.slots[index];
//                     return SlideFadeAnimation(
//                       duration: Duration(milliseconds: 800 + (index * 100)),
//                       child: PetSlotCard(
//                         slot: slot,
//                         onTap: () => _handleSlotTap(context, slot, authState.firebaseUser!.uid),
//                       ),
//                     );
//                   },
//                   childCount: slotsState.slots.length,
//                 ),
//               ),
//             ),

//             // Botão para expandir slots (premium)
//             if (slotsState.usedSlots == slotsState.maxSlots)
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.all(ThemeConfig.spacing16),
//                   child: SlideFadeAnimation(
//                     duration: const Duration(milliseconds: 1000),
//                     child: _buildExpandSlotsCard(context),
//                   ),
//                 ),
//               ),

//             // Espaçamento final
//             const SliverToBoxAdapter(
//               child: SizedBox(height: ThemeConfig.spacing40),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoPetsState(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(ThemeConfig.spacing24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             FloatingAnimation(
//               child: Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   gradient: ThemeConfig.primaryGradient,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: ThemeConfig.primaryColor.withOpacity(0.3),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: const Icon(
//                   Icons.pets,
//                   size: 60,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//             const SizedBox(height: ThemeConfig.spacing24),
//             Text(
//               'Hora de Adotar!',
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             const SizedBox(height: ThemeConfig.spacing12),
//             Text(
//               'Você ainda não tem nenhum pet. Que tal adotar um amiguinho?',
//               style: Theme.of(context).textTheme.bodyLarge,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: ThemeConfig.spacing32),
//             Column(
//               children: [
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () => Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) => const PetAdoptionScreen(),
//                       ),
//                     ),
//                     icon: const Icon(Icons.pets),
//                     label: const Text('Adoção Individual'),
//                     style: ElevatedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing16),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: ThemeConfig.spacing12),
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton.icon(
//                     onPressed: () => Navigator.of(context).push(
//                       MaterialPageRoute(
//                         builder: (context) => const CollaborativeAdoptionScreen(),
//                       ),
//                     ),
//                     icon: const Icon(Icons.group),
//                     label: const Text('Adoção Colaborativa'),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing16),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: ThemeConfig.spacing24),
//             Container(
//               padding: const EdgeInsets.all(ThemeConfig.spacing16),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
//               ),
//               child: Column(
//                 children: [
//                   const Icon(Icons.info_outline, color: Colors.blue),
//                   const SizedBox(height: ThemeConfig.spacing8),
//                   Text(
//                     'Na adoção colaborativa, você cuida de um pet junto com outro usuário anônimo!',
//                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                           color: Colors.blue[800],
//                         ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMainPetCard(BuildContext context, dynamic pet) {
//     return Card(
//       elevation: 8,
//       child: Container(
//         height: 200,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
//           gradient: ThemeConfig.primaryGradient,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(ThemeConfig.spacing20),
//           child: Row(
//             children: [
//               // Pet image
//               Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white.withOpacity(0.2),
//                   border: Border.all(color: Colors.white, width: 3),
//                 ),
//                 child: pet.imageUrl.isNotEmpty
//                     ? ClipOval(
//                         child: Image.network(
//                           pet.imageUrl,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) => const Icon(
//                             Icons.pets,
//                             size: 48,
//                             color: Colors.white,
//                           ),
//                         ),
//                       )
//                     : const Icon(
//                         Icons.pets,
//                         size: 48,
//                         color: Colors.white,
//                       ),
//               ),

//               const SizedBox(width: ThemeConfig.spacing20),

//               // Pet info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       pet.name,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       'Nível ${pet.level}',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.white70,
//                       ),
//                     ),
//                     const SizedBox(height: ThemeConfig.spacing12),
//                     Row(
//                       children: [
//                         _buildStatChip('❤️', '${pet.happiness.toInt()}%'),
//                         const SizedBox(width: ThemeConfig.spacing8),
//                         _buildStatChip('🍖', '${pet.hunger.toInt()}%'),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatChip(String emoji, String value) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: ThemeConfig.spacing8,
//         vertical: ThemeConfig.spacing4,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(emoji, style: const TextStyle(fontSize: 12)),
//           const SizedBox(width: ThemeConfig.spacing4),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 12,
//               color: Colors.white,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCollaborativeSlotsHeader(BuildContext context, CollaborationSlotsState slotsState) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(ThemeConfig.spacing16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.group,
//                   color: ThemeConfig.primaryColor,
//                 ),
//                 const SizedBox(width: ThemeConfig.spacing8),
//                 Expanded(
//                   child: Text(
//                     'Adoção Colaborativa',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: ThemeConfig.spacing8,
//                     vertical: ThemeConfig.spacing4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: ThemeConfig.primaryColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
//                   ),
//                   child: Text(
//                     '${slotsState.usedSlots}/${slotsState.maxSlots}',
//                     style: TextStyle(
//                       color: ThemeConfig.primaryColor,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: ThemeConfig.spacing8),
//             Text(
//               'Cuide de pets junto com outros usuários anônimos',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Colors.grey[600],
//                   ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildExpandSlotsCard(BuildContext context) {
//     return Card(
//       child: InkWell(
//         onTap: () => _showPremiumDialog(context),
//         borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
//         child: Padding(
//           padding: const EdgeInsets.all(ThemeConfig.spacing16),
//           child: Row(
//             children: [
//               Container(
//                 width: 48,
//                 height: 48,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Colors.amber, Colors.orange],
//                   ),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.add,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(width: ThemeConfig.spacing16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Expandir Slots',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w600,
//                           ),
//                     ),
//                     Text(
//                       'Tenha mais pets colaborativos com o plano premium',
//                       style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                             color: Colors.grey[600],
//                           ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 color: Colors.grey[400],
//                 size: 16,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleSlotTap(BuildContext context, CollaborationSlot slot, String userId) {
//     if (slot.isOccupied && slot.petId != null) {
//       // Navegar para detalhes do pet colaborativo
//       final collaborativeState = ref.read(collaborativePetProvider);
//       final pet = collaborativeState.userPets.firstWhere(
//         (p) => p.id == slot.petId,
//         orElse: () => collaborativeState.userPets.first,
//       );

//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => CollaborativePetDetailScreen(pet: pet),
//         ),
//       );
//     } else if (slot.isAvailable) {
//       // Navegar para adoção colaborativa
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => const CollaborativeAdoptionScreen(),
//         ),
//       );
//     } else {
//       // Slot premium bloqueado
//       _showPremiumDialog(context);
//     }
//   }

//   void _showAdoptionOptions(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(ThemeConfig.borderRadius16),
//         ),
//       ),
//       builder: (context) => Padding(
//         padding: const EdgeInsets.all(ThemeConfig.spacing20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               'Escolha o Tipo de Adoção',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//             const SizedBox(height: ThemeConfig.spacing20),
//             ListTile(
//               leading: const Icon(Icons.pets, color: Colors.blue),
//               title: const Text('Adoção Individual'),
//               subtitle: const Text('Cuide do seu pet sozinho'),
//               onTap: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => const PetAdoptionScreen(),
//                   ),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.group, color: Colors.purple),
//               title: const Text('Adoção Colaborativa'),
//               subtitle: const Text('Cuide junto com outro usuário anônimo'),
//               onTap: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => const CollaborativeAdoptionScreen(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showPremiumDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('💎 Premium'),
//         content: const Text(
//           'Para ter mais slots de colaboração, faça upgrade para o plano premium!\n\n'
//           '• Slots ilimitados\n'
//           '• Match prioritário\n'
//           '• Pets especiais\n'
//           '• Sem anúncios',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Depois'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               // Implementar upgrade premium
//             },
//             child: const Text('Fazer Upgrade'),
//           ),
//         ],
//       ),
//     );
//   }
// }



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

