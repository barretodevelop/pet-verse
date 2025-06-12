import 'package:flutter/material.dart' hide BottomSheet;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/app_notifier.dart';
import '../../data/mock_data.dart';
import '../../models/pet.dart';
import 'bottom_sheet.dart'; // Para LucideIcons

class AdoptionFlowSheet extends ConsumerStatefulWidget {
  final bool show;
  final VoidCallback onClose;
  final VoidCallback onAIGenerationRequest; // Callback para abrir o sheet de IA

  const AdoptionFlowSheet({
    super.key,
    required this.show,
    required this.onClose,
    required this.onAIGenerationRequest,
  });

  @override
  ConsumerState<AdoptionFlowSheet> createState() => _AdoptionFlowSheetState();
}

class _AdoptionFlowSheetState extends ConsumerState<AdoptionFlowSheet> {
  String? _adoptionType; // 'solo' ou 'collab'
  int _currentStep = 0; // 0: Tipo de Adoção, 1: Lista de Pets

  @override
  void didUpdateWidget(covariant AdoptionFlowSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      // Reseta o estado quando a folha é mostrada
      setState(() {
        _currentStep = 0;
        _adoptionType = null;
      });
    }
  }

  // Função para filtrar pets que já foram adotados, devolvidos ou morreram
  List<Pet> _getAvailablePets(
      List<Pet> allPets, List<Pet> ownedPets, List<Pet> deadPets, List<Pet> returnedPets) {
    return allPets.where((pet) {
      final isOwned = ownedPets.any((p) => p.name == pet.name && p.emoji == pet.emoji);
      final isDead = deadPets.any((p) => p.name == pet.name && p.emoji == pet.emoji);
      final isReturned = returnedPets.any((p) => p.name == pet.name && p.emoji == pet.emoji);
      return !isOwned && !isDead && !isReturned;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appServiceProvider);
    final appService = ref.read(appServiceProvider.notifier);
    final isDark = appState.isDark;
    final coins = appState.coins;
    final pets = appState.pets;
    final deadPets = appState.deadPets;
    final returnedPets = appState.returnedPets;
    final hasSoloPet = appService.hasSoloPet; // Usa o getter do AppService

    return AppBottomSheet(
      show: widget.show,
      onClose: widget.onClose,
      title: _currentStep == 0 ? 'Tipo de Adoção' : 'Escolha seu Pet',
      fullHeight: true,
      children: IndexedStack(
        // Usa IndexedStack para mostrar as etapas
        index: _currentStep,
        children: [
          // Step 0: Tipo de Adoção
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Botão Pet Solo
              ElevatedButton(
                onPressed: hasSoloPet
                    ? null
                    : () {
                        setState(() {
                          _adoptionType = 'solo';
                          _currentStep = 1;
                        });
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.white, // Corrected
                  foregroundColor: isDark ? Colors.white : Colors.grey.shade800, // Corrected
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  padding: const EdgeInsets.all(24.0),
                  elevation: 4,
                ).copyWith(
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return isDark ? Colors.grey.shade700 : Colors.grey.shade200; // Corrected
                      }
                      return isDark ? Colors.grey.shade800 : Colors.white; // Corrected
                    },
                  ),
                  foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.disabled)) {
                        return isDark ? Colors.grey.shade500 : Colors.grey.shade500; // Corrected
                      }
                      return isDark ? Colors.white : Colors.grey.shade800; // Corrected
                    },
                  ),
                ),
                child: Column(
                  children: [
                    const Text('🐕', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    const Text(
                      'Pet Solo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Cuide sozinho do seu amigo!',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, // Corrected
                      ),
                    ),
                    if (hasSoloPet)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Você já tem um pet solo',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Botão Pet Colaborativo
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _adoptionType = 'collab';
                    _currentStep = 1;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.white, // Corrected
                  foregroundColor: isDark ? Colors.white : Colors.grey.shade800, // Corrected
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  padding: const EdgeInsets.all(24.0),
                  elevation: 4,
                ),
                child: Column(
                  children: [
                    const Text('🤝', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    const Text(
                      'Pet Colaborativo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Adote um pet com um parceiro!',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, // Corrected
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Botão Pet Único com IA
              ElevatedButton(
                onPressed: () {
                  widget.onAIGenerationRequest(); // Chama o callback para abrir a folha de IA
                  widget.onClose(); // Fecha esta folha de adoção
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade50,
                  foregroundColor: Colors.purple.shade700, // Corrected
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                  padding: const EdgeInsets.all(24.0),
                  elevation: 4,
                ),
                child: Column(
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text(
                      'Gerar Pet Único com IA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.purple.shade700, // Corrected
                      ),
                    ),
                    Text(
                      'Crie um pet personalizado por IA (10 gemas)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.gem, size: 16, color: Colors.purple.shade500), // Corrected
                        const SizedBox(width: 4),
                        Text(
                          'Custo: 10 gemas',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700, // Corrected
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Step 1: Lista de Pets
          Column(
            children: [
              Expanded(
                child: Builder(
                  // Usar Builder para acessar o contexto e ref para obter pets
                  builder: (context) {
                    final List<Pet> availablePets = _getAvailablePets(
                      _adoptionType == 'solo' ? BASIC_PETS : COLLAB_PETS,
                      pets,
                      deadPets,
                      returnedPets,
                    );

                    if (availablePets.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '😔',
                              style: TextStyle(fontSize: 64),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Todos os pets desta categoria foram adotados ou não estão mais disponíveis.',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600, // Corrected
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12.0,
                        mainAxisSpacing: 12.0,
                        childAspectRatio: 0.75, // Ajuste para cards de pets
                      ),
                      itemCount: availablePets.length,
                      itemBuilder: (context, index) {
                        final pet = availablePets[index];
                        final canAfford = _adoptionType == 'solo' ? coins >= (pet.cost ?? 0) : true;

                        return Card(
                          color: isDark ? Colors.grey.shade800 : Colors.white, // Corrected
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                            side: BorderSide(
                              color:
                                  isDark ? Colors.grey.shade700 : Colors.grey.shade200, // Corrected
                              width: 2.0,
                            ),
                          ),
                          child: InkWell(
                            // Usa InkWell para o efeito de clique
                            borderRadius: BorderRadius.circular(16.0),
                            onTap: canAfford
                                ? () {
                                    appService.addPet(pet, _adoptionType!);
                                    widget.onClose(); // Fecha a folha ao adotar
                                  }
                                : null,
                            child: Opacity(
                              opacity: canAfford ? 1.0 : 0.5,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(pet.emoji, style: const TextStyle(fontSize: 32)),
                                    Text(
                                      pet.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.grey.shade800, // Corrected
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      pet.rarity,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600, // Corrected
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (_adoptionType == 'solo')
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(LucideIcons.coins,
                                              size: 14, color: Colors.yellow.shade500), // Corrected
                                          const SizedBox(width: 4),
                                          Text(
                                            '${pet.cost ?? 0}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.grey.shade800, // Corrected
                                            ),
                                          ),
                                        ],
                                      )
                                    else if (_adoptionType == 'collab' &&
                                        pet.canInteract) // hasMatch
                                      Text(
                                        '✅ Match disponível',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.green.shade600, // Corrected
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    else if (_adoptionType == 'collab' &&
                                        !pet.canInteract) // no hasMatch
                                      Text(
                                        '⏳ Sem match',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.orange.shade600, // Corrected
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (_currentStep == 1) // Botão de Voltar para a seleção de tipo
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 0;
                        _adoptionType = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.grey.shade700 : Colors.grey.shade100, // Corrected
                      foregroundColor:
                          isDark ? Colors.grey.shade300 : Colors.grey.shade700, // Corrected
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      elevation: 0,
                    ),
                    child: const Text('Voltar', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
