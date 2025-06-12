// File: lib/presentation/widgets/animations/advanced_particle_system.dart
// Sistema de partículas avançado para feedback visual dos pets

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/presentation/providers/ui_animations_provider.dart';

/// Classe representando uma partícula individual
class Particle {
  final String id;
  final Offset initialPosition;
  final Offset velocity;
  final Color color;
  final double size;
  final double life;
  final double maxLife;
  final ParticleType type;

  double _currentLife;
  Offset _currentPosition;

  Particle({
    required this.id,
    required this.initialPosition,
    required this.velocity,
    required this.color,
    required this.size,
    required this.life,
    required this.type,
  })  : maxLife = life,
        _currentLife = life,
        _currentPosition = initialPosition;

  double get currentLife => _currentLife;
  Offset get currentPosition => _currentPosition;
  double get lifeRatio => _currentLife / maxLife;
  bool get isAlive => _currentLife > 0;

  /// Atualizar partícula por frame
  void update(double deltaTime) {
    if (!isAlive) return;

    _currentLife -= deltaTime;

    // Aplicar movimento baseado na velocidade
    _currentPosition = Offset(
      _currentPosition.dx + velocity.dx * deltaTime,
      _currentPosition.dy + velocity.dy * deltaTime,
    );
  }

  /// Obter cor atual com fade baseado na vida
  Color get currentColor {
    final alpha = (lifeRatio * color.alpha).clamp(0, 255).toInt();
    return color.withAlpha(alpha);
  }

  /// Obter tamanho atual com escala baseada na vida
  double get currentSize {
    switch (type) {
      case ParticleType.burst:
        // Cresce rapidamente e depois diminui
        return size * (lifeRatio > 0.8 ? (1 - lifeRatio) * 5 : lifeRatio);
      case ParticleType.sparkle:
        // Mantém tamanho e depois fade
        return size * (lifeRatio > 0.3 ? 1.0 : lifeRatio * 3.33);
      case ParticleType.float:
        // Tamanho constante com fade suave
        return size;
      case ParticleType.hearts:
        // Pulsa suavemente
        return size * (0.8 + 0.2 * sin((_currentLife * 10) % (2 * pi)));
    }
  }
}

/// Tipos de partícula
enum ParticleType {
  burst, // Explosão rápida
  sparkle, // Brilho
  float, // Flutuação suave
  hearts, // Corações pulsantes
}

/// Configuração do sistema de partículas
class ParticleSystemConfig {
  final int maxParticles;
  final double emissionRate;
  final Duration particleLifetime;
  final Offset gravityAcceleration;
  final double speedVariation;
  final double sizeVariation;
  final List<Color> colors;
  final ParticleType type;

  const ParticleSystemConfig({
    this.maxParticles = 20,
    this.emissionRate = 10.0,
    this.particleLifetime = const Duration(seconds: 2),
    this.gravityAcceleration = const Offset(0, 50),
    this.speedVariation = 0.5,
    this.sizeVariation = 0.3,
    this.colors = const [Colors.yellow, Colors.orange, Colors.red],
    this.type = ParticleType.sparkle,
  });

  /// Configurações pré-definidas para ações de pet
  static const Map<String, ParticleSystemConfig> presets = {
    'feed': ParticleSystemConfig(
      colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFF4ECDC4)],
      type: ParticleType.burst,
      maxParticles: 15,
      emissionRate: 20.0,
    ),
    'play': ParticleSystemConfig(
      colors: [Color(0xFF95E1D3), Color(0xFFA8E6CF), Color(0xFFFFD93D)],
      type: ParticleType.sparkle,
      maxParticles: 25,
      emissionRate: 15.0,
    ),
    'rest': ParticleSystemConfig(
      colors: [Color(0xFFADD8E6), Color(0xFF87CEEB), Color(0xFFB0C4DE)],
      type: ParticleType.float,
      maxParticles: 10,
      emissionRate: 5.0,
      gravityAcceleration: Offset(0, -20),
    ),
    'heal': ParticleSystemConfig(
      colors: [Color(0xFFFFA07A), Color(0xFFFFB6C1), Color(0xFFDDA0DD)],
      type: ParticleType.hearts,
      maxParticles: 12,
      emissionRate: 8.0,
    ),
    'levelup': ParticleSystemConfig(
      colors: [Color(0xFFFFD700), Color(0xFFFF69B4), Color(0xFF00CED1)],
      type: ParticleType.burst,
      maxParticles: 30,
      emissionRate: 25.0,
      particleLifetime: Duration(seconds: 3),
    ),
  };

  static ParticleSystemConfig getPreset(String action) {
    return presets[action] ?? presets['play']!;
  }
}

/// Sistema de partículas
class ParticleSystem {
  final ParticleSystemConfig config;
  final List<Particle> _particles = [];
  final Random _random = Random();

  double _emissionTimer = 0;
  bool _isEmitting = false;
  Offset _emissionPosition = Offset.zero;

  ParticleSystem(this.config);

  List<Particle> get particles => _particles;
  bool get hasActiveParticles => _particles.isNotEmpty;

  /// Iniciar emissão de partículas
  void startEmission(Offset position) {
    _isEmitting = true;
    _emissionPosition = position;
    _emissionTimer = 0;
  }

  /// Parar emissão de partículas
  void stopEmission() {
    _isEmitting = false;
  }

  /// Emitir uma rajada única de partículas
  void burst(Offset position, {int? particleCount}) {
    final count = particleCount ?? (config.maxParticles * 0.6).round();

    for (int i = 0; i < count; i++) {
      _createParticle(position);
    }
  }

