// File: lib/presentation/providers/ui_animations_provider.dart
// Provider para gerenciar animações avançadas da interface

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado das animações da UI
class UIAnimationsState {
  final bool isFloatingAnimationEnabled;
  final bool isParticleAnimationEnabled;
  final bool isTransitionAnimationEnabled;
  final double animationSpeed;
  final bool reduceMotion;

  const UIAnimationsState({
    this.isFloatingAnimationEnabled = true,
    this.isParticleAnimationEnabled = true,
    this.isTransitionAnimationEnabled = true,
    this.animationSpeed = 1.0,
    this.reduceMotion = false,
  });

  UIAnimationsState copyWith({
    bool? isFloatingAnimationEnabled,
    bool? isParticleAnimationEnabled,
    bool? isTransitionAnimationEnabled,
    double? animationSpeed,
    bool? reduceMotion,
  }) {
    return UIAnimationsState(
      isFloatingAnimationEnabled: isFloatingAnimationEnabled ?? this.isFloatingAnimationEnabled,
      isParticleAnimationEnabled: isParticleAnimationEnabled ?? this.isParticleAnimationEnabled,
      isTransitionAnimationEnabled:
          isTransitionAnimationEnabled ?? this.isTransitionAnimationEnabled,
      animationSpeed: animationSpeed ?? this.animationSpeed,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }

  Duration get baseDuration => Duration(
        milliseconds: (300 / animationSpeed).round(),
      );

  Duration get longDuration => Duration(
        milliseconds: (600 / animationSpeed).round(),
      );

  Duration get shortDuration => Duration(
        milliseconds: (150 / animationSpeed).round(),
      );
}

/// Notifier para controlar animações
class UIAnimationsNotifier extends StateNotifier<UIAnimationsState> {
  UIAnimationsNotifier() : super(const UIAnimationsState());

  void toggleFloatingAnimation() {
    state = state.copyWith(
      isFloatingAnimationEnabled: !state.isFloatingAnimationEnabled,
    );
  }

  void toggleParticleAnimation() {
    state = state.copyWith(
      isParticleAnimationEnabled: !state.isParticleAnimationEnabled,
    );
  }

  void toggleTransitionAnimation() {
    state = state.copyWith(
      isTransitionAnimationEnabled: !state.isTransitionAnimationEnabled,
    );
  }

  void setAnimationSpeed(double speed) {
    state = state.copyWith(animationSpeed: speed.clamp(0.5, 2.0));
  }

  void setReduceMotion(bool reduce) {
    state = state.copyWith(
      reduceMotion: reduce,
      isFloatingAnimationEnabled: !reduce,
      isParticleAnimationEnabled: !reduce,
      animationSpeed: reduce ? 0.5 : 1.0,
    );
  }

  void resetToDefaults() {
    state = const UIAnimationsState();
  }
}

/// Provider das animações da UI
final uiAnimationsProvider = StateNotifierProvider<UIAnimationsNotifier, UIAnimationsState>((ref) {
  return UIAnimationsNotifier();
});

/// Configurações específicas de animação para pets
class PetAnimationConfig {
  static const Duration floatingDuration = Duration(seconds: 3);
  static const Duration scaleDuration = Duration(milliseconds: 200);
  static const Duration particleDuration = Duration(seconds: 2);
  static const Duration feedbackDuration = Duration(seconds: 1);

  /// Curvas de animação personalizadas
  static const Curve floatingCurve = Curves.easeInOut;
  static const Curve scaleCurve = Curves.elasticOut;
  static const Curve particleCurve = Curves.easeOut;
  static const Curve transitionCurve = Curves.easeInOutCubic;

  /// Configurações de partículas
  static const int maxParticles = 15;
  static const double particleSize = 4.0;
  static const double particleSpread = 60.0;
  static const double particleSpeed = 100.0;

  /// Cores das partículas por ação
  static const Map<String, List<Color>> particleColors = {
    'feed': [Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFF4ECDC4)],
    'play': [Color(0xFF95E1D3), Color(0xFFA8E6CF), Color(0xFFFFD93D)],
    'rest': [Color(0xFFADD8E6), Color(0xFF87CEEB), Color(0xFFB0C4DE)],
    'heal': [Color(0xFFFFA07A), Color(0xFFFFB6C1), Color(0xFFDDA0DD)],
    'default': [Color(0xFFFFD700), Color(0xFFFFB347), Color(0xFFFF69B4)],
  };

  /// Obter cores das partículas por ação
  static List<Color> getParticleColors(String action) {
    return particleColors[action] ?? particleColors['default']!;
  }

  /// Aplicar velocidade baseada nas configurações
  static Duration getAdjustedDuration(Duration baseDuration, double speedMultiplier) {
    final adjustedMilliseconds = (baseDuration.inMilliseconds / speedMultiplier).round();
    return Duration(milliseconds: adjustedMilliseconds);
  }
}

/// Helper para criar animações responsivas
class ResponsiveAnimationHelper {
  static Duration getDurationForScreenSize(BuildContext context, Duration baseDuration) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 400) {
      // Dispositivos pequenos: animações mais rápidas
      return Duration(milliseconds: (baseDuration.inMilliseconds * 0.8).round());
    } else if (screenWidth > 800) {
      // Tablets/Desktop: animações mais suaves
      return Duration(milliseconds: (baseDuration.inMilliseconds * 1.2).round());
    }

    return baseDuration;
  }

  static double getScaleForScreenSize(BuildContext context, double baseScale) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 400) {
      return baseScale * 0.9;
    } else if (screenWidth > 800) {
      return baseScale * 1.1;
    }

    return baseScale;
  }
}

/// Extension para AnimationController com configurações automáticas
extension SmartAnimationController on AnimationController {
  void smartRepeat({
    bool reverse = false,
    Duration? period,
    required WidgetRef ref,
  }) {
    final animationsState = ref.read(uiAnimationsProvider);

    if (animationsState.reduceMotion) {
      // Modo reduzido: apenas uma iteração
      forward();
      return;
    }

    final adjustedPeriod = period != null
        ? Duration(milliseconds: (period.inMilliseconds / animationsState.animationSpeed).round())
        : null;

    repeat(reverse: reverse, period: adjustedPeriod);
  }

  void smartForward({required WidgetRef ref}) {
    final animationsState = ref.read(uiAnimationsProvider);

    if (animationsState.reduceMotion) {
      value = 1.0; // Pular para o estado final
      return;
    }

    forward();
  }
}

/// Provider de configuração de partículas
final particleConfigProvider = Provider<Map<String, dynamic>>((ref) {
  final animationsState = ref.watch(uiAnimationsProvider);

  return {
    'enabled': animationsState.isParticleAnimationEnabled && !animationsState.reduceMotion,
    'maxParticles': animationsState.reduceMotion ? 5 : PetAnimationConfig.maxParticles,
    'speed': PetAnimationConfig.particleSpeed * animationsState.animationSpeed,
    'size': PetAnimationConfig.particleSize,
    'spread': PetAnimationConfig.particleSpread,
  };
});

/// Provider para verificar se animações devem ser executadas
final shouldAnimateProvider = Provider<bool>((ref) {
  final animationsState = ref.watch(uiAnimationsProvider);
  return !animationsState.reduceMotion;
});
