// File: lib/presentation/providers/feedback_notification_provider.dart
// Sistema de feedback visual e notificações para melhor UX

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tipos de feedback visual
enum FeedbackType {
  success,
  error,
  warning,
  info,
  petAction,
  levelUp,
  achievement,
}

/// Posição do feedback na tela
enum FeedbackPosition {
  top,
  center,
  bottom,
  topRight,
  bottomLeft,
}

/// Classe de feedback visual
class VisualFeedback {
  final String id;
  final String message;
  final FeedbackType type;
  final FeedbackPosition position;
  final Duration duration;
  final IconData? icon;
  final String? emoji;
  final Color? customColor;
  final VoidCallback? onTap;
  final DateTime createdAt;

  VisualFeedback({
    required this.id,
    required this.message,
    required this.type,
    this.position = FeedbackPosition.bottom,
    this.duration = const Duration(seconds: 3),
    this.icon,
    this.emoji,
    this.customColor,
    this.onTap,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Color get defaultColor {
    switch (type) {
      case FeedbackType.success:
        return Colors.green;
      case FeedbackType.error:
        return Colors.red;
      case FeedbackType.warning:
        return Colors.orange;
      case FeedbackType.info:
        return Colors.blue;
      case FeedbackType.petAction:
        return Colors.purple;
      case FeedbackType.levelUp:
        return Colors.amber;
      case FeedbackType.achievement:
        return Colors.pink;
    }
  }

  IconData get defaultIcon {
    switch (type) {
      case FeedbackType.success:
        return Icons.check_circle;
      case FeedbackType.error:
        return Icons.error;
      case FeedbackType.warning:
        return Icons.warning;
      case FeedbackType.info:
        return Icons.info;
      case FeedbackType.petAction:
        return Icons.pets;
      case FeedbackType.levelUp:
        return Icons.star;
      case FeedbackType.achievement:
        return Icons.emoji_events;
    }
  }

  String get defaultEmoji {
    switch (type) {
      case FeedbackType.success:
        return '✅';
      case FeedbackType.error:
        return '❌';
      case FeedbackType.warning:
        return '⚠️';
      case FeedbackType.info:
        return 'ℹ️';
      case FeedbackType.petAction:
        return '🐾';
      case FeedbackType.levelUp:
        return '⭐';
      case FeedbackType.achievement:
        return '🏆';
    }
  }
}

/// Estado do sistema de feedback
class FeedbackState {
  final List<VisualFeedback> activeFeedbacks;
  final int maxConcurrentFeedbacks;
  final bool soundEnabled;
  final bool hapticEnabled;

  const FeedbackState({
    this.activeFeedbacks = const [],
    this.maxConcurrentFeedbacks = 5,
    this.soundEnabled = true,
    this.hapticEnabled = true,
  });

  FeedbackState copyWith({
    List<VisualFeedback>? activeFeedbacks,
    int? maxConcurrentFeedbacks,
    bool? soundEnabled,
    bool? hapticEnabled,
  }) {
    return FeedbackState(
      activeFeedbacks: activeFeedbacks ?? this.activeFeedbacks,
      maxConcurrentFeedbacks: maxConcurrentFeedbacks ?? this.maxConcurrentFeedbacks,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }

  bool get hasActiveFeedbacks => activeFeedbacks.isNotEmpty;
  int get activeFeedbackCount => activeFeedbacks.length;
}

/// Notifier do sistema de feedback
class FeedbackNotifier extends StateNotifier<FeedbackState> {
  FeedbackNotifier() : super(const FeedbackState());

  /// Mostrar feedback visual
  void showFeedback({
    required String message,
    required FeedbackType type,
    FeedbackPosition position = FeedbackPosition.bottom,
    Duration? duration,
    IconData? icon,
    String? emoji,
    Color? customColor,
    VoidCallback? onTap,
  }) {
    final feedback = VisualFeedback(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      type: type,
      position: position,
      duration: duration ?? const Duration(seconds: 3),
      icon: icon,
      emoji: emoji,
      customColor: customColor,
      onTap: onTap,
    );

    _addFeedback(feedback);
    _scheduleRemoval(feedback);
  }

  /// Mostrar feedback de sucesso
  void showSuccess(String message, {Duration? duration}) {
    showFeedback(
      message: message,
      type: FeedbackType.success,
      duration: duration,
    );
  }

  /// Mostrar feedback de erro
  void showError(String message, {Duration? duration}) {
    showFeedback(
      message: message,
      type: FeedbackType.error,
      duration: duration ?? const Duration(seconds: 5),
    );
  }

  /// Mostrar feedback de ação do pet
  void showPetAction(String petName, String action, {String? emoji}) {
    showFeedback(
      message: _getPetActionMessage(petName, action),
      type: FeedbackType.petAction,
      emoji: emoji ?? _getPetActionEmoji(action),
      duration: const Duration(seconds: 2),
    );
  }

  /// Mostrar feedback de level up
  void showLevelUp(String petName, int newLevel) {
    showFeedback(
      message: '🎉 $petName subiu para o nível $newLevel!',
      type: FeedbackType.levelUp,
      position: FeedbackPosition.center,
      duration: const Duration(seconds: 4),
    );
  }

  /// Mostrar conquista desbloqueada
  void showAchievement(String achievementName) {
    showFeedback(
      message: '🏆 Conquista desbloqueada: $achievementName',
      type: FeedbackType.achievement,
      position: FeedbackPosition.top,
      duration: const Duration(seconds: 5),
    );
  }

  /// Adicionar feedback à lista
  void _addFeedback(VisualFeedback feedback) {
    final currentFeedbacks = List<VisualFeedback>.from(state.activeFeedbacks);

    // Remover feedbacks antigos se exceder o limite
    while (currentFeedbacks.length >= state.maxConcurrentFeedbacks) {
      currentFeedbacks.removeAt(0);
    }

    currentFeedbacks.add(feedback);

    state = state.copyWith(activeFeedbacks: currentFeedbacks);
  }

  /// Agendar remoção automática do feedback
  void _scheduleRemoval(VisualFeedback feedback) {
    Future.delayed(feedback.duration, () {
      removeFeedback(feedback.id);
    });
  }

  /// Remover feedback específico
  void removeFeedback(String feedbackId) {
    final updatedFeedbacks =
        state.activeFeedbacks.where((feedback) => feedback.id != feedbackId).toList();

    state = state.copyWith(activeFeedbacks: updatedFeedbacks);
  }

  /// Limpar todos os feedbacks
  void clearAllFeedbacks() {
    state = state.copyWith(activeFeedbacks: []);
  }

  /// Configurar som
  void setSoundEnabled(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
  }

  /// Configurar haptic feedback
  void setHapticEnabled(bool enabled) {
    state = state.copyWith(hapticEnabled: enabled);
  }

  /// Obter mensagem personalizada para ação do pet
  String _getPetActionMessage(String petName, String action) {
    switch (action.toLowerCase()) {
      case 'feed':
      case 'feeding':
        return '$petName adorou a comida!';
      case 'play':
      case 'playing':
        return '$petName se divertiu brincando!';
      case 'rest':
      case 'sleeping':
        return '$petName está descansando...';
      case 'heal':
      case 'medicine':
        return '$petName se sente melhor agora!';
      case 'bath':
        return '$petName está limpinho!';
      case 'training':
        return '$petName aprendeu algo novo!';
      default:
        return '$petName ficou feliz!';
    }
  }

  /// Obter emoji para ação do pet
  String _getPetActionEmoji(String action) {
    switch (action.toLowerCase()) {
      case 'feed':
      case 'feeding':
        return '🍖';
      case 'play':
      case 'playing':
        return '🎾';
      case 'rest':
      case 'sleeping':
        return '😴';
      case 'heal':
      case 'medicine':
        return '💊';
      case 'bath':
        return '🛁';
      case 'training':
        return '🎓';
      default:
        return '💖';
    }
  }
}

/// Provider do sistema de feedback
final feedbackProvider = StateNotifierProvider<FeedbackNotifier, FeedbackState>((ref) {
  return FeedbackNotifier();
});

/// Provider para verificar se deve usar haptic feedback
final shouldUseHapticProvider = Provider<bool>((ref) {
  final feedbackState = ref.watch(feedbackProvider);
  return feedbackState.hapticEnabled;
});

/// Provider para verificar se deve usar som
final shouldUseSoundProvider = Provider<bool>((ref) {
  final feedbackState = ref.watch(feedbackProvider);
  return feedbackState.soundEnabled;
});

/// Helper para feedback de pets
class PetFeedbackHelper {
  static void showPetInteraction(WidgetRef ref, String petName, String action,
      {bool success = true}) {
    final feedbackNotifier = ref.read(feedbackProvider.notifier);

    if (success) {
      feedbackNotifier.showPetAction(petName, action);
    } else {
      feedbackNotifier.showError('$petName não pode fazer isso agora');
    }
  }

  static void showPetStatusChange(
    WidgetRef ref,
    String petName,
    String statusChange,
  ) {
    final feedbackNotifier = ref.read(feedbackProvider.notifier);

    feedbackNotifier.showFeedback(
      message: '$petName: $statusChange',
      type: FeedbackType.info,
      emoji: '📊',
    );
  }

  static void showPetNeedsAttention(
    WidgetRef ref,
    String petName,
    String need,
  ) {
    final feedbackNotifier = ref.read(feedbackProvider.notifier);

    feedbackNotifier.showFeedback(
      message: '$petName precisa de $need',
      type: FeedbackType.warning,
      position: FeedbackPosition.topRight,
      duration: const Duration(seconds: 4),
    );
  }
}

/// Widget para exibir feedbacks ativos na interface
class FeedbackOverlay extends ConsumerWidget {
  const FeedbackOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackState = ref.watch(feedbackProvider);

    if (!feedbackState.hasActiveFeedbacks) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
        child: Stack(
          children: feedbackState.activeFeedbacks.map((feedback) {
            return _buildFeedbackWidget(context, feedback, ref);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFeedbackWidget(BuildContext context, VisualFeedback feedback, WidgetRef ref) {
    return Positioned(
      top: _getTopPosition(feedback.position, context),
      bottom: _getBottomPosition(feedback.position, context),
      left: _getLeftPosition(feedback.position, context),
      right: _getRightPosition(feedback.position, context),
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: feedback.customColor ?? feedback.defaultColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (feedback.emoji != null)
                Text(
                  feedback.emoji!,
                  style: const TextStyle(fontSize: 20),
                )
              else
                Icon(
                  feedback.icon ?? feedback.defaultIcon,
                  color: Colors.white,
                  size: 20,
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  feedback.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double? _getTopPosition(FeedbackPosition position, BuildContext context) {
    switch (position) {
      case FeedbackPosition.top:
      case FeedbackPosition.topRight:
        return 0;
      case FeedbackPosition.center:
        return MediaQuery.of(context).size.height * 0.4;
      default:
        return null;
    }
  }

  double? _getBottomPosition(FeedbackPosition position, BuildContext context) {
    switch (position) {
      case FeedbackPosition.bottom:
      case FeedbackPosition.bottomLeft:
        return 0;
      default:
        return null;
    }
  }

  double? _getLeftPosition(FeedbackPosition position, BuildContext context) {
    switch (position) {
      case FeedbackPosition.bottomLeft:
        return 0;
      case FeedbackPosition.center:
        return 20;
      default:
        return null;
    }
  }

  double? _getRightPosition(FeedbackPosition position, BuildContext context) {
    switch (position) {
      case FeedbackPosition.topRight:
        return 0;
      default:
        return null;
    }
  }
}