  /// Atualizar sistema por frame
  void update(double deltaTime) {
    // Atualizar partículas existentes
    _particles.removeWhere((particle) {
      particle.update(deltaTime);
      return !particle.isAlive;
    });

    // Emitir novas partículas se necessário
    if (_isEmitting && _particles.length < config.maxParticles) {
      _emissionTimer += deltaTime;

      final emissionInterval = 1.0 / config.emissionRate;
      while (_emissionTimer >= emissionInterval) {
        _createParticle(_emissionPosition);
        _emissionTimer -= emissionInterval;
      }
    }
  }

  /// Criar nova partícula
  void _createParticle(Offset position) {
    if (_particles.length >= config.maxParticles) return;

    final angle = _random.nextDouble() * 2 * pi;
    final speed = (50 + _random.nextDouble() * 100) *
        (1 + config.speedVariation * (_random.nextDouble() - 0.5));

    final velocity = Offset(
      cos(angle) * speed,
      sin(angle) * speed,
    );

    final color = config.colors[_random.nextInt(config.colors.length)];
    final size =
        (3 + _random.nextDouble() * 5) * (1 + config.sizeVariation * (_random.nextDouble() - 0.5));

    final particle = Particle(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      initialPosition: position,
      velocity: velocity,
      color: color,
      size: size,
      life: config.particleLifetime.inMilliseconds / 1000.0,
      type: config.type,
    );

    _particles.add(particle);
  }

  /// Limpar todas as partículas
  void clear() {
    _particles.clear();
    _isEmitting = false;
  }
}

/// Widget que renderiza o sistema de partículas
class ParticleSystemWidget extends ConsumerStatefulWidget {
  final ParticleSystemConfig config;
  final bool isActive;
  final Offset? emissionPosition;
  final String? actionType;

  const ParticleSystemWidget({
    super.key,
    required this.config,
    this.isActive = false,
    this.emissionPosition,
    this.actionType,
  });

  @override
  ConsumerState<ParticleSystemWidget> createState() => _ParticleSystemWidgetState();
}

class _ParticleSystemWidgetState extends ConsumerState<ParticleSystemWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late ParticleSystem _particleSystem;
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 16), // ~60 FPS
      vsync: this,
    );

    _particleSystem = ParticleSystem(widget.config);

    _controller.addListener(_updateParticles);
  }

  @override
  void didUpdateWidget(ParticleSystemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _startParticles();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopParticles();
    }

    if (widget.emissionPosition != null && widget.emissionPosition != oldWidget.emissionPosition) {
      _particleSystem.burst(widget.emissionPosition!);
    }
  }

  void _startParticles() {
    final animationsState = ref.read(uiAnimationsProvider);

    if (!animationsState.isParticleAnimationEnabled) return;

    _controller.repeat();

    if (widget.emissionPosition != null) {
      _particleSystem.startEmission(widget.emissionPosition!);
    }
  }

  void _stopParticles() {
    _controller.stop();
    _particleSystem.stopEmission();
  }

  void _updateParticles() {
    final now = DateTime.now();
    final deltaTime = (now.difference(_lastUpdate).inMicroseconds / 1000000.0);
    _lastUpdate = now;

    _particleSystem.update(deltaTime);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldAnimate = ref.watch(shouldAnimateProvider);

    if (!shouldAnimate || !_particleSystem.hasActiveParticles) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: ParticlesPainter(_particleSystem.particles),
        ),
      ),
    );
  }
}

/// Painter customizado para renderizar partículas
class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;

  ParticlesPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      if (!particle.isAlive) continue;

      final paint = Paint()
        ..color = particle.currentColor
        ..style = PaintingStyle.fill;

      final position = particle.currentPosition;
      final particleSize = particle.currentSize;

      switch (particle.type) {
        case ParticleType.burst:
        case ParticleType.sparkle:
        case ParticleType.float:
          // Círculo simples
          canvas.drawCircle(position, particleSize, paint);
          break;

        case ParticleType.hearts:
          // Desenhar coração
          _drawHeart(canvas, position, particleSize, paint);
          break;
      }
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();

    // Coração simplificado usando path
    final heartSize = size * 0.8;
    final left = center.dx - heartSize / 2;
    final top = center.dy - heartSize / 2;
    final right = center.dx + heartSize / 2;
    final bottom = center.dy + heartSize / 2;

    path.moveTo(center.dx, bottom);
    path.cubicTo(left, top, left - heartSize / 4, top - heartSize / 4, center.dx, center.dy);
    path.cubicTo(right + heartSize / 4, top - heartSize / 4, right, top, center.dx, bottom);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Widget helper para ações de pet com partículas
class PetActionParticles extends ConsumerWidget {
  final String action;
  final bool isActive;
  final Offset? position;
  final Widget child;

  const PetActionParticles({
    super.key,
    required this.action,
    required this.isActive,
    required this.child,
    this.position,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ParticleSystemConfig.getPreset(action);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        ParticleSystemWidget(
          config: config,
          isActive: isActive,
          emissionPosition: position,
          actionType: action,
        ),
      ],
    );
  }
}

/// Provider para controlar partículas ativas globalmente
final activeParticleSystemsProvider = StateProvider<Map<String, bool>>((ref) {
  return {};
});

/// Helper para trigger de partículas
class ParticleHelper {
  static void triggerPetAction(WidgetRef ref, String action, Offset position) {
    final activeParticles = ref.read(activeParticleSystemsProvider.notifier);
    final currentState = ref.read(activeParticleSystemsProvider);

    // Ativar partículas por um tempo determinado
    activeParticles.state = {
      ...currentState,
      action: true,
    };

    // Desativar automaticamente após 2 segundos
    Future.delayed(const Duration(seconds: 2), () {
      final newState = Map<String, bool>.from(ref.read(activeParticleSystemsProvider));
      newState.remove(action);
      activeParticles.state = newState;
    });
  }
}
