// lib/presentation/screens/home_screen.dart - CORRIGIDO
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/navigation_helpers.dart';
import '../../core/navigation/route_names.dart';
import '../../core/widgets/custom_bar.dart';
import '../../data/models/pet.dart';
import '../providers/currency_provider.dart';
import '../providers/pet_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with NavigationControlMixin {
  @override
  Widget build(BuildContext context) {
    final availablePetsAsync = ref.watch(availablePetsProvider);
    final userCurrency = ref.watch(userCurrencyProvider);
    final adoptionFlowState = ref.watch(adoptionFlowStateProvider);

    return Scaffold(
      appBar: CustomAppBar(
        onSettingsClick: () => safeNavigateTo(RouteNames.settings),
        onNotificationsClick: () => _showNotifications(),
        userDisplayName: 'Usuário',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refreshPets();
          ref.refreshAdoptionRequests();
        },
        child: CustomScrollView(
          slivers: [
            // Header com ações rápidas
            SliverToBoxAdapter(
              child: _buildQuickActions(),
            ),

            // Status do fluxo de adoção
            SliverToBoxAdapter(
              child: _buildAdoptionStatus(adoptionFlowState),
            ),

            // Lista de pets disponíveis
            availablePetsAsync.when(
              data: (pets) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPetCard(pets[index]),
                  childCount: pets.length,
                ),
              ),
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    children: [
                      Text('Erro: $error'),
                      ElevatedButton(
                        onPressed: () => ref.refreshPets(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ações Rápidas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionCard(
                icon: Icons.add_circle,
                title: 'Gerar Pet',
                onTap: () => safeNavigateTo(RouteNames.petGeneration),
              ),
              _buildActionCard(
                icon: Icons.favorite,
                title: 'Adotar',
                onTap: () => safeNavigateTo(RouteNames.adoptionRequest),
              ),
              _buildActionCard(
                icon: Icons.store,
                title: 'Loja',
                onTap: () => safeNavigateTo(RouteNames.store),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdoptionStatus(AdoptionFlowStates state) {
    switch (state) {
      case AdoptionFlowStates.hasPet:
        return _buildStatusCard(
          icon: Icons.pets,
          title: 'Você tem um pet!',
          subtitle: 'Cuide bem dele',
          color: Colors.green,
        );
      case AdoptionFlowStates.requestActive:
        return _buildStatusCard(
          icon: Icons.schedule,
          title: 'Solicitação ativa',
          subtitle: 'Aguardando participantes',
          color: Colors.orange,
        );
      default:
        return _buildStatusCard(
          icon: Icons.search,
          title: 'Encontre seu pet',
          subtitle: 'Explore os pets disponíveis',
          color: Theme.of(context).primaryColor,
        );
    }
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: () => _navigateToPetDetails(pet),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    pet.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.pets),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pet.type,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pet.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPetDetails(Pet pet) {
    safeNavigateTo(
      '${RouteNames.petDetails}/${pet.id}',
      extra: pet.toJson(),
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Você não tem notificações'),
      ),
    );
  }
}
