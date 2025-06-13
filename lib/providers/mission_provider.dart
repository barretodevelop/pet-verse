// lib/providers/mission_provider.dart - SECURE REFACTOR
// ✅ SEGURANÇA: Recompensas de missões agora validadas server-side
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/models/mission_model.dart';
import 'package:petverse/providers/user_provider.dart';
import 'package:petverse/services/secure_firestore_service.dart'; // ✅ NOVO
import 'package:petverse/utils/constants.dart';

final missionProvider =
    StateNotifierProvider<MissionNotifier, List<MissionModel>>(
        (ref) => MissionNotifier(ref));

class MissionNotifier extends StateNotifier<List<MissionModel>> {
  final Ref _ref;
  // ✅ NOVO: Estado para tracking de recompensas em processamento
  final Set<int> _claimingMissions = {};

  MissionNotifier(this._ref) : super(Constants.defaultMissions) {
    _initializeMissions();
    print('✅ MissionProvider inicializado com ${state.length} missões');
  }

  void _initializeMissions() {
    if (state.isEmpty) {
      state = Constants.defaultMissions;
      print('✅ Missões carregadas: ${state.length}');
    }

    for (int i = 0; i < state.length; i++) {
      final mission = state[i];
      print(
          '✅ Missão ${i + 1}: ${mission.title} (${mission.progress}/${mission.max})');
    }
  }

  void setMissions(List<MissionModel> missions) {
    state = missions;
    print('✅ MissionProvider: ${state.length} missões definidas manualmente');
  }

