// lib/data/achievement_data.dart (NOVO)
import 'package:petverse/shared/enums/enums.dart';
import 'package:petverse/shared/models/achievement_definition.dart';

class AchievementData {
  static final List<AchievementDefinition> allAchievements = [
    const AchievementDefinition(
        id: 'feed_10',
        title: 'Primeiros Lanches',
        description: 'Alimente seu pet 10 vezes.',
        goalType: AchievementGoalType.feedCount,
        targetValue: 10,
        rewardCoins: 20,
        rewardUxp: 10,
        iconEmoji: '🍼'),
    const AchievementDefinition(
        id: 'feed_100',
        title: 'Amigo Gourmet',
        description: 'Alimente seu pet 100 vezes.',
        goalType: AchievementGoalType.feedCount,
        targetValue: 100,
        rewardCoins: 100,
        rewardGems: 5,
        rewardUxp: 50,
        iconEmoji: '🍲'),
    const AchievementDefinition(
        id: 'pet_level_5',
        title: 'Companheiro Crescendo',
        description: 'Alcance o nível 5 com qualquer pet.',
        goalType: AchievementGoalType.petLevelReached,
        targetValue: 5,
        rewardCoins: 50,
        rewardUxp: 25,
        iconEmoji: '🌱'),
    const AchievementDefinition(
        id: 'dog_level_3',
        title: 'Melhor Amigo Cão',
        description: 'Alcance o nível 3 com um Cachorro.',
        goalType: AchievementGoalType.specificPetLevel,
        targetValue: 3,
        detail: 'dog',
        rewardCoins: 30,
        iconEmoji: '🐶'),
    const AchievementDefinition(
        id: 'cat_level_3',
        title: 'Companheiro Felino',
        description: 'Alcance o nível 3 com um Gato.',
        goalType: AchievementGoalType.specificPetLevel,
        targetValue: 3,
        detail: 'cat',
        rewardCoins: 30,
        iconEmoji: '🐱'),
    const AchievementDefinition(
        id: 'collect_5_items',
        title: 'Pequeno Colecionador',
        description: 'Adquira 5 itens diferentes (não acessórios).',
        goalType: AchievementGoalType.itemsCollectedCount,
        targetValue: 5,
        rewardGems: 2,
        rewardUxp: 15,
        iconEmoji: '🛍️'),
    // Exemplo de conquista para um item específico. A lógica de "todos os chapéus" seria mais complexa.
    const AchievementDefinition(
        id: 'own_crown',
        title: 'Realeza Adquirida',
        description: 'Adquira a Coroa Real.',
        goalType: AchievementGoalType.specificItemOwned,
        targetValue: 1,
        detail: 'crown',
        rewardCoins: 50,
        iconEmoji: '👑'),
    const AchievementDefinition(
        id: 'complete_10_quests',
        title: 'Aventureiro Diário',
        description: 'Complete 10 missões diárias.',
        goalType: AchievementGoalType.questsCompletedCount,
        targetValue: 10,
        rewardCoins: 75,
        rewardGems: 3,
        rewardUxp: 40,
        iconEmoji: '📜'),
    const AchievementDefinition(
        id: 'play_20_minigames',
        title: 'Rei dos Jogos',
        description: 'Jogue minijogos 20 vezes.',
        goalType: AchievementGoalType.minigamesPlayedCount,
        targetValue: 20,
        rewardCoins: 50,
        rewardUxp: 30,
        iconEmoji: '🎮'),
    const AchievementDefinition(
        id: 'earn_1000_coins',
        title: 'Poupador Nato',
        description: 'Ganhe um total de 1000 moedas.',
        goalType: AchievementGoalType.totalCoinsEarned,
        targetValue: 1000,
        rewardGems: 10,
        rewardUxp: 75,
        iconEmoji: '💰'),
  ];

  static AchievementDefinition? getAchievementById(String id) {
    try {
      return allAchievements.firstWhere((ach) => ach.id == id);
    } catch (e) {
      return null;
    }
  }
}
