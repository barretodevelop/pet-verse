// lib/features/missions/providers/missions_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petverse/feature/auth/providers/auth_provider.dart';
import 'package:petverse/feature/economy/providers/economy_provider.dart';
import 'package:petverse/feature/missions/models/mission.dart';
 

// Provider para missões do usuário
final missionsProvider = StreamProvider<List<Mission>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  
  // Por enquanto, retornar missões padrão
  // TODO: Implementar sistema completo com Firestore
  return Stream.value(DailyMissions.getMissionsForToday());
});

// Controller de missões
class MissionsController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  
  MissionsController(this._ref) : super(const AsyncData(null));

  Future<void> updateProgress(String missionId, int progress) async {
    // TODO: Implementar atualização de progresso no Firestore
  }

  Future<void> claimReward(Mission mission) async {
    if (!mission.canClaim) return;
    
    state = const AsyncLoading();
    try {
      // Adicionar moedas
      await _ref.read(economyControllerProvider.notifier).addCoins(mission.reward);
      
      // TODO: Marcar missão como claimed no Firestore
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final missionsControllerProvider = StateNotifierProvider<MissionsController, AsyncValue<void>>((ref) {
  return MissionsController(ref);
});

