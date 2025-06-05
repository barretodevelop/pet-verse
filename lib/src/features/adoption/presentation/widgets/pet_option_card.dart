// lib/src/features/adoption/presentation/widgets/pet_option_card.dart
// ALTERAÇÃO: Transformado em componente game-like com animações e dark mode

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart';

class PetOptionCard extends StatefulWidget {
  final Pet pet;
  final bool isSelected;
  final ValueChanged<String> onSelect;

  const PetOptionCard({
    super.key,
    required this.pet,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  State<PetOptionCard> createState() => _PetOptionCardState();
}

class _PetOptionCardState extends State<PetOptionCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));

    if (widget.isSelected) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(PetOptionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _shimmerController.repeat();
      } else {
        _shimmerController.stop();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onSelect(widget.pet.id);
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    _showPetDetails();
  }

  void _showPetDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle indicator
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Pet image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: widget.pet.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Pet info
                Text(
                  widget.pet.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                _buildInfoChip('Espécie', widget.pet.species),
                _buildInfoChip('Raça', widget.pet.breed),
                _buildInfoChip('Idade', '${widget.pet.age} anos'),
                _buildInfoChip('Gênero', widget.pet.gender),

                const SizedBox(height: 16),
                Text(
                  'Descrição',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.pet.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            _scaleController.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _scaleController.reverse();
          },
          child: GestureDetector(
            onTap: _handleTap,
            onLongPress: _handleLongPress,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isSelected
                      ? colorScheme.primary
                      : (_isHovered ? colorScheme.outline : Colors.transparent),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? colorScheme.primary.withOpacity(0.3)
                        : Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: widget.isSelected ? 12 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background with shimmer effect
                  if (widget.isSelected)
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            begin: Alignment(-1.0 + _shimmerAnimation.value, 0),
                            end: Alignment(1.0 + _shimmerAnimation.value, 0),
                            colors: [
                              colorScheme.primaryContainer.withOpacity(0.3),
                              colorScheme.primary.withOpacity(0.1),
                              colorScheme.primaryContainer.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Content
                  Container(
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? colorScheme.primaryContainer.withOpacity(0.8)
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Hero(
                        tag: 'pet-${widget.pet.id}',
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: widget.pet.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.pets,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: colorScheme.errorContainer,
                                child: Icon(
                                  Icons.error_outline,
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        widget.pet.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: widget.isSelected
                                      ? colorScheme.onPrimaryContainer
                                      : null,
                                ),
                      ),
                      subtitle: Text(
                        '${widget.pet.species} • ${widget.pet.breed}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: widget.isSelected
                                  ? colorScheme.onPrimaryContainer
                                      .withOpacity(0.8)
                                  : null,
                            ),
                      ),
                      trailing: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: widget.isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: colorScheme.primary,
                                size: 28,
                                key: const ValueKey('selected'),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                key: const ValueKey('unselected'),
                                child: Text(
                                  'Escolher',
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
