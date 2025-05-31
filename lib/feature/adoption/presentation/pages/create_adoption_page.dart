// lib/feature/adoption/presentation/pages/create_adoption_page.dart
// ATUALIZADO: Usa UnifiedUserStateProvider e AdoptionFlowService para fluxo robusto

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/model/firebase_pet_model.dart';
import 'package:petverse/core/providers/firebase_adoption_provider.dart';
import 'package:petverse/core/providers/unified_user_state_provider.dart';
import 'package:petverse/core/services/adoption_flow_service.dart';
import 'package:petverse/core/utils/app_utils.dart';

class CreateAdoptionPage extends ConsumerStatefulWidget {
  const CreateAdoptionPage({super.key});

  @override
  ConsumerState<CreateAdoptionPage> createState() => _CreateAdoptionPageState();
}

class _CreateAdoptionPageState extends ConsumerState<CreateAdoptionPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);

    // Inicializar dados do Firebase na primeira execução
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFirebaseData();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeFirebaseData() async {
    try {
      await ref.read(initializeMockDataProvider.future);
    } catch (e) {
      print('Erro ao inicializar dados: $e');
    }
  }

  void _togglePetSelection(FirebasePetModel pet) {
    HapticFeedback.lightImpact();
    ref.read(selectedCollaborativePetsProvider.notifier).togglePet(pet.id);
  }

  Future<void> _createAdoption() async {
    // NOVO: Verificar se pode criar usando provider unificado
    final canCreate = ref.read(canCreateRequestProvider);
    if (!canCreate) {
      AppUtils.showErrorSnackbar(
          context, 'Não é possível criar solicitação no momento');
      return;
    }

    final selectedPets = ref.read(selectedCollaborativePetsProvider);
    final unifiedState = ref.read(unifiedUserStateProvider);
    final user = unifiedState.user;

    if (selectedPets.length != 3 || user == null) {
      AppUtils.showErrorSnackbar(context, 'Selecione exatamente 3 pets');
      return;
    }

    // NOVO: Usar AdoptionFlowService para execução robusta
    final requestId = await AdoptionFlowService.executeCreateRequestFlow(
      context: context,
      ref: ref,
      selectedPetIds: selectedPets,
      codename: _generateCodename(user),
      colorTheme: _generateColorTheme(user),
      codedMessage: _generateCodedMessage(user),
      personalityTags: _generatePersonalityTags(user),
      region: _generateRegion(user),
    );

    if (requestId != null && mounted) {
      // Limpar seleção apenas se sucesso
      ref.read(selectedCollaborativePetsProvider.notifier).clear();
    }
  }

  String _generateCodename(user) {
    final prefixes = ['Guardian', 'Protetor', 'Anjo', 'Sombra', 'Mestre'];
    final suffixes = ['Azul', 'Rosa', 'Verde', 'Dourado', 'Prata', 'Violeta'];

    final prefix = prefixes[user.level % prefixes.length];
    final suffix = suffixes[user.id.hashCode % suffixes.length];

    return '$prefix $suffix';
  }

  int _generateColorTheme(user) {
    final colors = [
      0xFF3B82F6, // Azul
      0xFFEC4899, // Rosa
      0xFF10B981, // Verde
      0xFFF59E0B, // Dourado
      0xFF8B5CF6, // Violeta
      0xFF06B6D4, // Ciano
    ];

    return colors[user.id.hashCode % colors.length];
  }

  String _generateCodedMessage(user) {
    final messages = [
      'Colaborador experiente busca parceiro dedicado para missão especial',
      'Primeira missão em grupo, procuro mentor experiente',
      'Veterano em missão urgente, preciso de parceiro confiável',
      'Busco parceiro ativo para pets de alta energia - aventura garantida!',
      'Mestre experiente oferece sabedoria em troca de companhia',
    ];

    return messages[user.level % messages.length];
  }

  List<String> _generatePersonalityTags(user) {
    final allTags = [
      'dedicado',
      'organizado',
      'carinhoso',
      'iniciante',
      'entusiasmado',
      'responsável',
      'experiente',
      'paciente',
      'líder',
      'ativo',
      'aventureiro',
      'energético',
      'sábio',
      'mentor',
      'compassivo',
    ];

    final selectedTags = <String>[];
    final baseIndex = user.id.hashCode % allTags.length;

    for (int i = 0; i < 3; i++) {
      final index = (baseIndex + i * 2) % allTags.length;
      selectedTags.add(allTags[index]);
    }

    return selectedTags;
  }

  String _generateRegion(user) {
    final regions = [
      'Zona Sul - SP',
      'Centro - RJ',
      'Zona Norte - SP',
      'Zona Oeste - SP',
      'Interior - SP',
      'Centro - MG',
    ];

    return regions[user.id.hashCode % regions.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F8FF),
              Color(0xFFFFFFFF),
              Color(0xFFF0F8FF),
              Color(0xFFFAF8FF),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: _buildContent(),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icon(
          Icons.arrow_back,
          color: const Color(0xFF0F172A),
          size: 24.sp,
        ),
      ),
      title: Text(
        'Criar Nova Adoção',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            ref.invalidate(availableCollaborativePetsProvider);
            ref.invalidate(initializeMockDataProvider);
          },
          icon: Icon(
            Icons.refresh,
            color: const Color(0xFF64748B),
            size: 24.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    // NOVO: Verificar pré-condições usando provider unificado
    final canCreate = ref.watch(canCreateRequestProvider);
    final isInTransition = ref.watch(isInTransitionProvider);

    if (!canCreate && !isInTransition) {
      return _buildCannotCreateState();
    }

    final initializationAsync = ref.watch(initializeMockDataProvider);

    return initializationAsync.when(
      data: (isInitialized) {
        if (!isInitialized) {
          return _buildInitializationError();
        }
        return _buildMainContent();
      },
      loading: () => _buildLoadingState(),
      error: (error, __) => _buildInitializationError(),
    );
  }

  Widget _buildCannotCreateState() {
    final unifiedState = ref.watch(unifiedUserStateProvider);
    String message;
    String action;

    if (!unifiedState.isAuthenticated) {
      message = 'Você precisa estar logado para criar uma solicitação';
      action = 'Fazer Login';
    } else if (unifiedState.hasActiveRequest) {
      message = 'Você já possui uma solicitação ativa';
      action = 'Ver Solicitação';
    } else if (unifiedState.hasPet) {
      message = 'Você já possui um pet';
      action = 'Ver Pet';
    } else {
      message = 'Não é possível criar solicitação no momento';
      action = 'Voltar';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.block,
            size: 80.sp,
            color: const Color(0xFFEF4444),
          ),
          SizedBox(height: 16.h),
          Text(
            'Ação Bloqueada',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: Text(action),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final petsAsync = ref.watch(availableCollaborativePetsProvider);
    final selectedPets = ref.watch(selectedCollaborativePetsProvider);

    return petsAsync.when(
      data: (pets) {
        if (pets.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            if (selectedPets.isNotEmpty)
              _buildSelectedPetsPreview(pets, selectedPets),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedPets.isEmpty) _buildHeader(),
                    SizedBox(height: selectedPets.isEmpty ? 20.h : 0),
                    _buildPetsGrid(pets),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stackTrace) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildInitializationError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_outlined,
            size: 64.sp,
            color: const Color(0xFFF59E0B),
          ),
          SizedBox(height: 16.h),
          Text(
            'Erro na Inicialização',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Não foi possível inicializar os dados do Firebase. '
              'Verifique sua conexão e tente novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(initializeMockDataProvider);
              ref.invalidate(availableCollaborativePetsProvider);
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets_rounded,
              color: const Color(0xFF3B82F6),
              size: 40.sp,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 2000.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
                duration: 1000.ms,
              ),
          SizedBox(height: 24.h),
          Text(
            'Carregando Pets Disponíveis...',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              'Conectando com o Firebase...',
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets_outlined,
            size: 80.sp,
            color: const Color(0xFF64748B),
          ),
          SizedBox(height: 16.h),
          Text(
            'Nenhum Pet Disponível',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Não há pets disponíveis para adoção\ncolaborativa no momento.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(availableCollaborativePetsProvider);
            },
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80.sp,
            color: const Color(0xFFEF4444),
          ),
          SizedBox(height: 16.h),
          Text(
            'Erro ao Carregar',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(availableCollaborativePetsProvider);
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B82F6).withOpacity(0.1),
            const Color(0xFF1E40AF).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF3B82F6).withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF3B82F6),
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  'Como funciona?',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '1. Escolha exatamente 3 pets que você gostaria de cuidar\n'
            '2. Sua adoção será publicada na lista por 5 dias\n'
            '3. Alguém verá sua adoção e escolherá 1 dos 3 pets\n'
            '4. Vocês começarão a cuidar do pet juntos!',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF374151),
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildPetsGrid(List<FirebasePetModel> pets) {
    final selectedPets = ref.watch(selectedCollaborativePetsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Pets Disponíveis',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${selectedPets.length}/3',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          'Selecione exatamente 3 pets para criar sua adoção',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.9,
          ),
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];
            final isSelected = selectedPets.contains(pet.id);
            final canSelect = selectedPets.length < 3 || isSelected;

            return _buildPetCard(pet, isSelected, canSelect, index);
          },
        ),
      ],
    );
  }

  Widget _buildPetCard(
      FirebasePetModel pet, bool isSelected, bool canSelect, int index) {
    return GestureDetector(
      onTap: canSelect ? () => _togglePetSelection(pet) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10B981).withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981)
                : canSelect
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFFE2E8F0).withOpacity(0.5),
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF10B981).withOpacity(0.2)
                  : const Color(0xFF64748B).withOpacity(0.08),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      pet.photo,
                      style: TextStyle(fontSize: 28.sp),
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: -2.h,
                    right: -2.w,
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.w),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 10.sp,
                      ),
                    )
                        .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true))
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.2, 1.2),
                          duration: 1000.ms,
                        ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              pet.name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${pet.type} • ${pet.age}',
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
            if (pet.traits.isNotEmpty)
              Flexible(
                child: Wrap(
                  spacing: 4.w,
                  runSpacing: 2.h,
                  alignment: WrapAlignment.center,
                  children: pet.traits.take(2).map((trait) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF10B981).withOpacity(0.2)
                            : const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        trait,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF10B981)
                              : const Color(0xFF3B82F6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
            if (!canSelect && !isSelected)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  'Limite atingido',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: const Color(0xFF94A3B8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }

  Widget _buildSelectedPetsPreview(
      List<FirebasePetModel> allPets, List<String> selectedPetIds) {
    final selectedPets =
        allPets.where((pet) => selectedPetIds.contains(pet.id)).toList();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.2),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: const Color(0xFF10B981),
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Pets Selecionados',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              ...selectedPets.map((pet) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                        right: selectedPets.last == pet ? 0 : 8.w),
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          pet.photo,
                          style: TextStyle(fontSize: 18.sp),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          pet.name,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              ...List.generate(3 - selectedPets.length, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 8.w),
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        style: BorderStyle.solid,
                        width: 1.w,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.add,
                          color: const Color(0xFF94A3B8),
                          size: 18.sp,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Vazio',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          if (selectedPets.length < 3)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                'Selecione mais ${3 - selectedPets.length} pet(s)',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF64748B),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildBottomBar() {
    final selectedPets = ref.watch(selectedCollaborativePetsProvider);
    final canCreate = selectedPets.length == 3;
    final isInTransition = ref.watch(isInTransitionProvider);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${selectedPets.length} de 3 pets selecionados',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: canCreate
                          ? const Color(0xFF10B981)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  if (!canCreate)
                    Text(
                      'Selecione ${3 - selectedPets.length} pet(s) restante(s)',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            GestureDetector(
              onTap: canCreate && !isInTransition ? _createAdoption : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: canCreate && !isInTransition
                      ? const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        )
                      : null,
                  color: canCreate && !isInTransition
                      ? null
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: canCreate && !isInTransition
                      ? [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isInTransition) ...[
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.w,
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ] else ...[
                      Icon(
                        Icons.add_circle_outline,
                        color:
                            canCreate ? Colors.white : const Color(0xFF94A3B8),
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      isInTransition ? 'Criando...' : 'Criar Adoção',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: canCreate && !isInTransition
                            ? Colors.white
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