  // ✅ SEGURO: Atualização de progresso com validação
  void updateMissionProgress(int missionId, int progress, {String? reason}) {
    bool missionFound = false;

    state = state.map((mission) {
      if (mission.id == missionId) {
        missionFound = true;
        final newProgress = (mission.progress + progress).clamp(0, mission.max);

        print(
            '✅ Missão ${mission.title}: ${mission.progress} → $newProgress/${mission.max}');

        // ✅ NOVO: Auto-claim recompensa quando missão completada
        if (newProgress >= mission.max && mission.progress < mission.max) {
          print(
              '🎉 MISSÃO COMPLETADA: ${mission.title} - Recompensa: ${mission.reward} moedas');
          _autoClaimMissionReward(mission,
              reason: reason ?? 'Mission auto-completed');
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

  // ✅ NOVO: Claim manual de recompensa de missão (para UX)
  Future<bool> claimMissionReward(int missionId) async {
    final mission = state.firstWhere(
      (m) => m.id == missionId,
      orElse: () => throw Exception('Missão $missionId não encontrada'),
    );

    if (mission.progress < mission.max) {
      throw Exception('Missão ${mission.title} ainda não foi completada');
    }

    if (_claimingMissions.contains(missionId)) {
      print('⚠️ Recompensa da missão $missionId já sendo processada');
      return false;
    }

    _claimingMissions.add(missionId);

    try {
      final success =
          await _claimRewardSecure(mission, reason: 'Manual mission claim');

      if (success) {
        print('✅ Recompensa da missão ${mission.title} coletada manualmente');
      }

      return success;
    } catch (e) {
      print('❌ Falha ao coletar recompensa da missão ${mission.title}: $e');
      rethrow;
    } finally {
      _claimingMissions.remove(missionId);
    }
  }

  // ✅ INTERNO: Auto-claim de recompensa quando missão é completada
  void _autoClaimMissionReward(MissionModel mission, {String? reason}) {
    if (_claimingMissions.contains(mission.id)) {
      return; // Já está sendo processada
    }

    // Processamento assíncrono para não bloquear UI
    Future.microtask(() async {
      try {
        await _claimRewardSecure(mission,
            reason: reason ?? 'Mission auto-claim');
      } catch (e) {
        print('❌ Auto-claim falhou para missão ${mission.title}: $e');
        // Não re-throw para não quebrar o fluxo da UI
      }
    });
  }

  // ✅ MÉTODO SEGURO: Claim com validação server-side
  Future<bool> _claimRewardSecure(MissionModel mission,
      {String? reason}) async {
    if (_claimingMissions.contains(mission.id)) {
      return false;
    }

    _claimingMissions.add(mission.id);

    try {
      // ✅ Obter UserProvider via ref
      final userProvider = _ref.read(userProviderGetter);
      final user = userProvider;

      if (user == null) {
        throw Exception('Usuário não logado para coletar recompensa');
      }

      // ✅ USA OPERAÇÃO SEGURA com validação server-side
      final success = await SecureFirestoreService.completeMission(
        userId: user.id,
        missionId: mission.id,
        rewardCoins: mission.reward,
      );

      if (success) {
        print(
            '✅ Recompensa coletada com segurança: ${mission.reward} moedas para missão ${mission.title}');
      }

      return success;
    } catch (e) {
      print('❌ Falha no claim seguro da missão ${mission.title}: $e');

      // ✅ FALLBACK: Se operação segura falhar, tenta método legacy (temporário)
      if (e is! SecurityException && e is! InsufficientFundsException) {
        print('⚠️ Tentando método legacy devido a: $e');
        return await _claimRewardLegacy(mission, reason: reason);
      }

      rethrow;
    } finally {
      _claimingMissions.remove(mission.id);
    }
  }

  // ✅ FALLBACK: Método legacy para casos de erro na operação segura
  Future<bool> _claimRewardLegacy(MissionModel mission,
      {String? reason}) async {
    try {
      final userNotifier = _ref.read(userProviderGetter.notifier);
      final user = _ref.read(userProviderGetter);

      if (user != null) {
        await userNotifier.updateCoins(
          user.coins + mission.reward,
          reason: reason ?? 'Mission reward legacy: ${mission.title}',
        );
        print(
            '⚠️ Recompensa coletada via método legacy: ${mission.reward} moedas');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Método legacy também falhou: $e');
      return false;
    }
  }

  // ✅ MELHORADO: Verificações com estado de claim
  bool isMissionClaimable(int missionId) {
    final mission = state.firstWhere(
      (m) => m.id == missionId,
      orElse: () => MissionModel(
          id: 0, title: '', desc: '', reward: 0, progress: 0, max: 1),
    );

    final isComplete = mission.progress >= mission.max;
    final isNotClaiming = !_claimingMissions.contains(missionId);

    print('🔍 Missão $missionId coletável: $isComplete e $isNotClaiming');
    return isComplete && isNotClaiming;
  }

  bool isMissionClaiming(int missionId) {
    return _claimingMissions.contains(missionId);
  }

  // ✅ MANTIDOS: Métodos utilitários existentes
  List<MissionModel> getCompletedMissions() {
    final completed =
        state.where((mission) => mission.progress >= mission.max).toList();
    print('✅ Missões completas: ${completed.length}/${state.length}');
    return completed;
  }

  List<MissionModel> getActiveMissions() {
    final active =
        state.where((mission) => mission.progress < mission.max).toList();
    print('✅ Missões ativas: ${active.length}/${state.length}');
    return active;
  }

  List<MissionModel> getClaimableMissions() {
    final claimable = state
        .where((mission) =>
            mission.progress >= mission.max &&
            !_claimingMissions.contains(mission.id))
        .toList();
    print('✅ Missões coletáveis: ${claimable.length}/${state.length}');
    return claimable;
  }

  void resetMissions() {
    state = Constants.defaultMissions
        .map((mission) => mission.copyWith(progress: 0))
        .toList();
    _claimingMissions.clear();
    print('✅ Missões resetadas: ${state.length} missões com progresso 0');
  }

  void completeMission(int missionId) {
    state = state.map((mission) {
      if (mission.id == missionId) {
        print('✅ Forçando conclusão da missão: "${mission.title}"');
        return mission.copyWith(progress: mission.max);
      }
      return mission;
    }).toList();
  }

  bool isMissionComplete(int missionId) {
    final mission = state.firstWhere(
      (m) => m.id == missionId,
      orElse: () => MissionModel(
          id: 0, title: '', desc: '', reward: 0, progress: 0, max: 1),
    );
    final isComplete = mission.progress >= mission.max;
    print(
        '🔍 Missão $missionId completa: $isComplete (${mission.progress}/${mission.max})');
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
        '📊 Progresso missão $missionId: ${(progress * 100).toStringAsFixed(1)}%');
    return progress;
  }

  void debugMissionState() {
    print('🔍 === DEBUG MISSION STATE ===');
    print('📊 Total de missões: ${state.length}');
    print('✅ Missões completas: ${getCompletedMissions().length}');
    print('🔄 Missões ativas: ${getActiveMissions().length}');
    print('💰 Missões coletáveis: ${getClaimableMissions().length}');
    print('⏳ Missões sendo coletadas: ${_claimingMissions.length}');

    for (final mission in state) {
      final percentage = mission.max > 0
          ? (mission.progress / mission.max * 100).toStringAsFixed(1)
          : '0.0';
      final status =
          mission.progress >= mission.max ? '✅ COMPLETA' : '🔄 ATIVA';
      final claiming =
          _claimingMissions.contains(mission.id) ? ' (⏳ COLETANDO)' : '';
      print(
          '   ${mission.id}. ${mission.title}: ${mission.progress}/${mission.max} ($percentage%) - $status$claiming');
    }
    print('🔍 === FIM DEBUG ===');
  }

  void forceReloadMissions() {
    final backup = List<MissionModel>.from(state);
    state = [];
    state = Constants.defaultMissions;
    _claimingMissions.clear();
    print('🔄 Missões recarregadas forçadamente: ${state.length} missões');

    if (state.isEmpty) {
      print('❌ ERRO CRÍTICO: Missões ainda vazias após reload!');
      state = backup;
    }
  }
}

// ✅ NOVO: Getter para UserProvider (necessário para acessar via ref)
final userProviderGetter = userProvider;
