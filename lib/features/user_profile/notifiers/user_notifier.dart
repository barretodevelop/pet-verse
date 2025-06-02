import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:petverse/core/services/persistence_service.dart';
import 'package:petverse/data/achievement_data.dart';
import 'package:petverse/data/game_data.dart';
import 'package:petverse/shared/enums/enums.dart';
import 'package:petverse/shared/models/achievement_progress.dart';
import 'package:petverse/shared/models/app_event.dart' hide GameData;
import 'package:petverse/shared/models/quest_progress.dart';
import 'package:petverse/shared/models/shop_item.dart';
import 'package:petverse/shared/models/user_state.dart';

// lib/features/user_profile/notifiers/user_notifier.dart (ALTERADO)
class UserNotifier extends StateNotifier<UserProfile> {
  final PersistenceService _persistenceService;
  final AppEvent? _activeEvent;
  String? _currentFirebaseUserId; // Para saber para qual usuário salvar

  UserNotifier(this._persistenceService, this._activeEvent)
      : super(const UserProfile(coins: 100, gems: 10, uxp: 0));

  Future<void> _saveData() async {
    if (_currentFirebaseUserId != null) {
      await _persistenceService.saveUserProfile(_currentFirebaseUserId!, state);
    } else {
      debugPrint("Tentativa de salvar UserProfile sem Firebase UID.");
    }
  }

  Future<void> loadDataAndCheckQuests(String firebaseUserId) async {
    _currentFirebaseUserId = firebaseUserId;
    state = await _persistenceService.loadUserProfile(firebaseUserId) ??
        UserProfile(firebaseUserId: firebaseUserId, uxp: 0);
    _checkForDailyQuestReset();
    _initializeMissingAchievements();
  }

  void clearLocalUserData() {
    // Chamado no logout
    state = UserProfile(
        firebaseUserId:
            _currentFirebaseUserId); // Reseta para estado inicial, mantendo o UID se necessário para novo login
    _currentFirebaseUserId = null;
    // Não chama _saveData() aqui, pois os dados devem ser removidos do disco
  }

  void _initializeMissingAchievements() {
    final currentAchievements =
        Map<String, AchievementProgress>.from(state.achievementProgress);
    bool changed = false;
    for (var achDef in AchievementData.allAchievements) {
      if (!currentAchievements.containsKey(achDef.id)) {
        currentAchievements[achDef.id] =
            AchievementProgress(achievementId: achDef.id);
        changed = true;
      }
    }
    if (changed) {
      state = state.copyWith(achievementProgress: currentAchievements);
      // O _saveData será chamado por outras operações ou ao final de loadDataAndCheckQuests se necessário.
    }
  }

