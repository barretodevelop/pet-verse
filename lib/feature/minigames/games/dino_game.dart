// lib/feature/minigames/dino_game.dart
// ALTERAÇÃO - Implementação completa usando Flame Engine

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petverse/feature/minigames/mini_game.dart';

// ===== IMPLEMENTAÇÃO DO MINI GAME =====
class DinoGame implements MiniGame {
  @override
  String get name => "Corrida do Dinossauro";

  @override
  String get description =>
      "Ajude o dinossauro a pular cactos e acumular pontos!";

  @override
  IconData get icon => Icons.directions_run;

  @override
  Color get color => Colors.green;

  @override
  Widget buildGame(BuildContext context, Function(int) onGameComplete) {
    return DinoGameScreen(onGameComplete: onGameComplete);
  }
}

// ===== CONFIGURAÇÕES DO JOGO =====
class DinoGameConfig {
  static const double gravity = 980.0;
  static const double jumpSpeed = 350.0; // Pulo mais alto
  static const double gameSpeed = 150.0; // Velocidade reduzida
  static const double groundHeight = 120.0; // Chão mais alto
  static const double dinoWidth = 60.0; // Dinossauro maior
  static const double dinoHeight = 60.0;
  static const double obstacleMinWidth = 40.0; // Obstáculos maiores
  static const double obstacleMaxWidth = 80.0;
  static const double obstacleHeight = 60.0;
  static const double spawnInterval = 2.5; // Intervalo maior
  static const int pointsPerSecond = 10;
  static const int speedIncreaseInterval = 100;
  static const double speedIncreaseAmount = 20.0;
}

// ===== GAME STATE =====
enum GameState { waiting, playing, gameOver }

// ===== JOGO PRINCIPAL (FLAME ENGINE) =====
class DinoFlameGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection, TapDetector {
  late DinoComponent dino;
  late GroundComponent ground;
  late TextComponent scoreText;
  late TextComponent instructionText;
  late TextComponent gameOverText;

  GameState currentState = GameState.waiting;
  int score = 0;
  double currentGameSpeed = DinoGameConfig.gameSpeed;
  double lastObstacleSpawn = 0;
  double timeSinceStart = 0;

  Function(int)? onGameComplete;

  DinoFlameGame({this.onGameComplete});

  @override
  Future<void> onLoad() async {
    // Adiciona componentes
    await _loadComponents();
  }

