// MissionProvider

// lib/providers/mission_provider.dart - MissionProvider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/models/mission_model.dart';
import 'package:petverse/utils/constants.dart';

final missionProvider =
    StateNotifierProvider<MissionNotifier, List<MissionModel>>(
        (ref) => MissionNotifier());

class MissionNotifier extends StateNotifier<List<MissionModel>> {
  // ✅ CORREÇÃO CRÍTICA: Inicializar com missões padrão IMEDIATAMENTE
  MissionNotifier() : super(Constants.defaultMissions) {
    _initializeMissions();
    print(
        '✅ MissionProvider inicializado com ${state.length} missões'); // Debug
  }

  // ✅ CORREÇÃO: Método de inicialização garantindo que missões estejam sempre presentes
  void _initializeMissions() {
    if (state.isEmpty) {
      state = Constants.defaultMissions;
      print('✅ Missões carregadas: ${state.length}'); // Debug
    }

    // ✅ Debug: Mostrar todas as missões carregadas
    for (int i = 0; i < state.length; i++) {
      final mission = state[i];
      print(
          '✅ Missão ${i + 1}: ${mission.title} (${mission.progress}/${mission.max})');
    }
  }

  void setMissions(List<MissionModel> missions) {
    state = missions;
    print(
        '✅ MissionProvider: ${state.length} missões definidas manualmente'); // Debug
  }

  // ✅ CORREÇÃO: Método robusto de atualização de progresso
  void updateMissionProgress(int missionId, int progress) {
    bool missionFound = false;

    state = state.map((mission) {
      if (mission.id == missionId) {
        missionFound = true;
        final newProgress = (mission.progress + progress).clamp(0, mission.max);

        print(
            '✅ Missão ${mission.title}: ${mission.progress} → $newProgress/${mission.max}'); // Debug

        // ✅ Verificar se missão foi completada
        if (newProgress >= mission.max && mission.progress < mission.max) {
          print(
              '🎉 MISSÃO COMPLETADA: ${mission.title} - Recompensa: ${mission.reward} moedas');

          // TODO: Adicionar recompensa automaticamente ao usuário
          // final userNotifier = ref.read(userProvider.notifier);
          // final user = ref.read(userProvider);
          // if (user != null) {
          //   userNotifier.updateCoins(user.coins + mission.reward);
          // }
        }

        return mission.copyWith(progress: newProgress);
      }
      return mission;
    }).toList();

    if (!missionFound) {
      print('⚠️ ERRO: Missão ID $missionId não encontrada!');
      print(
          '📋 Missões disponíveis: ${state.map((m) => '${m.id}: ${m.title}').join(', ')}');
    }
  }

  // ✅ CORREÇÃO: Métodos utilitários melhorados
  List<MissionModel> getCompletedMissions() {
    final completed =
        state.where((mission) => mission.progress >= mission.max).toList();
    print('✅ Missões completas: ${completed.length}/${state.length}'); // Debug
    return completed;
  }

  List<MissionModel> getActiveMissions() {
    final active =
        state.where((mission) => mission.progress < mission.max).toList();
    print('✅ Missões ativas: ${active.length}/${state.length}'); // Debug
    return active;
  }

  // ✅ CORREÇÃO: Método para resetar missões (útil para debug/testes)
  void resetMissions() {
    state = Constants.defaultMissions
        .map((mission) => mission.copyWith(progress: 0))
        .toList();
    print(
        '✅ Missões resetadas: ${state.length} missões com progresso 0'); // Debug
  }

  // ✅ CORREÇÃO: Completar missão forçadamente (para testes)
  void completeMission(int missionId) {
    state = state.map((mission) {
      if (mission.id == missionId) {
        print('✅ Forçando conclusão da missão: "${mission.title}"'); // Debug
        return mission.copyWith(progress: mission.max);
      }
      return mission;
    }).toList();
  }

  // ✅ CORREÇÃO: Verificações de estado
  bool isMissionComplete(int missionId) {
    final mission = state.firstWhere(
      (m) => m.id == missionId,
      orElse: () => MissionModel(
          id: 0, title: '', desc: '', reward: 0, progress: 0, max: 1),
    );
    final isComplete = mission.progress >= mission.max;
    print(
        '🔍 Missão $missionId completa: $isComplete (${mission.progress}/${mission.max})'); // Debug
    return isComplete;
  }

  double getMissionProgress(int missionId) {
    final mission = state.firstWhere(
      (m) => m.id == missionId,
      orElse: () => MissionModel(
          id: 0, title: '', desc: '', reward: 0, progress: 0, max: 1),
    );
    final progress = mission.max > 0 ? (mission.progress / mission.max) : 0.0;
    print(
        '📊 Progresso missão $missionId: ${(progress * 100).toStringAsFixed(1)}%'); // Debug
    return progress;
  }

  // ✅ NOVO: Método para debug completo
  void debugMissionState() {
    print('🔍 === DEBUG MISSION STATE ===');
    print('📊 Total de missões: ${state.length}');
    print('✅ Missões completas: ${getCompletedMissions().length}');
    print('🔄 Missões ativas: ${getActiveMissions().length}');

    for (final mission in state) {
      final percentage = mission.max > 0
          ? (mission.progress / mission.max * 100).toStringAsFixed(1)
          : '0.0';
      final status =
          mission.progress >= mission.max ? '✅ COMPLETA' : '🔄 ATIVA';
      print(
          '   ${mission.id}. ${mission.title}: ${mission.progress}/${mission.max} ($percentage%) - $status');
    }
    print('🔍 === FIM DEBUG ===');
  }

  // ✅ NOVO: Forçar reload das missões (para casos extremos)
  void forceReloadMissions() {
    final backup = List<MissionModel>.from(state);
    state = [];
    state = Constants.defaultMissions;
    print('🔄 Missões recarregadas forçadamente: ${state.length} missões');

    // Verificar se realmente carregou
    if (state.isEmpty) {
      print('❌ ERRO CRÍTICO: Missões ainda vazias após reload!');
      state = backup; // Restaurar backup
    }
  }
}
