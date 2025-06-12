// AdoptionFlow

// lib/widgets/adoption_flow.dart - AdoptionFlow
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/models/pet_model.dart';
import 'package:petverse/providers/feed_provider.dart';
import 'package:petverse/providers/pet_provider.dart';
import 'package:petverse/providers/theme_provider.dart';
import 'package:petverse/providers/user_provider.dart';
import 'package:petverse/utils/constants.dart';
import 'package:petverse/widgets/bottom_sheet_base.dart';

class AdoptionFlow extends ConsumerStatefulWidget {
  final bool show;
  final VoidCallback onClose;

  const AdoptionFlow({super.key, required this.show, required this.onClose});

  @override
  ConsumerState<AdoptionFlow> createState() => _AdoptionFlowState();
}

class _AdoptionFlowState extends ConsumerState<AdoptionFlow> {
  int _currentStep = 0;
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    if (widget.show) {
      _currentStep = 0;
      _selectedType = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetBase(
      show: widget.show,
      onClose: _handleClose,
      title: _currentStep == 0 ? 'Tipo de Adoção' : _getScreenTitle(),
      fullHeight: true,
      child: _currentStep == 0 ? _buildTypeSelection() : _buildPetSelection(),
    );
  }

  String _getScreenTitle() {
    switch (_selectedType) {
      case 'solo':
        return 'Pets Básicos';
      case 'collab':
        return 'Pets Especiais';
      default:
        return 'Seleção';
    }
  }

