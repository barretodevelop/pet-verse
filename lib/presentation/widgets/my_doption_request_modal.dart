import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/data/models/pet.dart';
import 'package:petverse/presentation/providers/theme_provider.dart';

/// Modal para exibir detalhes da própria solicitação de adoção do usuário
class MyAdoptionRequestModal extends ConsumerStatefulWidget {
  final Map<String, dynamic> requestInfo;
  final List<Pet> petsInRequest;
  final VoidCallback onClose;
  final VoidCallback? onCancel;
  final VoidCallback? onEdit;

  const MyAdoptionRequestModal({
    super.key,
    required this.requestInfo,
    required this.petsInRequest,
    required this.onClose,
    this.onCancel,
    this.onEdit,
  });

  @override
  ConsumerState<MyAdoptionRequestModal> createState() =>
      _MyAdoptionRequestModalState();
}

class _MyAdoptionRequestModalState extends ConsumerState<MyAdoptionRequestModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
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
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 700,
                ),
                decoration: BoxDecoration(
                  color: isLightTheme ? Colors.white : Colors.grey[800],
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30.0,
                      offset: const Offset(0, 15),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Minha Solicitação',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Detalhes e estatísticas',
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
          // Status da solicitação
          _buildStatusCard(isLightTheme),
          const SizedBox(height: 20),

          // Estatísticas
          _buildStatsRow(isLightTheme),
          const SizedBox(height: 20),

          // Título dos pets
          _buildSectionTitle('Pets Selecionados', isLightTheme),
          const SizedBox(height: 12),

          // Grid de pets
          Expanded(
            child: _buildPetsGrid(isLightTheme),
          ),

          // Dicas
          const SizedBox(height: 16),
          _buildTips(isLightTheme),
        ],
      ),
    );
  }

  /// Constrói o card de status
  Widget _buildStatusCard(bool isLightTheme) {
    final daysLeft = widget.requestInfo['daysLeft'] as int;
    final isExpiring = daysLeft <= 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isExpiring
              ? [Colors.orange[400]!, Colors.orange[600]!]
              : [Colors.green[400]!, Colors.green[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isExpiring ? Colors.orange : Colors.green).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpiring ? Icons.warning_outlined : Icons.check_circle_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isExpiring ? 'Expirando em Breve!' : 'Solicitação Ativa',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isExpiring
                      ? 'Apenas $daysLeft dia${daysLeft == 1 ? '' : 's'} restante${daysLeft == 1 ? '' : 's'}'
                      : 'Aguardando adotador por $daysLeft dias',
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
    );
  }

  /// Constrói a linha de estatísticas
  Widget _buildStatsRow(bool isLightTheme) {
    final views = widget.requestInfo['views'] as int;
    final daysLeft = widget.requestInfo['daysLeft'] as int;
    const totalDays = 5; // Assumindo que o total é sempre 5 dias
    final progress = ((totalDays - daysLeft) / totalDays).clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Visualizações',
            value: views.toString(),
            icon: Icons.visibility_outlined,
            color: Colors.blue,
            isLightTheme: isLightTheme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Progresso',
            value: '${(progress * 100).toInt()}%',
            icon: Icons.timeline_outlined,
            color: Colors.indigo,
            isLightTheme: isLightTheme,
            progress: progress,
          ),
        ),
      ],
    );
  }

  /// Constrói um card de estatística
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isLightTheme,
    double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLightTheme ? color.withOpacity(0.1) : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isLightTheme ? Colors.grey[700] : Colors.grey[300]),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isLightTheme ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ],
        ],
      ),
    );
  }

  /// Constrói um título de seção
  Widget _buildSectionTitle(String title, bool isLightTheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
        ),
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
        childAspectRatio: 0.9,
      ),
      itemCount: widget.petsInRequest.length,
      itemBuilder: (context, index) {
        final pet = widget.petsInRequest[index];
        return _buildPetCard(pet, isLightTheme);
      },
    );
  }

  /// Constrói um card de pet
  Widget _buildPetCard(Pet pet, bool isLightTheme) {
    return Container(
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.white : Colors.grey[700],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isLightTheme ? Colors.purple[200]! : Colors.purple[600]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Imagem do pet
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.purple[300]!,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
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
              fontSize: 13,
              color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          // Tipo do pet
          Text(
            pet.type,
            style: TextStyle(
              fontSize: 11,
              color: isLightTheme ? Colors.grey[600] : Colors.grey[400],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Constrói as dicas
  Widget _buildTips(bool isLightTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.blue[50] : Colors.blue[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLightTheme ? Colors.blue[200]! : Colors.blue[700]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outlined,
            color: isLightTheme ? Colors.blue[600] : Colors.blue[300],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sua solicitação está visível para outros usuários. Quanto mais visualizações, maior a chance de adoção!',
              style: TextStyle(
                fontSize: 13,
                color: isLightTheme ? Colors.blue[700] : Colors.blue[200],
                height: 1.3,
              ),
            ),
          ),
        ],
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
          // Botões de ação
          if (widget.onCancel != null || widget.onEdit != null)
            Row(
              children: [
                if (widget.onEdit != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (widget.onCancel != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onCancel,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[600],
                        side: BorderSide(color: Colors.red[300]!),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

          if (widget.onCancel != null || widget.onEdit != null)
            const SizedBox(height: 12),

          // Botão fechar
          ElevatedButton(
            onPressed: _handleClose,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isLightTheme ? Colors.grey[600] : Colors.grey[500],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4,
            ),
            child: const Text(
              'Fechar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.pets, size: 25, color: Colors.grey),
      ),
    );
  }
}
