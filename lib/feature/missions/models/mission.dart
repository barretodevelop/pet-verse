// lib/features/missions/models/mission.dart
import 'package:equatable/equatable.dart';

enum MissionType { daily, weekly, special }
enum MissionStatus { locked, available, completed, claimed }

class Mission extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final MissionType type;
  final MissionStatus status;
  final int reward;
  final int currentProgress;
  final int targetProgress;
  final DateTime? completedAt;
  final DateTime? expiresAt;

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.status,
    required this.reward,
    required this.currentProgress,
    required this.targetProgress,
    this.completedAt,
    this.expiresAt,
  });

  double get progressPercentage => currentProgress / targetProgress;
  bool get isCompleted => currentProgress >= targetProgress;
  bool get canClaim => isCompleted && status != MissionStatus.claimed;

  Mission copyWith({
    MissionStatus? status,
    int? currentProgress,
    DateTime? completedAt,
  }) {
    return Mission(
      id: id,
      title: title,
      description: description,
      icon: icon,
      type: type,
      status: status ?? this.status,
      reward: reward,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt,
    );
  }

  @override
  List<Object?> get props => [
    id, title, type, status, currentProgress, targetProgress, completedAt
  ];
}

// Missões disponíveis
class DailyMissions {
  static List<Mission> getMissionsForToday() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return [
      Mission(
        id: 'daily_feed_3',
        title: 'Alimentador Dedicado',
        description: 'Alimente seu pet 3 vezes hoje',
        icon: '🍖',
        type: MissionType.daily,
        status: MissionStatus.available,
        reward: 50,
        currentProgress: 0,
        targetProgress: 3,
        expiresAt: endOfDay,
      ),
      Mission(
        id: 'daily_play_2',
        title: 'Hora da Diversão',
        description: 'Brinque com seu pet 2 vezes',
        icon: '🎾',
        type: MissionType.daily,
        status: MissionStatus.available,
        reward: 40,
        currentProgress: 0,
        targetProgress: 2,
        expiresAt: endOfDay,
      ),
      Mission(
        id: 'daily_clean_1',
        title: 'Pet Limpinho',
        description: 'Dê banho no seu pet',
        icon: '🛁',
        type: MissionType.daily,
        status: MissionStatus.available,
        reward: 30,
        currentProgress: 0,
        targetProgress: 1,
        expiresAt: endOfDay,
      ),
      Mission(
        id: 'daily_game_1',
        title: 'Jogador do Dia',
        description: 'Jogue 1 mini-game',
        icon: '🎮',
        type: MissionType.daily,
        status: MissionStatus.available,
        reward: 60,
        currentProgress: 0,
        targetProgress: 1,
        expiresAt: endOfDay,
      ),
      Mission(
        id: 'daily_chat_5',
        title: 'Comunicador',
        description: 'Envie 5 mensagens no chat',
        icon: '💬',
        type: MissionType.daily,
        status: MissionStatus.available,
        reward: 25,
        currentProgress: 0,
        targetProgress: 5,
        expiresAt: endOfDay,
      ),
    ];
  }
}
