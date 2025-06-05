import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/presentation/providers/theme_provider.dart';

/// Navegação customizada sem o item central (Pet)
enum NavigationItem {
  dashboard(0, 'Dashboard', Icons.dashboard_outlined, Icons.dashboard),
  store(1, 'Loja', Icons.store_outlined, Icons.store),
  games(2, 'Games', Icons.games_outlined, Icons.games),
  feed(3, 'Feed', Icons.article_outlined, Icons.article);

  const NavigationItem(
      this.position, this.label, this.outlinedIcon, this.filledIcon);
  final int position;
  final String label;
  final IconData outlinedIcon;
  final IconData filledIcon;
}

/// Widget de navegação inferior customizado
class CustomBottomNavigation extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool showLabels;

  const CustomBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLightTheme = ref.watch(isLightThemeProvider);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: BottomAppBar(
          color: isLightTheme ? Colors.white : Colors.grey[850],
          elevation: 0,
          notchMargin: 8,
          shape: const CircularNotchedRectangle(),
          child: SizedBox(
            height: 70,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final buttonWidth =
                    (screenWidth - 40) / 4; // 40px para espaço central

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Lado esquerdo (Dashboard e Loja)
                      SizedBox(
                        width: buttonWidth,
                        child: _buildNavigationItem(NavigationItem.dashboard,
                            isLightTheme, screenWidth),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: _buildNavigationItem(
                            NavigationItem.store, isLightTheme, screenWidth),
                      ),

                      // Espaço central para o FAB
                      const SizedBox(width: 30),

                      // Lado direito (Games e Feed)
                      SizedBox(
                        width: buttonWidth,
                        child: _buildNavigationItem(
                            NavigationItem.games, isLightTheme, screenWidth),
                      ),
                      SizedBox(
                        width: buttonWidth,
                        child: _buildNavigationItem(
                            NavigationItem.feed, isLightTheme, screenWidth),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói um item da navegação
  Widget _buildNavigationItem(
      NavigationItem item, bool isLightTheme, double screenWidth) {
    // Ajusta o índice para corresponder à navegação (Pet = index 2)
    final adjustedIndex =
        item.position >= 2 ? item.position + 1 : item.position;
    final isSelected = selectedIndex == adjustedIndex;

    // Determina se deve mostrar labels baseado no tamanho da tela
    final shouldShowLabels = showLabels && screenWidth > 320;

    // Ajusta tamanhos baseado na largura da tela
    final iconSize =
        screenWidth < 360 ? (isSelected ? 20 : 18) : (isSelected ? 24 : 22);
    final fontSize =
        screenWidth < 360 ? (isSelected ? 9 : 8) : (isSelected ? 11 : 10);

    return GestureDetector(
      onTap: () => onItemTapped(adjustedIndex),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container do ícone com animação
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(screenWidth < 360 ? 4 : 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isLightTheme ? Colors.purple[50] : Colors.purple[900])
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isSelected ? item.filledIcon : item.outlinedIcon,
                color: isSelected
                    ? (isLightTheme ? Colors.purple[700] : Colors.purple[300])
                    : (isLightTheme ? Colors.grey[600] : Colors.grey[400]),
                size: iconSize.toDouble(),
              ),
            ),

            // Label com animação e proteção contra overflow
            if (shouldShowLabels) ...[
              const SizedBox(height: 2),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: fontSize.toDouble(),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? (isLightTheme
                              ? Colors.purple[700]
                              : Colors.purple[300])
                          : (isLightTheme
                              ? Colors.grey[600]
                              : Colors.grey[400]),
                    ),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget do botão Pet floating central
class PetFloatingButton extends ConsumerStatefulWidget {
  final VoidCallback onPressed;
  final bool isSelected;

  const PetFloatingButton({
    super.key,
    required this.onPressed,
    this.isSelected = false,
  });

  @override
  ConsumerState<PetFloatingButton> createState() => _PetFloatingButtonState();
}

class _PetFloatingButtonState extends ConsumerState<PetFloatingButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Inicia animação de pulse se selecionado
    if (widget.isSelected) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PetFloatingButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(isLightThemeProvider);

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value * _scaleAnimation.value,
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isSelected
                    ? [Colors.purple[400]!, Colors.purple[700]!]
                    : [Colors.purple[500]!, Colors.purple[800]!],
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      Colors.purple.withOpacity(widget.isSelected ? 0.4 : 0.3),
                  blurRadius: widget.isSelected ? 15 : 12,
                  offset: const Offset(0, 6),
                ),
                if (widget.isSelected)
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(27.5),
                onTap: () {
                  _scaleController.forward().then((_) {
                    _scaleController.reverse();
                  });
                  widget.onPressed();
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: widget.isSelected ? 26 : 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget combinado de navegação com botão central
class NavigationWithCenterButton extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final VoidCallback onCenterButtonPressed;

  const NavigationWithCenterButton({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onCenterButtonPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Navigation Bar
        CustomBottomNavigation(
          selectedIndex: selectedIndex,
          onItemTapped: onItemTapped,
        ),

        // Botão central floating
        Positioned(
          left: MediaQuery.of(context).size.width / 2 - 27.5,
          top: -27.5,
          child: PetFloatingButton(
            onPressed: onCenterButtonPressed,
            isSelected: selectedIndex == 2, // Pet é index 2
          ),
        ),
      ],
    );
  }
}

/// Extensão para facilitar o uso
extension NavigationExtensions on BuildContext {
  /// Navega para uma página específica
  void navigateToPage(int index) {
    // Implementar navegação se necessário
  }
}
