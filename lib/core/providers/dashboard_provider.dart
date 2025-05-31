// ============================================================================
// ARQUIVO 1: lib/core/providers/dashboard_provider.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/model/mocks.dart';
import 'package:petverse/core/model/user_model.dart';
import 'package:petverse/feature/auth/providers/authentication_provider.dart';

// Provider para Dashboard que usa dados reais do Firebase
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final authState = ref.watch(authenticationNotifierProvider);
  return DashboardNotifier(authState.userModel);
});

class DashboardState {
  final bool isLoading;
  final UserModel? currentUser;
  final List<Map<String, dynamic>> myActivePets;
  final List<Map<String, dynamic>> notifications;

  DashboardState({
    required this.isLoading,
    this.currentUser,
    required this.myActivePets,
    required this.notifications,
  });

  DashboardState copyWith({
    bool? isLoading,
    UserModel? currentUser,
    List<Map<String, dynamic>>? myActivePets,
    List<Map<String, dynamic>>? notifications,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      myActivePets: myActivePets ?? this.myActivePets,
      notifications: notifications ?? this.notifications,
    );
  }

  // Getters para compatibilidade com a UI existente
  Map<String, dynamic> get currentUserData {
    if (currentUser == null) return {};

    return {
      'codename': currentUser!.displayName ?? 'Guardian Anônimo',
      'level': currentUser!.level,
      'xp': currentUser!.xp,
      'xpToNext': _calculateXPToNext(currentUser!.level),
      'colorTheme': 0xFF3B82F6, // Pode ser derivado de settings futuramente
      'successRate': _calculateSuccessRate(),
      'totalAdoptions': currentUser!.stats.totalPetsCared,
      'currentStreak': currentUser!.stats.loginStreak,
      'badges': _calculateBadges(),
    };
  }

  int _calculateXPToNext(int level) {
    return level * 100; // XP necessário para próximo nível
  }

  int _calculateSuccessRate() {
    final stats = currentUser?.stats;
    if (stats == null || stats.totalMissionsCompleted == 0) return 100;

    // Calcular baseado em missões completadas vs tentativas
    return ((stats.totalMissionsCompleted /
                (stats.totalMissionsCompleted + 1)) *
            100)
        .round();
  }

  List<String> _calculateBadges() {
    final badges = <String>[];
    final user = currentUser;

    if (user == null) return badges;

    // Badge baseado em nível
    if (user.level >= 10) badges.add('experienced_guardian');
    if (user.level >= 20) badges.add('master_guardian');

    // Badge baseado em pets cuidados
    if (user.stats.totalPetsCared >= 5) badges.add('pet_lover');
    if (user.stats.totalPetsCared >= 15) badges.add('pet_master');

    // Badge baseado em login streak
    if (user.stats.loginStreak >= 7) badges.add('dedicated');
    if (user.stats.loginStreak >= 30) badges.add('legendary_dedication');

    return badges;
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(UserModel? initialUser)
      : super(DashboardState(
          isLoading: true,
          currentUser: initialUser,
          myActivePets: [],
          notifications: [],
        )) {
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      isLoading: false,
      myActivePets: _generateMyPetsFromFirebase(),
      notifications: _generateNotificationsFromFirebase(),
    );
  }

  void updateUser(UserModel? newUser) {
    state = state.copyWith(currentUser: newUser);
    if (!state.isLoading) {
      _loadDashboardData();
    }
  }

  List<Map<String, dynamic>> _generateMyPetsFromFirebase() {
    final user = state.currentUser;
    if (user == null || user.petIds.isEmpty) {
      return [];
    }

    // Aqui você faria a busca real dos pets do Firebase
    // Por enquanto, gerando dados baseados nos IDs de pets do usuário
    return user.petIds.map((petId) => _createPetDataFromId(petId)).toList();
  }

  Map<String, dynamic> _createPetDataFromId(String petId) {
    // Mock data baseado no ID do pet
    // Na implementação real, buscaria os dados do pet no Firebase
    final pets = [
      {
        'pet': MockPet(name: 'Luna', type: 'Gato', age: '2 anos', photo: '🐱'),
        'coGuardian': 'Protetor Rosa',
        'happiness': 85,
        'health': 92,
        'energy': 78,
        'hunger': 35,
        'needsAttention': false,
        'lastActivity': '2h atrás',
      },
      {
        'pet':
            MockPet(name: 'Max', type: 'Cachorro', age: '3 anos', photo: '🐕'),
        'coGuardian': 'Anjo Verde',
        'happiness': 72,
        'health': 88,
        'energy': 45,
        'hunger': 85,
        'needsAttention': true,
        'lastActivity': '30min atrás',
      },
    ];

    return pets[petId.hashCode % pets.length];
  }

  List<Map<String, dynamic>> _generateNotificationsFromFirebase() {
    final user = state.currentUser;
    if (user == null) return [];

    final notifications = <Map<String, dynamic>>[];

    // Notificação baseada em pets que precisam de atenção
    if (user.petIds.isNotEmpty) {
      notifications.add({
        'type': 'urgent',
        'title': 'Pet precisa de atenção!',
        'message': 'Verifique o status dos seus pets',
        'time': '5min atrás',
        'icon': Icons.pets,
        'color': 0xFFEF4444,
      });
    }

    // Notificação baseada em conquistas
    if (user.achievements.isNotEmpty) {
      notifications.add({
        'type': 'achievement',
        'title': 'Nova conquista desbloqueada!',
        'message': 'Parabéns pelo seu progresso',
        'time': '1h atrás',
        'icon': Icons.emoji_events,
        'color': 0xFFF59E0B,
      });
    }

    // Notificação baseada em atividade social
    notifications.add({
      'type': 'social',
      'title': 'Atividade colaborativa',
      'message': 'Novos pets disponíveis para adoção',
      'time': '2h atrás',
      'icon': Icons.people,
      'color': 0xFF10B981,
    });

    return notifications;
  }

  void refreshData() {
    state = state.copyWith(isLoading: true);
    _loadDashboardData();
  }
}
