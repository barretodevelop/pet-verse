// lib/src/features/adoption/presentation/widgets/available_pet_card.dart
// ALTERAÇÃO: Card com hover effects, animações e visual aprimorado

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/src/features/pets/data/models/pet_model.dart';

class AvailablePetCard extends StatefulWidget {
  final Pet pet;
  final bool isSelected;
  final VoidCallback onTap;

  const AvailablePetCard({
    super.key,
    required this.pet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<AvailablePetCard> createState() => _AvailablePetCardState();
}

class _AvailablePetCardState extends State<AvailablePetCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _selectionController;
  late AnimationController _heartController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _selectionAnimation;
  late Animation<double> _heartAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _selectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.elasticOut,
    ));

    _heartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.elasticOut,
    ));

    if (widget.isSelected) {
      _selectionController.forward();
    }
  }

  @override
  void didUpdateWidget(AvailablePetCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
        _heartController.forward().then((_) {
          _heartController.reverse();
        });
        HapticFeedback.lightImpact();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _selectionController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  String _getAgeText() {
    if (widget.pet.age == 1) {
      return '1 ano';
    } else {
      return '${widget.pet.age} anos';
    }
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
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? colorScheme.primary.withOpacity(0.3)
                        : Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: widget.isSelected ? 12 : (_isHovered ? 8 : 4),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background container
                  AnimatedBuilder(
                    animation: _selectionAnimation,
                    builder: (context, child) => Container(
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? Color.lerp(
                                colorScheme.surface,
                                colorScheme.primaryContainer,
                                _selectionAnimation.value * 0.3,
                              )
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: widget.isSelected
                              ? colorScheme.primary
                              : (_isHovered
                                  ? colorScheme.outline
                                  : Colors.transparent),
                          width: widget.isSelected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Stack(
                          children: [
                            // Pet image
                            Hero(
                              tag: 'available-pet-${widget.pet.id}',
                              child: Container(
                                width: 64,
                                height: 64,
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
                                      color:
                                          colorScheme.surfaceContainerHighest,
                                      child: Icon(
                                        Icons.pets,
                                        color: colorScheme.onSurfaceVariant,
                                        size: 28,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: colorScheme.errorContainer,
                                      child: Icon(
                                        Icons.error_outline,
                                        color: colorScheme.onErrorContainer,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Heart animation overlay
                            if (widget.isSelected)
                              Positioned.fill(
                                child: AnimatedBuilder(
                                  animation: _heartAnimation,
                                  builder: (context, child) => Transform.scale(
                                    scale: _heartAnimation.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: colorScheme.primary
                                            .withOpacity(0.2),
                                      ),
                                      child: Icon(
                                        Icons.favorite,
                                        color: colorScheme.primary,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          widget.pet.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: widget.isSelected
                                        ? colorScheme.onSurface
                                        : null,
                                  ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.pet.species} • ${widget.pet.breed}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: widget.isSelected
                                        ? colorScheme.onSurface.withOpacity(0.8)
                                        : null,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.cake,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getAgeText(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  widget.pet.gender.toLowerCase() == 'macho'
                                      ? Icons.male
                                      : Icons.female,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.pet.gender,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: AnimatedBuilder(
                          animation: _selectionAnimation,
                          builder: (context, child) => Transform.scale(
                            scale: 0.8 + (_selectionAnimation.value * 0.4),
                            child: widget.isSelected
                                ? Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: colorScheme.onPrimary,
                                      size: 20,
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: colorScheme.outline
                                            .withOpacity(0.5),
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: colorScheme.onSurfaceVariant,
                                      size: 20,
                                    ),
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
