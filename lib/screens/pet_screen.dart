// PetScreen
// lib/screens/pet_screen.dart - PetScreen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petverse/providers/app_provider.dart';
import 'package:petverse/providers/pet_provider.dart';
import 'package:petverse/providers/theme_provider.dart';
import 'package:petverse/providers/user_provider.dart';
import 'package:petverse/widgets/adoption_flow.dart';
import 'package:petverse/widgets/pet_circle.dart';

class PetScreen extends ConsumerWidget {
  const PetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petProvider);
    final appState = ref.watch(appProvider);
    final isDark = ref.watch(themeProvider);
    final user =
        ref.watch(userProvider); // ✅ CORREÇÃO 1: Obter dados do usuário

    final activePet = pets.isNotEmpty && appState.activePetIndex < pets.length
        ? pets[appState.activePetIndex]
        : null;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF111827), Color(0xFF1F2937)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
              ),
      ),
      child: activePet != null
          ? PetCircle(pet: activePet)
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFD1D5DB),
                        width: 4,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🐾', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum pet adotado',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use os slots acima para adotar',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Adotar Pet Sozinho'),
                    onPressed: () {
                      final isDark = ref.read(
                          themeProvider); // Obtenha o tema para estilizar o modal
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled:
                            true, // Permite que o sheet ocupe mais altura
                        backgroundColor: Colors
                            .transparent, // Para usar o fundo do AdoptionFlow
                        builder: (bContext) {
                          return Container(
                            // Define a altura máxima ou uma fração da altura da tela
                            height: MediaQuery.of(bContext).size.height *
                                0.9, // Ajuste conforme necessário
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1F2937)
                                  : Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                            child:
                                const AdoptionFlow(), // Chame o AdoptionFlow refatorado
                          );
                        },
                      );
                    },
                  ),
                  // ✅ CORREÇÃO 2: Botão IA com navegação funcional
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAIGeneration(context, ref),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Gerar Pet Único com IA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  // ✅ CORREÇÃO 3: Mostrar gemas disponíveis
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.diamond,
                          size: 16, color: Color(0xFF8B5CF6)),
                      const SizedBox(width: 4),
                      Text(
                        'Você tem ${user?.gems ?? 0} gemas',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // ✅ CORREÇÃO 4: Implementação robusta de navegação
  void _navigateToAIGeneration(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);

    // Verificar se usuário tem gemas suficientes
    if ((user?.gems ?? 0) < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Você precisa de 10 gemas para gerar um pet único!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    try {
      // ✅ CORREÇÃO 5: Navegação com tratamento de erro
      context.push('/ai-generation');
      print('✅ Navegando para IA Generation'); // Debug
    } catch (e) {
      print('❌ Erro na navegação: $e'); // Debug

      // ✅ CORREÇÃO 6: Fallback com dialog se navegação falhar
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
}
