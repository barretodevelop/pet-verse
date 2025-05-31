// lib/feature/adoption/presentation/pages/adoption_list_page.dart
// UPDATE: Conectar com FirebaseAdoptionService

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/model/firebase_pet_model.dart'; // NEW: Import Firebase models
import 'package:petverse/core/providers/firebase_adoption_provider.dart'; // NEW: Import Firebase provider

class AdoptionListPage extends ConsumerStatefulWidget {
  // UPDATE: ConsumerStatefulWidget
  const AdoptionListPage({super.key});

  @override
  ConsumerState<AdoptionListPage> createState() =>
      _AdoptionListPageState(); // UPDATE: ConsumerState
}

class _AdoptionListPageState extends ConsumerState<AdoptionListPage>
    with TickerProviderStateMixin {
  // UPDATE: Remover variáveis locais que agora vêm do Firebase
  bool isLoading = true;
  String selectedFilter = 'Todas';

  late AnimationController _pulseController;

  final List<String> filters = [
    'Todas',
    'Urgentes',
    'Novas',
    'Experientes',
    'Filhotes',
    'Especiais',
    'Sênior'
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);

    // NEW: Inicializar dados mock no Firebase
    _initializeFirebaseData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // NEW: Inicializar dados do Firebase
  Future<void> _initializeFirebaseData() async {
    await ref.read(initializeMockDataProvider.future);
    setState(() {
      isLoading = false;
    });
  }

  // UPDATE: Filtrar adoptions usando dados do Firebase
  List<CollaborativeAdoptionRequest> _getFilteredAdoptions(
      List<CollaborativeAdoptionRequest> adoptions) {
    switch (selectedFilter) {
      case 'Urgentes':
        return adoptions.where((a) => a.isUrgent).toList();
      case 'Novas':
        return adoptions.where((a) => a.isNew).toList();
      case 'Experientes':
        return adoptions.where((a) => a.requesterLevel >= 15).toList();
      case 'Filhotes':
        return adoptions.where((a) => _hasTraitInPets(a, 'filhote')).toList();
      case 'Especiais':
        return adoptions.where((a) => _hasTraitInPets(a, 'especial')).toList();
      case 'Sênior':
        return adoptions.where((a) => _hasTraitInPets(a, 'sênior')).toList();
      default:
        return adoptions;
    }
  }

  // NEW: Helper para verificar traits nos pets
  bool _hasTraitInPets(CollaborativeAdoptionRequest adoption, String trait) {
    // TODO: Implementar verificação de traits quando tiver acesso aos pets
    // Por enquanto, retornar baseado em alguma lógica
    return adoption.requesterLevel > 10; // Placeholder
  }

  void _onAdoptionTap(CollaborativeAdoptionRequest adoption) {
    HapticFeedback.lightImpact();

    // NEW: Incrementar views no Firebase
    ref
        .read(firebaseAdoptionNotifierProvider.notifier)
        .incrementViews(adoption.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo adoção ${adoption.requesterCodename}...'),
        backgroundColor: Color(adoption.requesterColorTheme),
      ),
    );
  }

  void _onPetTap(String petId, CollaborativeAdoptionRequest adoption) {
    HapticFeedback.lightImpact();
    _showPetDetailsModal(petId, adoption);
  }

  void _showPetDetailsModal(
      String petId, CollaborativeAdoptionRequest adoption) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPetDetailsModal(petId, adoption),
    );
  }

  Widget _buildPetDetailsModal(
      String petId, CollaborativeAdoptionRequest adoption) {
    // UPDATE: Usar FutureBuilder para carregar dados do pet do Firebase
    return FutureBuilder<List<FirebasePetModel>>(
      future: ref.read(petsFromRequestProvider(adoption.id).future),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: const Center(child: Text('Erro ao carregar pet')),
          );
        }

        final pets = snapshot.data!;
        final pet = pets.firstWhere(
          (p) => p.id == petId,
          orElse: () => pets.first,
        );

        return _buildPetDetailsContent(pet, adoption);
      },
    );
  }

  Widget _buildPetDetailsContent(
      FirebasePetModel pet, CollaborativeAdoptionRequest adoption) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Detalhes do Pet',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: const Color(0xFF64748B),
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPetPhoto(pet, adoption),
                  SizedBox(height: 24.h),
                  _buildPetInfo(pet),
                  SizedBox(height: 24.h),
                  _buildPetTraits(pet, adoption),
                  SizedBox(height: 24.h),
                  _buildPetDescription(pet),
                  SizedBox(height: 24.h),
                  _buildAdopterInfo(adoption),
                  SizedBox(height: 120.h), // Espaço para o botão fixo
                ],
              ),
            ),
          ),

          // Bottom action
          _buildModalBottomAction(pet, adoption),
        ],
      ),
    )
        .animate()
        .slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  // UPDATE: Adaptar para FirebasePetModel
  Widget _buildPetPhoto(
      FirebasePetModel pet, CollaborativeAdoptionRequest adoption) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 200.w,
            height: 200.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(adoption.requesterColorTheme).withOpacity(0.1),
                  Color(adoption.requesterColorTheme).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(adoption.requesterColorTheme).withOpacity(0.3),
                width: 3.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(adoption.requesterColorTheme).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                pet.photo,
                style: TextStyle(fontSize: 80.sp),
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.05, 1.05),
                duration: 2000.ms,
              ),

          // Badge de status
          Positioned(
            top: 10.h,
            right: 10.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: pet.isAvailable
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: (pet.isAvailable
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444))
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                pet.isAvailable ? 'DISPONÍVEL' : 'RESERVADO',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UPDATE: Adaptar para FirebasePetModel
  Widget _buildPetInfo(FirebasePetModel pet) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pet.name,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  pet.type,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.cake,
                color: const Color(0xFF64748B),
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                pet.age,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // UPDATE: Adaptar para FirebasePetModel
  Widget _buildPetTraits(
      FirebasePetModel pet, CollaborativeAdoptionRequest adoption) {
    if (pet.traits.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Características',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: pet.traits.map((trait) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Color(adoption.requesterColorTheme).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Color(adoption.requesterColorTheme).withOpacity(0.3),
                  width: 1.w,
                ),
              ),
              child: Text(
                trait,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(adoption.requesterColorTheme),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // UPDATE: Adaptar para FirebasePetModel
  Widget _buildPetDescription(FirebasePetModel pet) {
    if (pet.description == null || pet.description!.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sobre o Pet',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.w,
            ),
          ),
          child: Text(
            pet.description!,
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF374151),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  // UPDATE: Adaptar para CollaborativeAdoptionRequest
  Widget _buildAdopterInfo(CollaborativeAdoptionRequest adoption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Guardião Responsável',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(adoption.requesterColorTheme).withOpacity(0.1),
                Color(adoption.requesterColorTheme).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Color(adoption.requesterColorTheme).withOpacity(0.2),
              width: 1.w,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Color(adoption.requesterColorTheme).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(adoption.requesterColorTheme),
                    width: 2.w,
                  ),
                ),
                child: Center(
                  child: Text(
                    adoption.requesterCodename
                        .split(' ')
                        .map((word) => word[0])
                        .join(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(adoption.requesterColorTheme),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adoption.requesterCodename,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Lv.${adoption.requesterLevel} • ${adoption.region}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModalBottomAction(
      FirebasePetModel pet, CollaborativeAdoptionRequest adoption) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Informação importante
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF3B82F6),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Ao adotar, você se tornará co-guardião junto com ${adoption.requesterCodename}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(
                          color: const Color(0xFFE2E8F0),
                          width: 1.w,
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _adoptPet(pet, adoption),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Adotar ${pet.name}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _adoptPet(
      FirebasePetModel pet, CollaborativeAdoptionRequest adoption) async {
    HapticFeedback.mediumImpact();
    Navigator.pop(context); // Fechar modal

    // NEW: Implementar adoção via Firebase
    try {
      // TODO: Pegar dados do usuário atual
      await ref
          .read(firebaseAdoptionNotifierProvider.notifier)
          .acceptAdoptionRequest(
            requestId: adoption.id,
            petId: pet.id,
            coParentId: 'current_user_id', // TODO: pegar do auth
            coParentDisplayName: 'Usuário Atual', // TODO: pegar do auth
            coParentCodename: 'Guardian Misterioso', // TODO: gerar
          );

      _showAdoptionSuccessDialog(pet, adoption);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao processar adoção: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAdoptionSuccessDialog(
      FirebasePetModel pet, CollaborativeAdoptionRequest adoption) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  pet.photo,
                  style: TextStyle(fontSize: 40.sp),
                ),
              ),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.1, 1.1),
                  duration: 1500.ms,
                ),
            SizedBox(height: 20.h),
            Text(
              'Adoção Confirmada!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Parabéns! Você e ${adoption.requesterCodename} agora são co-guardiões de ${pet.name}!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fechar dialog
              Navigator.pop(context); // Voltar para lista
            },
            child: Text(
              'Ver Lista',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fechar dialog
              Navigator.pop(context); // Voltar para lista
              // TODO: Navegar para a página do pet
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Começar a Cuidar',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: isLoading ? _buildLoadingState() : _buildContent(),
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
        'Adoções Disponíveis',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // NEW: Refresh dos dados do Firebase
            ref.invalidate(publicAdoptionRequestsFirebaseProvider);
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
            'Carregando Adoções...',
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
              'Conectando com Firebase...',
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

  Widget _buildContent() {
    // NEW: Usar dados do Firebase através dos providers
    final adoptionRequestsAsync =
        ref.watch(publicAdoptionRequestsFirebaseProvider);

    return adoptionRequestsAsync.when(
      data: (adoptions) {
        final filteredAdoptions = _getFilteredAdoptions(adoptions);

        return Column(
          children: [
            _buildFilters(),
            _buildStats(adoptions, filteredAdoptions),
            Expanded(
              child: filteredAdoptions.isEmpty
                  ? _buildEmptyState()
                  : _buildAdoptionsList(filteredAdoptions),
            ),
          ],
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stackTrace) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  selectedFilter = filter;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10B981) : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : const Color(0xFFE2E8F0),
                    width: 1.w,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // UPDATE: Stats usando dados reais do Firebase
  Widget _buildStats(List<CollaborativeAdoptionRequest> allAdoptions,
      List<CollaborativeAdoptionRequest> filteredAdoptions) {
    final totalAdoptions = allAdoptions.length;
    final urgentAdoptions = allAdoptions.where((a) => a.isUrgent).length;
    final filteredCount = filteredAdoptions.length;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '$filteredCount',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Disponíveis',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: const Color(0xFFE2E8F0),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$urgentAdoptions',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF4444),
                  ),
                ),
                Text(
                  'Urgentes',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1.w,
            height: 40.h,
            color: const Color(0xFFE2E8F0),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$totalAdoptions',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                  ),
                ),
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: const Color(0xFF64748B).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              color: const Color(0xFF64748B),
              size: 50.sp,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Nenhuma adoção encontrada',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tente alterar os filtros ou aguarde novas adoções',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
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
            size: 64.sp,
            color: const Color(0xFFEF4444),
          ),
          SizedBox(height: 16.h),
          Text(
            'Erro ao carregar dados',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(publicAdoptionRequestsFirebaseProvider);
            },
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdoptionsList(List<CollaborativeAdoptionRequest> adoptions) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      itemCount: adoptions.length,
      itemBuilder: (context, index) {
        final adoption = adoptions[index];
        return _buildAdoptionCard(adoption, index);
      },
    );
  }

  // UPDATE: Adaptar card para CollaborativeAdoptionRequest
  Widget _buildAdoptionCard(CollaborativeAdoptionRequest adoption, int index) {
    final isUrgent = adoption.isUrgent;
    final isHot = adoption.isHot;

    return GestureDetector(
      onTap: () => _onAdoptionTap(adoption),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isUrgent
                ? const Color(0xFFEF4444).withOpacity(0.3)
                : isHot
                    ? const Color(0xFFF59E0B).withOpacity(0.3)
                    : const Color(0xFFE2E8F0),
            width: isUrgent || isHot ? 2.w : 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(adoption),
            SizedBox(height: 12.h),
            _buildCardPetsPreview(adoption),
            SizedBox(height: 12.h),
            _buildCardMessage(adoption),
            SizedBox(height: 12.h),
            _buildCardFooter(adoption),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3, end: 0);
  }

  // UPDATE: Header do card usando dados do Firebase
  Widget _buildCardHeader(CollaborativeAdoptionRequest adoption) {
    final isUrgent = adoption.isUrgent;
    final isHot = adoption.isHot;

    return Row(
      children: [
        // Avatar do usuário anônimo
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: Color(adoption.requesterColorTheme).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Color(adoption.requesterColorTheme),
              width: 2.w,
            ),
          ),
          child: Center(
            child: Text(
              adoption.requesterCodename
                  .split(' ')
                  .map((word) => word[0])
                  .join(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Color(adoption.requesterColorTheme),
              ),
            ),
          ),
        ),

        SizedBox(width: 12.w),

        // Informações do usuário
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      adoption.requesterCodename,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  if (adoption.isNew)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'NOVO',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Lv.${adoption.requesterLevel}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(adoption.requesterColorTheme),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    adoption.region,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Status e tempo
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isUrgent)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'URGENTE',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              )
            else if (isHot)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'HOT',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            SizedBox(height: 4.h),
            Text(
              '${adoption.daysRemaining.toStringAsFixed(1)} dias',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isUrgent
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // NEW: Preview dos pets (placeholder até implementar busca de pets)
  Widget _buildCardPetsPreview(CollaborativeAdoptionRequest adoption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pets da Missão (${adoption.selectedPetIds.length})',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 8.h),
        // TODO: Implementar preview real dos pets
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Color(adoption.requesterColorTheme).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            '${adoption.selectedPetIds.length} pets selecionados para adoção',
            style: TextStyle(
              fontSize: 12.sp,
              color: Color(adoption.requesterColorTheme),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardMessage(CollaborativeAdoptionRequest adoption) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mensagem Codificada:',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            adoption.codedMessage,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF0F172A),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFooter(CollaborativeAdoptionRequest adoption) {
    return Row(
      children: [
        // Tags de personalidade
        if (adoption.personalityTags.isNotEmpty)
          Expanded(
            child: Wrap(
              spacing: 4.w,
              children: adoption.personalityTags.take(2).map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Color(adoption.requesterColorTheme).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(adoption.requesterColorTheme),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        SizedBox(width: 12.w),

        // Stats da adoção
        Row(
          children: [
            Icon(
              Icons.visibility,
              size: 14.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(width: 4.w),
            Text(
              '${adoption.views}',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(width: 12.w),
            Icon(
              Icons.favorite_border,
              size: 14.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(width: 4.w),
            Text(
              '${adoption.interested}',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