  Future<void> _loadComponents() async {
    // Background branco
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.white,
    ));

    // Chão
    ground = GroundComponent();
    add(ground);

    // Dinossauro
    dino = DinoComponent();
    add(dino);

    // Textos da UI
    scoreText = TextComponent(
      text: 'Pontos: 0',
      position: Vector2(size.x - 150, 30),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(scoreText);

    instructionText = TextComponent(
      text: 'Toque para começar',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(instructionText);

    gameOverText = TextComponent(
      text: '',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(gameOverText);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (currentState == GameState.playing) {
      _updateGameplay(dt);
    }
  }

  void _updateGameplay(double dt) {
    timeSinceStart += dt;
    lastObstacleSpawn += dt;

    // Atualiza pontuação
    score = (timeSinceStart * DinoGameConfig.pointsPerSecond).round();
    scoreText.text = 'Pontos: $score';

    // Aumenta velocidade gradualmente
    currentGameSpeed = DinoGameConfig.gameSpeed +
        (score ~/ DinoGameConfig.speedIncreaseInterval) *
            DinoGameConfig.speedIncreaseAmount;

    // Spawna novos obstáculos
    if (lastObstacleSpawn >= DinoGameConfig.spawnInterval) {
      _spawnObstacle();
      lastObstacleSpawn = 0;
    }

    // Remove obstáculos fora da tela
    children
        .whereType<ObstacleComponent>()
        .where((obstacle) => obstacle.position.x < -100)
        .forEach((obstacle) => obstacle.removeFromParent());
  }

  void _spawnObstacle() {
    final obstacle = ObstacleComponent(gameSpeed: currentGameSpeed);
    add(obstacle);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    _handleInput();
    return true;
  }

  void _handleInput() {
    switch (currentState) {
      case GameState.waiting:
        _startGame();
        break;
      case GameState.playing:
        dino.jump();
        break;
      case GameState.gameOver:
        _restartGame();
        break;
    }
  }

  void _startGame() {
    currentState = GameState.playing;
    instructionText.text = '';
    gameOverText.text = '';
    timeSinceStart = 0;
    score = 0;
    print('🎮 Jogo iniciado!');
    print('📏 Tamanho da tela: ${size.x} x ${size.y}');
    print('🦕 Posição do dinossauro: ${dino.position.x}, ${dino.position.y}');

    // Força criação do primeiro obstáculo após 1 segundo
    Future.delayed(const Duration(seconds: 1), () {
      if (currentState == GameState.playing) {
        _spawnObstacle();
      }
    });
  }

  void _restartGame() {
    // Remove todos os obstáculos
    children
        .whereType<ObstacleComponent>()
        .forEach((obstacle) => obstacle.removeFromParent());

    // Reset do estado
    currentState = GameState.waiting;
    score = 0;
    timeSinceStart = 0;
    lastObstacleSpawn = 0;
    currentGameSpeed = DinoGameConfig.gameSpeed;

    // Reset do dinossauro
    dino.reset();

    // Reset dos textos
    instructionText.text = 'Toque para começar';
    gameOverText.text = '';
    scoreText.text = 'Pontos: 0';

    print('🔄 Jogo reiniciado!');
  }

  void gameOver() {
    currentState = GameState.gameOver;
    gameOverText.text = 'Game Over\nPontuação: $score\n\nToque para reiniciar';
    HapticFeedback.heavyImpact();
    onGameComplete?.call(score);
    print('💀 Game Over! Score: $score');
  }
}

// ===== COMPONENTE DO DINOSSAURO =====
class DinoComponent extends PositionComponent
    with CollisionCallbacks, HasGameRef<DinoFlameGame> {
  double velocityY = 0;
  bool isGrounded = true;
  bool isJumping = false;

  final Paint _paint = Paint()..color = Colors.black87;
  final Paint _eyePaint = Paint()..color = Colors.white;

  @override
  Future<void> onLoad() async {
    // Tamanho maior e mais visível
    size = Vector2(60, 60); // Aumentado de 40x40 para 60x60
    position = Vector2(100, game.size.y - DinoGameConfig.groundHeight - size.y);

    // Adiciona hitbox para colisão
    add(RectangleHitbox()..isSolid = true);

    print('🦕 Dinossauro criado em posição: ${position.x}, ${position.y}');
    print('🦕 Tamanho do dinossauro: ${size.x}x${size.y}');
    print('🖥️ Tamanho da tela: ${game.size.x}x${game.size.y}');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isGrounded) {
      // Aplica gravidade
      velocityY += DinoGameConfig.gravity * dt;
      position.y += velocityY * dt;

      // Verifica se chegou no chão
      final groundY = game.size.y - DinoGameConfig.groundHeight - size.y;
      if (position.y >= groundY) {
        position.y = groundY;
        velocityY = 0;
        isGrounded = true;
        isJumping = false;
      }
    }
  }

  void jump() {
    if (isGrounded && !isJumping) {
      velocityY = -DinoGameConfig.jumpSpeed;
      isGrounded = false;
      isJumping = true;
      HapticFeedback.lightImpact();
      print('🦕 Dinossauro pulou! Nova posição Y: ${position.y}');
    }
  }

  void reset() {
    position.y = game.size.y - DinoGameConfig.groundHeight - size.y;
    velocityY = 0;
    isGrounded = true;
    isJumping = false;
    print('🔄 Dinossauro resetado para posição: ${position.x}, ${position.y}');
  }

  @override
  void render(Canvas canvas) {
    // Corpo do dinossauro (retângulo maior)
    canvas.drawRect(size.toRect(), _paint);

    // Olho maior
    canvas.drawCircle(
      Offset(size.x * 0.7, size.y * 0.3),
      6, // Aumentado de 3 para 6
      _eyePaint,
    );

    // Pernas mais visíveis (apenas quando no chão)
    if (isGrounded) {
      final legPaint = Paint()
        ..color = Colors.black87
        ..strokeWidth = 4; // Mais grosso
      canvas.drawLine(
        Offset(size.x * 0.3, size.y),
        Offset(size.x * 0.3, size.y + 12), // Pernas mais compridas
        legPaint,
      );
      canvas.drawLine(
        Offset(size.x * 0.7, size.y),
        Offset(size.x * 0.7, size.y + 12),
        legPaint,
      );
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is ObstacleComponent) {
      print('💥 Colisão detectada!');
      game.gameOver();
    }
  }
}

