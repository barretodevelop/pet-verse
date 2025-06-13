// lib/widgets/adoption_flow.dart - ENHANCED com IA Real
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/models/pet_model.dart';
import 'package:petverse/providers/feed_provider.dart';
import 'package:petverse/providers/pet_provider.dart';
import 'package:petverse/providers/theme_provider.dart';
import 'package:petverse/providers/user_provider.dart';
import 'package:petverse/services/ai_service.dart'; // ✅ ENHANCED AIService
import 'package:petverse/utils/constants.dart';

class AdoptionFlow extends ConsumerStatefulWidget {
  const AdoptionFlow({super.key});

  @override
  ConsumerState<AdoptionFlow> createState() => _AdoptionFlowState();
}

class _AdoptionFlowState extends ConsumerState<AdoptionFlow> {
  int _currentStep =
      0; // 0: Tipo, 1: Pets normais, 2: IA prompt, 3: Escolha de 3 opções
  String? _selectedType; // 'solo', 'collab', 'ai'
  bool _isGeneratingAIPet = false;

  // ✅ NOVOS: Estados para as 3 opções
  String _aiPrompt = '';
  bool _isAIHealthy = false;
  final TextEditingController _promptController = TextEditingController();
  AIGenerationResult? _aiGenerationResult; // ✅ Resultado com 3 opções
  AIGeneratedPetOption? _selectedPetOption; // ✅ Opção escolhida pelo usuário

