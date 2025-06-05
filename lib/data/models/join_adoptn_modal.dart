import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/data/models/adoption_request_status.dart';
import 'package:petverse/data/models/pet.dart';
import 'package:petverse/presentation/providers/theme_provider.dart';

/// Modal para participar de uma solicitação de adoção conjunta
class JoinAdoptionModal extends ConsumerStatefulWidget {
  final AdoptionRequest request;
  final VoidCallback onClose;
  final Function(String requestId, String petId) onChoosePet;

  const JoinAdoptionModal({
    super.key,
    required this.request,
    required this.onClose,
    required this.onChoosePet,
  });

  @override
  ConsumerState<JoinAdoptionModal> createState() => _JoinAdoptionModalState();
}

class _JoinAdoptionModalState extends ConsumerState<JoinAdoptionModal>
    with SingleTickerProviderStateMixin {
  String? _chosenPetId;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
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

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                  maxHeight: 650,
                ),
                decoration: BoxDecoration(
                  color: isLightTheme ? Colors.white : Colors.grey[800],
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 25.0,
                      offset: const Offset(0, 15),
                    ),
                  ],
                  border: Border.all(
                    color: isLightTheme
                        ? Colors.indigo[300]!
                        : Colors.indigo[700]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(isLightTheme),
                    Flexible(
                      child: _buildContent(isLightTheme),
                    ),
                    _buildActions(isLightTheme),
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
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLightTheme
              ? [Colors.indigo[500]!, Colors.indigo[700]!]
              : [Colors.indigo[800]!, Colors.indigo[900]!],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.favorite_border,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adoção Conjunta',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Escolha seu novo companheiro',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
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
  Widget _buildContent(bool isLightTheme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Informações da solicitação
          _buildRequestInfo(isLightTheme),
          const SizedBox(height: 24),

          // Instrução
          _buildInstruction(isLightTheme),
          const SizedBox(height: 20),

          // Grid de pets
          Expanded(
            child: _buildPetsGrid(isLightTheme),
          ),
        ],
      ),
    );
  }

  /// Constrói as informações da solicitação
  Widget _buildRequestInfo(bool isLightTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.blue[50] : Colors.blue[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLightTheme ? Colors.blue[200]! : Colors.blue[700]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLightTheme ? Colors.blue[100] : Colors.blue[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.schedule,
              color: isLightTheme ? Colors.blue[700] : Colors.blue[300],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solicitação Ativa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isLightTheme ? Colors.blue[800] : Colors.blue[200],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Restam ${widget.request.actualDaysLeft} dias para adoção',
                  style: TextStyle(
                    fontSize: 14,
                    color: isLightTheme ? Colors.blue[600] : Colors.blue[300],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[500],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.request.petsInRequest.length} pets',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a instrução
  Widget _buildInstruction(bool isLightTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.amber[50] : Colors.amber[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLightTheme ? Colors.amber[200]! : Colors.amber[700]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: isLightTheme ? Colors.amber[700] : Colors.amber[300],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Selecione um dos pets abaixo para adotá-lo conjuntamente com outro usuário.',
              style: TextStyle(
                fontSize: 14,
                color: isLightTheme ? Colors.amber[800] : Colors.amber[200],
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o grid de pets
  Widget _buildPetsGrid(bool isLightTheme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: widget.request.petsInRequest.length,
      itemBuilder: (context, index) {
        final pet = widget.request.petsInRequest[index];
        return _buildPetCard(pet, isLightTheme);
      },
    );
  }

  /// Constrói um card de pet
  Widget _buildPetCard(Pet pet, bool isLightTheme) {
    final isSelected = _chosenPetId == pet.id;

    return GestureDetector(
      onTap: () => _selectPet(pet.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isLightTheme ? Colors.white : Colors.grey[700],
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected
                ? (isLightTheme ? Colors.indigo[500]! : Colors.indigo[400]!)
                : (isLightTheme ? Colors.grey[200]! : Colors.grey[600]!),
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.indigo.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 6 : 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagem do pet
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.indigo[300]! : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: pet.imageUrl.startsWith('data:image')
                    ? Image.memory(
                        base64Decode(pet.imageUrl.split(',')[1]),
                        fit: BoxFit.cover,
                        errorBuilder: _buildImageError,
                      )
                    : Image.network(
                        pet.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: _buildImageError,
                      ),
              ),
            ),
            const SizedBox(height: 8),

            // Nome do pet
            Text(
              pet.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Tipo do pet
            Text(
              pet.type,
              style: TextStyle(
                fontSize: 12,
                color: isLightTheme ? Colors.grey[600] : Colors.grey[400],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Indicador de seleção
            if (isSelected) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.indigo[500],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Selecionado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Constrói os botões de ação
  Widget _buildActions(bool isLightTheme) {
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
          // Botão principal
          ElevatedButton(
            onPressed: _chosenPetId == null ? null : _handleConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[600],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: _chosenPetId != null ? 8 : 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_chosenPetId != null) ...[
                  const Icon(Icons.favorite, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  _chosenPetId == null
                      ? 'Selecione um Pet'
                      : 'Adotar Conjuntamente',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Botão cancelar
          TextButton(
            onPressed: _handleClose,
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(
              'Cancelar',
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

  /// Seleciona um pet
  void _selectPet(String petId) {
    setState(() {
      _chosenPetId = _chosenPetId == petId ? null : petId;
    });
  }

  /// Manipula a confirmação
  void _handleConfirm() {
    if (_chosenPetId != null) {
      widget.onChoosePet(widget.request.id, _chosenPetId!);
      _handleClose();
    }
  }

  /// Manipula o fechamento do modal
  void _handleClose() async {
    await _animationController.reverse();
    widget.onClose();
  }

  /// Constrói o widget de erro da imagem
  Widget _buildImageError(
      BuildContext context, Object error, StackTrace? stackTrace) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(
        child: Icon(Icons.pets, size: 30, color: Colors.grey),
      ),
    );
  }
}
