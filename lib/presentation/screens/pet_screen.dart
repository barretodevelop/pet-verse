import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/data/models/adoption_request_status.dart';
import 'package:petverse/data/models/join_adoptn_modal.dart';
import 'package:petverse/data/models/pet.dart';
import 'package:petverse/data/models/pet_detail_modal.dart';
import 'package:petverse/data/models/user_currency.dart';
import 'package:petverse/presentation/providers/currency_provider.dart';
import 'package:petverse/presentation/providers/pet_provider.dart';
import 'package:petverse/presentation/providers/theme_provider.dart';
import 'package:petverse/presentation/widgets/my_doption_request_modal.dart';

/// Tela principal de pets e adoção
class PetScreen extends ConsumerStatefulWidget {
  const PetScreen({super.key});

  @override
  ConsumerState<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends ConsumerState<PetScreen>
    with TickerProviderStateMixin {
  late AnimationController _pageAnimationController;
  late AnimationController _petActionController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Constantes de custo e recompensa
  static const int petGenerationCost = 20;
  static const int adoptionRewardCoins = 100;
  static const int feedCost = 10;
  static const int playCost = 5;
  static const int restCost = 8;
  static const int playXpReward = 10;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _pageAnimationController.forward();
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _petActionController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _petActionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _petActionController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(isLightThemeProvider);
    final userCurrency = ref.watch(userCurrencyProvider);
    final adoptionFlowState = ref.watch(adoptionFlowStateProvider);
    final currentPet = ref.watch(currentAdoptedPetProvider);

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            color: isLightTheme ? Colors.blue[50] : Colors.blue[900],
            child: _buildContent(
                isLightTheme, userCurrency, adoptionFlowState, currentPet),
          ),
        );
      },
    );
  }

  /// Constrói o conteúdo baseado no estado atual
  Widget _buildContent(
    bool isLightTheme,
    UserCurrency userCurrency,
    AdoptionFlowStates adoptionFlowState,
    Pet? currentPet,
  ) {
    switch (adoptionFlowState) {
      case AdoptionFlowStates.noPet:
        return _buildNoPetView(isLightTheme);
      case AdoptionFlowStates.creatingRequest:
        return _buildCreatingRequestView(isLightTheme, userCurrency);
      case AdoptionFlowStates.adoptExistingFlow:
        return _buildAdoptExistingView(isLightTheme);
      case AdoptionFlowStates.adoptWithFriendFlow:
        return _buildAdoptWithFriendView(isLightTheme, userCurrency);
      case AdoptionFlowStates.requestActive:
        return _buildRequestActiveView(isLightTheme);
      case AdoptionFlowStates.hasPet:
        return _buildHasPetView(isLightTheme, userCurrency, currentPet!);
    }
  }

  /// Vista quando não há pet
  Widget _buildNoPetView(bool isLightTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isLightTheme ? Colors.grey[200] : Colors.grey[700],
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: isLightTheme ? Colors.grey[300]! : Colors.grey[600]!,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.pets,
                size: 60,
                color: isLightTheme ? Colors.grey[400] : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ainda não há um companheiro\npeludo esperando por você!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isLightTheme ? Colors.grey[600] : Colors.grey[300],
                fontSize: 18,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            _buildActionButton(
              'Criar Solicitação de Adoção',
              Icons.add_circle,
              Colors.purple,
              () => _setAdoptionFlow(AdoptionFlowStates.creatingRequest),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              'Adotar Pet Existente',
              Icons.pets,
              Colors.green,
              () => _setAdoptionFlow(AdoptionFlowStates.adoptExistingFlow),
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              'Adoção com Amigo',
              Icons.link,
              Colors.orange,
              () => _setAdoptionFlow(AdoptionFlowStates.adoptWithFriendFlow),
            ),
          ],
        ),
      ),
    );
  }

  /// Vista para criar solicitação
  Widget _buildCreatingRequestView(
      bool isLightTheme, UserCurrency userCurrency) {
    final selectedPets = ref.watch(selectedPetsForMyRequestIdsProvider);
    final availablePets = ref.watch(availablePetsNotAdoptedProvider);
    final message = ref.watch(friendAdoptionMessageProvider);
    final isGenerating = ref.watch(generatingUniquePetProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: isLightTheme ? Colors.white : Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Crie sua Solicitação de Adoção!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isLightTheme ? Colors.purple[800] : Colors.purple[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sua solicitação será ativa por 5 dias. Escolha 3 pets para que outro adotador selecione um deles.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isLightTheme ? Colors.grey[700] : Colors.grey[200],
              ),
            ),
            const SizedBox(height: 24),

            // Botão para gerar pet único
            ElevatedButton.icon(
              onPressed: isGenerating ? null : _generateUniquePet,
              icon: isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lightbulb_outline),
              label: Text(
                isGenerating
                    ? 'Gerando Pet...'
                    : 'Gerar Novo Pet Único! ($petGenerationCost Gems)',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[500],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Escolha seus Pets (${selectedPets.length}/3)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
              ),
            ),

            if (message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  message,
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Grid de pets
            _buildPetsGrid(
              availablePets
                  .where((pet) =>
                      pet.generatedByUserId == userCurrency.currentUserId ||
                      pet.generatedByUserId == null)
                  .toList(),
              isLightTheme,
              PetDetailMode.createRequest,
            ),

            const SizedBox(height: 24),

            // Botões de ação
            ElevatedButton(
              onPressed:
                  selectedPets.length == 3 ? _confirmAdoptionRequest : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[500],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirmar Solicitação de Adoção',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  /// Vista para adotar pets existentes
  Widget _buildAdoptExistingView(bool isLightTheme) {
    final activeRequests = ref.watch(pendingAdoptionRequestsProvider);
    final userCurrency = ref.watch(userCurrencyProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: isLightTheme ? Colors.white : Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Adoções em Andamento!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isLightTheme ? Colors.green[800] : Colors.green[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Participe de uma solicitação de adoção existente e escolha seu pet!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isLightTheme ? Colors.grey[700] : Colors.grey[200],
              ),
            ),
            const SizedBox(height: 24),

            // Lista de solicitações
            ...activeRequests
                .where((req) => req.creatorUserId != userCurrency.currentUserId)
                .map((request) =>
                    _buildAdoptionRequestCard(request, isLightTheme)),

            const SizedBox(height: 24),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  /// Vista para adoção com amigo
  Widget _buildAdoptWithFriendView(
      bool isLightTheme, UserCurrency userCurrency) {
    final selectedPets = ref.watch(selectedPetsForFriendAdoptionIdsProvider);
    final friendCode = ref.watch(friendAdoptionCodeProvider);
    final message = ref.watch(friendAdoptionMessageProvider);
    final isGenerating = ref.watch(generatingUniquePetProvider);
    final availablePets = ref.watch(availablePetsNotAdoptedProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: isLightTheme ? Colors.white : Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Crie uma Adoção com Amigo!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isLightTheme ? Colors.orange[800] : Colors.orange[400],
              ),
            ),
            const SizedBox(height: 24),

            // Botão para gerar pet único
            ElevatedButton.icon(
              onPressed: isGenerating ? null : _generateUniquePet,
              icon: isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lightbulb_outline),
              label: Text(
                isGenerating
                    ? 'Gerando Pet...'
                    : 'Gerar Novo Pet Único! ($petGenerationCost Gems)',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[500],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            if (friendCode.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.yellow[400]!, Colors.orange[500]!],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Código Gerado!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      friendCode,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Compartilhe este código com seu amigo!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _simulateFriendAdoption,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange[600],
                      ),
                      child: const Text('Simular Adição do Amigo'),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            Text(
              'Escolha 3 Pets (${selectedPets.length}/3)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
              ),
            ),

            if (message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Text(
                  message,
                  style: TextStyle(color: Colors.orange[700]),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Grid de pets
            _buildPetsGrid(
              availablePets,
              isLightTheme,
              PetDetailMode.friendAdoption,
            ),

            const SizedBox(height: 24),

            // Botão para gerar código
            ElevatedButton(
              onPressed: selectedPets.length == 3 && friendCode.isEmpty
                  ? _generateFriendAdoptionCode
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[500],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Gerar Código para Adoção com Amigo',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 12),
            _buildCancelButton(),
          ],
        ),
      ),
    );
  }

  /// Vista quando solicitação está ativa
  Widget _buildRequestActiveView(bool isLightTheme) {
    final requestInfo = ref.watch(adoptionRequestInfoProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: isLightTheme ? Colors.white : Colors.grey[800],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sua Solicitação de Adoção está Ativa!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isLightTheme ? Colors.indigo[800] : Colors.indigo[400],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Aguardando um adotador para se juntar à sua solicitação.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isLightTheme ? Colors.grey[700] : Colors.grey[200],
                ),
              ),
              const SizedBox(height: 32),

              // Estatísticas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    requestInfo['views'].toString(),
                    'Visualizações',
                    Colors.blue,
                  ),
                  _buildStatColumn(
                    '${requestInfo['daysLeft']}',
                    'Dias Restantes',
                    Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _showMyRequestDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ver Detalhes da Solicitação',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 12),
              _buildCancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Vista quando tem pet
  Widget _buildHasPetView(
      bool isLightTheme, UserCurrency userCurrency, Pet pet) {
    final message = ref.watch(friendAdoptionMessageProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: isLightTheme ? Colors.white : Colors.grey[800],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Meu Pet: ${pet.name}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isLightTheme ? Colors.green[800] : Colors.green[400],
              ),
            ),
            const SizedBox(height: 24),

            // Avatar do pet com animação
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLightTheme ? Colors.grey[200] : Colors.grey[700],
                      border: Border.all(
                        color: _getPetBorderColor(pet.level),
                        width: 4 + (pet.level - 1) * 0.5,
                      ),
                    ),
                    child: ClipOval(
                      child: pet.imageUrl.startsWith('data:image')
                          ? Image.memory(
                              base64Decode(pet.imageUrl.split(',')[1]),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.pets, size: 80),
                            )
                          : Image.network(
                              pet.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.pets, size: 80),
                            ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Nível do pet
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[500],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Nível ${pet.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Status bars
            _buildStatusBar('🍔 Fome', pet.hunger, Colors.orange, isLightTheme),
            const SizedBox(height: 12),
            _buildStatusBar(
                '😊 Felicidade', pet.happiness, Colors.pink, isLightTheme),
            const SizedBox(height: 12),
            _buildStatusBar(
                '⚡ Energia', pet.energy, Colors.green, isLightTheme),

            const SizedBox(height: 32),

            // Ações do pet
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPetActionButton(
                  'Alimentar',
                  Icons.restaurant,
                  feedCost,
                  () => _feedPet(userCurrency),
                  Colors.orange,
                ),
                _buildPetActionButton(
                  'Brincar',
                  Icons.sports_soccer,
                  playCost,
                  () => _playWithPet(userCurrency),
                  Colors.blue,
                ),
                _buildPetActionButton(
                  'Descansar',
                  Icons.bed,
                  restCost,
                  () => _restPet(userCurrency),
                  Colors.purple,
                ),
              ],
            ),

            if (message.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  message,
                  style: TextStyle(color: Colors.blue[700]),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Botão de reset (apenas para teste)
            ElevatedButton(
              onPressed: _resetFlow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                foregroundColor: Colors.grey[900],
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Reiniciar Fluxo (Apenas para Teste)'),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói um grid de pets
  Widget _buildPetsGrid(List<Pet> pets, bool isLightTheme, PetDetailMode mode) {
    if (pets.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: isLightTheme ? Colors.grey[100] : Colors.grey[700],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLightTheme ? Colors.grey[300]! : Colors.grey[600]!,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 48,
                color: isLightTheme ? Colors.grey[400] : Colors.grey[500],
              ),
              const SizedBox(height: 8),
              Text(
                'Nenhum pet disponível',
                style: TextStyle(
                  color: isLightTheme ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          return _buildPetCard(pet, isLightTheme, mode);
        },
      ),
    );
  }

  /// Constrói um card de pet
  Widget _buildPetCard(Pet pet, bool isLightTheme, PetDetailMode mode) {
    final isSelected = _isPetSelected(pet.id, mode);

    return GestureDetector(
      onTap: () => _openPetDetailsModal(pet, mode),
      child: Container(
        decoration: BoxDecoration(
          color: isLightTheme ? Colors.white : Colors.grey[700],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.purple[500]!
                : (isLightTheme ? Colors.grey[200]! : Colors.grey[600]!),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.purple.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: Offset(0, isSelected ? 4 : 2),
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
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.purple[300]!,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: pet.imageUrl.startsWith('data:image')
                    ? Image.memory(
                        base64Decode(pet.imageUrl.split(',')[1]),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 30),
                      )
                    : Image.network(
                        pet.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 30),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pet.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              pet.type,
              style: TextStyle(
                fontSize: 12,
                color: isLightTheme ? Colors.grey[600] : Colors.grey[400],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple[500],
                  borderRadius: BorderRadius.circular(8),
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
        ),
      ),
    );
  }

  /// Constrói um botão de ação
  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(
        text,
        style: const TextStyle(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
      ),
    );
  }

  /// Constrói um botão de cancelar
  Widget _buildCancelButton() {
    return TextButton(
      onPressed: () => _setAdoptionFlow(AdoptionFlowStates.noPet),
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 45),
      ),
      child: const Text(
        'Cancelar',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  /// Constrói uma coluna de estatística
  Widget _buildStatColumn(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  /// Constrói um card de solicitação de adoção
  Widget _buildAdoptionRequestCard(AdoptionRequest request, bool isLightTheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, size: 20, color: Colors.indigo[500]),
                const SizedBox(width: 8),
                Text(
                  'Solicitação de Usuário Anônimo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Preview dos pets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: request.petsInRequest.take(3).map((pet) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: ClipOval(
                    child: pet.imageUrl.startsWith('data:image')
                        ? Image.memory(
                            base64Decode(pet.imageUrl.split(',')[1]),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 30),
                          )
                        : Image.network(
                            pet.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 30),
                          ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
            Text(
              'Escolha entre 3 pets incríveis.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isLightTheme ? Colors.grey[600] : Colors.grey[300],
              ),
            ),
            Text(
              'Faltam ${request.actualDaysLeft} dias para a adoção.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isLightTheme ? Colors.grey[500] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _openJoinAdoptionModal(request),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Participar da Adoção'),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói uma barra de status
  Widget _buildStatusBar(
      String label, int value, Color color, bool isLightTheme) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: isLightTheme ? Colors.grey[200] : Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 8),
        Text('$value%', style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  /// Constrói um botão de ação do pet
  Widget _buildPetActionButton(
    String text,
    IconData icon,
    int cost,
    VoidCallback onPressed,
    Color color,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
          ),
          child: Column(
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 4),
              Text(
                '$text\n(${cost}C)',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos auxiliares e ações

  /// Define o estado do fluxo de adoção
  void _setAdoptionFlow(AdoptionFlowStates state) {
    ref.read(adoptionFlowStateProvider.notifier).state = state;
    // Limpa seleções ao mudar de estado
    ref.read(selectedPetsForMyRequestIdsProvider.notifier).state = [];
    ref.read(selectedPetsForFriendAdoptionIdsProvider.notifier).state = [];
    ref.read(friendAdoptionCodeProvider.notifier).state = '';
    ref.read(friendAdoptionMessageProvider.notifier).state = '';
  }

  /// Verifica se um pet está selecionado
  bool _isPetSelected(String petId, PetDetailMode mode) {
    switch (mode) {
      case PetDetailMode.createRequest:
        return ref.read(selectedPetsForMyRequestIdsProvider).contains(petId);
      case PetDetailMode.friendAdoption:
        return ref
            .read(selectedPetsForFriendAdoptionIdsProvider)
            .contains(petId);
      default:
        return false;
    }
  }

  /// Retorna a cor da borda baseada no nível do pet
  Color _getPetBorderColor(int level) {
    if (level >= 10) return const Color(0xFFFFD700); // Dourado
    if (level >= 5) return const Color(0xFFC0C0C0); // Prata
    return const Color(0xFFCD7F32); // Bronze
  }

  /// Abre o modal de detalhes do pet
  void _openPetDetailsModal(Pet pet, PetDetailMode mode) {
    showDialog(
      context: context,
      builder: (context) => PetDetailModal(
        pet: pet,
        mode: mode,
        onClose: () => Navigator.of(context).pop(),
        onSelect: (petId) {
          Navigator.of(context).pop();
          _handlePetSelection(petId, mode);
        },
      ),
    );
  }

  /// Manipula a seleção de pets
  void _handlePetSelection(String petId, PetDetailMode mode) {
    switch (mode) {
      case PetDetailMode.createRequest:
        _handleSelectPetForMyRequest(petId);
        break;
      case PetDetailMode.friendAdoption:
        _handleSelectPetForFriendAdoption(petId);
        break;
      case PetDetailMode.adopt:
        _handleAdoptPetImmediately(petId);
        break;
      default:
        break;
    }
  }

  /// Manipula seleção para solicitação própria
  void _handleSelectPetForMyRequest(String petId) {
    final selectedPets = ref.read(selectedPetsForMyRequestIdsProvider);
    final notifier = ref.read(selectedPetsForMyRequestIdsProvider.notifier);
    final availablePets = ref.read(availablePetsProvider);

    final pet = availablePets.firstWhere((p) => p.id == petId);

    if (pet.isAdopted) {
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Este pet já foi adotado.';
      return;
    }

    if (selectedPets.contains(petId)) {
      notifier.state = selectedPets.where((id) => id != petId).toList();
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Pet "${pet.name}" removido da seleção.';
    } else if (selectedPets.length < 3) {
      notifier.state = [...selectedPets, petId];
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Pet "${pet.name}" adicionado à seleção.';
    } else {
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Você pode selecionar no máximo 3 pets.';
    }
  }

  /// Manipula seleção para adoção com amigo
  void _handleSelectPetForFriendAdoption(String petId) {
    final selectedPets = ref.read(selectedPetsForFriendAdoptionIdsProvider);
    final notifier =
        ref.read(selectedPetsForFriendAdoptionIdsProvider.notifier);
    final availablePets = ref.read(availablePetsProvider);

    final pet = availablePets.firstWhere((p) => p.id == petId);

    if (pet.isAdopted) {
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Este pet já foi adotado.';
      return;
    }

    if (selectedPets.contains(petId)) {
      notifier.state = selectedPets.where((id) => id != petId).toList();
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Pet "${pet.name}" removido da seleção.';
    } else if (selectedPets.length < 3) {
      notifier.state = [...selectedPets, petId];
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Pet "${pet.name}" adicionado à seleção.';
    } else {
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Você pode selecionar no máximo 3 pets.';
    }
  }

  /// Adota um pet imediatamente
  void _handleAdoptPetImmediately(String petId) {
    final availablePets = ref.read(availablePetsProvider);
    final pet = availablePets.firstWhere((p) => p.id == petId);

    ref.read(availablePetsProvider.notifier).markPetAsAdopted(petId);
    ref.read(currentAdoptedPetProvider.notifier).state = pet.copyWith(
      hunger: 80,
      happiness: 70,
      energy: 90,
      level: 1,
      xp: 0,
      xpToNextLevel: 100,
    );

    ref.read(adoptionFlowStateProvider.notifier).state =
        AdoptionFlowStates.hasPet;
    ref.read(userCurrencyProvider.notifier).addCoins(adoptionRewardCoins);
    ref.read(friendAdoptionMessageProvider.notifier).state =
        'Parabéns! Você adotou o pet e recebeu $adoptionRewardCoins Coins!';
  }

  /// Gera um pet único
  void _generateUniquePet() async {
    final userCurrency = ref.read(userCurrencyProvider);

    if (userCurrency.gems < petGenerationCost) {
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Você precisa de $petGenerationCost Gems para gerar um pet único.';
      return;
    }

    ref.read(generatingUniquePetProvider.notifier).state = true;
    ref.read(friendAdoptionMessageProvider.notifier).state = '';

    try {
      // Simula geração de pet único
      await Future.delayed(const Duration(seconds: 2));

      final newPet = Pet(
        id: 'ai-p-${DateTime.now().millisecondsSinceEpoch}',
        name: _generateRandomPetName(),
        type: _generateRandomPetType(),
        description: _generateRandomDescription(),
        imageUrl: 'https://placehold.co/60x60/purple/ffffff?text=🤖',
        isAdopted: false,
        generatedByUserId: userCurrency.currentUserId,
      );

      ref.read(availablePetsProvider.notifier).addPet(newPet);
      ref.read(userCurrencyProvider.notifier).removeGems(petGenerationCost);
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Pet "${newPet.name}" gerado com sucesso!';
    } catch (e) {
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Erro ao gerar pet: $e';
    } finally {
      ref.read(generatingUniquePetProvider.notifier).state = false;
    }
  }

  /// Confirma solicitação de adoção
  void _confirmAdoptionRequest() {
    final selectedPets = ref.read(selectedPetsForMyRequestIdsProvider);
    final availablePets = ref.read(availablePetsProvider);
    final userCurrency = ref.read(userCurrencyProvider);

    final requestId = generateRequestId();
    final petsForRequest =
        availablePets.where((pet) => selectedPets.contains(pet.id)).toList();

    ref.read(activeAdoptionRequestsProvider.notifier).addRequest(
          AdoptionRequest(
            id: requestId,
            creatorUserId: userCurrency.currentUserId,
            petsInRequest: petsForRequest,
            daysLeft: 5,
          ),
        );

    ref.read(adoptionFlowStateProvider.notifier).state =
        AdoptionFlowStates.requestActive;
    ref.read(adoptionRequestInfoProvider.notifier).state = {
      'views': 1,
      'daysLeft': 5,
      'petsSelected': selectedPets,
      'fullPetsSelected': petsForRequest,
    };

    // Limpa seleções
    ref.read(selectedPetsForMyRequestIdsProvider.notifier).state = [];
    ref.read(friendAdoptionMessageProvider.notifier).state = '';
  }

  /// Gera código para adoção com amigo
  void _generateFriendAdoptionCode() {
    final selectedPets = ref.read(selectedPetsForFriendAdoptionIdsProvider);

    if (selectedPets.length != 3) {
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Por favor, selecione exatamente 3 pets antes de gerar o código.';
      return;
    }

    final code = generateAdoptionCode();
    ref.read(friendAdoptionCodeProvider.notifier).state = code;
    ref.read(friendAdoptionMessageProvider.notifier).state =
        'Compartilhe este código: $code';
  }

  /// Simula adoção com amigo
  void _simulateFriendAdoption() {
    final selectedPets = ref.read(selectedPetsForFriendAdoptionIdsProvider);
    final availablePets = ref.read(availablePetsProvider);

    if (selectedPets.length == 3) {
      final petsForFriend =
          availablePets.where((pet) => selectedPets.contains(pet.id)).toList();
      final chosenByFriend =
          petsForFriend[Random().nextInt(petsForFriend.length)];

      ref
          .read(availablePetsProvider.notifier)
          .markPetAsAdopted(chosenByFriend.id);
      ref.read(currentAdoptedPetProvider.notifier).state =
          chosenByFriend.copyWith(
        hunger: 80,
        happiness: 70,
        energy: 90,
        level: 1,
        xp: 0,
        xpToNextLevel: 100,
      );

      ref.read(adoptionFlowStateProvider.notifier).state =
          AdoptionFlowStates.hasPet;
      ref.read(userCurrencyProvider.notifier).addCoins(adoptionRewardCoins);
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Adoção conjunta com ${chosenByFriend.name} concluída!';

      // Limpa estado
      ref.read(selectedPetsForFriendAdoptionIdsProvider.notifier).state = [];
      ref.read(friendAdoptionCodeProvider.notifier).state = '';
    }
  }

  /// Abre modal de participar em adoção
  void _openJoinAdoptionModal(AdoptionRequest request) {
    showDialog(
      context: context,
      builder: (context) => JoinAdoptionModal(
        request: request,
        onClose: () => Navigator.of(context).pop(),
        onChoosePet: (requestId, petId) {
          Navigator.of(context).pop();
          _handleJoinAdoption(requestId, petId);
        },
      ),
    );
  }

  /// Manipula participação em adoção conjunta
  void _handleJoinAdoption(String requestId, String chosenPetId) {
    final userCurrency = ref.read(userCurrencyProvider);
    final availablePets = ref.read(availablePetsProvider);

    ref
        .read(activeAdoptionRequestsProvider.notifier)
        .completeRequest(requestId, userCurrency.currentUserId, chosenPetId);
    ref.read(availablePetsProvider.notifier).markPetAsAdopted(chosenPetId);

    final adoptedPet = availablePets.firstWhere((p) => p.id == chosenPetId);
    ref.read(currentAdoptedPetProvider.notifier).state = adoptedPet.copyWith(
      hunger: 80,
      happiness: 70,
      energy: 90,
      level: 1,
      xp: 0,
      xpToNextLevel: 100,
    );

    ref.read(adoptionFlowStateProvider.notifier).state =
        AdoptionFlowStates.hasPet;
    ref.read(userCurrencyProvider.notifier).addCoins(adoptionRewardCoins);
    ref.read(friendAdoptionMessageProvider.notifier).state =
        'Parabéns! Você adotou um pet em conjunto!';
  }

  /// Mostra detalhes da própria solicitação
  void _showMyRequestDetails() {
    final requestInfo = ref.read(adoptionRequestInfoProvider);

    showDialog(
      context: context,
      builder: (context) => MyAdoptionRequestModal(
        requestInfo: requestInfo,
        petsInRequest: requestInfo['fullPetsSelected'] as List<Pet>,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Ações com o pet
  void _feedPet(UserCurrency userCurrency) {
    if (userCurrency.canAffordCoins(feedCost)) {
      ref.read(userCurrencyProvider.notifier).removeCoins(feedCost);
      _updatePetStats(20, 5, 0, 0);
      _animatePetAction();
    } else {
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Você não tem Coins suficientes para alimentar seu pet!';
    }
  }

  void _playWithPet(UserCurrency userCurrency) {
    if (userCurrency.canAffordCoins(playCost)) {
      ref.read(userCurrencyProvider.notifier).removeCoins(playCost);
      _updatePetStats(-10, 25, -15, playXpReward);
      _animatePetAction();
    } else {
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Você não tem Coins suficientes para brincar com seu pet!';
    }
  }

  void _restPet(UserCurrency userCurrency) {
    if (userCurrency.canAffordCoins(restCost)) {
      ref.read(userCurrencyProvider.notifier).removeCoins(restCost);
      _updatePetStats(-5, 5, 30, 0);
      _animatePetAction();
    } else {
      ref.read(friendAdoptionMessageProvider.notifier).state =
          'Você não tem Coins suficientes para fazer seu pet descansar!';
    }
  }

  /// Atualiza estatísticas do pet
  void _updatePetStats(
      int hungerChange, int happinessChange, int energyChange, int xpChange) {
    final currentPet = ref.read(currentAdoptedPetProvider);
    if (currentPet == null) return;

    final newHunger = (currentPet.hunger + hungerChange).clamp(0, 100);
    final newHappiness = (currentPet.happiness + happinessChange).clamp(0, 100);
    final newEnergy = (currentPet.energy + energyChange).clamp(0, 100);
    int newXp = currentPet.xp + xpChange;
    int newLevel = currentPet.level;
    int newXpToNextLevel = currentPet.xpToNextLevel;

    // Sistema de level up
    if (newXp >= newXpToNextLevel) {
      newLevel += 1;
      newXp = newXp - newXpToNextLevel;
      newXpToNextLevel = (newXpToNextLevel * 1.5).floor();
      ref.read(userCurrencyProvider.notifier).addXp(xpChange);
    } else {
      ref.read(userCurrencyProvider.notifier).addXp(xpChange);
    }

    ref.read(currentAdoptedPetProvider.notifier).state = currentPet.copyWith(
      hunger: newHunger,
      happiness: newHappiness,
      energy: newEnergy,
      xp: newXp,
      level: newLevel,
      xpToNextLevel: newXpToNextLevel,
    );
  }

  /// Anima ação do pet
  void _animatePetAction() {
    _petActionController.forward().then((_) {
      _petActionController.reverse();
    });
  }

  /// Reseta o fluxo (apenas para teste)
  void _resetFlow() {
    ref.read(currentAdoptedPetProvider.notifier).state = null;
    ref.read(adoptionFlowStateProvider.notifier).state =
        AdoptionFlowStates.noPet;
    ref.read(friendAdoptionMessageProvider.notifier).state = '';
  }

  // Métodos auxiliares para geração de pets

  String _generateRandomPetName() {
    final names = [
      'Luna',
      'Max',
      'Bella',
      'Rocky',
      'Zeca',
      'Nina',
      'Thor',
      'Mia'
    ];
    return names[Random().nextInt(names.length)];
  }

  String _generateRandomPetType() {
    final types = [
      'Cachorro Mágico',
      'Gato Cibernético',
      'Dragão de Bolso',
      'Robô-Hamster'
    ];
    return types[Random().nextInt(types.length)];
  }

  String _generateRandomDescription() {
    final descriptions = [
      'Um companheiro leal e cheio de energia.',
      'Adora aventuras e brincadeiras.',
      'Muito carinhoso e protetor.',
      'Inteligente e brincalhão.',
    ];
    return descriptions[Random().nextInt(descriptions.length)];
  }
}