  @override
  void initState() {
    super.initState();
    _checkAIHealth();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _checkAIHealth() async {
    final isHealthy = await AIService.checkAIServiceHealth();
    if (mounted) {
      setState(() => _isAIHealthy = isHealthy);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(isDark),
        Divider(
            height: 1,
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCurrentStepContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: isDark ? Colors.white : const Color(0xFF1F2937)),
                onPressed: () => setState(() {
                  if (_currentStep == 3) {
                    _currentStep = 2; // Das opções volta para prompt
                  } else if (_currentStep == 2 && _selectedType == 'ai') {
                    _currentStep = 0; // Do prompt IA volta para seleção de tipo
                  } else {
                    _currentStep--;
                  }
                }),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getScreenTitle(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getProgressText(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
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
    );
  }

  String _getScreenTitle() {
    switch (_currentStep) {
      case 0:
        return 'Tipo de Adoção';
      case 1:
        return _selectedType == 'solo' ? 'Pets Básicos' : 'Pets Especiais';
      case 2:
        return 'Descreva seu Pet Ideal';
      case 3:
        return 'Escolha seu Favorito'; // ✅ NOVO
      default:
        return 'Adoção';
    }
  }

  String _getProgressText() {
    switch (_currentStep) {
      case 0:
        return 'Passo 1 de 3 • Escolha o tipo';
      case 1:
        return 'Passo 2 de 3 • Selecione seu pet';
      case 2:
        return 'Passo 2 de 3 • Gere com IA';
      case 3:
        return 'Passo 3 de 3 • Escolha entre as opções'; // ✅ NOVO
      default:
        return '';
    }
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildTypeSelection();
      case 1:
        return _buildPetSelection();
      case 2:
        return _buildAIPromptStep();
      case 3:
        return _buildAIOptionsSelection(); // ✅ NOVO STEP
      default:
        return _buildTypeSelection();
    }
  }

  // ✅ NOVO: Step para escolher entre as 3 opções geradas
  Widget _buildAIOptionsSelection() {
    final isDark = ref.watch(themeProvider);

    if (_aiGenerationResult == null || !_aiGenerationResult!.isValid) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text('Erro ao gerar opções. Tente novamente.'),
          ],
        ),
      );
    }

    final options = _aiGenerationResult!.options;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ HEADER com informações da geração
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: _aiGenerationResult!.hasRealGeneration
                ? const Color(0xFFD1FAE5)
                : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _aiGenerationResult!.hasRealGeneration
                  ? const Color(0xFF10B981)
                  : const Color(0xFFF59E0B),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _aiGenerationResult!.hasRealGeneration
                    ? Icons.auto_awesome
                    : Icons.casino,
                color: _aiGenerationResult!.hasRealGeneration
                    ? const Color(0xFF065F46)
                    : const Color(0xFFA16207),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _aiGenerationResult!.hasRealGeneration
                          ? '✨ Gerado com IA Real'
                          : '🎲 Gerado com Simulação',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _aiGenerationResult!.hasRealGeneration
                            ? const Color(0xFF065F46)
                            : const Color(0xFFA16207),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Baseado em: "${_aiGenerationResult!.prompt}"',
                      style: TextStyle(
                        fontSize: 12,
                        color: _aiGenerationResult!.hasRealGeneration
                            ? const Color(0xFF047857)
                            : const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ✅ INSTRUÇÕES
        Text(
          'Escolha seu pet favorito:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),

        // ✅ GRID DAS 3 OPÇÕES
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1, // Uma opção por linha para mais espaço
              childAspectRatio: 2.5, // Proporção retangular
              mainAxisSpacing: 16,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = _selectedPetOption?.id == option.id;

              return _buildPetOptionCard(option, isSelected, isDark);
            },
          ),
        ),

        const SizedBox(height: 20),

        // ✅ BOTÃO DE FINALIZAR
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _selectedPetOption != null ? _finalizePetAdoption : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.pets),
                const SizedBox(width: 8),
                Text(_selectedPetOption != null
                    ? 'Adotar ${_selectedPetOption!.name}!'
                    : 'Escolha uma opção'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ CARD DE OPÇÃO DE PET
  Widget _buildPetOptionCard(
      AIGeneratedPetOption option, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPetOption = option),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF581C87) : const Color(0xFFF3E8FF))
              : (isDark ? const Color(0xFF1F2937) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8B5CF6)
                : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ✅ PREVIEW DA IMAGEM OU EMOJI
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF4B5563)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: option.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: option.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: Text(option.emoji,
                              style: const TextStyle(fontSize: 32)),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Text(option.emoji,
                              style: const TextStyle(fontSize: 32)),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(option.emoji,
                          style: const TextStyle(fontSize: 40)),
                    ),
            ),

            const SizedBox(width: 16),

            // ✅ INFORMAÇÕES DO PET
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      // ✅ BADGE DE TIPO
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: option.isGenerated
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          option.isGenerated ? 'IA Real' : 'Simulado',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    option.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // ✅ STATS PREVIEW
                  Row(
                    children: [
                      _buildStatPreview('😊', option.stats['happiness'] ?? 70),
                      const SizedBox(width: 12),
                      _buildStatPreview('❤️', option.stats['health'] ?? 80),
                      const SizedBox(width: 12),
                      _buildStatPreview('⚡', option.stats['energy'] ?? 75),
                    ],
                  ),
                ],
              ),
            ),

            // ✅ INDICADOR DE SELEÇÃO
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ PREVIEW PEQUENO DE STAT
  Widget _buildStatPreview(String emoji, int value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 2),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ✅ FINALIZAR ADOÇÃO DO PET ESCOLHIDO
  Future<void> _finalizePetAdoption() async {
    if (_selectedPetOption == null) return;

    final userNotifier = ref.read(userProvider.notifier);
    final petNotifier = ref.read(petProvider.notifier);
    final feedNotifier = ref.read(feedProvider.notifier);
    final user = ref.read(userProvider);

    if (user == null) return;

    try {
      // ✅ DEDUZIR GEMAS
      await userNotifier.updateGems(user.gems - 10);

      // ✅ CRIAR PET BASEADO NA OPÇÃO ESCOLHIDA
      final newPet = PetModel(
        id: _selectedPetOption!.id,
        name: _selectedPetOption!.name,
        emoji: _selectedPetOption!.emoji,
        rarity: _selectedPetOption!.rarity,
        category: _selectedPetOption!.category,
        type: 'ai',
        ownerId: user.id,
        imageUrl: _selectedPetOption!.imageUrl, // ✅ IMAGEM REAL da IA
        level: 1,
        xp: 0,
        happiness: _selectedPetOption!.stats['happiness']!,
        hunger: _selectedPetOption!.stats['hunger']!,
        energy: _selectedPetOption!.stats['energy']!,
        health: _selectedPetOption!.stats['health']!,
        revealLevel: 1,
        isCollab: false,
        isUnique: true,
        identityRevealed: true,
        canInteract: true,
        accessories: [],
        lastCared: DateTime.now(),
        adoptedAt: DateTime.now(),
        prompt: _aiPrompt, // ✅ Salvar prompt original
      );

      await petNotifier.addPet(newPet);
      feedNotifier.addAdoptionPost(user, newPet.name, newPet.id,
          isUnique: true);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(newPet.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🎉 ${newPet.name} adotado com sucesso!',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _selectedPetOption!.isGenerated
                            ? 'Gerado com IA real'
                            : 'Gerado com simulação',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF8B5CF6),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('❌ Erro na adoção final: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro na adoção: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  // ✅ RESTO DOS MÉTODOS PERMANECEM IGUAIS (buildTypeSelection, buildPetSelection, etc.)
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
          description: _isAIHealthy
              ? 'Gere 3 opções e escolha seu favorito'
              : 'IA indisponível • Usando simulação',
          type: 'ai',
          enabled: true,
          isSpecial: true,
          isAIHealthy: _isAIHealthy,
        ),
      ],
    );
  }

  // ✅ MÉTODOS EXISTENTES MANTIDOS
  Widget _buildTypeCard({
    required String emoji,
    required String title,
    required String description,
    required String type,
    bool enabled = true,
    String? disabledMessage,
    bool isSpecial = false,
    bool isAIHealthy = true,
  }) {
    final isDark = ref.watch(themeProvider);
    final user = ref.watch(userProvider);

    return GestureDetector(
      onTap: enabled
          ? () {
              if (type == 'ai') {
                if ((user?.gems ?? 0) >= 10) {
                  setState(() {
                    _selectedType = type;
                    _currentStep = 2; // Ir para step de prompt
                  });
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
                ? Border.all(
                    color: isAIHealthy
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFFF59E0B),
                    width: 2)
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 48)),
                  if (type == 'ai' && !isAIHealthy) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.warning,
                        color: Color(0xFFF59E0B), size: 20),
                  ],
                ],
              ),
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
                textAlign: TextAlign.center,
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

  Widget _buildAIPromptStep() {
    final isDark = ref.watch(themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isAIHealthy)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Color(0xFFF59E0B), size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'IA temporariamente indisponível. Gerando 3 opções com simulação inteligente.',
                    style: TextStyle(fontSize: 12, color: Color(0xFFA16207)),
                  ),
                ),
              ],
            ),
          ),
        Text(
          'Descreva seu pet ideal:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _promptController,
          maxLines: 4,
          maxLength: 200,
          onChanged: (value) => setState(() => _aiPrompt = value.trim()),
          decoration: InputDecoration(
            hintText:
                'Ex: Um dragão fofo com asas de borboleta e olhos brilhantes que brilham no escuro...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark ? const Color(0xFF374151) : Colors.white,
            contentPadding: const EdgeInsets.all(16),
            counterStyle: TextStyle(
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '💡 Sugestões rápidas:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _aiSuggestions.length,
            itemBuilder: (context, index) {
              final suggestion = _aiSuggestions[index];

              return GestureDetector(
                onTap: () {
                  _promptController.text = suggestion;
                  setState(() => _aiPrompt = suggestion);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF4B5563)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _canGenerateAI() ? _handleAIPetGeneration : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isGeneratingAIPet
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text('Gerando 3 opções...'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isAIHealthy ? Icons.auto_awesome : Icons.casino),
                      const SizedBox(width: 8),
                      Text(_isAIHealthy
                          ? 'Gerar 3 Opções'
                          : 'Gerar 3 Variações'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  final List<String> _aiSuggestions = [
    'Um dragão fofo de cristal azul',
    'Gato ninja com poderes mágicos',
    'Unicórnio cósmico das estrelas',
    'Cachorro robótico futurista',
    'Fenix de fogo dourado',
    'Panda samurai guerreiro',
    'Lobo das neves místico',
    'Coruja sábia com óculos',
  ];

  bool _canGenerateAI() {
    final user = ref.read(userProvider);
    return !_isGeneratingAIPet &&
        _aiPrompt.isNotEmpty &&
        (user?.gems ?? 0) >= 10;
  }

  /// ✅ ENHANCED: Gerar 3 opções com IA
  Future<void> _handleAIPetGeneration() async {
    if (_isGeneratingAIPet) return;

    setState(() => _isGeneratingAIPet = true);

    final user = ref.read(userProvider);
    if (user == null) {
      setState(() => _isGeneratingAIPet = false);
      return;
    }

    try {
      // ✅ CONFIGURAR IA com dados do usuário
      AIService.configureAPIKeys(
        stabilityKey: user.aiConfig['stabilityApiKey'],
        openaiKey: user.aiConfig['openaiApiKey'],
      );

      // ✅ GERAR 3 OPÇÕES
      final result = await AIService.generatePetOptions(_aiPrompt);

      if (result != null && result.isValid) {
        setState(() {
          _aiGenerationResult = result;
          _isGeneratingAIPet = false;
          _currentStep = 3; // ✅ IR PARA STEP DE SELEÇÃO
        });

        print('✅ 3 opções geradas com sucesso!');
      } else {
        throw Exception('Falha na geração de opções');
      }
    } catch (e) {
      print('❌ Erro na geração: $e');
      if (mounted) {
        setState(() => _isGeneratingAIPet = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro na geração: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  // ✅ RESTO DOS MÉTODOS EXISTENTES (buildPetSelection, etc.)
  Widget _buildPetSelection() {
    final user = ref.watch(userProvider);
    final pets =
        _selectedType == 'solo' ? Constants.basicPets : Constants.collabPets;

    return GridView.builder(
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
            : true;

        return _buildPetCard(petData, canAfford);
      },
    );
  }

  Widget _buildPetCard(Map<String, dynamic> petData, bool canAfford) {
    final isDark = ref.watch(themeProvider);

    return GestureDetector(
      onTap: canAfford ? () => _adoptPet(petData) : null,
      child: Container(
        padding: const EdgeInsets.all(6),
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              flex: 3,
              child: FittedBox(
                child: Text(
                  petData['emoji'],
                  style: TextStyle(
                    fontSize: 24,
                    color: canAfford ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Text(
                petData['name'],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: canAfford
                      ? (isDark ? Colors.white : const Color(0xFF1F2937))
                      : const Color(0xFF9CA3AF),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              flex: 1,
              child: Text(
                petData['rarity'],
                style: TextStyle(
                  fontSize: 8,
                  color: canAfford
                      ? (isDark
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF6B7280))
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
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

  // ✅ RESTO DOS MÉTODOS EXISTENTES (adoptPet, handleCollabAdoption, etc.)
  Future<void> _adoptPet(Map<String, dynamic> petData) async {
    final petNotifier = ref.read(petProvider.notifier);
    final userNotifier = ref.read(userProvider.notifier);
    final user = ref.read(userProvider);

    if (user == null) return;

    if (_selectedType == 'solo') {
      if (user.coins >= (petData['cost'] as int)) {
        try {
          await userNotifier.updateCoins(user.coins - (petData['cost'] as int));

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
            isCollab: false,
            isUnique: false,
            identityRevealed: false,
            canInteract: true,
            accessories: [],
            lastCared: DateTime.now(),
            adoptedAt: DateTime.now(),
          );

          await petNotifier.addPet(newPet);

          final feedNotifier = ref.read(feedProvider.notifier);
          feedNotifier.addAdoptionPost(user, newPet.name, newPet.id);

          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 ${petData['name']} adotado com sucesso!'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
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
        }
      }
    } else {
      await _handleCollabAdoption(petData);
    }
  }

  Future<void> _handleCollabAdoption(Map<String, dynamic> petData) async {
    final user = ref.read(userProvider);

    if (petData['hasMatch'] == true) {
      final petNotifier = ref.read(petProvider.notifier);

      final newPet = PetModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: petData['name'],
        emoji: petData['emoji'],
        rarity: petData['rarity'],
        category: petData['category'],
        type: 'collab',
        ownerId: user!.id,
        partnerId: 'partner_${DateTime.now().millisecondsSinceEpoch}',
        partnerAvatar: _generateRandomAvatar(),
        level: 1,
        xp: 0,
        happiness: 50,
        hunger: 50,
        energy: 50,
        health: 80,
        revealLevel: 5,
        isCollab: true,
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
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '🎉 Match encontrado! Vocês adotaram ${petData['name']}!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
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
    }
  }

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
}
