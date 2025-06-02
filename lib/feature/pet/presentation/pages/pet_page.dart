import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:petverse/core/model/mocks.dart';

class PetPage extends StatefulWidget {
  final MockPet pet;
  final AnonymousAdoption adoption;
  final bool isNewlyAdopted;

  const PetPage({
    super.key,
    required this.pet,
    required this.adoption,
    this.isNewlyAdopted = false,
  });

  @override
  State<PetPage> createState() => _PetPageState();
}

class _PetPageState extends State<PetPage> with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _pulseController;

  // Stats do pet (mock)
  int happiness = 85;
  int health = 92;
  int energy = 78;
  int hunger = 40;

  @override
  void initState() {
    super.initState();

    _celebrationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);

    // Se é um pet recém-adotado, mostrar celebração
    if (widget.isNewlyAdopted) {
      _celebrationController.forward();
    }
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onActionTap(String action) {
    HapticFeedback.lightImpact();

    setState(() {
      switch (action) {
        case 'feed':
          hunger = (hunger - 20).clamp(0, 100);
          happiness = (happiness + 5).clamp(0, 100);
          break;
        case 'play':
          energy = (energy - 15).clamp(0, 100);
          happiness = (happiness + 10).clamp(0, 100);
          break;
        case 'sleep':
          energy = (energy + 25).clamp(0, 100);
          break;
        case 'medicine':
          health = (health + 15).clamp(0, 100);
          break;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getActionMessage(action)),
        backgroundColor: Color(widget.adoption.colorTheme),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getActionMessage(String action) {
    switch (action) {
      case 'feed':
        return '${widget.pet.name} adorou a comida! 🍖';
      case 'play':
        return '${widget.pet.name} se divertiu muito brincando! 🎾';
      case 'sleep':
        return '${widget.pet.name} está descansando... 😴';
      case 'medicine':
        return '${widget.pet.name} está se sentindo melhor! 💊';
      default:
        return '${widget.pet.name} está feliz!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.isNewlyAdopted) _buildWelcomeBanner(),
            _buildPetDisplay(),
            _buildStatsSection(),
            _buildCoGuardianSection(),
            _buildActionsSection(),
            SizedBox(height: 20),
          ],
        ),
      ),
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
          size: 24,
        ),
      ),
      title: Text(
        widget.pet.name,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0F172A),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // TODO: Abrir menu de configurações do pet
          },
          icon: Icon(
            Icons.more_vert,
            color: const Color(0xFF64748B),
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF059669).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.celebration,
                  color: const Color(0xFF10B981),
                  size: 20,
                ),
              )
                  .animate(controller: _celebrationController)
                  .rotate(end: 1)
                  .scale(end: const Offset(1.2, 1.2)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo à família!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Você e ${widget.adoption.codename} agora são co-guardiões de ${widget.pet.name}',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: -0.3, end: 0).fadeIn();
  }

  Widget _buildPetDisplay() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pet Avatar Grande
          Stack(
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(widget.adoption.colorTheme).withOpacity(0.2),
                      Color(widget.adoption.colorTheme).withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(widget.adoption.colorTheme).withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.pet.photo,
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              )
                  .animate(
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.05, 1.05),
                    duration: 2000.ms,
                  ),

              // Status indicator
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _getPetMoodColor(),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Pet Info
          Text(
            widget.pet.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),

          Text(
            '${widget.pet.type} • ${widget.pet.age}',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
          ),

          SizedBox(height: 12),

          // Mood Status
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getPetMoodColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getPetMoodText(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getPetMoodColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'Status do Pet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 16),
          _buildStatBar(
              'Felicidade', happiness, const Color(0xFFF59E0B), Icons.mood),
          SizedBox(height: 12),
          _buildStatBar(
              'Saúde', health, const Color(0xFF10B981), Icons.favorite),
          SizedBox(height: 12),
          _buildStatBar('Energia', energy, const Color(0xFF3B82F6), Icons.bolt),
          SizedBox(height: 12),
          _buildStatBar(
              'Fome', hunger, const Color(0xFFEF4444), Icons.restaurant),
        ],
      ),
    );
  }

  Widget _buildStatBar(String label, int value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Text(
          '$value%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCoGuardianSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(widget.adoption.colorTheme).withOpacity(0.1),
            Color(widget.adoption.colorTheme).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(widget.adoption.colorTheme).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(widget.adoption.colorTheme).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(widget.adoption.colorTheme),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                widget.adoption.codename
                    .split(' ')
                    .map((word) => word[0])
                    .join(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(widget.adoption.colorTheme),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Co-Guardião: ${widget.adoption.codename}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Cuidando juntos de ${widget.pet.name}',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.people,
            color: Color(widget.adoption.colorTheme),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cuidados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildActionCard('Alimentar', Icons.restaurant,
                  const Color(0xFFF59E0B), 'feed'),
              _buildActionCard('Brincar', Icons.sports_tennis,
                  const Color(0xFF3B82F6), 'play'),
              _buildActionCard(
                  'Dormir', Icons.bedtime, const Color(0xFF8B5CF6), 'sleep'),
              _buildActionCard('Remédio', Icons.medical_services,
                  const Color(0xFF10B981), 'medicine'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, String action) {
    return GestureDetector(
      onTap: () => _onActionTap(action),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPetMoodColor() {
    final avgMood = (happiness + health + energy - hunger) / 3;
    if (avgMood >= 80) return const Color(0xFF10B981);
    if (avgMood >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _getPetMoodText() {
    final avgMood = (happiness + health + energy - hunger) / 3;
    if (avgMood >= 80) return 'Muito Feliz 😊';
    if (avgMood >= 60) return 'Feliz 😐';
    return 'Precisa de Cuidados 😔';
  }
}
