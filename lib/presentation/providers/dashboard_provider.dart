// lib/presentation/providers/dashboard_provider.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/service/dashboard_service.dart';
import 'package:petverse/presentation/providers/currency_provider.dart';
import 'package:petverse/presentation/providers/pet_provider.dart';

/// Provider para o serviço do dashboard
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

/// Provider para estatísticas do dashboard
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return service.getDashboardStats();
});

/// Provider para atividades recentes
final recentActivitiesProvider = StreamProvider<List<RecentActivity>>((ref) {
  final service = ref.watch(dashboardServiceProvider);
  return service.getRecentActivities(limit: 10);
});

/// Provider para dica do dia
final dailyTipProvider = FutureProvider<DailyTip?>((ref) async {
  final service = ref.watch(dashboardServiceProvider);
  return service.getDailyTip();
});

/// Provider para estatísticas de pets em tempo real
final petStatsStreamProvider = StreamProvider<Map<String, int>>((ref) {
  final service = ref.watch(dashboardServiceProvider);
  return service.getPetStats();
});

/// StateNotifier para gerenciar ações do dashboard
class DashboardActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final DashboardService _service;
  final Ref _ref;

  DashboardActionsNotifier(this._service, this._ref)
      : super(const AsyncData(null));

  /// Registra uma ação de cuidado com pet
  Future<void> recordPetCareAction(
      String action, String petId, String petName) async {
    state = const AsyncLoading();

    try {
      String title = '';
      String description = '';

      switch (action) {
        case 'feed':
          title = 'Pet Alimentado';
          description = 'Você alimentou $petName';
          break;
        case 'play':
          title = 'Brincou com Pet';
          description = 'Você brincou com $petName';
          break;
        case 'rest':
          title = 'Pet Descansando';
          description = '$petName está descansando';
          break;
      }

      await _service.addActivity(
        title: title,
        description: description,
        type: 'pet_care',
        petId: petId,
        metadata: {'action': action},
      );

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// Registra progresso em jogo
  Future<void> recordGameProgress(
      String gameId, int score, int coinsEarned) async {
    state = const AsyncLoading();

    try {
      await _service.updateGameScore(gameId, score);
      await _service.addActivity(
        title: 'Novo Score!',
        description: 'Score de $score no $gameId. Ganhou $coinsEarned coins!',
        type: 'game',
        metadata: {
          'gameId': gameId,
          'score': score,
          'coinsEarned': coinsEarned,
        },
      );

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// Registra adoção de pet
  Future<void> recordPetAdoption(
      String petId, String petName, String adoptionType) async {
    state = const AsyncLoading();

    try {
      await _service.addActivity(
        title: 'Pet Adotado!',
        description: 'Você adotou $petName',
        type: 'adoption',
        petId: petId,
        metadata: {'adoptionType': adoptionType},
      );

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  /// Atualiza tempo de jogo
  Future<void> updatePlayTime(int minutes) async {
    try {
      await _service.updatePlayTime(minutes);
    } catch (e) {
      // Log silencioso, não crítico
      print('Erro ao atualizar tempo de jogo: $e');
    }
  }

  /// Completa uma conquista
  Future<void> completeAchievement(String achievementId, int rewardCoins,
      int rewardGems, int rewardXp) async {
    state = const AsyncLoading();

    try {
      await _service.completeAchievement(achievementId);

      // Adiciona recompensas
      final currencyNotifier = _ref.read(userCurrencyProvider.notifier);
      if (rewardCoins > 0) currencyNotifier.addCoins(rewardCoins);
      if (rewardGems > 0) currencyNotifier.addGems(rewardGems);
      if (rewardXp > 0) currencyNotifier.addXp(rewardXp);

      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

/// Provider para ações do dashboard
final dashboardActionsProvider =
    StateNotifierProvider<DashboardActionsNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(dashboardServiceProvider);
  return DashboardActionsNotifier(service, ref);
});

/// Provider computado para mensagem de boas-vindas personalizada
final welcomeMessageProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;
  final userCurrency = ref.watch(userCurrencyProvider);

  String greeting;
  if (hour < 12) {
    greeting = 'Bom dia';
  } else if (hour < 18) {
    greeting = 'Boa tarde';
  } else {
    greeting = 'Boa noite';
  }

  // Mensagens personalizadas baseadas no nível
  if (userCurrency.level >= 10) {
    return '$greeting, Mestre dos Pets!';
  } else if (userCurrency.level >= 5) {
    return '$greeting, Cuidador Experiente!';
  } else {
    return '$greeting, Novo Cuidador!';
  }
});

/// Provider para sugestões de ações
final quickActionSuggestionsProvider =
    Provider<List<QuickActionSuggestion>>((ref) {
  final currentPet = ref.watch(currentAdoptedPetProvider);
  final userCurrency = ref.watch(userCurrencyProvider);
  final suggestions = <QuickActionSuggestion>[];

  // Sugestão baseada no pet
  if (currentPet == null) {
    suggestions.add(QuickActionSuggestion(
      title: 'Adote um Pet',
      description: 'Comece sua jornada adotando um companheiro',
      action: QuickActionType.adoptPet,
      priority: 10,
    ));
  } else if (currentPet.isCriticalStatus) {
    suggestions.add(QuickActionSuggestion(
      title: 'Pet Precisa de Cuidados!',
      description: '${currentPet.name} está precisando de atenção',
      action: QuickActionType.carePet,
      priority: 9,
    ));
  }

  // Sugestão baseada em recursos
  if (userCurrency.coins < 100) {
    suggestions.add(QuickActionSuggestion(
      title: 'Ganhe Coins',
      description: 'Jogue mini-games para ganhar mais coins',
      action: QuickActionType.playGame,
      priority: 8,
    ));
  }

  // Sugestão baseada em tempo
  final now = DateTime.now();
  if (now.hour >= 9 && now.hour <= 21) {
    suggestions.add(QuickActionSuggestion(
      title: 'Visite a Loja',
      description: 'Confira as ofertas do dia',
      action: QuickActionType.visitStore,
      priority: 5,
    ));
  }

  // Ordena por prioridade
  suggestions.sort((a, b) => b.priority.compareTo(a.priority));

  return suggestions.take(4).toList();
});

/// Modelo para sugestão de ação rápida
class QuickActionSuggestion {
  final String title;
  final String description;
  final QuickActionType action;
  final int priority;

  QuickActionSuggestion({
    required this.title,
    required this.description,
    required this.action,
    required this.priority,
  });
}

/// Tipos de ações rápidas
enum QuickActionType {
  adoptPet,
  carePet,
  playGame,
  visitStore,
  checkFeed,
}

/// Provider para timer de sessão
final sessionTimerProvider =
    StateNotifierProvider<SessionTimerNotifier, int>((ref) {
  return SessionTimerNotifier(ref);
});

/// Notifier para controlar tempo de sessão
class SessionTimerNotifier extends StateNotifier<int> {
  final Ref _ref;
  Timer? _timer;
  DateTime? _sessionStart;

  SessionTimerNotifier(this._ref) : super(0) {
    startSession();
  }

  void startSession() {
    _sessionStart = DateTime.now();
    _timer?.cancel();

    // Atualiza a cada minuto
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      state = state + 1;

      // Salva tempo de jogo a cada 5 minutos
      if (state % 5 == 0) {
        _ref.read(dashboardActionsProvider.notifier).updatePlayTime(5);
      }
    });
  }

  void endSession() {
    if (_sessionStart != null) {
      final totalMinutes = DateTime.now().difference(_sessionStart!).inMinutes;
      if (totalMinutes > 0) {
        _ref
            .read(dashboardActionsProvider.notifier)
            .updatePlayTime(totalMinutes);
      }
    }

    _timer?.cancel();
    state = 0;
  }

  @override
  void dispose() {
    endSession();
    super.dispose();
  }
}

/// Provider para verificar conquistas desbloqueáveis
final availableAchievementsProvider = Provider<List<AchievementCheck>>((ref) {
  final userCurrency = ref.watch(userCurrencyProvider);
  final petStats = ref.watch(petStatsStreamProvider);
  final dashboardStats = ref.watch(dashboardStatsProvider);

  final checks = <AchievementCheck>[];

  // Conquistas de nível
  if (userCurrency.level == 5) {
    checks.add(AchievementCheck(
      id: 'level_5',
      name: 'Iniciante Dedicado',
      description: 'Alcance o nível 5',
      isCompleted: true,
      rewardCoins: 500,
      rewardGems: 10,
      rewardXp: 100,
    ));
  }

  // Conquistas de pets
  petStats.whenData((stats) {
    if (stats['adopted'] == 1) {
      checks.add(AchievementCheck(
        id: 'first_adoption',
        name: 'Primeiro Amor',
        description: 'Adote seu primeiro pet',
        isCompleted: true,
        rewardCoins: 200,
        rewardGems: 5,
        rewardXp: 50,
      ));
    }
  });

  // Conquistas de daily streak
  dashboardStats.whenData((stats) {
    if (stats.dailyStreak >= 7) {
      checks.add(AchievementCheck(
        id: 'streak_7',
        name: 'Semana Completa',
        description: 'Mantenha uma sequência de 7 dias',
        isCompleted: true,
        rewardCoins: 700,
        rewardGems: 15,
        rewardXp: 150,
      ));
    }
  });

  return checks;
});

/// Modelo para verificação de conquista
class AchievementCheck {
  final String id;
  final String name;
  final String description;
  final bool isCompleted;
  final int rewardCoins;
  final int rewardGems;
  final int rewardXp;

  AchievementCheck({
    required this.id,
    required this.name,
    required this.description,
    required this.isCompleted,
    required this.rewardCoins,
    required this.rewardGems,
    required this.rewardXp,
  });
}