// ===== COMPONENTE DO OBSTÁCULO =====
class ObstacleComponent extends PositionComponent
    with HasGameRef<DinoFlameGame> {
  final double gameSpeed;
  final Paint _paint = Paint()
    ..color = Colors.green.shade700; // Cor mais visível

  ObstacleComponent({required this.gameSpeed});

  @override
  Future<void> onLoad() async {
    final random = Random();
    final width = 40 + random.nextDouble() * 40; // Largura entre 40-80 (maior)

    size = Vector2(width, 60); // Altura maior (60 ao invés de 40)
    position = Vector2(
      game.size.x + 50, // Começa mais à direita
      game.size.y - DinoGameConfig.groundHeight - size.y,
    );

    // Adiciona hitbox para colisão
    add(RectangleHitbox()..isSolid = true);

    print(
        '🌵 Obstáculo criado em x=${position.x}, tamanho: ${size.x}x${size.y}');
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= gameSpeed * dt;

    // Remove se saiu da tela
    if (position.x < -100) {
      print('🗑️ Obstáculo removido (fora da tela)');
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // Corpo do cacto (mais visível)
    canvas.drawRect(size.toRect(), _paint);

    // Borda para destacar
    canvas.drawRect(
      size.toRect(),
      Paint()
        ..color = Colors.green.shade900
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Espinhos do cacto (maiores)
    final spinePaint = Paint()
      ..color = Colors.green.shade900
      ..strokeWidth = 2;
    final spineCount = (size.x / 12).floor();

    for (int i = 0; i < spineCount; i++) {
      final x = (i + 1) * (size.x / (spineCount + 1));

      // Espinho superior
      canvas.drawLine(
        Offset(x, size.y * 0.2),
        Offset(x - 4, size.y * 0.1),
        spinePaint,
      );

      // Espinho inferior
      canvas.drawLine(
        Offset(x, size.y * 0.6),
        Offset(x + 4, size.y * 0.5),
        spinePaint,
      );
    }
  }
}

// ===== COMPONENTE DO CHÃO =====
class GroundComponent extends PositionComponent with HasGameRef<DinoFlameGame> {
  final Paint _paint = Paint()
    ..color = Colors.brown.shade600
    ..strokeWidth = 4;

  @override
  Future<void> onLoad() async {
    size = Vector2(game.size.x, 4); // Linha mais grossa
    position = Vector2(0, game.size.y - DinoGameConfig.groundHeight);

    print('🌍 Chão criado em posição Y: ${position.y}');
    print('🌍 Tamanho do chão: ${size.x}x${size.y}');
  }

  @override
  void render(Canvas canvas) {
    // Linha do chão mais visível
    canvas.drawRect(size.toRect(), _paint);

    // Linha adicional para destaque
    canvas.drawLine(
      const Offset(0, 0),
      Offset(size.x, 0),
      Paint()
        ..color = Colors.brown.shade800
        ..strokeWidth = 2,
    );
  }
}

// ===== TELA PRINCIPAL (INTEGRAÇÃO COM FLUTTER) =====
class DinoGameScreen extends StatefulWidget {
  final Function(int) onGameComplete;

  const DinoGameScreen({super.key, required this.onGameComplete});

  @override
  State<DinoGameScreen> createState() => _DinoGameScreenState();
}

class _DinoGameScreenState extends State<DinoGameScreen> {
  late DinoFlameGame game;

  @override
  void initState() {
    super.initState();
    game = DinoFlameGame(onGameComplete: widget.onGameComplete);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade800,
        title: const Text(
          'Corrida do Dinossauro',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => game._restartGame(),
          ),
        ],
      ),
      body: GameWidget(game: game),
    );
  }
}
