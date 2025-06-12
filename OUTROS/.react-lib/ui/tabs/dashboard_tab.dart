import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/app_notifier.dart'; // Para acessar o appServiceProvider
import '../../models/pet.dart'; // Para a lista de pets
import '../components/bottom_sheet.dart'; // Para abrir sheets

// --- Widgets Auxiliares para a Dashboard ---

// PetsListSheet (para mostrar listas de pets em BottomSheets)
class PetsListSheet extends ConsumerWidget {
  final bool show;
  final VoidCallback onClose;
  final List<Pet> pets;
  final String title;

  const PetsListSheet({
    super.key,
    required this.show,
    required this.onClose,
    required this.pets,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(appServiceProvider.select((state) => state.isDark));

    return AppBottomSheet(
      show: show,
      onClose: onClose,
      title: title,
      fullHeight: true,
      children: pets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '🐾',
                    style: TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum pet encontrado nesta categoria.',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, // Corrected
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  color: isDark ? Colors.grey.shade800 : Colors.white, // Corrected
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.emoji,
                          style: const TextStyle(fontSize: 40),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${pet.name} (Nível ${pet.level})',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                '${pet.rarity} • ${pet.category}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600, // Corrected
                                ),
                              ),
                              if (pet.diedAt != null)
                                Text(
                                  '💀 Faleceu em: ${DateTime.fromMillisecondsSinceEpoch(pet.diedAt!).toLocal().toString().split(' ')[0]}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (pet.returnedAt != null)
                                Text(
                                  '🔄 Devolvido em: ${DateTime.fromMillisecondsSinceEpoch(pet.returnedAt!).toLocal().toString().split(' ')[0]}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (pet.isUnique && pet.prompt != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Prompt IA: "${pet.prompt}"',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: isDark
                                          ? Colors.grey.shade500
                                          : Colors.grey.shade700, // Corrected
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (pet.accessories.isNotEmpty)
                          Row(
                            children: pet.accessories
                                .map((acc) => Text(acc.emoji, style: const TextStyle(fontSize: 20)))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// InventoryFullSheet (para mostrar o inventário completo em BottomSheets)
class InventoryFullSheet extends ConsumerWidget {
  final bool show;
  final VoidCallback onClose;

  const InventoryFullSheet({
    super.key,
    required this.show,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(appServiceProvider.select((state) => state.inventory));
    final isDark = ref.watch(appServiceProvider.select((state) => state.isDark));

    // Estado local para o filtro de categorias
    final ValueNotifier<String> filter = ValueNotifier<String>('todos');

    final categories = ['todos', ...inventory.map((item) => item.category).toSet().toList()];

    return AppBottomSheet(
      show: show,
      onClose: onClose,
      title: 'Meu Inventário',
      fullHeight: true,
      children: Column(
        children: [
          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ValueListenableBuilder<String>(
              valueListenable: filter,
              builder: (context, currentFilter, child) {
                return Row(
                  children: categories.map((category) {
                    final isSelected = currentFilter == category;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            filter.value = category;
                          }
                        },
                        selectedColor: Colors.purple.shade500,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.grey.shade300 : Colors.grey.shade700), // Corrected
                          fontWeight: FontWeight.w500,
                        ),
                        backgroundColor:
                            isDark ? Colors.grey.shade700 : Colors.grey.shade100, // Corrected
                        side: BorderSide(
                          color: isSelected
                              ? Colors.purple.shade500
                              : (isDark ? Colors.grey.shade600 : Colors.grey.shade300), // Corrected
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          // Itens do Inventário
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: filter,
              builder: (context, currentFilter, child) {
                final filteredItems = currentFilter == 'todos'
                    ? inventory
                    : inventory.where((item) => item.category == currentFilter).toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '📦',
                          style: TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum item encontrado nesta categoria.',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                isDark ? Colors.grey.shade400 : Colors.grey.shade600, // Corrected
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.8, // Ajuste para melhor visualização dos cards
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return Card(
                      color: isDark ? Colors.grey.shade800 : Colors.white, // Corrected
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item.effect,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600, // Corrected
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- DashboardTab Principal ---
class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab> {
  bool _showPetsActive = false;
  bool _showPetsDead = false;
  bool _showPetsReturned = false;
  bool _showPetsUnique = false;
  bool _showInventory = false;

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appServiceProvider);
    // Directly access properties from appState now
    final user = appState.user;
    final pets = appState.pets;
    final inventory = appState.inventory;
    final returnedPets = appState.returnedPets;
    final deadPets = appState.deadPets;
    final uniquePets = appState.uniquePets;
    final isDark = appState.isDark;
    final maxSlots =
        ref.read(appServiceProvider.notifier).maxSlots; // Call getter on notifier instance
    // Corrected hasSoloPet to be a getter on AppNotifier if it depends on internal state
    final hasSoloPet = ref.read(appServiceProvider.notifier).hasSoloPet;

    // Calcula a taxa de sucesso
    final totalPetsConsidered = pets.length + deadPets.length;
    final successRate = totalPetsConsidered > 0 ? (pets.length / totalPetsConsidered) : 0.0;

    Color getSuccessRateColor(double rate) {
      if (rate > 0.7) return Colors.green.shade500;
      if (rate > 0.4) return Colors.yellow.shade700;
      return Colors.red.shade500;
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A202C) : null, // bg-gray-900
            gradient: isDark
                ? null
                : const LinearGradient(
                    colors: [
                      Color(0xFFF3E8FF), // purple-100
                      Color(0xFFE0F2FE), // blue-100
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // User Profile Card (simplificado, o detalhe está no UserProfileSheet)
              Card(
                color: isDark ? Colors.grey.shade800 : Colors.white, // Corrected
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Text(user?.avatar ?? '❓', style: const TextStyle(fontSize: 48)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.username ?? 'Convidado',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(LucideIcons.star,
                                    size: 18, color: Colors.yellow.shade700), // Corrected
                                const SizedBox(width: 4),
                                Text(
                                  'Nível ${user?.level ?? 1}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        isDark ? Colors.white70 : Colors.grey.shade700, // Corrected
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (user?.xp ?? 0) % 100 / 100, // Progresso do XP no nível atual
                              backgroundColor:
                                  isDark ? Colors.grey.shade600 : Colors.grey.shade300, // Corrected
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                            ),
                            Text(
                              '${(user?.xp ?? 0) % 100}/100 XP para o próximo nível',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade700, // Corrected
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Stats
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Desabilita rolagem do GridView
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _StatCard(
                    icon: '🐾',
                    label: 'Pets Ativos',
                    value: pets.length,
                    onTap: () => setState(() => _showPetsActive = true),
                    isDark: isDark,
                  ),
                  _StatCard(
                    icon: '📦',
                    label: 'Inventário',
                    value: inventory.length,
                    onTap: () => setState(() => _showInventory = true),
                    isDark: isDark,
                  ),
                  _StatCard(
                    icon: '✨',
                    label: 'Pets Únicos',
                    value: uniquePets.length,
                    onTap: () => setState(() => _showPetsUnique = true),
                    isDark: isDark,
                    gradient: const LinearGradient(
                      colors: [Colors.yellow, Colors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  _StatCard(
                    icon: '🔄',
                    label: 'Devolvidos',
                    value: returnedPets.length,
                    onTap: () => setState(() => _showPetsReturned = true),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Resumo Geral e Pets Falecidos
              Card(
                color: isDark ? Colors.grey.shade800 : Colors.white, // Corrected
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Resumo Geral',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Total Adotados',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600, // Corrected
                                ),
                              ),
                              Text(
                                '${pets.length + returnedPets.length + deadPets.length}',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Taxa de Sucesso',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600, // Corrected
                                ),
                              ),
                              Text(
                                '${(successRate * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: getSuccessRateColor(successRate),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _showPetsDead = true),
                        icon: const Icon(LucideIcons.skull, size: 20),
                        label: Text('Ver pets falecidos (${deadPets.length})'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.grey.shade700 : Colors.grey.shade100, // Corrected
                          foregroundColor:
                              isDark ? Colors.grey.shade300 : Colors.grey.shade700, // Corrected
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Modals para as listas de pets e inventário
        PetsListSheet(
          show: _showPetsActive,
          onClose: () => setState(() => _showPetsActive = false),
          pets: pets,
          title: 'Pets Ativos',
        ),
        PetsListSheet(
          show: _showPetsDead,
          onClose: () => setState(() => _showPetsDead = false),
          pets: deadPets,
          title: 'Pets Falecidos',
        ),
        PetsListSheet(
          show: _showPetsReturned,
          onClose: () => setState(() => _showPetsReturned = false),
          pets: returnedPets,
          title: 'Pets Devolvidos',
        ),
        PetsListSheet(
          show: _showPetsUnique,
          onClose: () => setState(() => _showPetsUnique = false),
          pets: uniquePets,
          title: 'Pets Únicos',
        ),
        InventoryFullSheet(
          show: _showInventory,
          onClose: () => setState(() => _showInventory = false),
        ),
      ],
    );
  }
}

// Widget auxiliar para os cartões de estatísticas na Dashboard
class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final int value;
  final VoidCallback onTap;
  final bool isDark;
  final LinearGradient? gradient;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    required this.isDark,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isDark ? Colors.grey.shade800 : Colors.white, // Corrected
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.0),
            gradient: gradient, // Adiciona o gradiente se fornecido
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, // Corrected
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
