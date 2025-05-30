import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/model/mocks.dart';
import 'package:petverse/feature/pet/presentation/pages/pet_page.dart';
// import 'package:petverse/pages/pet_page.dart'; // Adicionar quando implementar

class AdoptionListPage extends StatefulWidget {
  const AdoptionListPage({super.key});

  @override
  State<AdoptionListPage> createState() => _AdoptionListPageState();
}

class _AdoptionListPageState extends State<AdoptionListPage>
    with TickerProviderStateMixin {
  List<AnonymousAdoption> adoptions = [];
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

    _loadAdoptions();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _loadAdoptions() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        adoptions = MockDataProvider.getExtendedAdoptions();
        isLoading = false;
      });
    });
  }

  List<AnonymousAdoption> get filteredAdoptions {
    switch (selectedFilter) {
      case 'Urgentes':
        return adoptions
            .where((a) => a.status == 'urgent' || a.timeLeftDays < 1.0)
            .toList();
      case 'Novas':
        return adoptions.where((a) => a.isNew).toList();
      case 'Experientes':
        return adoptions.where((a) => a.level >= 15).toList();
      case 'Filhotes':
        return adoptions
            .where((a) =>
                a.pets.any((pet) => pet.traits?.contains('filhote') ?? false))
            .toList();
      case 'Especiais':
        return adoptions
            .where((a) =>
                a.pets.any((pet) => pet.traits?.contains('especial') ?? false))
            .toList();
      case 'Sênior':
        return adoptions
            .where((a) =>
                a.pets.any((pet) => pet.traits?.contains('sênior') ?? false))
            .toList();
      default:
        return MockDataProvider.sortAdoptions([...adoptions], 'default');
    }
  }

  void _onAdoptionTap(AnonymousAdoption adoption) {
    HapticFeedback.lightImpact();
    // TODO: Navegar para tela de detalhes da adoção
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Abrindo adoção ${adoption.codename}...'),
        backgroundColor: Color(adoption.colorTheme),
      ),
    );
  }

  void _onPetTap(MockPet pet, AnonymousAdoption adoption) {
    HapticFeedback.lightImpact();
    _showPetDetailsModal(pet, adoption);
  }

  void _showPetDetailsModal(MockPet pet, AnonymousAdoption adoption) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPetDetailsModal(pet, adoption),
    );
  }

  Widget _buildPetDetailsModal(MockPet pet, AnonymousAdoption adoption) {
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

  Widget _buildPetPhoto(MockPet pet, AnonymousAdoption adoption) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 200.w,
            height: 200.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(adoption.colorTheme).withOpacity(0.1),
                  Color(adoption.colorTheme).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(adoption.colorTheme).withOpacity(0.3),
                width: 3.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(adoption.colorTheme).withOpacity(0.2),
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

          // Badge de status no canto
          Positioned(
            top: 10.h,
            right: 10.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'DISPONÍVEL',
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

  Widget _buildPetInfo(MockPet pet) {
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

  Widget _buildPetTraits(MockPet pet, AnonymousAdoption adoption) {
    if (pet.traits == null || pet.traits!.isEmpty) return const SizedBox();

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
          children: pet.traits!.map((trait) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Color(adoption.colorTheme).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Color(adoption.colorTheme).withOpacity(0.3),
                  width: 1.w,
                ),
              ),
              child: Text(
                trait,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(adoption.colorTheme),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPetDescription(MockPet pet) {
    if (pet.description == null || pet.description!.isEmpty)
      return const SizedBox();

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

  Widget _buildAdopterInfo(AnonymousAdoption adoption) {
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
                Color(adoption.colorTheme).withOpacity(0.1),
                Color(adoption.colorTheme).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Color(adoption.colorTheme).withOpacity(0.2),
              width: 1.w,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Color(adoption.colorTheme).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(adoption.colorTheme),
                    width: 2.w,
                  ),
                ),
                child: Center(
                  child: Text(
                    adoption.codename.split(' ').map((word) => word[0]).join(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Color(adoption.colorTheme),
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
                      adoption.codename,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Lv.${adoption.level} • ${adoption.successRate}% sucesso',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (adoption.badges.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Color(adoption.colorTheme),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    adoption.badges.first.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModalBottomAction(MockPet pet, AnonymousAdoption adoption) {
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
                      'Ao adotar, você se tornará co-guardião junto com ${adoption.codename}',
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

  void _adoptPet(MockPet pet, AnonymousAdoption adoption) {
    HapticFeedback.mediumImpact();
    Navigator.pop(context); // Fechar modal

    // TODO: Implementar lógica de adoção com verificação de concorrência
    _showAdoptionSuccessDialog(pet, adoption);
  }

  void _showAdoptionSuccessDialog(MockPet pet, AnonymousAdoption adoption) {
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
              'Parabéns! Você e ${adoption.codename} agora são co-guardiões de ${pet.name}!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
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
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Agora você pode começar a cuidar do seu novo pet!',
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
              // Navegar para a página do pet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetPage(
                    pet: pet,
                    adoption: adoption,
                    isNewlyAdopted: true,
                  ),
                ),
              );
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
      // floatingActionButton: _buildCreateButton(),
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
          onPressed: _loadAdoptions,
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
              'Buscando guardiões anônimos que precisam de parceiros',
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
    return Column(
      children: [
        _buildFilters(),
        _buildStats(),
        Expanded(
          child: filteredAdoptions.isEmpty
              ? _buildEmptyState()
              : _buildAdoptionsList(),
        ),
      ],
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

  Widget _buildStats() {
    final totalAdoptions = adoptions.length;
    final urgentAdoptions = adoptions
        .where((a) => a.status == 'urgent' || a.timeLeftDays < 1.0)
        .length;
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

  Widget _buildAdoptionsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: filteredAdoptions.length,
      itemBuilder: (context, index) {
        final adoption = filteredAdoptions[index];
        return _buildAdoptionCard(adoption, index);
      },
    );
  }

  Widget _buildAdoptionCard(AnonymousAdoption adoption, int index) {
    final isUrgent = adoption.status == 'urgent' || adoption.timeLeftDays < 1.0;
    final isHot = adoption.status == 'hot';

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
            _buildCardPets(adoption),
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

  Widget _buildCardHeader(AnonymousAdoption adoption) {
    final isUrgent = adoption.status == 'urgent' || adoption.timeLeftDays < 1.0;
    final isHot = adoption.status == 'hot';

    return Row(
      children: [
        // Avatar do usuário anônimo
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: Color(adoption.colorTheme).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Color(adoption.colorTheme),
              width: 2.w,
            ),
          ),
          child: Center(
            child: Text(
              adoption.codename.split(' ').map((word) => word[0]).join(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Color(adoption.colorTheme),
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
                      adoption.codename,
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
                    'Lv.${adoption.level}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(adoption.colorTheme),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${adoption.successRate}% sucesso',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '${adoption.completedAdoptions} adoções',
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
              '${adoption.timeLeftDays.toStringAsFixed(1)} dias',
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

  Widget _buildCardPets(AnonymousAdoption adoption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pets da Missão',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: adoption.pets.map((pet) {
            return Expanded(
              child: GestureDetector(
                onTap: () => _onPetTap(pet, adoption),
                child: Container(
                  margin: EdgeInsets.only(
                      right: adoption.pets.last == pet ? 0 : 8.w),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Color(adoption.colorTheme).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Color(adoption.colorTheme).withOpacity(0.2),
                      width: 1.w,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        pet.photo,
                        style: TextStyle(fontSize: 20.sp),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        pet.name,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        pet.type,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCardMessage(AnonymousAdoption adoption) {
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

  Widget _buildCardFooter(AnonymousAdoption adoption) {
    return Row(
      children: [
        // Badges
        if (adoption.badges.isNotEmpty)
          Expanded(
            child: Wrap(
              spacing: 4.w,
              children: adoption.badges.take(2).map((badge) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Color(adoption.colorTheme).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    badge.replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(adoption.colorTheme),
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

  Widget _buildCreateButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.lightImpact();
        // TODO: Navegar para CreateAdoptionPage
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navegando para criar nova adoção...'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      },
      backgroundColor: const Color(0xFF10B981),
      icon: Icon(
        Icons.add,
        color: Colors.white,
        size: 24.sp,
      ),
      label: Text(
        'Criar Adoção',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 1000.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }
}
