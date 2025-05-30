import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/model/mocks.dart';

class MissionDetailsPage extends StatefulWidget {
  final AnonymousAdoption adoption;

  const MissionDetailsPage({super.key, required this.adoption});

  @override
  State<MissionDetailsPage> createState() => _MissionDetailsPageState();
}

class _MissionDetailsPageState extends State<MissionDetailsPage>
    with TickerProviderStateMixin {
  late PageController _petGalleryController;
  int _currentPetIndex = 0;
  bool _isInterested = false;
  bool _isSaved = false;

  // Mock user compatibility data
  final int _userLevel = 8;
  final int _matchScore = 85;
  final int _potentialXP = 120;
  final List<String> _compatibilityReasons = [
    'Ambos têm experiência com gatos',
    'Níveis similares de dedicação',
    'Mesma região geográfica',
  ];

  late List<InterestedUser> _otherInterested;

  @override
  void initState() {
    super.initState();
    _petGalleryController = PageController();
    _otherInterested = MockDataProvider.getInterestedUsers();
  }

  @override
  void dispose() {
    _petGalleryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildGuardianProfile(),
                _buildCompatibilityCard(),
                _buildPetGallery(),
                _buildMissionDetails(),
                _buildOtherInterestedSection(),
                _buildActionButtons(),
                SizedBox(height: 100.h), // Espaço para botão fixo
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.h,
      floating: false,
      pinned: true,
      backgroundColor: Color(widget.adoption.colorTheme),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(widget.adoption.colorTheme),
                Color(widget.adoption.colorTheme).withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              // Avatar grande
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.pets_rounded,
                  color: Colors.white,
                  size: 40.sp,
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.05, 1.05),
                    duration: 3000.ms,
                  ),

              SizedBox(height: 12.h),

              Text(
                widget.adoption.codename,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),

              Text(
                'Nível ${widget.adoption.level} • ${widget.adoption.region}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _isSaved = !_isSaved;
            });
          },
          icon: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_outline,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuardianProfile() {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08),
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
                Icons.shield_outlined,
                color: Color(widget.adoption.colorTheme),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Perfil do Guardian',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Taxa de Sucesso',
                  '${widget.adoption.successRate}%',
                  Icons.trending_up,
                  const Color(0xFF10B981),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Pets Salvos',
                  '${widget.adoption.completedAdoptions}',
                  Icons.pets,
                  const Color(0xFF3B82F6),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Streak Atual',
                  '${widget.adoption.currentStreak}',
                  Icons.local_fire_department,
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Mensagem do Guardian:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1.w,
              ),
            ),
            child: Text(
              widget.adoption.codedMessage,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: widget.adoption.personalityTags.map((tag) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Color(widget.adoption.colorTheme).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Color(widget.adoption.colorTheme).withOpacity(0.3),
                    width: 1.w,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(widget.adoption.colorTheme),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCompatibilityCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF059669).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite,
                  color: const Color(0xFF10B981),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compatibilidade: $_matchScore%',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Excelente match para parceria!',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '+$_potentialXP XP',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Column(
            children: _compatibilityReasons.map((reason) {
              return Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF10B981),
                      size: 16.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        reason,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    )
        .animate(delay: 200.ms)
        .fadeIn(duration: 600.ms)
        .slideX(begin: -0.2, end: 0);
  }

  Widget _buildPetGallery() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pets da Missão (${widget.adoption.pets.length})',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),

          SizedBox(height: 12.h),

          SizedBox(
            height: 200.h,
            child: PageView.builder(
              controller: _petGalleryController,
              onPageChanged: (index) {
                setState(() {
                  _currentPetIndex = index;
                });
              },
              itemCount: widget.adoption.pets.length,
              itemBuilder: (context, index) {
                final pet = widget.adoption.pets[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Color(widget.adoption.colorTheme).withOpacity(0.2),
                      width: 1.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF64748B).withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: Color(widget.adoption.colorTheme)
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            pet.photo,
                            style: TextStyle(fontSize: 40.sp),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        pet.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${pet.type} • ${pet.age}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildPetTrait('Carinhoso', Icons.favorite_outline),
                          _buildPetTrait('Brincalhão', Icons.sports_tennis),
                          _buildPetTrait('Calmo', Icons.self_improvement),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 12.h),

          // Indicadores de página
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.adoption.pets.length,
              (index) => Container(
                width: 8.w,
                height: 8.w,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: _currentPetIndex == index
                      ? Color(widget.adoption.colorTheme)
                      : const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: 400.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildPetTrait(String trait, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Color(widget.adoption.colorTheme),
          size: 16.sp,
        ),
        SizedBox(height: 4.h),
        Text(
          trait,
          style: TextStyle(
            fontSize: 10.sp,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionDetails() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.08),
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
                Icons.access_time,
                color: _getTimerColor(),
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Detalhes da Missão',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Tempo Restante',
                  '${widget.adoption.timeLeftDays.toStringAsFixed(1)} dias',
                  _getTimerColor(),
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Visualizações',
                  '${widget.adoption.views}',
                  const Color(0xFF64748B),
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Interessados',
                  '${widget.adoption.interested}',
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: 600.ms)
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildDetailItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: const Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOtherInterestedSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outros Interessados (${_otherInterested.length})',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 60.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _otherInterested.length,
              itemBuilder: (context, index) {
                final user = _otherInterested[index];
                return Container(
                  width: 120.w,
                  margin: EdgeInsets.only(right: 12.w),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Color(user.colorTheme).withOpacity(0.2),
                      width: 1.w,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: Color(user.colorTheme),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user.codename,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Nível ${user.level}',
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
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
    )
        .animate(delay: 800.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildActionButtons() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Share functionality
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.share_outlined,
                      color: const Color(0xFF64748B),
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Compartilhar',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSaved = !_isSaved;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: _isSaved
                      ? const Color(0xFF3B82F6).withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _isSaved
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFFE2E8F0),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                      color: _isSaved
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF64748B),
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _isSaved ? 'Salvo' : 'Salvar',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: _isSaved
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: 1000.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildBottomActionBar() {
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
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isInterested = !_isInterested;
            });

            if (_isInterested) {
              _showInterestConfirmation();
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isInterested
                    ? [const Color(0xFF10B981), const Color(0xFF059669)]
                    : [
                        Color(widget.adoption.colorTheme),
                        Color(widget.adoption.colorTheme).withOpacity(0.8)
                      ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: (_isInterested
                          ? const Color(0xFF10B981)
                          : Color(widget.adoption.colorTheme))
                      .withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isInterested ? Icons.check_circle : Icons.favorite,
                  color: Colors.white,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  _isInterested
                      ? 'Interesse Demonstrado!'
                      : 'Quero Participar desta Missão',
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
      ),
    );
  }

  Color _getTimerColor() {
    if (widget.adoption.timeLeftDays <= 1) {
      return const Color(0xFFEF4444); // Vermelho
    } else if (widget.adoption.timeLeftDays <= 2) {
      return const Color(0xFFF59E0B); // Amarelo
    } else {
      return const Color(0xFF10B981); // Verde
    }
  }

  void _showInterestConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: const Color(0xFF10B981),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              'Interesse Confirmado!',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Você demonstrou interesse nesta missão de co-adoção!',
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
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                  width: 1.w,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Próximos passos:',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _buildNextStep(
                      'O guardian será notificado', Icons.notifications),
                  _buildNextStep(
                      'Aguarde confirmação da parceria', Icons.handshake),
                  _buildNextStep(
                      'Ganhe +$_potentialXP XP se aprovado', Icons.stars),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendi',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3B82F6),
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

  Widget _buildNextStep(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF3B82F6),
            size: 14.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
