// lib/features/pet_care/notifiers/active_pet_notifier.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petverse/core/services/persistence_service.dart';
import 'package:petverse/data/game_data.dart';
import 'package:petverse/shared/enums/enums.dart';
import 'package:petverse/shared/models/active_pet.dart';
import 'package:petverse/shared/models/pet_definition.dart';
import 'package:petverse/shared/models/pet_state.dart';
import 'package:petverse/shared/models/shop_item.dart';
import 'package:petverse/shared/providers/global_providers.dart';

class ActivePetNotifier extends StateNotifier<ActivePet?> {
  final PersistenceService _persistenceService;
  final Ref _ref;
  Timer? _moodDecayTimer;
  String?
      _currentFirebaseUserId; // Para saber para qual usuário salvar/carregar

  ActivePetNotifier(this._persistenceService, this._ref) : super(null) {
    // O UID será definido quando loadInitialPet for chamado
    // Se já houver um estado (ex: hot reload com pet ativo), reinicia o ciclo de humor
    if (state != null && _currentFirebaseUserId != null) {
      _startMoodDecayCycle();
    }
  }

  @override
  void dispose() {
    _moodDecayTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveCurrentPetStats() async {
    if (state != null && _currentFirebaseUserId != null) {
      await _persistenceService.savePetStats(
          _currentFirebaseUserId!, state!.definition.id, state!.stats);
    }
  }

  Future<void> loadInitialPet(String firebaseUserId) async {
    _currentFirebaseUserId = firebaseUserId;
    final id = await _persistenceService.loadSelectedPetId(firebaseUserId);
    if (id != null) {
      final def = GameData.getPetDefinitionById(id);
      if (def != null) {
        PetStats stats =
            await _persistenceService.loadPetStats(firebaseUserId, id) ??
                PetStats();
        stats = _calculateDecay(stats);
        state = ActivePet(definition: def, stats: stats);
        _startMoodDecayCycle();
      }
    } else {
      state = null; // Garante que não haja pet ativo se nenhum for carregado
    }
  }

  Future<void> selectPet(PetDefinition def) async {
    if (_currentFirebaseUserId == null) {
      debugPrint("Erro: Tentativa de selecionar pet sem UID de usuário.");
      return;
    }
    PetStats stats = await _persistenceService.loadPetStats(
            _currentFirebaseUserId!, def.id) ??
        PetStats();
    stats = _calculateDecay(stats);
    state = ActivePet(definition: def, stats: stats);
    await _persistenceService.saveSelectedPetId(
        _currentFirebaseUserId!, def.id);
    await _persistenceService.savePetStats(
        _currentFirebaseUserId!, def.id, stats);
    _ref.read(userProvider.notifier).logCollectedPet(def.id);
    _startMoodDecayCycle();
  }

  void _startMoodDecayCycle() {
    _moodDecayTimer?.cancel();
    _moodDecayTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (state != null && _currentFirebaseUserId != null) {
        PetStats newStats =
            _calculateDecay(state!.stats, applyDecayAmount: true);
        if (newStats.isVeryHungry && newStats.happiness > 10) {
          newStats = newStats.copyWith(
              happiness: (newStats.happiness - 5).clamp(0, 100));
        }
        state = state!.copyWith(stats: newStats);
        _saveCurrentPetStats();
      } else {
        timer.cancel();
      }
    });
  }

  PetStats _calculateDecay(PetStats stats, {bool applyDecayAmount = false}) {
    final now = DateTime.now();
    final diff = now.difference(stats.lastUpdate);
    int hapDec = 0;
    int hunInc = 0;
    if (applyDecayAmount) {
      hapDec = 1; // Decai 1 de felicidade por tick
      hunInc = 2; // Aumenta 2 de fome por tick
    } else {
      // Calcula decaimento proporcional ao tempo offline
      final minutesPassed = diff.inMinutes;
      hapDec = (minutesPassed ~/ 15)
          .clamp(0, 30); // Ex: 1 de felicidade a cada 15 min offline, max 30
      hunInc = (minutesPassed ~/ 10)
          .clamp(0, 50); // Ex: 1 de fome a cada 10 min offline, max 50
    }
    return stats.copyWith(
      happiness: (stats.happiness - hapDec).clamp(0, 100),
      hunger: (stats.hunger + hunInc).clamp(0, 100),
      lastUpdate: now,
    );
  }

  void addXp(int amount) {
    if (state == null) return;
    int newXp = state!.stats.xp + amount;
    int next = state!.stats.xpForNextLevel;
    if (next > 0 && newXp >= next) {
      _levelUp(newXp - next);
    } else if (next > 0) {
      state = state!.copyWith(stats: state!.stats.copyWith(xp: newXp));
    } else {
      // Nível máximo, não adiciona mais XP ou mantém no máximo do nível anterior
      state =
          state!.copyWith(stats: state!.stats.copyWith(xp: state!.stats.xp));
    }
    _saveCurrentPetStats();
  }

  void _levelUp(int leftoverXp) {
    if (state == null) return;
    int newLvl = state!.stats.level + 1;
    state = state!
        .copyWith(stats: state!.stats.copyWith(level: newLvl, xp: leftoverXp));
    // Recompensas ao usuário
    _ref.read(userProvider.notifier).addCoins(50 * newLvl, fromQuest: true);
    _ref.read(userProvider.notifier).addGems(5);
    _ref.read(userProvider.notifier).addUxp(25 * newLvl);
    // Atualiza conquistas de nível (supondo que UserNotifier tenha este método)
    // _ref.read(userProvider.notifier).updateAchievementProgress(AchievementGoalType.petLevelReached, newLvl, useNewValue: true);
    // _ref.read(userProvider.notifier).updateAchievementProgress(AchievementGoalType.specificPetLevel, newLvl, detail: state!.definition.id, useNewValue: true);
  }

  bool feedPetWithItem(ShopItem foodItem) {
    if (state == null ||
        foodItem.category != ItemCategory.food ||
        state!.stats.isSatiated) return false;
    bool consumed = _ref.read(userProvider.notifier).consumeItem(foodItem.id);
    if (!consumed) return false;

    _ref.read(userProvider.notifier).updateQuestProgress(QuestType.feed, 1);
    // _ref.read(userProvider.notifier).updateAchievementProgress(AchievementGoalType.feedCount, 1); // Movido para UserNotifier se necessário
    addXp(10);

    state = state!.copyWith(
        stats: state!.stats.copyWith(
            hunger: (state!.stats.hunger - 45).clamp(0, 100),
            happiness: (state!.stats.happiness + 20).clamp(0, 100),
            lastUpdate: DateTime.now()));
    _ref
        .read(userProvider.notifier)
        .addCoins(1, save: true, fromQuest: true); // save:true aqui
    _saveCurrentPetStats();
    return true;
  }

  bool playWithPet() {
    if (state == null || state!.stats.isInBadMood) return false;
    _ref.read(userProvider.notifier).updateQuestProgress(QuestType.play, 1);
    addXp(15);
    state = state!.copyWith(
        stats: state!.stats.copyWith(
            happiness: (state!.stats.happiness + 25).clamp(0, 100),
            hunger: (state!.stats.hunger + 8).clamp(0, 100),
            lastUpdate: DateTime.now()));
    _ref.read(userProvider.notifier).addCoins(2, save: true, fromQuest: true);
    _saveCurrentPetStats();
    return true;
  }

  bool useToy(ShopItem toyItem) {
    if (state == null ||
        toyItem.category != ItemCategory.toy ||
        state!.stats.isInBadMood) return false;
    // Brinquedos não são consumidos, apenas registram uso para missões/conquistas
    _ref.read(userProvider.notifier).updateQuestProgress(QuestType.useToy, 1);
    addXp(20);
    state = state!.copyWith(
        stats: state!.stats.copyWith(
            happiness: (state!.stats.happiness + 30).clamp(0, 100),
            hunger: (state!.stats.hunger + 10).clamp(0, 100),
            lastUpdate: DateTime.now()));
    _ref.read(userProvider.notifier).addCoins(3, save: true, fromQuest: true);
    _saveCurrentPetStats();
    return true;
  }

  bool useMedicine(ShopItem medicineItem) {
    if (state == null || medicineItem.category != ItemCategory.medicine)
      return false;
    bool consumed =
        _ref.read(userProvider.notifier).consumeItem(medicineItem.id);
    if (!consumed) return false;
    _ref
        .read(userProvider.notifier)
        .updateQuestProgress(QuestType.useMedicine, 1);
    addXp(15);
    state = state!.copyWith(
        stats: state!.stats.copyWith(
            happiness: (state!.stats.happiness + 35)
                .clamp(0, 100), // Remédio melhora felicidade
            // Poderia reduzir um status negativo "isSick" aqui no futuro
            lastUpdate: DateTime.now()));
    _saveCurrentPetStats();
    return true;
  }

  bool giveBath(ShopItem bathItem) {
    if (state == null || bathItem.category != ItemCategory.bath) return false;
    bool consumed = _ref.read(userProvider.notifier).consumeItem(bathItem.id);
    if (!consumed) return false;
    _ref.read(userProvider.notifier).updateQuestProgress(QuestType.giveBath, 1);
    addXp(20);
    state = state!.copyWith(
        stats: state!.stats.copyWith(
            happiness: (state!.stats.happiness + 30)
                .clamp(0, 100), // Banho deixa feliz
            lastUpdate: DateTime.now()));
    _saveCurrentPetStats();
    return true;
  }

  bool groomPet(ShopItem groomingItem) {
    if (state == null || groomingItem.category != ItemCategory.grooming)
      return false;
    bool consumed =
        _ref.read(userProvider.notifier).consumeItem(groomingItem.id);
    if (!consumed) return false;
    _ref.read(userProvider.notifier).updateQuestProgress(QuestType.groomPet, 1);
    addXp(18);
    state = state!.copyWith(
        stats: state!.stats.copyWith(
            happiness: (state!.stats.happiness + 22)
                .clamp(0, 100), // Tosa deixa bonito e feliz
            lastUpdate: DateTime.now()));
    _saveCurrentPetStats();
    return true;
  }

  Future<void> clearActivePet() async {
    _moodDecayTimer?.cancel();
    state = null;
    if (_currentFirebaseUserId != null) {
      await _persistenceService.saveSelectedPetId(
          _currentFirebaseUserId!, null);
    }
  }

  void clearLocalActivePetData() {
    // Chamado no logout
    _moodDecayTimer?.cancel();
    state = null;
    // _currentFirebaseUserId será limpo pelo UserNotifier ou na reinicialização do app
  }
}