  Widget _buildTypeSelection() {
    final pets = ref.watch(petProvider);
    final hasSoloPet = pets.any((pet) => !pet.isCollab);

    return Column(
      children: [
        _buildTypeCard(
          emoji: '🐕',
          title: 'Pet Solo',
          description: 'Cuide sozinho do seu pet',
          type: 'solo',
          enabled: !hasSoloPet,
          disabledMessage: 'Você já tem um pet solo',
        ),
        const SizedBox(height: 16),
        _buildTypeCard(
          emoji: '🦄',
          title: 'Pet Colaborativo',
          description: 'Cuide com um parceiro',
          type: 'collab',
          enabled: true,
        ),
        const SizedBox(height: 16),
        _buildTypeCard(
          emoji: '✨',
          title: 'Pet Único com IA',
          description: 'Gere com inteligência artificial',
          type: 'ai',
          enabled: true,
          isSpecial: true,
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required String emoji,
    required String title,
    required String description,
    required String type,
    bool enabled = true,
    String? disabledMessage,
    bool isSpecial = false,
  }) {
    final isDark = ref.watch(themeProvider);

    return GestureDetector(
      onTap: enabled
          ? () {
              if (type == 'ai') {
                // Navigate to AI generation
                widget.onClose();
                _showAIComingSoon();
              } else {
                setState(() {
                  _selectedType = type;
                  _currentStep = 1;
                });
              }
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: enabled
              ? (isSpecial
                  ? (isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF))
                  : (isDark ? const Color(0xFF1F2937) : Colors.white))
              : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(16),
          border: isSpecial
              ? Border.all(color: const Color(0xFF8B5CF6), width: 2)
              : Border.all(color: Colors.transparent),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: enabled
                    ? (isDark ? Colors.white : const Color(0xFF1F2937))
                    : const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: enabled
                    ? (isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280))
                    : const Color(0xFF6B7280),
              ),
            ),
            if (!enabled && disabledMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                disabledMessage,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
            if (isSpecial) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.diamond, size: 16, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 4),
                  Text(
                    '10 gemas',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFF7C3AED),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPetSelection() {
    final user = ref.watch(userProvider);
    final pets =
        _selectedType == 'solo' ? Constants.basicPets : Constants.collabPets;

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75, // ✅ CORREÇÃO: Proporção ajustada
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              final canAfford = _selectedType == 'solo'
                  ? (user?.coins ?? 0) >= (pet['cost'] ?? 0)
                  : true;

              return _buildPetCard(pet, canAfford);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPetCard(Map<String, dynamic> petData, bool canAfford) {
    final isDark = ref.watch(themeProvider);

    return GestureDetector(
      onTap: canAfford ? () => _adoptPet(petData) : null,
      child: Container(
        padding: const EdgeInsets.all(6), // ✅ CORREÇÃO: Padding reduzido
        decoration: BoxDecoration(
          color: canAfford
              ? (isDark ? const Color(0xFF1F2937) : Colors.white)
              : (isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(12),
          border: canAfford
              ? Border.all(
                  color: isDark
                      ? const Color(0xFF374151)
                      : const Color(0xFFE5E7EB))
              : Border.all(color: Colors.transparent),
          boxShadow: canAfford
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .spaceEvenly, // ✅ CORREÇÃO: Distribuição uniforme
          children: [
            // ✅ CORREÇÃO: Emoji com Flexible
            Flexible(
              flex: 3,
              child: FittedBox(
                child: Text(
                  petData['emoji'],
                  style: TextStyle(
                    fontSize: 24, // ✅ Tamanho controlado
                    color: canAfford ? null : Colors.grey,
                  ),
                ),
              ),
            ),

            // ✅ CORREÇÃO: Nome com overflow controlado
            Flexible(
              flex: 2,
              child: Text(
                petData['name'],
                style: TextStyle(
                  fontSize: 10, // ✅ Fonte pequena
                  fontWeight: FontWeight.bold,
                  color: canAfford
                      ? (isDark ? Colors.white : const Color(0xFF1F2937))
                      : const Color(0xFF9CA3AF),
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // ✅ Máximo 1 linha
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // ✅ CORREÇÃO: Raridade compacta
            Flexible(
              flex: 1,
              child: Text(
                petData['rarity'],
                style: TextStyle(
                  fontSize: 8, // ✅ Fonte muito pequena
                  color: canAfford
                      ? (isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280))
                      : const Color(0xFF6B7280),
                ),
              ),
            ),

            // ✅ CORREÇÃO: Preço/Status
            if (_selectedType == 'solo')
              Flexible(
                flex: 2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: canAfford
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: FittedBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 8,
                          color: canAfford
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 1),
                        Text(
                          '${petData['cost']}',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: canAfford
                                ? const Color(0xFFA16207)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (_selectedType == 'collab' && petData['hasMatch'] == true)
              Flexible(
                flex: 1,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const FittedBox(
                    child: Text(
                      '✅',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _adoptPet(Map<String, dynamic> petData) {
    final petNotifier = ref.read(petProvider.notifier);
    final userNotifier = ref.read(userProvider.notifier);
    final user = ref.read(userProvider);

    print('✅ Tentando adotar: ${petData['name']} (${_selectedType})'); // Debug

    if (_selectedType == 'solo') {
      if (user != null && user.coins >= (petData['cost'] as int)) {
        // Deduzir moedas
        userNotifier.updateCoins(user.coins - (petData['cost'] as int));

        // ✅ CORREÇÃO: Criar pet solo corretamente
        final newPet = PetModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: petData['name'],
          emoji: petData['emoji'],
          rarity: petData['rarity'],
          category: petData['category'],
          type: 'solo',
          ownerId: user.id,
          level: 1,
          xp: 0,
          happiness: 50,
          hunger: 50,
          energy: 50,
          health: 80,
          revealLevel: 5,
          isCollab: false, // ✅ Pet solo
          isUnique: false,
          identityRevealed: false,
          canInteract: true,
          accessories: [],
          lastCared: DateTime.now(),
          adoptedAt: DateTime.now(),
        );

        // ✅ CORREÇÃO: Adicionar pet ao provider
        petNotifier.addPet(newPet);

        // ✅ CORREÇÃO: Adicionar post no feed
        final feedNotifier = ref.read(feedProvider.notifier);
        feedNotifier.addAdoptionPost(
          user.username,
          newPet.name,
          user.id,
          newPet.id,
        );

        // ✅ CORREÇÃO: Feedback de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(petData['emoji'], style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('🎉 ${petData['name']} adotado com sucesso!')),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 3),
          ),
        );

        print(
            '✅ Pet solo adotado: ${newPet.name} por ${petData['cost']} moedas');
        widget.onClose(); // ✅ Fechar modal
      } else {
        // ✅ CORREÇÃO: Feedback de erro para moedas insuficientes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '❌ Moedas insuficientes! Você precisa de ${petData['cost']} moedas.'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
        print('❌ Moedas insuficientes: ${user?.coins ?? 0}/${petData['cost']}');
      }
    } else {
      // ✅ CORREÇÃO: Handle collaboration adoption melhorado
      _handleCollabAdoption(petData);
    }
  }

  void _handleCollabAdoption(Map<String, dynamic> petData) {
    final user = ref.read(userProvider);

    if (petData['hasMatch'] == true) {
      final petNotifier = ref.read(petProvider.notifier);

      // ✅ CORREÇÃO: Criar pet colaborativo
      final newPet = PetModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: petData['name'],
        emoji: petData['emoji'],
        rarity: petData['rarity'],
        category: petData['category'],
        type: 'collab',
        ownerId: user?.id ?? '',
        partnerId: 'partner_${DateTime.now().millisecondsSinceEpoch}',
        partnerAvatar: _generateRandomAvatar(),
        level: 1,
        xp: 0,
        happiness: 50,
        hunger: 50,
        energy: 50,
        health: 80,
        revealLevel: 5,
        isCollab: true, // ✅ Pet colaborativo
        isUnique: false,
        identityRevealed: false,
        canInteract: true,
        accessories: [],
        lastCared: DateTime.now(),
        adoptedAt: DateTime.now(),
      );

      petNotifier.addPet(newPet);

      // ✅ CORREÇÃO: Adicionar post no feed
      final feedNotifier = ref.read(feedProvider.notifier);
      feedNotifier.addCollaborationPost(
        user?.username ?? 'Usuário',
        newPet.name,
        user?.id ?? '',
        newPet.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('🎉 Match encontrado! Vocês adotaram ${petData['name']}!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );

      print('✅ Pet colaborativo adotado: ${newPet.name}');
      widget.onClose();
    } else {
      // Adicionar à fila de espera
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🦄 Solicitação enviada! Aguardando parceiro...'),
          backgroundColor: Color(0xFF8B5CF6),
        ),
      );
      widget.onClose();
    }
  }

  // ✅ CORREÇÃO: Método para gerar avatar aleatório
  String _generateRandomAvatar() {
    final avatars = [
      '👨',
      '👩',
      '🧑',
      '👱',
      '👨‍💻',
      '👩‍💻',
      '🧔',
      '👴',
      '👵'
    ];
    return avatars[DateTime.now().millisecond % avatars.length];
  }

  void _handleClose() {
    setState(() {
      _currentStep = 0;
      _selectedType = null;
    });
    widget.onClose();
  }

  void _showAIComingSoon() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFF8B5CF6)),
            SizedBox(width: 8),
            Text('🎨 Pet Único com IA'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Funcionalidade em desenvolvimento!\n\n'
              'Em breve você poderá gerar pets únicos usando inteligência artificial.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.diamond, color: Color(0xFF8B5CF6)),
                SizedBox(width: 4),
                Text('Custo: 10 gemas',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
