// PetActionsSheet

// lib/widgets/pet_actions_sheet.dart - PetActionsSheet
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/models/pet_model.dart';
import 'package:petverse/providers/pet_provider.dart';
import 'package:petverse/providers/theme_provider.dart';
import 'package:petverse/providers/user_provider.dart';
import 'package:petverse/widgets/chat_sheet.dart';
import 'package:petverse/widgets/inventory_sheet.dart';

class PetActionsSheet extends ConsumerStatefulWidget {
  final PetModel pet;
  // final bool show; // Removido
  // final VoidCallback onClose; // Removido

  const PetActionsSheet({
    super.key,
    required this.pet,
    // required this.show, // Removido
    // required this.onClose, // Removido
  });

  @override
  ConsumerState<PetActionsSheet> createState() => _PetActionsSheetState();
}

class _PetActionsSheetState extends ConsumerState<PetActionsSheet> {
  // bool _showInventory = false; // Não é mais necessário para controlar a exibição direta do InventorySheet
  // bool _showChat = false; // ChatSheet também será um modal
  bool _showReturnConfirm = false;

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);

    return Column(
      // Conteúdo direto do BottomSheet
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header (similar ao que BottomSheetBase fazia)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Cuidar de ${widget.pet.name}', // Título
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pop(context), // Fecha o showModalBottomSheet
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
            height: 1,
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
        // Conteúdo principal
        // Adicionado SingleChildScrollView para conteúdo que pode exceder a altura
        Expanded(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(16.0), // Padding para o conteúdo interno
            child: Column(
              children: [
                // Collaboration Info
                if (widget.pet.isCollab) _buildCollabInfo(),

                // Actions Grid
                const SizedBox(height: 16),
                Text(
                  'Ações',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildActionCard('🍖', 'Alimentar', 'Usar comida',
                        () => _openInventorySheet(context, ref, 'comida')),
                    _buildActionCard(
                        '🎾',
                        'Brincar',
                        'Usar brinquedo', // Descrição atualizada
                        () => _openInventorySheet(context, ref, 'brinquedo')),
                    _buildActionCard(
                        '💤',
                        'Cuidar',
                        'Usar medicamento', // Descrição atualizada
                        () => _openInventorySheet(context, ref, 'medicina')),
                    _buildActionCard('💝', 'Carinho', 'Demonstrar amor',
                        _showLove), // Mantém _showLove se não usar item
                  ],
                ),

                const SizedBox(height: 16),

                // Inventory & Chat
                Row(
                  children: [
                    Expanded(
                      child: _buildUtilityButton(
                        '👑',
                        'Acessórios',
                        'Equipar itens',
                        () => _openInventorySheet(context, ref, 'acessório'),
                      ),
                    ),
                    if (widget.pet.isCollab) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildUtilityButton(
                          '💬',
                          'Chat',
                          'Conversar',
                          () => _openChatSheet(context, ref),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Return Pet
                _buildReturnButton(),
              ],
            ),
          ),
        ),
        // Diálogo de confirmação para devolver o pet
        if (_showReturnConfirm)
          _buildReturnConfirmationDialog(context, ref, isDark),
      ],
    );
  }

  void _openInventorySheet(
      BuildContext context, WidgetRef ref, String category) {
    final isDark =
        ref.watch(themeProvider); // Obter o tema para estilizar o modal

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que o sheet ocupe mais altura
      backgroundColor:
          Colors.transparent, // Para usar o fundo do InventorySheet
      builder: (bContext) {
        // Usar um nome de contexto diferente para o builder
        return Container(
          // Define a altura máxima ou uma fração da altura da tela
          height: MediaQuery.of(bContext).size.height * 0.9,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: InventorySheet(
              pet: widget.pet, category: category), // ✅ Passar a categoria
        );
      },
    );
  }

  void _openChatSheet(BuildContext context, WidgetRef ref) {
    // Se ChatSheet também for refatorado para ser um modal, use esta lógica:
    final isDark = ref.watch(themeProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bContext) {
        return Container(
          height: MediaQuery.of(bContext).size.height * 0.9,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2937) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          // Assumindo que ChatSheet foi refatorado para não precisar de 'show' e 'onClose'
          // e que ele fecha a si mesmo com Navigator.pop(context)
          child: ChatSheet(pet: widget.pet),
        );
      },
    );
    // Se ChatSheet ainda usa a lógica antiga:
    // setState(() => _showChat = true);
  }

  Widget _buildCollabInfo() {
    final isDark = ref.watch(themeProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF374151) : const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B5CF6), width: 2),
      ),
      child: Row(
        children: [
          _buildAvatar(widget.pet.ownerId, true),
          const SizedBox(width: 12),
          Text(widget.pet.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          _buildAvatar(
            widget.pet.identityRevealed ? widget.pet.partnerAvatar ?? '❓' : '❓',
            false,
          ),
          const Spacer(),
          if (widget.pet.level >= widget.pet.revealLevel &&
              !widget.pet.identityRevealed)
            ElevatedButton.icon(
              onPressed: _revealIdentity,
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('Revelar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 32),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String avatar, bool isUser) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(child: Text(avatar, style: const TextStyle(fontSize: 20))),
    );
  }

  Widget _buildActionCard(
      String emoji, String title, String description, VoidCallback onTap) {
    final isDark = ref.watch(themeProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF374151) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilityButton(
      String emoji, String title, String description, VoidCallback onTap) {
    final isDark = ref.watch(themeProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF374151) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => setState(() => _showReturnConfirm = true),
        icon: const Icon(Icons.delete_outline),
        label: const Text('Devolver Pet (3 gemas)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // Novo método para construir o diálogo de confirmação
  Widget _buildReturnConfirmationDialog(
      BuildContext context, WidgetRef ref, bool isDark) {
    final user = ref.watch(userProvider);
    const returnCost = 3; // Custo em gemas para devolver o pet

    return Positioned.fill(
      child: GestureDetector(
        onTap: () =>
            setState(() => _showReturnConfirm = false), // Fecha ao clicar fora
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Center(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFEF4444), size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Devolver ${widget.pet.name}?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Esta ação não pode ser desfeita. O pet será removido permanentemente.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Custo: $returnCost gemas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () =>
                              setState(() => _showReturnConfirm = false),
                          child: Text('Cancelar',
                              style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _performReturnPet(context, ref),
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Devolver'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Os métodos _feedPet, _playWithPet e _carePet agora são tratados
  // pela lógica dentro de InventorySheet._handleItemAction quando um item é selecionado.
  // Eles podem ser removidos ou mantidos se houver alguma ação padrão
  // que não envolva itens do inventário.

  // void _feedPet() {
  //   final petNotifier = ref.read(petProvider.notifier);
  //   final userNotifier = ref.read(userProvider.notifier);
  //   final missionNotifier = ref.read(missionProvider.notifier);
  //   final user = ref.read(userProvider);

  //   petNotifier.updatePetStats(
  //     widget.pet.id,
  //     hunger: (widget.pet.hunger + 25).clamp(0, 100),
  //     happiness: (widget.pet.happiness + 10).clamp(0, 100),
  //   );
  //   petNotifier.addPetXP(widget.pet.id, 10);

  //   if (user != null) {
  //     userNotifier.updateXP(user.xp + 5);
  //   }
  //   missionNotifier.updateMissionProgress(1, 1);
  //   if (mounted) Navigator.pop(context); // Fecha o modal
  // }

  // void _playWithPet() {
  //   // Se "Brincar" puder ser uma ação sem item, mantenha uma lógica aqui.
  //   // Caso contrário, esta ação é agora via inventário.
  //   final petNotifier = ref.read(petProvider.notifier);
  //   final userNotifier = ref.read(userProvider.notifier);
  //   final missionNotifier = ref.read(missionProvider.notifier);
  //   final user = ref.read(userProvider);

  //   petNotifier.updatePetStats(
  //     widget.pet.id,
  //     happiness: (widget.pet.happiness + 20).clamp(0, 100),
  //     energy: (widget.pet.energy - 10).clamp(0, 100),
  //   );
  //   petNotifier.addPetXP(widget.pet.id, 15);

  //   if (user != null) {
  //     userNotifier.updateXP(user.xp + 8);
  //   }
  //   missionNotifier.updateMissionProgress(2, 1);
  //   if (mounted) Navigator.pop(context); // Fecha o modal
  // }

  // void _carePet() {
  //   final petNotifier = ref.read(petProvider.notifier);
  //   final userNotifier = ref.read(userProvider.notifier);
  //   final missionNotifier = ref.read(missionProvider.notifier);
  //   final user = ref.read(userProvider);

  //   petNotifier.updatePetStats(
  //     widget.pet.id,
  //     energy: (widget.pet.energy + 30).clamp(0, 100),
  //     health: (widget.pet.health + 15).clamp(0, 100),
  //   );
  //   petNotifier.addPetXP(widget.pet.id, 12);

  //   if (user != null) {
  //     userNotifier.updateXP(user.xp + 10);
  //   }
  //   missionNotifier.updateMissionProgress(3, 1);
  //   if (mounted) Navigator.pop(context); // Fecha o modal
  // }

  void _showLove() {
    final petNotifier = ref.read(petProvider.notifier);
    final userNotifier = ref.read(userProvider.notifier);
    final user = ref.read(userProvider);

    petNotifier.updatePetStats(
      widget.pet.id,
      happiness: (widget.pet.happiness + 15).clamp(0, 100),
      health: (widget.pet.health + 5).clamp(0, 100),
    );
    petNotifier.addPetXP(widget.pet.id, 8);

    if (user != null) {
      userNotifier.updateXP(user.xp + 3);
    }
    if (mounted) Navigator.pop(context); // Fecha o modal
    // widget.onClose(); // Removido
  }

  void _revealIdentity() {
    final petNotifier = ref.read(petProvider.notifier);
    petNotifier.updatePetData(widget.pet.copyWith(identityRevealed: true));
  }

  Future<void> _performReturnPet(BuildContext context, WidgetRef ref) async {
    final user = ref.read(userProvider);
    final userNotifier = ref.read(userProvider.notifier);
    final petNotifier = ref.read(petProvider.notifier);
    const returnCost = 3;

    setState(() {
      _showReturnConfirm = false; // Fecha o diálogo de confirmação
    });

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Usuário não encontrado.')),
      );
      return;
    }

    if (user.gems < returnCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Gemas insuficientes! Você precisa de $returnCost gemas.')),
      );
      return;
    }

    try {
      // Deduzir gemas
      await userNotifier.updateGems(user.gems - returnCost);

      // Remover o pet
      await petNotifier.removePet(widget.pet.id);

      if (mounted) {
        Navigator.pop(context); // Fecha o PetActionsSheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${widget.pet.name} foi devolvido com sucesso!')),
        );
      }
    } catch (e) {
      print('Erro ao devolver o pet: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao devolver o pet: ${e.toString()}')),
        );
      }
    }
  }
}
