import 'dart:async'; // Para Timer
import 'dart:math'; // Para Math.random() e min/max

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Para ícones
import '../../core/app_notifier.dart'; // Para acessar o appServiceProvider
import '../components/ai_pet_generation_sheet.dart';
import '../components/circular_progress.dart';
import '../components/pet_actions_sheet.dart'; // Seu componente CircularProgress

// --- PetTab Principal ---
class PetTab extends ConsumerStatefulWidget {
  const PetTab({super.key});

  @override
  ConsumerState<PetTab> createState() => _PetTabState();
}

class _PetTabState extends ConsumerState<PetTab> {
  bool _showActions = false;
  bool _showAIGeneration = false;
  String _petAnimation = 'breathing'; // 'breathing', 'bounce', 'wiggle'
  String _petMood = 'happy'; // 'excited', 'happy', 'neutral', 'sad'
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _startAnimationTimer();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  // Inicia um timer para mudar a animação e criar partículas aleatoriamente
  void _startAnimationTimer() {
    _animationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return; // Garante que o widget ainda está ativo
      setState(() {
        final random = Random();
        final animations = ['breathing', 'bounce', 'wiggle'];
        _petAnimation = animations[random.nextInt(animations.length)];
      });

      // Acessando activePet via notifier diretamente
      final activePet = ref.read(appServiceProvider.notifier).activePet;
      if (activePet != null) {
        final avgStats =
            (activePet.happiness + activePet.hunger + activePet.energy + activePet.health) / 4;
        if (avgStats >= 70 && Random().nextDouble() < 0.3) {
          ref.read(appServiceProvider.notifier).createParticle(
              'sparkle',
              MediaQuery.of(context).size.width / 2 + (Random().nextDouble() - 0.5) * 50,
              MediaQuery.of(context).size.height / 2 + (Random().nextDouble() - 0.5) * 50);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Corrigido: Acessando activePet via notifier.select para observar o getter
    final activePet =
        ref.watch(appServiceProvider.notifier.select((notifier) => notifier.activePet));
    final isDark = ref.watch(appServiceProvider.select((state) => state.isDark));
    final particles = ref.watch(appServiceProvider.select((state) => state.particles));

    // Atualiza o humor do pet
    if (activePet != null) {
      final avgStats =
          (activePet.happiness + activePet.hunger + activePet.energy + activePet.health) / 4;
      if (avgStats >= 80 && _petMood != 'excited') {
        _petMood = 'excited';
      } else if (avgStats >= 60 && _petMood != 'happy') {
        _petMood = 'happy';
      } else if (avgStats >= 40 && _petMood != 'neutral') {
        _petMood = 'neutral';
      } else if (avgStats < 40 && _petMood != 'sad') {
        _petMood = 'sad';
      }
    } else {
      _petMood = 'neutral'; // Sem pet, sem humor específico
    }

    // Retorna a cor da barra de estatísticas
    Color getStatColor(int value) {
      if (value >= 80) return Colors.green.shade500;
      if (value >= 60) return Colors.yellow.shade700;
      if (value >= 40) return Colors.orange.shade500;
      return Colors.red.shade500;
    }

    // Estilo de animação para o emoji do pet
    Matrix4 getPetAnimationTransform() {
      switch (_petAnimation) {
        case 'bounce':
          return Matrix4.translationValues(0, sin(DateTime.now().millisecondsSinceEpoch / 200) * 5,
              0); // Exemplo de um pequeno "bounce"
        case 'wiggle':
          return Matrix4.rotationZ(
              sin(DateTime.now().millisecondsSinceEpoch / 100) * 0.05); // Pequeno balanço
        case 'breathing':
        default:
          return Matrix4.identity(); // Sem transformação
      }
    }

    return Container(
      // Background (equivalente ao bg-gray-900 ou bg-gradient-to-br)
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A202C) : null, // gray-900
        gradient: isDark
            ? null
            : const LinearGradient(
                colors: [
                  Color(0xFFF3E8FF), // purple-100
                  Color(0xFFE0F2FE), // blue-100
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: Stack(
        children: [
          // Partículas flutuantes (renderizadas acima de tudo)
          ...particles.map((p) {
            return Positioned(
              left: p.x,
              top: p.y,
              child: Opacity(
                opacity: p.opacity,
                child: Transform.scale(
                  scale: p.scale,
                  child: Text(
                    p.type == 'heart'
                        ? '💖'
                        : p.type == 'star'
                            ? '⭐'
                            : p.type == 'coins'
                                ? '💰'
                                : '✨',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          }).toList(),

          if (activePet != null)
            Center(
              child: SingleChildScrollView(
                // Permite rolagem se o conteúdo for grande
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Círculo do Pet com Progresso e Detalhes
                    GestureDetector(
                      onTap: () => setState(() => _showActions = true), // Abre a folha de ações
                      child: Container(
                        width: 200,
                        height: 200,
                        margin: const EdgeInsets.only(bottom: 24.0), // mb-6
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgress(
                              progress:
                                  (activePet.xp % 100).toDouble(), // Progresso do XP no nível atual
                              size: 200,
                              strokeWidth: 8,
                              glowing: _petMood == 'excited',
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500), // Animação de mood
                              curve: Curves.easeInOut,
                              width: 190, // Levemente menor que o CircularProgress
                              height: 190,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? Colors.grey.shade800 : Colors.white, // Corrected
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withOpacity(0.4)
                                        : Colors.grey.withOpacity(0.2), // Corrected
                                    blurRadius: 20,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: getPetAnimationTransform(), // Aplica a animação
                                  child: Text(
                                    activePet.isUnique ? '✨' : activePet.emoji,
                                    style: const TextStyle(fontSize: 80),
                                  ),
                                ),
                              ),
                            ),
                            // Nível do Pet
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.purple.shade500, Colors.blue.shade500],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.shade300.withOpacity(0.5), // Corrected
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${activePet.level}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            // Ícone de Pet Único (se for o caso)
                            if (activePet.isUnique)
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.yellow.shade400,
                                        Colors.orange.shade500
                                      ], // Corrected
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.yellow.shade300.withOpacity(0.5), // Corrected
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Icon(LucideIcons.wand2, size: 18, color: Colors.white),
                                ),
                              ),
                            // Acessórios
                            if (activePet.accessories.isNotEmpty)
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: Text(activePet.accessories.first.emoji,
                                    style: const TextStyle(fontSize: 32)),
                              ),
                            // Avatares de Colaboração
                            if (activePet.isCollab) ...[
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.blue.shade500,
                                  child: Text(activePet.userAvatar ?? '❓',
                                      style: const TextStyle(fontSize: 14)),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                right: 10,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey.shade400, // Corrected
                                  child: Text(
                                      activePet.identityRevealed == true
                                          ? activePet.partnerAvatar ?? '❓'
                                          : '❓',
                                      style: const TextStyle(fontSize: 14)),
                                ),
                              ),
                            ],
                            // Indicador de Humor
                            Positioned(
                              bottom: 0,
                              child: Text(
                                _petMood == 'excited'
                                    ? '🎉'
                                    : _petMood == 'happy'
                                        ? '😊'
                                        : _petMood == 'neutral'
                                            ? '😐'
                                            : '😢',
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Informações do Pet
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      color: isDark
                          ? Colors.grey.shade800.withOpacity(0.9)
                          : Colors.white.withOpacity(0.9), // Corrected
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text(
                              '${activePet.name} - Nível ${activePet.level}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.grey.shade800, // Corrected
                              ),
                            ),
                            if (activePet.isUnique)
                              Text('✨ Pet Único ✨',
                                  style: TextStyle(
                                      color: Colors.yellow.shade700,
                                      fontStyle: FontStyle.italic)), // Corrected
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (activePet.xp % 100) / 100,
                              backgroundColor:
                                  isDark ? Colors.grey.shade700 : Colors.grey.shade200, // Corrected
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade500),
                              minHeight: 8,
                            ),
                            Text(
                              'XP: ${activePet.xp % 100}/100',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600, // Corrected
                              ),
                            ),
                            if (activePet.isCollab && !(activePet.identityRevealed ?? false))
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.eyeOff,
                                        size: 16,
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600), // Corrected
                                    const SizedBox(width: 4),
                                    Text(
                                      'Identidade secreta até Nível ${activePet.revealLevel}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600, // Corrected
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Barras de Estatísticas
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      color: isDark
                          ? Colors.grey.shade800.withOpacity(0.9)
                          : Colors.white.withOpacity(0.9), // Corrected
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio:
                              2.0, // Ajuste para que as barras de progresso não fiquem muito altas
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          children: [
                            _StatBar(
                              label: 'Felicidade',
                              value: activePet.happiness,
                              emoji: '😊',
                              color: getStatColor(activePet.happiness),
                              isDark: isDark,
                            ),
                            _StatBar(
                              label: 'Fome',
                              value: activePet.hunger,
                              emoji: '🍖',
                              color: getStatColor(activePet.hunger),
                              isDark: isDark,
                            ),
                            _StatBar(
                              label: 'Energia',
                              value: activePet.energy,
                              emoji: '⚡',
                              color: getStatColor(activePet.energy),
                              isDark: isDark,
                            ),
                            _StatBar(
                              label: 'Saúde',
                              value: activePet.health,
                              emoji: '❤️',
                              color: getStatColor(activePet.health),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade300, // Corrected
                        style: BorderStyle.solid,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '🐾',
                        style: TextStyle(
                          fontSize: 64,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400, // Corrected
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nenhum pet adotado ainda.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey.shade800, // Corrected
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use os slots abaixo para adotar um novo amigo!',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, // Corrected
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _showAIGeneration = true),
                    icon: const Icon(LucideIcons.wand2, color: Colors.white),
                    label: const Text('Gerar Pet Único com IA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                    ),
                  ),
                ],
              ),
            ),

          // Sheets/Modals que abrem a partir desta aba
          PetActionsSheet(
            pet: activePet,
            show: _showActions,
            onClose: () => setState(() => _showActions = false),
          ),
          AIPetGenerationSheet(
            show: _showAIGeneration,
            onClose: () => setState(() => _showAIGeneration = false),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para as barras de estatísticas
class _StatBar extends StatelessWidget {
  final String label;
  final int value;
  final String emoji;
  final Color color;
  final bool isDark;

  const _StatBar({
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade600, // Corrected
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade200, // Corrected
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 12,
          borderRadius: BorderRadius.circular(6),
        ),
        const SizedBox(height: 4),
        Text(
          '$value%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.grey.shade800, // Corrected
          ),
        ),
      ],
    );
  }
}
