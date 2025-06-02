// lib/features/user_profile/notifiers/user_notifier.dart
// ALTERADO: Implementação robusta com tratamento de erros e validações
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/persistence_service.dart';
import '../../../data/achievement_data.dart';
import '../../../data/game_data.dart';
import '../../../shared/enums/enums.dart';
import '../../../shared/models/achievement_progress.dart';
import '../../../shared/models/app_event.dart' hide GameData;
import '../../../shared/models/quest_progress.dart';
import '../../../shared/models/shop_item.dart';
import '../../../shared/models/user_state.dart';

class UserNotifier extends StateNotifier<UserProfile> {
  final PersistenceService _persistenceService;
  final AppEvent? _activeEvent;
  String? _currentFirebaseUserId;
  bool _isInitialized = false;

  UserNotifier(this._persistenceService, this._activeEvent)
      : super(const UserProfile(coins: 100, gems: 10, uxp: 0)) {
    debugPrint('🎮 UserNotifier inicializado');
  }

  // NOVO: Getter para verificar se está inicializado
  bool get isInitialized => _isInitialized;
  String? get currentUserId => _currentFirebaseUserId;

  Future<void> _saveData() async {
    if (_currentFirebaseUserId == null) {
      debugPrint('⚠️ Tentativa de salvar UserProfile sem Firebase UID');
      return;
    }

    try {
      // Validar dados antes de salvar
      final errors = state.validateData();
      if (errors.isNotEmpty) {
        debugPrint('⚠️ Dados inválidos detectados: ${errors.join(', ')}');
        // Usar versão limpa dos dados
        final cleanState = state.createCleanCopy();
        await _persistenceService.saveUserProfile(
            _currentFirebaseUserId!, cleanState);
      } else {
        await _persistenceService.saveUserProfile(
            _currentFirebaseUserId!, state);
      }

      debugPrint('✅ Dados do usuário salvos com sucesso');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao salvar dados do usuário: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  Future<void> loadDataAndCheckQuests(String firebaseUserId) async {
    if (_currentFirebaseUserId == firebaseUserId && _isInitialized) {
      debugPrint('ℹ️ Dados já carregados para este usuário');
      return;
    }

    try {
      debugPrint('📊 Carregando dados para usuário: $firebaseUserId');
      _currentFirebaseUserId = firebaseUserId;

      // Carregar dados do usuário ou criar perfil padrão
      UserProfile loadedProfile;
      try {
        final saved = await _persistenceService.loadUserProfile(firebaseUserId);
        loadedProfile = saved ??
            UserProfile(
              firebaseUserId: firebaseUserId,
              coins: 100,
              gems: 10,
              uxp: 0,
            );
      } catch (e) {
        debugPrint('⚠️ Erro ao carregar perfil, usando padrão: $e');
        loadedProfile = UserProfile(
          firebaseUserId: firebaseUserId,
          coins: 100,
          gems: 10,
          uxp: 0,
        );
      }

      state = loadedProfile;

      // Verificar e resetar missões diárias se necessário
      await _checkForDailyQuestReset();

      // Inicializar conquistas faltantes
      _initializeMissingAchievements();

      _isInitialized = true;
      debugPrint('✅ Dados do usuário carregados e inicializados');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro crítico ao carregar dados do usuário: $e');
      debugPrint('Stack trace: $stackTrace');

      // Fallback para perfil mínimo
      state = UserProfile(
        firebaseUserId: firebaseUserId,
        coins: 100,
        gems: 10,
        uxp: 0,
      );
      _currentFirebaseUserId = firebaseUserId;
      _isInitialized = true;
    }
  }

  void clearLocalUserData() {
    debugPrint('🧹 Limpando dados locais do usuário');
    try {
      state = UserProfile(
        firebaseUserId: _currentFirebaseUserId,
        coins: 100,
        gems: 10,
        uxp: 0,
      );
      _currentFirebaseUserId = null;
      _isInitialized = false;
      debugPrint('✅ Dados locais limpos');
    } catch (e) {
      debugPrint('❌ Erro ao limpar dados locais: $e');
    }
  }

  void _initializeMissingAchievements() {
    try {
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
        debugPrint('✅ Conquistas faltantes inicializadas');
      }
    } catch (e) {
      debugPrint('❌ Erro ao inicializar conquistas: $e');
    }
  }

  Future<void> _checkForDailyQuestReset() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      if (state.lastQuestResetDate != today) {
        await _generateNewDailyQuests(today);
      }
    } catch (e) {
      debugPrint('❌ Erro ao verificar reset de missões diárias: $e');
    }
  }

  Future<void> _generateNewDailyQuests(String today) async {
    try {
      final allQuests = GameData.getAvailableQuests(_activeEvent);
      if (allQuests.isEmpty) {
        debugPrint('⚠️ Nenhuma quest disponível para gerar');
        return;
      }

      allQuests.shuffle();
      final newQuests = <String, QuestProgress>{};

      // Gerar 3 missões aleatórias (ou menos se não houver suficientes)
      final questsToGenerate = allQuests.take(3);
      for (var quest in questsToGenerate) {
        newQuests[quest.id] = QuestProgress(questId: quest.id);
      }

      state = state.copyWith(
        dailyQuests: newQuests,
        lastQuestResetDate: today,
      );

      await _saveData();
      debugPrint('✅ Novas missões diárias geradas: ${newQuests.length}');
    } catch (e) {
      debugPrint('❌ Erro ao gerar missões diárias: $e');
    }
  }

  void updateQuestProgress(QuestType type, int amount) {
    if (!_isInitialized) {
      debugPrint('⚠️ Tentativa de atualizar quest sem inicialização');
      return;
    }

    try {
      final newQuests = Map<String, QuestProgress>.from(state.dailyQuests);
      bool changed = false;

      for (var entry in newQuests.entries) {
        final progress = entry.value;
        final qDef = GameData.getQuestById(progress.questId);

        if (qDef != null && qDef.type == type && !progress.isClaimed) {
          final newCount =
              (progress.currentCount + amount).clamp(0, qDef.targetCount);
          if (newCount != progress.currentCount) {
            newQuests[entry.key] = progress.copyWith(currentCount: newCount);
            changed = true;
          }
        }
      }

      if (changed) {
        state = state.copyWith(dailyQuests: newQuests);
        _saveData(); // Não aguardar para não bloquear UI
        debugPrint('✅ Progresso de quest atualizado: $type +$amount');
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar progresso da quest: $e');
    }
  }

  bool claimQuestReward(String questId) {
    if (!_isInitialized) {
      debugPrint('⚠️ Tentativa de resgatar quest sem inicialização');
      return false;
    }

    try {
      final progress = state.dailyQuests[questId];
      final qDef = GameData.getQuestById(questId);

      if (progress == null || qDef == null) {
        debugPrint('⚠️ Quest ou progresso não encontrado: $questId');
        return false;
      }

      if (progress.isClaimed) {
        debugPrint('⚠️ Quest já foi resgatada: $questId');
        return false;
      }

      if (progress.currentCount < qDef.targetCount) {
        debugPrint(
            '⚠️ Quest não completa: $questId (${progress.currentCount}/${qDef.targetCount})');
        return false;
      }

      // Marcar quest como resgatada
      final newQuests = Map<String, QuestProgress>.from(state.dailyQuests);
      newQuests[questId] = progress.copyWith(isClaimed: true);

      // Adicionar recompensas
      final newState = state.copyWith(
        dailyQuests: newQuests,
        coins: (state.coins + qDef.rewardCoins).clamp(0, 999999),
        gems: (state.gems + qDef.rewardGems).clamp(0, 999999),
      );

      state = newState;

      // Atualizar conquista de quests completadas
      updateAchievementProgress(AchievementGoalType.questsCompletedCount, 1);

      _saveData(); // Não aguardar
      debugPrint(
          '✅ Recompensa da quest resgatada: $questId (+${qDef.rewardCoins} moedas, +${qDef.rewardGems} gemas)');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao resgatar recompensa da quest: $e');
      return false;
    }
  }

  void addCoins(int amount,
      {bool save = true,
      bool fromQuest = false,
      bool fromAchievement = false}) {
    if (!_isInitialized || amount <= 0) return;

    try {
      // Atualizar conquista apenas se não for de quest/achievement (evitar loop)
      if (!fromQuest && !fromAchievement) {
        updateAchievementProgress(AchievementGoalType.totalCoinsEarned, amount);
      }

      final newCoins = (state.coins + amount).clamp(0, 999999);
      state = state.copyWith(coins: newCoins);

      if (save) _saveData();
      debugPrint('✅ Moedas adicionadas: +$amount (total: $newCoins)');
    } catch (e) {
      debugPrint('❌ Erro ao adicionar moedas: $e');
    }
  }

  void addGems(int amount, {bool save = true, bool fromAchievement = false}) {
    if (!_isInitialized || amount <= 0) return;

    try {
      if (!fromAchievement) {
        updateAchievementProgress(AchievementGoalType.totalGemsEarned, amount);
      }

      final newGems = (state.gems + amount).clamp(0, 999999);
      state = state.copyWith(gems: newGems);

      if (save) _saveData();
      debugPrint('✅ Gemas adicionadas: +$amount (total: $newGems)');
    } catch (e) {
      debugPrint('❌ Erro ao adicionar gemas: $e');
    }
  }

  bool buyItem(ShopItem item) {
    if (!_isInitialized) {
      debugPrint('⚠️ Tentativa de comprar item sem inicialização');
      return false;
    }

    try {
      // Validações
      if (!item.isStackable && state.hasItem(item.id)) {
        debugPrint('⚠️ Item não empilhável já possuído: ${item.id}');
        return false;
      }

      if (!state.canAfford(item)) {
        debugPrint('⚠️ Recursos insuficientes para: ${item.name}');
        return false;
      }

      // Atualizar quantidades
      final newQuantities = Map<String, int>.from(state.itemQuantities);
      newQuantities[item.id] = (newQuantities[item.id] ?? 0) + 1;

      final newCollectedItems = Set<String>.from(state.collectedItemIds)
        ..add(item.id);

      // Deduzir custos
      final newCoins = item.coinPrice > 0
          ? (state.coins - item.coinPrice).clamp(0, 999999)
          : state.coins;

      final newGems = item.gemPrice > 0
          ? (state.gems - item.gemPrice).clamp(0, 999999)
          : state.gems;

      state = state.copyWith(
        coins: newCoins,
        gems: newGems,
        itemQuantities: newQuantities,
        collectedItemIds: newCollectedItems,
      );

      // Atualizar progresso
      updateQuestProgress(QuestType.buyItem, 1);
      updateAchievementProgress(
        AchievementGoalType.itemsCollectedCount,
        newCollectedItems.length,
        useNewValue: true,
      );
      updateAchievementProgress(
        AchievementGoalType.specificItemOwned,
        1,
        detail: item.id,
      );

      _saveData();
      debugPrint(
          '✅ Item comprado: ${item.name} (${item.coinPrice} moedas, ${item.gemPrice} gemas)');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao comprar item: $e');
      return false;
    }
  }

  void equipItem(String id) {
    if (!_isInitialized || id.isEmpty) return;

    try {
      final allItems = GameData.getShopItems(null);
      final item = allItems.where((item) => item.id == id).firstOrNull;

      if (item == null) {
        debugPrint('⚠️ Item não encontrado para equipar: $id');
        return;
      }

      if (item.category != ItemCategory.accessory) {
        debugPrint('⚠️ Item não é acessório: $id');
        return;
      }

      if (!state.hasItem(id)) {
        debugPrint('⚠️ Item não possuído: $id');
        return;
      }

      state = state.copyWith(equippedItemId: id);
      _saveData();
      debugPrint('✅ Item equipado: $id');
    } catch (e) {
      debugPrint('❌ Erro ao equipar item: $e');
    }
  }

  void unequipItem() {
    if (!_isInitialized) return;

    try {
      state = state.copyWith(clearEquippedItem: true);
      _saveData();
      debugPrint('✅ Item desequipado');
    } catch (e) {
      debugPrint('❌ Erro ao desequipar item: $e');
    }
  }

  bool consumeItem(String itemId) {
    if (!_isInitialized || itemId.isEmpty) return false;

    try {
      final currentQuantity = state.itemQuantities[itemId] ?? 0;
      if (currentQuantity <= 0) {
        debugPrint('⚠️ Item não disponível para consumo: $itemId');
        return false;
      }

      final newQuantities = Map<String, int>.from(state.itemQuantities);
      if (currentQuantity == 1) {
        newQuantities.remove(itemId);
      } else {
        newQuantities[itemId] = currentQuantity - 1;
      }

      state = state.copyWith(itemQuantities: newQuantities);
      _saveData();
      debugPrint(
          '✅ Item consumido: $itemId (restam: ${newQuantities[itemId] ?? 0})');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao consumir item: $e');
      return false;
    }
  }

  void addUxp(int amount, {bool fromAchievement = false}) {
    if (!_isInitialized || amount <= 0) return;

    try {
      final newUxp = (state.uxp + amount).clamp(0, 999999999);
      state = state.copyWith(uxp: newUxp);
      _saveData();
      debugPrint('✅ UXP adicionada: +$amount (total: $newUxp)');
    } catch (e) {
      debugPrint('❌ Erro ao adicionar UXP: $e');
    }
  }

  void setActiveEnvironmentItem(ShopItem item) {
    if (!_isInitialized) return;

    try {
      if (!state.hasItem(item.id)) {
        debugPrint('⚠️ Item de ambiente não possuído: ${item.id}');
        return;
      }

      if (item.category != ItemCategory.environment) {
        debugPrint('⚠️ Item não é de ambiente: ${item.id}');
        return;
      }

      if (item.assetPath != null) {
        // Wallpaper
        state = state.copyWith(activeWallpaperId: item.id);
      } else if (item.itemColor != null) {
        // Piso
        state = state.copyWith(activeFloorId: item.id);
      }

      _saveData();
      debugPrint('✅ Item de ambiente ativado: ${item.id}');
    } catch (e) {
      debugPrint('❌ Erro ao ativar item de ambiente: $e');
    }
  }

  void clearActiveWallpaper() {
    if (!_isInitialized) return;

    try {
      state = state.copyWith(clearWallpaper: true);
      _saveData();
      debugPrint('✅ Wallpaper removido');
    } catch (e) {
      debugPrint('❌ Erro ao remover wallpaper: $e');
    }
  }

  void clearActiveFloor() {
    if (!_isInitialized) return;

    try {
      state = state.copyWith(clearFloor: true);
      _saveData();
      debugPrint('✅ Piso removido');
    } catch (e) {
      debugPrint('❌ Erro ao remover piso: $e');
    }
  }

  void logCollectedPet(String petId) {
    if (!_isInitialized || petId.isEmpty) return;

    try {
      if (!state.collectedPetIds.contains(petId)) {
        final newCollectedPets = Set<String>.from(state.collectedPetIds)
          ..add(petId);
        state = state.copyWith(collectedPetIds: newCollectedPets);
        _saveData();
        debugPrint('✅ Pet coletado: $petId');
      }
    } catch (e) {
      debugPrint('❌ Erro ao registrar pet coletado: $e');
    }
  }

  void updateAchievementProgress(
    AchievementGoalType type,
    int valueToAddOrSet, {
    String? detail,
    bool useNewValue = false,
  }) {
    if (!_isInitialized) return;

    try {
      final newProgressMap =
          Map<String, AchievementProgress>.from(state.achievementProgress);
      bool changed = false;

      for (var achDef in AchievementData.allAchievements) {
        if (achDef.goalType == type &&
            (achDef.detail == null || achDef.detail == detail)) {
          final currentProg = newProgressMap[achDef.id] ??
              AchievementProgress(achievementId: achDef.id);

          // Skip se já completou e resgatou
          if (currentProg.isClaimed) continue;

          int newCurrentValue = useNewValue
              ? valueToAddOrSet
              : currentProg.currentProgress + valueToAddOrSet;

          newCurrentValue = newCurrentValue.clamp(0, achDef.targetValue);

          if (newCurrentValue != currentProg.currentProgress) {
            newProgressMap[achDef.id] =
                currentProg.copyWith(currentProgress: newCurrentValue);
            changed = true;
          }

          // Marcar como completado se atingiu o alvo
          if (newCurrentValue >= achDef.targetValue &&
              !currentProg.isCompleted) {
            newProgressMap[achDef.id] =
                newProgressMap[achDef.id]!.copyWith(isCompleted: true);
            changed = true;
            debugPrint('🏆 Conquista desbloqueada: ${achDef.title}');
          }
        }
      }

      if (changed) {
        state = state.copyWith(achievementProgress: newProgressMap);
        _saveData();
      }
    } catch (e) {
      debugPrint('❌ Erro ao atualizar progresso de conquista: $e');
    }
  }

  bool claimAchievementReward(String achievementId) {
    if (!_isInitialized) return false;

    try {
      final progress = state.achievementProgress[achievementId];
      final achDef = AchievementData.getAchievementById(achievementId);

      if (progress == null || achDef == null) {
        debugPrint('⚠️ Conquista ou progresso não encontrado: $achievementId');
        return false;
      }

      if (!progress.isCompleted || progress.isClaimed) {
        debugPrint('⚠️ Conquista não pode ser resgatada: $achievementId');
        return false;
      }

      // Marcar como resgatada
      final newProgressMap =
          Map<String, AchievementProgress>.from(state.achievementProgress);
      newProgressMap[achievementId] = progress.copyWith(isClaimed: true);

      // Adicionar recompensas
      final newState = state.copyWith(
        achievementProgress: newProgressMap,
        coins: (state.coins + achDef.rewardCoins).clamp(0, 999999),
        gems: (state.gems + achDef.rewardGems).clamp(0, 999999),
        uxp: (state.uxp + achDef.rewardUxp).clamp(0, 999999999),
      );

      state = newState;
      _saveData();
      debugPrint('✅ Recompensa de conquista resgatada: ${achDef.title}');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao resgatar recompensa de conquista: $e');
      return false;
    }
  }

  // NOVO: Métodos de debug e manutenção
  Future<void> forceSync() async {
    if (_currentFirebaseUserId != null) {
      await _saveData();
      debugPrint('🔄 Sincronização forçada concluída');
    }
  }

  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'currentUserId': _currentFirebaseUserId,
      'state': {
        'coins': state.coins,
        'gems': state.gems,
        'uxp': state.uxp,
        'itemsCount': state.itemQuantities.length,
        'questsCount': state.dailyQuests.length,
        'achievementsCount': state.achievementProgress.length,
      },
      'validation': state.validateData(),
    };
  }
}
