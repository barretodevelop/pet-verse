import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/data/models/user_currency.dart';
import 'package:petverse/presentation/providers/currency_provider.dart';
import 'package:petverse/presentation/providers/theme_provider.dart';

/// Tipos de mini-games disponíveis
enum GameType {
  coinClicker('Coin Clicker', Icons.monetization_on, Colors.amber),
  petCare('Pet Care', Icons.pets, Colors.green),
  memoryGame('Jogo da Memória', Icons.psychology, Colors.blue),
  puzzleGame('Quebra-Cabeça', Icons.extension, Colors.purple);

  const GameType(this.displayName, this.icon, this.color);
  final String displayName;
  final IconData icon;
  final Color color;
}

/// Tela de jogos com mini-games interativos
class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _coinAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _coinScaleAnimation;
  late Animation<double> _coinRotationAnimation;

  // Estados dos jogos
  int _clickCount = 0;
  int _streak = 0;
  final bool _isPlaying = false;
  GameType? _selectedGame;

  // Configurações dos jogos
  static const int coinsPerClick = 10;
  static const int streakBonus = 5;
  static const int maxStreak = 10;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _coinAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _coinAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _coinScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _coinAnimationController,
      curve: Curves.elasticOut,
    ));

    _coinRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _coinAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ref.watch(isLightThemeProvider);
    final userCurrency = ref.watch(userCurrencyProvider);

    return Scaffold(
      backgroundColor: isLightTheme ? Colors.green[50] : Colors.green[900],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com estatísticas
              _buildHeader(isLightTheme, userCurrency),
              const SizedBox(height: 24),

              // Seletor de jogos
              _buildGameSelector(isLightTheme),
              const SizedBox(height: 24),

              // Área do jogo ativo
              _buildGameArea(isLightTheme, userCurrency),
              const SizedBox(height: 24),

              // Estatísticas e conquistas
              _buildStatsSection(isLightTheme),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o cabeçalho com estatísticas
  Widget _buildHeader(bool isLightTheme, UserCurrency userCurrency) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLightTheme
              ? [Colors.green[400]!, Colors.green[600]!]
              : [Colors.green[700]!, Colors.green[900]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🎮 Central de Jogos 🎮',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Saldo Atual',
                '${userCurrency.coinsFormatted} 💰',
                Colors.white,
              ),
              _buildStatItem(
                'Cliques Hoje',
                _clickCount.toString(),
                Colors.white,
              ),
              _buildStatItem(
                'Streak',
                '$_streak/$maxStreak',
                Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói um item de estatística
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  /// Constrói o seletor de jogos
  Widget _buildGameSelector(bool isLightTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escolha seu Jogo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: GameType.values.length,
          itemBuilder: (context, index) {
            final game = GameType.values[index];
            final isSelected = _selectedGame == game;

            return GestureDetector(
              onTap: () => _selectGame(game),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLightTheme ? Colors.white : Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? game.color
                        : (isLightTheme
                            ? Colors.grey[300]!
                            : Colors.grey[600]!),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? game.color.withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: isSelected ? 12 : 6,
                      offset: Offset(0, isSelected ? 6 : 3),
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
                        color: game.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        game.icon,
                        color: game.color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      game.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isLightTheme ? Colors.grey[800] : Colors.grey[100],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: game.color,
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
          },
        ),
      ],
    );
  }

  /// Constrói a área do jogo
  Widget _buildGameArea(bool isLightTheme, UserCurrency userCurrency) {
    if (_selectedGame == null) {
      return _buildSelectGamePrompt(isLightTheme);
    }

    switch (_selectedGame!) {
      case GameType.coinClicker:
        return _buildCoinClickerGame(isLightTheme, userCurrency);
      case GameType.petCare:
        return _buildPetCareGame(isLightTheme);
      case GameType.memoryGame:
        return _buildMemoryGame(isLightTheme);
      case GameType.puzzleGame:
        return _buildPuzzleGame(isLightTheme);
    }
  }

  /// Constrói o prompt para selecionar um jogo
  Widget _buildSelectGamePrompt(bool isLightTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.white : Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLightTheme ? Colors.grey[300]! : Colors.grey[600]!,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.gamepad,
            size: 64,
            color: isLightTheme ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Selecione um jogo acima\npara começar a diversão!',
            style: TextStyle(
              fontSize: 18,
              color: isLightTheme ? Colors.grey[600] : Colors.grey[300],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Constrói o jogo Coin Clicker
  Widget _buildCoinClickerGame(bool isLightTheme, UserCurrency userCurrency) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          Text(
            'Coin Clicker',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Clique na moeda para ganhar coins!',
            style: TextStyle(
              fontSize: 14,
              color: isLightTheme ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 32),

          // Moeda clicável
          AnimatedBuilder(
            animation:
                Listenable.merge([_pulseAnimation, _coinAnimationController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value * _coinScaleAnimation.value,
                child: Transform.rotate(
                  angle: _coinRotationAnimation.value * 3.14159 * 2,
                  child: GestureDetector(
                    onTap: _handleCoinClick,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
                          center: Alignment.center,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '💰',
                          style: TextStyle(fontSize: 64),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Informações do jogo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      '+$coinsPerClick',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber,
                      ),
                    ),
                    Text(
                      'Coins por clique',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '+$streakBonus',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Bônus de streak',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_streak > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Streak de $_streak! 🔥',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Constrói outros jogos (placeholders)
  Widget _buildPetCareGame(bool isLightTheme) {
    return _buildComingSoonGame('Pet Care', '🐾', isLightTheme);
  }

  Widget _buildMemoryGame(bool isLightTheme) {
    return _buildComingSoonGame('Jogo da Memória', '🧠', isLightTheme);
  }

  Widget _buildPuzzleGame(bool isLightTheme) {
    return _buildComingSoonGame('Quebra-Cabeça', '🧩', isLightTheme);
  }

  /// Constrói um placeholder para jogos em desenvolvimento
  Widget _buildComingSoonGame(
      String gameName, String emoji, bool isLightTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            gameName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Em breve!',
            style: TextStyle(
              fontSize: 16,
              color: isLightTheme ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showComingSoonDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[500],
              foregroundColor: Colors.white,
            ),
            child: const Text('Notificar quando disponível'),
          ),
        ],
      ),
    );
  }

  /// Constrói a seção de estatísticas
  Widget _buildStatsSection(bool isLightTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conquistas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isLightTheme ? Colors.grey[800] : Colors.grey[100],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isLightTheme ? Colors.white : Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildAchievement(
                'Primeiro Clique',
                'Clique pela primeira vez',
                _clickCount > 0,
                AchievementColors.bronze,
              ),
              const SizedBox(height: 12),
              _buildAchievement(
                'Clicador Iniciante',
                'Faça 100 cliques',
                _clickCount >= 100,
                Colors.amber,
              ),
              const SizedBox(height: 12),
              _buildAchievement(
                'Streak Master',
                'Alcance 10 de streak',
                _streak >= 10,
                Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Constrói uma conquista
  Widget _buildAchievement(
      String title, String description, bool unlocked, Color color) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: unlocked ? color : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            unlocked ? Icons.emoji_events : Icons.lock,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: unlocked ? color : Colors.grey[500],
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (unlocked)
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 24,
          ),
      ],
    );
  }

  // Métodos de ação
  void _selectGame(GameType game) {
    setState(() {
      _selectedGame = game;
    });
  }

  void _handleCoinClick() {
    final currencyNotifier = ref.read(userCurrencyProvider.notifier);

    setState(() {
      _clickCount++;
      _streak = (_streak + 1).clamp(0, maxStreak);
    });

    // Calcula recompensa
    int reward = coinsPerClick;
    if (_streak >= 5) {
      reward += streakBonus;
    }

    // Adiciona coins
    currencyNotifier.addCoins(reward);

    // Anima a moeda
    _coinAnimationController.forward().then((_) {
      _coinAnimationController.reverse();
    });

    // Reset do streak após 3 segundos de inatividade
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _streak = 0;
        });
      }
    });
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Em Desenvolvimento'),
        content: const Text(
            'Este jogo estará disponível em uma próxima atualização!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}

/// Cores customizadas para conquistas
extension AchievementColors on Color {
  static const Color bronze = Color(0xFFCD7F32);
}
