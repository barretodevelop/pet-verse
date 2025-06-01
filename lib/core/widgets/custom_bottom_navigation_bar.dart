// widgets/custom_bottom_navigation_bar.dart

import 'package:flutter/material.dart';
import 'package:petverse/core/theme/app_theme.dart';
// Importe seu modelo
// import 'models/bottom_nav_item.dart';

/// Uma Bottom Navigation Bar personalizada, dinâmica e reutilizável.
///
/// Ela é construída com uma lista de [items] e exibe um botão central flutuante.
/// O estado de seleção é controlado externamente através de [selectedIndex] e [onItemTapped].
class CustomBottomNavigationBar extends StatelessWidget {
  /// A lista de itens a serem exibidos na barra. Geralmente 4 itens para um bom visual.
  final List<BottomNavItem> items;

  /// O índice do item atualmente selecionado.
  final int selectedIndex;

  /// Callback chamado quando um item da barra é tocado.
  final ValueChanged<int> onItemTapped;

  /// O ícone para o botão central.
  final IconData centerIcon;

  /// Callback chamado quando o botão central é pressionado.
  final VoidCallback? onCenterButtonPressed;

  const CustomBottomNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemTapped,
    this.centerIcon = Icons.toys,
    this.onCenterButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Garante que a lista de itens seja dividida corretamente ao redor do botão central.
    final int midpoint = (items.length / 2).ceil();
    final List<BottomNavItem> firstHalf = items.sublist(0, midpoint);
    final List<BottomNavItem> secondHalf = items.sublist(midpoint);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // Sombra mais suave
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        // borderRadius: const BorderRadius.only(
        //   topLeft: Radius.circular(24),
        //   topRight: Radius.circular(24),
        // ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Mapeia a primeira metade dos itens
              ...List.generate(firstHalf.length, (index) {
                return _buildNavItem(
                  context,
                  index,
                  firstHalf[index],
                );
              }),

              // Botão Central
              _buildCenterButton(context),

              // Mapeia a segunda metade dos itens
              ...List.generate(secondHalf.length, (index) {
                final itemIndex = index + midpoint;
                return _buildNavItem(
                  context,
                  itemIndex,
                  secondHalf[index],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, BottomNavItem item) {
    final isSelected = index == selectedIndex;
    final color = isSelected ? AppTheme.primary : Colors.grey.shade600;

    return Expanded(
      child: InkWell(
        onTap: () => onItemTapped(index),
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.primary,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context) {
    return Transform.translate(
      // Eleva o botão central um pouco para fora da barra
      offset: const Offset(0, -20),
      child: GestureDetector(
        onTap: onCenterButtonPressed,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(119, 30, 136, 229),
                Color.lerp(Colors.blue.shade600, Colors.cyan.shade500, 0.4)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: AppTheme.primary,
                blurRadius: 15,
                spreadRadius: 2,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Icon(centerIcon, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}

// Classe modelo que deve ser importada
class BottomNavItem {
  final IconData icon;
  final String label;
  BottomNavItem({required this.icon, required this.label});
}
