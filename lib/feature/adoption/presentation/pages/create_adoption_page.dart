import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/model/mocks.dart';

class CreateAdoptionPage extends StatefulWidget {
  const CreateAdoptionPage({super.key});

  @override
  State<CreateAdoptionPage> createState() => _CreateAdoptionPageState();
}

class _CreateAdoptionPageState extends State<CreateAdoptionPage>
    with TickerProviderStateMixin {
  List<MockPet> selectedPets = [];
  bool isLoading = true;
  bool isCreating = false;

  late AnimationController _pulseController;
  late List<MockPet> availablePets;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);

    // Simular carregamento de pets aleatórios
    _loadRandomPets();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _loadRandomPets() {
    // Simular delay de carregamento
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        availablePets = _generateRandomPets();
        isLoading = false;
      });
    });
  }

  List<MockPet> _generateRandomPets() {
    // Mock de pets aleatórios gerados pelo sistema
    final random = [
      MockPet(
        name: 'Luna',
        type: 'Gato',
        age: '2 anos',
        photo: '🐱',
        traits: ['carinhoso', 'brincalhão', 'independente'],
        description: 'Gatinha muito carinhosa que adora brincar',
      ),
      MockPet(
        name: 'Max',
        type: 'Cachorro',
        age: '3 anos',
        photo: '🐕',
        traits: ['leal', 'energético', 'protetor'],
        description: 'Cachorro muito leal e cheio de energia',
      ),
      MockPet(
        name: 'Bella',
        type: 'Coelho',
        age: '1 ano',
        photo: '🐰',
        traits: ['fofo', 'tranquilo', 'tímido'],
        description: 'Coelhinha muito fofa e tranquila',
      ),
      MockPet(
        name: 'Charlie',
        type: 'Cachorro',
        age: '4 anos',
        photo: '🐕',
        traits: ['amigável', 'obediente', 'carinhoso'],
        description: 'Cachorro muito amigável e obediente',
      ),
      MockPet(
        name: 'Mimi',
        type: 'Gato',
        age: '1 ano',
        photo: '🐱',
        traits: ['curioso', 'ativo', 'brincalhão'],
        description: 'Gatinho muito curioso e ativo',
      ),
      MockPet(
        name: 'Rocky',
        type: 'Cachorro',
        age: '5 anos',
        photo: '🐕',
        traits: ['forte', 'protetor', 'leal'],
        description: 'Cachorro grande e muito protetor',
      ),
      MockPet(
        name: 'Snow',
        type: 'Hamster',
        age: '6 meses',
        photo: '🐹',
        traits: ['pequeno', 'ativo', 'fofo'],
        description: 'Hamster branquinho muito fofo',
      ),
      MockPet(
        name: 'Kiwi',
        type: 'Pássaro',
        age: '2 anos',
        photo: '🦜',
        traits: ['colorido', 'falante', 'inteligente'],
        description: 'Papagaio muito colorido e falante',
      ),
      MockPet(
        name: 'Shadow',
        type: 'Gato',
        age: '3 anos',
        photo: '🐱',
        traits: ['elegante', 'independente', 'misterioso'],
        description: 'Gato preto muito elegante e misterioso',
      ),
      MockPet(
        name: 'Buddy',
        type: 'Cachorro',
        age: '2 anos',
        photo: '🐕',
        traits: ['amigável', 'brincalhão', 'social'],
        description: 'Cachorro muito sociável e brincalhão',
      ),
    ];

    // Embaralhar e retornar apenas alguns
    random.shuffle();
    return random.take(8).toList();
  }

  void _togglePetSelection(MockPet pet) {
    HapticFeedback.lightImpact();

    setState(() {
      if (selectedPets.contains(pet)) {
        selectedPets.remove(pet);
      } else if (selectedPets.length < 3) {
        selectedPets.add(pet);
      }
    });
  }

  void _createAdoption() async {
    if (selectedPets.length != 3) return;

    setState(() {
      isCreating = true;
    });

    HapticFeedback.mediumImpact();

    // Simular criação da adoção
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isCreating = false;
    });

    // Mostrar sucesso e voltar
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
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
              child: Icon(
                Icons.pets_rounded,
                color: const Color(0xFF10B981),
                size: 40.sp,
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
              'Adoção Criada!',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Sua adoção foi publicada na lista.\nAguarde alguém escolher um dos pets!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: const Color(0xFF3B82F6),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Expira em 5 dias se ninguém aceitar',
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
              'Ver na Lista',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF10B981),
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
          onPressed: _loadRandomPets,
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
              'O sistema está gerando pets aleatórios para você',
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
        // Preview dos pets selecionados fixo no topo
        if (selectedPets.isNotEmpty) _buildSelectedPetsPreview(),

        // Conteúdo scrollável
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedPets.isEmpty) _buildHeader(),
                SizedBox(height: selectedPets.isEmpty ? 20.h : 0),
                _buildPetsGrid(),
                SizedBox(height: 20.h), // Espaço adicional no final
              ],
            ),
          ),
        ),
      ],
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

  Widget _buildPetsGrid() {
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
            childAspectRatio: 0.9, // Ajustado para melhor proporção
          ),
          itemCount: availablePets.length,
          itemBuilder: (context, index) {
            final pet = availablePets[index];
            final isSelected = selectedPets.contains(pet);
            final canSelect = selectedPets.length < 3 || isSelected;

            return _buildPetCard(pet, isSelected, canSelect, index);
          },
        ),
      ],
    );
  }

  Widget _buildPetCard(
      MockPet pet, bool isSelected, bool canSelect, int index) {
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
            // Pet photo com seleção
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

            // Traits principais - limitado a 2 e com overflow protegido
            if (pet.traits != null && pet.traits!.isNotEmpty)
              Flexible(
                child: Wrap(
                  spacing: 4.w,
                  runSpacing: 2.h,
                  alignment: WrapAlignment.center,
                  children: pet.traits!.take(2).map((trait) {
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

            // Estado de seleção
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

  Widget _buildSelectedPetsPreview() {
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
              // Slots vazios
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
    final canCreate = selectedPets.length == 3;

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
            // Contador
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

            // Botão criar
            GestureDetector(
              onTap: canCreate && !isCreating ? _createAdoption : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: canCreate
                      ? const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        )
                      : null,
                  color: canCreate ? null : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: canCreate
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
                    if (isCreating) ...[
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
                      isCreating ? 'Criando...' : 'Criar Adoção',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color:
                            canCreate ? Colors.white : const Color(0xFF94A3B8),
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
