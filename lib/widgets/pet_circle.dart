import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/models/pet_model.dart';
import 'package:petverse/providers/theme_provider.dart';
import 'package:petverse/widgets/circular_progress.dart';
import 'package:petverse/widgets/pet_actions_sheet.dart';

class PetCircle extends ConsumerStatefulWidget {
  final PetModel pet;

  const PetCircle({super.key, required this.pet});

  @override
  ConsumerState<PetCircle> createState() => _PetCircleState();
}

class _PetCircleState extends ConsumerState<PetCircle>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _bounceController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _bounceAnimation;
  // bool _showActions = false; // Não é mais necessário para controlar a exibição direta
  String _currentMood = 'happy';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _updateMood();
  }

  void _setupAnimations() {
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _breathingController.repeat(reverse: true);
  }

  void _updateMood() {
    final avgStats = (widget.pet.happiness +
            widget.pet.hunger +
            widget.pet.energy +
            widget.pet.health) /
        4;
    if (avgStats >= 80) {
      _currentMood = 'excited';
    } else if (avgStats >= 60) {
      _currentMood = 'happy';
    } else if (avgStats >= 40) {
      _currentMood = 'neutral';
    } else {
      _currentMood = 'sad';
    }
  }

  @override
  void didUpdateWidget(PetCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pet != widget.pet) {
      _updateMood();
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Color _getStatColor(int value) {
    if (value >= 80) return const Color(0xFF10B981);
    if (value >= 60) return const Color(0xFFFBBF24);
    if (value >= 40) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    return Stack(
      children: [
        // ✅ CORREÇÃO: SafeArea para evitar cortes + padding ajustado
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16), // ✅ Padding reduzido
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20), // ✅ Espaço superior

                // Pet Circle with Progress Ring
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // XP Progress Ring
                    CircularProgress(
                      progress: (widget.pet.xp % 100).toDouble(),
                      size: 220, // ✅ Tamanho reduzido para evitar overflow
                      strokeWidth: 6,
                      glowing: _currentMood == 'excited',
                    ),

                    // ✅ CORREÇÃO: Pet Container com GestureDetector funcional
                    AnimatedBuilder(
                      animation: _breathingAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _breathingAnimation.value,
                          child: GestureDetector(
                            onTap: () {
                              _bounceController.forward().then((_) {
                                _bounceController.reset();
                              });
                              // ✅ Abrir PetActionsSheet como um modal
                              _openPetActionsSheet(context, ref, widget.pet);
                              print('✅ Abrindo ações para ${widget.pet.name}');
                            },
                            child: AnimatedBuilder(
                              animation: _bounceAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _bounceAnimation.value,
                                  child: Container(
                                    width: 180, // ✅ Tamanho ajustado
                                    height: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: isDark
                                            ? [
                                                const Color(0xFF374151),
                                                const Color(0xFF1F2937)
                                              ]
                                            : [
                                                Colors.white,
                                                const Color(0xFFF8FAFC)
                                              ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _currentMood == 'excited'
                                              ? const Color(0xFF8B5CF6)
                                                  .withOpacity(0.3)
                                              : Colors.black.withOpacity(0.1),
                                          blurRadius: _currentMood == 'excited'
                                              ? 20
                                              : 10,
                                          spreadRadius:
                                              _currentMood == 'excited' ? 5 : 0,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // ✅ CORREÇÃO: Container para emoji evitar overflow
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              widget.pet.isUnique
                                                  ? '✨'
                                                  : widget.pet.emoji,
                                              style: TextStyle(
                                                fontSize:
                                                    64, // ✅ Tamanho controlado
                                                shadows: _currentMood ==
                                                        'excited'
                                                    ? [
                                                        Shadow(
                                                          color: const Color(
                                                                  0xFF8B5CF6)
                                                              .withOpacity(0.5),
                                                          blurRadius: 10,
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          // Acessórios
                                          if (widget.pet.accessories.isNotEmpty)
                                            Text(
                                              widget
                                                  .pet.accessories.first.emoji,
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    // Level Badge
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 36, // ✅ Tamanho ajustado
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${widget.pet.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ✅ CORREÇÃO: Collaboration Avatars MAIORES
                    if (widget.pet.isCollab) ...[
                      Positioned(
                        bottom: 15,
                        left: 15,
                        child: _buildAvatarBadge(widget.pet.ownerId, true),
                      ),
                      Positioned(
                        bottom: 15,
                        right: 15,
                        child: _buildAvatarBadge(
                          widget.pet.identityRevealed
                              ? widget.pet.partnerAvatar ?? '❓'
                              : '❓',
                          false,
                        ),
                      ),
                    ],

                    // Mood indicator
                    Positioned(
                      bottom: -15, // ✅ Posição ajustada
                      child: _buildMoodIndicator(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Pet Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1F2937).withOpacity(0.9)
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${widget.pet.name} - Nível ${widget.pet.level}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bolt,
                              size: 16, color: Color(0xFF8B5CF6)),
                          const SizedBox(width: 4),
                          Text(
                            'XP: ${widget.pet.xp % 100}/100',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      if (widget.pet.isCollab && !widget.pet.identityRevealed)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.visibility,
                                  size: 14, color: Color(0xFF6B7280)),
                              const SizedBox(width: 4),
                              Text(
                                'Identidade revelada no nível ${widget.pet.revealLevel}',
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
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ CORREÇÃO: Stats Grid compacto
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1F2937).withOpacity(0.9)
                        : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildStatColumn(
                          '😊', 'Felicidade', widget.pet.happiness, isDark),
                      _buildStatColumn('🍖', 'Fome', widget.pet.hunger, isDark),
                      _buildStatColumn(
                          '⚡', 'Energia', widget.pet.energy, isDark),
                      _buildStatColumn(
                          '❤️', 'Saúde', widget.pet.health, isDark),
                    ],
                  ),
                ),

                const SizedBox(height: 20), // ✅ Espaço inferior
              ],
            ),
          ),
        ),

        // ✅ CORREÇÃO: BottomSheet sobreposto
        // PetActionsSheet agora é exibido via showModalBottomSheet
      ],
    );
  }

  // ✅ CORREÇÃO: Avatar Badge MAIOR
  Widget _buildAvatarBadge(String avatar, bool isUser) {
    return Container(
      width: 44, // ✅ Tamanho aumentado de 32 para 44
      height: 44,
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3), // ✅ Borda maior
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          avatar,
          style: const TextStyle(fontSize: 22), // ✅ Fonte maior
        ),
      ),
    );
  }

  Widget _buildMoodIndicator() {
    String moodEmoji;
    switch (_currentMood) {
      case 'excited':
        moodEmoji = '🎉';
        break;
      case 'happy':
        moodEmoji = '😊';
        break;
      case 'neutral':
        moodEmoji = '😐';
        break;
      case 'sad':
        moodEmoji = '😢';
        break;
      default:
        moodEmoji = '😊';
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Text(
          moodEmoji,
          key: ValueKey(moodEmoji),
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String emoji, String label, int value, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji,
              style: const TextStyle(fontSize: 18)), // ✅ Tamanho ajustado
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 6, // ✅ Altura reduzida
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: _getStatColor(value),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NOVO MÉTODO: Para abrir o PetActionsSheet como um modal
  void _openPetActionsSheet(BuildContext context, WidgetRef ref, PetModel pet) {
    final isDark = ref.watch(themeProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bContext) {
        return Container(
          // Ajuste a altura conforme necessário, pode ser uma fração da tela
          // ou usar Wrap para se ajustar ao conteúdo.
          // Para PetActionsSheet, que pode ter bastante conteúdo, uma fração maior é melhor.
          height:
              MediaQuery.of(bContext).size.height * 0.75, // Exemplo de altura
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: PetActionsSheet(pet: pet),
        );
      },
    );
  }
}