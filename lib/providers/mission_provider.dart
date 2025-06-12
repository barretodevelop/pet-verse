// MissionProvider

// lib/providers/mission_provider.dart - MissionProvider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/models/mission_model.dart';
import 'package:petverse/utils/constants.dart';

final missionProvider =
    StateNotifierProvider<MissionNotifier, List<MissionModel>>(
        (ref) => MissionNotifier());

class MissionNotifier extends StateNotifier<List<MissionModel>> {
  // ✅ CORREÇÃO 1: Inicializar com missões padrão ao invés de lista vazia
  MissionNotifier() : super(Constants.defaultMissions) {
    print('✅ MissionProvider: ${state.length} missões inicializadas'); // Debug
  }

  void setMissions(List<MissionModel> missions) {
    state = missions;
    print('✅ MissionProvider: ${state.length} missões definidas'); // Debug
  }

  // ✅ CORREÇÃO 2: Melhorar lógica de atualização de progresso
  void updateMissionProgress(int missionId, int progress) {
    bool missionFound = false;
    state = state.map((mission) {
      if (mission.id == missionId) {
        missionFound = true;
        final newProgress = (mission.progress + progress).clamp(0, mission.max);
        print(
            '✅ Missão ${mission.title}: ${mission.progress} → $newProgress'); // Debug
        return mission.copyWith(progress: newProgress);
      }
      return mission;
    }).toList();

    if (!missionFound) {
      print('⚠️ Missão ID $missionId não encontrada');
    }
  }

  // ✅ CORREÇÃO 3: Métodos utilitários para filtrar missões
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

  // ✅ CORREÇÃO 4: Método para resetar missões (útil para testes)
  void resetMissions() {
    state = Constants.defaultMissions;
    print('✅ Missões resetadas: ${state.length} missões'); // Debug
  }

  // ✅ CORREÇÃO 5: Completar missão automaticamente quando atingir max
  void completeMission(int missionId) {
    state = state.map((mission) {
      if (mission.id == missionId) {
        print('✅ Missão "${mission.title}" completa!'); // Debug
        return mission.copyWith(progress: mission.max);
      }
      return mission;
    }).toList();
  }

  // ✅ CORREÇÃO 6: Verificar se missão específica está completa
  bool isMissionComplete(int missionId) {
    final mission = state.firstWhere(
      (m) => m.id == missionId,
      orElse: () => MissionModel(
          id: 0, title: '', desc: '', reward: 0, progress: 0, max: 1),
    );
    return mission.progress >= mission.max;
  }

  // ✅ CORREÇÃO 7: Obter progresso percentual
  double getMissionProgress(int missionId) {
    final mission = state.firstWhere(
      (m) => m.id == missionId,
      orElse: () => MissionModel(
          id: 0, title: '', desc: '', reward: 0, progress: 0, max: 1),
    );
    return mission.max > 0 ? (mission.progress / mission.max) : 0.0;
  }
}
