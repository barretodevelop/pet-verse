// File: lib/presentation/screens/home/pet/pet_adoption_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/utils/helpers.dart';
import 'package:petverse/core/widgets/error_widgets.dart';
import 'package:petverse/core/widgets/loading_widgets.dart';
import 'package:petverse/presentation/providers/dependencies_provider.dart';
import 'package:petverse/presentation/providers/pet_provider.dart';
import 'package:petverse/presentation/providers/user_provider.dart';
import 'package:petverse/presentation/widgets/animations/bounce_animation.dart';
import 'package:petverse/presentation/widgets/animations/slide_fade_animation.dart';

/// Pet adoption screen for adopting new pets
class PetAdoptionScreen extends ConsumerStatefulWidget {
  const PetAdoptionScreen({super.key});

  @override
  ConsumerState<PetAdoptionScreen> createState() => _PetAdoptionScreenState();
}

class _PetAdoptionScreenState extends ConsumerState<PetAdoptionScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(petGameProvider.notifier).loadAvailablePets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final petGameState = ref.watch(petGameProvider);
    final userGameData = ref.watch(userGameDataProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(petGameProvider.notifier).loadAvailablePets();
        },
        child: _buildBody(petGameState, userGameData),
      ),
    );
  }

  Widget _buildBody(PetGameState petGameState, UserGameDataState userGameData) {
    if (petGameState.isLoading || _isLoading) {
      return const Center(
        child: AppLoadingIndicator(),
      );
    }

    if (petGameState.hasError) {
      return AppErrorWidget(
        message: petGameState.errorMessage ?? 'Failed to load available pets',
        onRetry: () => ref.read(petGameProvider.notifier).loadAvailablePets(),
      );
    }

    if (petGameState.availablePets.isEmpty) {
      return EmptyStateWidget(
        title: 'No Pets Available',
        subtitle: 'Check back later for new pets to adopt!',
        icon: Icons.pets_outlined,
        onAction: () => ref.read(petGameProvider.notifier).loadAvailablePets(),
        actionText: 'Refresh',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(ThemeConfig.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          SlideFadeAnimation(
            duration: const Duration(milliseconds: 600),
            child: _buildHeader(context, userGameData),
          ),

          const SizedBox(height: ThemeConfig.spacing24),

          // Available pets grid
          SlideFadeAnimation(
            duration: const Duration(milliseconds: 700),
            child: _buildPetsGrid(context, petGameState.availablePets),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserGameDataState userGameData) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(ThemeConfig.spacing20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
          gradient: ThemeConfig.secondaryGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adopt a Pet! 🐾',
                        style: TextStyle(
                          fontSize: ThemeConfig.fontSize28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: ThemeConfig.spacing8),
                      Text(
                        'Choose your perfect virtual companion',
                        style: TextStyle(
                          fontSize: ThemeConfig.fontSize16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(ThemeConfig.spacing16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
                  ),
                  child: const Text(
                    '🏠',
                    style: TextStyle(fontSize: ThemeConfig.fontSize32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ThemeConfig.spacing16),
            Container(
              padding: const EdgeInsets.all(ThemeConfig.spacing12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: ThemeConfig.iconSize16,
                  ),
                  const SizedBox(width: ThemeConfig.spacing8),
                  Expanded(
                    child: Text(
                      'Adoption costs 100 coins. Your current balance: ${userGameData.user?.coins ?? 0} coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: ThemeConfig.fontSize14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetsGrid(BuildContext context, List pets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Pets',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: ThemeConfig.spacing16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: ThemeConfig.spacing12,
            mainAxisSpacing: ThemeConfig.spacing12,
          ),
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];
            return SlideFadeAnimation(
              duration: Duration(milliseconds: 800 + (index * 100)),
              child: _buildPetCard(context, pet),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPetCard(BuildContext context, pet) {
    return Card(
      child: InkWell(
        onTap: () => _showAdoptionDialog(context, pet),
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacing16),
          child: Column(
            children: [
              // Pet image
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ThemeConfig.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                  ),
                  child: pet.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                          child: Image.network(
                            pet.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.pets,
                              size: ThemeConfig.iconSize48,
                              color: ThemeConfig.primaryColor,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.pets,
                          size: ThemeConfig.iconSize48,
                          color: ThemeConfig.primaryColor,
                        ),
                ),
              ),

              const SizedBox(height: ThemeConfig.spacing12),

              // Pet name
              Text(
                pet.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: ThemeConfig.spacing4),

              // Pet type
              Text(
                pet.type,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ThemeConfig.spacing12),

              // Adopt button
              SizedBox(
                width: double.infinity,
                child: BounceAnimation(
                  child: ElevatedButton(
                    onPressed: () => _showAdoptionDialog(context, pet),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: ThemeConfig.spacing8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                      ),
                    ),
                    child: const Text(
                      'Adopt',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ThemeConfig.fontSize14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdoptionDialog(BuildContext context, pet) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeConfig.borderRadius16),
          ),
          title: Row(
            children: [
              const Icon(Icons.pets, color: ThemeConfig.primaryColor),
              const SizedBox(width: ThemeConfig.spacing8),
              Text('Adopt ${pet.name}?'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pet image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: ThemeConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
                ),
                child: pet.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
                        child: Image.network(
                          pet.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.pets,
                            size: ThemeConfig.iconSize48,
                            color: ThemeConfig.primaryColor,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.pets,
                        size: ThemeConfig.iconSize48,
                        color: ThemeConfig.primaryColor,
                      ),
              ),

              const SizedBox(height: ThemeConfig.spacing16),

              // Pet details
              _buildDetailRow('Type', pet.type),
              _buildDetailRow('Happiness', '${pet.happiness}/100'),
              _buildDetailRow('Hunger', '${pet.hunger}/100'),
              _buildDetailRow('Energy', '${pet.energy}/100'),

              const SizedBox(height: ThemeConfig.spacing16),

              // Description
              Container(
                padding: const EdgeInsets.all(ThemeConfig.spacing12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                ),
                child: Text(
                  pet.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: ThemeConfig.spacing16),

              // Cost information
              Container(
                padding: const EdgeInsets.all(ThemeConfig.spacing12),
                decoration: BoxDecoration(
                  color: ThemeConfig.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      color: ThemeConfig.accentColor,
                      size: ThemeConfig.iconSize20,
                    ),
                    SizedBox(width: ThemeConfig.spacing8),
                    Text(
                      'Adoption Cost: 100 coins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ThemeConfig.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _adoptPet(context, pet);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Adopt Now'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: ThemeConfig.fontSize14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: ThemeConfig.fontSize14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _adoptPet(BuildContext context, pet) async {
    setState(() => _isLoading = true);

    try {
      final result = await ref.read(petGameProvider.notifier).adoptPet(pet);

      if (context.mounted) {
        Helpers.showSnackBar(
          context,
          result.message,
          backgroundColor: result.success ? ThemeConfig.successColor : ThemeConfig.errorColor,
        );

        if (result.success) {
          // Navigate to pet screen
          ref.read(bottomNavIndexProvider.notifier).state = 2;
        }
      }
    } catch (e) {
      if (context.mounted) {
        Helpers.showSnackBar(
          context,
          'Failed to adopt pet: $e',
          backgroundColor: ThemeConfig.errorColor,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
