enum AchievementGoalType {
  feedCount, // Número total de vezes que alimentou qualquer pet
  petLevelReached, // Nível mais alto alcançado por qualquer pet
  itemsCollectedCount, // Número de itens únicos diferentes adquiridos (não quantidade)
  questsCompletedCount, // Número total de missões diárias completadas e resgatadas
  specificPetLevel, // Atingir um nível específico com um tipo de pet (detail: petId)
  totalCoinsEarned, // Total de moedas ganhas (excluindo recompensas de conquista)
  totalGemsEarned, // Total de gemas ganhas (excluindo recompensas de conquista)
  minigamesPlayedCount, // Número de vezes que um minijogo foi jogado até o fim
  specificItemOwned, // Possuir um item específico (detail: itemId)
  // Adicionar mais tipos conforme necessário
}

enum ItemCategory {
  accessory,
  food,
  toy,
  medicine,
  bath,
  grooming,
  environment,
  special
}

enum QuestType {
  feed,
  play,
  buyItem,
  earnCoins,
  useToy,
  useMedicine,
  giveBath,
  groomPet,
  playMinigame
}
