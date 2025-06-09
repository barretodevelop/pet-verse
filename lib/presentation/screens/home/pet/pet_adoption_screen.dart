// File: lib/presentation/screens/home/pet/pet_adoption_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/config/theme_config.dart';
import 'package:petverse/core/utils/helpers.dart';
import 'package:petverse/core/widgets/error_widgets.dart';
import 'package:petverse/presentation/providers/dependencies_provider.dart';
import 'package:petverse/presentation/providers/pet_provider.dart';
import 'package:petverse/presentation/providers/user_provider.dart';
import 'package:petverse/presentation/widgets/animations/floating_animation.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context, isDark),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(petGameProvider.notifier).loadAvailablePets();
        },
        child: _buildBody(petGameState, userGameData, isDark),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      foregroundColor: isDark ? Colors.white : Colors.black,
      title: Text(
        'Pet Sanctuary',
        style: TextStyle(
          fontSize: ThemeConfig.fontSize20,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: ThemeConfig.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on, size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                '${ref.watch(userGameDataProvider).user?.coins ?? 0}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(PetGameState petGameState, UserGameDataState userGameData, bool isDark) {
    if (petGameState.isLoading || _isLoading) {
      return _buildLoadingState(isDark);
    }

    if (petGameState.hasError) {
      return AppErrorWidget(
        message: petGameState.errorMessage ?? 'Erro ao carregar pets',
        onRetry: () => ref.read(petGameProvider.notifier).loadAvailablePets(),
      );
    }

    if (petGameState.availablePets.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Column(
      children: [
        _buildGradientHeader(userGameData, isDark)
            .animate()
            .slideY(
              begin: -1.0,
              end: 0.0,
              duration: 800.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(
              duration: 800.ms,
              curve: Curves.easeOut,
            ),
        Expanded(
          child: _buildAnimatedPetsList(petGameState.availablePets, isDark),
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingAnimation(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: ThemeConfig.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ThemeConfig.primaryColor.withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.pets,
                size: 35,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Encontrando pets especiais...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return EmptyStateWidget(
      title: 'Santuário Vazio',
      subtitle: 'Novos pets chegam em breve!\nVolte mais tarde para descobrir novos amigos.',
      icon: Icons.pets_outlined,
      onAction: () => ref.read(petGameProvider.notifier).loadAvailablePets(),
      actionText: 'Atualizar',
    );
  }

  Widget _buildGradientHeader(UserGameDataState userGameData, bool isDark) {
    final userCoins = userGameData.user?.coins ?? 0;
    final canAdopt = userCoins >= 100;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  ThemeConfig.primaryColor.withOpacity(0.8),
                  ThemeConfig.accentColor.withOpacity(0.6),
                  ThemeConfig.primaryColor.withOpacity(0.4),
                ]
              : [
                  ThemeConfig.primaryColor,
                  ThemeConfig.accentColor,
                  ThemeConfig.primaryColor.withOpacity(0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Centro de Adoção Premium',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Encontre seu companheiro ideal',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        canAdopt ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    canAdopt ? Icons.check_circle : Icons.info_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seu saldo: $userCoins moedas',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        canAdopt
                            ? 'Pronto para adotar! (Custo: 100 moedas)'
                            : 'Você precisa de ${100 - userCoins} moedas para adotar',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPetsList(List pets, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];

        return _buildPetCard(pet, index, isDark)
            .animate(delay: Duration(milliseconds: index * 100))
            .slideX(
              begin: 1.0,
              end: 0.0,
              duration: 600.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(
              duration: 600.ms,
              curve: Curves.easeOut,
            );
      },
    );
  }

  Widget _buildPetCard(dynamic pet, int index, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showPetBottomSheet(context, pet, isDark),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1E1E1E),
                        const Color(0xFF2A2A2A),
                      ]
                    : [
                        Colors.white,
                        Colors.grey[50]!,
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Pet Avatar com gradiente
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ThemeConfig.primaryColor.withOpacity(0.2),
                        ThemeConfig.accentColor.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: ThemeConfig.primaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: pet.imageUrl.isNotEmpty
                        ? Image.network(
                            pet.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.pets,
                              size: 30,
                              color: ThemeConfig.primaryColor,
                            ),
                          )
                        : Icon(
                            Icons.pets,
                            size: 30,
                            color: ThemeConfig.primaryColor,
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // Pet Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              pet.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ThemeConfig.accentColor.withOpacity(0.3),
                                  ThemeConfig.accentColor.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Nv.${pet.level}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: ThemeConfig.accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        pet.type,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Mini Stats
                      Row(
                        children: [
                          _buildMiniStat('❤️', pet.happiness, Colors.red),
                          const SizedBox(width: 12),
                          _buildMiniStat('⚡', pet.energy, Colors.orange),
                          const SizedBox(width: 12),
                          _buildMiniStat('🍖', pet.hunger, Colors.brown),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: isDark
                                ? Colors.white.withOpacity(0.5)
                                : Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String emoji, int value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 2),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showPetBottomSheet(BuildContext context, dynamic pet, bool isDark) {
    final userGameData = ref.watch(userGameDataProvider);
    final userCoins = userGameData.user?.coins ?? 0;
    final canAdopt = userCoins >= 100;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header com gradiente
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ThemeConfig.primaryColor,
                          ThemeConfig.accentColor,
                          ThemeConfig.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeConfig.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative elements
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -15,
                          left: -15,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                        // Pet image
                        Center(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 3,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(21),
                              child: pet.imageUrl.isNotEmpty
                                  ? Image.network(
                                      pet.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.pets,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.pets,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                            ),
                          )
                              .animate()
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1.0, 1.0),
                                duration: 800.ms,
                                curve: Curves.elasticOut,
                              )
                              .fadeIn(duration: 600.ms),
                        ),

                        // Level badge
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              'Nível ${pet.level}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                              .animate(delay: 400.ms)
                              .slideX(
                                begin: -1.0,
                                end: 0.0,
                                duration: 600.ms,
                                curve: Curves.easeOutBack,
                              )
                              .fadeIn(duration: 400.ms),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .slideY(
                        begin: -0.5,
                        end: 0.0,
                        duration: 700.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 500.ms),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pet name and type
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  pet.name,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        ThemeConfig.primaryColor.withOpacity(0.2),
                                        ThemeConfig.accentColor.withOpacity(0.2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: ThemeConfig.primaryColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    pet.type,
                                    style: TextStyle(
                                      color: ThemeConfig.primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate(delay: 600.ms).fadeIn(duration: 600.ms).slideY(
                                begin: 0.3,
                                end: 0.0,
                                duration: 600.ms,
                                curve: Curves.easeOut,
                              ),

                          const SizedBox(height: 32),

                          // Stats section
                          Text(
                            'Estatísticas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ).animate(delay: 800.ms).fadeIn(duration: 500.ms).slideX(
                                begin: -0.3,
                                end: 0.0,
                                duration: 500.ms,
                                curve: Curves.easeOut,
                              ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        Colors.white.withOpacity(0.05),
                                        Colors.white.withOpacity(0.02),
                                      ]
                                    : [
                                        Colors.grey[50]!,
                                        Colors.grey[25]!,
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withOpacity(0.1)
                                    : Colors.black.withOpacity(0.05),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildDetailedStat(
                                            '❤️', 'Felicidade', pet.happiness, Colors.red, isDark)),
                                    const SizedBox(width: 16),
                                    Expanded(
                                        child: _buildDetailedStat(
                                            '⚡', 'Energia', pet.energy, Colors.orange, isDark)),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildDetailedStat(
                                            '🍖', 'Fome', pet.hunger, Colors.brown, isDark)),
                                    const SizedBox(width: 16),
                                    Expanded(
                                        child: _buildDetailedStat('🏆', 'Nível', pet.level,
                                            ThemeConfig.accentColor, isDark,
                                            isLevel: true)),
                                  ],
                                ),
                              ],
                            ),
                          )
                              .animate(delay: 900.ms)
                              .fadeIn(duration: 600.ms)
                              .slideY(
                                begin: 0.3,
                                end: 0.0,
                                duration: 600.ms,
                                curve: Curves.easeOut,
                              )
                              .shimmer(
                                delay: 1200.ms,
                                duration: 1000.ms,
                                color: ThemeConfig.primaryColor.withOpacity(0.1),
                              ),

                          const SizedBox(height: 24),

                          // Description
                          Text(
                            'Sobre este pet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ).animate(delay: 1100.ms).fadeIn(duration: 500.ms).slideX(
                                begin: -0.3,
                                end: 0.0,
                                duration: 500.ms,
                                curve: Curves.easeOut,
                              ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        ThemeConfig.primaryColor.withOpacity(0.1),
                                        ThemeConfig.accentColor.withOpacity(0.05),
                                      ]
                                    : [
                                        ThemeConfig.primaryColor.withOpacity(0.05),
                                        ThemeConfig.accentColor.withOpacity(0.05),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: ThemeConfig.primaryColor.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              pet.description,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                          ).animate(delay: 1200.ms).fadeIn(duration: 600.ms).slideY(
                                begin: 0.3,
                                end: 0.0,
                                duration: 600.ms,
                                curve: Curves.easeOut,
                              ),

                          const SizedBox(height: 32),

                          // Adoption button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: canAdopt
                                  ? () {
                                      Navigator.of(context).pop();
                                      _adoptPet(context, pet);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canAdopt
                                    ? null
                                    : (isDark ? Colors.grey[800] : Colors.grey[300]),
                                foregroundColor: canAdopt ? Colors.white : Colors.grey[500],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: canAdopt ? 8 : 0,
                              ),
                              child: Container(
                                decoration: canAdopt
                                    ? BoxDecoration(
                                        gradient: ThemeConfig.primaryGradient,
                                        borderRadius: BorderRadius.circular(16),
                                      )
                                    : null,
                                height: 56,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        canAdopt ? Icons.favorite : Icons.lock,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        canAdopt ? 'Adotar por 100 moedas' : 'Moedas insuficientes',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                              .animate(delay: 1400.ms)
                              .fadeIn(duration: 600.ms)
                              .slideY(
                                begin: 0.5,
                                end: 0.0,
                                duration: 600.ms,
                                curve: Curves.easeOutBack,
                              )
                              .then(delay: 200.ms)
                              .shimmer(
                                duration: canAdopt ? 1500.ms : 0.ms,
                                color: Colors.white.withOpacity(0.3),
                              ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailedStat(String emoji, String label, int value, Color color, bool isDark,
      {bool isLevel = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!isLevel) ...[
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: (value / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
        Text(
          isLevel ? '$value' : '$value%',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _adoptPet(BuildContext context, dynamic pet) async {
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
          'Falha ao adotar pet: $e',
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

// /// Pet adoption screen for adopting new pets
// class PetAdoptionScreen extends ConsumerStatefulWidget {
//   const PetAdoptionScreen({super.key});

//   @override
//   ConsumerState<PetAdoptionScreen> createState() => _PetAdoptionScreenState();
// }

// class _PetAdoptionScreenState extends ConsumerState<PetAdoptionScreen> {
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(petGameProvider.notifier).loadAvailablePets();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final petGameState = ref.watch(petGameProvider);
//     final userGameData = ref.watch(userGameDataProvider);

//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: () async {
//           await ref.read(petGameProvider.notifier).loadAvailablePets();
//         },
//         child: _buildBody(petGameState, userGameData),
//       ),
//     );
//   }

//   Widget _buildBody(PetGameState petGameState, UserGameDataState userGameData) {
//     if (petGameState.isLoading || _isLoading) {
//       return const Center(
//         child: AppLoadingIndicator(),
//       );
//     }

//     if (petGameState.hasError) {
//       return AppErrorWidget(
//         message: petGameState.errorMessage ?? 'Failed to load available pets',
//         onRetry: () => ref.read(petGameProvider.notifier).loadAvailablePets(),
//       );
//     }

//     if (petGameState.availablePets.isEmpty) {
//       return EmptyStateWidget(
//         title: 'No Pets Available',
//         subtitle: 'Check back later for new pets to adopt!',
//         icon: Icons.pets_outlined,
//         onAction: () => ref.read(petGameProvider.notifier).loadAvailablePets(),
//         actionText: 'Refresh',
//       );
//     }

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(ThemeConfig.spacing16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header section
//           SlideFadeAnimation(
//             duration: const Duration(milliseconds: 600),
//             child: _buildHeader(context, userGameData),
//           ),

//           const SizedBox(height: ThemeConfig.spacing24),

//           // Available pets grid
//           SlideFadeAnimation(
//             duration: const Duration(milliseconds: 700),
//             child: _buildPetsGrid(context, petGameState.availablePets),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context, UserGameDataState userGameData) {
//     return Card(
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(ThemeConfig.spacing20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
//           gradient: ThemeConfig.secondaryGradient,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Adopt a Pet! 🐾',
//                         style: TextStyle(
//                           fontSize: ThemeConfig.fontSize28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: ThemeConfig.spacing8),
//                       Text(
//                         'Choose your perfect virtual companion',
//                         style: TextStyle(
//                           fontSize: ThemeConfig.fontSize16,
//                           color: Colors.white.withOpacity(0.9),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(ThemeConfig.spacing16),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
//                   ),
//                   child: const Text(
//                     '🏠',
//                     style: TextStyle(fontSize: ThemeConfig.fontSize32),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: ThemeConfig.spacing16),
//             Container(
//               padding: const EdgeInsets.all(ThemeConfig.spacing12),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.info_outline,
//                     color: Colors.white,
//                     size: ThemeConfig.iconSize16,
//                   ),
//                   const SizedBox(width: ThemeConfig.spacing8),
//                   Expanded(
//                     child: Text(
//                       'Adoption costs 100 coins. Your current balance: ${userGameData.user?.coins ?? 0} coins',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: ThemeConfig.fontSize14,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPetsGrid(BuildContext context, List pets) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Available Pets',
//           style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//         ),
//         const SizedBox(height: ThemeConfig.spacing16),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             childAspectRatio: 0.8,
//             crossAxisSpacing: ThemeConfig.spacing12,
//             mainAxisSpacing: ThemeConfig.spacing12,
//           ),
//           itemCount: pets.length,
//           itemBuilder: (context, index) {
//             final pet = pets[index];
//             return SlideFadeAnimation(
//               duration: Duration(milliseconds: 800 + (index * 100)),
//               child: _buildPetCard(context, pet),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildPetCard(BuildContext context, pet) {
//     return Card(
//       child: InkWell(
//         onTap: () => _showAdoptionDialog(context, pet),
//         borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
//         child: Padding(
//           padding: const EdgeInsets.all(ThemeConfig.spacing16),
//           child: Column(
//             children: [
//               // Pet image
//               Expanded(
//                 child: Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: ThemeConfig.primaryColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
//                   ),
//                   child: pet.imageUrl.isNotEmpty
//                       ? ClipRRect(
//                           borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
//                           child: Image.network(
//                             pet.imageUrl,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) => const Icon(
//                               Icons.pets,
//                               size: ThemeConfig.iconSize48,
//                               color: ThemeConfig.primaryColor,
//                             ),
//                           ),
//                         )
//                       : const Icon(
//                           Icons.pets,
//                           size: ThemeConfig.iconSize48,
//                           color: ThemeConfig.primaryColor,
//                         ),
//                 ),
//               ),

//               const SizedBox(height: ThemeConfig.spacing12),

//               // Pet name
//               Text(
//                 pet.name,
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                 textAlign: TextAlign.center,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),

//               const SizedBox(height: ThemeConfig.spacing4),

//               // Pet type
//               Text(
//                 pet.type,
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                       color: Colors.grey[600],
//                     ),
//                 textAlign: TextAlign.center,
//               ),

//               const SizedBox(height: ThemeConfig.spacing12),

//               // Adopt button
//               SizedBox(
//                 width: double.infinity,
//                 child: BounceAnimation(
//                   child: ElevatedButton(
//                     onPressed: () => _showAdoptionDialog(context, pet),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: ThemeConfig.primaryColor,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         vertical: ThemeConfig.spacing8,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
//                       ),
//                     ),
//                     child: const Text(
//                       'Adopt',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: ThemeConfig.fontSize14,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showAdoptionDialog(BuildContext context, pet) {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(ThemeConfig.borderRadius16),
//           ),
//           title: Row(
//             children: [
//               const Icon(Icons.pets, color: ThemeConfig.primaryColor),
//               const SizedBox(width: ThemeConfig.spacing8),
//               Text('Adopt ${pet.name}?'),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Pet image
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   color: ThemeConfig.primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
//                 ),
//                 child: pet.imageUrl.isNotEmpty
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(ThemeConfig.borderRadius12),
//                         child: Image.network(
//                           pet.imageUrl,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) => const Icon(
//                             Icons.pets,
//                             size: ThemeConfig.iconSize48,
//                             color: ThemeConfig.primaryColor,
//                           ),
//                         ),
//                       )
//                     : const Icon(
//                         Icons.pets,
//                         size: ThemeConfig.iconSize48,
//                         color: ThemeConfig.primaryColor,
//                       ),
//               ),

//               const SizedBox(height: ThemeConfig.spacing16),

//               // Pet details
//               _buildDetailRow('Type', pet.type),
//               _buildDetailRow('Happiness', '${pet.happiness}/100'),
//               _buildDetailRow('Hunger', '${pet.hunger}/100'),
//               _buildDetailRow('Energy', '${pet.energy}/100'),

//               const SizedBox(height: ThemeConfig.spacing16),

//               // Description
//               Container(
//                 padding: const EdgeInsets.all(ThemeConfig.spacing12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
//                 ),
//                 child: Text(
//                   pet.description,
//                   style: Theme.of(context).textTheme.bodySmall,
//                   textAlign: TextAlign.center,
//                 ),
//               ),

//               const SizedBox(height: ThemeConfig.spacing16),

//               // Cost information
//               Container(
//                 padding: const EdgeInsets.all(ThemeConfig.spacing12),
//                 decoration: BoxDecoration(
//                   color: ThemeConfig.accentColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(ThemeConfig.borderRadius8),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(
//                       Icons.monetization_on,
//                       color: ThemeConfig.accentColor,
//                       size: ThemeConfig.iconSize20,
//                     ),
//                     SizedBox(width: ThemeConfig.spacing8),
//                     Text(
//                       'Adoption Cost: 100 coins',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: ThemeConfig.accentColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(dialogContext).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(dialogContext).pop();
//                 _adoptPet(context, pet);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: ThemeConfig.primaryColor,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('Adopt Now'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: ThemeConfig.spacing2),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontWeight: FontWeight.w500,
//               fontSize: ThemeConfig.fontSize14,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: ThemeConfig.fontSize14,
//               color: Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _adoptPet(BuildContext context, pet) async {
//     setState(() => _isLoading = true);

//     try {
//       final result = await ref.read(petGameProvider.notifier).adoptPet(pet);

//       if (context.mounted) {
//         Helpers.showSnackBar(
//           context,
//           result.message,
//           backgroundColor: result.success ? ThemeConfig.successColor : ThemeConfig.errorColor,
//         );

//         if (result.success) {
//           // Navigate to pet screen
//           ref.read(bottomNavIndexProvider.notifier).state = 2;
//         }
//       }
//     } catch (e) {
//       if (context.mounted) {
//         Helpers.showSnackBar(
//           context,
//           'Failed to adopt pet: $e',
//           backgroundColor: ThemeConfig.errorColor,
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
// }
