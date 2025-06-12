// AdoptionFlow

// lib/widgets/adoption_flow.dart - AdoptionFlow
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/models/pet_model.dart';
import 'package:petverse/providers/feed_provider.dart';
import 'package:petverse/providers/pet_provider.dart';
import 'package:petverse/providers/theme_provider.dart';
import 'package:petverse/providers/user_provider.dart';
import 'package:petverse/utils/constants.dart';
// import 'package:petverse/widgets/bottom_sheet_base.dart'; // Removido

class AdoptionFlow extends ConsumerStatefulWidget {
  // final bool show; // Removido
  // final VoidCallback onClose; // Removido

  const AdoptionFlow({super.key}); // Construtor simplificado

  @override
  ConsumerState<AdoptionFlow> createState() => _AdoptionFlowState();
}

class _AdoptionFlowState extends ConsumerState<AdoptionFlow> {
  int _currentStep = 0; // 0: Seleção de tipo, 1: Seleção de pet
  String? _selectedType; // 'solo', 'collab'
  bool _isGeneratingAIPet = false; // Estado para o loading da IA

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    // O estado (_currentStep, _selectedType) será resetado cada vez que o modal for aberto
    // devido à natureza de como o showModalBottomSheet constrói seu filho.

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              if (_currentStep == 1) // Botão de voltar para a seleção de tipo
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: isDark ? Colors.white : const Color(0xFF1F2937)),
                    onPressed: () => setState(() => _currentStep = 0),
                  ),
                ),
              Expanded(
                child: Text(
                  _currentStep == 0 ? 'Tipo de Adoção' : _getScreenTitle(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context), // Fecha o modal
                child: Container(
                  /* ... (código do botão de fechar como nos outros sheets) ... */
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF374151)
                          : const Color(0xFFF3F4F6),
                      shape: BoxShape.circle),
                  child: Icon(Icons.close,
                      size: 18,
                      color: isDark ? Colors.white : const Color(0xFF1F2937)),
                ),
              ),
            ],
          ),
        ),
        Divider(
            height: 1,
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
        Expanded(
          child: Padding(
            // Adiciona padding ao redor do conteúdo principal
            padding: const EdgeInsets.all(16.0),
            child: _currentStep == 0
                ? _buildTypeSelection()
                : _buildPetSelection(),
          ),
        ),
      ],
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
    final user = ref.watch(userProvider);

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
          type: 'ai', // Custo de 10 gemas
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
    final user = ref.watch(userProvider);

    return GestureDetector(
      onTap: enabled
          ? () {
              if (type == 'ai') {
                if ((user?.gems ?? 0) >= 10) {
                  _handleAIPetAdoption(); // Inicia a geração do pet por IA
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          '❌ Gemas insuficientes! Você precisa de 10 gemas.'),
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  );
                }
              } else {
                setState(() {
                  _selectedType = type;
                  _currentStep = 1;
                });
              }
            }
          : null,
      child: Opacity(
        // Adiciona opacidade se desabilitado
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: enabled
                ? (isSpecial
                    ? (isDark
                        ? const Color(0xFF581C87)
                        : const Color(0xFFF3E8FF))
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
              if (type == 'ai' && _isGeneratingAIPet) ...[
                const SizedBox(height: 12),
                const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6))),
                const SizedBox(height: 12),
              ] else
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
                    const Icon(Icons.diamond,
                        size: 16, color: Color(0xFF8B5CF6)),
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
      ),
    );
  }

  Widget _buildPetSelection() {
    final user = ref.watch(userProvider);
    final pets =
        _selectedType == 'solo' ? Constants.basicPets : Constants.collabPets;

    // Não precisa de Column > Expanded aqui, pois o GridView já é expansível
    // e o Padding já foi adicionado no build principal.
    return GridView.builder(
      // padding: const EdgeInsets.symmetric(vertical: 16), // Removido, padding geral já existe
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final petData = pets[index];
        final canAfford = _selectedType == 'solo'
            ? (user?.coins ?? 0) >= (petData['cost'] ?? 0)
            : true; // Pets de colaboração não têm custo de moedas aqui

        return _buildPetCard(petData, canAfford);
      },
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

  Future<void> _adoptPet(Map<String, dynamic> petData) async {
    // Marcado como async
    final petNotifier = ref.read(petProvider.notifier);
    final userNotifier = ref.read(userProvider.notifier);
    final user = ref.read(userProvider);

    print('✅ Tentando adotar: ${petData['name']} (${_selectedType})'); // Debug

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('❌ Erro: Usuário não logado.'),
            backgroundColor: Color(0xFFEF4444)),
      );
      return;
    }

    if (_selectedType == 'solo') {
      if (user != null && user.coins >= (petData['cost'] as int)) {
        try {
          // Deduzir moedas
          await userNotifier.updateCoins(user.coins - (petData['cost'] as int));

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
          await petNotifier.addPet(newPet);

          // ✅ CORREÇÃO: Adicionar post no feed
          final feedNotifier = ref.read(feedProvider.notifier);
          feedNotifier.addAdoptionPost(
            user, // Argument 1: UserModel user
            newPet.name, // Argument 2: String petName
            newPet.id, // Argument 3: String petId
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Text(petData['emoji'],
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                        child:
                            Text('🎉 ${petData['name']} adotado com sucesso!')),
                  ],
                ),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
            print(
                '✅ Pet solo adotado: ${newPet.name} por ${petData['cost']} moedas');
            Navigator.pop(context); // Fecha o modal
          }
        } catch (e) {
          print('❌ Erro ao adotar pet solo: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('❌ Erro ao adotar: ${e.toString()}'),
                  backgroundColor: const Color(0xFFEF4444)),
            );
          }
          // Considerar reverter a dedução de moedas se a criação do pet falhar,
          // mas isso adiciona complexidade. Por ora, o erro é exibido.
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '❌ Moedas insuficientes! Você precisa de ${petData['cost']} moedas.'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
        print('❌ Moedas insuficientes: ${user.coins}/${petData['cost']}');
      }
    } else {
      // ✅ CORREÇÃO: Handle collaboration adoption melhorado
      await _handleCollabAdoption(petData);
    }
  }

  Future<void> _handleCollabAdoption(Map<String, dynamic> petData) async {
    // Marcado como async
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
        ownerId: user!.id, // user já foi verificado ou deveria ser
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

      try {
        await petNotifier.addPet(newPet);

        final feedNotifier = ref.read(feedProvider.notifier);
        feedNotifier.addCollaborationPost(
          user.username,
          newPet.name,
          user.id,
          newPet.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '🎉 Match encontrado! Vocês adotaram ${petData['name']}!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          print('✅ Pet colaborativo adotado: ${newPet.name}');
          Navigator.pop(context); // Fecha o modal
        }
      } catch (e) {
        print('❌ Erro ao adotar pet colaborativo: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('❌ Erro ao adotar: ${e.toString()}'),
                backgroundColor: const Color(0xFFEF4444)),
          );
        }
      }
    } else {
      // Adicionar à fila de espera
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🦄 Solicitação enviada! Aguardando parceiro...'),
            backgroundColor: Color(0xFF8B5CF6),
          ),
        );
        Navigator.pop(context); // Fecha o modal
      }
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

  // Simula uma chamada à API da Gemini para gerar dados de um pet
  Future<Map<String, dynamic>> _fetchAIPetData() async {
    // Simula um delay de rede
    await Future.delayed(const Duration(seconds: 3));

    // Lógica para gerar dados aleatórios para o pet de IA
    final random = Random();
    final names = [
      'Centurion',
      'Nebula',
      'Sparky',
      'Cosmo',
      'Pixel',
      'Bolt',
      'Echo'
    ];
    final emojis = [
      '✨',
      '🌠',
      '💫',
      '☄️',
      '🌌',
      '🌟',
      '👾'
    ]; // Emojis que indicam IA/raridade
    final categories = [
      'cósmico',
      'digital',
      'elemental',
      'robótico',
      'energético'
    ];
    final rarities = ['único', 'mítico']; // Pets de IA são sempre raros/únicos

    // Simula uma possível falha da API (5% de chance)
    if (random.nextDouble() < 0.05) {
      throw Exception("Falha na API de geração de pets. Tente novamente.");
    }

    return {
      'name': names[random.nextInt(names.length)],
      'emoji': emojis[random.nextInt(emojis.length)],
      'rarity': rarities[random.nextInt(rarities.length)],
      'category': categories[random.nextInt(categories.length)],
    };
  }

  Future<void> _handleAIPetAdoption() async {
    if (_isGeneratingAIPet) return; // Evita múltiplas chamadas

    setState(() => _isGeneratingAIPet = true);

    final userNotifier = ref.read(userProvider.notifier);
    final petNotifier = ref.read(petProvider.notifier);
    final feedNotifier = ref.read(feedProvider.notifier);
    final user = ref.read(userProvider);

    const aiPetCost = 10;

    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('❌ Erro: Usuário não logado para gerar pet IA.'),
              backgroundColor: Color(0xFFEF4444)),
        );
        setState(() => _isGeneratingAIPet = false);
      }
      return;
    }

    try {
      final aiPetData = await _fetchAIPetData();

      await userNotifier.updateGems(user.gems - aiPetCost);

      final newPet = PetModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: aiPetData['name'],
        emoji: aiPetData['emoji'],
        rarity: aiPetData['rarity'],
        category: aiPetData['category'],
        type: 'ai',
        ownerId: user.id,
        level: 1,
        xp: 0,
        happiness: 70,
        hunger: 70,
        energy: 70,
        health: 90,
        revealLevel: 1,
        isCollab: false,
        isUnique: true,
        identityRevealed: true,
        canInteract: true,
        accessories: [],
        lastCared: DateTime.now(),
        adoptedAt: DateTime.now(),
      );

      await petNotifier.addPet(newPet);
      feedNotifier.addAdoptionPost(user, newPet.name, newPet.id,
          isUnique: true);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '🎉 Pet de IA "${newPet.name}" ${newPet.emoji} gerado e adotado!'),
              backgroundColor: const Color(0xFF8B5CF6)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ Erro ao gerar pet: ${e.toString()}'),
              backgroundColor: const Color(0xFFEF4444)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingAIPet = false);
      }
    }
  }

  void _showAIComingSoon() {
    // Primeiro, fecha o modal de adoção se ele estiver aberto
    // Navigator.of(context).pop(); // Comentado pois o modal de adoção já deve ser fechado antes

    showDialog(
      // Mostra o diálogo de "Em Breve"
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
