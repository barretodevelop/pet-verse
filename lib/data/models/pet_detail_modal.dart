import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/presentation/providers/pet_provider.dart';
import 'package:petverse/presentation/providers/theme_provider.dart';

import '../models/pet.dart';

/// Modos de exibição do modal de detalhes do pet
enum PetDetailMode {
  view, // Apenas visualização
  select, // Seleção para solicitação
  adopt, // Adoção imediata
  createRequest, // Criação de solicitação
  friendAdoption, // Adoção com amigo
}

/// Modal para exibir detalhes de um pet
class PetDetailModal extends ConsumerStatefulWidget {
  final Pet pet;
  final VoidCallback onClose;
  final Function(String petId)? onSelect;
  final PetDetailMode mode;
  final String? actionButtonText;
  final bool showStats;

  const PetDetailModal({
    super.key,
    required this.pet,
    required this.onClose,
    this.onSelect,
    this.mode = PetDetailMode.view,
    this.actionButtonText,
    this.showStats = false,
  });

  @override
  ConsumerState<PetDetailModal> createState() => _PetDetailModalState();
}

class _PetDetailModalState extends ConsumerState<PetDetailModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(isLightThemeProvider);
    final selectedPetsForMyRequest =
        ref.watch(selectedPetsForMyRequestIdsProvider);
    final selectedPetsForFriendAdoption =
        ref.watch(selectedPetsForFriendAdoptionIdsProvider);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                  maxHeight: 600,
                ),
                decoration: BoxDecoration(
                  color: isLightTheme ? Colors.white : Colors.grey[800],
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20.0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: isLightTheme
                        ? Colors.purple[300]!
                        : Colors.purple[700]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(isLightTheme),
                    Flexible(
                      child: _buildContent(
                          isLightTheme,
                          selectedPetsForMyRequest,
                          selectedPetsForFriendAdoption),
                    ),
                    _buildActions(isLightTheme, selectedPetsForMyRequest,
                        selectedPetsForFriendAdoption),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Constrói o cabeçalho do modal
  Widget _buildHeader(bool isLightTheme) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLightTheme
              ? [Colors.purple[500]!, Colors.purple[700]!]
              : [Colors.purple[800]!, Colors.purple[900]!],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.pet.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
            onPressed: _handleClose,
            tooltip: 'Fechar',
          ),
        ],
      ),
    );
  }

  /// Constrói o conteúdo principal do modal
  Widget _buildContent(bool isLightTheme, List<String> selectedForRequest,
      List<String> selectedForFriend) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Imagem do pet
          _buildPetImage(isLightTheme),
          const SizedBox(height: 20),

          // Informações básicas
          _buildBasicInfo(isLightTheme),
          const SizedBox(height: 16),

          // Descrição
          _buildDescription(isLightTheme),

          // Stats (se habilitado)
          if (widget.showStats) ...[
            const SizedBox(height: 16),
            _buildStats(isLightTheme),
          ],

          // Status de seleção
          if (widget.mode == PetDetailMode.createRequest ||
              widget.mode == PetDetailMode.friendAdoption) ...[
            const SizedBox(height: 16),
            _buildSelectionStatus(
                isLightTheme, selectedForRequest, selectedForFriend),
          ],
        ],
      ),
    );
  }

  /// Constrói a imagem do pet
  Widget _buildPetImage(bool isLightTheme) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getBorderColor(),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: widget.pet.imageUrl.startsWith('data:image')
            ? Image.memory(
                base64Decode(widget.pet.imageUrl.split(',')[1]),
                fit: BoxFit.cover,
                errorBuilder: _buildImageError,
              )
            : Image.network(
                widget.pet.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: _buildImageLoading,
                errorBuilder: _buildImageError,
              ),
      ),
    );
  }

  /// Constrói as informações básicas do pet
  Widget _buildBasicInfo(bool isLightTheme) {
    return Column(
      children: [
        // Tipo do pet
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isLightTheme ? Colors.purple[100] : Colors.purple[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.pet.type,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isLightTheme ? Colors.purple[800] : Colors.purple[200],
            ),
          ),
        ),

        // Nível (se mostrar stats)
        if (widget.showStats) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text(
                'Nível ${widget.pet.level}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isLightTheme ? Colors.amber[700] : Colors.amber[300],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Constrói a descrição do pet
  Widget _buildDescription(bool isLightTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.grey[50] : Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLightTheme ? Colors.grey[200]! : Colors.grey[600]!,
        ),
      ),
      child: Text(
        '"${widget.pet.description}"',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
          color: isLightTheme ? Colors.grey[700] : Colors.grey[300],
          height: 1.4,
        ),
      ),
    );
  }

  /// Constrói as estatísticas do pet
  Widget _buildStats(bool isLightTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.blue[50] : Colors.blue[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLightTheme ? Colors.blue[200]! : Colors.blue[700]!,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Status do Pet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isLightTheme ? Colors.blue[800] : Colors.blue[200],
            ),
          ),
          const SizedBox(height: 12),
          _buildStatBar('🍔 Fome', widget.pet.hunger, Colors.orange),
          const SizedBox(height: 8),
          _buildStatBar('😊 Felicidade', widget.pet.happiness, Colors.pink),
          const SizedBox(height: 8),
          _buildStatBar('⚡ Energia', widget.pet.energy, Colors.green),
        ],
      ),
    );
  }

  /// Constrói uma barra de estatística
  Widget _buildStatBar(String label, int value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value%',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Constrói o status de seleção
  Widget _buildSelectionStatus(bool isLightTheme,
      List<String> selectedForRequest, List<String> selectedForFriend) {
    final isSelected = widget.mode == PetDetailMode.createRequest
        ? selectedForRequest.contains(widget.pet.id)
        : selectedForFriend.contains(widget.pet.id);

    if (!isSelected) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green[400]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
          const SizedBox(width: 8),
          Text(
            'Selecionado',
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói os botões de ação
  Widget _buildActions(bool isLightTheme, List<String> selectedForRequest,
      List<String> selectedForFriend) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.grey[50] : Colors.grey[700],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          if (widget.pet.isAdopted)
            _buildAdoptedMessage(isLightTheme)
          else if (widget.onSelect != null)
            _buildActionButton(
                isLightTheme, selectedForRequest, selectedForFriend),

          const SizedBox(height: 12),

          // Botão fechar sempre presente
          TextButton(
            onPressed: _handleClose,
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
            ),
            child: Text(
              'Fechar',
              style: TextStyle(
                fontSize: 16,
                color: isLightTheme ? Colors.grey[700] : Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a mensagem de pet adotado
  Widget _buildAdoptedMessage(bool isLightTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[400]!),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite, color: Colors.orange[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Este pet já encontrou uma família!',
              style: TextStyle(
                color: Colors.orange[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o botão de ação principal
  Widget _buildActionButton(bool isLightTheme, List<String> selectedForRequest,
      List<String> selectedForFriend) {
    final buttonText = _getButtonText(selectedForRequest, selectedForFriend);
    final buttonColor = _getButtonColor(selectedForRequest, selectedForFriend);
    final canSelect = _canSelectPet(selectedForRequest, selectedForFriend);

    return ElevatedButton(
      onPressed: canSelect ? () => _handleAction() : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 6,
      ),
      child: Text(
        buttonText,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Obtém a cor da borda baseada no pet
  Color _getBorderColor() {
    if (widget.pet.level >= 10) return const Color(0xFFFFD700); // Dourado
    if (widget.pet.level >= 5) return const Color(0xFFC0C0C0); // Prata
    return const Color(0xFFCD7F32); // Bronze
  }

  /// Obtém o texto do botão baseado no modo e seleção
  String _getButtonText(
      List<String> selectedForRequest, List<String> selectedForFriend) {
    if (widget.actionButtonText != null) return widget.actionButtonText!;

    switch (widget.mode) {
      case PetDetailMode.createRequest:
        return selectedForRequest.contains(widget.pet.id)
            ? 'Remover da Seleção'
            : 'Selecionar para Adoção';
      case PetDetailMode.friendAdoption:
        return selectedForFriend.contains(widget.pet.id)
            ? 'Remover da Seleção'
            : 'Selecionar para Amigo';
      case PetDetailMode.adopt:
        return 'Adotar Este Pet';
      default:
        return 'Confirmar';
    }
  }

  /// Obtém a cor do botão baseada na seleção
  Color _getButtonColor(
      List<String> selectedForRequest, List<String> selectedForFriend) {
    final isSelected = widget.mode == PetDetailMode.createRequest
        ? selectedForRequest.contains(widget.pet.id)
        : selectedForFriend.contains(widget.pet.id);

    if (isSelected) return Colors.red[600]!;

    switch (widget.mode) {
      case PetDetailMode.adopt:
        return Colors.green[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  /// Verifica se o pet pode ser selecionado
  bool _canSelectPet(
      List<String> selectedForRequest, List<String> selectedForFriend) {
    if (widget.mode == PetDetailMode.createRequest) {
      return selectedForRequest.contains(widget.pet.id) ||
          selectedForRequest.length < 3;
    }
    if (widget.mode == PetDetailMode.friendAdoption) {
      return selectedForFriend.contains(widget.pet.id) ||
          selectedForFriend.length < 3;
    }
    return true;
  }

  /// Manipula o fechamento do modal
  void _handleClose() async {
    await _animationController.reverse();
    widget.onClose();
  }

  /// Manipula a ação principal
  void _handleAction() {
    if (widget.onSelect != null) {
      widget.onSelect!(widget.pet.id);
    }
    _handleClose();
  }

  /// Constrói o widget de loading da imagem
  Widget _buildImageLoading(
      BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  }

  /// Constrói o widget de erro da imagem
  Widget _buildImageError(
      BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('Pet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
