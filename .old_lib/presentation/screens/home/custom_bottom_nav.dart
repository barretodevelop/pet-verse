import 'package:flutter/material.dart';
import 'package:petverse/core/config/theme_config.dart';

class ProfessionalBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CustomBottomNavItem> items;
  final int? centerButtonIndex; // Index do botão central (normalmente 2 para 5 itens)

  const ProfessionalBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.centerButtonIndex,
  });

  @override
  State<ProfessionalBottomNav> createState() => _ProfessionalBottomNavState();
}

class _ProfessionalBottomNavState extends State<ProfessionalBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rippleController;
  late List<AnimationController> _itemControllers;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Controladores individuais para cada item
    _itemControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    // Anima o item selecionado inicialmente
    if (widget.currentIndex < _itemControllers.length) {
      _itemControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(ProfessionalBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Anima saída do item anterior
      if (oldWidget.currentIndex < _itemControllers.length) {
        _itemControllers[oldWidget.currentIndex].reverse();
      }
      // Anima entrada do novo item
      if (widget.currentIndex < _itemControllers.length) {
        _itemControllers[widget.currentIndex].forward();
        _triggerRipple();
      }
    }
  }

  void _triggerRipple() {
    _rippleController.reset();
    _rippleController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rippleController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Container principal da navbar
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.1 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.currentIndex;
              final isCenterButton = widget.centerButtonIndex == index;

              return Expanded(
                child: _buildNavItem(
                  index: index,
                  item: item,
                  isSelected: isSelected,
                  isCenterButton: isCenterButton,
                  isDark: isDark,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required int index,
    required CustomBottomNavItem item,
    required bool isSelected,
    required bool isCenterButton,
    required bool isDark,
  }) {
    if (isCenterButton) {
      return _buildCenterPetButton(index, item, isSelected, isDark);
    }

    return _buildRegularNavItem(index, item, isSelected, isDark);
  }

  Widget _buildCenterPetButton(int index, CustomBottomNavItem item, bool isSelected, bool isDark) {
    return Positioned(
      top: -25,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () {
          widget.onTap(index);
          _triggerRipple();
        },
        child: Container(
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ripple effect
              AnimatedBuilder(
                animation: _rippleController,
                builder: (context, child) {
                  return Container(
                    width: 65 + (_rippleController.value * 15),
                    height: 65 + (_rippleController.value * 15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ThemeConfig.primaryColor.withOpacity(
                        0.2 * (1 - _rippleController.value),
                      ),
                    ),
                  );
                },
              ),
              // Botão principal flutuante
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                width: isSelected ? 65 : 60,
                height: isSelected ? 65 : 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSelected
                        ? [
                            ThemeConfig.primaryColor,
                            ThemeConfig.primaryColor.withOpacity(0.8),
                          ]
                        : [
                            ThemeConfig.primaryColor.withOpacity(0.9),
                            ThemeConfig.primaryColor.withOpacity(0.7),
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeConfig.primaryColor.withOpacity(0.4),
                      blurRadius: isSelected ? 20 : 15,
                      offset: const Offset(0, 8),
                      spreadRadius: isSelected ? 3 : 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: AnimatedScale(
                  scale: isSelected ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: Colors.white,
                    size: isSelected ? 30 : 26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegularNavItem(int index, CustomBottomNavItem item, bool isSelected, bool isDark) {
    final isCenterButton = widget.centerButtonIndex == index;

    // Se for o botão central, retorna um espaço vazio
    if (isCenterButton) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: AnimatedBuilder(
        animation: _itemControllers[index],
        builder: (context, child) {
          final animationValue = _itemControllers[index].value;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Container do ícone com animação
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  padding: EdgeInsets.all(8 + (animationValue * 3)),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ThemeConfig.primaryColor.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: ThemeConfig.primaryColor.withOpacity(0.3),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Transform.scale(
                    scale: 1.0 + (animationValue * 0.15),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected
                          ? ThemeConfig.primaryColor
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                // Label com animação e controle de overflow
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? ThemeConfig.primaryColor
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    child: Transform.translate(
                      offset: Offset(0, -animationValue * 1),
                      child: Text(
                        item.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Custom bottom navigation item (mantendo sua classe original)
class CustomBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const CustomBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
