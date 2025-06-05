// lib/src/features/adoption/presentation/screens/adopt_new_pet_screen.dart
// REFACTOR - Progress indicators + Feedback visual melhorado + Animações

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/src/core/utils/snackbar_utils.dart';
import 'package:petverse/src/features/adoption/presentation/providers/adoption_providers.dart';
import 'package:petverse/src/features/adoption/presentation/providers/available_pets_provider.dart';
import 'package:petverse/src/features/adoption/presentation/widgets/available_pet_card.dart';

class AdoptNewPetScreen extends ConsumerStatefulWidget {
  const AdoptNewPetScreen({super.key});

  @override
  ConsumerState<AdoptNewPetScreen> createState() => _AdoptNewPetScreenState();
}

class _AdoptNewPetScreenState extends ConsumerState<AdoptNewPetScreen>
    with TickerProviderStateMixin {
  final List<String> _selectedPetIds = [];
  final int _maxSelectionCount = 3;
  bool _isPublicAdoption = true;

  late AnimationController _progressAnimationController;
  late AnimationController _stepAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _stepAnimation;

  @override
  void initState() {
    super.initState();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    _stepAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _stepAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _progressAnimationController.dispose();
    _stepAnimationController.dispose();
    super.dispose();
  }

  void _togglePetSelection(String petId) {
    setState(() {
      if (_selectedPetIds.contains(petId)) {
        _selectedPetIds.remove(petId);
        HapticFeedback.lightImpact();
      } else {
        if (_selectedPetIds.length < _maxSelectionCount) {
          _selectedPetIds.add(petId);
          HapticFeedback.mediumImpact();

          // Animar progress quando atinge o máximo
          if (_selectedPetIds.length == _maxSelectionCount) {
            _stepAnimationController.forward();
            HapticFeedback.heavyImpact();
          }
        } else {
          HapticFeedback.heavyImpact();
          showAppSnackBar(
            context,
            '🐾 Você pode selecionar no máximo $_maxSelectionCount pets.',
            type: SnackBarType.info,
          );
        }
      }
    });

    // Animar progress bar
    final progress = _selectedPetIds.length / _maxSelectionCount;
    _progressAnimationController.animateTo(progress);
  }

  @override
  Widget build(BuildContext context) {
    // Listener para feedback de criação da solicitação
    ref.listen<AsyncValue<String?>>(createAdoptionRequestNotifierProvider,
        (previous, next) {
      next.when(
        data: (friendCode) {
          if (friendCode != null) {
            // Sucesso para convite de amigo
            HapticFeedback.heavyImpact();
            _showSuccessDialog(friendCode);
          } else if (previous is AsyncLoading &&
              next is AsyncData &&
              _isPublicAdoption) {
            // Sucesso para adoção pública
            HapticFeedback.lightImpact();
            showAppSnackBar(
              context,
              '🎉 Sua solicitação foi publicada com sucesso!',
              type: SnackBarType.success,
            );
            _resetAndNavigateBack();
          }
        },
        error: (e, s) {
          HapticFeedback.heavyImpact();
          showAppSnackBar(
            context,
            '❌ Erro ao criar solicitação: ${e.toString()}',
            type: SnackBarType.error,
          );
        },
        loading: () {
          HapticFeedback.selectionClick();
        },
      );
    });

    final availablePetsAsyncValue = ref.watch(availablePetsProvider);
    final isCreating =
        ref.watch(createAdoptionRequestNotifierProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adotar Novo Pet'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Header
          _buildProgressHeader(context),

          // Pet Selection List
          Expanded(
            child: availablePetsAsyncValue.when(
              data: (pets) => _buildPetsList(pets),
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error),
            ),
          ),

          // Selection Options (quando 3 pets selecionados)
          if (_selectedPetIds.length == _maxSelectionCount) ...[
            _buildSelectionOptions(),
          ],
        ],
      ),

      // FAB para confirmar seleção
      floatingActionButton: _selectedPetIds.length == _maxSelectionCount
          ? _buildConfirmationFAB(isCreating)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildProgressHeader(BuildContext context) {
    final progress = _selectedPetIds.length / _maxSelectionCount;
    final isComplete = _selectedPetIds.length == _maxSelectionCount;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isComplete
              ? [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ]
              : [
                  Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.3),
                  Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.1),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e contador
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isComplete
                        ? Icons.check_circle_rounded
                        : Icons.pets_rounded,
                    color: isComplete
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isComplete ? 'Seleção Completa!' : 'Selecione seus Pets',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isComplete
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
              AnimatedBuilder(
                animation: _stepAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale:
                        isComplete ? 1.0 + (_stepAnimation.value * 0.2) : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isComplete
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_selectedPetIds.length}/$_maxSelectionCount',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: isComplete
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _progressAnimation.value,
                      minHeight: 8,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isComplete
                        ? '✓ Perfeito! Agora escolha como prosseguir'
                        : 'Escolha ${_maxSelectionCount - _selectedPetIds.length} pet(s) para continuar',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight:
                              isComplete ? FontWeight.w500 : FontWeight.normal,
                        ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList(List<dynamic> pets) {
    if (pets.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        final isSelected = _selectedPetIds.contains(pet.id);
        final isDisabled =
            !isSelected && _selectedPetIds.length >= _maxSelectionCount;

        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 50)),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isDisabled ? 0.5 : 1.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: AvailablePetCard(
                pet: pet,
                isSelected: isSelected,
                onTap: isDisabled ? () {} : () => _togglePetSelection(pet.id),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Carregando pets disponíveis...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar pets',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum pet disponível',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'No momento não há pets disponíveis para adoção.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionOptions() {
    return AnimatedBuilder(
      animation: _stepAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _stepAnimation.value)),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: _stepAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .secondaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.settings_rounded,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Como deseja prosseguir?',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Opção pública
                  _buildOptionTile(
                    title: 'Publicar para Adoção Anônima',
                    subtitle: 'Sua solicitação aparecerá para outros usuários',
                    icon: Icons.public_rounded,
                    value: true,
                    groupValue: _isPublicAdoption,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _isPublicAdoption = value);
                        HapticFeedback.selectionClick();
                      }
                    },
                  ),

                  const SizedBox(height: 8),

                  // Opção amigo
                  _buildOptionTile(
                    title: 'Convidar um Amigo',
                    subtitle: 'Você receberá um código para compartilhar',
                    icon: Icons.person_add_rounded,
                    value: false,
                    groupValue: _isPublicAdoption,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _isPublicAdoption = value);
                        HapticFeedback.selectionClick();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required bool groupValue,
    required ValueChanged<bool?> onChanged,
  }) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationFAB(bool isCreating) {
    return AnimatedBuilder(
      animation: _stepAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_stepAnimation.value * 0.2),
          child: FloatingActionButton.extended(
            onPressed: isCreating
                ? null
                : () {
                    HapticFeedback.heavyImpact();
                    ref
                        .read(createAdoptionRequestNotifierProvider.notifier)
                        .createRequest(_selectedPetIds,
                            isPublic: _isPublicAdoption);
                  },
            icon: isCreating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(_isPublicAdoption
                    ? Icons.public_rounded
                    : Icons.share_rounded),
            label: Text(
              isCreating
                  ? 'Criando...'
                  : _isPublicAdoption
                      ? 'Publicar Solicitação'
                      : 'Gerar Código',
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        );
      },
    );
  }

  void _showSuccessDialog(String friendCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.celebration_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Solicitação Criada!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Seu código para convidar um amigo:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      friendCode,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                                letterSpacing: 2,
                              ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Compartilhe este código com seu amigo!',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _resetAndNavigateBack();
                },
                child: const Text('Entendi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetAndNavigateBack() {
    setState(() => _selectedPetIds.clear());
    _progressAnimationController.reset();
    _stepAnimationController.reset();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }
}
