// lib/features/pet_care/notifiers/active_pet_notifier.dart
// ALTERADO: Implementação robusta com tratamento de erros e validações
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
  String? _currentFirebaseUserId;
  bool _isInitialized = false;

  ActivePetNotifier(this._persistenceService, this._ref) : super(null) {
    debugPrint('🐾 ActivePetNotifier inicializado');
  }

  @override
  void dispose() {
    _moodDecayTimer?.cancel();
    debugPrint('🐾 ActivePetNotifier descartado');
    super.dispose();
  }

  // NOVO: Getters para status
  bool get isInitialized => _isInitialized;
  String? get currentUserId => _currentFirebaseUserId;
  bool get hasPet => state != null;

  Future<void> _saveCurrentPetStats() async {
    if (state == null || _currentFirebaseUserId == null) {
      debugPrint('⚠️ Tentativa de salvar stats sem pet ou usuário ativo');
      return;
    }

    try {
      await _persistenceService.savePetStats(
        _currentFirebaseUserId!,
        state!.definition.id,
        state!.stats,
      );
      debugPrint('✅ Stats do pet salvos: ${state!.definition.name}');
    } catch (e) {
      debugPrint('❌ Erro ao salvar stats do pet: $e');
    }
  }

  Future<void> loadInitialPet(String firebaseUserId) async {
    if (_currentFirebaseUserId == firebaseUserId && _isInitialized) {
      debugPrint('ℹ️ Pet já carregado para este usuário');
      return;
    }

    try {
      debugPrint('🐾 Carregando pet inicial para usuário: $firebaseUserId');
      _currentFirebaseUserId = firebaseUserId;

      // Parar timer anterior se existir
      _moodDecayTimer?.cancel();

      // Carregar ID do pet selecionado
      final selectedPetId =
          await _persistenceService.loadSelectedPetId(firebaseUserId);

      if (selectedPetId == null) {
        debugPrint('ℹ️ Nenhum pet selecionado para o usuário');
        state = null;
        _isInitialized = true;
        return;
      }

      // Buscar definição do pet
      final petDefinition = GameData.getPetDefinitionById(selectedPetId);
      if (petDefinition == null) {
        debugPrint('⚠️ Definição de pet não encontrada: $selectedPetId');
        state = null;
        _isInitialized = true;
        return;
      }

      // Carregar stats do pet
      PetStats petStats;
      try {
        final loadedStats = await _persistenceService.loadPetStats(
            firebaseUserId, selectedPetId);
        petStats = loadedStats ?? PetStats();
      } catch (e) {
        debugPrint('⚠️ Erro ao carregar stats, usando padrão: $e');
        petStats = PetStats();
      }

      // Calcular decaimento por tempo offline
      petStats = _calculateDecay(petStats);

      // Definir estado do pet
      state = ActivePet(definition: petDefinition, stats: petStats);

      // Iniciar ciclo de decaimento
      _startMoodDecayCycle();

      _isInitialized = true;
      debugPrint(
          '✅ Pet carregado: ${petDefinition.name} (Level ${petStats.level})');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro crítico ao carregar pet inicial: $e');
      debugPrint('Stack trace: $stackTrace');

      state = null;
      _currentFirebaseUserId = firebaseUserId;
      _isInitialized = true;
    }
  }

  Future<void> selectPet(PetDefinition definition) async {
    if (_currentFirebaseUserId == null) {
      debugPrint('❌ Tentativa de selecionar pet sem UID de usuário');
      return;
    }

    try {
      debugPrint('🎯 Selecionando pet: ${definition.name}');

      // Parar timer anterior
      _moodDecayTimer?.cancel();

      // Carregar ou criar stats para este pet
      PetStats petStats;
      try {
        final loadedStats = await _persistenceService.loadPetStats(
          _currentFirebaseUserId!,
          definition.id,
        );
        petStats = loadedStats ?? PetStats();
      } catch (e) {
        debugPrint('⚠️ Erro ao carregar stats, criando novos: $e');
        petStats = PetStats();
      }

      // Calcular decaimento
      petStats = _calculateDecay(petStats);

      // Definir como pet ativo
      state = ActivePet(definition: definition, stats: petStats);

      // Salvar seleção
      await _persistenceService.saveSelectedPetId(
          _currentFirebaseUserId!, definition.id);
      await _persistenceService.savePetStats(
          _currentFirebaseUserId!, definition.id, petStats);

      // Registrar pet como coletado
      _ref.read(userProvider.notifier).logCollectedPet(definition.id);

      // Iniciar ciclo de decaimento
      _startMoodDecayCycle();

      debugPrint('✅ Pet selecionado com sucesso: ${definition.name}');
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao selecionar pet: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _startMoodDecayCycle() {
    _moodDecayTimer?.cancel();

    if (state == null || _currentFirebaseUserId == null) {
      debugPrint('⚠️ Não é possível iniciar ciclo sem pet ou usuário');
      return;
    }

    _moodDecayTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (state == null || _currentFirebaseUserId == null) {
        debugPrint('⚠️ Parando ciclo de decaimento: pet ou usuário removido');
        timer.cancel();
        return;
      }

      try {
        // Aplicar decaimento gradual
        PetStats newStats =
            _calculateDecay(state!.stats, applyDecayAmount: true);

        // Penalidade adicional se estiver com muita fome
        if (newStats.isVeryHungry && newStats.happiness > 10) {
          newStats = newStats.copyWith(
            happiness: (newStats.happiness - 5).clamp(0, 100),
          );
        }

        state = state!.copyWith(stats: newStats);
        _saveCurrentPetStats(); // Não aguardar para não bloquear

        debugPrint(
            '🔄 Decaimento aplicado: Felicidade=${newStats.happiness}, Fome=${newStats.hunger}');
      } catch (e) {
        debugPrint('❌ Erro no ciclo de decaimento: $e');
      }
    });

    debugPrint('⏰ Ciclo de decaimento iniciado');
  }

  PetStats _calculateDecay(PetStats stats, {bool applyDecayAmount = false}) {
    try {
      final now = DateTime.now();
      final diff = now.difference(stats.lastUpdate);

      int happinessDecrease = 0;
      int hungerIncrease = 0;

      if (applyDecayAmount) {
        // Decaimento por tick (a cada 5 minutos)
        happinessDecrease = 1;
        hungerIncrease = 2;
      } else {
        // Decaimento proporcional ao tempo offline
        final minutesPassed = diff.inMinutes;

        // Configurar limites para evitar penalidades excessivas
        happinessDecrease = (minutesPassed ~/ 15).clamp(0, 30); // Max 30 pontos
        hungerIncrease = (minutesPassed ~/ 10).clamp(0, 50); // Max 50 pontos

        if (minutesPassed > 0) {
          debugPrint(
              '📊 Calculando decaimento: ${minutesPassed}min offline = -$happinessDecrease felicidade, +$hungerIncrease fome');
        }
      }

      return stats.copyWith(
        happiness: (stats.happiness - happinessDecrease).clamp(0, 100),
        hunger: (stats.hunger + hungerIncrease).clamp(0, 100),
        lastUpdate: now,
      );
    } catch (e) {
      debugPrint('❌ Erro no cálculo de decaimento: $e');
      return stats.copyWith(lastUpdate: DateTime.now());
    }
  }

  void addXp(int amount) {
    if (state == null || amount <= 0) {
      debugPrint('⚠️ Tentativa de adicionar XP inválida');
      return;
    }

    try {
      int newXp = state!.stats.xp + amount;
      int xpForNext = state!.stats.xpForNextLevel;

      if (xpForNext > 0 && newXp >= xpForNext) {
        // Level up!
        _levelUp(newXp - xpForNext);
      } else if (xpForNext > 0) {
        // Apenas adicionar XP
        state = state!.copyWith(stats: state!.stats.copyWith(xp: newXp));
      }
      // Se xpForNext <= 0, está no nível máximo

      _saveCurrentPetStats();
      debugPrint('✅ XP adicionado: +$amount (total: ${state!.stats.xp})');
    } catch (e) {
      debugPrint('❌ Erro ao adicionar XP: $e');
    }
  }

  void _levelUp(int leftoverXp) {
    if (state == null) return;

    try {
      final currentLevel = state!.stats.level;
      final newLevel = currentLevel + 1;

      state = state!.copyWith(
        stats: state!.stats.copyWith(
          level: newLevel,
          xp: leftoverXp,
        ),
      );

      // Recompensas do level up
      final coinReward = 50 * newLevel;
      const gemReward = 5;
      final uxpReward = 25 * newLevel;

      _ref.read(userProvider.notifier).addCoins(coinReward, fromQuest: true);
      _ref.read(userProvider.notifier).addGems(gemReward);
      _ref.read(userProvider.notifier).addUxp(uxpReward);

      debugPrint(
          '🎉 LEVEL UP! ${state!.definition.name} alcançou nível $newLevel');
      debugPrint(
          '🎁 Recompensas: +$coinReward moedas, +$gemReward gemas, +$uxpReward UXP');
    } catch (e) {
      debugPrint('❌ Erro no level up: $e');
    }
  }

  bool feedPetWithItem(ShopItem foodItem) {
    if (state == null) {
      debugPrint('⚠️ Tentativa de alimentar sem pet ativo');
      return false;
    }

    if (foodItem.category != ItemCategory.food) {
      debugPrint('⚠️ Item não é comida: ${foodItem.id}');
      return false;
    }

    if (state!.stats.isSatiated) {
      debugPrint('⚠️ Pet já está saciado');
      return false;
    }

    try {
      // Tentar consumir o item
      final consumed =
          _ref.read(userProvider.notifier).consumeItem(foodItem.id);
      if (!consumed) {
        debugPrint('⚠️ Não foi possível consumir item: ${foodItem.id}');
        return false;
      }

      // Atualizar progresso de quest
      _ref.read(userProvider.notifier).updateQuestProgress(QuestType.feed, 1);

      // Adicionar XP
      addXp(10);

      // Aplicar efeitos da alimentação
      final newStats = state!.stats.copyWith(
        hunger: (state!.stats.hunger - 45).clamp(0, 100),
        happiness: (state!.stats.happiness + 20).clamp(0, 100),
        lastUpdate: DateTime.now(),
      );

      state = state!.copyWith(stats: newStats);

      // Recompensa em moedas
      _ref.read(userProvider.notifier).addCoins(1, save: true, fromQuest: true);

      _saveCurrentPetStats();
      debugPrint('✅ Pet alimentado com ${foodItem.name}');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao alimentar pet: $e');
      return false;
    }
  }

  bool playWithPet() {
    if (state == null) {
      debugPrint('⚠️ Tentativa de brincar sem pet ativo');
      return false;
    }

    if (state!.stats.isInBadMood) {
      debugPrint('⚠️ Pet está de mau humor para brincar');
      return false;
    }

    try {
      // Atualizar progresso de quest
      _ref.read(userProvider.notifier).updateQuestProgress(QuestType.play, 1);

      // Adicionar XP
      addXp(15);

      // Aplicar efeitos da brincadeira
      final newStats = state!.stats.copyWith(
        happiness: (state!.stats.happiness + 25).clamp(0, 100),
        hunger: (state!.stats.hunger + 8).clamp(0, 100), // Brincar dá fome
        lastUpdate: DateTime.now(),
      );

      state = state!.copyWith(stats: newStats);

      // Recompensa em moedas
      _ref.read(userProvider.notifier).addCoins(2, save: true, fromQuest: true);

      _saveCurrentPetStats();
      debugPrint('✅ Brincou com ${state!.definition.name}');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao brincar com pet: $e');
      return false;
    }
  }

  bool useToy(ShopItem toyItem) {
    if (state == null) {
      debugPrint('⚠️ Tentativa de usar brinquedo sem pet ativo');
      return false;
    }

    if (toyItem.category != ItemCategory.toy) {
      debugPrint('⚠️ Item não é brinquedo: ${toyItem.id}');
      return false;
    }

    if (state!.stats.isInBadMood) {
      debugPrint('⚠️ Pet está de mau humor para brincar');
      return false;
    }

    try {
      // Brinquedos não são consumidos, apenas usados
      _ref.read(userProvider.notifier).updateQuestProgress(QuestType.useToy, 1);

      // Adicionar XP
      addXp(20);

      // Aplicar efeitos do brinquedo (mais efetivo que brincadeira normal)
      final newStats = state!.stats.copyWith(
        happiness: (state!.stats.happiness + 30).clamp(0, 100),
        hunger: (state!.stats.hunger + 10).clamp(0, 100),
        lastUpdate: DateTime.now(),
      );

      state = state!.copyWith(stats: newStats);

      // Recompensa em moedas
      _ref.read(userProvider.notifier).addCoins(3, save: true, fromQuest: true);

      _saveCurrentPetStats();
      debugPrint(
          '✅ Usado brinquedo ${toyItem.name} com ${state!.definition.name}');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao usar brinquedo: $e');
      return false;
    }
  }

  bool useMedicine(ShopItem medicineItem) {
    if (state == null) {
      debugPrint('⚠️ Tentativa de usar remédio sem pet ativo');
      return false;
    }

    if (medicineItem.category != ItemCategory.medicine) {
      debugPrint('⚠️ Item não é remédio: ${medicineItem.id}');
      return false;
    }

    try {
      // Consumir remédio
      final consumed =
          _ref.read(userProvider.notifier).consumeItem(medicineItem.id);
      if (!consumed) {
        debugPrint('⚠️ Não foi possível consumir remédio: ${medicineItem.id}');
        return false;
      }

      // Atualizar progresso de quest
      _ref
          .read(userProvider.notifier)
          .updateQuestProgress(QuestType.useMedicine, 1);

      // Adicionar XP
      addXp(15);

      // Aplicar efeitos do remédio
      final newStats = state!.stats.copyWith(
        happiness: (state!.stats.happiness + 35).clamp(0, 100),
        lastUpdate: DateTime.now(),
      );

      state = state!.copyWith(stats: newStats);

      _saveCurrentPetStats();
      debugPrint(
          '✅ Remédio ${medicineItem.name} usado em ${state!.definition.name}');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao usar remédio: $e');
      return false;
    }
  }

  bool giveBath(ShopItem bathItem) {
    if (state == null) {
      debugPrint('⚠️ Tentativa de dar banho sem pet ativo');
      return false;
    }

    if (bathItem.category != ItemCategory.bath) {
      debugPrint('⚠️ Item não é de banho: ${bathItem.id}');
      return false;
    }

    try {
      // Consumir item de banho
      final consumed =
          _ref.read(userProvider.notifier).consumeItem(bathItem.id);
      if (!consumed) {
        debugPrint(
            '⚠️ Não foi possível consumir item de banho: ${bathItem.id}');
        return false;
      }

      // Atualizar progresso de quest
      _ref
          .read(userProvider.notifier)
          .updateQuestProgress(QuestType.giveBath, 1);

      // Adicionar XP
      addXp(20);

      // Aplicar efeitos do banho
      final newStats = state!.stats.copyWith(
        happiness: (state!.stats.happiness + 30).clamp(0, 100),
        lastUpdate: DateTime.now(),
      );

      state = state!.copyWith(stats: newStats);

      _saveCurrentPetStats();
      debugPrint(
          '✅ Banho dado em ${state!.definition.name} com ${bathItem.name}');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao dar banho: $e');
      return false;
    }
  }

  bool groomPet(ShopItem groomingItem) {
    if (state == null) {
      debugPrint('⚠️ Tentativa de tosar sem pet ativo');
      return false;
    }

    if (groomingItem.category != ItemCategory.grooming) {
      debugPrint('⚠️ Item não é de tosa: ${groomingItem.id}');
      return false;
    }

    try {
      // Consumir item de tosa
      final consumed =
          _ref.read(userProvider.notifier).consumeItem(groomingItem.id);
      if (!consumed) {
        debugPrint(
            '⚠️ Não foi possível consumir item de tosa: ${groomingItem.id}');
        return false;
      }

      // Atualizar progresso de quest
      _ref
          .read(userProvider.notifier)
          .updateQuestProgress(QuestType.groomPet, 1);

      // Adicionar XP
      addXp(18);

      // Aplicar efeitos da tosa
      final newStats = state!.stats.copyWith(
        happiness: (state!.stats.happiness + 22).clamp(0, 100),
        lastUpdate: DateTime.now(),
      );

      state = state!.copyWith(stats: newStats);

      _saveCurrentPetStats();
      debugPrint(
          '✅ Tosa feita em ${state!.definition.name} com ${groomingItem.name}');
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao tosar pet: $e');
      return false;
    }
  }

  Future<void> clearActivePet() async {
    try {
      _moodDecayTimer?.cancel();
      state = null;

      if (_currentFirebaseUserId != null) {
        await _persistenceService.saveSelectedPetId(
            _currentFirebaseUserId!, null);
      }

      debugPrint('✅ Pet ativo removido');
    } catch (e) {
      debugPrint('❌ Erro ao remover pet ativo: $e');
    }
  }

  void clearLocalActivePetData() {
    try {
      _moodDecayTimer?.cancel();
      state = null;
      _currentFirebaseUserId = null;
      _isInitialized = false;
      debugPrint('✅ Dados locais do pet limpos');
    } catch (e) {
      debugPrint('❌ Erro ao limpar dados locais do pet: $e');
    }
  }

  // NOVO: Métodos de debug e manutenção
  Future<void> forceSync() async {
    if (state != null && _currentFirebaseUserId != null) {
      await _saveCurrentPetStats();
      debugPrint('🔄 Sincronização forçada do pet concluída');
    }
  }

  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'currentUserId': _currentFirebaseUserId,
      'hasPet': hasPet,
      'pet': state != null
          ? {
              'id': state!.definition.id,
              'name': state!.definition.name,
              'level': state!.stats.level,
              'happiness': state!.stats.happiness,
              'hunger': state!.stats.hunger,
              'xp': state!.stats.xp,
              'isInBadMood': state!.stats.isInBadMood,
              'isSatiated': state!.stats.isSatiated,
            }
          : null,
      'timerActive': _moodDecayTimer?.isActive ?? false,
    };
  }

  // NOVO: Método para aplicar boost temporário
  void applyTemporaryBoost({
    int happinessBoost = 0,
    int hungerReduction = 0,
    String reason = 'Boost temporário',
  }) {
    if (state == null) return;

    try {
      final newStats = state!.stats.copyWith(
        happiness: (state!.stats.happiness + happinessBoost).clamp(0, 100),
        hunger: (state!.stats.hunger - hungerReduction).clamp(0, 100),
        lastUpdate: DateTime.now(),
      );

      state = state!.copyWith(stats: newStats);
      _saveCurrentPetStats();
      debugPrint(
          '✨ Boost aplicado: $reason (+$happinessBoost felicidade, -$hungerReduction fome)');
    } catch (e) {
      debugPrint('❌ Erro ao aplicar boost: $e');
    }
  }
}
