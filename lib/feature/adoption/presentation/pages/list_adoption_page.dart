// lib/feature/adoption/presentation/pages/list_adoption_page.dart
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

class AdoptionListPage extends ConsumerStatefulWidget {
  const AdoptionListPage({super.key});

  @override
  ConsumerState<AdoptionListPage> createState() => _AdoptionListPageState();
}

class _AdoptionListPageState extends ConsumerState<AdoptionListPage>
    with TickerProviderStateMixin {
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

    _initializeFirebaseData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeFirebaseData() async {
    await ref.read(initializeMockDataProvider.future);
    setState(() {
      isLoading = false;
    });
  }

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

  bool _hasTraitInPets(CollaborativeAdoptionRequest adoption, String trait) {
    return adoption.requesterLevel > 10; // Placeholder
  }

  void _onAdoptionTap(CollaborativeAdoptionRequest adoption) {
    HapticFeedback.lightImpact();

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
      height: MediaQuery.of(context).size.height * 0.75,
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
            margin: EdgeInsets.only(top: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header compacto
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 16.w, 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Detalhes do Pet',
                    style: TextStyle(
                      fontSize: 18.sp,
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
                    size: 22.sp,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 32.w,
                    minHeight: 32.w,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompactPetHeader(pet, adoption),
                  SizedBox(height: 16.h),
                  _buildStatsAndTraits(pet, adoption),
                  SizedBox(height: 16.h),
                  _buildCompactAdopterInfo(adoption),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // Bottom action
          _buildCompactBottomAction(pet, adoption),
        ],
      ),
    )
        .animate()
        .slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildCompactPetHeader(
      FirebasePetModel pet, CollaborativeAdoptionRequest adoption) {
    return Row(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(adoption.requesterColorTheme).withOpacity(0.2),
                Color(adoption.requesterColorTheme).withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: Color(adoption.requesterColorTheme).withOpacity(0.3),
              width: 2.w,
            ),
          ),
          child: Center(
            child: Text(
              pet.photo,
              style: TextStyle(fontSize: 36.sp),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      pet.name,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color:
                          Color(adoption.requesterColorTheme).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      pet.type,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(adoption.requesterColorTheme),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                '${pet.breed} • ${pet.age}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getPetMoodColor(pet).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _getPetMoodText(pet),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: _getPetMoodColor(pet),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsAndTraits(
      FirebasePetModel pet, CollaborativeAdoptionRequest adoption) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
              Expanded(child: _buildCompactStat('❤️', 'Saúde', pet.health)),
              SizedBox(width: 12.w),
              Expanded(
                  child: _buildCompactStat('😊', 'Felicidade', pet.happiness)),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(child: _buildCompactStat('⚡', 'Energia', pet.energy)),
              SizedBox(width: 12.w),
              Expanded(child: _buildCompactStat('✨', 'Higiene', pet.hygiene)),
            ],
          ),
          if (pet.traits.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'Características',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 6.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              children: pet.traits.take(4).map((trait) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Color(adoption.requesterColorTheme).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    trait,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(adoption.requesterColorTheme),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactStat(String emoji, String label, int value) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: 14.sp)),
        SizedBox(width: 6.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 2.h),
              Stack(
                children: [
                  Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: _getStatColor(value).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: value / 100,
                    child: Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: _getStatColor(value),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                '$value%',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: _getStatColor(value),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactAdopterInfo(CollaborativeAdoptionRequest adoption) {
    return Container(
      padding: EdgeInsets.all(12.w),
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
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: Color(adoption.requesterColorTheme).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(adoption.requesterColorTheme),
                width: 1.w,
              ),
            ),
            child: Center(
              child: Text(
                adoption.requesterCodename
                    .split(' ')
                    .map((word) => word[0])
                    .join(),
                style: TextStyle(
                  fontSize: 12.sp,
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
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Lv.${adoption.requesterLevel} • ${adoption.region}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.people,
            color: Color(adoption.requesterColorTheme),
            size: 18.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBottomAction(
      FirebasePetModel pet, CollaborativeAdoptionRequest adoption) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF3B82F6),
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Ao adotar, você se tornará co-guardião junto com ${adoption.requesterCodename}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF3B82F6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: Consumer(
                    builder: (context, ref, child) {
                      // NOVO: Verificar se pode adotar usando provider unificado
                      final canAdopt = ref.watch(canAdoptPetProvider);
                      final isInTransition = ref.watch(isInTransitionProvider);

                      return ElevatedButton(
                        onPressed: canAdopt && !isInTransition
                            ? () => _adoptPet(adoption, pet.id)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: isInTransition
                            ? SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.w,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Adotar ${pet.name}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPetMoodColor(FirebasePetModel pet) {
    final avgMood = (pet.happiness + pet.health + pet.energy) / 3;
    if (avgMood >= 80) return const Color(0xFF10B981);
    if (avgMood >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _getPetMoodText(FirebasePetModel pet) {
    final avgMood = (pet.happiness + pet.health + pet.energy) / 3;
    if (avgMood >= 80) return 'Muito Feliz 😊';
    if (avgMood >= 60) return 'Feliz 😐';
    return 'Precisa de Cuidados 😔';
  }

  Color _getStatColor(int value) {
    if (value >= 80) return const Color(0xFF10B981);
    if (value >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  // NOVO: Método de adoção usando AdoptionFlowService
  Future<void> _adoptPet(
      CollaborativeAdoptionRequest request, String petId) async {
    final success = await AdoptionFlowService.executeAdoptionFlow(
      context: context,
      ref: ref,
      requestId: request.id,
      petId: petId,
      coParentDisplayName: 'Co-guardião',
      coParentCodename: 'Guardião Colaborativo',
    );

    // Fechar modal se sucesso
    if (success && mounted) {
      Navigator.pop(context); // Fechar modal de detalhes
    }
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
    // NOVO: Verificar se pode ver adoções usando provider unificado
    final unifiedState = ref.watch(unifiedUserStateProvider);

    if (!unifiedState.isAuthenticated) {
      return _buildUnauthenticatedState();
    }

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

  Widget _buildUnauthenticatedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login,
            size: 80.sp,
            color: const Color(0xFF64748B),
          ),
          SizedBox(height: 16.h),
          Text(
            'Login Necessário',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Você precisa estar logado para ver as adoções disponíveis',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
        ],
      ),
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
        return _buildAdoptionCard(adoption, index, ref);
      },
    );
  }

  Widget _buildAdoptionCard(
      CollaborativeAdoptionRequest adoption, int index, WidgetRef ref) {
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
            _buildCardPetsPreview(adoption, ref),
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

  Widget _buildCardHeader(CollaborativeAdoptionRequest adoption) {
    final isUrgent = adoption.isUrgent;
    final isHot = adoption.isHot;

    return Row(
      children: [
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

  Widget _buildCardPetsPreview(
      CollaborativeAdoptionRequest adoption, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer(
          builder: (context, ref, child) {
            final petsAsync = ref.watch(petsFromRequestProvider(adoption.id));

            return petsAsync.when(
              data: (pets) => _buildPetsGrid(pets, adoption),
              loading: () => _buildPetsLoading(adoption),
              error: (error, _) => _buildPetsError(adoption),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPetsGrid(
      List<FirebasePetModel> pets, CollaborativeAdoptionRequest adoption) {
    if (pets.isEmpty) {
      return _buildPetsError(adoption);
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Color(adoption.requesterColorTheme).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Color(adoption.requesterColorTheme).withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.pets,
                color: Color(adoption.requesterColorTheme),
                size: 16.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                'Escolha um dos pets:',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(adoption.requesterColorTheme),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: pets.asMap().entries.map((entry) {
              final index = entry.key;
              final pet = entry.value;
              final isLast = index == pets.length - 1;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: isLast ? 0 : 8.w),
                  child: _buildPetPreviewCard(pet, adoption),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPetPreviewCard(
      FirebasePetModel pet, CollaborativeAdoptionRequest adoption) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showPetDetailsModal(pet.id, adoption);
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: Color(adoption.requesterColorTheme).withOpacity(0.3),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(adoption.requesterColorTheme).withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: Color(adoption.requesterColorTheme).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  pet.photo,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
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
              textAlign: TextAlign.center,
            ),
            Text(
              pet.type,
              style: TextStyle(
                fontSize: 8.sp,
                color: const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              height: 2.h,
              decoration: BoxDecoration(
                color: _getHealthColor(pet.health).withOpacity(0.3),
                borderRadius: BorderRadius.circular(1.r),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: pet.health / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: _getHealthColor(pet.health),
                    borderRadius: BorderRadius.circular(1.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(int health) {
    if (health >= 80) return const Color(0xFF10B981);
    if (health >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Widget _buildPetsLoading(CollaborativeAdoptionRequest adoption) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Color(adoption.requesterColorTheme).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Color(adoption.requesterColorTheme).withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              color: Color(adoption.requesterColorTheme),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'Carregando pets...',
            style: TextStyle(
              fontSize: 12.sp,
              color: Color(adoption.requesterColorTheme),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsError(CollaborativeAdoptionRequest adoption) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: const Color(0xFFEF4444),
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Erro ao carregar pets desta adoção',
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
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