  void _checkForDailyQuestReset() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (state.lastQuestResetDate != today) _generateNewDailyQuests(today);
  }

  void _generateNewDailyQuests(String today) {
    final allQuests = GameData.getAvailableQuests(_activeEvent);
    allQuests.shuffle();
    final newQuests = <String, QuestProgress>{};
    for (var q in allQuests.take(3)) {
      newQuests[q.id] = QuestProgress(questId: q.id);
    }
    state = state.copyWith(dailyQuests: newQuests, lastQuestResetDate: today);
    _saveData();
  }

  void updateQuestProgress(QuestType type, int amount) {
    // Lógica original de atualização de missões
    final newQuests = Map<String, QuestProgress>.from(state.dailyQuests);
    bool changed = false;
    for (var p in newQuests.values) {
      final qDef = GameData.getQuestById(p.questId);
      if (qDef != null && qDef.type == type && !p.isClaimed) {
        newQuests[p.questId] = p.copyWith(
            currentCount: (p.currentCount + amount).clamp(0, qDef.targetCount));
        changed = true;
      }
    }
    if (changed) {
      state = state.copyWith(dailyQuests: newQuests);
      _saveData();
    }
  }

  bool claimQuestReward(String questId) {
    final p = state.dailyQuests[questId];
    final qDef = GameData.getQuestById(questId);
    if (p == null ||
        qDef == null ||
        p.isClaimed ||
        p.currentCount < qDef.targetCount) return false;
    final newQuests = Map<String, QuestProgress>.from(state.dailyQuests);
    newQuests[questId] = p.copyWith(isClaimed: true);

    // Adiciona recompensas da missão
    addCoins(qDef.rewardCoins, fromQuest: true, save: false);
    addGems(qDef.rewardGems,
        save: false); // Não chama _saveData aqui, será chamado abaixo

    state = state.copyWith(dailyQuests: newQuests);
    updateAchievementProgress(
        AchievementGoalType.questsCompletedCount, 1); // Atualiza conquista
    _saveData(); // Salva tudo
    return true;
  }

  void addCoins(int amount,
      {bool save = true,
      bool fromQuest = false,
      bool fromAchievement = false}) {
    if (!fromQuest && !fromAchievement) {
      updateAchievementProgress(AchievementGoalType.totalCoinsEarned, amount);
    }
    state = state.copyWith(coins: state.coins + amount);
    if (save) _saveData();
  }

  void addGems(int amount, {bool save = true, bool fromAchievement = false}) {
    if (!fromAchievement) {
      updateAchievementProgress(AchievementGoalType.totalGemsEarned, amount);
    }
    state = state.copyWith(gems: state.gems + amount);
    if (save) _saveData();
  }

  bool buyItem(ShopItem item) {
    if (!item.isStackable && state.hasItem(item.id)) return false;
    if (!state.canAfford(item)) return false;
    final newQuantities = Map<String, int>.from(state.itemQuantities);
    newQuantities[item.id] = (newQuantities[item.id] ?? 0) + 1;

    final newCollectedItems = Set<String>.from(state.collectedItemIds)
      ..add(item.id);

    if (item.gemPrice > 0) {
      state = state.copyWith(
          gems: state.gems - item.gemPrice,
          itemQuantities: newQuantities,
          collectedItemIds: newCollectedItems);
    } else {
      state = state.copyWith(
          coins: state.coins - item.coinPrice,
          itemQuantities: newQuantities,
          collectedItemIds: newCollectedItems);
    }

    updateQuestProgress(QuestType.buyItem, 1);
    updateAchievementProgress(
        AchievementGoalType.itemsCollectedCount, newCollectedItems.length,
        useNewValue: true);
    updateAchievementProgress(AchievementGoalType.specificItemOwned, 1,
        detail: item.id); // Verifica se este item completa uma conquista
    _saveData();
    return true;
  }

  void equipItem(String id) {
    final itemDef = GameData.getShopItems(null).firstWhere(
        (item) => item.id == id,
        orElse: () => const ShopItem(id: 'error', name: 'Erro'));
    if (itemDef.category == ItemCategory.accessory && state.hasItem(id)) {
      state = state.copyWith(equippedItemId: id);
      _saveData();
    }
  }

  void unequipItem() {
    state = state.copyWith(clearEquippedItem: true);
    _saveData();
  }

  bool consumeItem(String itemId) {
    final currentQuantity = state.itemQuantities[itemId] ?? 0;
    if (currentQuantity <= 0) return false;
    final newQuantities = Map<String, int>.from(state.itemQuantities);
    if (currentQuantity == 1) {
      newQuantities.remove(itemId);
    } else {
      newQuantities[itemId] = currentQuantity - 1;
    }
    state = state.copyWith(itemQuantities: newQuantities);
    _saveData();
    return true;
  }

  void addUxp(int amount, {bool fromAchievement = false}) {
    state = state.copyWith(uxp: state.uxp + amount);
    // Não atualiza conquista de UXP aqui para evitar loops se a recompensa de conquista for UXP
    _saveData();
  }

  void setActiveEnvironmentItem(ShopItem item) {
    if (!state.hasItem(item.id)) return;
    if (item.category == ItemCategory.environment) {
      if (item.assetPath != null) {
        // Assumindo que wallpapers usam assetPath
        state = state.copyWith(activeWallpaperId: item.id);
      } else if (item.itemColor != null) {
        // Assumindo que pisos usam itemColor
        state = state.copyWith(activeFloorId: item.id);
      }
      _saveData();
    }
  }

  void clearActiveWallpaper() {
    state = state.copyWith(clearWallpaper: true);
    _saveData();
  }

  void clearActiveFloor() {
    state = state.copyWith(clearFloor: true);
    _saveData();
  }

  void logCollectedPet(String petId) {
    if (!state.collectedPetIds.contains(petId)) {
      final newCollectedPets = Set<String>.from(state.collectedPetIds)
        ..add(petId);
      state = state.copyWith(collectedPetIds: newCollectedPets);
      _saveData();
      // Poderia ter uma conquista para "Colete X tipos de pets"
    }
  }

  void updateAchievementProgress(AchievementGoalType type, int valueToAddOrSet,
      {String? detail, bool useNewValue = false}) {
    final newProgressMap =
        Map<String, AchievementProgress>.from(state.achievementProgress);
    bool changed = false;

    for (var achDef in AchievementData.allAchievements) {
      if (achDef.goalType == type &&
          (achDef.detail == null || achDef.detail == detail)) {
        final currentProg = newProgressMap[achDef.id] ??
            AchievementProgress(achievementId: achDef.id);
        if (currentProg.isCompleted && !currentProg.isClaimed)
          continue; // Se completou mas não resgatou, não atualiza mais
        if (currentProg.isClaimed)
          continue; // Se já resgatou, não atualiza mais

        int newCurrentValue = useNewValue
            ? valueToAddOrSet
            : currentProg.currentProgress + valueToAddOrSet;
        newCurrentValue = newCurrentValue.clamp(0, achDef.targetValue);

        if (newCurrentValue != currentProg.currentProgress) {
          newProgressMap[achDef.id] =
              currentProg.copyWith(currentProgress: newCurrentValue);
          changed = true;
        }
        if (newCurrentValue >= achDef.targetValue && !currentProg.isCompleted) {
          newProgressMap[achDef.id] =
              newProgressMap[achDef.id]!.copyWith(isCompleted: true);
          changed = true;
          // Notificação de conquista desbloqueada poderia ser disparada aqui (ex: usando um provider de mensagens)
        }
      }
    }
    if (changed) {
      state = state.copyWith(achievementProgress: newProgressMap);
      _saveData();
    }
  }

  bool claimAchievementReward(String achievementId) {
    final progress = state.achievementProgress[achievementId];
    final achDef = AchievementData.getAchievementById(achievementId);

    if (progress == null ||
        achDef == null ||
        !progress.isCompleted ||
        progress.isClaimed) {
      return false;
    }

    final newProgressMap =
        Map<String, AchievementProgress>.from(state.achievementProgress);
    newProgressMap[achievementId] = progress.copyWith(isClaimed: true);

    // Adiciona recompensas, marcando como 'fromAchievement' para evitar loops
    addCoins(achDef.rewardCoins, fromAchievement: true, save: false);
    addGems(achDef.rewardGems, fromAchievement: true, save: false);
    addUxp(achDef.rewardUxp, fromAchievement: true); // Salva no final da addUxp

    state = state.copyWith(
        achievementProgress: newProgressMap); // Salva o estado das conquistas
    _saveData(); // Salva tudo (moedas, gemas, uxp e estado da conquista)
    return true;
  }
}
